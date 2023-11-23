public class UtilityCls {
    public static void notify(String title,String body,String TemplateInfoDetailId,String userId,String applicationId){
        // Create a new custom notification
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        // Set the contents for the delinking notification    
        currNotification.setTitle(title);
        currNotification.setBody(body);
        // Set the notification type and target
        currNotification.setNotificationTypeId(TemplateInfoDetailId);
        currNotification.setTargetId(applicationId);
        // Send the notification
        try {
            currNotification.send(new Set<String>{userId});   
            //return 'success';
        }
        catch (Exception ex) {
            System.debug('Notification Failed: ' + ex.getMessage());
        }
    }
}