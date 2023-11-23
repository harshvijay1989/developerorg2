public class AccountOrderHandle {
    
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
                vc.Company_Name__c = csvRowData[0];
                vc.PartyName__c = csvRowData[1];
                vc.VoucherNumber__c = Decimal.ValueOf(csvRowData[2]);
                vc.VoucherType__c=csvRowData[3];               
                vc.Amount__c = Decimal.ValueOf(csvRowData[4]); 
                vc.Quantity__c= Decimal.ValueOf(csvRowData[5]);
                vc.Gu_Id__c=csvRowData[6];
                Vclist.add(vc);
                system.debug('Vclist'+Vclist);
            }
        } 
        return Vclist;    
    }
    
    @AuraEnabled
    public static void insertCSVFile(list<Voucher__c> accList,Id recordId){
        system.debug('on save button recordId'+recordId);
        system.debug('on save button accList'+accList);

        List<Voucher_Data__c> vchDataList = new List<Voucher_Data__c>();
        Voucher_Data__c vchObj = new Voucher_Data__c();
        vchObj.Account__c = recordId ;
        vchObj.Source__c = 'Excel';
        insert vchObj;
        for (Voucher__c vcl : accList){
            vcl.Voucher_Data__c = vchObj.id;
            vcl.Source__c = 'Excel';
        } 
        try{    
            if(!accList.isEmpty()) {
                upsert accList Gu_Id__c;
            }
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }   
    }
    @AuraEnabled
    public static void insertrecord(list<Voucher__c> accList,Id recordId){
        try{
            List<Voucher_Data__c> vchDataList = new List<Voucher_Data__c>();
            Voucher_Data__c vchObj = new Voucher_Data__c();
            vchObj.Account__c = recordId ;
            insert vchObj;
            for (Voucher__c vcl : accList){
                vcl.Voucher_Data__c = vchObj.id;
                vcl.Source__c = 'Excel';
            } 
            try{    
                if(!accList.isEmpty()) {
                    upsert accList Gu_Id__c;
                }
            }
            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } 
            if(!accList.isEmpty()){
                //HandleAccount.handleParentAccount(accList);
                HandleAccount.handleChildAccount(accList);
                handleOrder.handleOrderchange(accList);
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