@isTest
public class DocumentUtility_HandlerTest {
	
    @isTest
    static void testDocumentUtilityMethods() {
        
        Account testAccount = new Account(Name = 'Test Account', Industry = 'Technology');
        insert testAccount;
        Map<String, String> fieldMap = new Map<String, String>{'Name' => 'Name', 'Industry' => 'Industry'};
        List<String> fieldList = new List<String>{'Name', 'Industry'};
        String objectName = 'Account';
        
        Test.startTest();
        Boolean isValid = DocumentUtility_Handler.validateDoc(fieldList, objectName);
        //System.assertEquals(true, isValid);
        Map<String, String> blankData = DocumentUtility_Handler.getBlankData(fieldMap);
        //System.assertEquals(2, blankData.size());

        Map<String, String> patternData = DocumentUtility_Handler.makePattern(fieldMap);
        //System.assertEquals(2, patternData.size());
        
        DocumentUtility_Handler.getAllData(fieldMap,'Account',testAccount.Id);
		Test.stopTest();
     }

    
    @isTest
    static void testgetAllData() {
        Map<String, String> fieldMap = new Map<String, String>{'Name' => 'Name', 'Industry' => 'Industry','Type' => 'Type', 'BillingStreet' => 'BillingStreet', 'BillingCity' => 'BillingCity', 'BillingCountry' => 'BillingCountry'};
        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account', Industry = 'Technology');
        insert testAccount;
    	DocumentUtility_Handler.getAllData(fieldMap,'Account',testAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllData1() {
        Map<String, String> fieldMap = new Map<String, String>{
            'Name' => 'AccountName',
            'BillingCity' => 'TestCity',
            'Owner.Name' => 'OwnerName'
        };

        Account testAccount = new Account(Name = 'Test Account', BillingCity = 'TestCity');
        insert testAccount;

        Test.startTest();

        Map<String, String> result = DocumentUtility_Handler.getAllData(fieldMap, 'Account', testAccount.Id);

        Test.stopTest();

        /*System.assertEquals('AccountName', result.get('Name'), 'Name should have the expected value');
        System.assertEquals('TestCity', result.get('BillingCity'), 'BillingCity should have the expected value');
        System.assertEquals('OwnerName', result.get('Owner.Name'), 'Owner.Name should have the expected value');

        System.assertEquals('SELECT id, Name, BillingCity FROM Account WHERE id=\'' + testAccount.Id + '\' LIMIT 1', YourClassName.getLastQuery(), 'Query formed incorrectly');
        System.assertNotNull(YourClassName.getLastQueriedObject(), 'Content should not be null');*/
    }


}