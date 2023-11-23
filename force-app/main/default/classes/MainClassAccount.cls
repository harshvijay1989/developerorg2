public without Sharing class  MainClassAccount {
    @AuraEnabled
    public static String createAccount(String data1) {
        
        Map<String, Object> untypedData = (Map<String, Object>) JSON.deserializeUntyped(data1);
        Account acc= new Account();
        acc.Name = (String) (String) untypedData.get('Shop Name');
        acc.Phone = (String) untypedData.get('Phone');
        acc.HMC_Contact_Number__c = (String) untypedData.get('Phone');
        acc.HMC_Contact_Email__c = (String) untypedData.get('Email');
        acc.BillingStreet = (String) untypedData.get('Billing Street');
        acc.BillingCity = (String) untypedData.get('Billing City');
        acc.BillingCountry = (String) untypedData.get('Billing Country');
        acc.BillingState = (String) untypedData.get('Billing Province'); 
        acc.BillingPostalCode = (String) untypedData.get('Billing Postal Code');
        acc.ShippingStreet = (String) untypedData.get('Shipping Street');
        acc.ShippingCity = (String) untypedData.get('Shipping City');
        acc.ShippingCountry = (String) untypedData.get('Shipping Country');
        acc.ShippingState = (String) untypedData.get('Shipping Province'); 
        acc.ShippingPostalCode = (String) untypedData.get('Shipping Postal Code');
        acc.Select_Region__c = (String) untypedData.get('Region');
        acc.Status__c = 'Document Upload';
        acc.Allocated_Credit_Limit__c=1000000.00;
        acc.Remaining_Credit_Limit__c=1000000.00;
        acc.Consumed_Credit_Limit__c=0.00;
        acc.Application_Id__c = 'APP-'+generateRandomString(12);
        if(acc!=null){
            //   try{
            User u = [SELECT Id,username FROM user WHERE username = 'anirudh.sharma@crmlanding.in.dev2' LIMIT 1];
            acc.OwnerId = u.Id;
            insert acc;
            CustomNotificationType TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Dealer_Onboarding' LIMIT 1];
            //User u = [SELECT Id,username FROM user WHERE username = 'anirudh.sharma@crmlanding.in.dev2' LIMIT 1];
            UtilityCls.notify('Customer is created - '+acc.Name,'Customer is created - '+acc.Name,TemplateInfoDetail.Id,u.Id,acc.Id);            
            // }catch(Exception e){
            //    system.debug(e);       
            //  }
        }
        return JSON.serialize(acc);
        
    }
    
    @AuraEnabled
    public static String getAccount() {
        system.debug('in getaccount');
        Id currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId LIMIT 1];
        Contact userContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];
        String accid = userContact.AccountId;
        system.debug(accid);
        Account acc=[select Id,Name,Allocated_Credit_Limit__c,Consumed_Credit_Limit__c,Remaining_Credit_Limit__c from Account where id=:accid limit 1];
        return JSON.serialize(acc);
    }
    
    private static String generateRandomString(Integer length) {
        String validChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randomString = '';
        
        for (Integer i = 0; i < length; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), validChars.length());
            randomString += validChars.substring(randomIndex, randomIndex + 1);
        }
        
        return randomString;
    }
    
}