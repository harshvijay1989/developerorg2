public class BeatMatrixTriggerHandler {
    public static Id groupRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group').getRecordTypeId();
    public static Id groupMemberRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group Member').getRecordTypeId();

    public static void beatGroup(List<Beat_Matrix__c> btLst,Map<id,Beat_Matrix__c> btgOldmap){
        Set<id> btId = new Set<id>();
        for(Beat_Matrix__c cc : btLst) {
            if(cc.Dealer__c != null || (cc.Dealer__c != null && cc.Dealer__c != btgOldmap.get(cc.Id).Dealer__c)) {
                btId.add(cc.Dealer__c); 
                System.debug('cc.Dealer__c'+cc.Dealer__c);
            }
        }
        Map<Id,Account> mapAccount = new Map<Id,Account> ([SELECT Id,(SELECT Id FROM Beat_Matrix__r WHERE RecordTypeId=:groupMemberRecordTypeId) FROM Account WHERE Id IN : btId]);
        for(Beat_Matrix__c Hmcbtg: btLst) {	
            if( Hmcbtg.Dealer__c != null && mapAccount.containsKey(Hmcbtg.Dealer__c)) {
                Account acc = mapAccount.get(Hmcbtg.Dealer__c);
                System.debug('acc.Beat_Matrix__r.size()'+acc.Beat_Matrix__r.size());
                if(acc.Beat_Matrix__r.size() > 1) {
                    Hmcbtg.addError('One dealer can not be part of multiple beat group members.'); 
                }
            }
        }
    }
}