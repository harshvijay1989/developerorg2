public with sharing class lead_AccountSearchController {
    @AuraEnabled
    public static List<Account> searchAccounts( String searchTerm , String leadRecordId) {
        system.debug('@@leadRecordId'+leadRecordId);
        List<Account> accounts = new List<Account>();  
        if ( String.isNotBlank( searchTerm )    && searchTerm.length() > 1 ) {
            accounts = [SELECT Id, Name, Phone, ShippingAddress, Website, BillingStreet, BillingCity,BillingState, BillingPostalCode 
                        FROM Account WHERE  (BillingPostalCode =:searchTerm OR BillingCity=:searchTerm OR BillingState=:searchTerm) ORDER BY Name  LIMIT 100];
        }
        system.debug('@@'+accounts);
        return accounts;
    }
}