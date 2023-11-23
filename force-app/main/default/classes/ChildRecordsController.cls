public class ChildRecordsController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getRelatedAccounts(Id recordId) {
        system.debug('recordId==>'+recordId);
        return [SELECT Id, Name FROM Account WHERE ParentId = :recordId];
    }
   @AuraEnabled(cacheable=true)
    public static String getAccountDetailUrl(Id AccountId) {
        system.debug('AccountId'+AccountId);
        String accountDetailUrl = '/' + AccountId;
        return accountDetailUrl;
    }
}