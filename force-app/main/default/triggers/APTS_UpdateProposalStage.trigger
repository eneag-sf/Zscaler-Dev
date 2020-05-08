/*************************************************************
@Name: APTS_UpdateProposalStage
@Author:  Jigar Naik
@CreateDate: 18 Nov 2016
@Description: Trigger to update cloned quote stage to Approval Required.
******************************************************************/
trigger APTS_UpdateProposalStage on Task(after insert) 
{
  Set<Id> allIdSet = new Set<Id>();
  
  for(Task taskRecord : Trigger.New)
  {
    
    if(taskRecord.WhatId != null && taskRecord.Subject == 'Cloned from Proposal')
    {
      allIdSet.add(taskRecord.WhatId);
    }
  }
  
  List<Apttus_Proposal__Proposal__c> proposalList = [Select Id, Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__Primary__c,Apttus_QPApprov__Approval_Status__c From Apttus_Proposal__Proposal__c Where Id in :allIdSet];
  
  if(proposalList.isEmpty()){
    return;
  }
  
  for(Apttus_Proposal__Proposal__c proposal : proposalList){
    proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
    proposal.Apttus_Proposal__Primary__c = false;
   // proposal.Apttus_QPApprov__Approval_Status__c  =  'Approval Required'; 
  }
  
  update proposalList;
}