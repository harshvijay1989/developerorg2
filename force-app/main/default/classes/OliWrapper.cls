public class OliWrapper {
    @AuraEnabled public String orderItemId{get;set;}
    @AuraEnabled public boolean expanded{get;set;}
    @AuraEnabled public List<String> thikinessValSet{get;set;}
    @AuraEnabled public String size{get;set;}
    //@AuraEnabled public String thiknessSelectedVal{get;set;}*/
    @AuraEnabled public Decimal quantityTypeBaseVale{get;set;} 
    @AuraEnabled public Decimal totalAmount{get;set;} 
    @AuraEnabled public Decimal price{get;set;} 
    @AuraEnabled public String quantityTypes{get;set;}  
    @AuraEnabled public List<string> quantityTypesList{get;set;}  
    @AuraEnabled public List<String> typePicValList{get;set;}
    @AuraEnabled public String typePic{get;set;}
    
    @AuraEnabled public String ProductName{get;set;}
    
    @AuraEnabled public String productId{get;set;}
    @AuraEnabled public String quantity{get;set;}
    @AuraEnabled public String roundSection{get;set;}
    @AuraEnabled public Set<String> materialTypeList{get;set;}
    @AuraEnabled public String materialType{get;set;}
   /* @AuraEnabled public List<String> roundSectionList{get;set;}
    @AuraEnabled public String grade{get;set;}
    @AuraEnabled public Decimal length{get;set;}
    @AuraEnabled public String surfaceCondition{get;set;}
    @AuraEnabled public String isSpecification{get;set;}
    @AuraEnabled public String endCondition{get;set;}
    @AuraEnabled public String deliveryRemark{get;set;}
    @AuraEnabled public String specialRemark{get;set;}
    @AuraEnabled public boolean roundSectionDis{get;set;}
    @AuraEnabled public boolean isSizeDisabled{get;set;}
    @AuraEnabled public boolean isTypeDisabled{get;set;}
    @AuraEnabled public boolean isThicknessDisabled{get;set;}
    @AuraEnabled public boolean queantityTypeDis{get;set;}
    @AuraEnabled public decimal totalQuantityInTons{get;set;}
    @AuraEnabled public decimal totalQuantityInMeter{get;set;}
    @AuraEnabled public boolean isOrderLineItemAccepted{get;set;}
    @AuraEnabled public boolean isOrderAccepted{get;set;}*/
    @AuraEnabled public List<Product2__c> product2List{get;set;}
    @AuraEnabled public List<Product2__c> product2ListWithPrice{get;set;}
    @AuraEnabled public String specialRemark{get;set;}
    @AuraEnabled public Integer DealerPrice{get;set;}
    @AuraEnabled public Integer TotalPrice{get;set;}
    @AuraEnabled public String product2Id{get;set;}
    
    public OliWrapper(){
        //materialTypeList = new Set<String>();
        price = 0;
        DealerPrice = 0;
        TotalPrice = 0;
        quantityTypeBaseVale = 0.00;
        product2List=new List<Product2__c>();
        product2ListWithPrice=new List<Product2__c>();
        /*roundSectionDis = false;
        isSizeDisabled = false;
        isTypeDisabled = false;
        queantityTypeDis = false;
        isThicknessDisabled = false;
        isOrderLineItemAccepted = false;
        isOrderAccepted = false;*/
    }
}