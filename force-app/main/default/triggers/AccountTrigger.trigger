trigger AccountTrigger on Account (After update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(AccountTriggerHandler2.isRun){
         	AccountTriggerHandler2.beforeUpdateAccount(Trigger.new, Trigger.oldMap);   
        }
    }
}