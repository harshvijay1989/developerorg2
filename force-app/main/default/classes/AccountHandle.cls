public class AccountHandle {
    @AuraEnabled
    public static list<Voucher__c> readCSVFile(Id idContentDocument){
        
        List<Voucher__c> Vclist = new list<Voucher__c>();///new
        
        
        if(idContentDocument != null) {
            
            // getting File Data based on document id 
            
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            
            // split the file data
            
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
            
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                
                Voucher__c vc = new Voucher__c();
                list<String> csvRowData = lstCSVLines[i].split(',');
                System.debug('csvRowData====> '+csvRowData);
                vc.Company_Name__c =csvRowData[0];
                vc.PartyName__c =csvRowData[1];
               vc.VoucherNumber__c=11;  //csvRowData[2];
                vc.VoucherType__c=csvRowData[3];               
                vc.Quantity__c=23; //csvRowData[4];
                vc.Gu_Id__c=csvRowData[5];
                
                
              
                
                Vclist.add(vc);
                system.debug('Vclist'+Vclist);
                
            }
            
        } 
        
        return Vclist;    
        
    }
    
    @AuraEnabled
    public static void insertCSVFile(list<Account> accList){
        
        system.debug('accList'+accList);
        
        try{    
            
            if(!accList.isEmpty()) {
                
                insert accList;
                
                system.debug('accList'+accList);
                
            }
            
        }
        
        catch (Exception ex) {
            
            throw new AuraHandledException(ex.getMessage());
            
        }     
        
    }
    
    
    @AuraEnabled
    public static void documentIdapx(Id idContentDocument){
        
        system.debug('idContentDocument'+idContentDocument);
        
        List<contentdocument> clist =[SELECT Id FROM contentdocument WHERE Id =:idContentDocument ];
        
        system.debug('clist'+clist);
        
        delete clist;
        
    }
    
}