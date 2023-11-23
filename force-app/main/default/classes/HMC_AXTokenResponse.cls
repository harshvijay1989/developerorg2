/**
* @Class Name:  HMC_AXTokenResponse 
* @Description: HMC_AXTokenResponse - 
* @Author:      Developer Name (Neeraj Sethi) (Date - 10/15/2021)
* @TestClass:   
* @History
* 10/15/2021    Developer Name (Neeraj Sethi) | 
*/
global virtual class HMC_AXTokenResponse {
    global String status; 
    global String Accesstoken;
    global String Desciption;
    global String statusCode;
    
    public class LoginWrapper{
        public String UserName;
        public String password;
    }
    
    public static String getToken() {
        if(String.isBlank(HMC_Constants.AX_TOKEN)){
            HMC_Endpoint__mdt axObj = HMC_Endpoint__mdt.getInstance('AX_Token_Credentials');
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(axObj.Endpoint__c);
            request.setMethod(axObj.Method__c);
            request.setHeader('content-type','application/json');
            
            LoginWrapper loginObj = new LoginWrapper();
            loginObj.userName = axObj.UserName__c;
            loginObj.password = axObj.password__c;
            
            String reqBody = JSON.serialize(loginObj);
            request.setBody(reqBody);
            
            HttpResponse response = http.send(request);
            HMC_AXTokenResponse resObj = (HMC_AXTokenResponse)System.JSON.deserialize(response.getbody(),HMC_AXTokenResponse.class);
            HMC_Constants.AX_TOKEN = resObj.Accesstoken;
            System.debug('HMC_AXTokenResponse'+response.getbody());
         }
        System.debug('HMC_Constants.AX_TOKEN'+HMC_Constants.AX_TOKEN);
         return HMC_Constants.AX_TOKEN;
    }
}