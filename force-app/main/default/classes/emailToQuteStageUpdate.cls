global class emailToQuteStageUpdate implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('envelope==> ' + envelope);
        System.debug('email==> ' + email);
        System.debug('emailText=> ' + email.plainTextBody);
        String plainTextBody = email.plainTextBody;
        System.debug('PlainTextBody: ' + plainTextBody);
        System.debug('Subject: ' + email.Subject);
        System.debug('result==> ' + result);

        String jsonString = null;

        plainTextBody = plainTextBody.replaceAll('\\s', '');
        if (plainTextBody.contains('Approve') || plainTextBody.contains('approve')) {
            jsonString = 'Approve';
        } else if (plainTextBody.contains('Reject') || plainTextBody.contains('reject')) {
            jsonString = 'Reject';
        }
		String msg = '';
        System.debug('JSON value: ' + jsonString);

        if (email.Subject.startsWith('Re: Sandbox: Quote Approval : ')) {
            email.Subject = email.Subject.substringAfter('Re: Sandbox: Quote Approval : ').trim();
        }
        Quote quoteStage = [SELECT Id, Name, Status,OwnerId,QuoteNumber FROM Quote WHERE QuoteNumber = :email.Subject];

        System.debug('quoteStage' + quoteStage);
        System.debug('123' + jsonString + '123');

        String activityMessage = '';
        if (jsonString == 'Approve') {
            if (quoteStage.Status == 'Rejected') {
                quoteStage.Status = 'Approved';
                activityMessage = 'Approved';
                //sendCustomNotification(quoteStage.OwnerId); // Send a custom notification
            } else {
                msg = 'Your request has been Approved';
                completeTask(quoteStage.id,quoteStage.OwnerId,msg);
                quoteStage.Status = 'Approved';
                
                //For E-Stamping
                System.debug('quoteStage : '+quoteStage.id); 
            	List<ContentVersion> conVers = [SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId, Record_Id__c, History_Tracker_Id__c FROM ContentVersion WHERE Record_Id__c =: quoteStage.Id +'E-Stamping' Order by CreatedDate Desc Limit 1];
                System.debug('conVers : '+ conVers);
                History_Tracker__c hsTracker = [Select Id, Content_Version__c From History_Tracker__c Where Id =: conVers[0].History_Tracker_Id__c];
                
                Blob verData = conVers[0].VersionData;
                String str = verData.toString();
                System.debug('@@@str : '+ str);
                PageReference docPage = Page.DocumentPreview;
                docPage.setRedirect(true);
                docPage.getParameters().put('conVirId', conVers[0].Id);
                Blob contentBody = docPage.getContentAsPDF(); 
                
                
                System.debug('contentBody : '+ contentBody);
                
                ContentVersion cv1 = new ContentVersion();
                cv1.Title = conVers[0].Title +' E-Stamping.Pdf';
                cv1.PathOnClient = conVers[0].Title +' E-Stamping.Pdf';
                cv1.VersionData =  contentBody;
                cv1.IsMajorVersion = false;
                cv1.Record_Id__c = quoteStage.Id+'03';
                insert cv1; 
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocumentId;
                cDocLink.LinkedEntityId = quoteStage.Id; 
                cDocLink.ShareType = 'V';
                cDocLink.Visibility = 'AllUsers'; 
                Insert cDocLink; 
                
                Update new History_Tracker__c(Id = hsTracker.id, Content_Version__c = conVers[0].Id);     
            }
        } else if (jsonString == 'Reject') {
            if (quoteStage.Status == 'Approved') {
                quoteStage.Status = 'Rejected';
            } else {
                msg = 'Your request has been Rejected';
                completeTask(quoteStage.id,quoteStage.OwnerId,msg);
                quoteStage.Status = 'Rejected';
            }
            activityMessage = 'Rejected';
        } else {
            quoteStage.Status = 'Draft';
            activityMessage = 'Draft';
        }

        Update quoteStage;

        logActivity(quoteStage.Id, activityMessage);

        //System.debug('quoteStage' + quoteStage);
        return result;
    }

    public void logActivity(Id recordId, String description) {
        Quote qu =[Select id,ownerId from Quote where id =: recordId];

        Task task = new Task();
        task.WhatId = recordId;
        task.OwnerId = qu.ownerId;
        task.Subject = 'Approval Status';
        task.ActivityDate = Date.today();
        task.Status = 'Completed';
        task.Description = description;

        insert task;
    }

   public void completeTask(Id recordId , Id userId,string msg) {
        system.debug('recordID'+recordId);
        system.debug('userId'+userId);

        List<Task> tasksToComplete = [SELECT Id FROM Task WHERE WhatId = :recordId AND Status != 'Completed'];
       system.debug('tasksToComplete'+tasksToComplete);
        for (Task t : tasksToComplete) {
            system.debug('tasks80');
            t.Status = 'Completed';
        }
        update tasksToComplete;
        
         CustomNotificationType notificationType = 
           [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Mail_To_MD'];
                system.debug('notificationType'+notificationType);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
       				 system.debug('recordID'+recordId);
        			system.debug('userId'+userId);
                notification.setTitle('Response to your Approval Request.');
                notification.setBody(msg);
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(recordId);
                notification.send(new set<String>{userId});
        system.debug('notification'+notification);
    }
}