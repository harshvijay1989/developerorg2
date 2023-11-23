public class OrderWrapperNew {
    public String Description;  //
    public cls_OrderId OrderId;
    public String Status;   //SUCCESS
    public Integer StatusCode;  //200
    
    public class cls_OrderId {
        public String DelaerCode;   //
        public String SourceorderId;    //
        public cls_Orders[] Orders;
    }
    public class cls_Orders {
        public String Order_Id; //
        public cls_OrderProducts[] OrderProducts;   
    }
    
    public class cls_OrderProducts {
        public String ProductCode;  //
        public String productName;  //
        public Integer Quantity;    //0
        public Decimal DealerPrice; //0
        public Integer DealerDiscount;  //5
        public String ItemId;   //
        public Integer LineNum; //1
    }
    public static OrderWrapper parse(String json){
        return (OrderWrapper) System.JSON.deserialize(json, OrderWrapper.class);
    }
}