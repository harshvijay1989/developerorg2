public class ProfileController {
    
    @AuraEnabled(cacheable=true)
    public static List<Profile> getAllProfiles() {
        return [SELECT Id, Name FROM Profile];
    }
   /* @AuraEnabled
    public static void saveProfilesData(String profilesData) {
        System.debug('helo profile');
        custome_Profile__c proData = new custome_Profile__c();
        proData.Permission_Name__c=profilesData;
        
        insert proData;
        System.debug('submited are : '+proData);
    }*/

}