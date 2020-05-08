public without sharing class AccessRequestTriggerHandler {
    
    public static void beforeUpdate(Map<Id, Access_Request__c> newAccessRequests, Map<Id, Access_Request__c> oldAccessRequests){
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType Where SObjectType = 'Access_Request__c']);
        Set<Id> accessRequestsToRecallApprovals = new Set<Id>();
        List<AccountShare> accountShareInsertList = new List<AccountShare>();
        for(Access_Request__c accessReq : newAccessRequests.values()){
            if(recordTypeMap.get(accessReq.RecordTypeId).Name == 'Account Access'){
                if(accessReq.Recall_Approval__c && accessReq.Recall_Approval__c != oldAccessRequests.get(accessReq.Id).Recall_Approval__c){
                    accessRequestsToRecallApprovals.add(accessReq.Id);
                    accessReq.Recall_Approval__c = false;
                    accessReq.Send_To_Auto_Approval__c = true;
                }
                if(accessReq.Request_Status__c == 'Approved' && accessReq.Request_Status__c != oldAccessRequests.get(accessReq.Id).Request_Status__c){
                    AccountShare acctShr = new AccountShare();
                    acctShr.UserOrGroupId = accessReq.Requested_From__c;
                    acctShr.AccountId = accessReq.Account__c;
                    acctShr.AccountAccessLevel = 'Edit';
                    //acctShr.ContactAccessLevel = 'Edit';
                    acctShr.CaseAccessLevel = 'Edit';
                    acctShr.OpportunityAccessLevel = 'Edit';
                    accountShareInsertList.add(acctShr);
                }
                
            }
        }
        if(!accessRequestsToRecallApprovals.isEmpty()){
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id 
                                                            FROM 
                                                            ProcessInstanceWorkItem 
                                                            WHERE ProcessInstance.TargetObjectId IN: accessRequestsToRecallApprovals
                                                            AND 
                                                            ProcessInstance.Status = 'Pending']; 
            for(ProcessInstanceWorkitem pwiRec : piWorkItems){
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(pwiRec.Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
            }
        }
        if(!accountShareInsertList.isEmpty()){
            Database.insert(accountShareInsertList, false);
        }
    }
    
    public static void afterUpdate(Map<Id, Access_Request__c> newAccessRequests, Map<Id, Access_Request__c> oldAccessRequests){
        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, Name FROM RecordType Where SObjectType = 'Access_Request__c']);
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
        for(Access_Request__c accessReq : newAccessRequests.values()){
            if(recordTypeMap.get(accessReq.RecordTypeId).Name == 'Account Access'){
                if(accessReq.Send_To_Auto_Approval__c && accessReq.Request_Status__c == 'Requested'){
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitting request for approval.');
                    req.setObjectId(accessReq.id);
                    requestList.add(req);
                }
            }
        }
        if(!requestList.isEmpty()){
            Approval.ProcessResult[] result = Approval.process(requestList);
        }
    }
}