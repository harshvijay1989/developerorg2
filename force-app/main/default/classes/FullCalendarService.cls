public class FullCalendarService {
    
    public static Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
    public static Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
    public static Id expenseRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
    public static Id groupRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group').getRecordTypeId();
    public static Id groupMemberRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group Member').getRecordTypeId();
    
    @AuraEnabled
    public static List<Event> fetchAllEvents(){
        List<Event> eventList = new List<Event>();
        eventList = [Select Id, Subject, WhatId, WhoId, 
                     Description, EndDate, EndDateTime, OwnerId,
                     ActivityDate, ActivityDateTime From Event LIMIT 100];
        return eventList;
    } 
    @AuraEnabled
    public static String checkList(String q1, String q2, String q3,String routPlanActId){
        system.debug('checkList called');
        system.debug('Question1__c'+q1);
        system.debug('Question2__c'+q2);
        system.debug('Question3__c'+q3);
        system.debug('routPlanActId'+routPlanActId);
        
        List<String> delerId=new List<String>();        
        List<Route_Plan__c> routActObj = [SELECT Id, Dealer_Name__c FROM Route_Plan__c where RecordTypeId=:activityRecordTypeId AND Id=:routPlanActId];
        system.debug('routActObj'+routActObj);
        delerId.add(routActObj[0].Dealer_Name__c);         
        List<Route_Plan__c> checkListList=new List<Route_Plan__c>(); 
        
        Route_Plan__c checkListObj=new Route_Plan__c();
        checkListObj.Id=routActObj[0].Id;
        checkListObj.RecordTypeId = activityRecordTypeId;
        checkListObj.Question1__c=q1;
        checkListObj.Question2__c=q2;
        checkListObj.Question3__c=q3;      
        checkListList.add(checkListObj);
        
        if(!checkListList.isEmpty()){
            update checkListList;
            return 'checkListDone';
        }
        else{
            return 'checkListNotDone';
        }
        
    }
    
    /**
* @description: To retrieve the files
*/
    @AuraEnabled()
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs      
        System.debug('recordId'+recordId); 
        System.debug('I am in file get');
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
    
    @AuraEnabled()
    public static List<Order__c> getManageExpenses(String rootID){
        System.debug('rootID'+rootID);
        List<Order__c> routeExpenseDetailList=new List<Order__c>();
        Integer month = Date.Today().Month();
        Integer year = Date.Today().Year();
        routeExpenseDetailList=[SELECT Id, Name, Visit_Date__c,Amount__c,Comment__c,Route_Plan__c FROM
                                Order__c WHERE
                                RecordTypeId=:expenseRecordTypeId AND 
                                CALENDAR_MONTH(Visit_Date__c) = :month AND
                                CALENDAR_YEAR(Visit_Date__c) = :year AND 
                                Route_Plan__c=: rootID order by Visit_Date__c ASC];
        System.debug('routeExpenseDetailList'+routeExpenseDetailList);
        return routeExpenseDetailList; 
    }
    
    @AuraEnabled()
    public static String updateManageExpenses( List<Order__c> toupdate){
        System.debug('toupdate'+toupdate);
        if(toupdate!=null){
            update toupdate;  
            return 'toupdateDone';
        }else {
            return 'toupdateNotDone';
        }                   
    }
    
    @AuraEnabled()
    public static List<GetEvtData> getEventData(String routPlaneId){
        System.debug('routPlaneId'+routPlaneId);
        List<Route_Plan__c> routPlanActList=new List<Route_Plan__c>();//activity
        routPlanActList=[SELECT Id,Name,Question1__c, Question2__c, Question3__c,Dealer_Name__c,CheckInDateTime__c,
                         CheckInLocation__C,CheckOutDateTime__c,Dealer_Name__r.Name,Visit_Date__c,
                         Dealer_Name__r.BillingStreet,Dealer_Name__r.BillingCity,Amount__c,
                         CheckInLocation__longitude__s,CheckInLocation__latitude__s,CheckOutLocation__C,
                         CheckOutLocation__longitude__s,CheckOutLocation__latitude__s FROM
                         Route_Plan__c WHERE RecordTypeId=:activityRecordTypeId AND id =:routPlaneId];
        
        List<GetEvtData> getEventDataList=new List<GetEvtData>();
        GetEvtData getEvtObj=new GetEvtData();
        getEvtObj.rotPlanActList=routPlanActList;
        getEventDataList.add(getEvtObj);
        return getEventDataList;   
    }
    public class GetEvtData{       
        @AuraEnabled
        public List<Route_Plan__c> rotPlanActList;
    }
    
    @AuraEnabled public final Boolean isCheckIn=false;
    @AuraEnabled()
    public static String checkInDMSOLD(String routPlaneId, Double lat,Double lng){
        System.debug('delrId-----'+routPlaneId);
        System.debug('lat-----'+lat);
        System.debug('lng-----'+lng);
        List<Route_Plan__c> checkInList= new List<Route_Plan__c>();
        Set<Id> delerId=new Set<Id>();
        for(Route_Plan__c routobj : [SELECT Dealer_Name__r.BillingLatitude,Dealer_Name__r.BillingLongitude, CheckInLocation__Latitude__s, Id, CheckInDateTime__c, CheckInLocation__Longitude__s, CheckInLocation__c FROM Route_Plan__c where  RecordTypeId=:activityRecordTypeId AND id =:routPlaneId]){
            
            if(routObj.CheckInLocation__c==null){
                Route_Plan__c hmcRoutObj=new Route_Plan__c();        
                if(routobj.CheckInDateTime__c==null && lat!=null && lng!=null){ 
                    Location loc1 = Location.newInstance(routobj.Dealer_Name__r.BillingLatitude,routobj.Dealer_Name__r.BillingLongitude);
                    Location loc2 = Location.newInstance(lat,lng);
                    Double dist = Location.getDistance(loc1, loc2, 'mi');
                    System.debug('dist'+dist);
                    hmcRoutObj.CheckInDateTime__c=System.now(); 
                    hmcRoutObj.ID=routobj.ID;
                    hmcRoutObj.CheckInLocation__Longitude__s=lng;
                    hmcRoutObj.CheckInLocation__Latitude__s=lat;
                    hmcRoutObj.LocationDistance__c=dist;
                    checkInList.add(hmcRoutObj);
                }
                System.debug('checkInObj----'+checkInList);
            }     
        }
        
        if(!checkInList.isEmpty()){
            System.debug(checkInList);
            System.debug('I am in update');
            update checkInList;  
            return 'checkInDone';   
        }
        else{
            System.debug('I am in not done');
            return 'checkInNotDone';  
            
        }
    }
    @AuraEnabled()
    public static String checkIn(String routPlaneId, Double lat,Double lng){
        System.debug('delrId-----'+routPlaneId);
        System.debug('lat-----'+lat);
        System.debug('lng-----'+lng);
        List<Route_Plan__c> checkInList= new List<Route_Plan__c>();
        Set<Id> delerId=new Set<Id>();
        for(Route_Plan__c routobj : [SELECT Dealer_Name__r.BillingLatitude,Dealer_Name__r.BillingLongitude,
                                     CheckInLocation__Latitude__s, Id, CheckInDateTime__c,
                                     CheckInLocation__Longitude__s, CheckInLocation__c FROM 
                                     Route_Plan__c where RecordTypeId=:activityRecordTypeId AND id =:routPlaneId]){
                                         
                                         if(routObj.CheckInLocation__c==null){
                                             if(routobj.CheckInDateTime__c==null && lat!=null && lng!=null){ 
                                                 Location loc1 = Location.newInstance(routobj.Dealer_Name__r.BillingLatitude,routobj.Dealer_Name__r.BillingLongitude);
                                                 System.debug('loc1'+loc1);
                                                 Location loc2 = Location.newInstance(lat,lng);
                                                 System.debug('loc2'+loc2);
                                                 Double dist = Location.getDistance(loc1, loc2, 'mi');
                                                 System.debug('dist'+dist);
                                                 Integer DistanceValidate = Integer.valueOf(System.label.Distance_Validate);
                                                 if(routobj.Dealer_Name__c !=Null){
                                                     if(dist < DistanceValidate){
                                                         Route_Plan__c hmcRoutObj=new Route_Plan__c(); //activity give recordtype       
                                                         hmcRoutObj.RecordTypeId=activityRecordTypeId;
                                                         hmcRoutObj.CheckInDateTime__c=System.now(); 
                                                         hmcRoutObj.ID=routobj.ID;
                                                         hmcRoutObj.CheckInLocation__Longitude__s=lng;
                                                         hmcRoutObj.CheckInLocation__Latitude__s=lat;
                                                         hmcRoutObj.LocationDistance__c=dist;
                                                         checkInList.add(hmcRoutObj);
                                                     }else{
                                                         return 'DisWarning';
                                                     } 
                                                 }else{
                                                     Route_Plan__c hmcRoutObj=new Route_Plan__c();  //activity give recordtype       
                                                     hmcRoutObj.RecordTypeId=activityRecordTypeId;
                                                     hmcRoutObj.CheckInDateTime__c=System.now(); 
                                                     hmcRoutObj.ID=routobj.ID;
                                                     hmcRoutObj.CheckInLocation__Longitude__s=lng;
                                                     hmcRoutObj.CheckInLocation__Latitude__s=lat;
                                                     hmcRoutObj.LocationDistance__c=dist;
                                                     checkInList.add(hmcRoutObj); 
                                                 }
                                                 
                                             }
                                             
                                             System.debug('checkInObj----'+checkInList);
                                         }     
                                     }
        
        if(!checkInList.isEmpty()){
            System.debug(checkInList);
            System.debug('I am in update');
            update checkInList;  
            return 'checkInDone';   
        }
        else{
            System.debug('I am in not done');
            return 'checkInNotDone';  
            
        }
    }
    
    @AuraEnabled()
    public static String checkOut(String routPlaneId,Double lat,Double lng){
        System.debug('delrId checkout-----'+routPlaneId);
        System.debug('delrId lat-----'+lat);
        System.debug('delrId lng-----'+lng);
        List<Route_Plan__c> checkOutList= new List<Route_Plan__c>();
        for(Route_Plan__c routobj : [SELECT Id,CheckOutDateTime__c,CheckOutLocation__C,CheckOutLocation__longitude__s,CheckOutLocation__latitude__s FROM Route_Plan__c where  RecordTypeId=:activityRecordTypeId AND Id =:routPlaneId]){
            system.debug('routobj'+routobj);
            if(routObj.CheckOutLocation__c==null){
                Route_Plan__c hmcRoutObj=new Route_Plan__c();        
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
* @description: To retrieve the most recent events
*/
    @AuraEnabled
    public static List<Route_Plan__c> fetchEvents() {
        List<Route_Plan__c> routPlaneList=new List<Route_Plan__c>();    
        datetime dt = system.today();
        string rotePMonth=monthNames.get(dt.format('MMMM'));
        String rotePYear = String.valueof(Date.Today().Year());
        System.debug('rotePMonth==>'+rotePMonth);
        System.debug('rotePYear==>'+rotePYear);
        system.debug('RecordTypeId=:'+monthRecordTypeId);
        system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
        
        Set<Id> routPlaneIds= new Set<Id>();
        routPlaneList=[SELECT Id,ASM__c,Month__c,Year__c FROM Route_Plan__c where  RecordTypeId=:monthRecordTypeId 
                       AND ASM__c=:UserInfo.getUserId() AND Month__c=:rotePMonth AND Year__c=:rotePYear 
                       and Approval_Status__c = 'Approved'];
        system.debug('routPlaneList===>'+routPlaneList);
        for(Route_Plan__c routPlaneObj :routPlaneList){
            routPlaneIds.add(routPlaneObj.Id);    
        }
        Integer month = Date.Today().Month();
        Integer year = Date.Today().Year();
        List<Route_Plan__c> routePlanAct=new List<Route_Plan__c>();//ativity
        routePlanAct=[SELECT Id,CreatedDate, Name, Status__c, Route_Plan__c,Route_Plan__r.Name, Visit_Date__c, Ad_hoc_visit__c,
                      Dealer_Name__r.Name,Dealer_Name__c,Dealer_Name__r.BillingStreet,Dealer_Name__r.BillingCity,
                      Beat_Group__c, Comments__c FROM Route_Plan__c where  RecordTypeId=:activityRecordTypeId AND
                      CALENDAR_MONTH(Visit_Date__c) = :month and CALENDAR_YEAR(Visit_Date__c) = :year AND
                      Route_Plan__c IN:routPlaneIds LIMIT 100]; //HMC_Beat_plan_matrix__c
        System.debug('act'+routePlanAct);
        System.debug('routPlaneList'+routPlaneList);
        System.debug('UserInfo.getUsername()'+UserInfo.getUsername());
        System.debug('Current User Id - '+UserInfo.getUserId());
        return routePlanAct;      
    }
    public static Map<String,String> monthNames = new Map<String,String>{
        'January'=> '01',
            'February'=> '02',
            'March'=> '03',
            'April'=> '04',
            'May'=> '05',
            'June'=> '06',
            'July'=> '07',
            'August'=> '08',
            'September'=> '09',
            'October'=> '10',
            'November'=> '11',
            'December'=> '12'
            };
                @AuraEnabled
                public static List<RotePlanActivityCls> fetchEvents1() {
                    
                    List<RotePlanActivityCls> rotePlaneList=new List<RotePlanActivityCls>();
                    List<Account> accList= [select id,Name,(select id,Visit_Date__c from Route_Plan__r WHERE  RecordTypeId=:activityRecordTypeId) from Account ORDER BY CreatedDate DESC Limit 100];
                    for(Account accOj :accList ){
                        RotePlanActivityCls roteObj=new RotePlanActivityCls();
                        roteObj.dealerName=accOj.Name;
                        roteObj.activities=accOj.Route_Plan__r;
                        rotePlaneList.add(roteObj);
                        
                    }        
                    return rotePlaneList;
                }
    public class RotePlanActivityCls{
        @AuraEnabled
        public String dealerName;
        @AuraEnabled
        public List<Route_Plan__c> activities;
    }
    @AuraEnabled
    public static String createNewEvent(Date visitdate, String delear,String Name,String routePlane){
        Map<String, Route_Plan__c> stringRoutePlanMap = new Map<String, Route_Plan__c>();
        List<Route_Plan__c> hmcRoutList=new List<Route_Plan__c>();
        System.debug('Visit Date'+visitdate);
        DateTime dt = visitdate;
        Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
        string sdate = String.valueOf(myDate);
        System.debug('Visit Date Only'+sdate);
        System.debug('Delear '+delear);
        System.debug('Name '+Name);
        System.debug('routePlane '+routePlane);
        Route_Plan__c routPlanObj = [SELECT Id, Name FROM Route_Plan__c WHERE Id=:routePlane LIMIT 1];
        List<Route_Plan__c> existungRoutePlanActivity = [SELECT Id, Dealer_Name__c,Visit_Date__c FROM
                                                         Route_Plan__c WHERE Route_Plan__c=:routePlane
                                                         AND Visit_Date__c=:visitdate AND RecordTypeId=:activityRecordTypeId];
        if(existungRoutePlanActivity.size()>0){
            for(Route_Plan__c rpa:existungRoutePlanActivity){
                string existingKey = rpa.Dealer_Name__c+'_'+rpa.Visit_Date__c;
                system.debug('existingKey===>'+existingKey);
                stringRoutePlanMap.put(existingKey, rpa);
            }
            if(stringRoutePlanMap.size()>0){
                string newKey =  delear+'_'+visitdate;
                system.debug('newKey===>'+newKey);
                if(!stringRoutePlanMap.containsKey(newKey)){ // if key is not present
                    Route_Plan__c hmcRoutObj=new Route_Plan__c();
                    hmcRoutObj.Name = routPlanObj.Name+' - '+sdate;
                    hmcRoutObj.RecordTypeId=activityRecordTypeId;
                    hmcRoutObj.Visit_Date__c=visitdate;
                    hmcRoutObj.Dealer_Name__c =delear;
                    hmcRoutObj.Route_Plan__c=routePlane; 
                    hmcRoutObj.Ad_hoc_visit__c=true;
                    hmcRoutList.add(hmcRoutObj);
                    system.debug('if key is not present');
                }else{
                    system.debug('if key is present'); 
                }
            }
        }else{
            Route_Plan__c hmcRoutObj=new Route_Plan__c();
            hmcRoutObj.Name = routPlanObj.Name+' - '+sdate;
            hmcRoutObj.RecordTypeId=activityRecordTypeId;
            hmcRoutObj.Visit_Date__c=visitdate;
            hmcRoutObj.Dealer_Name__c =delear;
            hmcRoutObj.Route_Plan__c=routePlane; 
            hmcRoutObj.Ad_hoc_visit__c=true;
            hmcRoutList.add(hmcRoutObj);
            system.debug('if no visist on this day is present'); 
        }
        if(!hmcRoutList.isEmpty()){
            System.debug('I am in insert');
            System.debug('hmcRoutList===>'+hmcRoutList.size());
            insert hmcRoutList;   
            System.debug('I am in insert done');  
            return 'Done';         
        }else{
            return 'NotDone';
        }       
    }
    
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
            Route_Plan__c hmcRoutObj=new Route_Plan__c();
            hmcRoutObj.Amount__c=amount;
            hmcRoutObj.RecordTypeId=activityRecordTypeId;
            hmcRoutObj.Id=recordId;
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
    
}