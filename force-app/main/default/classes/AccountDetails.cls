public class AccountDetails {
    @AuraEnabled
    public static String getCurrentAccount(){
        User u = [SELECT id,Contact.AccountId FROM user WHERE Id = :UserInfo.getUserId()];
        return JSON.serialize(u);
    }
    
	@AuraEnabled
    public static String getAccount(){
        User u = [SELECT id,Contact.AccountId FROM user WHERE Id = :UserInfo.getUserId()];
        Account acc = [SELECT Id,Name,BillingStreet,BillingCity,BillingState, BillingPostalCode, BillingCountry,ShippingStreet,ShippingCity,ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE Id = :u.Contact.AccountId];
        return JSON.serialize(acc);
    }
}