public with sharing class PriceListCtrl {
    @AuraEnabled
    public static String getPriceList(){
        try{
            String pdfUrl = '';
            String currentUserId = UserInfo.getUserId();
            String currentUserSalesOffice = [select id,Sales_Office__c from user where id = :currentUserId Limit 1].Sales_Office__c;
            if(!String.isBlank(currentUserSalesOffice)){
                Price_List__c pl = [select id,name,Content_Link__c from Price_List__c where Name = :currentUserSalesOffice order by CreatedDate desc limit 1];
                pdfUrl = pl.Content_Link__c;
                return pdfUrl;
            }
            return pdfUrl;
        }Catch(Exception e){
            return '';
        }
    }
    
   
    @AuraEnabled
    public static String getSalesOffice(){
        String currentUserId = UserInfo.getUserId();
        System.debug('currentUserId: '+currentUserId);
        String currentUserSalesOffice = [select id,Sales_Office__c from user where id = :currentUserId Limit 1].Sales_Office__c;
        return currentUserSalesOffice;
    }
    
    @AuraEnabled
    public static String getRollingSalesOffice(){
        String currentUserId = UserInfo.getUserId();
        String currentUserSalesOffice = [select id,Sales_Office__c from user where id = :currentUserId Limit 1].Sales_Office__c;
        String showDate = String.valueOf(System.today()).split(' ')[0];
        if(currentUserSalesOffice != '' || currentUserSalesOffice != NULL){
            return currentUserSalesOffice+'-'+showDate;
        }else{
            return '';
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Price_List__c> getPriceListName() {
       
        User currentUser = [SELECT id,Sales_Office__c FROM User WHERE Id =: UserInfo.getUserId()];
        List<Price_List__c> priceList = [SELECT  id,Name,Sales_Office__c,Content_Link__c FROM Price_List__c
                                         WHERE Sales_Office__c =: currentUser.Sales_Office__c AND Active__c = true] ;
        return priceList;
    }
     @AuraEnabled(cacheable=true)
    public static Price_List__c getAttachmentUrl(String selectedAttachmentId) {
        system.debug('selectedAttachmentId==>'+selectedAttachmentId);
        Price_List__c priceList = [SELECT  id,Name,Sales_Office__c,Content_Link__c FROM Price_List__c WHERE Id =:selectedAttachmentId ] ;
        
            return priceList;
    }
}