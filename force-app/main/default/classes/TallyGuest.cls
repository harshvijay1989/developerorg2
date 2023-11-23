@RestResource(urlMapping='/createAccounts/*')
global  class TallyGuest {
    
    @HttpPost
    global static String createAccounts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Voucher__c> vchListnew = [Select id,Gu_Id__c from Voucher__c];
        
        Map<String,String> vchMap = new Map<String,String>();
        system.debug('vchMap'+vchMap);
        for (Voucher__c vchObj : vchListnew){
            system.debug('vchObj.Gu_Id__c'+vchObj.Gu_Id__c);
            if(vchObj.Gu_Id__c != null){
                vchMap.put(vchObj.Gu_Id__c,vchObj.Id);
            }
        }
        try { 
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            system.debug('requestData'+requestData);
            if (requestData.containsKey('VCHS')) {
                Map<String, Object> ledgersData = (Map<String, Object>) requestData.get('VCHS');
                if (ledgersData.containsKey('VCH')) {
                    List<Object> ledgerList = (List<Object>) ledgersData.get('VCH');
                    List<Voucher__c> vchListUpdate = new List<Voucher__c>();
                    List<Voucher__c> vchListInsert = new List<Voucher__c>();
                    Set<String> strList = new Set<String>();
                    
                    if (!ledgerList.isEmpty()) {
                        for (Object ledgerItem : ledgerList) {
                            Map<String, Object> item = (Map<String, Object>) ledgerItem;
                            Integer VchNumber = Integer.valueof(item.get('VoucherNumber'));
                            String VchType = String.valueOf(item.get('VoucherType'));
                            String partyName = String.valueOf(item.get('PartyName'));
                            String TypeName = String.valueOf(item.get('TypeName'));
                            Double Amount = Double.valueof(item.get('Amount'));
                            Integer Quantity = Integer.valueof(item.get('Quantity'));
                            String GuId = String.valueOf(item.get('Guid'));
                            String CompanyName = String.valueOf(item.get('CompanyName'));
                            strList.add(CompanyName);
                            //Date dates = Date.valueof(item.get('Date'));
                            if(vchMap.containsKey(GuId)){
                                system.debug('Inside'+vchMap.get(GuId));
                                Voucher__c vch = new Voucher__c();
                                vch.Id = vchMap.get(GuId);
                                vch.VoucherNumber__c = VchNumber;
                                vch.PartyName__c = partyName;
                                vch.VoucherType__c = VchType;
                                vch.TypeName__c =TypeName;
                                vch.Amount__c = Amount;
                                vch.Quantity__c = Quantity;
                                vch.Source__c = 'Excel';
                                vch.Company_Name__c = CompanyName;
                                // Vch.Date__c = dates;
                                vchListUpdate.add(vch);
                            }else if(!vchMap.containsKey(GuId)) {
                                system.debug('Inside Insert');
                                Voucher__c vchinsert = new Voucher__c();
                                vchinsert.VoucherNumber__c = VchNumber;
                                vchinsert.PartyName__c = partyName;
                                vchinsert.VoucherType__c = VchType;
                                vchinsert.TypeName__c =TypeName;
                                vchinsert.Amount__c = Amount;
                                vchinsert.Quantity__c = Quantity;
                                vchinsert.Gu_Id__c = GuId;
                                vchinsert.Source__c = 'Tally';
                                vchinsert.Company_Name__c = CompanyName;
                                // Vch.Date__c = dates;
                                vchListInsert.add(vchinsert);
                            }
                        }
                        List<Account> accList = [Select id from Account where Name =:strList];
                        Voucher_Data__c vchObj = new Voucher_Data__c();
                        vchObj.Account__c = accList[0].id ;
                        vchObj.Source__c = 'Tally';
                        insert vchObj;
                        if (!vchListUpdate.isEmpty()) {
                            for(Voucher__c vcObj: vchListUpdate){vcObj.Voucher_Data__c = vchObj.id ;}
                            Update vchListUpdate;
                        }
                        if(!vchListInsert.isEmpty()){
                            for(Voucher__c vcObj: vchListInsert){vcObj.Voucher_Data__c = vchObj.id ;}
                            insert vchListInsert;
                        }
                    }
                }
            }
            return 'Accounts created successfully.';
        } catch (Exception e) {
            res.statusCode = 400; // Bad Request
            return 'Error: ' + e.getMessage();
        }
    }
}