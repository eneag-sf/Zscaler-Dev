/*************************************************************************************************************************
 @Name: ApttusNewOppToQuoteControllerTest
 @Author: Anay Bhande
 @Created Date: 15/12/2016
 @Descripton: Test Class for ApttusNewOppToQuoteController
 @Used By: 
*************************************************************************************************************************/
@isTest
public class ApttusNewOppToQuoteControllerTest {
    public static testMethod void testMyController() {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Test.startTest();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus_Config2__PriceList__c Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        Id priceListId = Pricelist.Id;
        Account account = new Account(Name = 'ZScaler');
        insert account;
        Account PartnerAccount = new Account(Name = 'Partner',Type='Partner');
        insert PartnerAccount;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller');
        insert OppPartner;

        ApexPages.StandardController stdOpportunity = new ApexPages.StandardController(opportunity);
        ApttusNewOppToQuoteController controller = new ApttusNewOppToQuoteController(stdOpportunity);
        controller.onload();

        PageReference pageRef = Page.ApttusCreateNewQuotePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_ID,opportunity.Id);
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_PRICELIST_NAME,'ZScaler Price List');
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_RECORDTYPE_ID,schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_RECORDTYPE_NAME,'Proposal');
                
        controller = new ApttusNewOppToQuoteController(stdOpportunity);
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_ID,opportunity.Id);
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_PRICELIST_NAME,'ZScaler Price List');
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_RECORDTYPE_ID,schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Proposal').getRecordTypeId());
        ApexPages.currentPage().getParameters().put(ApttusNewOppToQuoteController.PARAM_RECORDTYPE_NAME,'Proposal');
        controller.onload();
        controller.doCancel();
        controller.getHasErrors();
        Test.stopTest();
    }
}