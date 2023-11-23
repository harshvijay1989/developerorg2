public class ConfigrationPageCMP_Handler {
    public string body{get;set;}
    public string bodytable{get;set;}
    
    
    @AuraEnabled
    public static String getObjectName(String recordIdOrPrefix){
        DateTime StartTimegetObjectName = Datetime.Now();
        
        String objectName = '';
        String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
        
        //Get schema information
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        
        //Loop through all the sObject types returned by Schema
        for(Schema.SObjectType stype : gd.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            //Check if the prefix matches with requested prefix
            if(prefix!=null && prefix.equals(myIdPrefix)){
                objectName = r.getName();
                break;
            }
        }
        DateTime EndTimegetObjectName = Datetime.now();
        return objectName;
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getCurrentUserProfileId() {
        return UserInfo.getProfileId();
    }
    
    @AuraEnabled
    public static void insertRecordDT(String strRichText){
        if(String.isNotBlank(strRichText)){
           // Document_Template__c documentObj=new Document_Template__c();
            //documentObj.Rich_Text_Field__c=strRichText;
            //insert documentObj;
        }
    }
 
    @AuraEnabled
    public static List<DocumentTemplateWrapper> getDocumentTemplate(String recordId){
        System.debug('Final method');
        String permission = '';
        List<DocumentTemplateWrapper> documentTemplateModalList = new List<DocumentTemplateWrapper>();  
        List<Document_Template__c> permissionSelected  = [SELECT Permission_Name__c from Document_Template__c ];
        System.debug('permission selected '+permissionSelected);
        List<Document_Template__c> SelectedRecord = new List<Document_Template__c>();
        
        Id profileId=userinfo.getProfileId();
        System.debug('profile Id ..............'+profileId);
        String profileName=[Select Name from Profile where Id=:profileId].Name;
        System.debug('profile name  '+profileName);
        LIST<String> profileList = new LIST<String>(); 
        profileList.add('ABC');
        Boolean isProfile = false;
        for(Document_Template__c obj : permissionSelected){
            //System.debug('enter rrr');
            if(String.isNotBlank(obj.Permission_Name__c)){
                profileList.addAll(obj.Permission_Name__c.split(','));
                //String isTrue = obj.Permission_Name__c.split(',');
                if(obj.Permission_Name__c.contains(profileName)){
                    isProfile = true;
                }
            }
        }
        System.debug('isProfile ****'+isProfile);
        Set<String> uniqueProfileList = new Set<String>(profileList);
        //uniqueProfileList.add('Hello');
        System.debug('uniqueProfileList set'+uniqueProfileList);
        if (isProfile == true) {
            System.debug('uniqueProfileList contains'+profileName);
            List<Document_Template__c> documentTemplate = [SELECT Id,name,Object_Name__c,isActive__c,Permission_Name__c FROM Document_Template__c Where  Object_Name__c != null  ORDER BY Name  ASC]; 
            System.debug('documentTemplate #####'+documentTemplate);
            for(Document_Template__c obj1 : documentTemplate){
                System.debug('obj1 document '+obj1);
     		   if (obj1.Permission_Name__c.contains(profileName)) {
                    System.debug('SelectedRecord '+obj1.Permission_Name__c);
                    SelectedRecord.add(obj1);
                }
            }
            
            if(SelectedRecord != null && !SelectedRecord.isEmpty()){
                Map<Id, Document_Template__c> documentTemplateMap = new Map<Id, Document_Template__c>(SelectedRecord); 
                Map<String, List<ContentVersion>> contentVersionMap = getAttachments(documentTemplateMap); 
                
                for(String documentTemplateId : documentTemplateMap.keySet()){
                    DocumentTemplateWrapper obj = new DocumentTemplateWrapper();
                    obj.documentTemplate = documentTemplateMap.get(documentTemplateId);
                    if(contentVersionMap.containsKey(documentTemplateId)){ 
                        obj.files = contentVersionMap.get(documentTemplateId);
                    }
                    documentTemplateModalList.add(obj); 
                }                
            }
            return documentTemplateModalList;
        } 
        return null;
        
    } 

// Owner Name : Roshina Azmat
// purpose :  for file preview
public class DocumentTemplateWrapper {
    @AuraEnabled public Document_Template__c documentTemplate {get;set;}
    @AuraEnabled public List<ContentVersion> files {get;set;}
}

// Owner Name : Roshina Azmat
// purpose :  for file preview
@AuraEnabled
public static Map<String, List<ContentVersion>> getAttachments(Map<Id, Document_Template__c> projectMap){ 
    
    Map<String, List<ContentVersion>> projectWithContentVersionMap = new Map<String,  List<ContentVersion>>();
    Map<String, String> projectAndContentDocumentMap = new  Map<String, String>();
    
    for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId  IN : projectMap.keySet()]) {
        projectAndContentDocumentMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
    }   
    
    for(ContentVersion cv : [SELECT  Title, ContentDocumentId, IsLatest, ContentUrl, VersionNumber, FileType, FileExtension, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :projectAndContentDocumentMap.keySet() ORDER BY CreatedDate DESC]){
        String projectId = projectAndContentDocumentMap.get(cv.ContentDocumentId);
        if(projectWithContentVersionMap.containsKey(projectId)){
            projectWithContentVersionMap.get(projectId).add(cv);
        }else{
            projectWithContentVersionMap.put(projectId, new List<ContentVersion>{cv});
        }
    } 
    return projectWithContentVersionMap; 
}

