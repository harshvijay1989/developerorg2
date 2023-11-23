public class SendMdPageVfController {
    public String pdfURL { get; set; }
    public String contentVersionId { get; set; }
    public ContentVersion contentVersion { get; private set; }
    public String contentUrl { get; private set; }
    public SendMdPageVfController(){
        //Id recordId = ApexPages.CurrentPage().getParameters().get('id');
        //String contentVersionId = ApexPages.currentPage().getParameters().get('contentVersionId');
        
    }
    public void callPDF(){
        Blob fileData;
        System.debug(' call pdf ');
        String contentVersionId = apexPages.currentPage().getParameters().get('conVirId');
        
        System.debug('###contentVersionId : '+ contentVersionId);
        if(contentVersionId != Null  && contentVersionId != 'undefined'){
            System.debug('not null @@@ ');
            //List<ContentVersion> conVirLst1 = new List<ContentVersion>([select id, title, VersionData, PathOnClient, FirstPublishLocationId,IsMajorVersion, ContentDocumentId from ContentVersion Where FirstPublishLocationId =: contentVersionId order by CreatedDate desc]);
            List<ContentVersion> conVirLst1 = new List<ContentVersion>([SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId, Record_Id__c FROM ContentVersion WHERE Record_Id__c =: contentVersionId +'01' Order by CreatedDate Desc Limit 1]);
            if(!conVirLst1.isEmpty()){
                fileData = conVirLst1[0].VersionData;
                pdfURL = fileData != null ? fileData.toString() : '';
                System.debug('pdfURL : '+ pdfURL);       
            }
            else{
                System.debug('helo no preview');
                pdfURL = 'No Preview Page, Please Generate The Document';
            }
        }
    }
}