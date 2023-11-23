public class ManageRoutePlanActivities {
    
    public static Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
    public static Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
    public static Id expenseRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
    public static Id groupRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group').getRecordTypeId();
    public static Id groupMemberRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Group Member').getRecordTypeId();
    public static Id planmatrixRecordTypeId = Schema.SObjectType.Beat_Matrix__c.getRecordTypeInfosByName().get('Beat Plan Matrix').getRecordTypeId();
    
    @AuraEnabled(cacheable = true)
    public static List<Route_Plan__c> getRoutePlanActivities(String recordId){
        return [SELECT Id,Name, Visit_Date__c, Route_Plan__c, Dealer_Name__c,Dealer_Name__r.Name, Beat_Group__c,
                Beat_Group__r.Name FROM Route_Plan__c WHERE RecordTypeId =:activityRecordTypeId AND
                Route_Plan__c = :recordId];
    }
    
    @AuraEnabled(cacheable = true)
    public static Route_Plan__c getRoutePlanDetails(String recordId){
        System.debug('recordId Test'+recordId);
        return [SELECT Id,Approval_Status__c,Month__c,Year__c,ASM__c FROM Route_Plan__c WHERE 
                RecordTypeId =:monthRecordTypeId AND  Id = :recordId];
    }
    
    @AuraEnabled
    public static string updateRoutePlanActivities(Object data) {
        List<Route_Plan__c> RPAForUpdate = (List<Route_Plan__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Route_Plan__c>.class
        );
        try {
            update RPAForUpdate;
            return 'Success: Route plan activities updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }
    
    
    // updateApprovalStatus
    @AuraEnabled
    public static void updateApprovalStatus(String recordId){
        
        try{
            Route_Plan__c plan = new Route_Plan__c(Id=Id.valueOf(recordId),Deviation_approval_status__c='Submit for approval');
            update plan;
            
            String userId = UserInfo.getUserId();
            User usr = [SELECT Id,Name,UserRoleId,ProfileId,ManagerId from User where id=:userId];//
            Task tsk = new Task();
            tsk.Subject = 'Route plan Deviation Approval';
            tsk.OwnerId = usr.ManagerId;
            tsk.WhatId = Id.valueOf(recordId);
            tsk.Status = 'Open';
            Insert tsk;
            
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Dealer_Onboarding'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(usr.Name +' Route plan Deviation Approval ');
            notification.setBody('Status Route plan Deviation Approval '+usr.Name + ' is updated to approve ');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(recordId);
            notification.send(new set<String>{usr.ManagerId});
            
            
        }catch(Exception oEx){
            
        }
        
    }
    
    // OnApprove
    @AuraEnabled
    public static void OnApprove(String recordId){
        
        try{
            
            Route_Plan__c plan = [SELECT Id,Name,Deviation_approval_status__c,CreatedById from Route_Plan__C WHERE Id =: recordId];
            plan.Deviation_approval_status__c='Approved';
            update plan;
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Dealer_Onboarding'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(plan.Name +' is Approved');
            notification.setBody(plan.Name +' is Approved by Manager');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(recordId);
            notification.send(new set<String>{plan.CreatedById});
        }catch(Exception e){
            
        }
        
    }
    //OnReject
    @AuraEnabled
    public static void OnReject(String recordId){
        
        try{
            Route_Plan__c plan = [SELECT Id,Name,Deviation_approval_status__c,CreatedById from Route_Plan__C WHERE Id =: recordId];
            plan.Deviation_approval_status__c='Reject';
            update plan;
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Dealer_Onboarding'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(plan.Name +'is Rejected');
            notification.setBody(plan.Name +'is Rejected by Manager');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(recordId);
            notification.send(new set<String>{plan.CreatedById});
        }catch(Exception oEx){
            
        }
        
    }
    //Get userInfo
    
    
    @AuraEnabled(Cacheable=false)
    public Static String deleteBeatPlanMatrix(String recordId){
        Route_Plan__c routeActivity = new Route_Plan__c();
        routeActivity.Id = recordId;
        delete routeActivity;
        return 'Deleted';
    }
    
    @AuraEnabled
    public static String createTask(String recordId){
        String returnstr = '';
        try{
            Route_Plan__c plan = new Route_Plan__c(Id=Id.valueOf(recordId),Approval_Status__c='Submitted');
            update plan;
            
            String userId = UserInfo.getUserId();
            User usr = [SELECT Id,UserRoleId,ProfileId,ManagerId from User where id=:userId];
            system.debug('tsk'+usr.ManagerId);
            system.debug('tsk222'+userId);
            Task tsk = new Task();
            tsk.Subject = 'Route plan Approval';
            tsk.OwnerId = usr.ManagerId;
            tsk.WhatId = Id.valueOf(recordId);
            tsk.Status = 'Open';
            Insert tsk;
            system.debug('======> '+tsk.id);
            User usrmanager = [SELECT Id,Email from User where id=:usr.ManagerId];
            String  emailaddress = usrmanager.Email;
            system.debug('Manager emailaddress'+emailaddress);
            
        }catch(Exception oEx){
            
        }
        return returnstr;
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean getTasks(String recordId){
        Boolean disable = false;
        String userId  = UserInfo.getUserId();
        List<Task> tsklist = new List<Task>();
        try {
            Route_Plan__c plans = [SELECT Id,Name,CreatedById,Approval_Status__c from Route_Plan__c where Id =:Id.valueOf(recordId)];
            tsklist = [SELECT Id,Subject,Status FROM Task where Subject ='Route plan Approval' AND WhatId=: Id.valueOf(recordId) AND Status !='Completed' AND OwnerId =: Id.valueOf(userId)];
            if(tsklist.size() > 0){
                disable = true;
                return disable;
            }else if(tsklist.size() == 0){
                if(plans.Approval_Status__c == 'Approved'){
                    disable = true;
                    return disable;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return disable;
    }
    
    @AuraEnabled
    public static string updateBeatPlan(String recordId,String status,String comments){
        String userId  = UserInfo.getUserId();
        List<Task> tsklist = new List<Task>();
        String returnstr = '';
        try {
            Route_Plan__c plans = [SELECT Id,Name,CreatedById,Owner.Email from Route_Plan__c where Id =:Id.valueOf(recordId)];
            Route_Plan__c plan = new Route_Plan__c(Id=Id.valueOf(recordId),Approval_Status__c=status,Comments__c = comments);
            update plan;
            system.debug('tsklist'+plan);
            system.debug('tsklist'+recordId);
            system.debug('tsklist'+userId);
            tsklist = [SELECT Id,Subject,Status FROM Task where Subject ='Route plan Approval' AND WhatId=: Id.valueOf(recordId) AND Status !='Completed' AND OwnerId =: Id.valueOf(userId)];
            system.debug('tsklist000'+tsklist);
            if(!tsklist.isEmpty()){
                for(Task tsk : tsklist){
                    tsk.Status = 'Completed';
                }
                system.debug('tsklist'+tsklist);
                update tsklist;
            }
            
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Dealer_Onboarding'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(plans.Name +' status is updates to '+status);
            notification.setBody('Status of your plan '+plans.Name + ' is updated to '+status);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(plans.Id);
            notification.send(new set<String>{plans.CreatedById});
            
            String  emailaddress = plans.Owner.Email;
            if(test.isRunningTest()){
                emailaddress = 'test@gmail.com';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return returnstr;
    }
    
    @AuraEnabled(cacheable = false)
    public static List<beatRouteWrapper> getBeatGroup(String recordId){
        Set<Id> beatIds = new Set<Id>();
        List<Route_Plan__c> activities = new List<Route_Plan__c>(); //activity
        List<Route_Plan__c> subActivities = new List<Route_Plan__c>(); //activity
        
        Map<Id,String> routePlanActivity = new Map<Id,String>();
        Map<Id,List<String>> mapOfdates = new map<Id,List<String>>();
        String userId = UserInfo.getUserId();
        Map<Id,String> subRoutePlanActivity = new Map<Id,String>();
        Map<Id,List<String>> subMapOfdates = new map<Id,List<String>>();
        Map<Id,List<Account>> mapOfsubDea = new map<Id,List<Account>>();
        Set<Id> subDealerIds = new Set<Id>();
        List<Route_Plan__c> routeplan = [SELECT Id,ASM__c from Route_Plan__c where Id=: Id.valueOf(recordId)];
        List<Beat_Matrix__c> beatGroup = [Select Id,Name,Group_Name__c,Dealer__c,Dealer__r.Name,ASM__c,
                                          (Select Id,Name,Dealer__c,Dealer__r.Name,Dealer__r.Category__c,
                                           Dealer__r.BillingStreet,Dealer__r.BillingCity,Dealer__r.BillingState,
                                           Dealer__r.BillingCountry,Dealer__r.BillingPostalCode from 
                                           Beat_Matrix__r WHERE RecordtypeId=:groupMemberRecordTypeId)
                                          from Beat_Matrix__c where RecordtypeId=:groupRecordTypeId AND
                                          ASM__c =: routeplan[0].ASM__c LIMIT 200];
        If(!beatGroup.isEmpty()){
            for(Beat_Matrix__c bb : beatGroup){
                for(Beat_Matrix__c beatRec : bb.Beat_Matrix__r){
                    beatIds.add(beatRec.Dealer__c);
                }
            }
            System.debug('beatIdsbeatIds'+beatIds);
        }
        
        
        //Sub Dealers logic starts here 5th Jan
        List<Account> subDealers = [Select Id,Name, (Select Id, Name, Category__c,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode from Accounts__r)from Account where Id IN: beatIds];
        if(!subDealers.IsEmpty()){
            for(Account accRec: subDealers ){
                if(accRec.Accounts__r.Size() > 0){
                    for(Account subDealer : accRec.Accounts__r){
                        subDealerIds.add(subDealer.Id);
                        if(mapOfsubDea.containsKey(accRec.Id)){
                            mapOfsubDea.get(accRec.Id).add(subDealer);
                        }else{
                            mapOfsubDea.put(accRec.Id,new List<Account>{ subDealer});
                        }
                    }
                }
            } 
        }
        
        If(!subDealerIds.IsEmpty()){
            subActivities = [Select Id,Name,Dealer_Name__c,Visit_Date__c from Route_Plan__c where RecordTypeId=:activityRecordTypeId AND Route_Plan__c =: Id.valueOf(recordId) AND Dealer_Name__c IN: subDealerIds];
            if(!subActivities.isEmpty()){
                for(Route_Plan__c routeActivities : subActivities){
                    if(subRoutePlanActivity.containsKey(routeActivities.Dealer_Name__c)){
                        String append = subRoutePlanActivity.get(routeActivities.Dealer_Name__c);
                        subRoutePlanActivity.put(routeActivities.Dealer_Name__c,append+';'+string.valueof(routeActivities.Visit_Date__c)); 
                        subMapOfdates.get(routeActivities.Dealer_Name__c).add(string.valueof(routeActivities.Visit_Date__c)); 
                    }else{
                        subRoutePlanActivity.put(routeActivities.Dealer_Name__c,string.valueof(routeActivities.Visit_Date__c));  
                        subMapOfdates.put(routeActivities.Dealer_Name__c ,  new List<String>{string.valueof(routeActivities.Visit_Date__c)});
                    }
                }
            }
        }
        
        //Sub Dealars logic ends here
        activities  = [Select Id,Name,Dealer_Name__c,Visit_Date__c from Route_Plan__c where 
                       Route_Plan__c =: Id.valueOf(recordId) AND RecordTypeId=:activityRecordTypeId 
                       AND Dealer_Name__c IN: beatIds];
        System.debug('activitiesactivities'+activities);
        If(!activities.isEmpty()){
            for(Route_Plan__c routeActivities : activities){
                if(routePlanActivity.containsKey(routeActivities.Dealer_Name__c)){
                    String append = routePlanActivity.get(routeActivities.Dealer_Name__c);
                    routePlanActivity.put(routeActivities.Dealer_Name__c,append+';'+string.valueof(routeActivities.Visit_Date__c));  
                    mapOfdates.get(routeActivities.Dealer_Name__c).add(string.valueof(routeActivities.Visit_Date__c));
                }else{
                    routePlanActivity.put(routeActivities.Dealer_Name__c,string.valueof(routeActivities.Visit_Date__c));  
                    mapOfdates.put(routeActivities.Dealer_Name__c ,  new List<String>{string.valueof(routeActivities.Visit_Date__c)});
                }
            }
        }
        
        List<beatRouteWrapper> beatGroupWrap = new List<beatRouteWrapper>();
        //List<beatRouteMembersWrapper> beatGroupMember = new List<beatRouteMembersWrapper>();
        
        for(Beat_Matrix__c beatGrpRec : beatGroup){
            beatRouteWrapper  beatwrap = new beatRouteWrapper();
            List<beatRouteMembersWrapper> beatGroupMember = new List<beatRouteMembersWrapper>();
            beatwrap.Name = beatGrpRec.Group_Name__c;
            beatwrap.Dealer = beatGrpRec.Dealer__c;
            beatwrap.DealerName = beatGrpRec.Dealer__r.Name;
            beatwrap.Id = beatGrpRec.Id;
            //beatwrap.checked = false;
            for(Beat_Matrix__c beatRec : beatGrpRec.Beat_Matrix__r){
                List<subRouteGrpMemWrapper> subRtWrap = new List<subRouteGrpMemWrapper>();
                beatRouteMembersWrapper beatMemWrap = new beatRouteMembersWrapper();
                beatMemWrap.Name = beatRec.Name;
                beatMemWrap.Id = beatRec.Id;
                beatMemWrap.Dealer = '/'+beatRec.Dealer__c;
                beatMemWrap.DealerName = beatRec.Dealer__r.Name;
                beatMemWrap.ActivityDates = routePlanActivity.get(beatRec.Dealer__c);
                beatMemWrap.lstDates = mapOfdates.get(beatRec.Dealer__c);
                beatMemWrap.Category = beatRec.Dealer__r.Category__c;
                beatMemWrap.checked = false;
                
                beatMemWrap.Address = beatRec.Dealer__r.BillingStreet + ',' + beatRec.Dealer__r.BillingCity + ',' + beatRec.Dealer__r.BillingState+ ',' + beatRec.Dealer__r.BillingCountry+ ',' + beatRec.Dealer__r.BillingPostalCode;
                if(!mapOfsubDea.IsEmpty()){
                    if(mapOfsubDea.get(beatRec.Dealer__c) != null){
                        beatMemWrap.checkSubGrpDealer = true;
                        for(Account AccRec : mapOfsubDea.get(beatRec.Dealer__c)){
                            subRouteGrpMemWrapper srw = new subRouteGrpMemWrapper();
                            srw.Dealer = AccRec.Id;
                            srw.DealerName =AccRec.Name;
                            srw.ActivityDates = subRoutePlanActivity.get(AccRec.Id);
                            srw.Category = AccRec.Category__c;
                            srw.lstDates = subMapOfdates.get(AccRec.Id);
                            srw.checked = false;
                            srw.Address = AccRec.BillingStreet + ' , ' +AccRec.BillingCity+ ', ' +AccRec.BillingState+ ', ' +AccRec.BillingCountry + ', ' +AccRec.BillingPostalCode;
                            subRtWrap.add(srw);
                        }
                        beatMemWrap.subRouteGrpWrap = subRtWrap;
                    }else{
                        beatMemWrap.checkSubGrpDealer = false;
                    }
                }
                
                //
                beatGroupMember.add(beatMemWrap);
            }
            beatwrap.beatGroupMem = beatGroupMember;
            beatGroupWrap.add(beatwrap); 
        }
        System.debug('beatGroupWrap'+beatGroupWrap);
        return beatGroupWrap;
    }
    
    @AuraEnabled
     public static List<beatRouteWrapper> saveRoutePlans(List<String> plans,String recordId,String selectedDate){
        Map<String, Route_Plan__c> stringRoutePlanMap = new Map<String, Route_Plan__c>();
        List<beatRouteWrapper> wrapper = new List<beatRouteWrapper>();
        try {
            List<Route_Plan__c> lsttoInsert = new List<Route_Plan__c>();
            set<Id> MatrixIdSet = new set<Id>();
            for(String ids:plans){
                MatrixIdSet.add(ids); 
            }
            Map<Id,Beat_Matrix__c> beatMatrixMap= new Map<Id,Beat_Matrix__c>();
            if(MatrixIdSet.size()>0){
                for(Beat_Matrix__c bm:[SELECT Id, RecordTypeId, Beat_Group__c,Dealer__c FROM Beat_Matrix__c WHERE Id IN:MatrixIdSet]){
                    if(bm.Dealer__c !=Null){
                        beatMatrixMap.put(bm.Dealer__c, bm);   
                    }
                }
            }
            Map<Id,Route_Plan__c> routplanNameMap= new Map<Id,Route_Plan__c>([SELECT Id, Name FROM Route_Plan__c WHERE Id=:Id.valueOf(recordId)]);
            List<Route_Plan__c> existungRoutePlanActivity = [SELECT Id, Dealer_Name__c,Visit_Date__c FROM
                                                             Route_Plan__c WHERE Route_Plan__c=:Id.valueOf(recordId)
                                                             AND Visit_Date__c=:Date.valueOf(selectedDate) AND RecordTypeId=:activityRecordTypeId];
            
            if(existungRoutePlanActivity.size()>0){
                for(Route_Plan__c rpa:existungRoutePlanActivity){
                    string existingKey = rpa.Dealer_Name__c+'_'+rpa.Visit_Date__c;
                    system.debug('existingKey===>'+existingKey);
                    stringRoutePlanMap.put(existingKey, rpa);
                }
                if(beatMatrixMap.size()>0 && stringRoutePlanMap.size()>0){
                    for(Id str : beatMatrixMap.keySet()){
                        string newKey =  beatMatrixMap.get(str).Dealer__c+'_'+Date.valueOf(selectedDate);
                        system.debug('newKey===>'+newKey);
                        if(!stringRoutePlanMap.containsKey(newKey)){ // if key is not present
                            Route_Plan__c activity = new  Route_Plan__c();
                            activity.RecordTypeId = activityRecordTypeId;
                            activity.Name = routplanNameMap.get(Id.valueOf(recordId)).Name +' - '+ selectedDate;
                            activity.Route_Plan__c = Id.valueOf(recordId);
                            activity.Visit_Date__c = Date.valueOf(selectedDate);
                            activity.Dealer_Name__c = beatMatrixMap.get(Id.valueOf(str)).Dealer__c;
                            activity.Beat_Group__c = beatMatrixMap.get(Id.valueOf(str)).Beat_Group__c;
                            lsttoInsert.add(activity);
                            system.debug('if key is not present'); 
                        }else{
                            system.debug('if key is present'); 
                        }
                    }
                }
            }else{ //this else part will run only when there is no any activity scheduled on same day.
                if(beatMatrixMap.size()>0 && routplanNameMap.size()>0){
                    for(Id str : beatMatrixMap.keySet()){
                        system.debug('str===.'+str);
                        Route_Plan__c activity = new  Route_Plan__c();
                        activity.RecordTypeId = activityRecordTypeId;
                        activity.Name = routplanNameMap.get(Id.valueOf(recordId)).Name +' - '+ selectedDate;
                        activity.Route_Plan__c = Id.valueOf(recordId);
                        activity.Visit_Date__c = Date.valueOf(selectedDate);
                        activity.Dealer_Name__c = beatMatrixMap.get(Id.valueOf(str)).Dealer__c;
                        activity.Beat_Group__c = beatMatrixMap.get(Id.valueOf(str)).Beat_Group__c;
                        lsttoInsert.add(activity);
                        system.debug('if no visist on this day is present');
                    } 
                } 
            }
            if(lsttoInsert.size()>0){
                Insert lsttoInsert; 
            }
            wrapper = getBeatGroup(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +'@Line Number'+  e.getLineNumber());
        }
        return wrapper;
    }
    
    @AuraEnabled(cacheable = false)
    public static List<beatRouteWrapper> CreateBeatGroupActivities(String beatGroupId, String RoutePlanId, List<String> activitydates){
        List<beatRouteWrapper> wrapper = new List<beatRouteWrapper>();
        List<Route_Plan__c> routePlanActivityList  = new List<Route_Plan__c>();//activity
        List<Route_Plan__c> routeplan = [SELECT Id,ASM__c from Route_Plan__c where Id=: Id.valueOf(RoutePlanId)];
        List<Beat_Matrix__c> beatGroup = [Select Id,Name,Dealer__c,Dealer__r.Name,ASM__c,
                                          (Select Id,Name,Dealer__c,Dealer__r.Name,Dealer__r.Category__c from 
                                           Beat_Matrix__r WHERE RecordTypeId=:groupMemberRecordTypeId) 
                                          from Beat_Matrix__c where RecordTypeId=:groupRecordTypeId AND 
                                          Id =: Id.valueOf(beatGroupId)];
        for(String ss: activitydates){
            for(Beat_Matrix__c mem : beatGroup[0].Beat_Matrix__r){
                Route_Plan__c planActivity = new Route_Plan__c(); //activity
                planActivity.RecordTypeId = activityRecordTypeId;
                planActivity.Dealer_Name__c = mem.Dealer__c;
                planActivity.Visit_Date__c = Date.valueOf(ss);
                planActivity.Beat_Group__c = beatGroup[0].Id;
                planActivity.Route_Plan__c = routeplan[0].Id;
                routePlanActivityList.add(planActivity);
            }
        }
        insert routePlanActivityList;
        wrapper = getBeatGroup(routeplan[0].Id);
        return wrapper;
    }
    
    @AuraEnabled(cacheable = false)
    public static List<Route_Plan__c> getRoutePlanActivitiesforBeatGroup(String beatId,String recordId){
        List<Route_Plan__c> activities = new List<Route_Plan__c>();//activity
        try {
            List<Beat_Matrix__c> beatMatrix = [Select Id,Name,Dealer__c from Beat_Matrix__c where RecordTypeid=:groupMemberRecordTypeId AND Id =: Id.valueOf(beatId)];
            activities  = [Select Id,Name,Dealer_Name__c,Visit_Date__c,Status__c,Comments__c,Beat_Group__c from Route_Plan__c 
                           where Route_Plan__c =: Id.valueOf(recordId) AND RecordTypeid=:activityRecordTypeId AND
                           Dealer_Name__c =: beatMatrix[0].Dealer__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return activities;
    }
    
    @AuraEnabled(cacheable = false)
    public static List<Route_Plan__c> getRoutePlanActivitiesforDealer(String beatId,String recordId){
        List<Route_Plan__c> activities = new List<Route_Plan__c>();
        try {
            List<Route_Plan__c> beatMatrix = [SELECT Id,Name,ASM__c,Dealer_Name__c,Dealer_Name__r.Name from Route_Plan__c where RecordTypeid=:planmatrixRecordTypeId AND Id =: Id.valueOf(beatId)];
            activities  = [Select Id,Name,Dealer_Name__c,Visit_Date__c,Status__c,Comments__c from
                           Route_Plan__c where RecordTypeid=:activityRecordTypeId AND
                           Route_Plan__c =: Id.valueOf(recordId) AND Dealer_Name__c =: beatMatrix[0].Dealer_Name__c];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return activities;
    }
    
    @AuraEnabled(cacheable = true)
    public Static Account getDealerDetails(String beatId){
        Account acc = new Account();
        List<Beat_matrix__c> beatMatrix = [SELECT Id,Name,ASM__c,Dealer__c,Dealer__r.Name,Pincode__c 
                                           from Beat_matrix__c where RecordTypeId=:planmatrixRecordTypeId
                                           AND Id =: Id.valueOf(beatId)];
        
        acc = [SELECT Id,Name,Category__c From Account where id =: beatMatrix[0].Dealer__c];
        return acc;
    }
    
    @AuraEnabled(cacheable = true)
    public Static Account getDealerDetailsGroup(String accbeatMemId){
        Account acc = new Account();
        List<Beat_Matrix__c> beatGroup = [Select Id,Name,Dealer__c from Beat_Matrix__c where
                                          RecordTypeId=:groupMemberRecordTypeId AND
                                          Id =: Id.valueOf(accbeatMemId)];
        acc = [SELECT Id,Name,Category__c From Account where id =: beatGroup[0].Dealer__c];
        return acc;
    }
    
    //Get userInfo
    
    @AuraEnabled
    public static String GetUserDetails(String recordId){
        System.debug('recordId Test '+recordId);
        
        try{
            String userId = UserInfo.getUserId();
            //original logic is commended due to Role Not assigned to any user.
           // List<User> usr = [SELECT Id,UserRole.Name,ProfileId,ManagerId from User where UserRole.Name LIKE 'RSM%' AND id=:userId];

            List<User> usr = [SELECT Id,ProfileId from User where ProfileId='00e5j000005BRrWAAW' AND id=:userId];
            Route_Plan__c plan = [Select Id, Deviation_approval_status__c from Route_Plan__c where RecordTypeId=:monthRecordTypeId
                                  AND id =: Id.valueOf(recordId)];
            
            if(!usr.IsEmpty() && plan.Deviation_approval_status__c == 'Submit for approval'){
                return 'SUCCESS';
            }else if(plan.Deviation_approval_status__c == 'Approved'){
                return 'Approved';
            }else if(plan.Deviation_approval_status__c == 'Submit for approval'){
                return 'Subbmitted';
            }else {
                return 'FAILURE';
            }
            
        }catch(Exception oEx){
            
        }
        return ' ';
    }
    
    
    @AuraEnabled
    public static List<beatRouteWrapper>  createRoutePlangroup(Object data){
        string res = 'Success';
        List<beatRouteWrapper>  wrapper  = new List<beatRouteWrapper>();
        try {
            System.debug('data-->'+data);
            List<Route_Plan__c> RPAForUpdate = (List<Route_Plan__c>) JSON.deserialize(JSON.serialize(data),List<Route_Plan__c>.class);//activity
            List<Beat_Matrix__c> beatMatrix = [Select Id,Name,Dealer__c,Beat_Group__c from Beat_Matrix__c where
                                               RecordtypeId=:groupMemberRecordTypeId And Beat_Group__c =: RPAForUpdate[0].Beat_Group__c];//group member
            system.debug('===='+beatMatrix);
            for(Route_Plan__c act : RPAForUpdate){
                act.Beat_Group__c = beatMatrix[0].Beat_Group__c;
                act.Dealer_Name__c = beatMatrix[0].Dealer__c;
            }
            Upsert RPAForUpdate;
            wrapper = getBeatGroup(RPAForUpdate[0].Route_Plan__c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return wrapper;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<routeWrapper> getBeatPlanMatrix(String recordId){
        system.debug('getBeatPlanMatrix method called=====>'+recordId); //route plan id
        List<Route_Plan__c> activities = new List<Route_Plan__c>();//activity
        List<Route_Plan__c> subActivities = new List<Route_Plan__c>(); //activity
        Set<Id> beatIds = new Set<Id>();
        String userId = UserInfo.getUserId();
        Map<Id,String> routePlanActivity = new Map<Id,String>();
        Map<Id,List<String>> mapOfdates = new map<Id,List<String>>();
        Map<Id,String> subRoutePlanActivity = new Map<Id,String>();
        Map<Id,List<String>> subMapOfdates = new map<Id,List<String>>();
        List<routeWrapper> routeWrap = new List<routeWrapper>();
          List<routeWrapper> routeWrapTempList = new List<routeWrapper>();
        Map<Id,List<Account>> mapOfsubDea = new map<Id,List<Account>>();
        
        List<Route_Plan__c> routeplan = [SELECT Id,ASM__c from Route_Plan__c where Id=: Id.valueOf(recordId)];
        system.debug('routeplan'+routeplan);
        system.debug('routeplan[0].ASM__c'+routeplan[0].ASM__c);
        
        List<Beat_matrix__c> beatMatrix = [SELECT Id,Name,Beat_Group__c, ASM__c,Dealer__c,Dealer__r.Name,Dealer__r.BillingStreet,
                                           Dealer__r.BillingCity,Dealer__r.BillingState,Dealer__r.BillingCountry,
                                           Dealer__r.BillingPostalCode,Dealer__r.Category__c, Pincode__c from
                                           Beat_matrix__c where ASM__c =: routeplan[0].ASM__c AND
                                           RecordTypeId=:planmatrixRecordTypeId];   
        
        system.debug('beatMatrix'+beatMatrix);
        If(!beatMatrix.isEmpty()){
            for(Beat_matrix__c beatRec : beatMatrix){
                beatIds.add(beatRec.Dealer__c);
            }
        }
        if(beatIds.size()>0){
            activities  = [Select Id,Name,Dealer_Name__c,Visit_Date__c from Route_Plan__c where
                           RecordTypeId=:activityRecordTypeId AND Route_Plan__c =: Id.valueOf(recordId) AND
                           Dealer_Name__c IN: beatIds];   
        }
        
        If(!activities.isEmpty()){
            for(Route_Plan__c routeActivities : activities){
                if(routePlanActivity.containsKey(routeActivities.Dealer_Name__c)){
                    String append = routePlanActivity.get(routeActivities.Dealer_Name__c);
                    routePlanActivity.put(routeActivities.Dealer_Name__c,append+';'+string.valueof(routeActivities.Visit_Date__c)); 
                    mapOfdates.get(routeActivities.Dealer_Name__c).add(string.valueof(routeActivities.Visit_Date__c)); 
                }else{
                    routePlanActivity.put(routeActivities.Dealer_Name__c,string.valueof(routeActivities.Visit_Date__c));  
                    mapOfdates.put(routeActivities.Dealer_Name__c ,  new List<String>{string.valueof(routeActivities.Visit_Date__c)});
                }
            }
        }
        
        System.debug('beatMatrix--->'+beatMatrix);
       
        for(Beat_matrix__c beatRec : beatMatrix){
            if(beatRec.Dealer__c !=Null){
               routeWrapper rw = new routeWrapper();
                rw.Name = beatRec.Name;
                rw.Id = beatRec.Id;
                rw.Pincode = beatRec.Pincode__c;
                rw.Dealer = beatRec.Dealer__c;
                rw.DealerName = beatRec.Dealer__r.Name;
                rw.ActivityDates = routePlanActivity.get(beatRec.Dealer__c);
                rw.Category = beatRec.Dealer__r.Category__c;
                rw.lstDates = mapOfdates.get(beatRec.Dealer__c);
                rw.Address = beatRec.Dealer__r.BillingStreet + ',' + beatRec.Dealer__r.BillingCity + ',' + beatRec.Dealer__r.BillingState+ ',' + beatRec.Dealer__r.BillingCountry+ ',' + beatRec.Dealer__r.BillingPostalCode;
                rw.checked = false;
                routeWrap.add(rw);  
            }
            if(beatRec.Beat_group__c !=Null){
                routeWrapTempList = getWrapperByGroupID(beatRec.Beat_group__c ,recordId);
                if(routeWrapTempList.size()>0){
                     routeWrap.addAll(routeWrapTempList);
                }
            }
        }
        System.debug('@#@#@##@#@#routeWrap-616=====>'+routeWrap);
        return routeWrap;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<routeWrapper> getWrapperByGroupID(string groupId, String recordId){
        List<routeWrapper> routeWrap = new List<routeWrapper>();
        Set<Id> beatIds = new Set<Id>();
         List<Route_Plan__c> activities = new List<Route_Plan__c>();//activity
         Map<Id,String> routePlanActivity = new Map<Id,String>();
         Map<Id,List<String>> mapOfdates = new map<Id,List<String>>();
        
        List<Beat_matrix__c> beatGroupmemberList = new List<Beat_matrix__c>();
        beatGroupmemberList = [SELECT Id,Name,Pincode__c,Dealer__c,Dealer__r.Name,Dealer__r.Category__c,
                               Dealer__r.BillingStreet,Dealer__r.BillingCity,Dealer__r.BillingState,
                               Dealer__r.BillingCountry,Dealer__r.BillingPostalCode FROM Beat_matrix__c
                               WHERE Beat_Group__c =:groupId AND RecordTypeId=:groupMemberRecordTypeId];
        
        if(beatGroupmemberList.size()>0){
            for(Beat_matrix__c beatRec:beatGroupmemberList){
                beatIds.add(beatRec.Dealer__c);
            } 
        }
         if(beatIds.size()>0){
            activities  = [Select Id,Name,Dealer_Name__c,Visit_Date__c from Route_Plan__c where
                           RecordTypeId=:activityRecordTypeId AND Route_Plan__c =: Id.valueOf(recordId) AND
                           Dealer_Name__c IN: beatIds];   
        }
        
        If(!activities.isEmpty()){
            for(Route_Plan__c routeActivities : activities){
                if(routePlanActivity.containsKey(routeActivities.Dealer_Name__c)){
                    String append = routePlanActivity.get(routeActivities.Dealer_Name__c);
                    routePlanActivity.put(routeActivities.Dealer_Name__c,append+';'+string.valueof(routeActivities.Visit_Date__c)); 
                    mapOfdates.get(routeActivities.Dealer_Name__c).add(string.valueof(routeActivities.Visit_Date__c)); 
                }else{
                    routePlanActivity.put(routeActivities.Dealer_Name__c,string.valueof(routeActivities.Visit_Date__c));  
                    mapOfdates.put(routeActivities.Dealer_Name__c ,  new List<String>{string.valueof(routeActivities.Visit_Date__c)});
                }
            }
        }
        
        
        if(beatGroupmemberList.size()>0){
            for(Beat_matrix__c beatRec:beatGroupmemberList){
                routeWrapper rw = new routeWrapper();
                rw.Name = beatRec.Name;
                rw.Id = beatRec.Id;
                rw.Pincode = beatRec.Pincode__c;
                rw.Dealer = beatRec.Dealer__c;
                rw.DealerName = beatRec.Dealer__r.Name;
                rw.ActivityDates = routePlanActivity.get(beatRec.Dealer__c);
                rw.Category = beatRec.Dealer__r.Category__c;
                rw.lstDates = mapOfdates.get(beatRec.Dealer__c);
                rw.Address = beatRec.Dealer__r.BillingStreet + ',' + beatRec.Dealer__r.BillingCity + ',' + beatRec.Dealer__r.BillingState+ ',' + beatRec.Dealer__r.BillingCountry+ ',' + beatRec.Dealer__r.BillingPostalCode;
                rw.checked = false;
                routeWrap.add(rw);   
            }
        }
        system.debug('672====>'+routeWrap);
        return routeWrap;
    }
    
    @AuraEnabled
    public static List<routeWrapper>  saveForGroup(List<String> plans,String recordId,String selectedDate){
        system.debug('plans-683'+plans);
        system.debug('recordId-684'+recordId);
        system.debug('selectedDate-685'+selectedDate);
        List<routeWrapper> wrapper = new List<routeWrapper>();
        try {
            set<Id> matrixIds = new set<Id>();
            List<Route_Plan__c> lsttoInsert = new List<Route_Plan__c>();
            
            Schema.DescribeSObjectResult matirx = Beat_Matrix__c.sObjectType.getDescribe();
            String MatrixPrefix = matirx.getKeyPrefix();
            System.debug('MatrixPrefix'+MatrixPrefix);
            
            for(String str : plans){ //plans is beat plan matrix
                System.debug('result01'+str);
                System.debug('result'+str.startsWith(MatrixPrefix));
                if(str.startsWith(MatrixPrefix)){
                    matrixIds.add(str);
                }
            }
            Set<Id> groupIdset = new Set<Id>();
            
            Map<Id,Route_Plan__c> routplannameMap= new Map<Id,Route_Plan__c>([SELECT Id, Name, Beat_Group__r.Name FROM Route_Plan__c WHERE Id=:Id.valueOf(recordId)]);
            
            system.debug('matrixIds===='+matrixIds);
            Map<Id,Beat_Matrix__c> delerMap;
            if(!matrixIds.isEmpty()){
                delerMap = new Map<Id,Beat_Matrix__c>([SELECT Id,Beat_Group__c,Dealer__c FROM Beat_Matrix__c WHERE RecordTypeId=:planmatrixRecordTypeId AND Id IN: matrixIds]);
            }
            system.debug('delerMap===='+delerMap);
            for(String str : plans){
                if(str.startsWith(MatrixPrefix)){
                    Route_Plan__c activity = new  Route_Plan__c();
                    activity.Name= routplannameMap.get(Id.valueOf(recordId)).Name +' - '+ selectedDate;
                    activity.RecordTypeId = activityRecordTypeId;
                    activity.Route_Plan__c = Id.valueOf(recordId);
                    activity.Visit_Date__c = Date.valueOf(selectedDate);
                    activity.Dealer_Name__c = delerMap.get(Id.valueOf(str)).Dealer__c;
                    //activity.Beat_matrix__c = Id.valueOf(str);
                    lsttoInsert.add(activity);   
                    
                } else if(str.startsWith('001')){
                    Route_Plan__c activity = new  Route_Plan__c();
                    activity.Name= routplannameMap.get(Id.valueOf(recordId)).Name +' - '+ selectedDate;
                    activity.Route_Plan__c = Id.valueOf(recordId);
                    activity.RecordTypeId = activityRecordTypeId;
                    activity.Visit_Date__c = Date.valueOf(selectedDate);
                    activity.Dealer_Name__c = delerMap.get(Id.valueOf(str)).Dealer__c;
                    //activity.Beat_plan_matrix__c = Id.valueOf(str);
                    lsttoInsert.add(activity);
                }
            }
            
            if(lsttoInsert.size()>0){
                Insert lsttoInsert;  
            }
            
            wrapper = getBeatPlanMatrix(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static List<routeWrapper> createRoutePlan(Object data){
        string res = 'Success';
        List<routeWrapper> wrapper  = new List<routeWrapper>();
        try {
            System.debug('data-->'+data);
            List<Route_Plan__c> RPAForUpdate = (List<Route_Plan__c>) JSON.deserialize(JSON.serialize(data),List<Route_Plan__c>.class);
            Upsert RPAForUpdate;
            wrapper = getBeatPlanMatrix(RPAForUpdate[0].Route_Plan__c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() +''+  e.getLineNumber());
        }
        return wrapper;
    }
    
    public class routeWrapper {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Pincode {get;set;}
        @AuraEnabled Public Id Dealer {get;set;}
        @AuraEnabled public String DealerName {get;set;}
        @AuraEnabled public String ActivityDates {get;set;}
        @AuraEnabled public String Category {get;set;}
        @AuraEnabled public List<String> lstDates {get;set;}
        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public Boolean checkSubDealer {get;set;}
        @AuraEnabled public List<subRouteWrapper> subRouteWrap {get;set;}
        @AuraEnabled public String Address {get;set;}
    }
    
    public class subRouteWrapper {
        // @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Id {get;set;}
        // @AuraEnabled public String Pincode {get;set;}
        @AuraEnabled Public Id Dealer {get;set;}
        @AuraEnabled public String DealerName {get;set;}
        @AuraEnabled public String ActivityDates {get;set;}
        @AuraEnabled public String Category {get;set;}
        @AuraEnabled public List<String> lstDates {get;set;}
        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public String Address {get;set;}
    }
    public class beatRouteWrapper {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled Public String Dealer {get;set;}
        @AuraEnabled public String DealerName {get;set;}
        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public List<beatRouteMembersWrapper> beatGroupMem {get;set;}
    }
    public class beatRouteMembersWrapper {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled Public String Dealer {get;set;}
        @AuraEnabled Public String DealerName {get;set;}
        @AuraEnabled public String ActivityDates {get;set;}
        @AuraEnabled public String Category {get;set;}
        @AuraEnabled public List<String> lstDates {get;set;}
        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public Boolean checkSubGrpDealer {get;set;}
        @AuraEnabled public String Address {get;set;}
        @AuraEnabled public List<subRouteGrpMemWrapper> subRouteGrpWrap {get;set;}
    }
    public class subRouteGrpMemWrapper {
        
        @AuraEnabled Public Id Dealer {get;set;}
        @AuraEnabled public String DealerName {get;set;}
        @AuraEnabled public String ActivityDates {get;set;}
        @AuraEnabled public String Category {get;set;}
        @AuraEnabled public List<String> lstDates {get;set;}
        @AuraEnabled public Boolean checked {get;set;}
        @AuraEnabled public String Address {get;set;}
    }
    
    public class beatRouteMembersWrapper1 {
        @AuraEnabled public String groupName {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled Public String Dealer {get;set;}
        @AuraEnabled Public String DealerName {get;set;}
        @AuraEnabled public String ActivityDates {get;set;}
        @AuraEnabled public String Category {get;set;}
        @AuraEnabled public List<String> lstDates {get;set;}
    }
    
    
    
    
}