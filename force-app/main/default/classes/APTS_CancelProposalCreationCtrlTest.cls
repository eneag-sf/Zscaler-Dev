@isTest
public class APTS_CancelProposalCreationCtrlTest{
    static testMethod void deleteProposalMethod() {
        Test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id);
        insert proposal;
        
        APTS_CancelProposalCreationController controller = new APTS_CancelProposalCreationController();
        controller.proposalId = proposal.Id;
        controller.deleteProposal();
        
        proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id);
        insert proposal;
        
        controller.proposalId = proposal.Id;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Approval Required';
        update proposal;
        
        controller.deleteProposal();
        
        Test.stopTest();
    }
}