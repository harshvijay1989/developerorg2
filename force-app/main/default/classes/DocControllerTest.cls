@isTest
public class DocControllerTest {
    
    @isTest
    static void testSetValues() {
        
        Document_Store__c documentStore = new Document_Store__c();
        documentStore.FooterHTML__c = '<div style="display: flex; border: undefined; width: initial;"><div style=""><p style="font-family: undefined; font-size: undefined; color: undefined; text-align: undefined; margin-left: undefined; margin-right: undefined; margin-top: undefined; margin-bottom: undefined;"></p></div></div>';
        insert documentStore;
        String recordId = documentStore.Id;


        Attachment attachment = new Attachment();
        attachment.ParentId = documentStore.Id;
        attachment.Body = Blob.valueOf('Sample Attachment Body');
        attachment.Name = 'test';
        insert attachment;
        
        ContentVersion contentVersion = new ContentVersion(VersionData = blob.valueOf('test file'),Title = 'test file',pathOnClient = 'test0');
        insert contentVersion;
        
        ContentVersion cvUpdated = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = documentStore.id,ShareType= 'I',ContentDocumentId = cvUpdated.ContentDocumentId,Visibility = 'AllUsers');
        insert contentlink;
        
        DocController docControllerInstance = new DocController();

        Test.startTest();

        ApexPages.currentPage().getParameters().put('recordId', documentStore.id);

        docControllerInstance.setValues();

        Test.stopTest();

        //System.assertEquals('Sample Footer HTML', docControllerInstance.footer);
        System.assertEquals('Sample Attachment Body', docControllerInstance.body);
    }
}