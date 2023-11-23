public without sharing class HandleAccount {
    public static void handleParentAccount(List<Voucher__c> vchList){
        List<String> companyNameString = new List<String>();
        for(Voucher__c vchObj : vchList){
            if(vchObj.Company_Name__c != null){
                companyNameString.add(vchObj.Company_Name__c);
            }
        }
        if(!companyNameString.isEmpty()){
            Map<String,Id> accMap = new Map<String,Id>();
            List<RecordType> dealerRecordType = [select id,DeveloperName  from RecordType  where DeveloperName = 'Dealer'];
            List<Account> accList = [select id, name from  Account where ParentId = null AND RecordType.name = 'Dealer' and Name in :companyNameString];
            List<User> userList = [Select Id from User where Profile.name = 'System Administrator'];
            Map<String,Account> accMaptoInsert = new Map<String,Account>();  
            for (Account accObj : accList){
                accMap.put(accObj.Name, accObj.id);
            }
            for(Voucher__c vch : vchList){
                if(!accMap.containsKey(vch.Company_Name__c)){
                    Account acc = new Account();
                    acc.OwnerId = '0055j00000A4WAAAA3';
                    acc.Name = vch.Company_Name__c;
                    acc.RecordTypeId = dealerRecordType[0].Id;
                    acc.HMC_Contact_Email__c = 'Test@gmail.com';
                    acc.HMC_Contact_Number__c = '7568485481';
                    accMaptoInsert.put(acc.Name, acc);
                }
            }
            if(!accMaptoInsert.isEmpty()){
                insert accMaptoInsert.values();
            }
        }
        
        
        
    }
    public Static Void handleChildAccount(List<Voucher__c> vchList){
        System.debug('Here in child 1');
        List<String> childNameString = new List<String>();
        List<String> parentNameString = new List<String>();
        for(Voucher__c vch : vchList){
            if(vch.PartyName__c != null){
                System.debug('Here in child 2');
                childNameString.add(vch.PartyName__c);
                parentNameString.add(vch.Company_Name__c);
            }
        }
        if(!childNameString.isEmpty() && !parentNameString.isEmpty()){
            System.debug('Here in child 3');
            Map<String,Account> toInsert = new Map<String,Account>();
            Map<String,Id> childMap = new Map<String,Id>();
            Map<String,Id> ParentMap = new Map<String,Id>();
            List<RecordType> retailerRecordType = [select id,DeveloperName  from RecordType  where DeveloperName = 'Retailer'];
            List<Account> childAccounts = [Select id,Name from Account where name in:childNameString AND RecordType.name = 'Retailer'];
            List<Account> parentAccounts = [Select id,Name from Account where name in:parentNameString];
            for (Account accObjP : parentAccounts){
                ParentMap.put(accObjP.Name,accObjP.Id);
            }
            for (Account accObjCh : childAccounts){
                childMap.put(accObjCh.Name, accObjCh.id);
            }
            for (Voucher__c vchObj : vchList){
                if(!childMap.containsKey(vchObj.PartyName__c)){
                    System.debug('Here in child 4');
                    Account accObj = new Account();
                    accObj.Name = vchObj.PartyName__c;
                    accObj.OwnerId = '0055j00000A4WAAAA3';
                    accObj.RecordTypeId = retailerRecordType[0].id;
                    accObj.ParentId = ParentMap.get(vchObj.Company_Name__c);
                    accObj.Related_Account__c = ParentMap.get(vchObj.Company_Name__c);
                    toInsert.put(accObj.Name,accObj);
                }
            }
            if(!toInsert.isEmpty()){
                insert toInsert.values();
            }
        }
    }
    
    
}