public static void getOpportunityData(Map<String,Set<String>> objectWithFields,String filedata){     
    if(!objectWithFields.isEmpty()){
        String objectQuery='SELECT ID,Name,CloseDate,';
        for(String getSingleObject : objectWithFields.keyset()){
            Set<String> getParentObjectNames=getParentObjectName(getSingleObject);
            Set<String> getChildObjectNames=getChildRelationShipName(getSingleObject);
            if(getParentObjectNames.contains(getSingleObject)){
                set<String> ParentFields=objectWithFields.get(getSingleObject);                
                List<string>ParentFieldsTemp=new List<String>(ParentFields);                
                if(!ParentFieldsTemp.isEmpty()){
                    String joinedString='';
                    //joinedString+=String.join(ParentFieldsTemp, ', '); 
                    for (Integer i = 0; i < ParentFieldsTemp.size(); i++) {
                        joinedString = getSingleObject+'.'+ParentFieldsTemp[i];
                        if (i < ParentFieldsTemp.size() - 1) {
                            joinedString += ',';
                            
                        }
                        objectQuery+=joinedString; 
                    }                        
                }
            }else{
                objectQuery+=' FROM Opportunity Where Id =\'0061y0000092iLtAAI\'';
            }
        } 
        
        
        Opportunity oppObj=Database.query(objectQuery);      
        string subString='';
        if(oppObj!=null){
            filedata=filedata.replaceAll('>', '> ');
            filedata=filedata.replaceAll('<', ' <');    
            subString=filedata;
            
            subString=subString.replace('{!Opportunity.Name}',String.valueOf(oppObj.get('Name')));
            subString=subString.replace('{!Opportunity.CloseDate}',String.valueOf(oppObj.get('CloseDate')));
            subString=subString.replace('{!Account.Name}',(String)oppObj.getSObject('Account').get('Name'));
            subString=subString.replace('{!Account.Phone}',(String)oppObj.getSObject('Account').get('Phone'));
        }       
        
        
        Document_Template__c documentTempObj=[SELECT  Long__c, Object_Name__c,isActive__c, Template_Name__c, Name, Id FROM Document_Template__c Where Id='a0j1y000000rm5HAAQ'];
        Map<Id, Document_Template__c> projectMap=new Map<Id, Document_Template__c>();
        Map<String, List<ContentVersion>> projectWithContentVersionMap = new Map<String,  List<ContentVersion>>();
        Map<String, String> projectAndContentDocumentMap = new  Map<String, String>();
        
        
        
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId  = :documentTempObj.Id ]) {
            projectAndContentDocumentMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }   
        
        ContentVersion cv=[SELECT  Title, ContentDocumentId, IsLatest, ContentUrl, VersionNumber, FileType, FileExtension, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN :projectAndContentDocumentMap.keySet() ORDER BY CreatedDate DESC];
        ContentVersion newVersion = new ContentVersion();
        newVersion.ContentDocumentId = cv.ContentDocumentId;
        newVersion.VersionData = Blob.valueOf(subString);
        newVersion.pathOnClient = cv.Title+'.docx';
        //insert newVersion;       
        
        
    }
}
public static void getObjectDataAndReplacement(String fileData){
    
}
public static Set<String> getParentObjectName(string objectName){
    Set<String> parentRelationShipObjectName=new Set<String>();  
    if(String.isNotEmpty(objectName)){
        for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().Values()){
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                List <Schema.SObjectType> fieldsList = strFld.getDescribe().getReferenceTo();
                for (schema.SObjectType fieldRef : fieldslist )
                {
                    parentRelationShipObjectName.add(String.valueOf(fieldRef));   
                }      
            } 
        }
    }
    
    return parentRelationShipObjectName;
    
}
public static Set<String> getChildRelationShipName(string objectName){
    Set<String> childRelationShipObjectName=new Set<String>();  
    Schema.DescribeSObjectResult parentDescribe =Schema.getGlobalDescribe().get('Opportunity').getDescribe();
    List<Schema.ChildRelationship> childRelationships = parentDescribe.getChildRelationships();
    for (Schema.ChildRelationship childRelationship : childRelationships) {
        String childRelationshipName = childRelationship.getRelationshipName();
        if(String.isNotEmpty(childRelationshipName)){
            childRelationShipObjectName.add(childRelationshipName);
        }  
    }
    return childRelationShipObjectName;
}

