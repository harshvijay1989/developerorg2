public with sharing class FileUploadController {
    @AuraEnabled
    public static List<List<String>> processCSVFile(Id parentId, String fileContents) {
        System.debug('parentId==>' + parentId);
        System.debug('fileContents==>' + fileContents);
        
        List<List<String>> csvData = new List<List<String>>();
        try {
            List<String> rows = fileContents.split('\n');
            
            // Start the loop from the second row (index 1) to skip the header row
            for (Integer i = 1; i < rows.size(); i++) {
                String row = rows[i];
                List<String> columns = new List<String>();
                String[] values = row.split(',');
                columns.addAll(values);
                csvData.add(columns);
            }
            
        } catch (Exception e) {
            System.debug('Error processing CSV: ' + e.getMessage());
            // Handle the exception, e.g., return an error message
            return null;
        }
        System.debug('csvData==>' + csvData);
        
        return csvData;
    }
    
    @AuraEnabled
    public static String saveDataToApex(List<List<String>> csvData) {
        System.debug('csvData==>' + csvData);
        
        return 'Data saved successfully';
    }
    
}