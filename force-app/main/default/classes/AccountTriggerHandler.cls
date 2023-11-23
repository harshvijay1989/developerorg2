public class AccountTriggerHandler {
    public static Boolean isRun = true;
    public static void beforeUpdateAccount(List<Account> newList, Map<Id, Account> oldMap) {
        isRun = false;
        List<Account> updateAccountList = new List<Account>();
        for (Account item : newList) {
            if (item.Status__c != oldMap.get(item.Id).Status__c && oldMap.get(item.Id).Status__c != 'Approved' && item.Status__c == 'Approved') {
                Account accObj = new Account();
                accObj.Id = item.Id;
                accObj.Status__c = 'Onboarded';
                System.debug('item.Status__c => ' + item.Status__c);
                updateAccountList.add(accObj);
            }
        }
        if(updateAccountList!=null){
            update updateAccountList;
        }
    }
}