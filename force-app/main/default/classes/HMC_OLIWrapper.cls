public class HMC_OLIWrapper {
    @AuraEnabled public String productId{get;set;}
    @AuraEnabled public List<Product2__c> lstProductsFilter{get;set;}
    @AuraEnabled public product2__c product{get;set;}
    @AuraEnabled public priceBookEntry priceBookEntry{get;set;}
    @AuraEnabled public Decimal listPrice{get;set;}
    @AuraEnabled public Decimal RetaillistPrice{get;set;} //added by prasanna
    @AuraEnabled public String productType{get;set;}
    @AuraEnabled public String quantity{get;set;}
    @AuraEnabled public String priceBookEntryId{get;set;}
    @AuraEnabled public String fileId{get;set;}
    @AuraEnabled public String model{get;set;}
    @AuraEnabled public String Tax{get;set;}
    @AuraEnabled public Set<String> AICMAList{get;set;}
    @AuraEnabled public String AICMA{get;set;}
    @AuraEnabled public String type{get;set;}//added by Uday
    @AuraEnabled public String StockFlag{get;set;}
    @AuraEnabled public String Disount{get;set;} //added by prasanna
    @AuraEnabled public String FinalPrice{get;set;} //added by prasanna
    @AuraEnabled public String TotalPrice{get;set;} //added by prasanna
    @AuraEnabled public String Chaincover{get;set;}
    @AuraEnabled public String Tyre{get;set;}
    @AuraEnabled public String Newkit{get;set;}
    @AuraEnabled public String Saddles{get;set;}
    @AuraEnabled public List<String> models{get;set;}
    @AuraEnabled public List<String> aicmas{get;set;}
    @AuraEnabled public Decimal unitPrice {get;set;}
    // get price
    // Added K-MRP
    @AuraEnabled public String MRP{get;set;}
    @AuraEnabled public String BasePrice{get;set;}//BasePrice   TotalDiscount   NetAmount
    @AuraEnabled public String TotalDiscount{get;set;}
    @AuraEnabled public String NetAmount{get;set;}
    @AuraEnabled public String OfferDescription{get;set;}
    @AuraEnabled public String DiscountType{get;set;}
    @AuraEnabled public String DistributerDiscount{get;set;}
    @AuraEnabled public String DPDiscount{get;set;}
    @AuraEnabled public String MRPDiscount{get;set;}
    @AuraEnabled public String CustomerGroup{get;set;}
    @AuraEnabled public String AreaId{get;set;}
    
    public HMC_OLIWrapper(){
        AICMAList = new Set<String>();
    }
}