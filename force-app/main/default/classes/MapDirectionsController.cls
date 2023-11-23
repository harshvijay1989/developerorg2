public class MapDirectionsController {
@AuraEnabled(cacheable=true)
    public static List<Account> getTodayCreatedAccounts() {
        Set<Id> PlanDealerId = new Set<Id>();
        Id activityRecordType = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        List<Route_Plan__c> dealerLst = [SELECT Dealer_Name__c,Dealer_Name__r.Name , Dealer_Name__r.ID FROM Route_Plan__c WHERE RecordType.Name = 'Activity' AND Visit_Date__c = TODAY AND ASM__c = :UserInfo.getUserId()];
        for(Route_Plan__c rr : dealerLst){
            if(rr.Dealer_Name__c != null){
                PlanDealerId.add(rr.Dealer_Name__r.ID);
            }
        }
        List<Account> accounts = [SELECT Id, Name, BillingLatitude, BillingLongitude, BillingStreet, BillingCity, BillingState, BillingPostalCode
                                   FROM Account where Id =: PlanDealerId ];
        return accounts;
    }
}