public with sharing class TestingController {
    // This controller handles the data parameter passed to the Visualforce page

    public String data { get; set; }

    public TestingController() {
        // Retrieve the data parameter and convert it to a Blob
        ContentVersion con = [SELECT Id, Title, FileType, VersionData, ContentDocument.Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId = '0Q01m000000CtO0CAK' limit 1];

        Blob pdfURL = con.VersionData; //ApexPages.currentPage().getParameters().get('data');
        data = pdfURL != null ? pdfURL.toString() : '';
        System.debug('data : '+ data);
    }
}