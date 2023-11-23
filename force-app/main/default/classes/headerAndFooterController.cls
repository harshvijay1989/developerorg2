// Owner Name : Roshina Azmat
// Designation : salesforce Developer
//Email : roshina@crmlanding.in
//purpose : create Header and Footer records... 
public class headerAndFooterController {
    
    @AuraEnabled
    public static String saveHeaderFooterTemplateConfig(Documnet_Template_Config__c headerData, 
    Documnet_Template_Config__c footerData,String filedata){ 
        System.debug('calling:   ');
        System.debug('calling:   '+filedata);
        fileModal file = new fileModal();
        Map<String,Object> fileDataMap = (Map<String,Object>)JSON.deserializeuntyped(filedata);
       // file.recordId = (String)fileDataMap.get('recordId');
        file.base64 = (String)fileDataMap.get('base64');
        file.filename = (String)fileDataMap.get('filename');
        
         System.debug('calling:   '+file);
        try {
           
            headerData.RecordTypeId = Schema.SObjectType.Documnet_Template_Config__c.getRecordTypeInfosByDeveloperName().get('Document_Header').getRecordTypeId();
            footerData.RecordTypeId = Schema.SObjectType.Documnet_Template_Config__c.getRecordTypeInfosByDeveloperName().get('Document_footer').getRecordTypeId();
            List<Documnet_Template_Config__c> configRecordList = new  List<Documnet_Template_Config__c>{headerData, footerData}; 
            System.debug('configRecordList' + configRecordList);
               
            insert configRecordList;
             if(file != null && file.base64 != null){
                    uploadLogo(headerData.Id, file.base64, file.filename);
              } 
                return 'SUCCESS';
        }  catch (Exception e) { 
            throw new AuraHandledException(e.getMessage() + ', STACK:' + e.getStackTraceString() );    
        }
        
    }
    public class fileModal{
        @AuraEnabled public String recordId{get;set;}	
        @AuraEnabled public String base64{get;set;}
        @AuraEnabled public String filename{get;set;}
    }
    
    @AuraEnabled
    public static String uploadLogo(String recordId, String base64, String filename) {
        Id recordTypeId = Schema.SObjectType.Documnet_Template_Config__c.getRecordTypeInfosByDeveloperName().get('Document_Header').getRecordTypeId();
        List<Documnet_Template_Config__c> listForImg = [SELECT Id, Name,RecordTypeId, RecordType.Name FROM Documnet_Template_Config__c where RecordTypeId =: recordTypeId];
        System.debug('listForImg' + listForImg);

        Attachment attach = new Attachment();
        attach.ParentId = recordId;
        attach.Name = filename;
        attach.Body = EncodingUtil.base64Decode(base64); 
        insert attach;
        System.debug('@@==============>'+ attach);

        System.debug('@@Id_____'+ attach.Id);
		System.debug('@@Id_____'+recordId);  		
        saveAttachementUrl(attach.Id, recordId);
      
        return 'SUCCESS';
        
    }
     
     @AuraEnabled
    public static String saveAttachementUrl(String AttachementId, String recordId) {
        
        String attachementUrl = 'https://crmlandingsoftwareprivatelimited--dev2.sandbox.my.salesforce.com/servlet/servlet.FileDownload?file='+AttachementId;
       	System.debug('@@attachementUrl=============>'+ attachementUrl);
        
        Documnet_Template_Config__c obj = new Documnet_Template_Config__c();
        System.debug('obj=====hello=>'+recordId);
        obj.Id =  recordId;
        obj.Logo_Url__c = attachementUrl;
        System.debug('obj======>'+ obj);
        update obj;
      
        return 'SUCCESS';
        
    }
   @AuraEnabled
    public static List<Documnet_Template_Config__c> getTemplateNames(){
        return [SELECT Id, Template_Name__c,RecordType.Name  FROM Documnet_Template_Config__c where RecordType.Name = :  'Document Header'];
    }
}