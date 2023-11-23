public class SampleController {
    public String outputData { get; set; }
    
    public SampleController() {
        outputData = ApexPages.currentPage().getParameters().get('outputDataParam');
    	System.debug('outputData : '+ outputData);
    }
}