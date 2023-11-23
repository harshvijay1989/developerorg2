public class VFPadCtrl {
    
    public String wrapperHtmlData{get;set;}
    public String ObjectName{get;set;}
    public String fileContent{get;set;}
    public String recordId { get; private set; }
    public String recId { get; private set; }
    public String orgBaseURL { get; private set; }
    public String htmlContent { get; set; }
    
    public void updateList(){
        
        fileContent = ApexPages.currentPage().getParameters().get('htmlParam');
        System.debug('htmlContent : '+ fileContent);
        
        orgBaseURL = ProxyController.getLightningDomainURL();
        System.debug('hello dataFromLWC ');
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        if(recordId != Null){
            System.debug('If Part');
            List<ContentVersion>  updatedConVerList = [SELECT Id, FirstPublishLocationId,Title, PathOnClient,VersionData, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: recordId AND Title = 'Content Document' order by CreatedDate LIMIT 1];
            Blob updatedFileData = updatedConVerList[0].VersionData;
            fileContent = updatedFileData != null ? updatedFileData.toString() : '';
            
            System.debug('fileContent---->' + fileContent);
            fileContent.remove(''); 
            List<Document_Template__c> docList = [SELECT Id, Object_Name__c FROM Document_Template__c Where Id =: recordId];
            ObjectName = docList[0].Object_Name__c;
            System.debug('ObjectName---->' + ObjectName);
            
            List<Document_Store__c> docStr = [Select id, HTML_Data__c, Mached_Data__c from Document_Store__c Where Mached_Data__c = 'Upload Document File' Order by createdDate desc Limit 1];
            if(docStr.Size() > 0 && docStr[0].Mached_Data__c == 'Upload Document File'){
                List<ContentVersion>  conVerList = [SELECT Id, FirstPublishLocationId,Title, PathOnClient,VersionData, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: docStr[0].Id AND Title = 'Upload Document File' order by CreatedDate desc LIMIT 1];
                if(conVerList.size() > 0){
                    Blob fileData = conVerList[0].VersionData;
                    fileContent = fileData != null ? fileData.toString() : '';
                    List<ContentDocument> listToDelete = new List<ContentDocument>();
                    for(ContentVersion conVer : conVerList){
                        listToDelete.add(new ContentDocument(Id = conVer.ContentDocumentId));
                    }
                    List<Document_Store__c> delList = New List<Document_Store__c>();
                    delList = docStr;
                    delete listToDelete;
                    Delete docStr;    
                }    
            }
        }else{
            List<Document_Store__c> docStr = [Select id, HTML_Data__c, Mached_Data__c from Document_Store__c Where Mached_Data__c = 'Upload Document File' Order by createdDate desc Limit 1];
            System.debug('docStr : '+ docStr);
            if(docStr.Size() > 0 && docStr[0].Mached_Data__c == 'Upload Document File'){
                System.debug('htmlData : '+docStr[0].HTML_Data__c); 
                List<ContentVersion>  conVerList1 = [SELECT Id, FirstPublishLocationId,Title, PathOnClient,VersionData, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: docStr[0].Id AND Title = 'Upload Document File' order by CreatedDate LIMIT 1];
                Blob fileData1 = conVerList1[0].VersionData;
                fileContent = fileData1 != null ? fileData1.toString() : '';
                System.debug('fileContent : '+ fileContent);
                List<ContentDocument> listToDelete = new List<ContentDocument>();
                for(ContentVersion conVer : conVerList1){
                    listToDelete.add(new ContentDocument(Id = conVer.ContentDocumentId));
                }
                List<Document_Store__c> delList = New List<Document_Store__c>();
                delList = docStr;
                delete listToDelete;
                Delete docStr;    
            }
        }
    }
}