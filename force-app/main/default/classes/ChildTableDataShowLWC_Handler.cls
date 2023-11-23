public class ChildTableDataShowLWC_Handler {
    @AuraEnabled(cacheable=true)
    public static List<DataWrapper> getSelectedObjectFields(String selectedObject){
        List<DataWrapper> DataWrapperList=new List<DataWrapper>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();     
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            DataWrapperList.add(new DataWrapper(fieldResult.getLabel(),fieldResult.getName()));
        }
        System.debug(DataWrapperList);
        return DataWrapperList;
    }

    public Class DataWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiValue;
        public DataWrapper(String label,String apiValue){
            this.label=label;
            this.apiValue=apiValue;
        }
    }
}