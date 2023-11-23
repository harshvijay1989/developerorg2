public class UserSignCtrl {
    public String dataURL { get; set; }
    
    @AuraEnabled
    public static void saveImage(String base64Image) {
        System.debug('base64Image '+ base64Image);

        Blob imageBlob = EncodingUtil.base64Decode(base64Image);
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = imageBlob;
        contentVersion.Title = 'UserSignatureImage';
        contentVersion.PathOnClient = 'UserSignatureImage.png';
        insert contentVersion;
        
        ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        Opportunity oppRec = [Select Id from Opportunity Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
        contentLink.LinkedEntityId = oppRec.id;//'0011y00000eewSLAAY';//UserInfo.getUserId();
        contentLink.ShareType = 'I'; // Use "I" for sharing with the user
        insert contentLink;
        System.debug('contentLink' + contentLink.id);
        String fileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentVersion.Id;
        String userId = UserInfo.getUserId();
        User usr = [Select id, user_signature__c from user where id =: userId];
        if(usr.User_Signature__c == null){
            usr.User_Signature__c = fileURL;
            //update usr;
        }
        System.debug('fileURL '+ fileURL);
    }

    @AuraEnabled
    public static void saveDataURL(string dataURL) {
        System.debug('dataURL '+ dataURL);
        String base64Data = dataURL.substringAfter(',');
        System.debug('Base64 data: ' + base64Data);
        
        Blob imageBlob = EncodingUtil.base64Decode(base64Data);
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = imageBlob;
        contentVersion.Title = 'UserSignatureImage';
        contentVersion.PathOnClient = 'UserSignatureImage.png';
        insert contentVersion;
        
        ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        Opportunity oppRec = [Select Id from Opportunity Limit 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
        contentLink.LinkedEntityId = oppRec.id;//'0011y00000eewSLAAY';//UserInfo.getUserId();
        contentLink.ShareType = 'I'; // Use "I" for sharing with the user
        insert contentLink;
        System.debug('contentLink' + contentLink.id);
        String fileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentVersion.Id;
        String userId = UserInfo.getUserId();
        User usr = [Select id, user_signature__c from user where id =: userId];
        if(usr.User_Signature__c == null){
            usr.User_Signature__c = fileURL;
            //update usr;
        }
        System.debug('fileURL '+ fileURL);
    }
}