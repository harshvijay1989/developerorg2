public class HMC_OrderPreviewController {
    public order__c quoObj{set;get;}
    public Account hmcObj{get;set;}
    public list<order__c> quoLineItemList{set;get;}  
    public Decimal totalPrice {set;get;}
    public Integer totalQuantity {get;set;}
    public id recID{get;set;}
    public String BuTypeOfDealer { get; set; }
    
    public HMC_OrderPreviewController(ApexPages.StandardController std){
        String currentRecordId  = ApexPages.CurrentPage().getparameters().get('Id');
        //Opportunity BuType = [SELECT Account.hmc_Bu_Type__c  FROM Opportunity where id=:currentRecordId];
        //if(BuType.Account.hmc_Bu_Type__c == 'Firefox'){
            BuTypeOfDealer = 'Firefox';
            System.debug('firefox');
            Decimal total = 0;
            Integer quantity = 0;
            Decimal rounded = 0;
            quoObj=[SELECT LastModifiedById,Id,Account__c,Owner.Name,Account__r.HMC_Contact_Email__c,Account__r.HMC_Contact_Number__c,Account__r.Fax,Account__r.Name,Account__r.BillingState,Account__r.ShippingState,CreatedDate,CreatedById,Account__r.BillingCity,Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.ShippingStreet,Account__r.ShippingCity,Account__r.ShippingPostalCode,Account__r.ShippingCountry  FROM order__C where id=:currentRecordId];
           /* List<Account> addressLst =[select id,City__c,State__c,pincode__c,Country__c,Primary__c,Account__c from HMC_Address__c where Account__c =: quoObj.Account__C limit 1];
            if(addressLst.isempty()){
                hmcObj = new HMC_Address__c();
            }else{
                hmcObj = addressLst[0];
            }*/
            quoLineItemList=[select id,Product__c,Product__r.name,Product__r.ProductCode__c , List_Price__C,Quantity__c,TotalPrice__c,discount__c, Tax__c, Net_Amount__c,Base_Price__c ,Total_Discount__c from Order__c where order__c=:quoObj.id ];
            for(order__c item : quoLineItemList){
                total = total + item.Net_Amount__c;
                rounded = total.setScale(2);
                quantity = quantity + Integer.valueOf(item.Quantity__c);
            }
            totalQuantity = quantity;
            totalPrice = rounded; 
       /* }else{
            BuTypeOfDealer = 'hero';
            Decimal total = 0;
            Integer quantity = 0;
            Decimal rounded = 0;
            Decimal gstIncludePrice = 0;
            Decimal grandTotal = 0;
            quoObj=[SELECT LastModifiedById,Id,AccountId,Owner.Name,Account.HMC_Contact_Email__c,Account.HMC_Contact_Number__c,Account.Fax,Account.Name,Account.BillingState,Account.ShippingState,CreatedDate,CreatedById,Account.BillingCity,Account.BillingPostalCode,Account.BillingCountry,Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingCountry  FROM Opportunity where id=:currentRecordId];
            List<HMC_Address__c> addressLst =[select id,City__c,State__c,pincode__c,Country__c,Primary__c,Account__c from HMC_Address__c where Account__c =: quoObj.AccountId AND Primary__c = true limit 1];
            if(addressLst.isempty()){
                hmcObj = new HMC_Address__c();
            }else{
                hmcObj = addressLst[0];
            }
            quoLineItemList=[select id,Product2id,Product2.name,Product2.ProductCode,ListPrice,UnitPrice,Quantity,TotalPrice,discount, Tax__c,HMC_GST__c, Net_Amount__c,Base_Price__c ,Total_Discount__c from OpportunityLineItem where OpportunityId=:quoObj.id AND Reason_of_Rejection__c = null];
            for(OpportunityLineItem item : quoLineItemList){
                gstIncludePrice = item.UnitPrice + item.UnitPrice*item.HMC_GST__c/100;
                total = gstIncludePrice *  Integer.valueOf(item.Quantity);
                grandTotal = grandTotal + total;
                quantity = quantity + Integer.valueOf(item.Quantity);
            }
            totalQuantity = quantity;
            totalPrice = grandTotal.setScale(2);  
        }*/
    }
}