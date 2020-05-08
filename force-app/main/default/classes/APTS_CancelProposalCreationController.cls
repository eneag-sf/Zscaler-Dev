/*************************************************************
@Name: APTS_CancelProposalCreationController
@Author:  Jigar Naik
@CreateDate: 15 Nov 2016
@Description: Class to update proposal status to Presented.
******************************************************************/
public with sharing class APTS_CancelProposalCreationController{
    public String proposalId {get; set;}
    
    public APTS_CancelProposalCreationController(){
        proposalId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference deleteProposal(){
        Apttus_Proposal__Proposal__c proposalSO = [Select Id, Apttus_Proposal__Opportunity__c, LastModifiedDate, CreatedDate From Apttus_Proposal__Proposal__c Where Id = :proposalId];
        
        system.debug('###proposalSO:' + proposalSO.CreatedDate.getTime());
        system.debug('###proposalSO:' + proposalSO.LastModifiedDate.getTime());
        
        if(proposalSO.LastModifiedDate.getTime() - proposalSO.CreatedDate.getTime() < 1001){
            delete proposalSO;
            return new PageReference('/' + proposalSO.Apttus_Proposal__Opportunity__c);
        }else{
            return new PageReference('/' + proposalSO.Id);
        }
    }
}