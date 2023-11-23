public class AccountTriggerHandler2 {
    public static Boolean isRun = true;
    public static void beforeUpdateAccount(List<Account> newList, Map<Id, Account> oldMap) {
        isRun = false;
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        List<Account> updateAccountList = new List<Account>();
        for (Account item : newList) {
            if ((item.Path_Status__c != oldMap.get(item.Id).Path_Status__c) && (oldMap.get(item.Id).Path_Status__c == 'Qualified' && item.Path_Status__c == 'Dealer Onboarded') && item.HMC_Dealer_Code__c != NULL) {
                Account accObj = new Account();
                accObj.Id = item.Id;
                accObj.Status__c = 'Onboarded';
                updateAccountList.add(accObj);
            }
        }
        if(updateAccountList!=null){
            update updateAccountList;
        }
    }
}