@RestResource(urlMapping='/sendmail')
global class EmailWebService {
    @HttpPost
    global static String sendMail() {
        System.debug('php');
        RestRequest req = RestContext.request;
        req.addHeader('accept', 'application/json');
        System.debug('php body: '+req.requestBody.toString());
        String jsonString = req.requestBody.toString();
        String currentUserId = UserInfo.getUserId();
        System.debug('Current User ID: ' + currentUserId);
        
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
		
        System.debug('jsonMap : '+ jsonMap);
        String title = (String) jsonMap.get('Title');
        String conrollId = (String) jsonMap.get('conrollId');
        String usrId = (String) jsonMap.get('usrId');
        String status = (String) jsonMap.get('Status');
        String recordId = (String) jsonMap.get('RecordId');
        String HistoryTrackerId = (String) jsonMap.get('HistoryTrackerId');
        String envelopeId = (String) jsonMap.get('envelopeId');
        String responsneContentVerId = (String) jsonMap.get('uniqueId');
        
        System.debug('responsneContentVerId '+ responsneContentVerId);
        conrollId = conrollId.replaceAll('[()]+', '');
        List<String> idList = conrollId.split(',');
        
        if(Status.containsIgnoreCase('reject')){
            
            
            
            if(envelopeId != Null){
                List<Envelope__c> listOfEnv = [Select Id, Name, Is_received__c, Is_Sent__c, Status__c, Is_Viewed__c, Opportunity__c from Envelope__c Where Id =: envelopeId];
                if(!listOfEnv.isEmpty()){
                	update new Envelope__c(Id=listOfEnv[0].id,Status__c='Rejected');     
                }
            }
            emailToCustomerCtrl.rejectSendEmail(idList, usrId, currentUserId, recordId, HistoryTrackerId, responsneContentVerId);
            
            //customm notification send
            CustomNotificationType notificationType = [ 
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = 'emailSendOnOpportunity'
            ];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            notification.setTitle('Email Notification');
            notification.setBody('You have received a Mail!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(currentUserId);
            notification.send(new Set<String>{currentUserId});
            
            return req.requestBody.toString();
        }else{
            if(recordId != null){
                	update new quote(Id = recordId, status = 'Accepted');     
            }
            if(envelopeId != Null){
                List<Envelope__c> listOfEnv = [Select Id, Name, Is_received__c, Is_Sent__c, Status__c, Is_Viewed__c, Opportunity__c from Envelope__c Where Id =: envelopeId];
        		update new Envelope__c(Id=listOfEnv[0].id, Status__c='Accepted'); 
            	
                
                //Envelope__c envObj = [Select Id, Name, Is_received__c, Is_Sent__c, Is_Viewed__c, Opportunity__c, Status__c from Envelope__c Where Id =: envelopeId];
            	//envObj.Status__c = 'Accepted';
                //Update envObj;    
            }
            
           emailToCustomerCtrl.reSendEmail(idList, usrId, currentUserId, recordId, HistoryTrackerId, responsneContentVerId);
            
           //
           Quote quoteStage = [SELECT Id, Name, Status,OwnerId,QuoteNumber FROM Quote WHERE Id = : recordId];

           CustomNotificationType notificationType = 
           [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='emailSendOnOpportunity'];
                system.debug('notificationType'+notificationType);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
       				 //system.debug('recordID'+recordId);
        			//system.debug('userId'+userId);
                notification.setTitle('Email Notification');
                notification.setBody('Your Document has been Accepted');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(recordId);
                notification.send(new set<String>{quoteStage.OwnerId});
        system.debug('notification'+notification);
            
            
            
            //customm notification send
            /*CustomNotificationType notificationType = [
                SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName = 'emailSendOnOpportunity'
            ];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            notification.setTitle('Email Notification');
            notification.setBody('You have received a Mail!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(currentUserId);
            notification.send(new Set<String>{currentUserId});*/
            return req.requestBody.toString();
        }
        //emailToCustomerCtrl.reSendEmail(idList, usrId, currentUserId);
        
        //customm notification send
        /*CustomNotificationType notificationType = [
            SELECT Id, DeveloperName 
            FROM CustomNotificationType 
            WHERE DeveloperName = 'emailSendOnOpportunity'
        ];
       
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        notification.setTitle('Email Notification');
        notification.setBody('You have received a Mail!');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(currentUserId);
        notification.send(new Set<String>{currentUserId});
        return req.requestBody.toString();*/
        //return null;
    }
    
    public class MailWrapper {
        public String contactId;
        public String salesrepId;
        public String opportunityId;
        public String body;
    }
}