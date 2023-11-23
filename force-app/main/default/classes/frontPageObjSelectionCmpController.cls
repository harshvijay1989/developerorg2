public with sharing class frontPageObjSelectionCmpController {
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectNames() {
        List<String> objectNames = new List<String>();
        
        // Query the object names and sort them in ascending order
        List<Schema.SObjectType> objectTypes = Schema.getGlobalDescribe().Values();
        for (Schema.SObjectType objectType : objectTypes) {
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            objectNames.add(describeResult.getName());
        }
        objectNames.sort();
        
        return objectNames;
    }
}