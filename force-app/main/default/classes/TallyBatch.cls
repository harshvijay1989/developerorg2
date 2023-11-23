public without sharing class  TallyBatch implements Database.Batchable <SObject>,schedulable {
    public String recordIds;
    public TallyBatch(Id RecordId){
        recordIds = RecordId; 
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query= 'Select Id,Amount__c,VoucherNumber__c,PartyName__c,VoucherType__c,Quantity__c,Company_Name__c,Gu_Id__c from Voucher__c where Process__c = \'Unprocessed\'';
        return Database.getQueryLocator(Query);
    }
    //EXECUTE METHOD
    public void execute(Database.BatchableContext bc, List<Voucher__c> scopeList){
       // HandleAccount.handleParentAccount(scopeList);
        HandleAccount.handleChildAccount(scopeList);
        handleOrder.handleOrderchange(scopeList);
        for (Voucher__c vchObj : scopeList){
            vchObj.Process__c = 'Processed';
        }
        update scopeList;
        
        
    }
    //FINISH METHOD 
    public void finish(Database.BatchableContext bc){
        
    }
    public void execute(SchedulableContext sc){
    }
    
}