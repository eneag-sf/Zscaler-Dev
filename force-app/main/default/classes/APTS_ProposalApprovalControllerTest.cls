@isTest
public class APTS_ProposalApprovalControllerTest{
    static testMethod void executeAllMethods() {
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
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Name = 'Test Config', Apttus_QPConfig__Proposald__c = proposal.Id);
        insert prodConfig;
        
        List<Apttus_Approval__Approval_Request__c> appr = new List<Apttus_Approval__Approval_Request__c>();
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Subscription Uplift .',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Discount',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Support Discount',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Payment Term',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Billing Frequency',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Custom Terms',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Ramp Schedule',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Term < 3 Years',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Co-Term',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Decrease in Renewal MRR',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Decrease in Renewal TCV',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'DAS Seats Mismatch - Customer Success',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Buy Back Credit - Deal Desk',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'NFR - Deal Desk',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Onsite TAM - Customer Success',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        appr.add(new Apttus_Approval__Approval_Request__c(Apttus_Approval__Step_Name__c = 'Zscaler Extend Transaction Log - Product Management',Apttus_QPApprov__ProposalId__c = proposal.Id, Apttus_CQApprov__CartId__c=prodConfig.Id));
        insert appr;
//        ApexPages.currentPage().getParameters().put('ProposalId',proposal.Id);
        APTS_ProposalApprovalController controller = new APTS_ProposalApprovalController();
        controller.ProposalId = proposal.Id;
        controller.ListOfTermApprovalLineItems=appr;
        controller.InstanceURL='test url';
        for(Apttus_Approval__Approval_Request__c app:appr){
            controller.ApprovalRequestId = app.Id;            
            controller.GetListOfReasons();
        }
        controller.GetProposal();
        controller.getProductConfig();
        controller.GetListOfLineItems();
        //controller = new APTS_ProposalApprovalController();
        //controller.GetApprovalHistory();
        Test.stopTest();
    }
}