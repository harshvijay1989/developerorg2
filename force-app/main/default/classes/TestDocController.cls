@isTest
private class TestDocController {
    
    @isTest
    static void testSetValues() {
        DocController controller = new DocController();
        
        Document_Store__c mockDocument = new Document_Store__c(FooterHTML__c = 'Mock Footer HTML');
        Attachment mockAttachment = new Attachment(Body = Blob.valueOf('Mock Body Content'));
      //  ContentDocumentLink mockContentDocumentLink = new ContentDocumentLink(ContentDocumentId = 'mockContentDocumentId', LinkedEntityId = 'someRecordId');
        
        controller.setValues();
        
    }   
}