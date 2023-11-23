public with sharing class ObjectNameController { 
    public ContentVersion cvPdf;
      
     // Owner Name : Roshina Azmat
    // purpose :  update doc file data 
    @AuraEnabled
    public static String updateTemplate(String recordId, String profileData,  String body, String footer,String documentName, String DocumentStoreAttachementHeader, String pdfBody, String objectName,Boolean isActive){
        System.debug('update template ');
       try {
            List<Document_Template__c> updateTemplate = [SELECT id, Parent_Base_Document_Template1__r.Id FROM Document_Template__c WHERE Id =: recordId];
        profileData=profileData.replace('"','');
        System.debug('profileData ===> '+profileData);
        Document_Template__c documentObj=new Document_Template__c();
        documentObj.Parent_Base_Document_Template1__c  = updateTemplate[0].Parent_Base_Document_Template1__r.Id;
        documentObj.Name = documentName;
        documentObj.isActive__c = isActive;
        documentObj.Permission_Name__c=profileData;
        documentObj.Object_Name__c  = objectName;
        System.debug('documentObj permission '+documentObj.Permission_Name__c);

        Insert documentObj;  
         
        System.debug('updatw template '+documentObj.Id);
           
        Document_Store__c storeObj = new Document_Store__c();
        storeObj.FooterHTML__c = footer;
        insert storeObj; 

        System.debug('store obj updatw temp '+storeObj);
           
        ContentVersion cvDocFile = new ContentVersion();
        cvDocFile.Title = 'Testing';
        cvDocFile.PathOnClient = 'need to store.doc';
        cvDocFile.VersionData = Blob.valueOf(body);
        cvDocFile.IsMajorVersion = false;
        cvDocFile.FirstPublishLocationId = documentObj.Id; 
        insert cvDocFile; 

        ContentVersion cvDocFile1 = new ContentVersion();
        cvDocFile1.Title = 'Content Document';
        cvDocFile1.PathOnClient = 'Document1.doc';
        cvDocFile1.VersionData = Blob.valueOf(pdfBody);
        cvDocFile1.IsMajorVersion = false;
        cvDocFile1.FirstPublishLocationId = documentObj.Id;
        insert cvDocFile1; 
           
        System.debug('update temp all content');
        
        return 'SUCCESS';
        } catch (Exception e) { 
            throw new AuraHandledException( e.getMessage());    
        }
    } 
    
    @AuraEnabled
    public static void wordSaveDataForPDF(String wordBody){
        System.debug('helo word save ');
        
    }
          @AuraEnabled
       public static String saveTemplateWithoutHeaderFooter(String body, String profileData,  Cross_Selling__c documentTemplateRecord){
           System.debug('documentTemplateRecord ' +documentTemplateRecord);
           insert documentTemplateRecord;  
           System.debug('helo save header footer doc without');
        profileData=profileData.replace('"','');
        Document_Template__c documentObj=new Document_Template__c();
    	documentObj.Permission_Name__c=profileData;
        documentObj.Parent_Base_Document_Template1__c=documentTemplateRecord.Id;   
        documentObj.Name=documentTemplateRecord.Name;
        documentObj.isActive__c=documentTemplateRecord.IsActive__c;
        documentObj.Object_Name__c=documentTemplateRecord.Object_Name__c;
    
        insert documentObj;
        
        Document_Store__c storeObj = new Document_Store__c();
        storeObj.document_template__c = documentObj.Id;
        insert storeObj; 
        System.debug('storeObj '+storeObj.Id);
        
        ContentVersion cvDocFile = new ContentVersion();
        cvDocFile.Title = 'Test Document 12';
        cvDocFile.PathOnClient = 'Document1.doc';
        cvDocFile.VersionData = Blob.valueOf(body);
        cvDocFile.IsMajorVersion = false;
        cvDocFile.FirstPublishLocationId = documentTemplateRecord.Id;
        insert cvDocFile; 
        
        ContentVersion cvDocFile1 = new ContentVersion();
        cvDocFile1.Title = 'Content Document';
        cvDocFile1.PathOnClient = 'Document1.doc';
        cvDocFile1.VersionData = Blob.valueOf(body);
        cvDocFile1.IsMajorVersion = false;
        cvDocFile1.FirstPublishLocationId = documentTemplateRecord.Id;
        insert cvDocFile1;
        
        ContentVersion cvDocFile2 = new ContentVersion();
        cvDocFile2.Title = 'Test Document 12';
        cvDocFile2.PathOnClient = 'Document1.doc';
        cvDocFile2.VersionData = Blob.valueOf(body);
        cvDocFile2.IsMajorVersion = false;
        cvDocFile2.FirstPublishLocationId = documentObj.Id;
        insert cvDocFile2; 
        
        ContentVersion cvDocFileA2 = new ContentVersion();
        cvDocFileA2.Title = 'Content Document';
        cvDocFileA2.PathOnClient = 'Document1.doc';
        cvDocFileA2.VersionData = Blob.valueOf(body);
        cvDocFileA2.IsMajorVersion = false;
        cvDocFileA2.FirstPublishLocationId = documentObj.Id;
        insert cvDocFileA2;
                         
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(body);
        attachment.Name = 'body.text';
        attachment.ParentId = storeObj.Id; 
        insert attachment;
           
        System.debug('attachment '+attachment.Id);
           
        History_Tracker__c hsTracker = New History_Tracker__c();
        hsTracker.Name__c = documentTemplateRecord.Name;
        hsTracker.Status__c = 'Document Agreement Accepted/Rejected';
        hsTracker.Step__c = 1;
        hsTracker.Document_Template__c = documentObj.Id;
        hsTracker.Object_Name__c = documentTemplateRecord.Object_Name__c;
        Insert hsTracker;
          
        System.debug('history '+hsTracker.Id);
 
        saveAttachment(storeObj.Id, documentTemplateRecord.Id);
        System.debug('final send ');
        return 'SUCCESS';
    }
    // Owner Name : Roshina Azmat
    // purpose :  save doc file data 
    //please do not touch
    @AuraEnabled
    public static String temSaveDataForPDF(String body, String profileData,   Cross_Selling__c documentTemplateRecord, String footer, String DocumentStoreAttachementHeader, String pdfBody){
        System.debug('with header footer ');
        insert documentTemplateRecord;  
        System.debug('with header footer '+documentTemplateRecord.Id);

        profileData=profileData.replace('"','');
         Document_Template__c documentObj=new  Document_Template__c();
    	documentObj.Permission_Name__c=profileData;
        documentObj.Parent_Base_Document_Template1__c=documentTemplateRecord.Id;   
        documentObj.Name=documentTemplateRecord.Name;
        documentObj.isActive__c=documentTemplateRecord.IsActive__c;
        documentObj.Object_Name__c=documentTemplateRecord.Object_Name__c;
        System.debug('body store in @@@@'+body);
        System.debug('body store pdf body in @@@@'+pdfBody);
        insert documentObj;
        
        System.debug('with header '+documentObj.Id);
        
        Document_Store__c storeObj = new  Document_Store__c();
        storeObj.FooterHTML__c = footer;
        storeObj.document_template__c = documentObj.Id;
        insert storeObj; 
        
        System.debug('document store '+storeObj.Id);
        
        ContentVersion cvDocFile = new ContentVersion();
        cvDocFile.Title = 'Test Document 12';
        cvDocFile.PathOnClient = 'Document1.doc';
        cvDocFile.VersionData = Blob.valueOf(body);
        cvDocFile.IsMajorVersion = false;
        cvDocFile.FirstPublishLocationId = documentTemplateRecord.Id;
        insert cvDocFile; 
        
        
        ContentVersion cvDocFile1 = new ContentVersion();
        cvDocFile1.Title = 'Content Document';
        cvDocFile1.PathOnClient = 'Document1.doc';
        cvDocFile1.VersionData = Blob.valueOf(pdfBody);
        cvDocFile1.IsMajorVersion = false;
        cvDocFile1.FirstPublishLocationId = documentTemplateRecord.Id;
        insert cvDocFile1;
        
        ContentVersion cvDocFile2 = new ContentVersion();
        cvDocFile2.Title = 'Test Document 12';
        cvDocFile2.PathOnClient = 'Document1.doc';
        cvDocFile2.VersionData = Blob.valueOf(body);
        cvDocFile2.IsMajorVersion = false;
        cvDocFile2.FirstPublishLocationId = documentObj.Id;
        insert cvDocFile2; 
        
        
        ContentVersion cvDocFileA2 = new ContentVersion();
        cvDocFileA2.Title = 'Content Document';
        cvDocFileA2.PathOnClient = 'Document1.doc';
        cvDocFileA2.VersionData = Blob.valueOf(pdfBody);
        cvDocFileA2.IsMajorVersion = false;
        cvDocFileA2.FirstPublishLocationId = documentObj.Id;
        insert cvDocFileA2;

		System.debug('all  content version created ');        
        
        //PDF File 
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Header';
        cv.PathOnClient = 'Header.jpg';
        cv.VersionData =  EncodingUtil.base64Decode(DocumentStoreAttachementHeader);
        cv.IsMajorVersion = false;
        insert cv;  
                         
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(pdfBody);
        attachment.Name = 'body.text';
        attachment.ParentId = storeObj.Id; 
        insert attachment;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId;//Add ContentDocumentId
        cDocLink.LinkedEntityId = storeObj.Id;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
        History_Tracker__c hsTracker = New History_Tracker__c();
        hsTracker.Name__c = documentTemplateRecord.Name;
        hsTracker.Status__c = 'Document Agreement Accepted/Rejected';
        hsTracker.Step__c = 1;
        hsTracker.Document_Template__c = documentObj.Id;
        hsTracker.Object_Name__c = documentTemplateRecord.Object_Name__c;
        Insert hsTracker;
        
        saveAttachment(storeObj.Id, documentTemplateRecord.Id);
        System.debug('History tracker '+hsTracker.Id);
        return 'SUCCESS: ' + storeObj.Id;
    }
    
    
    @future(callout=true)
    public static void saveAttachment(String storeRecordId, String recordId){  
        System.debug('save attachment ');
        PageReference docPage = Page.docPDF;
        docPage.setRedirect(true);
        docPage.getParameters().put('recordId', storeRecordId);
        Blob contentBody;
        if(test.isrunningtest()){
           contentBody = blob.valueOf('test data'); 
        }else{
        	contentBody = docPage.getContentAsPDF();    
        }
         
        ContentVersion cv = new ContentVersion();
        cv.Title = 'MyDocument';
        cv.PathOnClient = 'MyDocument.doc';
        cv.VersionData =  contentBody;
        cv.IsMajorVersion = false;
        insert cv; 

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId;//Add ContentDocumentId
        cDocLink.LinkedEntityId = recordId; //Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink; 
        
        System.debug('success full save attachment ');
    }
    
    
    //Ravi code here -> Pdf File 
    @AuraEnabled
    public static String temSaveDataForPDF1(String docTemId, String pdfBody, String oppRecId){ 
        System.debug('temsavedataforpdf1');
        try{
            if(pdfBody.containsIgnoreCase('Error,')){
                return pdfBody;
            }
            System.debug('1111@@@ '+Limits.getCpuTime());
            
            System.debug('--- docTemId : '+ docTemId);
            List<Document_Store__c> storeObjLst = [SELECT Id, Name, body__c, footer__c, CreatedDate, document_Template__c from Document_Store__c  where document_Template__c =: docTemId limit 1];
            String storeObj;
            System.debug('--- storeObjLst : '+ storeObjLst);
            System.debug('document store tempdatasafevpdf1 '+storeObjLst);

            if(storeObjLst.size() > 0){
                storeObj = storeObjLst[0].Id;
            }

            List<Attachment> attLst = new List<Attachment>();
            List<Attachment> attDel = new List<Attachment>();
            attLst = [SELECT id, body, ParentId from Attachment where ParentId =: storeObj];

            if(attLst.size() > 0){
                for(Attachment attObj : attLst){
                    attDel.add(attObj);    
                    
                }
                delete attDel;
            }
            System.debug('--- storeObj '+ storeObj);
            System.debug('--- pdfBody '+ pdfBody);
            System.debug('--- oppRecId '+ oppRecId);
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(pdfBody);
            attachment.Name = 'PDF_Body-2.text';
            attachment.ParentId = storeObj;  
            insert attachment;
            System.debug('--- attachment :'+ attachment.Body);
            DateTime startTime = DateTime.now();

            saveAttachmentPDF(storeObj, oppRecId);  
           
            return 'SUCCESS: save attachment pdf @@@@ ' + storeObj;
        }catch(Exception e){
            System.debug('**--- Pre error :'+ e.getLineNumber());
            System.debug('**--- Pre error :'+ e.getMessage());
            return 'Error, '+ e.getMessage();
        }
    }
    
  
    @future(callout=true)
    public static void saveAttachmentPDF(String storeRecordId, String recordId){  
        System.debug('save attachment pdf ');
        System.debug('stroe recor d id '+storeRecordId);
        System.debug('recordId @@ '+recordId);
        try{
            PageReference docPage = Page.docPDF;
            docPage.setRedirect(true);
            docPage.getParameters().put('recordId', storeRecordId);
            Blob contentBody = docPage.getContentAsPDF(); 
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'PDF_MyDocument';
            cv.PathOnClient = 'PDF_MyDocument.pdf';
            cv.VersionData =  contentBody;
            cv.IsMajorVersion = false;
            insert cv; 
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocumentId;//Add ContentDocumentId
            cDocLink.LinkedEntityId = recordId; //Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers , InternalUsers, SharedUsers
            Insert cDocLink; 
            
        }catch(Exception e){
            System.debug('**--- Pre error :'+ e.getLineNumber());
            System.debug('**--- Pre error :'+ e.getMessage());
            String errorMsg = 'Error, ' + e.getMessage(); 
            ObjectNameController.temSaveDataForPDF1('', errorMsg,'');
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectNames() {
        System.debug('getobject name ');
        List<String> objectNames = new List<String>();
      
        // Query for all objects
        List<Schema.SObjectType> objectTypes = Schema.getGlobalDescribe().values();
        for (Schema.SObjectType objectType : objectTypes) {
            String objectName = objectType.getDescribe().getName();
            objectNames.add(objectName);
        }
        return objectNames;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FieldDescribe> getObjectFields(String objectName) {
        System.debug('getobjectfields');
        List<FieldDescribe> fields = new List<FieldDescribe>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            for (String fieldName: fieldMap.keySet()) {  
                Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
                
                if (field.isAccessible()) {
                    String label = field.getLabel();
                    if(String.valueof(field.getType()) == 'REFERENCE'){
                        label = label+' >';
                    }
                    fields.add(new FieldDescribe(label, field.getName(),apexTypetoJSType.get(String.valueof(field.getType()))));
                    System.debug(' Fieldsssss '+fields);
                }
            } 
        }
        
        return fields;
    }
    
    public class FieldDescribe {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String datatype;
        
        public FieldDescribe(String label, String value, String datatype) {
            this.label = label;
            this.value = value;
            this.datatype = datatype;
            
        }
    }
    public static Map<String, String> apexTypetoJSType = new Map<String, String> {
        'ADDRESS' => 'text',
            'ID' => 'text',
            'TEXTAREA' => 'text',
            'STRING' => 'text',
            'REFERENCE' => 'lookup',
            'PICKLIST' => 'text',
            'MULTIPICKLIST' => 'text',
            'DATE' => 'date',
            'DOUBLE' => 'number',
            'PERCENT' => 'percent',
            'PHONE' => 'phone',
            'URL' => 'url',
            'INTEGER' => 'number',
            'CURRENCY' => 'currency',
            'DATETIME' => 'date',
            'BOOLEAN' => 'boolean',
            'EMAIL' => 'email'
            };
                
                @AuraEnabled public static String getApiName (String objNameAPI , String objLabel){
                    String apiName = '';
                    Map<String, String> fieldsMap = new Map<String, String>();
                    Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get(objNameAPI).getDescribe().fields.getMap().get(objLabel).getDescribe();
                    for(Schema.SObjectType reference :  f.getReferenceTo()) {
                        apiName = reference.getDescribe().getName();
                    }
                    return apiName; 
                }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getParentObjects(string obj) { 
        System.debug('selected parent obj '+obj);
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);
        string selectedObj = obj;
        List<String> parentObjects = new List<String>();
        for(Schema.SobjectField strFld: objType.getDescribe().fields.getMap().Values())
        {
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE)  {
              	Schema.DescribeFieldResult fieldResult = strFld.getDescribe();
         	   if (fieldResult.isCustom() || fieldResult.getReferenceTo().size() > 0) {
            	    parentObjects.add(fieldResult.getReferenceTo()[0].getDescribe().getName());   
            	}
            }
        }
                
                Set<String> uniqueParentObjects = new Set<String>(parentObjects);
                parentObjects = new List<String>(uniqueParentObjects);
                System.debug('parent objects '+parentObjects);
             
        
        return parentObjects;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getChildObjects(string obj) { 
        System.debug('selected child obj '+obj);
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj);
        string selectedObj = obj;
        
        Schema.DescribeSObjectResult R = objType.getDescribe();
        List<String> childObjects = new List<String>();
        for (Schema.ChildRelationship cr: R.getChildRelationships()) 
        {
            childObjects.add(String.valueOf(cr.getChildSObject()));   
        }
        Set<String> uniqueChildObjects = new Set<String>(childObjects);
        childObjects = new List<String>(uniqueChildObjects);
        System.debug('child objects '+childObjects);
        return childObjects;
        
        
    }  
    //Owner:Rajesh
    //Method for fetch Company Address
    @AuraEnabled(cacheable=true)
    public static List<Organization > getCompanyInfo() {                 
        return [SELECT Id, IsSandbox, OrganizationType, Name, Division, Street, City, State, PostalCode, Country,Address, Phone FROM Organization];
        
    }  
    @AuraEnabled(cacheable=true)
    public static String getOrgBaseUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }    
}