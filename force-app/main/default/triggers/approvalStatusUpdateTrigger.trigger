trigger approvalStatusUpdateTrigger on Apttus_Approval__Approval_Request__c (after update) {
    ApprovalStatusUpdateTriggerHandler.updateApprovalStatus(Trigger.oldMap, Trigger.new);
}