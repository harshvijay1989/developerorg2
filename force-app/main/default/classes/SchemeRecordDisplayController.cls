public class SchemeRecordDisplayController {
    
    @AuraEnabled(cacheable=true)
    public Static List<Scheme__c> getAllScheme(){
        List<Scheme__c> schemeListIsPublic = [SELECT Id, Name,Thumbnail__c,Title__c, Start_Date__c,End_Date__c FROM Scheme__c];
        return schemeListIsPublic;    
    }
    
    @AuraEnabled
    public static String getschemedetail(String searchKey){
        Scheme__c sc = [select Id, Name,Product__c, Start_Date__c,Thumbnail__c,Description__c,End_Date__c from Scheme__c where Id =: searchKey LIMIT 1];
        return JSON.serialize(sc);       
    }
}