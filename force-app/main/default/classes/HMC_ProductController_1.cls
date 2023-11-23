public without sharing class HMC_ProductController_1 {
    
    @AuraEnabled
    public static Order__c getOptyinfo(String opportunityId) {
        Id orderRecordType = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Order').getRecordTypeId();
        return [select id, Name, Account__r.HMC_BU_Type__c, Account__r.HMC_Account_Selection__c, Account__r.HMC_Dealer_Code__c, HMC_Order_Submitted__c, Account__r.Name, Account__r.HMC_Credit_Limit__c, Account__c from Order__c where id =: opportunityId];
    }
    @AuraEnabled
    public static HMC_ProductDataWrapper getProductInformation(String opportunityId) {
        Id OLIRecordType = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Order Line Item').getRecordTypeId();
        List <Order__c> orderList = [select id,Scheme__c,Scheme__r.Product_Type__c,Name,Account__r.HMC_COCO_Store__c, Account__r.RecordType.Name, Account__r.HMC_BU_Type__c, Account__r.HMC_Account_Selection__c, Account__r.HMC_Dealer_Code__c, HMC_Order_Submitted__c, Account__r.Name, Account__r.HMC_Credit_Limit__c, Account__c from Order__c where id =: opportunityId limit 1];
        list <HMC_ProductDataWrapper.ProductTypeOptionWrapper> productTypeList = new list <HMC_ProductDataWrapper.ProductTypeOptionWrapper> ();
        list <HMC_OLIWrapper> existingOLIList = new list <HMC_OLIWrapper> ();
        list <HMC_Price_Master__c> priceMaster = new list <HMC_Price_Master__c> ();
        Map <String, PricebookEntry> mapOfProductIdVsPricebookEntry = new Map <String, PricebookEntry> ();
        Map <String, String> mapOfProductIdVsFileId = new Map <String, String> ();
        Map <String, Set <String>> mapOfModelandAICMA = new Map <String, Set <String>> ();
        Map <String, List <String>> mapOfModelandAICMAList = new Map <String, List <String>> ();
        Map <String, String> mapOfPriceMaster = new Map <String, String> ();
        
        List <Product2__c> lstOfProduct = new List <Product2__c>(); /*= [Select Id, Name, HMC_Model__c,Tax_Percentage__c, HMC_AICMA__c, BusinessUnitType__c, Type__c, ProductCode__c FROM Product2__c where
                                        IsActive__c = true
                                       ];*/
        
        if(orderList[0].Scheme__c != NULL && orderList[0].Scheme__r.Product_Type__c != NULL){
            lstOfProduct = [Select Id, Name, HMC_Model__c,Tax_Percentage__c, HMC_AICMA__c, BusinessUnitType__c, Type__c, ProductCode__c FROM Product2__c where 
                            IsActive__c = true AND HMC_AICMA__c = :orderList[0].Scheme__r.Product_Type__c
                           ];
        }else{
            lstOfProduct = [Select Id, Name, HMC_Model__c,Tax_Percentage__c, HMC_AICMA__c, BusinessUnitType__c, Type__c, ProductCode__c FROM Product2__c where
                            IsActive__c = true
                           ];
        }
        
        System.debug('lstOfProduct: '+lstOfProduct);
        List<Order__c> lstOptyOfAcc = [SELECT Id from Order__c where Account__c =: orderList[0].Account__c AND Id !=: orderList[0].Id];
        productTypeList.add(new HMC_ProductDataWrapper.ProductTypeOptionWrapper('', 'Choose One'));
        productTypeList.add(new HMC_ProductDataWrapper.ProductTypeOptionWrapper('CKD', 'CKD'));
        productTypeList.add(new HMC_ProductDataWrapper.ProductTypeOptionWrapper('SKD', 'SKD'));
        if (orderList != null && orderList.size()> 0 && orderList[0].account__r.HMC_BU_Type__c == 'hero') {
            productTypeList.add(new HMC_ProductDataWrapper.ProductTypeOptionWrapper('Loose', 'Loose'));
        }
        HMC_ProductDataWrapper dataWrapper = new HMC_ProductDataWrapper();
        if (orderList[0].Account__r.Recordtype.Name == 'Retail' || (orderList[0].Account__r.HMC_Dealer_Code__c != '' && orderList[0].Account__r.HMC_Dealer_Code__c != null)) {
            
            dataWrapper.productTypeList = productTypeList;
            dataWrapper.objOfOpportunity = orderList[0];
            
            if (lstOptyOfAcc.size() <= 3) {
                
                dataWrapper.finalnote = 'Kindly collect 100% advance payment';
            }
            String returnval = getCreditLimit(opportunityId);
            System.debug('Debug value : '+ returnval);
            
            if (returnval == 'Error') {
                dataWrapper.creditLimt = '0.0';
            } else {
                dataWrapper.creditLimt = returnval;
            }
            ContentDocumentLink link = new ContentDocumentLink();
            //link = [SELECT ContentDocument.title, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = '006C30000000dkXIAQ'];
            for (Order__c oli: [select id, Product__c, Product__r.Family__c, Product__r.Name, Product__r.ProductCode__c,Product__r.Tax_Percentage__c, Quantity__c, List_Price__c, UnitPrice__c, HMC_MODEL__c, AICMA__c, Discount__c, TotalPrice__c, HMC_Dealer_Price__c,Base_Price__c,HMC_MRP__c,Net_Amount__c,Total_Discount__c,Offer_Description__c,Discount_Type__c ,  Distributer_Discount__c ,  DP_Discount__c ,  MRP_Discount__c ,  Customer_Group__c , Area_Id__c from Order__c where Order__c =: opportunityId AND RecordTypeId = :OLIRecordType]) {
                HMC_OLIWrapper oliWrap = new HMC_OLIWrapper();
                oliWrap.listPrice = oli.UnitPrice__c;
                oliWrap.quantity = String.valueOf(oli.Quantity__c);
                oliWrap.product = new product2__c(id = oli.Product__c, Name = oli.Product__r.Name, ProductCode__c = oli.Product__r.ProductCode__c , Tax_Percentage__c = oli.Product__r.Tax_Percentage__c);
                oliWrap.productType = oli.Product__r.Family__c;
                //System.debug('oli.Product2.Tax_Percentage__c'+oli.Product2.Tax_Percentage__c);
                //oliWrap.priceBookEntry = new PricebookEntry(id = oli.priceBookEntryId);
                oliWrap.productId = oli.Product__c;
                oliWrap.model = oli.HMC_MODEL__c;
                oliWrap.AICMA = oli.AICMA__c;
                oliWrap.TotalPrice = String.valueOf(oli.TotalPrice__c);
                oliWrap.RetaillistPrice = oli.HMC_Dealer_Price__c;
                //Added K-MRP
                //oliWrap.MRP = String.valueOf(oli.HMC_MRP__c);
                oliWrap.BasePrice = String.valueOf(oli.Base_Price__c);//
                oliWrap.NetAmount = String.valueOf(oli.Net_Amount__c);
                oliWrap.OfferDescription = oli.Offer_Description__c;
                // add
                oliWrap.DiscountType = oli.Discount_Type__c;
                oliWrap.DistributerDiscount = oli.Distributer_Discount__c;
                oliWrap.DPDiscount = oli.DP_Discount__c;
                oliWrap.MRPDiscount = oli.MRP_Discount__c;
                oliWrap.CustomerGroup = oli.Customer_Group__c;
                oliWrap.AreaId = oli.Area_Id__c;
                //oliWrap.Tax = oli.Tax__c;
                oliWrap.TotalDiscount = String.valueOf(oli.Total_Discount__c);
                oliwrap.lstProductsFilter = new List <Product2__c> {
                    oliWrap.product
                        };
                            if (oli.Discount__c != null) {
                                oliWrap.Disount = String.valueOf(oli.Discount__c);
                            } else {
                                oliWrap.Disount = String.valueOf('');
                            }
                /* if(mapOfProductIdVsFileId.containsKey(oli.Product2Id)){
oliWrap.fileId = mapOfProductIdVsFileId.get(oli.Product2Id);
} */
                system.debug('link.ContentDocumentId'+link.ContentDocumentId);
                /* for(ContentDocumentLink cdl : [SELECT ContentDocument.title, ContentDocumentId FROM ContentDocumentLink]){
if(){

}
}*/
                oliWrap.fileId = HMC_ProductController_1.HMCItemImages(oli.Product__r.ProductCode__c);
                // oliWrap.fileId = link.ContentDocumentId;
                //oliWrap.priceBookEntryId = oli.priceBookEntryId;
                //if(mapOfModelandAICMAList.containsKey(oliWrap.model))
                oliWrap.AICMAList = new Set <String> {
                    oli.AICMA__c
                        };
                            oliWrap.models = new List <String> {
                                oli.HMC_MODEL__c
                                    };
                                        existingOLIList.add(oliWrap);
            }
            dataWrapper.mapOfProductIdVsFileId = mapOfProductIdVsFileId;
            dataWrapper.mapOfProductIdVsPricebookEntry = mapOfProductIdVsPricebookEntry;
            dataWrapper.exisintingOLIList = existingOLIList;
            dataWrapper.lstOfProduct = lstOfProduct;
            dataWrapper.DealerCodeNotPresent = false;
            System.debug('dataWrapper:::::' + dataWrapper);
            //return dataWrapper;
        } else {
            dataWrapper.DealerCodeNotPresent = true;
            //return dataWrapper;
        }
        System.debug('dataWrapper'+dataWrapper);
        return dataWrapper;
    }
    
    @AuraEnabled
    public static void createOLI(String opportunityId, String cliJson) {
        Id OLIRecordType = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Order Line Item').getRecordTypeId();
        System.debug('cliJson' + cliJson);
        System.debug('opportunityId' + opportunityId);
        List <HMC_OLIWrapper> oliWrapperList = (List <HMC_OLIWrapper> ) JSON.deserialize(cliJson, List <HMC_OLIWrapper> .class);
        System.debug('oliWrapperList' + oliWrapperList);
        Order__c oppRec = [SELECT ID,Account__c FROM Order__c WHERE ID =: opportunityId LIMIT 1];
        Account accRec = [SELECT ID, HMC_Dealer_Code__c FROM Account WHERE ID=:oppRec.Account__c LIMIT 1];
        List<JSONWrapper> lstProductData = new List<JSONWrapper>();
        for(HMC_OLIWrapper Data :oliWrapperList ){
            for(Product2__c prodRec : Data.lstProductsFilter){
                JSONWrapper wrapp = new JSONWrapper();
                wrapp.DealerCode = accRec.HMC_Dealer_Code__c;
                wrapp.ProductCode = prodRec.ProductCode__c;
                lstProductData.add(wrapp);
            }
        }
        
        List <OpportunityLineItem> existingOLiList = [Select id from OpportunityLineItem where OpportunityId =: opportunityId];
        if (existingOLiList.size()> 0) {
            delete existingOLiList;
        }
        List <Order__c> OLIList = new List <Order__c> ();
        integer lineItemCount = 1;
        Decimal TotalAmount = 0;
        for (HMC_OLIWrapper oliWrap: oliWrapperList) {
            Order__c lineItem = new Order__c();
            lineItem.RecordTypeId = OLIRecordType;
            lineItem.Quantity__c = Decimal.valueOf(oliWrap.Quantity);
            lineItem.Order__c = opportunityId;
            if(oliWrap.Tax == null){
                lineItem.UnitPrice__c = Decimal.valueOf(oliWrap.BasePrice) ;           // Standard function
            }else {
                lineItem.UnitPrice__c = Decimal.valueOf(oliWrap.BasePrice)  + (Decimal.valueOf(oliWrap.BasePrice) * (Decimal.valueOf(oliWrap.Tax)/100));           // Standard function
            }
            //lineItem.UnitPrice = oliWrap.RetaillistPrice;
            //lineItem.PricebookEntryId = oliWrap.priceBookEntryId;
            lineItem.Product__c = oliWrap.productId;
            lineItem.HMC_MODEL__c = oliWrap.model;
            lineItem.AICMA__c = oliWrap.AICMA;
            ////      lineItem.HMC_Dealer_Price__c = oliWrap.RetaillistPrice;
            lineItem.Item_Number__c = lineItemCount;
            //Added K-MRP
            //lineItem.HMC_MRP__c = Decimal.valueOf(oliWrap.MRP);
            lineItem.Base_Price__c = Decimal.valueOf(oliWrap.BasePrice);
            
            // lineItem.TotalPrice = Decimal.valueOf(oliWrap.NetAmount) * Decimal.valueOf(oliWrap.Quantity);   /// change 14-06-2022
            lineItem.Net_Amount__c = Decimal.valueOf(oliWrap.NetAmount);
            TotalAmount += Decimal.valueOf(oliWrap.NetAmount);
            lineItem.Offer_Description__c = oliWrap.OfferDescription;
            
            lineItem.Discount_Type__c = oliWrap.DiscountType;
            lineItem.Distributer_Discount__c = oliWrap.DistributerDiscount;
            lineItem.DP_Discount__c = oliWrap.DPDiscount;
            lineItem.MRP_Discount__c = oliWrap.MRPDiscount;
            lineItem.Customer_Group__c = oliWrap.CustomerGroup;
            lineItem.Area_Id__c = oliWrap.AreaId;
            if(oliWrap.product.Tax_Percentage__c != null){
                lineItem.Tax__c = oliWrap.product.Tax_Percentage__c; 
            }
            
            if (!String.isBlank(oliWrap.TotalDiscount)) {
                lineItem.Total_Discount__c = Decimal.valueOf(oliWrap.TotalDiscount);
                lineItem.Discount__c = Decimal.valueOf(oliWrap.TotalDiscount);
                //lineItem.UnitPrice = oliWrap.listPrice * (1-(lineItem.Discount)/100);
            }
            lineItemCount++;
            OLIList.add(lineItem);
        }
        Order__C Ord = [Select id,HMC_Invoice_Amount__c ,HMC_Order_Number__c,name, HMC_Payment_Amount__c from order__c where Id =: opportunityId];
        ord.HMC_Invoice_Amount__c = TotalAmount;
        ord.HMC_Payment_Amount__c = TotalAmount;
        Ord.HMC_Order_Number__c = 'ORD-O3728'+Ord.name;
        update ord; 
        List <Order__c> OLIListDeleat = new List <Order__c> (); 
        OLIListDeleat = [Select id from order__c where order__c =:opportunityId ];
        if (OLIList.size()> 0) {
            Delete OLIListDeleat;
            insert OLIList;
        }
    }
    @AuraEnabled
    public static List <Product2__c> fetchProduct(String opportunityId) {
        List <Order__c> opportunityList = [select id, Name, account__r.HMC_BU_Type__c from Order__c where id =: opportunityId];
        List <Product2__c> returnList = new List <Product2__c> ();
        List <Product2__c> lstOfProduct = [select id, Name, HMC_MODEL__c, Family__c, HMC_AICMA__c,IsActive__c from product2__c  Order by Name/*WHERE HMC_BusinessUnitType__c = :opportunityList[0].account.HMC_BU_Type__c*/ ];
        for (Product2__c Prod: lstOfProduct) {
            returnList.add(Prod);
        }
        return returnList;
    }
    @AuraEnabled
    public static HMC_AXCreateOrderHandler.reponse getorder(String opportunityId) {
        HTTPResponse response = HMC_AXCreateOrderHandler.createOrder(Id.valueOf(opportunityId));
        system.debug('response'+response.getbody());
        String jsonbody = response.getbody();
        HMC_AXCreateOrderHandler.reponse res = new HMC_AXCreateOrderHandler.reponse();
        res = (HMC_AXCreateOrderHandler.reponse) json.deserialize(jsonbody, HMC_AXCreateOrderHandler.reponse.class);
        system.debug('res+res+res+res'+res);
        
        if (res.Status == 'SUCCESS') {
            // Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Order_Confirm').getRecordTypeId();
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
            system.debug('OrderSizeM()'+HMC_AXCreateOrderHandler.OrderSizeM());
            Order__c orderupdate = new Order__c(Id = opportunityId, HMC_Order_Submitted__c = true, recordTypeId = oppRecordTypeId, StageName__c = 'Pushed to ERP', HMC_Order_Pushed_to_ERP_Date__c = System.today() , Total_ERP_Orders__c = HMC_AXCreateOrderHandler.OrderSizeM() );
            UPDATE orderupdate;
        }
        system.debug('returnres'+res);
        return res;
    }
    
    @AuraEnabled
    public static priceMaster getPriceMaster(String opportunityId, String productId) {
        List <Order__c> opportunityList = [select id, Name, Account__r.HMC_BU_Type__c, Account__r.HMC_Account_Selection__c, Account__r.HMC_Dealer_Code__c, Account__r.HMC_Line_Discount__c from Order__c where id =: opportunityId];
        Product2__c prod = [SELECT Id, ProductCode__c, HMC_Dealer_Price__c, HMC_Price__c from product2__c where Id =: productId AND IsActive__c = true];
        list <HMC_Price_Master__c> priceMasters = new list <HMC_Price_Master__c> ();
        list <HMC_Price_Master__c> priceMasterDisc = new list <HMC_Price_Master__c> ();
        Map <String, priceMaster> mapOfProductIdVsPricebookEntry = new Map <String, priceMaster> ();
        Map <String, List <HMC_Price_Master__c>> mapOfPriceMaster = new Map <String, List <HMC_Price_Master__c>> ();
        Map <String, String> mapOfCodePrice = new Map <String, String> ();
        Map <String, String> mapOfGroupDisc = new Map <String, String> ();
        priceMaster masterWrapper = new priceMaster();
        ContentDocumentLink link;
        try {
            //sales price
            //if(Test.isRunningTest()){
            //link = [SELECT ContentDocument.title, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = '006C30000000dkXIAQ'];
            //}
            link = new ContentDocumentLink();
            Date todaydate = System.today();
            priceMasters = [SELECT Id,HMC_Max_Retail_Price__c, HMC_Account_Selection__c, HMC_Item__c, HMC_From_Date__c, HMC_Amount_in_transaction_currency__c, HMC_Account_Code__c, HMC_Dealer_Code__c, HMC_To_Date__c FROM HMC_Price_Master__c WHERE HMC_Relation__c = 'Price (sales)'
                            AND HMC_Item__c =: prod.ProductCode__c
                           ];
            if (!priceMasters.isEmpty()) {
                for (HMC_Price_Master__c master: priceMasters) {
                    if (mapOfPriceMaster.containskey(master.HMC_Item__c)) {
                        mapOfPriceMaster.get(master.HMC_Item__c).add(master);
                    } else {
                        mapOfPriceMaster.put(master.HMC_Item__c, new List < HMC_Price_Master__c > {
                            master
                                });
                    }
                }
                
                for (String code: mapOfPriceMaster.keySet()) {
                    String tableVal = '';
                    String groupVal = '';
                    String allVal = '';
                    
                    String tableValFrom = '';
                    String groupValFrom = '';
                    String allValFrom = '';
                    
                    Date fromRecent = Date.newInstance(1, 1, 1);
                    System.debug(code+'master.mapOfPriceMaster' + mapOfPriceMaster.keySet());
                    for (HMC_Price_Master__c master: mapOfPriceMaster.get(code)) {
                        System.debug('master.HMC_To_Date__c' + master.HMC_To_Date__c);
                        if (master.HMC_To_Date__c != null) {
                            System.debug('master.HMC_Account_Code__c' + master.HMC_Account_Code__c);
                            if (master.HMC_Account_Code__c == 'Table' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Dealer_Code__c && (master.HMC_From_Date__c < todaydate && master.HMC_To_Date__c > todaydate)) {
                                tableVal = String.valueOf(master.HMC_Amount_in_transaction_currency__c) + '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                            } else if (master.HMC_Account_Code__c == 'Group' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Account_Selection__c && (master.HMC_From_Date__c < todaydate && master.HMC_To_Date__c > todaydate)) {
                                groupVal = String.valueOf(master.HMC_Amount_in_transaction_currency__c)+ '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                            } else if (master.HMC_Account_Code__c == 'All' && (master.HMC_From_Date__c < todaydate && master.HMC_To_Date__c > todaydate)) {
                                allVal = String.valueOf(master.HMC_Amount_in_transaction_currency__c) + '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                            }
                            System.debug('allVal' + allVal);
                        } else {
                            if (master.HMC_From_Date__c < todaydate) {
                                if (master.HMC_From_Date__c >= fromRecent) {
                                    if (master.HMC_Account_Code__c == 'Table' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Dealer_Code__c) {
                                        tableValFrom = String.valueOf(master.HMC_Amount_in_transaction_currency__c)+ '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                                    } else if (master.HMC_Account_Code__c == 'Group' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Account_Selection__c) {
                                        groupValFrom = String.valueOf(master.HMC_Amount_in_transaction_currency__c)+ '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                                    } else if (master.HMC_Account_Code__c == 'All') {
                                        allValFrom = String.valueOf(master.HMC_Amount_in_transaction_currency__c)+ '__' + String.valueOf(master.HMC_Max_Retail_Price__c);
                                    }
                                    fromRecent = master.HMC_From_Date__c;
                                }
                            }
                        }
                    }
                    if (tableVal != '') {
                        mapOfCodePrice.put(code, tableVal);
                    } else if (groupVal != '') {
                        mapOfCodePrice.put(code, groupVal);
                    } else if (allVal != '') {
                        mapOfCodePrice.put(code, allVal);
                    } else if (tableValFrom != '') {
                        mapOfCodePrice.put(code, tableValFrom);
                    } else if (groupValFrom != '') {
                        mapOfCodePrice.put(code, groupValFrom);
                    } else if (allValFrom != '') {
                        mapOfCodePrice.put(code, allValFrom);
                    }
                    System.debug(mapOfCodePrice.values() + 'mapOfCodePrice' + mapOfCodePrice.keySet());
                }
            }
            // discount
            
            //Enable discount Code
            
            priceMasterDisc = [SELECT Id, HMC_Item_Code__c, HMC_Account_Selection__c, HMC_Item__c, HMC_From_Date__c, HMC_Amount_in_transaction_currency__c, HMC_Account_Code__c, HMC_Dealer_Code__c, HMC_To_Date__c, HMC_Discount_Percentage__c FROM HMC_Price_Master__c WHERE
                               HMC_Product__c =: productId
                              ];
            //(HMC_Dealer_Code__c =: opportunityList[0].Account.HMC_Dealer_Code__c OR HMC_Account_Selection__c =: opportunityList[0].Account.HMC_Line_Discount__c) or HMC_Item_Code__c = 'All'];
           // for (pricebookEntry entry: [select id, product2Id, Pricebook2ID, unitPrice, product2.ProductCode, product2__r.HMC_Discount_Group__c from pricebookEntry where Pricebook2.isStandard = true AND product2Id =: productId]) {
                //priceMaster masterWrapper = new priceMaster();
              //  System.debug(mapOfCodePrice.get(entry.product2.ProductCode)+'entryentryentry+' + entry);
              /*  if (mapOfCodePrice.containskey(entry.product2.ProductCode)) {
                    List<String> value= mapOfCodePrice.get(entry.product2.ProductCode).split('__');
                    masterWrapper.UnitPrice = value[0];
                    masterWrapper.RetailUnitPrice = value[1];
                }
                System.debug('priceMasterDisc' + priceMasterDisc);
                System.debug('priceMasterDiscsssssssssss' + priceMasterDisc.Size());*/
                Decimal tableTableVal = 0.0;
                Decimal tableGroupVal = 0.0;
                Decimal tableAllVal = 0.0;
                
                Decimal groupTableVal = 0.0;
                Decimal groupGroupVal = 0.0;
                Decimal groupAllVal = 0.0;
                
                Decimal allTableVal = 0.0;
                Decimal allGroupVal = 0.0;
                Decimal allAllVal = 0.0;
                for (HMC_Price_Master__c master: priceMasterDisc) {
                    System.debug('master.HMC_Account_Code__c' + master.HMC_Account_Code__c);
                    System.debug('master.HMC_Item_Code__c' + master.HMC_Item_Code__c);
                    System.debug('master.HMC_Item__c' + master.HMC_Item__c);
                   // System.debug('entry.product2.ProductCode' + entry.product2.ProductCode);
                    //for table as a Account Code
                    if (master.HMC_Account_Code__c == 'Table' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Dealer_Code__c && master.HMC_Item_Code__c == 'Table' && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        tableTableVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'Table' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Dealer_Code__c && master.HMC_Item_Code__c == 'Group'  && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        tableGroupVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'Table' && master.HMC_Account_Selection__c == opportunityList[0].Account__r.HMC_Dealer_Code__c && master.HMC_Item_Code__c == 'All' && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        tableAllVal = master.HMC_Discount_Percentage__c;
                    }
                    //for group as a Account Code
                    if (master.HMC_Account_Code__c == 'Group' && master.HMC_Item_Code__c == 'Table'  && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        groupTableVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'Group' && master.HMC_Item_Code__c == 'Group'  && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        groupGroupVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'Group' && master.HMC_Item_Code__c == 'All' && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        groupAllVal = master.HMC_Discount_Percentage__c;
                    }
                    //for all as a Account Code
                    if (master.HMC_Account_Code__c == 'All' && master.HMC_Item_Code__c == 'Table'  && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        allTableVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'All' && master.HMC_Item_Code__c == 'Group'  && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        allGroupVal = master.HMC_Discount_Percentage__c;
                    }
                    if (master.HMC_Account_Code__c == 'All' && master.HMC_Item_Code__c == 'All' && (master.HMC_From_Date__c <todaydate && master.HMC_To_Date__c> todaydate)) {
                        allAllVal = master.HMC_Discount_Percentage__c;
                    }
                }
                
                if (tableTableVal != 0.0) {
                    masterWrapper.discount = String.valueOf(tableTableVal);
                } else if (tableGroupVal != 0.0) {
                    masterWrapper.discount = String.valueOf(tableGroupVal);
                } else if (tableAllVal != 0.0) {
                    masterWrapper.discount = String.valueOf(tableAllVal);
                } else if (groupTableVal != 0.0) {
                    masterWrapper.discount = String.valueOf(groupTableVal);
                } else if (groupGroupVal != 0.0) {
                    masterWrapper.discount = String.valueOf(groupGroupVal);
                } else if (groupAllVal != 0.0) {
                    masterWrapper.discount = String.valueOf(groupAllVal);
                } else if (allTableVal != 0.0) {
                    masterWrapper.discount = String.valueOf(allTableVal);
                } else if (allGroupVal != 0.0) {
                    masterWrapper.discount = String.valueOf(allGroupVal);
                } else if (allAllVal != 0.0) {
                    masterWrapper.discount = String.valueOf(allAllVal);
                }
                Product2__c stockAvailable = [Select Id, stock_available__c,ProductCode__c from Product2__c where Id =: productId];
                if (stockAvailable != null) {
                    if (stockAvailable.stock_available__c>= 1 && stockAvailable.stock_available__c <= 10) {
                        masterWrapper.StockAvailable = 'Error';
                    } else if (stockAvailable.stock_available__c> 10 && stockAvailable.stock_available__c <= 25) {
                        masterWrapper.StockAvailable = 'Warning';
                    } else if (stockAvailable.stock_available__c == 0) {
                        masterWrapper.StockAvailable = 'Zero';
                    } else {
                        masterWrapper.StockAvailable = 'Success';
                    }
                    masterWrapper.StockAvailable = 'Success';
                    masterWrapper.discount = '10';
                    System.debug('stockAvailable' + stockAvailable);
                    System.debug('ssssssssssss' + masterWrapper.StockAvailable);
                }
                System.debug('masterWrapper.discount+' + masterWrapper.discount);
                //masterWrapper.UnitPrice = String.valueOf(prod.HMC_Price__c);
                //masterWrapper.RetailUnitPrice = String.valueOf(prod.HMC_Dealer_Price__c);
                //masterWrapper.priceBookEntry = entry;
                //masterWrapper.priceBookEntryId = entry.Id;
                masterWrapper.FileId = HMC_ProductController_1.HMCItemImages(stockAvailable.ProductCode__c);
                //if (link != null)
                    // masterWrapper.FileId = link.ContentDocumentId;
                   // mapOfProductIdVsPricebookEntry.put(entry.product2Id, masterWrapper);
                //}
                
          //  }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return masterWrapper;
    }
    
    public class priceMaster {
        @AuraEnabled public String discount {
            get;
            set;
        }
        @AuraEnabled public priceBookEntry priceBookEntry {
            get;
            set;
        }
        @AuraEnabled public String priceBookEntryId {
            get;
            set;
        }
        @AuraEnabled public String finalAmount {
            get;
            set;
        }
        @AuraEnabled public String UnitPrice {
            get;
            set;
        }
        @AuraEnabled public String RetailUnitPrice {
            get;
            set;
        }
        @AuraEnabled public String FileId {
            get;
            set;
        }
        @AuraEnabled public String StockAvailable {
            get;
            set;
        }
    }
    
    /* should get live credit limit of Dealer
Need to update Credit Limit on Dealer once API started working*/
    @AuraEnabled
    public static string getCreditLimit(String recordId) {
        String returnVal = '';
        try {
            String CreditLimit = '200000';
            //HTTPResponse res = HMC_AXCreateOrderHandler.CreditLimitOfDealer(Id.valueOf(recordId));
            //String jsonbody = res.getbody();
           // HMC_AXCreateOrderHandler.creditlimitresponse resonse = new HMC_AXCreateOrderHandler.creditlimitresponse();
            //resonse = (HMC_AXCreateOrderHandler.creditlimitresponse) json.deserialize(jsonbody, HMC_AXCreateOrderHandler.creditlimitresponse.class);
            if (CreditLimit != '' && CreditLimit != null) {
                List <Order__c> opportunityList = [select id, Name, Account__c from Order__c where id =: recordId];
                returnVal = String.valueOf(CreditLimit);
                Account orderupdate = new Account(Id = opportunityList[0].Account__c, HMC_Credit_Limit__c = Integer.valueOf(CreditLimit));
                UPDATE orderupdate;
            }
        } catch (Exception e) {
            returnVal = 'Error';
            throw new AuraHandledException(e.getMessage());
        }
        return returnVal;
    }
    /*@AuraEnabled
    public static opportunity getAddress(String recordId) {
        //  String AccountId = [Select Id,AccountId from Opportunity where Id =: recordId].AccountId;
        return [Select Id, Shipping_City__c, Shipping_Country__c, Shipping_Pincode__c, Shipping_State__c, Shipping_Street__c from Opportunity where Id =: recordId];
        // return [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Primary__c = true AND Account__c =: AccountId];
    }*/
    @AuraEnabled
    public static Account getAddress(String recordId) {
        System.debug('getAddress Method called...');
        String AccountId = [Select Id, Account__c from Order__c where Id =: recordId].Account__c;
        System.debug('AccountId: '+AccountId);
        return [Select Id, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet from Account where Id =: AccountId];
        // return [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Primary__c = true AND Account__c =: AccountId];
    }
    @AuraEnabled
    public static Account getBillingAddress(String recordId) {
        String AccountId = [Select Id, Account__c from Order__c where Id =: recordId].Account__c;
        return [Select Id, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet from Account where Id =: AccountId];
        // return [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Primary__c = true AND Account__c =: AccountId];
    }
    @AuraEnabled
    public static List <Order__c> getOppLineItems(String recordId) {
        Decimal total = 0;
        List <Order__c> quoLineItemList = [select id, Product__c, Product__r.name, Quantity__c, TotalPrice__c,Net_Amount__c, discount__c , Total_Discount__c,Base_Price__c, HMC_MRP__c from Order__c where Order__c =: recordId];
        for (Order__c item: quoLineItemList) {
            if (item.Net_Amount__c != null) {
                total = total + item.Net_Amount__c;
            }
        }
        return quoLineItemList;
    }
    
    @AuraEnabled
    public static List <Product2__c> getProductBySku(String sku) {
        String searchString = '%' + sku + '%';
        //String searchString = sku;
        List <Product2__c> lstprods = new List <Product2__c> ();
        try {
            lstprods = [SELECT Id, ProductCode__c, Name, Type__c, HMC_AICMA__c, HMC_MODEL__c, HMC_Price__c from Product2__c where (ProductCode__c LIKE: searchString OR Name LIKE: searchString) AND IsActive__c = true];
            system.debug('lstprods'+lstprods);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstprods;
    }
    
    @AuraEnabled
    public static Map <Id, priceMaster> getPriceForSku(List <Sobject> prodlst, String opportunityId) {
        Map <Id, priceMaster> mapOfIdPrice = new Map <Id, priceMaster> ();
        system.debug('prodlst'+prodlst);
        try {
            for (SObject prod: prodlst) {
                mapOfIdPrice.put(String.valueOf(prod.Id), getPriceMaster(opportunityId, String.valueOf(prod.Id)));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mapOfIdPrice;
    }
    /*@AuraEnabled
    public static List <HMC_Address__c> getHMCAddress(String recId) {
        system.debug('ID====' + recId);
        //recId =  '0060l00000MgI5VAAV';
        List <Opportunity> AccountId = [Select Id, AccountId from Opportunity where Id =: recId];
        set <id> ids = new set <id> ();
        for (Opportunity s: AccountId) {
            ids.add(s.AccountId);
        }
        system.debug('getHMCAddress' + ids);
        List <HMC_Address__c> lstAddresses = [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Type__c = 'Ship'
                                              AND Account__c =: ids
                                             ];
        return lstAddresses;
    }
    
    @AuraEnabled
    public static List <HMC_Address__c> getAddressHMC(String recordId) {
        String AccountId = [Select Id, AccountId from Opportunity where Id =: recordId].AccountId;
        //  return [Select Id, Shipping_City__c, Shipping_Country__c, Shipping_Pincode__c,Shipping_State__c, Shipping_Street__c from Opportunity where Id =: recordId];
        return [SELECT Id, IsDeleted, City__c, State__c, Street__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Primary__c = true AND Account__c =: AccountId];
    }
    
    @AuraEnabled
    public static String SaveAddressHMC(String recordId, String AddId) {
        system.debug('Test save address');
        // String AccountId = [Select Id,AccountId from Opportunity where Id =: recordId].AccountId;
        if (AddId != null) {
            HMC_Address__c hmcAddress = [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Id =: AddId];
            if (hmcAddress != null) {
                Opportunity opp = new Opportunity();
                opp.Id = recordId;
                opp.Shipping_City__c = hmcAddress.City__c;
                opp.Shipping_Country__c = hmcAddress.Country__c;
                opp.Shipping_Pincode__c = hmcAddress.pincode__c;
                opp.Shipping_State__c = hmcAddress.State__c;
                update opp;
            }
        }
        return 'Success';
    }
    @AuraEnabled
    public static void createHMCAddress(String recordId, String City, String State, String Country, String Pincode, String Street) {
        system.debug('ID====' + recordId);
        List <Opportunity> AccountId = [Select Id, AccountId from Opportunity where Id =: recordId];
        
        Order__c opp = new Order__c();
        opp.Id = recordId;
        opp.Shipping_City__c = City;
        opp.Shipping_Country__c = Country;
        opp.Shipping_Pincode__c = Pincode;
        opp.Shipping_State__c = State;
        opp.Shipping_Street__c = Street;
        
        update opp;
        
        List <HMC_Address__c> addLst = new List <HMC_Address__c> ();
        
        for (Opportunity s: AccountId) {
            HMC_Address__c addrs = new HMC_Address__c();
            addrs.Account__c = s.AccountId;
            addrs.City__c = City;
            addrs.Country__c = Country;
            addrs.State__c = State;
            addrs.pincode__c = Pincode;
            addrs.Street__c = Street;
            
            addrs.Type__c = 'Ship';
            addrs.Primary__c = true;
            addLst.add(addrs);
        }
        system.debug('addLst===' + addLst);
        if (!addLst.isEmpty()) {
            //insert addLst;
        }
        
    }
    @AuraEnabled
    public static void showHMCAddress(String recordId, string selectAddress) {
        system.debug('ID====' + recordId);
        //recordId =  '0060l00000MgI5VAAV';
        List <Opportunity> AccountId = [Select Id, AccountId from Opportunity where Id =: recordId];
        System.debug('AccountId' + AccountId);
        set <id> ids = new set <id> ();
        for (Opportunity s: AccountId) {
            ids.add(s.AccountId);
        }
        System.debug('ids' + ids);
        system.debug('getHMCAddress' + ids);
        
        List <HMC_Address__c> lstAddresses = [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where Primary__c = true AND Type__c = 'Ship'
                                              AND Account__c =: ids
                                             ];
        List <HMC_Address__c> addLst = new List <HMC_Address__c> ();
        System.debug('lstAddresses' + lstAddresses);
        If(lstAddresses != null) {
            for (HMC_Address__c add: lstAddresses) {
                System.debug('add' + add);
                HMC_Address__c addrs = new HMC_Address__c();
                addrs.id = add.id;
                addrs.Primary__c = false;
                addLst.add(addrs);
            }
            
            system.debug('addLst===' + addLst);
            if (!addLst.isEmpty()) {
                Update addLst;
            }
        }
        List <HMC_Address__c> lstAddresses1 = [SELECT Id, IsDeleted, City__c, State__c, Country__c, pincode__c, Primary__c, Type__c, Account__c FROM HMC_Address__c where id =: selectAddress];
        List <HMC_Address__c> addLst1 = new List <HMC_Address__c> ();
        for (HMC_Address__c add: lstAddresses1) {
            HMC_Address__c addrs1 = new HMC_Address__c();
            addrs1.id = add.Id;
            addrs1.Primary__c = true;
            addLst1.add(addrs1);
        }
        system.debug('addLst1===' + addLst1);
        if (!addLst1.isEmpty()) {
            Update addLst1;
        }
        
    }
    */
    @AuraEnabled
    public static String genaratePdf(String OrderId) {
        String returnstr = 'Success';
        System.debug('OrderId   ' + OrderId);
        PageReference reportPage = new Pagereference('/apex/HMC_OrderPreview?Id=' + OrderId); //Page.HMC_OrderPreview;
        //reportPage.getParameters().put('email', 'gauravkumartiwari937@gmail.com');
        Blob body;
        List<Opportunity> oppLst = [select id,name,account.name,account.HMC_Contact_Email__c from Opportunity where id = :OrderId];
        try {
            body = reportPage.getContentAsPDF(); //reportPage.getContent();
        } catch (VisualforceException e) {
            returnstr = 'Failure';
            body = Blob.valueOf(e.getMessage());
        }
        System.debug('Body of pdf' + body);
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('testPdf.pdf');
        attach.setInline(false);
        attach.Body = body;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        if(oppLst[0].account.HMC_Contact_Email__c != null){
            mail.setToAddresses(new String[] {
                oppLst[0].account.HMC_Contact_Email__c
                    });
        }else{
            List<contact> contLst = [select id,email from contact where accountid = : oppLst[0].accountId and email != null];
            if(contLst.isEmpty()){
                returnstr = 'Failure';
            }else{
                mail.setToAddresses(new String[] {
                    contLst[0].email
                        });
            }
        }
        mail.setSubject('HMC Quote for '  + oppLst[0].name);
        mail.setHtmlBody('Dear Dealer,' + '<br/>' + 'Kindly find the quote attached.');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {
            attach
                });
        // Send the email    
        if(returnstr != 'Failure'){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
                    });
        }
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF sent to '+'udaykiran629@gmail.com'));
        return returnstr;
        
    }
     @AuraEnabled
    public static List<HMC_OLIWrapper> HMC_ProductGetDiscount(String opportunityId, String cliJson){
        List<HMC_OLIWrapper> HMC_OLIWrapperList = new List<HMC_OLIWrapper>();
        List<SFInstance> SFInstanceList = new List<SFInstance>();
        System.debug('cliJson : ' + cliJson);
        List <HMC_OLIWrapper> oliWrapperList = (List <HMC_OLIWrapper> ) JSON.deserialize(cliJson, List <HMC_OLIWrapper> .class);
        System.debug('oliWrapperList : ' + oliWrapperList);
        Order__c oppRec = [SELECT ID,Account__c FROM Order__c WHERE ID =: opportunityId LIMIT 1];
        Account accRec = [SELECT ID, HMC_Dealer_Code__c FROM Account WHERE ID=:oppRec.Account__c LIMIT 1];
        Set<String> ProductCodeSet = new Set<String>();
        List<JSONWrapper> lstProductData = new List<JSONWrapper>();
        for(HMC_OLIWrapper Data :oliWrapperList ){
            JSONWrapper wrapp = new JSONWrapper();
            ProductCodeSet.add(Data.product.ProductCode__c);
            wrapp.DealerCode = accRec.HMC_Dealer_Code__c;
            wrapp.ProductCode = Data.product.ProductCode__c;
            lstProductData.add(wrapp);
        }
       
       List<Product2__c> ListOfProduct = new List<Product2__c>();
        ListOfProduct = [select id,HMC_Price__c,ProductCode__c from Product2__c where BusinessUnitType__c = 'firefox' AND ProductCode__c =:ProductCodeSet];
            //String jsonString = String.valueOf( JSON.deserializeUntyped(response.getBody()) );
            System.debug(SFInstanceList);
            for(Product2__c obj : ListOfProduct){
                for(HMC_OLIWrapper Data :oliWrapperList ){
                    //system.debug('Data.product.ProductCode'+Data.product.ProductCode);
                    system.debug('Data.product.Tax_Percentage__c'+Data.product.Tax_Percentage__c);
                    if(Data.product.ProductCode__c == obj.ProductCode__c){
                        Data.BasePrice = String.valueof(obj.HMC_Price__c);
                        //Added K-MRP
                        //Data.MRP = String.valueOf(5000.00);
                       
                        Data.NetAmount = String.valueOf(Decimal.valueof(Data.quantity) * Decimal.valueOf(Data.BasePrice));
                        if(String.isNotBlank(Data.NetAmount)){
                            Decimal netAmount = Decimal.valueOf(Data.NetAmount);
                            if(String.isNotBlank(Data.TotalDiscount)){
                                Decimal dis = Decimal.valueOf(Data.TotalDiscount);
                                netAmount -= ((netAmount/100)*dis).setScale(2);
                            }
                            System.debug('Data.NetAmount'+netAmount);
                            system.debug('Tax_Percentage__c'+Data.product.Tax_Percentage__c);
                            if(Data.product.Tax_Percentage__c != null)
                                netAmount += ((netAmount/100)*Data.product.Tax_Percentage__c).setScale(2);
                            if(netAmount != null)
                                Data.NetAmount = String.valueOf(netAmount);
                            Data.DPDiscount = '10';
                            Data.TotalDiscount = '10';
                            System.debug('Data.NetAmount'+Data.NetAmount);
                        }
                    }
                }
            }
        return oliWrapperList;
    }/*
    @AuraEnabled
    public static List<HMC_OLIWrapper> HMC_ProductGetDiscount(String opportunityId, String cliJson){
        List<HMC_OLIWrapper> HMC_OLIWrapperList = new List<HMC_OLIWrapper>();
        List<SFInstance> SFInstanceList = new List<SFInstance>();
        System.debug('cliJson : ' + cliJson);
        List <HMC_OLIWrapper> oliWrapperList = (List <HMC_OLIWrapper> ) JSON.deserialize(cliJson, List <HMC_OLIWrapper> .class);
        System.debug('oliWrapperList : ' + oliWrapperList);
        Opportunity oppRec = [SELECT ID,AccountID FROM Opportunity WHERE ID =: opportunityId LIMIT 1];
        Account accRec = [SELECT ID, HMC_Dealer_Code__c FROM Account WHERE ID=:oppRec.AccountID LIMIT 1];
        List<JSONWrapper> lstProductData = new List<JSONWrapper>();
        for(HMC_OLIWrapper Data :oliWrapperList ){
            JSONWrapper wrapp = new JSONWrapper();
            wrapp.DealerCode = accRec.HMC_Dealer_Code__c;
            wrapp.ProductCode = Data.product.ProductCode;
            lstProductData.add(wrapp);
        }
        HMC_Endpoints__mdt axObj = HMC_Endpoints__mdt.getInstance('AX_Get_Discount');
        system.debug('axObj.Endpoint__c'+axObj.Endpoint__c);
        //JSON.serialize();
        String Token = HMC_AXTokenResponse.getToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(axObj.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer'+' '+Token);
        // Set the body as a JSON object
        system.debug('lstProductData'+JSON.serialize(lstProductData));
        request.setBody(JSON.serialize(lstProductData));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                         response.getStatusCode() + ' ' + response.getStatus());
            System.debug(response.getBody());
        } else {
            //String jsonString = String.valueOf( JSON.deserializeUntyped(response.getBody()) );
            SFInstanceList = (List<SFInstance>) System.JSON.deserialize(response.getBody(), List<SFInstance>.class);
            System.debug(SFInstanceList);
            for(SFInstance obj : SFInstanceList){
                for(HMC_OLIWrapper Data :oliWrapperList ){
                    system.debug('Data.product.ProductCode'+Data.product.ProductCode);
                    system.debug('Data.product.Tax_Percentage__c'+Data.product.Tax_Percentage__c);
                    if(Data.product.ProductCode == obj.ProductCode){
                        if(obj.OfferDescription == null || obj.OfferDescription == ''){
                            Data.OfferDescription = 'Offer Not Available';
                        }else{
                            Data.OfferDescription = obj.OfferDescription;
                        }
                        Data.BasePrice = obj.BasePrice;
                        //Added K-MRP
                        //Data.MRP = String.valueOf(5000.00);
                        Data.TotalDiscount = obj.TotalDiscount;
                        Data.NetAmount = String.valueOf(Decimal.valueof(Data.quantity) * Decimal.valueOf(Data.BasePrice));
                        if(String.isNotBlank(Data.NetAmount)){
                            Decimal netAmount = Decimal.valueOf(Data.NetAmount);
                            if(String.isNotBlank(Data.TotalDiscount)){
                                Decimal dis = Decimal.valueOf(Data.TotalDiscount);
                                netAmount -= ((netAmount/100)*dis).setScale(2);
                            }
                            System.debug('Data.NetAmount'+netAmount);
                            system.debug('Tax_Percentage__c'+Data.product.Tax_Percentage__c);
                            if(Data.product.Tax_Percentage__c != null)
                                netAmount += ((netAmount/100)*Data.product.Tax_Percentage__c).setScale(2);
                            if(netAmount != null)
                                Data.NetAmount = String.valueOf(netAmount);
                            System.debug('Data.NetAmount'+Data.NetAmount);
                        }
                        //DiscountType DistributerDiscount DPDiscount MRPDiscount CustomerGroup AreaId
                        Data.DiscountType = obj.DiscountType;
                        Data.DistributerDiscount = obj.DistributerDiscount;
                        Data.DPDiscount = obj.DPDiscount;
                        Data.MRPDiscount = obj.MRPDiscount;
                        Data.CustomerGroup = obj.CustomerGroup;
                        Data.AreaId = obj.AreaId;
                    }
                }
            }
        }
        return oliWrapperList;
    }*/
    
    Public class SFInstance
    {
        @AuraEnabled public String ProductCode{get;set;}
        //Added K-MRP
       // @AuraEnabled public String MRP{get;set;}
        @AuraEnabled public String BasePrice{get;set;}
        @AuraEnabled public String TotalDiscount{get;set;}
        @AuraEnabled public String OfferDescription{get;set;}
        @AuraEnabled public String DiscountType{get;set;}
        @AuraEnabled public String DistributerDiscount{get;set;}
        @AuraEnabled public String DPDiscount{get;set;}
        @AuraEnabled public String MRPDiscount{get;set;}
        @AuraEnabled public String CustomerGroup{get;set;}
        @AuraEnabled public String AreaId{get;set;}
        
    }
    
    public class JSONWrapper{
        @AuraEnabled  public string ProductCode{get;set;}
        @AuraEnabled  public String DealerCode{get;set;}
    }
    //26/06/2022 item image
    public static String HMCItemImages(String ItemName){
        string ContentDocumentId = '';
        if(ItemName != null){
            Set<Id> cdSet = new Set<Id>();
            List<ContentDocument> cdList = new List<ContentDocument>();
            List<ContentDocumentLink> ccl = new List<ContentDocumentLink>();
            
            cdList = [SELECT Id, Title FROM ContentDocument where Title =: ItemName LIMIT 1];
            for(ContentDocument cc : cdList ){
                if(cc.id != null){
                    cdSet.add(cc.id);
                }
            }
            if(!cdSet.isEmpty()){
                ccl = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink where ContentDocumentId =: cdSet LIMIT 1];
                // ccl = [select id, ContentDocument.title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN ( SELECT Id FROM User) AND ContentDocument.title =: ItemName LIMIT 1];
                for(ContentDocumentLink cl : ccl){
                    if(cl.ContentDocumentId != null){
                        ContentDocumentId = cl.ContentDocumentId; 
                    }
                } 
            }
        }
        return ContentDocumentId;
        
    }
    
}