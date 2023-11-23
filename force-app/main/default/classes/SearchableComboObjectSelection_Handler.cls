public class SearchableComboObjectSelection_Handler {
    @AuraEnabled(cacheable=true)
    //@AuraEnabled
    public static List<DataWrapper> getObjectNames() {
        List<DataWrapper> objectDataNames = new List<DataWrapper>();
        
        // Query the object names and sort them in ascending order
        List<Schema.SObjectType> objectTypes = Schema.getGlobalDescribe().Values();
        for (Schema.SObjectType objectType : objectTypes) {
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            objectDataNames.add(new DataWrapper(describeResult.getlabel(),describeResult.getName()));
        }
       
        return objectDataNames;
    }

    public class DataWrapper{
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string value;
        public DataWrapper(string label,string value){
            this.label=label;
            this.value=value;
        }
    }
}