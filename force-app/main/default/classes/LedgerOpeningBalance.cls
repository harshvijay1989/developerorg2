public class LedgerOpeningBalance {
    
    public Static Decimal currentUserOpeningBalance(){
        User us = [SELECT Id, name,AccountId,Account.HMC_Dealer_Code__c from user Where Id =: UserInfo.getUserId()];
        List<Account> accListCurrentUser = [SELECT id,Name,HMC_Dealer_Code__c,Opening_Balance__c FROM Account WHERE Id =: us.AccountId];
        Decimal openingBalance ;
        List<Account> accList = new List<Account>();
        if(us.Account.HMC_Dealer_Code__c != null){
             accList = [SELECT id,Name,HMC_Dealer_Code__c,Opening_Balance__c FROM Account where HMC_Dealer_Code__c =: us.Account.HMC_Dealer_Code__c];
            System.debug('accList ===> '+accList);
            openingBalance = accList[0].Opening_Balance__c;
            
            System.debug('openingBalance===> '+openingBalance);
        }
        return openingBalance;
    }
}