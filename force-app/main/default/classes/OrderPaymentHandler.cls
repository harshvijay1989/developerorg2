public class OrderPaymentHandler {
public static void afterUpdateTarget(List<Order__c> newoppotunity,Map<Id,Order__c> oldMap){
        Set<Id> accIds= new Set<Id>();
        for(Order__c opp: newoppotunity){
            if(opp !=null &&  opp.HMC_Invoice_Amount__c != oldMap.get(opp.id).HMC_Invoice_Amount__c){
                system.debug('opp'+opp);
                accIds.add(opp.Account__c);
            }
        }
        
        Map<map<String,String>,List<Order__c>> oppMap=new  Map<map<String,String>,List<Order__c>>();
        if(accIds !=null){
            for(Order__c opp:[SELECT Id,HMC_Invoice_Date__c,CreatedDate,HMC_Invoice_Amount__c FROM Order__c WHERE HMC_Order_Number__c != null AND Account__c IN :accIds]){
                system.debug('opp'+opp);
                if(opp.CreatedDate != null){
                map<String,String> monthYearMap=new  map<String,String>();
                String month=String.valueOf(opp.CreatedDate.month());
                String year = String.valueOf(opp.CreatedDate.year());
                system.debug('month'+month);
                system.debug('year'+year);
                monthYearMap.put(month, year);
                List<Order__c> oppList = oppMap.get(monthYearMap);
                if(oppList == null)
                    oppList = new List<Order__c>();
                oppList.add(opp);
                system.debug('monthYearMap'+monthYearMap);
                system.debug('oppList'+oppList);
                oppMap.put(monthYearMap,oppList);
                }
            }
        }
        system.debug('oppMap'+oppMap);
        List<HMC_Target__c> targateList=new  List<HMC_Target__c>();
        if(accIds !=null){
            for(HMC_Target__c HMCTarget:[SELECT Id,HMC_Month__c,HMC_Year__c,HMC_Achievement_Amount__c FROM HMC_Target__c WHERE HMC_Dealer__c IN :accIds ]){
                system.debug('HMCTarget'+HMCTarget);
                if(HMCTarget.HMC_Year__c != null && HMCTarget.HMC_Month__c != null){
                    Integer achiveMentAmount=0;
                    system.debug('HMCTarget'+HMCTarget);
                    map<String,String> yearMonthMap=new map<String,String>();
                    yearMonthMap.put(HMCTarget.HMC_Month__c,HMCTarget.HMC_Year__c);
                    if(oppMap.containsKey(yearMonthMap)){
                        for(Order__c opp: oppMap.get(yearMonthMap)){
                            if(opp.HMC_Invoice_Amount__c != null){
                                achiveMentAmount=achiveMentAmount+integer.valueOf(opp.HMC_Invoice_Amount__c); 
                            }
                        }
                    }
                    system.debug('achiveMentAmount'+achiveMentAmount);
                    HMCTarget.HMC_Achievement_Amount__c=achiveMentAmount;
                    targateList.add(HMCTarget);
                }
                
            }
        }
        system.debug('targateList'+targateList);
        if(!targateList.isEmpty()){
            system.debug('targateList'+targateList);
            update targateList;
            
        }
    }
}