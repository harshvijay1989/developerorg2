@isTest
public class PreviewDocumentTest {
    
    @testSetup static void setup() {
        Document_Template__c testTemplate = new Document_Template__c(    Template_Name__c = 'Test template',Permission_Name__c = 'System Administrator',Object_Name__c='Opportunity');
        insert testTemplate;
        
        Pricebook2 testPricebook = new Pricebook2(Name='Test Pricebook', IsActive=true);
        insert testPricebook;

        
        //Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(),Pricebook2Id = testPricebook.id);
        insert testOpportunity;
       
        /*
        List<OpportunityLineItem> showOpp = new List<OpportunityLineItem>();
        

        Product2 product2Record = new Product2();
        product2Record.Name = 'Product 2';
        product2Record.Description = 'Description for Product 2';
        product2Record.IsActive = true;
        product2Record.Family = 'Some Product Family';
        
        insert product2Record;
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem();
        oppLineItem1.Product2Id = product2Record.id;
        oppLineItem1.Quantity = 1;
        oppLineItem1.UnitPrice = 100.00;
        oppLineItem1.OpportunityId = testOpportunity.Id;
        
        OpportunityLineItem oppLineItem2 = new OpportunityLineItem();
        oppLineItem2.Product2Id = product2Record.Id;
        oppLineItem2.Quantity = 2;
        oppLineItem2.UnitPrice = 50.00;
        oppLineItem2.OpportunityId = testOpportunity.Id;
        
        showOpp.add(oppLineItem1);
        showOpp.add(oppLineItem2);
        
        insert showOpp;
        */
    }   
    
    @isTest
    static void testGetContentVersionTitle() {
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;
        
        Document_Template__c documentTemplate = new Document_Template__c(
            Template_Name__c = 'Test template',Permission_Name__c = 'System Administrator',Object_Name__c='Opportunity'
        );
        insert documentTemplate;
        
        History_Tracker__c historyTracker = new History_Tracker__c(
            Document_Name__c = 'Test Document',
            Object_Record_Ids__c = testOpportunity.Id,
            Document_Template__c = documentTemplate.Id
        );
        insert historyTracker;
        
        History_Tracker__c testHistoryTracker = new History_Tracker__c(Document_Template__c = documentTemplate.Id);
        insert testHistoryTracker;
        
        Test.startTest();
        PreviewDocument.getUsers();
        Map<String, String> result = PreviewDocument.getContentVersionTitle( documentTemplate.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
        
    }
    
    @isTest
    static void testGetPdfName() {
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;
        
        Document_Template__c testTemplate = new Document_Template__c(    Template_Name__c = 'Test template',Permission_Name__c = 'System Administrator',Object_Name__c='Opportunity');
        insert testTemplate;
        
        ContentVersion testContentVersion = new ContentVersion( VersionData = Blob.valueOf('Test PDF Content'), Title = 'Test PDF', Record_Id__c = testOpportunity.Id, pathOnClient = 'test0' );
        insert testContentVersion;
        
        History_Tracker__c testHistoryTracker = new History_Tracker__c( Document_Name__c = 'Test Document', Content_Version__c = testContentVersion.Id, Object_Record_Ids__c = testOpportunity.Id, Document_Generate_Date_Time__c = String.valueOf(System.today()) );
        insert testHistoryTracker;
        
        Map<String, String> result = PreviewDocument.getPdfName(testOpportunity.Id);
        
        System.assertNotEquals(null, result);
        System.assertEquals(testContentVersion.Id, result.get('Content_Version__c'));
        System.assertEquals(testHistoryTracker.Document_Name__c, result.get('Document_Name__c'));
        System.assertEquals(testHistoryTracker.Document_Generate_Date_Time__c, result.get('Document_Generate_Date_Time__c'));
    }
    
    @isTest
    static void testGetDocumentData() {
        Document_Template__c documentTemplate = [select id,Template_Name__c,Permission_Name__c,Object_Name__c from Document_Template__c limit 1];
        Opportunity opportunityRec = [select id,Name,StageName,CloseDate from Opportunity limit 1];
        
        ContentVersion contentVersion = new ContentVersion(
            VersionData = Blob.valueOf('{{{TableStarted'),
            Title = 'Content Document',
            pathOnClient = 'test0',
            Record_Id__c = opportunityRec.Id
        );
        insert contentVersion;
        
        ContentVersion cvUpdated = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        
        ContentDocumentLink contentlink = new ContentDocumentLink(
            LinkedEntityId = opportunityRec.Id,
            ShareType = 'I',
            ContentDocumentId = cvUpdated.ContentDocumentId,
            Visibility = 'AllUsers'
        );
        insert contentlink;
        
        Test.startTest();
        String result = PreviewDocument.getDocumentData(documentTemplate.Id, opportunityRec.Id, 'Opportunity', null, opportunityRec.Id, 'PDF');
        Test.stopTest();
    }
    
}