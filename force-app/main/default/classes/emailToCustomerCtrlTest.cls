@isTest
public class emailToCustomerCtrlTest {
    
    @isTest 
    private static void testSendEmail() {
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;
        
        Envelope__c envelope = new Envelope__c(Name = 'test envelope',Is_Sent__c = true,Is_Received__c = true,Opportunity__c = testOpportunity.Id);
        insert envelope;
        
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert testContact;
        
        ContentVersion contentVersion = new ContentVersion(VersionData = blob.valueOf('test file'),Title = 'test file',pathOnClient = 'test0',Record_Id__c = testOpportunity.Id);
        insert contentVersion;
        
        ContentVersion cvUpdated = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink(LinkedEntityId = testOpportunity.id,ShareType= 'I',ContentDocumentId = cvUpdated.ContentDocumentId,Visibility = 'AllUsers');
        insert contentlink;
        
        Test.startTest();
      	emailToCustomerCtrl.getCurrentUserName();
        emailToCustomerCtrl.getContactRole(testOpportunity.Id);
        emailToCustomerCtrl.getContactEmail(new List<String>{ testContact.Id });
        
        boolean isEmailSent = emailToCustomerCtrl.SendEmail(new List<String>{ 'test@example.com' }, 'Test Email Body', testOpportunity.Id, 'Test Subject', new List<String>{ testContact.Id });
        Test.stopTest();
        //System.assertEquals(true, isEmailSent, 'Email should be sent successfully');
    }
   
    @isTest
    private static void testReSendEmail() {
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;

        History_Tracker__c historyTracker = new History_Tracker__c(Document_Name__c = 'opp rec', Object_Record_Ids__c = testOpportunity.Id);
        insert historyTracker;

        Envelope__c envelope = new Envelope__c(Name = 'test envelope', Is_Sent__c = true, Is_Received__c = true, Opportunity__c = testOpportunity.Id);
        insert envelope;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert testContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser0000@example.com' + System.currentTimeMillis(), 
            Alias = 'TUser',
            CommunityNickname = 'testuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            IsActive = true
        );
        insert testUser;

        System.runAs(testUser) {
            EmailTemplate emailTemplate = new EmailTemplate(
                Name = 'Test Email Template',
                FolderId = UserInfo.getUserId(),
                DeveloperName = 'Test_Email_Template',
                HtmlValue = '<html><body>This is the HTML content of your email template.</body></html>',
                Subject = 'Test Email Subject',
                Body = 'This is the plain text content of your email template.',
                TemplateType = 'text'
            );
            insert emailTemplate;
        }

        ContentVersion contentVersion = new ContentVersion(VersionData = Blob.valueOf('test file'), Title = 'test file', PathOnClient = 'test0', Record_Id__c = testOpportunity.Id);
        insert contentVersion;

        ContentVersion cvUpdated = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];

        ContentDocumentLink contentlink = new ContentDocumentLink(LinkedEntityId = testOpportunity.Id, ShareType = 'I', ContentDocumentId = cvUpdated.ContentDocumentId, Visibility = 'AllUsers');
        insert contentlink;

        Test.startTest();
        boolean isEmailSent = emailToCustomerCtrl.reSendEmail(new List<String>{ testContact.Id }, testOpportunity.Id, UserInfo.getUserId(), envelope.Id);
        Test.stopTest();
    }
    
     @isTest
    private static void testRejectSendEmail() {
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today());
        insert testOpportunity;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com');
        insert testContact;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            CommunityNickname = 'testuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            IsActive = true
        );
        insert testUser;
        
        System.runAs(testUser) {
            EmailTemplate emailTemplate = new EmailTemplate(
                Name = 'Test Email Template',
                FolderId = UserInfo.getUserId(),
                DeveloperName = 'Test_Email_Template',
                HtmlValue = '<html><body>This is the HTML content of your email template.</body></html>',
                Subject = 'Test Email Subject',
                Body = 'This is the plain text content of your email template.',
                TemplateType = 'text'
            );
            insert emailTemplate;
        }
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

        Envelope__c envelope = new Envelope__c(
            Name = 'Test Envelope',
            Is_Sent__c = true,
            Is_Received__c = true,
            Opportunity__c = testOpportunity.Id
        );
        insert envelope;

        ContentVersion contentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test file'),
            Title = 'Test File',
            pathOnClient = 'test0',
            Record_Id__c = testOpportunity.Id
        );
        insert contentVersion;
        
        ContentVersion cvUpdated = [select id,ContentDocumentId from ContentVersion where id =: contentVersion.Id];
        
        ContentDocumentLink contentlink = new ContentDocumentLink(
            LinkedEntityId = testOpportunity.Id,
            ShareType = 'I',
            ContentDocumentId = cvUpdated.ContentDocumentId,
            Visibility = 'AllUsers'
        );
        insert contentlink;

        Test.startTest();
        boolean isEmailSent = emailToCustomerCtrl.rejectSendEmail(
            new List<String>{testContact.Id},
            testOpportunity.Id,
            testUser.Id,
            testOpportunity.Id,
            historyTracker.Id
        );
        Test.stopTest();

        //System.assertEquals(true, isEmailSent, 'Email should be sent successfully');
    }
}