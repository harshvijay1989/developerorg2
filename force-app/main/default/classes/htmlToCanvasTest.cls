@isTest
public class htmlToCanvasTest {
	
    @isTest
    private static void testHtmlToCanvas(){
        Test.startTest();
        htmlToCanvas htmlCanvasCls = new htmlToCanvas();
        htmlCanvasCls.handleUrl();
        Test.StopTest();
        //system.assert(htmlCanvasCls.orgBaseURL != '');
    }
}