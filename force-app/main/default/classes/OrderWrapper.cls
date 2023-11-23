public class OrderWrapper{
    public String DelaerCode;	//
    public String SourceorderId;	//
    public cls_Orders[] Orders;
    public class cls_Orders {
        public String Order_Id;	//
        public cls_OrderProducts[] OrderProducts;    }
    public class cls_OrderProducts {
        public String ProductCode;	//
        public String productName;	//
        public Integer Quantity;	//0
        public Integer DealerPrice;	//0
        public Integer DealerDiscount;	//5
        public String ItemId;	//
        public Integer LineNum;	//1
    }
    public static OrderWrapper parse(String json){
        return (OrderWrapper) System.JSON.deserialize(json, OrderWrapper.class);
    }
    
    /*	
static testMethod void testParse() {
String json=		'{ "DelaerCode": "", "SourceorderId": "", "Orders": [ { "Order_Id": "", "OrderProducts": [ { "ProductCode": "", "productName": "", "Quantity": 0, "DealerPrice": 0, "DealerDiscount": 5, "ItemId": "", "LineNum": 1 }, { "ProductCode": "", "productName": "", "Quantity": 0, "DealerPrice": 0, "DealerDiscount": 5, "ItemId": "", "LineNum": 2 } ] }, { "Order_Id": "Orde1", "OrderProducts": [ { "ProductCode": "", "productName": "", "Quantity": 0, "ItemId": "", "DealerPrice": 0, "DealerDiscount": 5, "LineNum": 1 }, { "ProductCode": "", "productName": "", "Quantity": 0, "Price": 0, "DealerPrice": 0, "DealerDiscount": 5, "TotalAmount": 0, "ItemId": "", "LineNum": 2 } ] } ] }';
OrderWrapper obj = parse(json);
System.assert(obj != null);
}*/
}