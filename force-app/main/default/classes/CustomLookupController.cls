public without sharing class CustomLookupController {
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        System.debug('searchTerm'+searchTerm);
        System.debug('myObject'+myObject);
        System.debug('filter'+filter);
        
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
            
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> searchRoute(String searchTerm, string myObject, String filter) {
        System.debug('searchTerm'+searchTerm);
        System.debug('myObject'+myObject);
        System.debug('filter'+filter);
        
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}