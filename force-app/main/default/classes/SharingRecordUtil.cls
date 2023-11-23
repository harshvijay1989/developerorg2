public class SharingRecordUtil {
    public static void shareRecordPriceList(Set<Id> recordIds,Id sharedWith){
        if(!recordIds.isEmpty()){
            List<Price_List__Share> jobShrs = new List<Price_List__Share>();
            Price_List__Share recruiterShr;
            
            for(Id item:recordIds){
                // Instantiate the sharing objects
                recruiterShr = new Price_List__Share();
                
                // Set the ID of record being shared
                recruiterShr.ParentId = item;
                
                // Set the ID of user or group being granted access
                recruiterShr.UserOrGroupId = sharedWith;
                
                // Set the access level
                recruiterShr.AccessLevel = 'edit';
                
                // Set the Apex sharing reason for hiring manager and recruiter
                //recruiterShr.RowCause = Schema.Job__Share.RowCause.Recruiter__c;
                
                // Add objects to list for insert
                jobShrs.add(recruiterShr);
            }
            
            if(!jobShrs.isEmpty()){
                Database.SaveResult[] lsr = Database.insert(jobShrs,false);
            }
        }
    }
    
    
}