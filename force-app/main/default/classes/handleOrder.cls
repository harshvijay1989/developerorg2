public class handleOrder {
    public static void handleOrderchange(List<Voucher__c> vchList){
         List<String> guidList = new List<String>();
        List<String> nameList = new List<String>();
        for (Voucher__c vch : vchList){
            if (vch.Gu_Id__c != null){
                guidList.add(vch.Gu_Id__c);
                nameList.add(vch.PartyName__c);
            }
        }
        if(!guidList.isEmpty()){
            Map<String,Id> ordMap = new Map<String,Id>();
            Map<String,Id> accMap = new Map<String,Id>();
            List<Order> toUpdate = new List<Order>();
            List<Order> toInsert = new List<Order>();
            List<Account> accList = [Select id, Name from Account where Name in :nameList ];
            for (Account accObj : accList){
                accMap.put(accObj.Name,accObj.Id);
            }
            List<RecordType> orderRecordType = [Select id,developername from RecordType where DeveloperName = 'Secondry_Sales'];
            List<Order> ordList = [Select id,Guid__c from Order where Guid__c in :guidList ];
            List<Contract> contractList = [Select id from Contract Limit 1];
            for (Order ordObj : ordList){
                ordMap.put(ordObj.Guid__c,ordObj.Id);
            }
            for(Voucher__c vchObj : vchList){
                if(ordMap.containsKey(vchObj.Gu_Id__c)){
                    order ord = new Order();
                    ord.Id = ordMap.get(vchObj.Gu_Id__c);
                    ord.AccountId = accMap.get(vchObj.PartyName__c);
                    ord.Amount__c = vchObj.Amount__c;
                    ord.Quantity__c = vchObj.Quantity__c;
                    ord.VoucherNumber__c = vchObj.VoucherNumber__c;
                    ord.VoucherType__c = vchObj.VoucherType__c;
                    ord.OwnerId = '0055j00000A4WAAAA3';
                    toUpdate.add(ord);
                    
                }else if (!ordMap.containsKey(vchObj.Gu_Id__c)){
                    order ord = new Order();
                   // ord.ContractId = contractList[0].id;
                    ord.Guid__c = vchObj.Gu_Id__c;
                    ord.RecordTypeId = orderRecordType[0].id;
                    ord.AccountId = accMap.get(vchObj.PartyName__c);
                    ord.Amount__c = vchObj.Amount__c;
                    ord.Quantity__c = vchObj.Quantity__c;
                    ord.VoucherNumber__c = vchObj.VoucherNumber__c;
                    ord.VoucherType__c = vchObj.VoucherType__c;
                    ord.Status = 'Draft';
                    ord.OwnerId = '0055j00000A4WAAAA3';
                    ord.EffectiveDate = system.today();
                    toInsert.add(ord);
                }
            }
            if(!toInsert.isEmpty()){
                Insert toInsert;
            }
            if(!toUpdate.isEmpty()){
                Update toUpdate;
            }
        }
    }

        
}