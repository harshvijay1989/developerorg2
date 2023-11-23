trigger SendNotificationOnQuoteApproval on Quote (after update) {
    set<id>setId = new set<id>();
    for(Quote qu : trigger.old){
            setId.add(qu.id);
    }
    
    list<quote> listQuote = [SELECT id,Status,Approval_Check_RSM__c,ownerId from quote where id = : setId ];
    if(!listQuote.isEmpty()){
         for(quote qu : listQuote ){
          if(qu.Approval_Check_RSM__c == true && qu.Status == 'Needs Review'){
              CustomNotificationType notificationType = 
           [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Mail_To_MD'];
              
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
       				
                notification.setTitle('Response to your Approval Request.');
                notification.setBody('Approval notification');
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(qu.id);
                notification.send(new set<String>{qu.OwnerId});
          }
    }
     

    }
   
}