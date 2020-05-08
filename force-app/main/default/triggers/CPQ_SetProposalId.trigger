trigger CPQ_SetProposalId on Apttus_Approval__Approval_Request__c (before insert) {
     Set<Id> configIds = new Set<Id>();
        for(Apttus_Approval__Approval_Request__c approvalRequest : Trigger.New){
        if(approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus_Config2__ProductConfiguration__c'){
        configIds.add(approvalRequest.Apttus_Approval__Object_Id__c);
        }
        }
        if(configIds.isEmpty()){
        return;
        }
        Map<Id, Apttus_Config2__ProductConfiguration__c> prodConfigMap = new Map<Id, Apttus_Config2__ProductConfiguration__c>([Select Id, Apttus_QPConfig__Proposald__c From Apttus_Config2__ProductConfiguration__c Where Id in :configIds]);
        for(Apttus_Approval__Approval_Request__c approvalRequest : Trigger.New){
        if(approvalRequest.Apttus_Approval__Object_Type__c == 'Apttus_Config2__ProductConfiguration__c'){
        approvalRequest.Apttus_QPApprov__ProposalId__c = prodConfigMap.get(approvalRequest.Apttus_Approval__Object_Id__c).Apttus_QPConfig__Proposald__c;
        }
        }

}