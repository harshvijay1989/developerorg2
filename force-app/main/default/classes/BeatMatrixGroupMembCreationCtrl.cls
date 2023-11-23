public without sharing class BeatMatrixGroupMembCreationCtrl {
    @AuraEnabled(cacheable=true)
    public static beatGPMWrapper gpmemberCreation(String recordId){
        beatGPMWrapper objBeatGPMWrapper = new beatGPMWrapper();
        objBeatGPMWrapper.beatGroupMemRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByDeveloperName().get('Group_Member').getRecordTypeId();
        if(String.isNotBlank(recordId)){
            objBeatGPMWrapper.beatGroupRecord = [Select Id,Dealer__c,Beat_Group__c from Beat_Matrix__c Where Id =: recordId];
            return objBeatGPMWrapper;
        } 
        return objBeatGPMWrapper;
    }
    @AuraEnabled
    public static void saveGroupmemberRecord(List<Beat_Matrix__c>  beatGroupMembLst){
        System.debug('beatGroupMembLst--->'+beatGroupMembLst);
        if(!beatGroupMembLst.isEmpty()){
            insert beatGroupMembLst;
        }
    }
    @AuraEnabled
    public static Account fetchDealer(String  delearId){
        if(String.isNotBlank(delearId)){
            List<Account> dealerLst = [Select Id, Name From Account Where Id =: delearId ];
            System.debug('delaerList'+dealerLst);
            return dealerLst[0] ;
        }
        return new Account();
    }

    public class beatGPMWrapper{
        @AuraEnabled
        public Beat_Matrix__c beatGroupRecord{get;set;} 
        @AuraEnabled
        public String beatGroupMemRecordTypeId{get;set;}
        
        public beatGPMWrapper(){
            beatGroupRecord = new Beat_Matrix__c();
            beatGroupMemRecordTypeId = '';
        }
    }
}