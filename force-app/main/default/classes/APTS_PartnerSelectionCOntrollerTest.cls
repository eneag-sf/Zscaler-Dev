/*************************************************************************************************************************
 @Name: APTS_PartnerSelectionCOntrollerTest
 @Author: Anay Bhande
 @Created Date: 13/12/2016
 @Descripton: Test Class for APTS_PartnerSelectionCOntroller
 @Used By: 
*************************************************************************************************************************/
@isTest
//Class added by Anay Bhande
public class APTS_PartnerSelectionCOntrollerTest {
    
     @testSetup static void setup() {
        List<Account> accListForInsert = new List<Account>(); 
        Account account = new Account(Name = 'ZScaler');
        accListForInsert.add(account);
        //insert account;
        Account PartnerAccount = new Account(Name = 'Partner', Type='Partner');
        //insert PartnerAccount;
        accListForInsert.add(PartnerAccount);
        insert accListForInsert;
        Id accountId = accListForInsert[0].Id;
        Id OppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',RecordTypeId = OppRecTypeId,AccountId = account.Id,  CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Renewal)');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller',Account__c = account.Id);
        insert OppPartner;  
        
        Incumbent_Partner__c IncumbentPartner = new Incumbent_Partner__c(Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller',Account__c = account.Id,Incumbent_Partner_Account__c = account.Id);
        insert IncumbentPartner;
         
        Opportunity_Partner__c DistributorPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Distributor',Account__c = account.Id);
        insert DistributorPartner;  
        
        Incumbent_Partner__c DistributorIncumbentPartner = new Incumbent_Partner__c(Opportunity__c = opportunity.Id,Partner_Type__c = 'Distributor',Account__c = account.Id,Incumbent_Partner_Account__c = account.Id);
        insert DistributorIncumbentPartner; 
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365);
        insert proposal;
        
        Triggers_Switch__c Tg = new Triggers_Switch__c();
        Tg.Name = 'Update_GAM_NAM';
        Tg.Execute__c = true;
        insert Tg;
    }
    
    public static testMethod void testMyController(){
        Test.StartTest();
        //Opportunity opportunityRec = [Select Id,Name from Opportunity Where Name = 'Test Opportunity' LIMIT 1];
        //Account accRecord = [Select Id from Account Where Name = 'ZScaler' LIMIT 1];
        Opportunity_Partner__c OppPartnerRec = [select Id,Name from Opportunity_Partner__c Where Partner_Type__c='Reseller' limit 1];
        Opportunity_Partner__c DistributorPartnerRec = [select Id,Name from Opportunity_Partner__c Where Partner_Type__c='Distributor' limit 1];
        Apttus_Proposal__Proposal__c proposal = [Select Id,Name,Apttus_Proposal__Proposal_Name__c,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Name__c = 'Test Proposal' limit 1];
        
        ApexPages.StandardController stdProposal = new ApexPages.StandardController(proposal);
        APTS_PartnerSelectionCOntroller controller = new APTS_PartnerSelectionCOntroller(stdProposal);
        controller.SelectedPartnerId = OppPartnerRec.Id;
        controller.SelectedDistributorPartnerId = DistributorPartnerRec.Id;
        controller.selectedPartnerIdForApproval = DistributorPartnerRec.Id;
        controller.DistributorPartnerId = DistributorPartnerRec.Id;
        controller.UncheckDistributorPartnerId = DistributorPartnerRec.Id;
        controller.selectedPartner = '';
        controller.haserror = false;
        controller.needsRepricing = false;
        controller.SavePartner();
        controller.AssignPartnerId();
        controller.AssignDistributorPartnerId();
        controller.submitForApproval();
        controller.cancelAction();
        controller.CheckDistributorPartners();
        Test.StopTest();
    }
    
    public static testMethod void testElseConditionsController(){
        Test.StartTest();
        //Opportunity opportunityRec = [Select Id,Name from Opportunity Where Name = 'Test Opportunity' LIMIT 1];
        //Account accRecord = [Select Id from Account Where Name = 'ZScaler' LIMIT 1];
        Opportunity_Partner__c OppPartnerRec = [select Id,Name from Opportunity_Partner__c Where Partner_Type__c='Reseller' limit 1];
        Opportunity_Partner__c DistributorPartnerRec = [select Id,Name from Opportunity_Partner__c Where Partner_Type__c='Distributor' limit 1];
        Apttus_Proposal__Proposal__c proposal = [Select Id,Name,Apttus_Proposal__Proposal_Name__c,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Name__c = 'Test Proposal' limit 1];
        
        Attachment attach = new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=OppPartnerRec.id;
        insert attach;
        
        ApexPages.StandardController stdProposal = new ApexPages.StandardController(proposal);
        APTS_PartnerSelectionCOntroller controller = new APTS_PartnerSelectionCOntroller(stdProposal);
        controller.SelectedPartnerId = null;
        controller.SelectedDistributorPartnerId = null;
        controller.UncheckDistributorPartnerId = DistributorPartnerRec.Id;
        controller.selectedPartner = '';
        controller.AttachmentId = attach.Id; 
        controller.haserror = false;
        controller.needsRepricing = false;
        controller.SavePartner();
        controller.submitForApproval();
        Test.StopTest();
    }
    
}