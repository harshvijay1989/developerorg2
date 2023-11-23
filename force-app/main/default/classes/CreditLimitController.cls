/*
    Name : CreditLimitController
    Author :Harendra Singh
    Test Class : CreditLimitController_Test
*/
public with sharing class CreditLimitController {
    
  @AuraEnabled(cacheable=true)
    public static Account getAccounts() {
  
        User usr  = [SELECT Id, AccountId , contactId FROM user Where Id = : UserInfo.getUserId() ];
        
        Account acc = [select Id,Allocated_Credit_Limit__c, Consumed_Credit_Limit__c,Remaining_Credit_Limit__c from Account where Id = : usr.AccountId];
        return acc; 
      }
    
  }