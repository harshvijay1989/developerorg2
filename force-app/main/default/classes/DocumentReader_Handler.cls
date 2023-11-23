public class DocumentReader_Handler {
    public static Map<String, String> getAllFields(String data, String childObj) {
        System.debug('@@@data :' + data);
        Map<String, String> val = new Map<String, String>();
        data = data.trim();
        data = data.replaceAll('<p>', ' ');
        data = data.replaceAll('</p>', ' ');
        Boolean btn = false;
        
        String regexPattern = '\\{\\{\\{([^{}]+)}}}';
        System.Pattern myPattern = System.Pattern.compile(regexPattern);
        System.Matcher myMatcher = myPattern.matcher(data);
        try {
            // Find and process all matches
            while (myMatcher.find()) {
                String value = myMatcher.group(1).trim();
                System.debug('$#$#' + value);
                
                String starttemp = 'TableStarted___' + childObj;
                String endtemp = 'TableEnd___' + childObj;
                
                if (value.equalsIgnoreCase(starttemp)) {
                    btn = true;
                }
                if (!btn && (!value.equalsIgnoreCase(endtemp) && !value.equalsIgnoreCase(starttemp))) {
                    val.put('{{{' + value + '}}}', value);
                }
                if (value.equalsIgnoreCase(endtemp)) {
                    btn = false;
                }
            }
        } catch (Exception e) {
            System.debug('Exception caught: ' + e.getMessage());
            // Handle the exception as needed
        }
        return val;
    }
    
    public static Map<String,String> getChildAllFields(String data){
        system.debug('data 56Test '+data);
        Map<String,String> val = new Map<String,String>();
        data = data.trim();
        data = data.replaceAll('<p>',' ');
        data = data.replaceAll('</p>',' ');
        System.debug('Replaced data @@'+data);
        for(String str:data.split('<td>')){
            System.debug('$$$$$$'+str);
            str=str.trim();
            if(str.length()!=0){
                if(str.contains('{{{') || str.contains('}}}')){
                    try{
                        System.debug('Split str @@'+str); 
                        String value = str.substringBetween('{{{','}}}').trim();  
                        System.debug('Split value @@'+value);
                        val.put('{{{'+value+'}}}',value);
                    }catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }
            }
        }
        system.debug('val Chiled '+val);
        return val;
    }
    
    public static String getChildData(String data,String obj,String recordId){
        String finalData = '';
        if(data.length()!=0){
            System.debug(' getChildData '+data);
            
            if(data.contains('{{{TableStarted') && data.contains('{{{TableEnd')){
                try{
                    String childObjectName=data.substringBetween('{{{TableStarted___', '}}}');
                    System.debug('@@@ where'+childObjectName);
                    System.debug('Obj ## '+obj);
                    String value = data.substringBetween('{{{TableStarted','{{{TableEnd').trim();
                    
                    Map<String,String> columns = getChildAllFields(value);
                    
                    String ParentRelName=getSelectedObjectFields(obj,childObjectName);
                    String qury = 'SELECT '+String.join(columns.values(),',')+' FROM '+childObjectName+' WHERE '+ParentRelName+'  = \''+recordId+'\'';
                    System.debug('$$$$$'+qury);
                    List<sObject> childLst = Database.query(qury);
                    String table = getChildTable(columns.values(),childLst);
                    System.debug(' table get child data '+table);
                    finalData = data.substringBefore('{{{TableStarted')+table+data.substringAfter('{{{TableEnd___'+childObjectName+'}}}'); 
                    System.debug(' finalData get child data '+finalData);
                    return finalData; 
                }catch(Exception e){
                    return 'Error, '+ e.getMessage();
                    //System.debug(e.getMessage()+e.getLineNumber());
                }
            }    
        }
        return finalData;
    }
    
    //Gaurav Kumar Tiwari 17/07/2023
    //For Parent Or Child Data
    public static String getSelectedObjectFields(String selectedObject,String childObjName){
        SObjectField parentField;
        Schema.DescribeSObjectResult parentDescribe =Schema.getGlobalDescribe().get(selectedObject).getDescribe();
        for(ChildRelationship rel: parentDescribe.getChildRelationships()) {
            String relName=String.valueOf(rel.getChildSObject());
            if(relName== childObjName) {
                parentField = rel.getField();
                break;
            }
        }
        System.debug(parentField);
        return String.valueOf(parentField);
        
    }
    
    //Gaurav Kumar Tiwari 11/07/2023
    //For Parent Or Child Data
    public static Set<String> getParentObjectName(string objectName){
        Set<String> parentRelationShipObjectName=new Set<String>();  
        if(String.isNotEmpty(objectName)){
            for(Schema.SobjectField strFld: Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().Values()){
                if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                    List <Schema.SObjectType> fieldsList = strFld.getDescribe().getReferenceTo();
                    for (schema.SObjectType fieldRef : fieldslist )
                    {
                        parentRelationShipObjectName.add(String.valueOf(fieldRef));   
                    }      
                } 
            }
        }
        System.debug(parentRelationShipObjectName);
        return parentRelationShipObjectName;
        
    }
    public static Set<String> getChildRelationShipName(string objectName){
        Set<String> childRelationShipObjectName=new Set<String>();  
        Schema.DescribeSObjectResult parentDescribe =Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<Schema.ChildRelationship> childRelationships = parentDescribe.getChildRelationships();
        for (Schema.ChildRelationship childRelationship : childRelationships) {
            String childRelationshipName = childRelationship.getRelationshipName();
            if(String.isNotEmpty(childRelationshipName)){
                childRelationShipObjectName.add(childRelationshipName);
            }  
        }
        return childRelationShipObjectName;
    }
    
    // for create child record table
    public static String getChildTable(List<String> headerLst,List<Sobject> oliList){
        string table = '<table cellspacing="0" border="2" width="100%"><tbody>';
        table += '<tr style="border:1px solid black;>';
        table += '<tr style="border:1px solid black;>';
        for(integer i=0;i<headerLst.size();i++){
            table += '<th>'+headerLst[i]+'</th>';
        }
        table +='</tr>';
        for(Sobject item : oliList){
            table += '<tr>';
            for (String heading : headerLst) {
                String strtemp=(String.isNotEmpty(String.valueOf(item.get(heading))))?String.valueOf(item.get(heading)):'';
                table += '<td>' + strtemp + '</td>';
            }
            table += '</tr>';
        }
        table += '</tbody></table>';
        system.debug('table @#@# '+table);
        return table;
    }
    
    public static String bindParam(String content,Map<String,String> fields){
        for(String key:fields.keySet()){
            System.debug(fields.get(key));
            if(fields.get(key)!=NULL){
                content = content.replace(key, fields.get(key));
            }else{
                content = content.replace(key, ' ');
            } 
        }
        return content;
    }
    
}