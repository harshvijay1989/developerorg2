public class ShowDealerLocationCtr {

   
       @AuraEnabled(cacheable=true)
    public static List<Route_Plan__c> getTodayVisitedDealersOnDayEnd() {

        Date systemToday = System.today();
        DateTime dateTimeToday = DateTime.newInstance(systemToday, Time.newInstance(0, 0, 0, 0));
        Date dateToday = dateTimeToday.dateGMT();
        Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        List<Route_Plan__c> HMCRoutePlaneList = [SELECT Id,Visit_Date__c, Dealer_Name__r.Name, CreatedById, Dealer_Name__r.BillingAddress,Dealer_Name__r.BillingStreet,Dealer_Name__r.BillingCity,Dealer_Name__r.BillingPostalCode,Dealer_Name__r.BillingState,Dealer_Name__r.BillingCountry FROM Route_Plan__c WHERE Visit_Date__c = :systemToday AND CreatedById = :UserInfo.getUserId() AND  RecordTypeId=: activityRecordTypeId AND CheckInDateTime__c !=Null];

        return HMCRoutePlaneList;
    }
}