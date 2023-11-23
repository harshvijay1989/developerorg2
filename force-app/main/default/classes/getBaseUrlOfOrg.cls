public with sharing class getBaseUrlOfOrg {
    
    @AuraEnabled(cacheable=true)
    public static String getOrgBaseUrl() {
        
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
}