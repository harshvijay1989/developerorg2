public class ProxyController {
    
    @AuraEnabled(cacheable=true)
    public static String getVFBaseURL() {
        String hostname = Url.getSalesforceBaseUrl().toExternalForm(); 
        String nameSpace = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
        List<String> orgURL = hostname.split('\\.');
        String vfPageUrl;
       System.debug('nameSpace : '+ nameSpace);
        if(nameSpace != '' && nameSpace != null){
             vfPageUrl = orgURL[0] +'--'+nameSpace + '.';//nameSpace
        }else{
            vfPageUrl = orgURL[0] + '--c.';
        }      
         
        if( orgURL[1] != null && !orgURL[1].equalsIgnoreCase('my.salesforce.com')){
            vfPageUrl += orgURL[1] + '.';
        }
        vfPageUrl += 'vf.force.com';       
        System.debug('vfPageUrl' + vfPageUrl);
        
        return vfPageUrl;
        	   
    }
    
    public static String getLightningDomainURL(){
        String hostName = Url.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '.lightning.force.com');
        return hostName;
    }
    
}