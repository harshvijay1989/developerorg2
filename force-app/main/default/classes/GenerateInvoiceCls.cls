public class GenerateInvoiceCls {
    @AuraEnabled
    public static String generatePDF(Id recordId) {
        try {
            String invoiceNumber = 'INV-'+generateRandomString(6);
            // Generate PDF from Visualforce page
            PageReference pdfPage = Page.InvoiceOrderReceiptVF;
            pdfPage.getParameters().put('id', recordId); // Pass any necessary parameters
            
            Blob pdfBlob;
            pdfBlob = pdfPage.getContentAsPDF();
            
            // Create a new ContentVersion
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = invoiceNumber+'.pdf'; // Set the desired file name
            contentVersion.VersionData = pdfBlob;
            contentVersion.PathOnClient = invoiceNumber+'.pdf';
            contentVersion.FirstPublishLocationId = recordId; // Associate it with the Account
            
            insert contentVersion;
             

           Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;

           
  /*
//Create ContentDocumentLink 
ContentDocumentLink cdl = New ContentDocumentLink();
cdl.LinkedEntityId = recordId;
cdl.ContentDocumentId = conDocId;
cdl.shareType = 'V';
Insert cdl;*/
            updateOrder(invoiceNumber,recordId);
            
            return conDocId;
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }
    
    public static void updateOrder(String invoiceNumber,String orderId){
        try{
            if(orderId != NULL || orderId != ''){
             	update new Order__c(Id=orderId,Invoice_Generated__c=true,Invoice_Number__c=invoiceNumber);   
            }
        }Catch(Exception e){
            System.debug('e: '+e.getMessage());
        }
    }
    
    private static String generateRandomString(Integer length) {
        String validChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randomString = '';
        
        for (Integer i = 0; i < length; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), validChars.length());
            randomString += validChars.substring(randomIndex, randomIndex + 1);
        }
        
        return randomString;
    }
}