public class OrderController {
    @AuraEnabled
    public static Id createOrder(String accountId,String schemeId) {
        String orderRecordType = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Order').getRecordTypeId();
        Order__c newOrder = new Order__c();
        newOrder.RecordTypeId = orderRecordType;
        newOrder.Account__c = accountId;
        newOrder.Scheme__c = schemeId;
        insert newOrder;
        return newOrder.Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static Account getContactAccountName() {
        user u = [SELECT Id,Contact.AccountId FROM user where id=:UserInfo.getUserId()];
        Account acc=[SELECT Id,Name,BillingStreet, 
                     BillingCity, 
                     BillingState, 
                     BillingPostalCode, 
                     BillingCountry, 
                     ShippingStreet, 
                     ShippingCity, 
                     ShippingState, 
                     ShippingPostalCode, 
                     ShippingCountry from Account where id =:u.Contact.AccountId];
        return acc;
    }
    
}