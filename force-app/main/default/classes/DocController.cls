public class DocController {
    //public String header{get;set;}
    public String body{get;set;}
    public String footer{get;set;}
    public String contentVersionId{get;set;}
    public Integer currentPage { get; set; }
    
    public void setValues(){
        String recordId = apexPages.currentPage().getParameters().get('recordId');
        
        System.debug('reocrd id of doc controller '+recordId);
        Document_Store__c obj = [SELECT Id, FooterHTML__c FROM Document_Store__c WHERE Id =: recordId LIMIT 1]; 
        footer = obj.FooterHTML__c;
        Attachment att = [ SELECT  Body FROM Attachment WHERE ParentId =: recordId Limit 1];
        System.debug('--- att '+ att.Body);
        body =  att.Body.toString();
        contentVersionId = [SELECT ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]?.ContentDocument.LatestPublishedVersionId;
    }
}