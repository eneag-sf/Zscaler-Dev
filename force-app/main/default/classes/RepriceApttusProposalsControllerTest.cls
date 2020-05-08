@isTest
private class RepriceApttusProposalsControllerTest {

    public static Account acc;
    public static Account acc1;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string newcartId;
    public static string cartId;

    static
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        acc = APTS_TestUtil.creatAccount ();
        acc1 = APTS_TestUtil.creatAccount ();
        pricelist = new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        Pricebook2 Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
        insert Pricebook;
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        Apttus_Config2__ConfigSystemProperties__c config=new Apttus_Config2__ConfigSystemProperties__c(Name='System Properties',Apttus_Config2__InstanceUrl__c=URL.getSalesforceBaseUrl().toExternalForm() + '/');
        insert config;

        opp = APTS_TestUtil.createOpportunity (acc.Id,pricelist.Id);

        prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);

        cartId = APTSCU_AcceptProposalController.CreateCartForProposal(prop.Id);

        PageReference tpageRef = Page.RepriceApttusProposals;
        Test.setCurrentPage(tpageRef);

        RepriceApttusProposalsController controller = new RepriceApttusProposalsController() ;

        primaryprop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,true);
        String prdId = APTS_TestUtil.createProduct ();
        APTS_TestUtil.createassetlineItems ( prop.Id,acc.id,prdId,null );

        Apttus__APTS_Admin__c testAdmin = new Apttus__APTS_Admin__c(Name = 'Generate Document Email Template');
        testAdmin.Apttus__Value__c = 'Zscaler Proposal';
        insert testAdmin;

        Partner testOpptyPartner = new Partner();
        testOpptyPartner.AccountToId = acc1.Id;
        testOpptyPartner.IsPrimary = true;
        testOpptyPartner.OpportunityId = opp.Id;
        //testOpptyPartner.Role = 'Vendor';
        insert testOpptyPartner;

    }

    @isTest static void testGetProposalsForReprice() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        RepriceApttusProposalsController.getAllProposalIdsToReprice(new List<Id> { prop.Id });
        Test.stopTest();
    }

    @isTest static void testCreateCartForProposal() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        RepriceApttusProposalsController.createCartForProposal(primaryprop.Id);
        Test.stopTest();
    }

    @isTest static void testRepriceCart() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        RepriceApttusProposalsController.repriceCart(cartId);
        Test.stopTest();
    }

    @isTest static void testFinalizeCart() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        try{
        RepriceApttusProposalsController.finalizeCart(cartId);
        }catch(exception ex){
        
        }
        try{
        RepriceApttusProposalsController.updatePricingFields(cartId);
        }catch(exception ex){
        
        }
        try{
        RepriceApttusProposalsController.updateCartLinesPricingStatus(cartId);
        }catch(exception ex){
        
        }
        try{
        RepriceApttusProposalsController ctrl = new RepriceApttusProposalsController();
        ctrl .navigatetoURL();
        }catch(exception ex){
        
        }
        Test.stopTest();
    }
}