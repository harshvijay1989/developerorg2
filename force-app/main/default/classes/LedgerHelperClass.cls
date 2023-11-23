public class LedgerHelperClass {
    @AuraEnabled
    Public static WrapperClass  getLedgerData(Date startDate, Date endDate){//,string dmsAndSalesRepreName
        
       
        WrapperClass objWrapWire = new WrapperClass(); 
        User us = [SELECT Id, name,AccountId,Account.HMC_Dealer_Code__c	 from user Where Id =: UserInfo.getUserId()];//UserInfo.getUserId() //0051e000002xntXAAQ
        
        List<Account> accListCurrentUser = [SELECT id,Name,HMC_Dealer_Code__c	,Opening_Balance__c FROM Account WHERE Id =: us.AccountId];
        objWrapWire.currentDealerList = accListCurrentUser; 
        
        if(startDate != null && endDate != null){	
            
            List<Ledger__c> ledgerList = new List<Ledger__c>();
            
            if(startDate != null && endDate != null  ){
                system.debug('startDate>>>>>>'+startDate);
                system.debug('endDate>>>>>>'+endDate);
                ledgerList = [SELECT id,Debit_Note__c,Credit_Note__c,Sales_Organisation__c,Accumulated_Balance__c,Invoice_Dr_Cr_Number__c,Description_Narration__c,
                              Profit_Center__c,Account__c,Amount_in_local_Currency__c,Document_Number__c, Assignment__c,Clearing_Document__c, Document_Date__c,
                              Document_Type__c, Local_Currency__c,Special_G_L_Ind__c, Text__c, Posting_Date__c,Customer__c,Account__r.Name 
                              FROM Ledger__c 
                             WHERE  Posting_Date__c >= : startDate AND Posting_Date__c <=: endDate  and Account__r.Id != null
                              order by Posting_Date__c];
                system.debug('ledgerList@196=>'+ledgerList);
                
                Decimal openingBalance =accListCurrentUser[0].Opening_Balance__c;
                
                if(openingBalance != null){
                    objWrapWire.openingBalance = openingBalance;
                }
                
                if(ledgerList != null){
                    system.debug('ledgerList@215=>'+ledgerList);
                    objWrapWire.ledgerDataList = ledgerList;
                    system.debug('ledgerList@217=>'+ledgerList);
                    
                    Decimal closingBalance = 0.0;
                    system.debug('ledgerList@220=>'+ledgerList);
                    for(Ledger__c ledger: ledgerList){
                        if(ledger.Amount_in_local_Currency__c != null){
                            closingBalance = closingBalance + ledger.Amount_in_local_Currency__c;
                        }
                    }
                    //objWrapWire.openingBalance = LedgerOpeningBalance.currentUserOpeningBalance();
                    objWrapWire.closingBalance = closingBalance;
                }
            }
        }
        
        return objWrapWire;
    }
    @AuraEnabled
    Public static WrapperClass getLedgerFilterData(Date startDate, Date endDate,String accDealerId,String customerIsAll,String salesOrganisation){//String salesRepresentativeSelectDealer
        
        WrapperClass objWrapWire = new WrapperClass(); 
        User us = [SELECT Id, name,AccountId,Account.HMC_Dealer_Code__c	 from user Where Id =: UserInfo.getUserId()];//UserInfo.getUserId() //0051e000002xntXAAQ
        
        List<Account> accListCurrentUser = [SELECT id,Name,HMC_Dealer_Code__c	,Opening_Balance__c FROM Account WHERE Id =: us.AccountId];
        objWrapWire.currentDealerList = accListCurrentUser; 
        
        if(startDate != null && endDate != null){	
            
            List<Ledger__c> ledgerList = new List<Ledger__c>();
            
            if(startDate != null && endDate != null  ){
                system.debug('startDate>>>>>>'+startDate);
                system.debug('endDate>>>>>>'+endDate);
                system.debug('salesOrganisation@@177'+salesOrganisation);
                ledgerList = [SELECT id,Debit_Note__c,Credit_Note__c,Sales_Organisation__c,Accumulated_Balance__c,Invoice_Dr_Cr_Number__c,Description_Narration__c,
                              Profit_Center__c,Account__c,Amount_in_local_Currency__c,Document_Number__c, Assignment__c,Clearing_Document__c, Document_Date__c,
                              Document_Type__c, Local_Currency__c,Special_G_L_Ind__c, Text__c, Posting_Date__c,Customer__c,Account__r.Name 
                              FROM Ledger__c 
                             WHERE  Posting_Date__c >= : startDate AND Posting_Date__c <=: endDate  and Account__r.Id != null
                              order by Posting_Date__c];
                system.debug('ledgerList@196=>'+ledgerList);
                
                Decimal openingBalance =accListCurrentUser[0].Opening_Balance__c;
                
                if(openingBalance != null){
                    objWrapWire.openingBalance = openingBalance;
                }
                
                if(ledgerList != null){
                    system.debug('ledgerList@215=>'+ledgerList);
                    objWrapWire.ledgerDataList = ledgerList;
                    system.debug('ledgerList@217=>'+ledgerList);
                    
                    Decimal closingBalance = 0.0;
                    system.debug('ledgerList@220=>'+ledgerList);
                    for(Ledger__c ledger: ledgerList){
                        if(ledger.Amount_in_local_Currency__c != null){
                            closingBalance = closingBalance + ledger.Amount_in_local_Currency__c;
                        }
                    }
                    //objWrapWire.openingBalance = LedgerOpeningBalance.currentUserOpeningBalance();
                    objWrapWire.closingBalance = closingBalance;
                }
            }
        }
        
        return objWrapWire;
    }
    public class WrapperClass {
        
        @AuraEnabled
        public List<Ledger__c> ledgerDataList;
        @AuraEnabled
        public List<Account> accDealerList;
        @AuraEnabled
        public Decimal openingBalance;
        @AuraEnabled
        public Decimal closingBalance;
        @AuraEnabled
        public List<Account> accSubDealerList;
        @AuraEnabled
        public List<String> accumulatedList;
        @AuraEnabled
        public List<Account> currentDealerList;
        
    }
}