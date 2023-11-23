// QuoteToOrderController.cls
public with sharing class QuoteToOrderController {
    @AuraEnabled
    public static String convertQuoteToOrder(Id quoteId) {
        try {
            Quote quoteRecord = [SELECT Id, Name, Status,GrandTotal,ContractId,OpportunityId,AccountId,Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];
            System.debug('quoteRecord==> ' + quoteRecord);
            if(quoteRecord.Status == 'Accepted'){
                Account acc=[select id,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry from Account where id=:quoteRecord.AccountId];
                system.debug('Account 11 ========>'+acc);
                
                
                Order newOrder = new Order(
                    AccountId = quoteRecord.AccountId, 
                    EffectiveDate = Date.today(), 
                    Pricebook2Id = quoteRecord.Pricebook2Id,
                    //ContractId__c = Contra.Id,
                    Name = quoteRecord.Name,
                    Status = 'Draft',
                    //TotalAmount = quoteRecord.GrandTotal,
                    ShippingCity=acc.ShippingCity,
                    ShippingStreet=acc.ShippingStreet,
                    ShippingPostalCode=acc.ShippingPostalCode,
                    BillingCity=acc.BillingCity,
                    BillingPostalCode=acc.BillingPostalCode,
                    BillingStreet=acc.BillingStreet,
                    QuoteId = quoteId
                    
                    
                    
                );
                
                if(newOrder != null ){
                    insert newOrder;
                }
                
                //Create orderlineItem
                List<OpportunityLineItem> opportunityLineItems = [select  Name,Id,ListPrice,Discount, Product2Id,
                                                                  UnitPrice, Quantity, Subtotal,TotalPrice,PricebookEntry.Pricebook2Id,PricebookEntryId,Description
                                                                  from OpportunityLineItem where OpportunityId =: quoteRecord.OpportunityId];
                
                
                
                //  id recIdOrderItem=[select Id,DeveloperName from RecordType  where DeveloperName='Order_Line_Item' limit 1].Id;
                List<OrderItem> orderLineItemsToInsert = new List<OrderItem>();
                
                for (opportunityLineItem oppLineObj : opportunityLineItems) {
                    system.debug('line 21'+oppLineObj);
                    OrderItem OrderItem1 = new OrderItem();
                    
                    // Name=opportunityLineItem.Product2Id.Name,
                    OrderItem1.Product2Id = oppLineObj.Product2Id;
                    OrderItem1.PricebookEntryId = oppLineObj.PricebookEntryId;
                    OrderItem1.Quantity = oppLineObj.Quantity;
                    OrderItem1.ListPrice = oppLineObj.ListPrice;
                    OrderItem1.UnitPrice = oppLineObj.UnitPrice;
                    //  OrderItem1.TotalPrice = oppLineObj.TotalPrice;
                    OrderItem1.OrderId = newOrder.Id;
                    orderLineItemsToInsert.add(OrderItem1);
                    system.debug('line 28'+orderLineItemsToInsert);
                }
                
                if(orderLineItemsToInsert != null){
                    system.debug('line 28'+orderLineItemsToInsert);
                    try{
                        insert orderLineItemsToInsert;
                    }
                    catch (Exception e) {
                        System.debug('Error converting quote to order: ' + e.getMessage());
                        throw e;
                    }
                }
                
                //return the newly created Order Id
                return newOrder.Id;
            }
            else{
                return 'Null'; 
            }
        } catch (Exception e) {
            System.debug('Error converting quote to order: ' + e.getMessage());
            throw e;
        }
    }
    
    
    
}