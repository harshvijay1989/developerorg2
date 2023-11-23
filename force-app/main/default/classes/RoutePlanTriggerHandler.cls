public class RoutePlanTriggerHandler {
    
    
    //this method work on before opreations
    public static void beforeOpreations(List<Route_Plan__c> newRoutePlanLst){
        Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
        Set<Id> hmcRoutePlanIDs=new Set<Id>();
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);      
        List<Route_Plan__c> hmcRoutePlanList=new List<Route_Plan__c>();
        if(!hmcRoutePlanIDs.isEmpty() || hmcRoutePlanIDs!=null ){
            System.debug(hmcRoutePlanIDs);
            hmcRoutePlanList=[SELECT Id,Approval_Status__c,Month__c,Year__c,ASM__c FROM Route_Plan__c
                              Where Id NOT In : hmcRoutePlanIDs AND RecordTypeId=:monthRecordTypeId];         
        }else{
            hmcRoutePlanList=[SELECT Id,Approval_Status__c,Month__c,Year__c,ASM__c FROM Route_Plan__c WHERE RecordTypeId=:monthRecordTypeId ];
        }
        System.debug('hmcRoutePlanList'+hmcRoutePlanList);
        if(!hmcRoutePlanList.isEmpty()){
            System.debug(hmcRoutePlanList);
            Set<String> routePlandeatils=new Set<String>();
            for(Route_Plan__c hmcObj:hmcRoutePlanList){
                String rouDetails='';
                if(String.isNotBlank(hmcObj.ASM__c) && (hmcObj.Approval_Status__c=='Rejected' || hmcObj.Approval_Status__c=='Draft')){
                    System.debug(hmcObj.Month__c);
                    rouDetails=hmcObj.ASM__c + String.valueOf(hmcObj.Month__c) + hmcObj.Year__c;
                    routePlandeatils.add(rouDetails);
                    System.debug(routePlandeatils);
                }
            }
        }
    }
    
    //this method work on after opreations
    public static void afterUpdate(List<Route_Plan__c> newRoutePlanLst, Map<Id,Route_Plan__c> oldRoutePlanMap){
        Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
        Id expenseRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        
        Set<Id> ids = new  Set<Id>();
        List<Order__c> routExpDet = new List<Order__c>();
        for(Route_Plan__c routPlan : newRoutePlanLst){
            ids.add(routPlan.id);  
        }
        
        Set<Date> datSet = new Set<Date>();
        system.debug('ids'+ids);
        List<Route_Plan__c> roughtPlanActivLst1 = [SELECT Id,Visit_Date__c,Route_Plan__c FROM Route_Plan__c WHERE RecordTypeId=:activityRecordTypeId AND Route_Plan__c =: ids];
        system.debug('roughtPlanActivLst1'+roughtPlanActivLst1);
        if(!roughtPlanActivLst1.isEmpty()){
            for(Route_Plan__c obj : roughtPlanActivLst1 ){
                datSet.add(obj.Visit_Date__c); 
            }
        }
        List<date> dLst = new List<date>();
        for(date d : datSet){
            dLst.add(d);
        }
        
        //system.debug('ans 1 ==>'+datSet);
        
        List< Route_Plan__c> roughtPlanActivLst = [SELECT Id,Visit_Date__c,Route_Plan__c FROM Route_Plan__c WHERE Route_Plan__c =: ids AND Visit_Date__c in: datSet AND RecordTypeId=:activityRecordTypeId];
        system.debug('ans==>'+roughtPlanActivLst);
        for(Route_Plan__c objj : newRoutePlanLst){
            if(objj.Approval_Status__c == 'Approved' && !dLst.isEmpty() && oldRoutePlanMap.get(objj.id).Approval_Status__c != objj.Approval_Status__c ){
                for(integer i=0; i<dLst.size(); i++){
                    
                    Order__c expDetails = new Order__c();
                    expDetails.RecordTypeId= expenseRecordTypeId;
                    expDetails.Route_Plan__c =   roughtPlanActivLst[i].Route_Plan__c;                 //ids[i];
                    expDetails.Visit_Date__c = dLst[i];
                    routExpDet.add(expDetails);          
                }   
            }
        }
        if(!routExpDet.isEmpty()){
           // insert routExpDet;
        }
    }
    
    
    public static void deleteRelatedRecords(List<Route_Plan__c> newRoutePlanLst){
    Id activityRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
    Id monthRecordTypeId = Schema.SObjectType.Route_Plan__c.getRecordTypeInfosByName().get('Month').getRecordTypeId();
    Id expenseRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
    
        Set<Id> deletedIdSet = new Set<Id>();
        for(Route_Plan__c deletedPlans :newRoutePlanLst){
            system.debug('deletedPlans.RecordTypeId=====>'+deletedPlans.RecordTypeId);
             system.debug('monthRecordTypeId============>'+monthRecordTypeId);
            if(deletedPlans.RecordTypeId==monthRecordTypeId){
                deletedIdSet.add(deletedPlans.Id);
            }
        }
        
        if(deletedIdSet.size()>0){
           List<Route_Plan__c> activityToBeDeleted = [SELECT Id,Route_Plan__c FROM Route_Plan__c WHERE 
                                                      RecordTypeId=:activityRecordTypeId AND 
                                                      Route_Plan__c IN:deletedIdSet];
            system.debug('activityToBeDeleted====>'+activityToBeDeleted.size());
            if(activityToBeDeleted.size()>0){
                delete activityToBeDeleted;
            }
            
            List<Order__c> expenseToBeDeleated = [SELECT Id,Route_Plan__c FROM Order__c WHERE
                                                  RecordTypeId=:expenseRecordTypeId AND
                                                  Route_Plan__c IN:deletedIdSet];
            system.debug('expenseToBeDeleated====>'+expenseToBeDeleated.size());
            if(expenseToBeDeleated.size()>0){
                delete expenseToBeDeleated;
            }
        }
    }
}