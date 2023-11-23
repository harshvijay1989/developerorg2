public with sharing class AccountCurrentApprovalController {
    @AuraEnabled
    public static String getApprovalStatus(Id recordId) {
        String ProcessInstanceId = [SELECT Id,Actor.Name , ProcessInstance.TargetObject.Id FROM ProcessInstanceWorkitem where ProcessInstance.TargetObject.Id = :recordId LIMIT 1].Id;
        return ProcessInstanceId;
    }
}