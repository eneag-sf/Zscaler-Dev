@isTest
public class APTS_AssetLineItemTriggerHandlerTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    //public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static String prdId;

    static{

    }

    @testSetup
    static void testData(){
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();

        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        Apttus__APTS_Admin__c testAdmin = new Apttus__APTS_Admin__c(Name = 'Generate Document Email Template');
        testAdmin.Apttus__Value__c = 'Zscaler Proposal';
        insert testAdmin;
        insert adminPriceBook;
        insert adminPriceList;





       // APTS_TestUtil.createassetlineItems(prop.Id,acc.id,prdId,null);
    }

    @isTest
    static void scheduleTestMethod(){
        
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        acc = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        acc.APTS_No_of_Platform_Seats__c = 10;
        update acc;
        pricelist = APTS_TestUtil.createpricelist();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won, CloseDate = Date.today());
        opp.AccountID = acc.Id;
        //testOppty.OwnerId = userTest.Id;
        opp.PriceBook2Id = Test.getStandardPricebookId();
        opp.Price_List__c = pricelist.Id;
        insert opp;
        prdId = APTS_TestUtil.createProduct();
        List<Product2> listOfProd = APTS_TestUtil.createProducts(3);
        listOfProd[0].ProductCode = 'ZSC-SIP';
        update listOfProd;
        Test.startTest();
        prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);
        List<Apttus_Proposal__Proposal_Line_Item__c> listOfPli = APTS_TestUtil.createProposalLineItems(prop, listOfProd);
        List<Apttus_Config2__AssetLineItem__c> lstAssets = APTS_TestUtil.createassetlineItems(prop, listOfPli);
        lstAssets[0].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[0].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[1].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[1].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[2].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[2].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[0].Apttus_Config2__StartDate__c = Date.today().addDays(-1095);
        lstAssets[1].Apttus_Config2__StartDate__c = Date.today().addDays(-1095);
        lstAssets[2].Apttus_Config2__StartDate__c = Date.today().addDays(-1094);
        lstAssets[0].Apttus_Config2__EndDate__c = Date.today();
        lstAssets[1].Apttus_Config2__EndDate__c = Date.today();
        lstAssets[2].Apttus_Config2__EndDate__c = Date.today().adddays(1);
        for(Apttus_Config2__AssetLineItem__c asl:lstAssets){
            asl.Apttus_Config2__DeltaQuantity__c = 2;
        }
        update lstAssets;
        APTS_AssetLineItemTriggerHandler obj = new APTS_AssetLineItemTriggerHandler();
        obj.handleAfterInsertEvents(lstAssets);
        Test.stopTest();
    }
    @isTest
    static void scheduleTestMethod1(){
        
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        acc = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        acc.APTS_No_of_Platform_Seats__c = 10;
        update acc;
        pricelist = APTS_TestUtil.createpricelist();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won, CloseDate = Date.today());
        opp.AccountID = acc.Id;
        //testOppty.OwnerId = userTest.Id;
        opp.PriceBook2Id = Test.getStandardPricebookId();
        opp.Price_List__c = pricelist.Id;
        insert opp;
        prdId = APTS_TestUtil.createProduct();
        List<Product2> listOfProd = APTS_TestUtil.createProducts(3);
        listOfProd[0].ProductCode = 'ZPA-BUS';
        update listOfProd;
        Test.startTest();
        prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);
        List<Apttus_Proposal__Proposal_Line_Item__c> listOfPli = APTS_TestUtil.createProposalLineItems(prop, listOfProd);
        List<Apttus_Config2__AssetLineItem__c> lstAssets = APTS_TestUtil.createassetlineItems(prop, listOfPli);
        lstAssets[0].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[0].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[1].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[1].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[2].Apttus_Config2__ProductId__c = listOfProd[0].Id;
        lstAssets[2].Apttus_Config2__AssetStatus__c = 'Activated';
        lstAssets[0].Apttus_Config2__StartDate__c = Date.today().addDays(-1095);
        lstAssets[1].Apttus_Config2__StartDate__c = Date.today().addDays(-1095);
        lstAssets[2].Apttus_Config2__StartDate__c = Date.today().addDays(-1094);
        lstAssets[0].Apttus_Config2__EndDate__c = Date.today();
        lstAssets[1].Apttus_Config2__EndDate__c = Date.today();
        lstAssets[2].Apttus_Config2__EndDate__c = Date.today().adddays(1);
        for(Apttus_Config2__AssetLineItem__c asl:lstAssets){
            asl.Apttus_Config2__DeltaQuantity__c = 2;
            asl.Apttus_Config2__BaseExtendedPrice__c = 10000;
        }
        update lstAssets;
        APTS_AssetLineItemTriggerHandler obj = new APTS_AssetLineItemTriggerHandler();
        obj.handleAfterInsertEvents(lstAssets);
        Test.stopTest();
    }
}