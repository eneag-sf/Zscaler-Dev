@isTest
public class APTS_ProposalApprovalControllerProdTest{
    static testMethod void executeAllMethods() {
        Test.startTest();
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id);
        insert proposal;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Name = 'Test Config', Apttus_QPConfig__Proposald__c = proposal.Id);
        insert prodConfig;
        
        Set<string> allReasons = new Set<string>();
        allReasons.add('Support Discount');
        allReasons.add('Discount');
        allReasons.add('Payment Term');
        allReasons.add('Billing Frequency');
        allReasons.add('Custom Terms');
        allReasons.add('Ramp Schedule');
        allReasons.add('Term < 3 Years');
        allReasons.add('Subscription Uplift ');
        allReasons.add('Co-Term');
        allReasons.add('Decrease in Renewal MRR');
        allReasons.add('Decrease in Renewal TCV');
        allReasons.add('DAS Seats Mismatch - Customer Success');
        allReasons.add('Buy Back Credit - Deal Desk');
        allReasons.add('NFR - Deal Desk');
        allReasons.add('Onsite TAM - Customer Success');
        allReasons.add('Zscaler Extend Transaction Log - Product Management');
        allReasons.add('Zscaler Extend Transaction Log - Product Management');
        
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
        
        APTS_ProposalApprovalControllerProdConf controller = new APTS_ProposalApprovalControllerProdConf();
        controller.proposalID = proposal.Id;
        controller.prodConfigID=prodConfig.Id;
        Set<string> ListOfReasons = new Set<String>(controller.getListOfReasons());
        
        controller.getproposalSO();
        controller.getprodConfigSO();
        controller.getListOfLineItems();
        controller.getListOfReasons();
        
        Apttus_Proposal__Proposal__c proposalSO = controller.getproposalSO();
        Apttus_Config2__ProductConfiguration__c prodConfigSO = controller.getprodConfigSO();
        
        List<Apttus_Config2__LineItem__c> ListOfLineItems = controller.getListOfLineItems();
        Test.stopTest();
        system.assert(ListOfReasons.containsAll(allReasons),'Not all reasons covered. All Reason '+allReasons+ '. Covered Rasons'+ListOfReasons );
        system.assert(proposalSO.Id == proposal.Id, 'Proposal ID not Matched. Expected:'+proposal.Id + '  Actual :'+ proposalSO.Id);
        system.assert(prodConfigSO.Id == prodConfig.Id, 'prodConfig ID not Matched. Expected:'+prodConfig.Id + '  Actual :'+ prodConfigSO.Id);
    }
}