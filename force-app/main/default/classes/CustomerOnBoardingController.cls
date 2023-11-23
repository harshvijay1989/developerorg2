public with sharing class CustomerOnBoardingController {
    
    @AuraEnabled
    public static String createAccount(String data1) {
        
        Map<String, Object> untypedData = (Map<String, Object>) JSON.deserializeUntyped(data1);
        Account acc= new Account();
       
        return acc.Name;
        
    }
    
    @AuraEnabled
    public static String getAccount() {
       /* system.debug('in getaccount');
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId LIMIT 1];
        Contact userContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];
        String accid = userContact.AccountId;
        system.debug(accid);
        Account acc=[select Id,Name from Account where id=:accid limit 1];//Allocated_Credit_Limit__c,Consumed_Credit_Limit__c,Remaining_Credit_Limit__c
        */return null;//JSON.serialize(acc);        
    }
    
    
}