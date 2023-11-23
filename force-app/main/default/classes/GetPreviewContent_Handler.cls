public class GetPreviewContent_Handler {
	
    @AuraEnabled(cacheable=true)
    public static String getContent(String recordId){
        Base_Document_Template__c docObj = [SELECT Rich_Text_Field__c FROM Base_Document_Template__c WHERE id = :recordId LIMIT 1];
        String content = docObj.Rich_Text_Field__c;
        system.debug('content '+content);
        return content;
    }
    
    @AuraEnabled
    public static void saveContent(String recordId, String content){
        Base_Document_Template__c docObj = new Base_Document_Template__c(Id=recordId,Rich_Text_Field__c=content);
        update docObj;
    }
    
    @AuraEnabled
    public static String getFileContentAsString(string tempObjId, string fileType) {
        ContentVersion cv;
        if(fileType == 'PDF'){
        	ContentDocumentLink contntDocu = [select id,LinkedEntityId,ContentDocumentId, ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: tempObjId AND ContentDocument.Title = 'Content Document' limit 1];    
        	cv = [SELECT Checksum,ContentBodyId,ContentDocumentId,ContentLocation,Title,VersionData,VersionNumber FROM ContentVersion 
                                 WHERE ContentDocumentId =: contntDocu.ContentDocumentId];
        }else{
            ContentDocumentLink contntDocu = [select id,LinkedEntityId,ContentDocumentId, ContentDocument.Title from ContentDocumentLink where LinkedEntityId =: tempObjId limit 1];
        	System.debug('file contntDocu : '+ contntDocu );
            cv    =	[SELECT Checksum,ContentBodyId,ContentDocumentId,ContentLocation,Title,VersionData,VersionNumber FROM ContentVersion 
                                 WHERE ContentDocumentId =: contntDocu.ContentDocumentId];
            System.debug('file contntDocu  cvcv: '+ cv );
        }
        
        string fileContent = '';
        System.debug('fileContent '+fileContent);
        try {
            // Read the file as a blob
            Blob fileBlob = cv.VersionData;
            system.debug('fileBlob '+fileBlob);
            
            // Convert the blob to a string
            fileContent = fileBlob.toString();
            system.debug('fileContent '+fileContent);
        } catch (Exception e) {
            // Handle any exceptions
            System.debug('Error reading file: ' + e.getMessage());
        }
        
        return fileContent;
    }
}