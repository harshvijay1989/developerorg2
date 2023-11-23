public class HMC_AccountTriggerHandler {
    public static void afterInsertDistance(List<Account> newAccounts , List<Account> oldAccounts){
        String AccountId;
        system.debug('======Run 0001');
        for(Account acc : newAccounts){
            system.debug('======Class Run 00909'+acc.BillingLongitude + acc.BillingLatitude);
            // If(acc.Distance_Calculated__c != true && acc.BillingLatitude != null && acc.BillingLongitude != null && acc.ShippingLatitude != null && acc.ShippingLongitude != null){
            If(acc.BillingPostalCode != null && acc.ShippingPostalCode != null){
                AccountId = acc.Id;
                system.debug('======Class AccountId');
            }
        }
        If(AccountId != null){
            system.debug('======Class Run 0006');
            //CalculateDistancePolicyController.calculateDistance(AccountId);
        }
    }
    public static void sendNotification(List<Account> newAccounts , List<Account> oldAccounts){
        String name;
        String Ids;
        String ownerIds;
        
        for(Account acc : newAccounts){
            
            If(acc.HMC_ROI_Score1__c == null && acc.Distance_Calculated__c == true && acc.Distance_Policy_Approval_Status__c == 'Approved' && acc.Distance_Policy_Approval_Required__c == false){
                name = acc.Name;
                Ids = acc.Id;
                ownerIds = acc.OwnerId;
            }
        }
        if(name != null && Ids != null && ownerIds != null){
            CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Dealer_Onboarding'];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Distance Policy Approval request for the account is approved');
        notification.setBody(name);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(Ids);
        notification.send(new set<String>{ownerIds});
        }
        
    }
    public static void afterInsert(List<Account> newAccounts){  
        Set<String> cities =new Set<String>();
        for(Account acc : newAccounts){
            if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HMC_Constants.HMCDEALERACCOUNT).getRecordTypeId()){
                if(acc.HMC_Checklist_Completed__c && (acc.HMC_Legal_Proceeding__c == 'No' && acc.HMC_KYC_Document__c == 'No' && acc.HMC_Market_Reputation__c == 'Negative') && ((acc.HMC_Deviation_Approval_Status__c !='Rejected') || (acc.HMC_Deviation_Approval_Status__c !='Waiting for Approval') || (acc.HMC_Deviation_Approval_Status__c !='Not Required'))){
                    //submitForApproval(acc.Id);
                }
                cities.add(acc.BillingCity);
            }        
        }
        if(!cities.isEmpty()){
            List <Account> acnt =[SELECT Id,BillingCity from Account Where BillingCity IN : cities];                         
            System.debug('acnt' +acnt);
            for(Account act : newAccounts){
                if(act.HMC_Tier__c == 'Tier 1' || act.HMC_Tier__c == 'Tier 2'){
                    System.debug('Here' + acnt.size());
                    for(Account city :newAccounts){
                        if(!String.isBlank(city.BillingCity) && acnt.size()>0){
                            System.debug('Here' + acnt.size());
                            //submitForApproval(city.Id);
                        }
                    }
                }
            }        
        }
    }    
    
    public static void updateUser(List<Account> newAccounts,Map<Id,Account> oldMap){ 
        Set<Id> ownerids=new Set<Id>();
        for(Account acc : newAccounts){
            if(acc.Target_amount__c !=null ||(acc.Target_amount__c !=null && acc.Target_amount__c != oldMap.get(acc.Id).Target_amount__c)){
                ownerids.add(acc.OwnerId);
            }
        }
        
        list<User> lstUser = new list<User>();
        Map<ID, User> users = new Map<ID, User>([select id from User where id =: ownerids]);
        AggregateResult[] groupedResults = [SELECT OwnerId,SUM(Target_amount__c)amt FROM Account where OwnerId  in : ownerids group by OwnerId];
        for(AggregateResult Results: groupedResults){
            Id userId =(id)Results.get('OwnerId'); 
            // User userObj=new User();
            User userObj=users.get(userId);
            userObj.Id=userId;
            //userObj.Total_Target_amount__c=(Decimal)Results.get('amt');
            lstUser.add(userObj);
        }   
        if(!lstUser.isEmpty()){
            update lstUser;
        }
    }
    
    
    public static void afterUpdate(List<Account> newAccounts,Map<Id,Account> oldMap){        
        Set<String> cities =new Set<String>();
        for(Account acc : newAccounts){
            if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HMC_Constants.HMCDEALERACCOUNT).getRecordTypeId()){
                // if(acc.HMC_Checklist_Completed__c != oldMap.get(acc.Id).HMC_Checklist_Completed__c || acc.HMC_Legal_Proceeding__c != oldMap.get(acc.Id).HMC_Legal_Proceeding__c ||  acc.HMC_KYC_Document__c != oldMap.get(acc.Id).HMC_KYC_Document__c || acc.HMC_Deviation_Approval_Status__c != oldMap.get(acc.Id).HMC_Deviation_Approval_Status__c ) {
                if(acc.HMC_Checklist_Completed__c && ( acc.HMC_Legal_Proceeding__c == 'No' ||  acc.HMC_KYC_Document__c == 'No' || acc.HMC_Market_Reputation__c == 'Negative') && (acc.HMC_Deviation_Approval_Status__c !='Rejected' && acc.HMC_Deviation_Approval_Status__c !='Waiting for Approval' && acc.HMC_Deviation_Approval_Status__c !='Not Required')){
                    //submitForApproval(acc.Id);
                }
                if(acc.BillingCity != oldMap.get(acc.Id).BillingCity){
                    cities.add(acc.BillingCity);
                }   
                //}
            }
        }
        if(!cities.isEmpty()){
            List <Account> acnt =[SELECT Id,BillingCity from Account Where BillingCity IN : cities];
            for(Account act : newAccounts){
                if(act.HMC_Tier__c == 'Tier 1' || act.HMC_Tier__c == 'Tier 2'){
                    System.debug('Here' + acnt.size());
                    for(Account city :newAccounts){
                        if(!String.isBlank(city.BillingCity) && acnt.size()>0){
                            System.debug('Here' + acnt.size());
                            //submitForApproval(city.Id);
                        }
                    }
                }            
            }
        }
    }
    /* public static void updatedDealercode(List<Account> newAccounts){
Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer_Confirm').getRecordTypeId();
System.debug('recordTypeId'+recordTypeId);
List<Account>accLst = new List<Account>();
for(Account acc : newAccounts){ 
System.debug('testete'+ acc.HMC_Dealer_Code__c);
if(acc.HMC_Dealer_Code__c != null){
System.debug('Inside If');
Account acco = new Account();
acco.Id = acc.Id;
acco.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer_Confirm').getRecordTypeId();
accLst.add(acco);
}

}
if(!accLst.IsEmpty()){
update accLst;
}

}*/
    public static void beforeUpdate(List<Account> newAccounts,Map<Id,Account> oldMap){
        for(Account acc : newAccounts){
            if(acc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HMC_Constants.HMCDEALERACCOUNT).getRecordTypeId()){
                if(acc.HMC_Tier__c != oldMap.get(acc.Id).HMC_Tier__c ) {
                    if(acc.HMC_tier__c =='Tier 3'){
                        if(acc.HMC_Man_Power__c ==null){
                            System.debug('HERE');
                            acc.addError('Please Check that Manpower field is empty.');
                        }
                        if( acc.HMC_Money_Power__c == null){
                            System.debug('HERE1');
                            acc.addError('Please Check that Money Power is empty.');
                        }
                        if(acc.HMC_Marketing_Power__c == null ){
                            acc.addError('Please Check that Marketing Power is empty.');
                        }
                    }
                }
                
            }
            if(acc.HMC_Annual__c >= 1 && acc.HMC_Annual__c <5000000){
                acc.HMC_Category__c = 'Silver';
            }else if(acc.HMC_Annual__c >= 5000000 && acc.HMC_Annual__c <10000000){
                acc.HMC_Category__c = 'Gold';
            }else if(acc.HMC_Annual__c >= 10000000){
                acc.HMC_Category__c = 'Platinum';
            }
        }
    }
    Public static void beforeInsert(List<Account> newAcc){
        for(Account acc : newAcc){
            if(acc.HMC_Annual__c != null){
                if(acc.HMC_Annual__c >= 1 && acc.HMC_Annual__c <5000000){
                    acc.HMC_Category__c = 'Silver';
                }else if(acc.HMC_Annual__c >= 5000000 && acc.HMC_Annual__c <10000000){
                    acc.HMC_Category__c = 'Gold';
                }else if(acc.HMC_Annual__c >= 10000000){
                    acc.HMC_Category__c = 'Platinum';
                }  
            }
        }
    }
    public static void submitForApproval(String accId){
        // Create an approval request for the account
        System.debug('approval'+accID);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Deviation Approval.');
        req1.setObjectId(accId);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId()); 
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
    }
    /*public static HMC_Training__C getTrainingObj(Account acc,String name){

HMC_Training__C newRec=new HMC_Training__C();
newRec.Account__c=acc.Id;
newRec.HMC_Start_Date__c=system.today();
//newRec.HMC_Completed_Date__c=system.today();
newRec.HMC_Status__c='In Progress';
newRec.OwnerId=acc.OwnerId;
System.debug('Owner'+newRec.OwnerId);
newRec.Name= name;
return newRec ;
}*/
    
    //dealer - 
    /* public static void trainingRecord(List<Account> newLst, Map<Id,Account> oldMap){
list<HMC_Training__C> trainingObjLst=new list<HMC_Training__C>();
List<String> nameList = new List<String> {'Sales training by Sales team','Technician training by technical team','Dealer portal training by Sales team','Order making process by Sales team','Social Media and local Promotion Support by Marketing team','Accounts Training – Accounts Team'};
for(Account acc : newLst){
if(acc.HMC_Dealer_Code__c != null && oldMap.get(acc.Id).HMC_Dealer_Code__c ==null){
for(String s:nameList){
trainingObjLst.add(getTrainingObj(acc,s));
}               
}

}
if(!trainingObjLst.isEmpty()){
insert trainingObjLst;
try{
sendEmail(newLst);
}catch(Exception oEx){
System.debug('Exception  '+oEx.getMessage()  + oEx.getLineNumber());
}
try{
sendEmailToASM(newLst);
}catch(exception oEx){
System.debug('Exception  '+oEx.getMessage()  + oEx.getLineNumber());
}
try{
sendEmailToTechnicalTeam(newLst);
}catch(exception oEx){
System.debug('Exception  '+oEx.getMessage()  + oEx.getLineNumber());
}
}
}*/
    
    //send email to Dealer and SPOC
    public static void sendEmail(List<Account> newLst){
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress where DisplayName Like '%Firefox%'];
        for(Account acc : newLst){
            EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate WHERE Name ='Firefox Dealer Confirmation Email'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
            message.setTargetObjectId(acc.CreatedById);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(acc.Id); 
            //This is important for the merge fields in template to work
            if(acc.HMC_Contact_Email__c != null){
                message.toAddresses = new String[] { acc.HMC_Contact_Email__c};
                    
                    Messaging.SingleEmailMessage[] messages = new   
                    List<Messaging.SingleEmailMessage> {message};
                        
                        Messaging.SendEmailResult[] results =
                        Messaging.sendEmail(messages);
            }
        }
    }
    //Send Email to Technical Team
    
    public static void sendEmailToTechnicalTeam(List<Account> newLst){
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress where DisplayName Like '%Firefox%'];
        for(Account acc : newLst){
            EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate WHERE Name ='FirefoxOnboarding Marketing and Tech'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
            message.setTargetObjectId(acc.CreatedById);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(acc.Id); 
            //This is important for the merge fields in template to work
            if(Label.TechPersonEmail != null){
                message.toAddresses = new String[] { Label.MarketingEmail,Label.TechPersonEmail};
                    
                    Messaging.SingleEmailMessage[] messages = new   
                    List<Messaging.SingleEmailMessage> {message};
                        
                        Messaging.SendEmailResult[] results =
                        Messaging.sendEmail(messages);
            }
        }
    }
    //send email to Dealer and SPOC
    public static void sendEmailToASM(List<Account> newLst){
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress where DisplayName Like '%Firefox%'];
        Map<Id,Id> mapOwnerEmail = new Map<Id,Id>();
        //Map<String,User> mapUsers = new Map<String,User>();
        Map<Id,String> mapUsers = new Map<Id,String>();
        for(Account acco : newLst){
            If(acco.OwnerId != null){
                mapOwnerEmail.put(acco.Id, acco.OwnerId);
            }
        }
        List<User> userrec = [SELECT Id,Email FROM User WHERE Id IN:mapOwnerEmail.values()];
        //Map<ID> mapUsers = new Map<ID>([SELECT Email FROM User WHERE Id IN:mapOwnerEmail.values()]);
        for(User uu : userrec){
            mapUsers.put(uu.Id,uu.Email);
        }
        
        for(Account acc : newLst){
            
            EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate WHERE Name ='Internal Email to Brand SPOC for Training initiation1'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
            message.setTargetObjectId(acc.CreatedById);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(acc.Id); 
            message.setTargetObjectId(acc.CreatedById);
            //message.setReplyTo(lstEmailAddress[0].Id);
            //This is important for the merge fields in template to work
            if(mapUsers.get(mapOwnerEmail.get(acc.Id)) != null){
                message.toAddresses = new String[] { mapUsers.get(mapOwnerEmail.get(acc.Id))};
                    
                    Messaging.SingleEmailMessage[] messages = new   
                    List<Messaging.SingleEmailMessage> {message};
                        
                        Messaging.SendEmailResult[] results =
                        Messaging.sendEmail(messages);
            }
        }
    }
    public static void accountAddress(List<Account> accLst,Map<id,Account> oldMap){
        Set<Id> accountIds = new Set<Id>();
        for(Account acc: accLst){
            if(acc.HMC_Dealer_Code__c != null && oldMap!= null && acc.HMC_Dealer_Code__c != oldMap.get(acc.Id).HMC_Dealer_Code__c){
                accountIds.add(acc.Id);
                system.debug('=======here'+accountIds);
            }
        }
        if(!accountIds.isEmpty()){
            List<Account> accList = [SELECT Id,ShippingAddress,Shippingstate,Shippingcity,ShippingCountry,ShippingPostalCode FROM Account WHERE Id =: accountIds];
            /*List<HMC_Address__c> address = new List<HMC_Address__c>();

for(Account accObj : accList){

if(accObj.shippingAddress != null){
system.debug('======00=here');
HMC_Address__c Shipping = new HMC_Address__c();
Shipping.account__c = accObj.Id;
Shipping.city__c = accObj.ShippingCity;
Shipping.State__c = accObj.ShippingState;
Shipping.Country__c = accObj.shippingCountry;
Shipping.Pincode__c = accObj.ShippingpostalCode;
Shipping.Type__c = 'Ship';
Shipping.Primary__c = true;
address.add(Shipping);
}
}
if(!address.isEmpty()){
insert address;
}*/
        }
    }
    /*public static void createTargetHistoryRecord(List<Account> newAccounts,Map<Id,Account> oldAccounts,Boolean isInsert){
Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HMC_Dealer_Account').getRecordTypeId();
if(isInsert){
List<HMC_Target__c> targets = new List<HMC_Target__c>();
for(Account  acc : newAccounts){
if(acc.RecordTypeId == rtId){
HMC_Target__c targetObj = new HMC_Target__c();
targetObj.HMC_Dealer__c = acc.Id;
targetObj.HMC_Target_Amount__c = acc.Target_amount__c;
targetObj.HMC_Achievement_Amount__c = acc.HMC_Achievement__c;
targets.add(targetObj);
}
}
if(targets.size() > 0){
INSERT targets;
}
}else{
Set<Id> accountIds = new Set<Id>();
Map<Id,Account> accMap = new Map<Id,Account>();
for(Account  acc : newAccounts){
if(acc.RecordTypeId == rtId && (acc.Target_amount__c != oldAccounts.get(acc.Id).Target_amount__c || acc.HMC_Achievement__c != oldAccounts.get(acc.Id).HMC_Achievement__c)){
accountIds.add(acc.Id);
accMap.put(acc.Id,acc);
}
}
if(accountIds.size() > 0){
Integer month = System.today().month();
Integer year = System.today().year();

List<HMC_Target__c> targetList = [SELECT Id,HMC_Target_Amount__c,HMC_Achievement_Amount__c,HMC_Year__c,HMC_Month__c,HMC_Dealer__c from HMC_Target__c WHERE HMC_Dealer__c IN :accountIds AND HMC_Year__c = :year AND HMC_Month__c = :month];
Map<String,HMC_Target__c> tagetMap = new Map<String,HMC_Target__c>();
for(HMC_Target__c target : targetList){
if(accMap.containsKey(target.HMC_Dealer__c)){
target.HMC_Target_Amount__c = accMap.get(target.HMC_Dealer__c).Target_amount__c;
target.HMC_Achievement_Amount__c = accMap.get(target.HMC_Dealer__c).HMC_Achievement__c;
}
}
if(targetList.size() > 0){
UPDATE targetList;
}
}
}
}*/
    
}