public static Map<String,Set<String>>  getObjectData(List<String> fillterQueryData,string fileData){
    Map<String,Set<String>> objectWithFields=new Map<String,Set<String>>();
    if(!fillterQueryData.isEmpty()){
        for(String strObj : fillterQueryData){
            String objectName=strObj.substringBetween('!', '.');
            String fieldName=strObj.substringBetween('.', '}');
            if(objectWithFields.containsKey(objectName)){
                Set<String> strTemp=objectWithFields.get(objectName);
                strTemp.add(fieldName);
                objectWithFields.put(objectName,strTemp);
            }else{
                Set<String> strTemp=new Set<String>();
                strTemp.add(fieldName);
                objectWithFields.put(objectName,strTemp);
            }
        }
    }
    
    if(!objectWithFields.isEmpty()){
        getOpportunityData(objectWithFields,fileData);
        return objectWithFields;
    }else{
        return null;
    }
    
}

public static void getFieldAPIs(String fileData){
    String withOutHTML=fileData.replaceAll('<[^>]+>', ' ');
    List<String> fillterQueryData=new List<String>();
    if(String.isNotEmpty(fileData)){
        String strtmp=withOutHTML.replaceAll('\\s+', ' ').trim();       
        List<String> strList=strtmp.split(' ');
        for(String strObj : strList){
            if((strObj.startsWith('{') || strObj.startsWith('(')) && (strObj.endsWith('}') || strObj.endsWith(')'))){
                fillterQueryData.add(strObj);
            }
        }          
    }
    getObjectData(fillterQueryData,fileData);
    
}
@AuraEnabled
public static String getDocuContentBody(String recId,String contentDId){
    
    Http h = new Http(); 
    HttpRequest req = new HttpRequest(); 
    String endpoint=URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v56.0/sobjects/ContentVersion/'+contentDId+'/VersionData';
    req.setEndpoint(endpoint); 
    req.setMethod('GET'); 
    req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId()); 
    req.setHeader('Content-Type', 'application/json'); 
    HttpResponse res = h.send(req); 
    
    getFieldAPIs(res.getBody());
    return res.getBody();
}

}