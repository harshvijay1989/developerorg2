@isTest
public class ObjectNameControllerTest {
    
    @isTest
    private static void testMethod1(){
        Test.startTest();
        //ObjectNameController.updateTemplate
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateTemplate() {
        
        Cross_Selling__c crossSelling = new Cross_Selling__c();
        crossSelling.name = 'test';
        crossSelling.IsActive__c = true;
        crossSelling.Object_Name__c = 'test';
        insert crossSelling;
        
        Document_Template__c testTemplate = new Document_Template__c();
        testTemplate.Name = 'test name';
        testTemplate.isActive__c = true;
        testTemplate.Permission_Name__c = 'System Administrator';
        testTemplate.Parent_Base_Document_Template1__c = crossSelling.Id;
        //testTemplate.Template Name

        insert testTemplate;
        
        Test.startTest();
        
        Cross_Selling__c crossSelling1 = new Cross_Selling__c(name = 'test',IsActive__c = true,Object_Name__c = 'test');
        Cross_Selling__c crossSelling2 = new Cross_Selling__c(name = 'test',IsActive__c = true,Object_Name__c = 'test');
        
        String result = ObjectNameController.updateTemplate(testTemplate.Id, 'Test Profile Data', 'Test Body', 'Test Footer', 'Test Document','Test Header', 'Test PDF Body', 'Test Object', true);
		ObjectNameController.getObjectNames();   
        
        String profileData = '{"key": "value"}';
        String result1 = ObjectNameController.saveTemplateWithoutHeaderFooter('Dummy document body', profileData, crossSelling1);
        String result3 = ObjectNameController.temSaveDataForPDF('Dummy document body', profileData, crossSelling2, 'Dummy footer', 'Base64EncodedHeaderImage', 'Base64EncodedPDFBody');
        
        ObjectNameController.getCompanyInfo();
        ObjectNameController.getOrgBaseUrl();
        List<String> childObjLst = ObjectNameController.getChildObjects('Account');
        List<String> parentObjLst = ObjectNameController.getParentObjects('Contact');
        ObjectNameController.getObjectFields('Account');
        //ObjectNameController.getApiName('Account','Account');
        Test.stopTest();
        System.assertEquals('SUCCESS', result);
        System.assertEquals('SUCCESS', result1);
        System.assert(childObjLst.size() > 0);
        System.assert(parentObjLst.size() > 0);
        
        
    }
    
}