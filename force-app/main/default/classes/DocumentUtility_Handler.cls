public class DocumentUtility_Handler {
 /*   public static All_Document__c getDocument(String recordId){
       // return [SELECT id,Name,Active__c,Description__c,Content__c,Object_Name__c FROM All_Document__c WHERE id =: recordId LIMIT 1];
    }*/
    public static Boolean validateDoc(List<String> fieldLst,String objName){
        Boolean flag = true;
        if(fieldLst.size()!=0){
            String fields = String.join(fieldLst, ', ');
            system.debug('fields '+fields);
            String Query;
            if(!fieldLst.isEmpty()){
                Query = 'SELECT id,'+fields+' FROM '+objName+' LIMIT 1';
            }
            System.debug('Query'+Query);
            try{
                Database.query(Query);
                flag = true;
            }catch(Exception e){
                System.debug('Exception: '+e);
                flag = false;
            }
        }
        return flag;
    }
    
    public static Map<String,String> getBlankData(Map<String,String> fieldMap){
        Map<String,String> data = new Map<String,String>();
        for(String key:fieldMap.keySet()){
            data.put(fieldMap.get(key),NULL); 
        }
        return data;
    }
    
    public static Map<String,String> makePattern(Map<String,String> fieldMap){
        Map<String,String> data = new Map<String,String>();
        for(String key:fieldMap.keySet()){
            String pattern = '{{{'+key+'}}}';
            data.put(pattern,fieldMap.get(key));
        }
        return data;
    }
    
    public static Map<String,String> getAllData(Map<String,String> fieldMap,String objName,String recordId){
        try{
            Map<String,String> data = new Map<String,String>();
            data = getBlankData(fieldMap);
            System.debug('getBlankData :'+ data);
            System.debug('fieldMap :'+ fieldMap);
            List<String> fieldLst = new List<String>();
            for(String val:data.keySet()){
                fieldLst.add(val);
            }
            System.debug('fieldLst : '+ fieldLst);
            String fields = String.join(fieldLst, ', ');
            String Query;
            if(!fieldLst.isEmpty()){
                Query = 'SELECT id,'+fields+' FROM '+objName+' WHERE id=\''+recordId+'\' LIMIT 1'; 
                System.debug('Query : '+ Query);
                System.debug('All Data '+database.query(Query));
                
                sObject content = Database.query(Query);
                System.debug('content : '+ content);
                System.debug('data.keySet() '+ data.keySet());
                for(String val:data.keySet()){
                    System.debug('val : '+val);
                    if(val.contains('.')){
                        List<String> relationshipFields = val.split('\\.');
                        System.debug('***--- relationshipFields '+ relationshipFields);
                        System.debug('***--- relationshipFields.size() '+ relationshipFields.size());
                        if(relationshipFields.size() == 2){
                            Object obj = content.getSObject(relationshipFields[0]);
                            if (obj != null) {
                                if (obj instanceof SObject) {
                                    SObject sObjectRecord = (SObject)obj; // Use a different variable name
                                    Object fieldValue = sObjectRecord.get(relationshipFields[1]);
                                    data.put(val, (fieldValue != null) ? fieldValue.toString() : '');
                                } else {
                                    data.put(val,'');
                                }
                            } else {
                                // Handle the case where obj is null
                                // You can log an error message or take other appropriate actions
                            }
                        }else if(relationshipFields.size() == 3){
                            Object obj1 = content.getSObject(relationshipFields[0]);
                            
                            if (obj1 != null && obj1 instanceof SObject) {
                                SObject sObject1 = (SObject)obj1;
                                
                                Object obj2 = sObject1.getSObject(relationshipFields[1]);
                                
                                if (obj2 != null && obj2 instanceof SObject) {
                                    SObject sObject2 = (SObject)obj2;
                                    
                                    Object fieldValue = sObject2.get(relationshipFields[2]);
                                    data.put(val,(String)fieldValue);
                                } else {
                                    data.put(val,'');
                                }
                            } else {
                                // Handle the case where obj1 is null or not an SObject
                                // You can log an error message or take other appropriate actions
                            } 
                            //data.put(val,(String)content.getSObject(relationshipFields[0]).getSObject(relationshipFields[1]).get(relationshipFields[2]));
                        }else if(relationshipFields.size() == 4){
                            Object obj1 = content.getSObject(relationshipFields[0]);
                            
                            if (obj1 != null && obj1 instanceof SObject) {
                                SObject sObject1 = (SObject)obj1;
                                
                                Object obj2 = sObject1.getSObject(relationshipFields[1]);
                                
                                if (obj2 != null && obj2 instanceof SObject) {
                                    SObject sObject2 = (SObject)obj2;
                                    
                                    Object obj3 = sObject2.getSObject(relationshipFields[2]);
                                    
                                    if (obj3 != null && obj3 instanceof SObject) {
                                        SObject sObject3 = (SObject)obj3;
                                        
                                        Object fieldValue = sObject3.get(relationshipFields[3]);
                                        
                                        // Now you can add fieldValue to the map using val as the key
                                        data.put(val, (fieldValue != null) ? fieldValue.toString() : '');
                                    } else {
                                        // Handle the case where obj3 is null or not an SObject
                                        // You can log an error message or take other appropriate actions
                                    }
                                } else {
                                    // Handle the case where obj2 is null or not an SObject
                                    // You can log an error message or take other appropriate actions
                                }
                            } else {
                                // Handle the case where obj1 is null or not an SObject
                                // You can log an error message or take other appropriate actions
                            }
                            //data.put(val,(String)content.getSObject(relationshipFields[0]).getSObject(relationshipFields[1]).getSObject(relationshipFields[2]).get(relationshipFields[3]));
                        }else if(relationshipFields.size() == 5){
                            Object obj1 = content.getSObject(relationshipFields[0]);
                            
                            if (obj1 != null && obj1 instanceof SObject) {
                                SObject sObject1 = (SObject)obj1;
                                
                                Object obj2 = sObject1.getSObject(relationshipFields[1]);
                                
                                if (obj2 != null && obj2 instanceof SObject) {
                                    SObject sObject2 = (SObject)obj2;
                                    
                                    Object obj3 = sObject2.getSObject(relationshipFields[2]);
                                    
                                    if (obj3 != null && obj3 instanceof SObject) {
                                        SObject sObject3 = (SObject)obj3;
                                        
                                        Object obj4 = sObject3.getSObject(relationshipFields[3]);
                                        
                                        if (obj4 != null && obj4 instanceof SObject) {
                                            SObject sObject4 = (SObject)obj4;
                                            
                                            Object fieldValue = sObject4.get(relationshipFields[4]);
                                            
                                            // Now you can add fieldValue to the map using val as the key
                                            data.put(val, (fieldValue != null) ? fieldValue.toString() : '');
                                        } else {
                                            // Handle the case where obj4 is null or not an SObject
                                            // You can log an error message or take other appropriate actions
                                        }
                                    } else {
                                        // Handle the case where obj3 is null or not an SObject
                                        // You can log an error message or take other appropriate actions
                                    }
                                } else {
                                    // Handle the case where obj2 is null or not an SObject
                                    // You can log an error message or take other appropriate actions
                                }
                            } else {
                                // Handle the case where obj1 is null or not an SObject
                                // You can log an error message or take other appropriate actions
                            }
                            //data.put(val,(String)content.getSObject(relationshipFields[0]).getSObject(relationshipFields[1]).getSObject(relationshipFields[2]).getSObject(relationshipFields[3]).get(relationshipFields[4]));
                        }else if(relationshipFields.size() == 6){
                            Object obj1 = content.getSObject(relationshipFields[0]);
                            if (obj1 != null && obj1 instanceof SObject) {
                                SObject sObject1 = (SObject)obj1;
                                
                                Object obj2 = sObject1.getSObject(relationshipFields[1]);
                                
                                if (obj2 != null && obj2 instanceof SObject) {
                                    SObject sObject2 = (SObject)obj2;
                                    
                                    Object obj3 = sObject2.getSObject(relationshipFields[2]);
                                    
                                    if (obj3 != null && obj3 instanceof SObject) {
                                        SObject sObject3 = (SObject)obj3;
                                        
                                        Object obj4 = sObject3.getSObject(relationshipFields[3]);
                                        
                                        if (obj4 != null && obj4 instanceof SObject) {
                                            SObject sObject4 = (SObject)obj4;
                                            
                                            Object obj5 = sObject4.getSObject(relationshipFields[4]);
                                            
                                            if (obj5 != null && obj5 instanceof SObject) {
                                                SObject sObject5 = (SObject)obj5;
                                                
                                                Object fieldValue = sObject5.get(relationshipFields[5]);
                                                
                                                // Now you can add fieldValue to the map using val as the key
                                                data.put(val, (fieldValue != null) ? fieldValue.toString() : '');
                                            } else {
                                                // Handle the case where obj5 is null or not an SObject
                                                // You can log an error message or take other appropriate actions
                                            }
                                        } else {
                                            // Handle the case where obj4 is null or not an SObject
                                            // You can log an error message or take other appropriate actions
                                        }
                                    } else {
                                        // Handle the case where obj3 is null or not an SObject
                                        // You can log an error message or take other appropriate actions
                                    }
                                } else {
                                    // Handle the case where obj2 is null or not an SObject
                                    // You can log an error message or take other appropriate actions
                                }
                            } else {
                                // Handle the case where obj1 is null or not an SObject
                                // You can log an error message or take other appropriate actions
                            }
                            //data.put(val,(String)content.getSObject(relationshipFields[0]).getSObject(relationshipFields[1]).getSObject(relationshipFields[2]).getSObject(relationshipFields[3]).getSObject(relationshipFields[4]).get(relationshipFields[5]));   
                        }
                    }else{
                        data.put(val, String.valueOf(content.get(val)));
                        System.debug('Else val data '+ data);
                    }
                }
            }
            system.debug('***---return-Data '+data);
            return data;
        }Catch(Exception e){
            System.debug('**---error22 :'+ e.getLineNumber());
            System.debug('**---error22 :'+ e.getMessage());
            Map<String,String> mapOfStr = new Map<String,String>();
            String errMsg = e.getMessage();
            String errKey = 'errKey';//e.getMessage();
            mapOfStr.put(errKey, errMsg);
            return mapOfStr;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistOptions> getAllObjects(String objName) {
        List<PicklistOptions> fieldsList = new List<PicklistOptions>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            fieldsList.add(new PicklistOptions(objTyp.getDescribe().getLabel(), objTyp.getDescribe().getName()));
        }
        return fieldsList;
    }
    
    public class PicklistOptions implements Comparable {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
        public Integer compareTo(Object ObjToCompare) {
            return label.CompareTo(((PicklistOptions)ObjToCompare).label);
        }
    }
}