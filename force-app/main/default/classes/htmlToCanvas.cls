public class htmlToCanvas {
 
    public String orgBaseURL { get; private set; }
    
    public void handleUrl(){     
             orgBaseURL = ProxyController.getLightningDomainURL();
           
        }   
}