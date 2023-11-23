public class HistoryTrackerController {
    //Ravi Jangid - Code here
    //For - History Tracker Records

    @AuraEnabled(cacheable=true)
    public static Map<Id, History_Tracker__c> fetchData(String recordId) {
        System.debug('recordId : '+ recordId);
        Map<Id, History_Tracker__c> mapOfHT = new Map<Id, History_Tracker__c>();
		System.debug('mapofht'+mapOfHT);
        List<History_Tracker__c> historyLst1 = [
                    SELECT Id, Document_Name__c, Document_Template__c, Status__c, Name__c, Step__c, Object_Record_Name__c, Object_Record_Id__c, History_Tracker_Id__c, Content_Version__c, Object_Name__c, Object_Record_Ids__c 
                    FROM History_Tracker__c WHERE CreatedDate = LAST_N_DAYS:365 And Document_Template__c != Null ORDER BY CreatedDate DESC LIMIT 200];    
        
        System.debug('historyLst1' +historyLst1);
        
        if (!historyLst1.isEmpty()) {
            System.debug('not empty ');
            for (History_Tracker__c history : historyLst1) {
                String objRecIds = history.Object_Record_Ids__c;
                if (objRecIds != null && objRecIds.containsIgnoreCase(recordId)) {
                    mapOfHT.put(history.id, history);
                }
            }
            System.debug('mapOfHT '+ mapOfHT);
            return mapOfHT;
        }
        return null;
    }
}