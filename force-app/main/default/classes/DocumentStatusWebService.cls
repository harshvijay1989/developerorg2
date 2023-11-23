@RestResource(urlMapping='/updatestatus/*')
global class DocumentStatusWebService {
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request; 
        Map<String,Object> mapOdData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
        String parentId = (String)mapOdData.get('recordId');
        String envelopeId = (String)mapOdData.get('envelopeId');
        String historyTrackerId = (String)mapOdData.get('HistoryTrackerId');
        System.debug('historyTrackerId :'+ historyTrackerId);
        If(historyTrackerId != null){
            History_Tracker__c htObj = [Select Id, Step__c from History_Tracker__c Where Id =: historyTrackerId];
            System.debug('htObj.step__c '+ htObj.step__c);
            update new History_Tracker__c(Id=historyTrackerId,Step__c = 4);
        }
        System.debug('envelopeId : '+ envelopeId);
        if(envelopeId != ''){
            try{
             	update new Envelope__c(Id=envelopeId,Is_Viewed__c=true);
                return 'success';
            }Catch(Exception e){
                return e.getMessage();
            }
        }else{
            Map<String,String> returnMap = new Map<String,String>();
            if(parentId.trim() == ''){
             	returnMap.put('parentId','Parent Id is blank.');   
            }
            if(envelopeId.trim() == ''){
             	returnMap.put('envelopeId','Envelope Id is blank.');
            }
            return JSON.serialize(returnMap);
        }
    }
}