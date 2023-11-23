/*
@CreationDate    July 30 2023                                                                    
@Author          Rajesh Kumar & Ravi Jangid
@Description     Method for Send last create Date Attachment to the Contact Email Address & generated also mail for Accepted & Rejected.
@Invoked from  	'View Document' - LWC Cmp Button on Record Page
*/
public class emailToCustomerCtrl {
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }

    
    @AuraEnabled(cacheable=true)
    public static List <DataWrapper> getContactRole(string recId){
        List<DataWrapper> dataWrapperLst = new List <DataWrapper>();
        system.debug('recId '+recId);
        List<OpportunityContactRole> ContRoleLst = [SELECT Id, Opportunity.Name,Contact.Id, Contact.Email, Contact.Name, Role, isPrimary FROM OpportunityContactRole Where OpportunityId =: recId];
        for(OpportunityContactRole Con :ContRoleLst){
            dataWrapperLst.add(new DataWrapper(Con.Contact.Id,Con.Contact.Name,Con.Role, Con.isPrimary,Con.Contact.Email,con.Opportunity.Name));
        }
        system.debug('ContRoleLst '+ContRoleLst);
        return dataWrapperLst;
        
    }
    @AuraEnabled
    public static String getContactEmail(List <String> conRecIds){
        List<Quote> quoteLst = [SELECT Id, account.HMC_Contact_Email__c  FROM Quote WHERE Id IN :conRecIds];
        System.debug('quoteLst :'+ quoteLst);
        //List<Contact> contactLst = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN :conRecIds];
        return quoteLst[0].account.HMC_Contact_Email__c;
    }
    @AuraEnabled
    public static List <ContentDocumentLink> getAttachment (string recId){
        system.debug('recId '+recId);
        List<ContentDocumentLink> contentLinkLst =  [SELECT Id,LinkedEntity.Name, LinkedEntityId, ContentDocumentId,ContentDocument.Title,
                                                     ContentDocument.CreatedDate,ContentDocument.FileType FROM ContentDocumentLink
                                                     WHERE LinkedEntityId=:recId order by ContentDocument.CreatedDate DESC Limit 1];
        system.debug('contentLinkLst '+contentLinkLst[0].ContentDocument.CreatedDate);
        
        return contentLinkLst;
    }
    
    @AuraEnabled
    public static String SendEmail(List<String> Emails,String Body,String recId,String subj, List<String>contactIds) {
        System.debug('------------');
        System.debug('1 '+ Emails);
        System.debug('2 '+ Body);
        System.debug('3 '+ recId);
        System.debug('4 '+ subj);
        System.debug('5 '+ contactIds);
        
        List<Quote> quoteLst = [SELECT Id, account.HMC_Contact_Email__c  FROM Quote WHERE Id =: recId];
        
        // For Envelope Object 
        List<Envelope__c> listOfEnv = [Select Id, Name, Is_received__c, Is_Sent__c, Is_Viewed__c, Quote__c from Envelope__c Where Quote__c =: recId Order By CreatedDate Desc Limit 1];
        update new Envelope__c(Id=listOfEnv[0].id,Is_Sent__c=true); 
        //--------------------------
        
        System.debug('Emails : '+ Emails);
        List<ContentDocumentLink> contentLinkLst =  [SELECT Id,LinkedEntity.Name,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                                                     WHERE LinkedEntityId=:recId order by ContentDocument.CreatedDate DESC];
        system.debug('Emails '+Emails);
        boolean isEmailSent = true;
        ContentVersion ContentVersionData = new ContentVersion();
        
        if(!contentLinkLst.isEmpty()){
            Id contentVersionId = contentLinkLst[0].ContentDocument.LatestPublishedVersionId;
        	System.debug('contentVersionId : '+ contentVersionId);
            // Get the ContentVersion ID for the latest version
       		ContentVersionData = [SELECT Title, FileType, VersionData,ContentDocument.Title, ContentDocumentId, History_Tracker_Id__c, Record_Id__c  FROM ContentVersion WHERE Record_Id__c =: recId Order By CreatedDate Desc Limit 1];
            System.debug('ContentVersionData.Id :'+ ContentVersionData.Id);
                
            String linkUrl = 'https://newkabir.com/docuSign/index.php?recordId='+recId+'&type=sandbox'+'&docId='+ContentVersionData.Id+'&orgId='+UserInfo.getOrganizationId()+'&conRolId='+quoteLst[0].Id+'&usrId='+UserInfo.getUserId()+'&historyTrackerId='+ContentVersionData.History_Tracker_Id__c+'&EnvelopId='+listOfEnv[0].Id+'&docname='+ContentVersionData.ContentDocument.Title+'&orgno=4';
            
            String htmlTemplate = '<div style="background:#E7E7E7; justify-content: center; align-items: center; height:77vh;width:680px;position:relative;"> <div style="padding-top:2.5rem; padding-left:2rem; padding-right:2rem"> <table style="width:100%; border-collapse:collapse;"> <tr style="background:#fff;"> <td> <img src="https://appexchange.salesforce.com/partners/servlet/servlet.FileDownload?file=00P4V00000ytCSpUAM" style="margin-top: -5px; width: 150px; height:60px;" /> </td> <td style="border: none;"></td> </tr> <tr style="background:#000"> <td style="width:50%"> <div style="color: #fff; width: 70px; height: 70px; border: 1px solid #fff; border-radius: 100%; margin: auto; margin-top: -12px; background: url(\'https://static.vecteezy.com/system/resources/previews/005/004/109/original/document-with-pen-icon-notepad-symbol-pencil-pictogram-contract-line-icon-list-file-notebook-report-vector.jpg\'); background-size: cover;"></div> <div style="text-align: center;"> <p style="font-size:14px;color:#fff; margin-top:2rem;"> ' + UserInfo.getName() + ' sent you a document to review and sign</p> <br/><br/> <a href="' + linkUrl + '" style="padding: 10px 10px; background: #fff; font-size: 13px; text-decoration: none; color: #000;">View Documents</a> </div> </td> <td> <div style="background: url(\'https://images.unsplash.com/photo-1694435016274-fe1c0773a5d7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8MXx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60\'); height: 300px; width:auto; background-repeat: no-repeat; background-size: cover; background-position: center;"></div> </td> </tr> <tr style="height:90px border:none;background:#fff;"> <td style="border:none; background:#fff;" colspan="2"> <div style="text-align: left; font-size: 14px; padding: 10px; color:#000;">Please do not share this email, link, or access code with others.</div> </td> <td style="border: none;background:#fff;"></td> </tr> </table> </div> </div>';
            
            Body += htmlTemplate;
             
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress Limit 1];
            Emails.add('ravi.jangid@crmlanding.in');
            //Emails.add('rahul.jangid@crmlanding.in');
            List<Contact> conList= [Select Id,Email from Contact Limit 1];
            
            // For PDF Document Display 
            List<ContentVersion> conVers = [SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId, Record_Id__c FROM ContentVersion WHERE Record_Id__c =: recId +'03' Order by CreatedDate Desc Limit 1];
            System.debug('conVers : '+ conVers);
            //-------------------------
            if(!orgEmailAddress.isEmpty()){
                Set<String> uniqueEmails = new Set<String>(Emails);
                Emails = new List<String>(uniqueEmails);
                system.debug('Emails '+Emails);
                List<Messaging.SingleEmailMessage> MessagingEmailList = new List<Messaging.SingleEmailMessage>();
                for (String emailAdd : Emails) {
                    system.debug('emailAdd '+emailAdd);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new List<String>{emailAdd};
                    message.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
                    message.optOutPolicy = 'FILTER';
                    message.subject = subj ;
                    message.setSaveAsActivity(true);
                    message.plainTextBody = Body;
                    message.setHtmlBody(Body);
                    message.setsaveAsActivity(true);
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(conVers[0].Title);
                    //efa.setContentType('application/'+ContentVersionData.FileType);
                    efa.setContentType('application/'+conVers[0].FileType);
                    efa.setBody(conVers[0].VersionData);
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                    MessagingEmailList.add(message);
                }
                System.debug('MessagingEmailList : '+ MessagingEmailList);
                if(MessagingEmailList.size() > 0){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(MessagingEmailList, false);
                    if (!results[0].success) {
                        System.debug('false ');
                        return '';
                    }
                }
                List<History_Tracker__c> historyToUpdate = new List<History_Tracker__c>();
                List<History_Tracker__c> historyLst1 = [
                    SELECT Id, Document_Name__c, Document_Template__c, Status__c, Name__c, Step__c, Object_Record_Name__c, Object_Record_Id__c, History_Tracker_Id__c, Content_Version__c, Object_Name__c, Object_Record_Ids__c 
                    FROM History_Tracker__c WHERE Id =: ContentVersionData.History_Tracker_Id__c];

                    System.debug('historyLst1 : ' + historyLst1);
                    if (!historyLst1.isEmpty()) {
                        System.debug('historyLst1 -->: ' + historyLst1);
                        for (History_Tracker__c history : historyLst1) {
                            String objRecIds = history.Object_Record_Ids__c;
                                history.step__c = 3;
                                historyToUpdate.add(history); // Add the record to the list for update
                        }
                    }
                    if (!historyToUpdate.isEmpty()) {
                        Update historyToUpdate; // Update the records outside of the loop
                    }
                }
        }
        return  ContentVersionData.Id;//History_Tracker_Id__c;//isEmailSent;
    }
    
    public static boolean reSendEmail(List<String> contactIds, String oppIds, String currentUserId, String recordId, String HistoryTrackerId, String responsneContentVerId) {
        System.debug(' res send email '+ responsneContentVerId);
        if(responsneContentVerId != null){
        	List<ContentVersion> ContentVersionData = [SELECT Title, FileType, VersionData,ContentDocument.Title, ContentDocumentId, History_Tracker_Id__c, Record_Id__c, Unique_Ids__c FROM ContentVersion WHERE Unique_Ids__c =: responsneContentVerId Order By CreatedDate Desc Limit 1];    
        List<History_Tracker__c> historyToUpdate = new List<History_Tracker__c>();
            	List<History_Tracker__c> historyLst1 = [
                    SELECT Id, Document_Name__c, Document_Template__c, Status__c, Name__c, Step__c, Object_Record_Name__c, Object_Record_Id__c, History_Tracker_Id__c, Content_Version__c, Object_Name__c, Object_Record_Ids__c 
                    FROM History_Tracker__c WHERE Id =: HistoryTrackerId];
                
        String recId = recordId;
                System.debug('historyLst1 : ' + historyLst1);
                if (!historyLst1.isEmpty()) {
                    System.debug('historyLst1 -->: ' + historyLst1);
                    for (History_Tracker__c history : historyLst1) {
                        String objRecIds = history.Object_Record_Ids__c;
                        if (objRecIds != null && objRecIds.containsIgnoreCase(recId)) {
                            history.step__c = 4;
                            historyToUpdate.add(history); // Add the record to the list for update
                        }
                    }
                }

                if (!historyToUpdate.isEmpty()) {
                    Update historyToUpdate; // Update the records outside of the loop
                }
        
        String Body = 'Your Document has been sent';
        String subj= 'Mail sent';
        List<User> userList = [select id,Email from User where id =: currentUserId];
        List<String> Emails =  new List<String>();
        String  userEmail = userList[0].Email;   
        System.debug('userEmails' +  userEmail);
     	
        List<Quote> quoteLst = [SELECT Id, account.HMC_Contact_Email__c  FROM Quote WHERE Id =: recordId];
        Emails.add(quoteLst[0].account.HMC_Contact_Email__c);
        List<ContentDocumentLink> contentLinkLst =  [SELECT Id,LinkedEntity.Name,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                                                     WHERE LinkedEntityId=:oppIds order by ContentDocument.CreatedDate DESC];
                
        boolean isEmailSent = true;   
        
        if(!contentLinkLst.isEmpty()){
            Id contentVersionId = contentLinkLst[0].ContentDocument.LatestPublishedVersionId;
            String linkUrl = 'https://newkabir.com/documentverification/index.php?recordId='+oppIds+'&type=sandbox'+'&docId='+contentVersionId+'&orgId='+UserInfo.getOrganizationId();
            
            //String linkUrl = 'https://www.example.com/endpoint.php?salesforceOrgID='+UserInfo.getOrganizationId()+'&contentVersionID='+contentVersionId+'&objectRecordID='+recId; 
            
            String htmlTemplate = '<div style="background:#E7E7E7; justify-content: center; align-items: center; height:75vh;width:680px;position:relative;"> <div style="padding-top:2.5rem; padding-left:2rem; padding-right:2rem"> <table style="width:100%; border-collapse:collapse;"> <tr style="background:#fff;"> <td> <img src="https://appexchange.salesforce.com/partners/servlet/servlet.FileDownload?file=00P4V00000ytCSpUAM" style="margin-top: -5px; width: 150px; height:60px;" /> </td> <td style="border: none;"></td> </tr> <tr style="background:#000"> <td style="width:40%"> <div style="justify-content: center;align-items: center;width: 60px;height: 60px;margin: auto;text-align: center;border-radius: 100%;"> <div style="background-image: url(\'https://www.freeiconspng.com/thumbs/document-icon/document-icon-33.png\'); border-radius: 25px;background-color: white; width: 70px;height: 70px; background-size:75%; background-repeat:no-repeat;background-position:center;border-radius: 100%;"></div> </div> <div style="text-align: center;"> <p style="font-size:14px;color:#fff; margin-top:2.5rem;"> Your Document has been completed.</p> </div> </td> <td> <div style="background: url(\'https://images.unsplash.com/photo-1694435016274-fe1c0773a5d7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8MXx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60\'); height: 300px; width:auto; background-repeat: no-repeat; background-size: cover; background-position: center;"></div> </td> </tr> <tr style="height:90px border:none;background:#fff;"> <td style="border:none; background:#fff;" colspan="2"> <div style="text-align: left; font-size: 14px; padding: 10px; color:#000;">Please do not share this email, link, or access code with others.</div> </td> <td style="border: none;background:#fff;"></td> </tr> </table> </div> </div>';

             
            Body += htmlTemplate;
            //ContentVersion ContentVersionData = [SELECT Title, FileType, VersionData,ContentDocument.Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress Limit 1];
            Emails.add(userEmail);
            if(!orgEmailAddress.isEmpty()){
                Set<String> uniqueEmails = new Set<String>(Emails);
                Emails = new List<String>(uniqueEmails);
                system.debug('Emails '+Emails);
                for (String emailAdd : Emails) {
                    system.debug('emailAdd '+emailAdd);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses =  new List<String>{emailAdd};
                    message.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
                    message.optOutPolicy = 'FILTER';
                    message.subject = subj ;
                    
                    message.plainTextBody = Body;
                    message.setHtmlBody(Body);
                    //message.setTargetObjectId(contactIds[0]);
					message.setsaveAsActivity(true);
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(ContentVersionData[0].ContentDocument.Title);
                    efa.setContentType('application/'+ContentVersionData[0].FileType);
                    efa.setBody(ContentVersionData[0].VersionData);
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                    
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (!results[0].success) {
                        isEmailSent = false ;
                    }
                }
            }
            List<History_Tracker__c> historyToUpdate1 = new List<History_Tracker__c>();
            if (!historyLst1.isEmpty()) {
                System.debug('historyLst1 -->: ' + historyLst1);
                    for (History_Tracker__c history : historyLst1) {
                        String objRecIds = history.Object_Record_Ids__c;
                        if (objRecIds != null && objRecIds.containsIgnoreCase(recId)) {
                            history.step__c = 5;
                            history.Status__c = 'Accepted';
                            historyToUpdate1.add(history); // Add the record to the list for update
                        }
                    }
                }
                if (!historyToUpdate1.isEmpty()) {
                    Update historyToUpdate1; // Update the records outside of the loop
                }
        }
        /*ESignPlatformEvent__e newsEvent = new ESignPlatformEvent__e	(Message__c = 'Agreement has been signed',Status__c='Accepted', recordId__c = currentUserId, documentId__c=historyLst1[0].Document_Name__c);
        Database.SaveResult sr = EventBus.publish(newsEvent);
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                            err.getStatusCode() +
                            ' - ' +
                            err.getMessage());
            }
        }*/
        return  isEmailSent;
        }
        return null;
    }
    
    
    public static boolean rejectSendEmail(List<String>contactIds, String oppIds, String currentUserId, String recordId, String HistoryTrackerId, String responsneContentVerId) {
        System.debug('res send email ');
        if(responsneContentVerId != null){
            System.debug(responsneContentVerId); 
        	List<ContentVersion> ContentVersionData = [SELECT Title, FileType, VersionData,ContentDocument.Title, ContentDocumentId, History_Tracker_Id__c, Record_Id__c, Unique_Ids__c FROM ContentVersion WHERE Unique_Ids__c =: responsneContentVerId Order By CreatedDate Desc Limit 1];    
        
        List<History_Tracker__c> historyToUpdate = new List<History_Tracker__c>();
            List<History_Tracker__c> historyLst1 = [
                    SELECT Id, Document_Name__c, Document_Template__c, Status__c, Name__c, Step__c, Object_Record_Name__c, Object_Record_Id__c, History_Tracker_Id__c, Content_Version__c, Object_Name__c, Object_Record_Ids__c 
                    FROM History_Tracker__c WHERE Id =: HistoryTrackerId]; //WHERE CreatedDate = LAST_N_DAYS:365 And Document_Template__c != Null ORDER BY CreatedDate DESC LIMIT 200];    
                    
        	
                String recId = recordId;
                System.debug('historyLst1 : ' + historyLst1);
                if (!historyLst1.isEmpty()) {
                    System.debug('historyLst1 -->: ' + historyLst1);
                    for (History_Tracker__c history : historyLst1) {
                        String objRecIds = history.Object_Record_Ids__c;
                        if (objRecIds != null && objRecIds.containsIgnoreCase(recId)) {
                            history.step__c = 4;
                            historyToUpdate.add(history); // Add the record to the list for update
                        }
                    }
                }

                if (!historyToUpdate.isEmpty()) {
                    Update historyToUpdate; // Update the records outside of the loop
                }
        
        String Body = 'Your Document has been sent';
        String subj= 'Mail sent';
        List<Contact> conList= [Select Id,Email from Contact limit 1];//where Id IN : contactIds];
        List<User> userList = [select Id,Email from User where id =: currentUserId];
        List<String> Emails =  new List<String>();
        String  userEmail = userList[0].Email;   
        List<Quote> quoteLst = [SELECT Id, account.HMC_Contact_Email__c  FROM Quote WHERE Id =: recordId];
        /*(for(Contact obj : conList){
            Emails.add(obj.Email);
        }
        System.debug('Emails' + Emails);*/
        Emails.add(quoteLst[0].account.HMC_Contact_Email__c);
        
        List<ContentDocumentLink> contentLinkLst =  [SELECT Id,LinkedEntity.Name,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink
                                                     WHERE LinkedEntityId=:oppIds order by ContentDocument.CreatedDate DESC];
                
        boolean isEmailSent = true;   
        
        if(!contentLinkLst.isEmpty()){
            Id contentVersionId = contentLinkLst[0].ContentDocument.LatestPublishedVersionId;
            String linkUrl = 'https://newkabir.com/documentverification/index.php?recordId='+oppIds+'&type=sandbox'+'&docId='+contentVersionId+'&orgId='+UserInfo.getOrganizationId();
            
            String htmlTemplate = '<div style="background:#E7E7E7; justify-content: center; align-items: center; height:75vh;width:680px;position:relative;"> <div style="padding-top:2.5rem; padding-left:2rem; padding-right:2rem"> <table style="width:100%; border-collapse:collapse;"> <tr style="background:#fff;"> <td> <img src="https://appexchange.salesforce.com/partners/servlet/servlet.FileDownload?file=00P4V00000ytCSpUAM" style="margin-top: -5px; width: 150px; height:60px;" /> </td> <td style="border: none;"></td> </tr> <tr style="background:#000"> <td style="width:40%"> <div style="justify-content: center;align-items: center;width: 60px;height: 60px;margin: auto;text-align: center;border-radius: 100%;"> <div style="background-image: url(\'https://www.freeiconspng.com/thumbs/document-icon/document-icon-33.png\'); border-radius: 25px;background-color: white; width: 70px;height: 70px; background-size:75%; background-repeat:no-repeat;background-position:center;border-radius: 100%;"></div> </div> <div style="text-align: center;"> <p style="font-size:14px;color:#fff; margin-top:2.5rem;"> Your Document has been Rejected.</p> </div> </td> <td> <div style="background: url(\'https://images.unsplash.com/photo-1694435016274-fe1c0773a5d7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwcm9maWxlLXBhZ2V8MXx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=500&q=60\'); height: 300px; width:auto; background-repeat: no-repeat; background-size: cover; background-position: center;"></div> </td> </tr> <tr style="height:90px border:none;background:#fff;"> <td style="border:none; background:#fff;" colspan="2"> <div style="text-align: left; font-size: 14px; padding: 10px; color:#000;">Please do not share this email, link, or access code with others.</div> </td> <td style="border: none;background:#fff;"></td> </tr> </table> </div> </div>';

            Body += htmlTemplate;
            //ContentVersion ContentVersionData = [SELECT Title, FileType, VersionData,ContentDocument.Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];
            List<OrgWideEmailAddress> orgEmailAddress=[select Id from OrgWideEmailAddress Limit 1];
            Emails.add(userEmail);
            if(!orgEmailAddress.isEmpty()){
                Set<String> uniqueEmails = new Set<String>(Emails);
                Emails = new List<String>(uniqueEmails);
                for (String emailAdd : Emails) {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses =  new List<String>{emailAdd};
                    message.setOrgWideEmailAddressId(orgEmailAddress[0].Id); 
                    message.optOutPolicy = 'FILTER';
                    message.subject = subj ;
                    
                    message.plainTextBody = Body;
                    message.setHtmlBody(Body);
                    //message.setTargetObjectId(contactIds[0]);
					message.setsaveAsActivity(true);
                    
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.setFileName(ContentVersionData[0].ContentDocument.Title);
                    efa.setContentType('application/'+ContentVersionData[0].FileType);
                    efa.setBody(ContentVersionData[0].VersionData);
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
                    
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (!results[0].success) {
                        isEmailSent = false ;
                    }
                }
            }
            List<History_Tracker__c> historyToUpdate1 = new List<History_Tracker__c>();
            if (!historyLst1.isEmpty()) {
                    for (History_Tracker__c history : historyLst1) {
                        String objRecIds = history.Object_Record_Ids__c;
                        if (objRecIds != null && objRecIds.containsIgnoreCase(recId)) {
                            history.status__c = 'Rejected';
                            historyToUpdate1.add(history); // Add the record to the list for update
                        }
                    }
                }
                if (!historyToUpdate1.isEmpty()) {
                    Update historyToUpdate1; // Update the records outside of the loop
                }
        }
        
        /*ESignPlatformEvent__e newsEvent = new ESignPlatformEvent__e	(Message__c = 'Agreement has been rejected',Status__c='Rejected', recordId__c = currentUserId, documentId__c=historyLst1[0].Document_Name__c);
        Database.SaveResult sr = EventBus.publish(newsEvent);
        if (sr.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }*/
        return  isEmailSent;
        }
        return null;
    }
    
    public class DataWrapper {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled       
        public String Role {get;set;}
        @AuraEnabled
        public Boolean IsPrimary {get;set;}
        @AuraEnabled       
        public String Email {get;set;}
        @AuraEnabled       
        public String OppName {get;set;}
        
        
        
        public DataWrapper(String Id,String Name, String Role, Boolean IsPrimary,String Email,String OppName){
            this.Id=Id;
            this.Name = Name;
            this.Role = Role;
            this.IsPrimary = IsPrimary; 
            this.Email = Email;
            this.OppName = OppName;
        }
    }
}