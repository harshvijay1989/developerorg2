public class  FullCalendarService2 {
    
    public static Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
    public static Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
    public static Id expenseRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
    public static Id groupRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group').getRecordTypeId();
    public static Id groupMemberRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group Member').getRecordTypeId();
    public static Id planmatrixRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Beat Plan Matrix').getRecordTypeId();
        
    @AuraEnabled
    public static List<Event> fetchAllEvents(){
        List<Event> eventList = new List<Event>();
        eventList = [Select Id, Subject, WhatId, WhoId, 
                     Description, EndDate, EndDateTime, OwnerId,
                     ActivityDate, ActivityDateTime From Event LIMIT 100];
        return eventList;
    } 
    @AuraEnabled()
    public static List< Route_Plan__c> getEventData(String routPlaneId){
        return [SELECT Id,CheckInDateTime__c,CheckInLocation__c,CheckOutDateTime__c,CheckInLocation__longitude__s,
                CheckInLocation__latitude__s,CheckOutLocation__c,CheckOutLocation__longitude__s,
                CheckOutLocation__latitude__s FROM  Route_Plan__c where  RecordTypeId=:activityRecordTypeId
                AND Route_Plan__c =:routPlaneId];
    }
    
    @AuraEnabled public final Boolean isCheckIn=false;
    @AuraEnabled()
    public static String checkIn(String routPlaneId, Double lat, Double lng) {
        List<Route_Plan__c> checkInList = new List<Route_Plan__c>(); //activity list
        
        for (Route_Plan__c routobj : [SELECT Id, CheckInDateTime__c, CheckInLocation__c, CheckInLocation__longitude__s
                                      , CheckInLocation__latitude__s FROM Route_Plan__c WHERE RecordTypeId=:activityRecordTypeId
                                      AND Route_Plan__c = :routPlaneId]) {
            System.debug('I am in check in ' + routobj);
            if (routobj.CheckInLocation__longitude__s == null && routobj.CheckInLocation__latitude__s == null) {
                System.debug('Enter');
                Route_Plan__c hmcRoutObj = new Route_Plan__c();
                System.debug('1111111111' + routobj.CheckInDateTime__c);
                System.debug('2222222222' + lat);
                System.debug('33333333' + lng);
                if (routobj.CheckInDateTime__c == null && lat != null && lng != null) {
                    hmcRoutObj.CheckInDateTime__c = System.now();
                    hmcRoutObj.Id = routobj.Id;
                    hmcRoutObj.CheckInLocation__longitude__s = lng;
                    hmcRoutObj.CheckInLocation__latitude__s = lat;
                    checkInList.add(hmcRoutObj);
                }
            }
        }
        
        if (!checkInList.isEmpty()) {
            System.debug(checkInList);
            System.debug('I am in update');
            update checkInList;
            return 'checkInDone';
        } else {
            System.debug('I am in not done');
            return 'checkInNotDone';
        }
    }
    
    @AuraEnabled()
    public static String checkOut(String routPlaneId,Double lat,Double lng){
        System.debug('delrId checkout-----'+routPlaneId);
        System.debug('delrId lat-----'+lat);
        System.debug('delrId lng-----'+lng);
        
        List< Route_Plan__c> checkOutList= new List< Route_Plan__c>();
        
        for( Route_Plan__c routobj : [SELECT Id,CheckOutDateTime__c,CheckOutLocation__C,CheckOutLocation__longitude__s,
                                      CheckOutLocation__latitude__s FROM  Route_Plan__c where RecordTypeId=:activityRecordTypeId
                                      AND Route_Plan__c =:routPlaneId]){
            if(routObj.CheckOutLocation__c==null){
                Route_Plan__c hmcRoutObj=new  Route_Plan__c();        
                if(routobj.CheckOutDateTime__c==null && lat!=null && lng!=null){          
                    hmcRoutObj.CheckOutDateTime__c=System.now(); 
                    hmcRoutObj.ID=routobj.ID;
                    hmcRoutObj.CheckOutLocation__longitude__s=lng;
                    hmcRoutObj.CheckOutLocation__latitude__s=lat;
                    checkOutList.add(hmcRoutObj);
                }
                
                System.debug('checkInObj----'+checkOutList);
            }
            
        }
        if(!checkOutList.isEmpty()){
            System.debug('I am in update');
            update checkOutList;  
            return 'checkOutDone';   
        }
        else{
            System.debug('i am in else');
            return 'checkOutNotDone';   
        }
    }
    
    
    public class EventException extends Exception {}
    /**
* @description: To retrieve the files
*/
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
    /**
* @description: To retrieve the most recent events
*/
    @AuraEnabled
    public static List< Route_Plan__c> fetchEvents(String recordId) {
        return [SELECT Id, Name,  Status__c,  Visit_Date__c,  Dealer_Name__r.BillingCity, Dealer_Name__r.BillingStreet,
                Route_Plan__c,  Dealer_Name__r.Name,  Dealer_Name__c,  Beat_Group__c,  Comments__c FROM 
                Route_Plan__c where RecordTypeId=:activityRecordTypeId AND Route_Plan__c =:recordId  ORDER BY CreatedDate DESC LIMIT 100];
    }
    @AuraEnabled
    public static String createNewEvent(Date visitdate, String delear,String Name,String routePlane){
        System.debug('Visit Date'+visitdate);
        System.debug('Delear '+delear);
        System.debug('Name '+Name);
        System.debug('routePlane '+routePlane);
        List< Route_Plan__c> hmcRoutList = new List< Route_Plan__c>(); //activity
        Route_Plan__c hmcRoutObj = new  Route_Plan__c(); //activity
        hmcRoutObj.RecordTypeId = activityRecordTypeId;
        hmcRoutObj.Visit_Date__c = visitdate;
        hmcRoutObj.Dealer_Name__c = delear;
        //hmcRoutObj.Name=Name;
        hmcRoutObj.Route_Plan__c=routePlane;
        hmcRoutList.add(hmcRoutObj);
        
        if(!hmcRoutList.isEmpty()){
            System.debug('I am in insert');
            insert hmcRoutList;   
            System.debug('I am in insert done');  
            return 'Done';         
        }else{
            return 'NotDone';
        }       
        
    }
    /**
* @description To create an event from web component 
* @param event - json string with event details - title, start and end for now
*/
    /*    @AuraEnabled
public static Id createEvent(String event){

//The following logic to be replaced with your respective event object
if(String.isBlank(event)){
return null;
}
Map<String, Object> eventMap = (Map<String, Object>) JSON.deserializeUntyped(event);

Event newEvent = new Event();
newEvent.Subject = eventMap.get('title') != null ? (String)eventMap.get('title') : null;

String startdate = eventMap.get('start') != null ? 
((String)eventMap.get('start')).replace('T', ' ').replace('.000Z', '') : 
null;
String endDate = eventMap.get('end') != null ? 
((String)eventMap.get('end')).replace('T', ' ').replace('.000Z', '') : 
null;

newEvent.StartDateTime = startdate != null ? Datetime.valueOfGmt(startdate) : null;
newEvent.EndDateTime = endDate != null ? Datetime.valueOfGmt(endDate) : null;
// newEvent.IsAllDayEvent = eventMap.get('start') != null ? eventMap.get('start') : null;
insert newEvent;

return newEvent.Id;

}*/
    
    /**
* @description To delete an event from web component 
* @param eventid - event id to delete from the component
*/
    @AuraEnabled
    public static void deleteEvent(Id eventid) {
        
        if(eventid != null){
            delete [SELECT Id FROM Event Where Id=:eventid];
        }else{
            throw new EventException('Event id is not passed');
        }
        
    }
    /*
* @method uploadFile() 
* @desc Creates a content version from a given file's base64 and name
* 
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentVersion} - returns the created ContentDocumentLink Id if the
*   upload was successful, otherwise returns null
*/
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId,Integer amount) {
        System.debug('Amount-----'+amount);
        if(amount!=null && recordId!=null){
            System.debug('I am in amount');
            Route_Plan__c hmcRoutObj = new  Route_Plan__c(); //activity
            hmcRoutObj.RecordTypeId = activityRecordTypeId;
            hmcRoutObj.Amount__c=  amount;
            hmcRoutObj.Id = recordId;
            update hmcRoutObj;
            System.debug('I am in last');
        }
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    /*
* @method createContentVersion() [private]
* @desc Creates a content version from a given file's base64 and name
* 
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* 
* @return {ContentVersion} - returns the newly created ContentVersion, or null
*   if there was an error inserting the record
*/
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /*
* @method createContentLink() [private]
* @desc Creates a content link for a given ContentVersion and record
* 
* @param {String} contentVersionId - Id of the ContentVersion of the file
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
*   or null if there was an error inserting the record
*/
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    @AuraEnabled()
    public static String deleteRouteplan(String routPlaneId){
        String returnval = '';
        try{
            List< Route_Plan__c> act = [SELECT Id from  Route_Plan__c where RecordTypeId=:activityRecordTypeId
                                        AND Route_Plan__c =: routPlaneId];
            Delete act;
            returnval = 'Success';
        }catch(Exception oEx){
            returnval = 'Error';
        }
        return returnval;
    }
    
}