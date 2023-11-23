public class InvoiceOrderReceiptCls {
    public Id orderId{get; set;}
    public Static String orderDate{get; set;}
    public Static Order__c orderData {get; set;}
    public Static List<Order__c> orderItemLst {get; set;}
    
    public InvoiceOrderReceiptCls(){
        orderDate = String.valueOf(System.today());
        String queryString ='';
        orderId = ApexPages.currentPage().getParameters().get('id');
        orderData = getOrderData(orderId);
        System.debug('orderData: '+orderData);
        orderItemLst = getOrderItems(orderId);
        System.debug('orderItemLst: '+orderItemLst);
    }
    
    public static Order__c getOrderData(Id orderId){
        try{
            String orderRecordType = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Order').getRecordTypeId();
            Order__c order = [SELECT Id,Account__r.HMC_Contact_Number__c,Account__r.HMC_Contact_Email__c,HMC_Invoice_Amount__c,Account__r.ShippingStreet, Account__r.ShippingState,Account__r.ShippingCountry,Account__r.ShippingCity,  Account__r.BillingStreet,  Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingCity,createdDate FROM Order__c WHERE Id =: orderId AND RecordTypeId = :orderRecordType LIMIT 1];
            if(order != null){
                orderDate = String.valueOf(order.createdDate).split(' ')[0];
                //updateOrder(orderId);
                return order;
            }
            return null;
        }Catch(Exception e){
            return null;
        }
    }
    
    public static List<Order__c> getOrderItems(Id orderId){
        try{
            String oliRecordType = Schema.getGlobalDescribe().get('Order__c').getDescribe().getRecordTypeInfosByName().get('Order Line Item').getRecordTypeId();
			List<Order__c> orderItemLst = [select id,UnitPrice__c,Product__c,Product__r.Name,Product__r.BusinessUnitType__c,Product__r.ProductCode__c,Quantity__c  from Order__c where Order__c =: orderId AND RecordTypeId = :oliRecordType];
            if(orderItemLst.size() > 0){
                return orderItemLst;
            }
            return null;
        }Catch(Exception e){
            return null;
        }
    }
}