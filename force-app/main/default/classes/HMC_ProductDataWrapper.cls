public class HMC_ProductDataWrapper {
    @AuraEnabled public list<ProductTypeOptionWrapper> productTypeList{get;set;}
    @AuraEnabled public Map<String,PricebookEntry> mapOfProductIdVsPricebookEntry{get;set;}
    @AuraEnabled public list<HMC_OLIWrapper> exisintingOLIList{get;set;}
    @AuraEnabled public List<String> models{get;set;}
    @AuraEnabled public List<String> AICMAList{get;set;}
     @AuraEnabled public List<String> aicma{get;set;}
    @AuraEnabled public Map<String,String> mapOfProductIdVsFileId{get;set;}
    @AuraEnabled public Order__c objOfOpportunity{get;set;}
    @AuraEnabled public Map<String,List<String>> mapOfModelandAICMA{get;set;}
    @AuraEnabled public List <Product2__c> lstOfProduct{get;set;}
    @AuraEnabled public String finalnote {get;set;}
    @AuraEnabled public String creditLimt {get;set;} // onload credit limit
    @AuraEnabled public Boolean DealerCodeNotPresent {get;set;} // true when dealer code present
    public HMC_ProductDataWrapper(){
        productTypeList = new list<ProductTypeOptionWrapper>();
    	mapOfProductIdVsPricebookEntry = new Map<String,PricebookEntry>();
    	exisintingOLIList = new list<HMC_OLIWrapper>();
    	mapOfProductIdVsFileId = new Map<String,String>();    	
        objOfOpportunity = new Order__c();
        mapOfModelandAICMA = new Map<String,List<String>>();
        models = new List<String>();
        aicma = new List<String>();
        lstOfProduct = new List <Product2__c>();
        AICMAList = new List<String>();
    }
    public class ProductTypeOptionWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public ProductTypeOptionWrapper(String value,String label){
            this.label = label;
            this.value = value;
        }
    }
}