public class SendEmailToMDController {
    @AuraEnabled
    public static String checkValidations(String recordId) { 
        system.debug('recordId'+recordId);
        List<ContentVersion> conVers = [SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId, Record_Id__c FROM ContentVersion WHERE Record_Id__c =: recordId +'02' Order by CreatedDate Desc Limit 1];
        
        
        Quote quoteRecord = [SELECT Id, Name, QuoteNumber,Approval_Check_RSM__c, Owner.Name,Account.name,GrandTotal ,Status,Customer_Agreed__c FROM Quote WHERE Id = :recordId LIMIT 1];
        system.debug('quoteRecord'+quoteRecord);
        if(quoteRecord.Customer_Agreed__c != true){
            return 'Customer invalid';
        }else if (quoteRecord.Status != 'Needs Review'){
            return 'Invalid Stage';
        }else if (quoteRecord.Approval_Check_RSM__c != true){
            return 'Not approved';
        }else if (conVers.isEmpty()){
            return 'Generate Document';
        }else{
            return 'Empty List';
        }
    }
    
    
    
    
    
    @AuraEnabled
    public static void sendEmailWithPDF(String recordId) { 
        system.debug('recordId'+recordId);
        List<ContentVersion> conVers = [SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId, Record_Id__c FROM ContentVersion WHERE Record_Id__c =: recordId +'02' Order by CreatedDate Desc Limit 1];
        if(!conVers.isEmpty()){
            if (String.isNotBlank(recordId) && recordId.startsWith('0Q0')) {
                System.debug('Yes');
                Quote quoteRecord = [SELECT Id, Name, QuoteNumber,Approval_Check_RSM__c, Owner.Name,Account.name,GrandTotal ,Status,Customer_Agreed__c FROM Quote WHERE Id = :recordId LIMIT 1];
                
                try { 
                    Blob documentBlob;
                    
                    if (conVers != null && conVers.size() > 0) {
                        ContentVersion contentVersion = conVers[0];
                        documentBlob = [SELECT VersionData FROM ContentVersion WHERE Id = :contentVersion.Id].VersionData;
                    }
                    
                    String MdEmail = System.Label.MD_Email;
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Quote Approval : '+quoteRecord.QuoteNumber);
                    email.setReplyTo('truecallersalesforce2@1dfaevnofvdgvkz381ghin16eg1d232z798q4v4fsw3an5rhhn.1m-czz1eak.cs117.apex.sandbox.salesforce.com');
                    String emailBody = '<html><head></head><body><p>Dear Sir,</p><p>Request you to approve attached quote. Following are the details:</p><p> Customer Name: '+quoteRecord.Account.name+'</p><p>Amount: '+quoteRecord.GrandTotal+'</p><p>ASM Name: '+quoteRecord.Owner.Name+'</p><p>Quote Number: '+quoteRecord.QuoteNumber+'</p><br/><p>Request you to please responsed as Approved or Reject.</p><b>Best Regards,</b><br/><b>Truecaller team.</b></body></html>';
                    
                    email.setHtmlBody(emailBody);
                    
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(conVers[0].Title + '-Quote.pdf');
                    attachment.setContentType('application/'+conVers[0].FileType);
                    attachment.setBody(conVers[0].VersionData);
                    
                    email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
                    email.setToAddresses(new List<String>{MdEmail});
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    
                    List<Task> notificationTasks = new List<Task>();
                    notificationTasks.add(createNotificationTask(quoteRecord.Id));
                    insert notificationTasks;
                    
                    // sendCustomNotification(quoteRecord.OwnerId); // Send the custom notification
                    
                } catch (Exception e) {
                    system.debug(e.getMessage());
                }
            }
        }
    }
    
    private static Task createNotificationTask(Id quoteId) {
        Quote qu =[Select id,ownerId,Status from Quote where id =: quoteId];
        qu.Status = 'In Review';
        update qu;
        User usr =  [SELECT Id,UserRoleId,ProfileId,ManagerId from User where  Id =: qu.ownerId];
        Task notificationTask = new Task();
        notificationTask.WhatId = quoteId;
        //notificationTask.OwnerId = usr.ManagerId;
        notificationTask.Subject = 'Approval Request';
        notificationTask.ActivityDate = Date.today();
        notificationTask.Status = 'Not Started';
        notificationTask.Priority = 'Normal';
        notificationTask.Description = 'Your process is currently underway';
        
        return notificationTask;
    }
    
    /*private static void sendCustomNotification(Id userId) {


CustomNotificationType notificationType = 
[SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Mail_To_MD'];

Messaging.CustomNotification notification = new Messaging.CustomNotification();
notification.setTitle('Mail_To_MD');
notification.setBody('Your request has been sent to MD' );
notification.setNotificationTypeId(notificationType.Id);
notification.setTargetId(userId);
notification.send(new set<String>{userId});
}*/
    
}