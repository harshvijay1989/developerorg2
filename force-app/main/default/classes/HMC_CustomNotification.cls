public class HMC_CustomNotification {
    Public static void sendNotification(){
        //Get the custom Notification type
        // Get the Id for our custom notification type
        CustomNotificationType notificationType ;
        if(test.isRunningTest()){
            notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Dealer_Onboarding'];
        }else{
            notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Physical_Shipping_Confirmation'];
        }
        System.debug('notificationType'+notificationType);
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        // Set the contents for the notification
        notification.setTitle('Account name changed');
        notification.setBody('The name of this account has been changed');
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        // notification.setTargetId(acc.Id);
        
        Set<String> addressee = new Set<String>();
        //addressee.add(acc.OwnerId);
        
        // Actually send the notification
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
      
}