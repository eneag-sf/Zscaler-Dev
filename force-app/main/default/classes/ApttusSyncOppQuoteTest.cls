/*************************************************************************************************************************
 @Name: ApttusSyncOppQuoteTest
 @Author: Pranjal Mittal
 @Created Date: 14/12/2016
 @Descripton: Test Class for ApttusSyncOppQuote
 @Used By:
*************************************************************************************************************************/

@isTest
public class ApttusSyncOppQuoteTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;

    static{
        pricelist = APTS_TestUtil.createpricelist();
        acc = APTS_TestUtil.creatAccount();
        //opp = APTS_TestUtil.createOpportunity(acc.Id, pricelist.Id);
    }

    @testSetup static void testData(){
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList',
                                                                         Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceList;
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook',
                                                                         Apttus__Value__c = 'Apttus Default Price Book');
        insert adminPriceBook;
    }

    @isTest static void testcreateQuoteOrProposal() {
        Test.startTest();
        opp = new Opportunity(Name = 'Test Opportunity Test Opportunity Test Opportunity Test Opportunity',
                              StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today().addDays(-180));
        opp.AccountID = acc.Id;
        opp.OwnerId = UserInfo.getUserId();
        opp.type = 'Existing Customer (Add On)';
        insert opp;
        ApttusSyncOppQuote.createQuoteOrProposal(opp, 'Upsell', pricelist.Name);

        Opportunity opp1 = new Opportunity(Name = 'Test Opportunity',
                                           StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        opp1.AccountID = acc.Id;
        opp1.OwnerId = UserInfo.getUserId();
        opp1.type = 'Existing Customer (Renewal)';
        insert opp1;
        ApttusSyncOppQuote.createQuoteOrProposal(opp1, 'Upsell', pricelist.Name);
        Test.stopTest();
    }


    /*@isTest static void testcreateQuoteOrProposal1() {
        Test.startTest();
        Account acc1 = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        Apttus_Config2__PriceList__c  pricelist1 = APTS_TestUtil.createpricelist();
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity 2',
                                           StageName = label.Stage_6_Closed_Won /**'13 - Closed & Approved By Finance'**, CloseDate = Date.today());
        opp2.AccountID = acc1.Id;
        opp2.OwnerId = UserInfo.getUserId();
        opp2.type = 'New Business';
        insert opp2;
        ApttusSyncOppQuote.createQuoteOrProposal(opp2, 'Upsell', pricelist1.Name);

        Opportunity opp3 = new Opportunity(Name = 'Test Opportunity 3',
                                           StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'**, CloseDate = Date.today());
        opp3.AccountID = acc1.Id;
        opp3.OwnerId = UserInfo.getUserId();
        opp3.type = 'NFR (Not For Resale)';
        insert opp3;
        ApttusSyncOppQuote.createQuoteOrProposal(opp3, 'Upsell', pricelist1.Name);

        Test.stopTest();
    }*/

    @isTest static void testcreateQuoteOrProposal2() {
        //When Opportunity type is not mentioned
        Test.startTest();
        Account acc1 = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        Apttus_Config2__PriceList__c  pricelist1 = APTS_TestUtil.createpricelist();

        Opportunity opp4 = new Opportunity(Name = 'Test Opportunity 4',
                                           StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        opp4.AccountID = acc1.Id;
        opp4.OwnerId = UserInfo.getUserId();
        insert opp4;
        ApttusSyncOppQuote.createQuoteOrProposal(opp4, '', pricelist1.Name);

        Test.stopTest();
    }

    @isTest static void testnullOrEmpty(){
        Test.startTest();
        ApttusSyncOppQuote.nullOrEmpty('Test String');
        Test.stopTest();
    }

    @isTest static void testgetOpportunitySO(){
        Test.startTest();
        opp = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        opp.AccountID = acc.Id;
        opp.OwnerId = UserInfo.getUserId();
        opp.type = 'Existing Customer (Add On)';
        insert opp;
        ApttusSyncOppQuote.getOpportunitySO(opp.Id);
        Test.stopTest();
    }
}