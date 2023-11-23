public class extractTextFromDocxCtrl {
    @AuraEnabled(cacheable=false)
    public static boolean uploadDocument(String documentStoreId) {
        System.debug('@@@documentStoreId : '+ documentStoreId);
        String documentId;
        Document_Store__c doc = New Document_Store__c();
        doc.Mached_Data__c = 'Upload Document File';
        Insert doc;
        ContentVersion cvDocFile1 = new ContentVersion();
        cvDocFile1.Title = 'Upload Document File';
        cvDocFile1.PathOnClient = 'Upload Document File.doc';
        cvDocFile1.VersionData = Blob.valueOf(documentStoreId);
        cvDocFile1.IsMajorVersion = false;
        cvDocFile1.FirstPublishLocationId = doc.id;
        insert cvDocFile1;
        return true;
    }

    private static final String ENDPOINT_URL = 'https://jkj9ylbhqe.execute-api.ap-south-1.amazonaws.com/dev';
    
    @AuraEnabled
    public static boolean extractTextFromDocx(String base64FileData) {
        System.debug('Hello');
        // Create an HTTP request
        System.debug('@@@ base64FileData : '+ base64FileData);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_URL);
        request.setMethod('POST');
        String jsonBody = '{"base64code":"' + base64FileData + '"}';
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody;
        if (response.getStatusCode() == 200) {
            responseBody = response.getBody();
            System.debug('API Response: ' + responseBody);
            String[] textPatternsToRemove = new String[]{
                'Evaluation Only\\. Created with Aspose\\.Words\\. Copyright 2003-2023 Aspose Pty Ltd\\.',
                    'Created with an evaluation copy of Aspose\\.Words\\. To discover the full versions of our APIs please visit: https://products\\.aspose\\.com/words/'
                    };
                        for (String pattern : textPatternsToRemove) {
                            responseBody = responseBody.replaceAll(pattern, '');
                        }
            System.debug('Main responseBody : '+ responseBody);
            responseBody = responseBody.replace('src=\\"', 'src="');
			responseBody = responseBody.replace('\\"', '"'); 
            responseBody = responseBody.replaceAll('<table', '<table border="1"');
            
            responseBody = responseBody.replaceAll('\"<html', '<html');
			responseBody = responseBody.replaceAll('/html>"', '/html>');
            Integer startIndex = responseBody.indexOf('<img');
            if (startIndex >= 0) {
                Integer endIndex = responseBody.indexOf('>', startIndex);
                // Remove the first <img> tag
                if (endIndex >= 0) {
                    responseBody = responseBody.substring(0, startIndex) + responseBody.substring(endIndex + 1);
                }
            }
            
        } 
        System.debug('Final responseBody  :'+ responseBody);
        return true;
    }
}