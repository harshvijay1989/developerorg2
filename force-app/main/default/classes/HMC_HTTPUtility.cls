/**
* @Class Name:  HMC_HTTPUtility 
* @Description: HMC_HTTPUtility 
* @Author:      Developer Name (Neeraj Sethi) (Date - 10/15/2021)
* @TestClass:   
* @History
* 10/15/2021    Developer Name (Neeraj Sethi) | 
*/

public class HMC_HTTPUtility{
    public static HTTPResponse sendRequestAX(String apiName,String requestBody){
        System.debug('Request body ->' + requestBody);
        System.debug('API Name->' + apiName);
        HMC_Endpoint__mdt axObj = HMC_Endpoint__mdt.getInstance(apiName);
        System.debug('axObj'+axObj);
        String token = HMC_AXTokenResponse.getToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(axObj.Endpoint__c);
        System.debug(axObj.Endpoint__c);
        request.setMethod(axObj.Method__c);
        request.setTimeout(120000);
        request.setHeader('content-type','application/json');
        request.setHeader('Authorization','Bearer ' + token);
        request.setBody(requestBody);
        System.debug('Token'+token);
        HttpResponse response = http.send(request);
        System.debug('Response2'+response.getBody());
        return response;        
    }
}