/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class HMC_AXCreateOrderHandler {
    public static string OrderSize;
    public static HTTPResponse createOrder(Id recordId) {
        string returnStr = '';
        List<Order__c> currentOppLst = [select id,Name,Account__c from Order__c where id = :recordId];
        String body = getOrderBody(recordId);
        HTTPResponse response = HMC_AXCreateOrderHandler.processOrder(body);
        
        System.debug('Responsee11'+response.getbody());
        //HMC_AXCreateOrderHandler res = (HMC_AXCreateOrderHandler) System.JSON.deserialize(response.getbody(), HMC_AXCreateOrderHandler.class);
        OrderWrapperNew orderWrapperObj1 = (OrderWrapperNew) System.JSON.deserialize(response.getbody(), OrderWrapperNew.class);       
        
        //String json = '{ "DelaerCode": "", "SourceorderId": "", "Orders": [ { "Order_Id": "", "OrderProducts": [ { "ProductCode": "40091", "productName": "Brake shoe tuner", "Quantity": 0, "DealerPrice": 0, "DealerDiscount": 5, "ItemId": "01tC30000000pFx", "LineNum": 1 }, { "ProductCode": "22358", "productName": "KryptoFlex 1565 Combo Cable w/ FlexFrame-C bracket", "Quantity": 0, "DealerPrice": 0, "DealerDiscount": 5, "ItemId": "01tC30000000omv", "LineNum": 2 } ] }, { "Order_Id": "Orde1", "OrderProducts": [ { "ProductCode": "40091", "productName": "Brake shoe tuner", "Quantity": 0, "ItemId": "01tC30000000pFx", "DealerPrice": 0, "DealerDiscount": 5, "LineNum": 1 }, { "ProductCode": "22358", "productName": "KryptoFlex 1565 Combo Cable w/ FlexFrame-C bracket", "Quantity": 0, "Price": 0, "DealerPrice": 0, "DealerDiscount": 5, "TotalAmount": 0, "ItemId": "01tC30000000omv", "LineNum": 2 } ] } ] }';
        //String jsonnew = '{ "Description": "", "OrderId": { "DelaerCode": "FFXCUS7142", "Orders": [ { "Order_Id": "SO/1920/020614", "OrderProducts": [ { "DealerDiscount": 0, "DealerPrice": 12000, "ItemId": "99990002", "LineNum": 1, "Price": null, "ProductCode": "99990002", "productName": "SF B2b Test item 2", "Quantity": 1, "TotalAmount": null } ] }, { "Order_Id": "SO/1920/020615", "OrderProducts": [ { "DealerDiscount": 0, "DealerPrice": 990, "ItemId": "22110", "LineNum": 1, "Price": null, "ProductCode": "22110", "productName": "Tube 700 x 19-25 with Slime Lite Smart", "Quantity": 1, "TotalAmount": null } ] } ], "SourceorderId": "" }, "Status": "SUCCESS", "StatusCode": 200 }';
        // system.debug('json----->'+json);
        
        // OrderWrapper orderWrapperObj = OrderWrapper.parse(json);
        system.debug('orderWrapperObj-->'+orderWrapperObj1);
        List<Order__c> oppLst = new List<Order__c>();
        List<Order__c> oppLineitem = new List<Order__c>();
        System.debug('oppLineitem'+oppLineitem);
        System.debug('oppLst'+oppLst);
        //List<PricebookEntry> existingPriceBook1 = [Select Id, product2__r.ProductCode__c,product2__c from PricebookEntry];  
        Map<String,Id> productPricebookmap = new Map<String,Id>();
        
        /*if(!existingPriceBook1.IsEmpty()){
            for(PricebookEntry pp1 : existingPriceBook1){
                productPricebookmap.put(pp1.product2__r.ProductCode__c,pp1.Id);  
            }  
        }*/
        if(orderWrapperObj1.Status.toLowerCase() == 'Success'){
            OrderWrapperNew.cls_OrderId  orderWrapperObj = orderWrapperObj1.OrderId;
            Integer j = 1;
            system.debug('size'+orderWrapperObj.Orders.size());
            OrderSize = string.valueof(orderWrapperObj.Orders.size());
            Account acc=[Select id,Name,HMC_COCO_Store__c from Account where id =: currentOppLst[0].Account__c Limit 1];
            //Id hmcOrderRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Child Order').getRecordTypeId();
            for(OrderWrapperNew.cls_Orders orderObj : orderWrapperObj.Orders){
                System.debug('i am in opportunity');               
                Order__c opp = new Order__c();
                System.debug('currentOppLst[0].Name'+currentOppLst[0].Name); 
                // opp.Name = currentOppLst[0].Name +' - ERP Order' + '-' + j++;
                //opp.Name = ' '+ system.today().format() + ' - ERP Order' + '-' + j++;
                opp.Account__c = currentOppLst[0].Account__c;
                opp.Parent_Account__c = currentOppLst[0].Account__c;// change 23/06/2022  ERP Orders
                 // change 17/06/2022  last value is Pushed to ERP
                //opp.CloseDate = System.today();
                opp.Parent_Order__c = recordId; 
                if(acc.HMC_COCO_Store__c == true){
                    //opp.StageName = 'Created';
                    opp.HMC_Order_Status__c = 'Created';
                   opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('COCO Store Confirm Order').getRecordTypeId();
                }else{
                    //opp.StageName = 'Order created in ERP';
                  opp.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Child Order').getRecordTypeId();
                }
                //opp.RecordTypeId = hmcOrderRecordTypeId;  // '012C30000000pgrIAA';// change Pro
                opp.HMC_Order_Number__c = orderObj.Order_Id;
                System.debug('opp.HMC_Order_Number__c'+opp.HMC_Order_Number__c);
                //oppLst.add(opp);   
                System.debug('oppLst'+oppLst);
            }
            
            if(!oppLst.isEmpty()){
                insert oppLst;
                Set<String> codes = new Set<String>();
                for(Integer i = 0;i < orderWrapperObj.Orders.size() ; i++){
                    OrderWrapperNew.cls_Orders orderObj = orderWrapperObj.Orders[i];
                    for(OrderWrapperNew.cls_OrderProducts orderObj1: orderObj.OrderProducts){
                        codes.add(orderObj1.ProductCode);
                    }
                }
                List <product2__c> lstOfProduct = [Select Id, Name, HMC_MODEL__c,Tax_Percentage__c, HMC_AICMA__c, BusinessUnitType__c, Type__c, ProductCode__c FROM product2__c where 
                                                IsActive__c = true and ProductCode__c = :codes];
                Map<String,product2__c> codeProductMap = new Map<String,product2__c>(); 
                for(product2__c pro : lstOfProduct){
                    codeProductMap.put(pro.ProductCode__c,pro);
                }               
                for(Integer i = 0;i< orderWrapperObj.Orders.size() ; i++){
                    OrderWrapperNew.cls_Orders orderObj = orderWrapperObj.Orders[i];
                    
                    //OrderWrapper.cls_Orders orderObj1=new OrderWrapper.cls_Orders();
                    for(OrderWrapperNew.cls_OrderProducts orderObj1: orderObj.OrderProducts){
                        Order__c lineitem = new Order__c();
                        lineitem.Quantity__c = orderObj1.Quantity;
                        lineitem.Discount__c = orderObj1.DealerDiscount;
                        lineItem.Order__c = oppLst[i].Id;
                        Boolean isExist = false;
                        if(codeProductMap.containsKey(orderObj1.ProductCode) && codeProductMap.get(orderObj1.ProductCode) != null){
                            product2__c pro = codeProductMap.get(orderObj1.ProductCode);
                            if(pro.Tax_Percentage__c != null){
                                lineItem.UnitPrice__c = orderObj1.DealerPrice  + (orderObj1.DealerPrice * (pro.Tax_Percentage__c/100));           // Standard function
                                isExist = true;
                                lineItem.Tax__c = pro.Tax_Percentage__c;           // Standard function
                            }
                        }
                        if(isExist == false){
                            lineItem.UnitPrice__c = orderObj1.DealerPrice;
                        }
                        lineItem.Item_Number__c = orderObj1.LineNum;
                        //lineItem.PricebookEntryId = productPricebookmap.get(orderObj1.ProductCode);
                        oppLineitem.add(lineitem);
                    }     
                }
                insert oppLineitem;
            }
        }
        system.debug('oppLineitem-->'+oppLineitem);
        return response;
    }
    public static HTTPResponse processOrder(String requestBodyJson) {
        // Parse the incoming JSON request body
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBodyJson);

        // Perform any required processing or business logic with the request data here
        // For demonstration purposes, we will directly use the provided request data in the response

        // Build the response data dynamically
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('StatusCode', 200);
        responseMap.put('Status', 'SUCCESS');
        responseMap.put('Description', '');

        // Get the order ID and other dynamic data from the request
        String dealerCode = (String) requestBodyMap.get('dealercode');
        String orderDate = (String) requestBodyMap.get('orderDate');
        String orderId = (String) requestBodyMap.get('order_id');

        // Build the Orders list with the dynamic data
        Map<String, Object> orderData = new Map<String, Object>();
        orderData.put('DelaerCode', null);
        orderData.put('SourceorderId', '');
        List<Map<String, Object>> ordersList = new List<Map<String, Object>>();
        orderData.put('Orders', ordersList);
        responseMap.put('OrderId', orderData);

        // Build the OrderProducts list dynamically from the request data
        List<Object> requestOrderProductsList = (List<Object>) requestBodyMap.get('orderproducts');
        /*for (Object orderProductObj : requestOrderProductsList) {
            Map<String, Object> requestOrderProduct = (Map<String, Object>) orderProductObj;
            Map<String, Object> orderProduct = new Map<String, Object>();
            orderProduct.put('ProductCode', requestOrderProduct.get('productcode'));
            orderProduct.put('productName', requestOrderProduct.get('productname'));
            orderProduct.put('Quantity', Double.valueOf((String) requestOrderProduct.get('quantity')));
            orderProduct.put('DealerPrice', Double.valueOf((String) requestOrderProduct.get('totalamount')));
            orderProduct.put('DealerDiscount', 0);
            orderProduct.put('ItemId', requestOrderProduct.get('itemid'));
            orderProduct.put('LineNum', Integer.valueOf((String) requestOrderProduct.get('linenum')));
            orderProduct.put('Price', null);
            orderProduct.put('TotalAmount', null);
            ordersList.add(orderProduct);
        }*/
		System.debug('ordersListordersList'+ordersList);
        // Serialize the response to JSON
        String responseBodyJson = '{"StatusCode":200,"Status":"SUCCESS","Description":"","OrderId":{"DelaerCode":null,"SourceorderId":"","Orders":[{"Order_Id":"SO/1920/020783","OrderProducts":[{"ProductCode":"101210111","productName":"Bicycle 26 (MissFit SSP, Matt Maroon), 17","Quantity":1,"DealerPrice":7329.0,"DealerDiscount":0,"ItemId":"101210111","LineNum":1,"Price":null,"TotalAmount":null},{"ProductCode":"101210211","productName":"Bicycle 26 (Target-V) Matt Blk, 21","Quantity":2,"DealerPrice":12208.0,"DealerDiscount":0,"ItemId":"101210211","LineNum":2,"Price":null,"TotalAmount":null}]}]}}';//JSON.serialize(responseMap);
		//String responseBodyJson	= '{"StatusCode":200,"Status":"SUCCESS","Description":"","OrderId":{"DelaerCode":null,"SourceorderId":"","Orders":[{"Order_Id":"SO/1920/020783","OrderProducts":'+ordersList+'}]}}';
        System.debug('responseBodyJson===>'+responseBodyJson);
        // Create the HTTPResponse object and set the JSON body
        HTTPResponse response = new HTTPResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBodyJson);
		System.debug('responseresponse==>'+response);
        return response;
    }
    public static HTTPResponse processOrder2(String requestBodyJson) {
        // Parse the incoming JSON request body
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBodyJson);

        // Perform any required processing or business logic with the request data here
        // For demonstration purposes, we will directly use the provided request data in the response

        // Build the response data dynamically
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('StatusCode', 200);
        responseMap.put('Status', 'SUCCESS');
        responseMap.put('Description', '');

        // Get the order ID and other dynamic data from the request
        String dealerCode = (String) requestBodyMap.get('dealercode');
        String orderDate = (String) requestBodyMap.get('orderDate');
        String orderId = (String) requestBodyMap.get('order_id');

        // Build the Orders list with the dynamic data
        Map<String, Object> orderData = new Map<String, Object>();
        orderData.put('DelaerCode', null);
        orderData.put('SourceorderId', '');
        List<Map<String, Object>> ordersList = new List<Map<String, Object>>();
        orderData.put('Orders', ordersList);
        responseMap.put('OrderId', orderData);

        // Build the OrderProducts list dynamically from the request data
        List<Object> requestOrderProductsList = (List<Object>) requestBodyMap.get('orderproducts');
        List<Map<String, Object>> orderProductsList = new List<Map<String, Object>>();
        for (Object orderProductObj : requestOrderProductsList) {
            Map<String, Object> requestOrderProduct = (Map<String, Object>) orderProductObj;
            Map<String, Object> orderProduct = new Map<String, Object>();
            orderProduct.put('ProductCode', requestOrderProduct.get('productcode'));
            orderProduct.put('productName', requestOrderProduct.get('productname'));
            orderProduct.put('Quantity', parseDoubleValue((String) requestOrderProduct.get('quantity')));
            orderProduct.put('DealerPrice', parseDoubleValue((String) requestOrderProduct.get('totalamount')));
            orderProduct.put('DealerDiscount', 0);
            orderProduct.put('ItemId', requestOrderProduct.get('itemid'));
            orderProduct.put('LineNum', Integer.valueOf((String) requestOrderProduct.get('linenum')));
            orderProduct.put('Price', null);
            orderProduct.put('TotalAmount', null);
            orderProductsList.add(orderProduct);
        }

        // Add the dynamically built OrderProducts list to the Orders list
        Map<String, Object> order = new Map<String, Object>();
        order.put('Order_Id', orderId);
        order.put('OrderProducts', orderProductsList);
        ordersList.add(order);

        // Serialize the response to JSON
        String responseBodyJson = JSON.serialize(responseMap);

        // Create the HTTPResponse object and set the JSON body
        HTTPResponse response = new HTTPResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBodyJson);

        return response;
    }

    // Custom parsing method to handle decimal values with trailing zero
    private static Decimal parseDoubleValue(String value) {
        if (value == null) {
            return null;
        }

        // Remove trailing zeros, if any, and parse the decimal value
        return Decimal.valueOf(value).setScale(2);
    }
    public static string OrderSizeM(){
        return OrderSize;
    }
    public static HTTPResponse CreditLimitOfDealer(Id recordId){
        string returnStr = '';
        List<Opportunity> opportunityList = [select id, Name, account.HMC_BU_Type__c,Account.HMC_Account_Selection__c,Account.HMC_Dealer_Code__c,Account.HMC_Line_Discount__c from opportunity where id = :recordId];
        String body = '{"DealerCode":"'+opportunityList[0].Account.HMC_Dealer_Code__c +'"}';
        system.debug('Request body CL'+body);
        creditlimitReq req = new creditlimitReq();
        req.Dealercode = opportunityList[0].Account.HMC_Dealer_Code__c;
        System.debug('req== '+req);
        HTTPResponse response = HMC_HTTPUtility.sendRequestAX('AX_Credit_Limit',JSON.serialize(req));
        System.debug('Responsee== '+response);
        String jsonbody = response.getbody();
        reponse  res = new reponse();
        return response;
    }    
    public static String getOrderBody(Id oppId){
        List<Order__c> oppLst = [SELECT Id,Shipping_Pincode__c,ProductCode__c,Shipping_City__c,Shipping_Country__c,Shipping_Street__c,Shipping_State__c,Account__c,Account__r.HMC_COCO_Store__c,Account__r.Name,Amount__c,Account__r.HMC_Dealer_Code__c,Account__r.ShippingState,TotalOpportunityQuantity__c,Account__r.Shippingstreet,Account__r.shippingcountry,Account__r.shippingcity,(SELECT Id,Product__r.Name,Product__r.ProductCode__c,quantity__c,UnitPrice__c,TotalPrice__c,ProductCode__c FROM orderLineItems__r) FROM Order__c WHERE Id = : oppId];
        //List<Opportunity> oppLst=[SELECT Id,Shipping_Pincode__c,Shipping_City__c,Shipping_Country__c,Shipping_Street__c,Shipping_State__c,AccountId,Account.HMC_COCO_Store__c,Account.Name,Amount,Account.HMC_Dealer_Code__c,Account.ShippingState,TotalOpportunityQuantity,Account.Shippingstreet,Account.shippingcountry,Account.shippingcity,(SELECT Id,product2__r.Name__c,ProductCode,quantity,UnitPrice,TotalPrice FROM OpportunityLineItems) FROM Opportunity WHERE Id = : oppId];        
        OrderRequestWrapper wrapperObj = new OrderRequestWrapper();
        wrapperObj.dealercode = oppLst[0].Account__r.HMC_Dealer_Code__c;
        wrapperObj.sf_dealerid = oppLst[0].Account__c;
        wrapperObj.order_id = oppLst[0].Id;
        wrapperObj.customername = oppLst[0].Account__r.Name;
        wrapperObj.totalprice=string.valueof(oppLst[0].Amount__c);
        //update address
        //wrapperObj.shippingstatecode=HMC_Utility.getStateCode(oppLst[0].Shipping_State__c);
        wrapperObj.shippingstreet=oppLst[0].Shipping_Street__c;          
        wrapperObj.shippingcity=oppLst[0].Shipping_City__c;
        wrapperObj.shippingzipcode = oppLst[0].Shipping_Pincode__c;
        wrapperObj.shippingcountry='IND';//oppLst[0].Account.shippingCountry;
        
        wrapperObj.orderDate=String.valueOf(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        System.debug(wrapperObj.orderDate+'Date');
        wrapperObj.quantity=String.valueOf(oppLst[0].TotalOpportunityQuantity__c);
        //COCO Store Order 02-03-2023
		wrapperObj.CocoStore = String.valueOf(oppLst[0].Account__r.HMC_COCO_Store__c);        
        System.debug('TotalOpportunity'+oppLst[0].TotalOpportunityQuantity__c);        
        integer lineItemCount=1;
        List<OrderProductsWrapper> opwList = new List<OrderProductsWrapper>();
        for(Order__c lineItem : oppLst[0].orderLineItems__r){
            OrderProductsWrapper opw = new OrderProductsWrapper();
            opw.productcode=lineItem.ProductCode__c;
            opw.productname=lineItem.Product__r.Name;
            opw.quantity=String.valueOf(lineItem.quantity__c);
            opw.price=String.valueOf(lineItem.unitPrice__c);
            opw.totalamount=String.ValueOf(lineItem.totalPrice__c);
            opw.itemid=String.valueOf(LineItem.Id);
            opw.linenum=String.valueOf(lineItemCount);        
            lineItemCount++;
            opwList.add(opw);
        }            
        wrapperObj.orderproducts = opwList;
        System.debug('WrapperObj'+wrapperObj);
        return JSON.serialize(wrapperObj);
    }
    public class OrderRequestWrapper{
        Public String dealercode;
        Public String sf_dealerid;
        Public String order_id;
        public String comment;
        public String customername;
        public String warehouseid;
        public String WarehouseSiteId;
        public String totalprice;
        public String shippingzipcode;
        public String shippingstatecode;
        public String shippingstreet;
        public String shippingcity;
        public String shippingcountry;
        public String orderDate;
        public String quantity;
        //COCO Store Order 02-03-2023
        public String CocoStore;
        public List<OrderProductsWrapper> orderproducts;
    }
    Public class OrderProductsWrapper{
        public String productcode;
        public String productname;
        public String quantity;
        public String price;
        public String totalamount;
        public String itemid;
        public String linenum;
    }
    public class reponse{
       @AuraEnabled public Integer StatusCode;  //200
       @AuraEnabled public String Status;   //SUCCESS
       @AuraEnabled public String Description;  //
    }
    
    public class creditlimitReq{
        public string Dealercode;
    }
    
    public class creditlimitresponse{
        public Integer statuscode;  //0
        public String status;   //ERROR
        public String DealerCode;   //
        public String CreditLimit;  //
        public String Description;  
    }
    public String Status;   //Sucess
    public String OrderId;  //  
}