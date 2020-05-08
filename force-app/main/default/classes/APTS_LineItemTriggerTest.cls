/**
 * Description: Test class for Line Item trigger.
 * SeeAllData should be set to true to make the custom settings available for managed package to run.
 * Author: Harish Emmadi, 11/23/2016
 */

@isTest
private class APTS_LineItemTriggerTest {
    public static Account testAccount;
    public static List<product2> testProducts;
    public static Apttus_Config2__PriceList__c  testPriceList;
    public static Opportunity testOpportunity;
    public static Apttus_Proposal__Proposal__c  testProposal;
    public static Id testCartId;
    public static List<Apttus_Config2__LineItem__c> testLineItems;
    private static Id lineItemId;
    private static Id configId;
    private static Id lineItemId1;
    private static Id configId1;
    private static Id accountId;
    
    static
    {
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        // create account
        testAccount = APTS_TestUtil.creatAccount ();
        
        // create 5 zscaler products.
        testProducts = APTS_TestUtil.createProducts(5);

        // create a price list
        testPriceList = APTS_TestUtil.createpricelist ();
        
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        // create opportunity
        testOpportunity = APTS_TestUtil.createOpportunity (testAccount.Id, testPriceList.Id);
        
        // create proposal
        testProposal = APTS_TestUtil.createproposal(testOpportunity.Id, testAccount.Id, testPriceList.Id, false);
        
        // create cart
        testCartId = APTSCU_CreateProposalUtility.CreateCartForProposal(testProposal.Id);
        
        Boolean isTrigger = new APTS_LineItem_Master_TriggerHandler(true).IsTriggerContext;
        
        Apttus_Config2__PriceList__c Pricelist = new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
   
        /*Apttus_DealMgr__DealGuidanceRule__c dealGuidanceMap=new Apttus_DealMgr__DealGuidanceRule__c(Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__BusinessObject__c ='Apttus_Config2__LineItem__c');
        insert dealGuidanceMap;
        
        Apttus_DealMgr__DealGuidanceRuleEntry__c dealGuidanceEntryMap1=new Apttus_DealMgr__DealGuidanceRuleEntry__c(
                        Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__GuidanceRuleId__c=dealGuidanceMap.Id,
                        Apttus_DealMgr__Dimension2Value__c='Zscaler',Apttus_DealMgr__Band1Value__c='21',Apttus_DealMgr__Band2Value__c='22',
                        Apttus_DealMgr__Band3Value__c='23',Apttus_DealMgr__Band4Value__c='24');
        insert dealGuidanceEntryMap1;
        
        Apttus_DealMgr__DealGuidanceRuleEntry__c dealGuidanceEntryMap2=new Apttus_DealMgr__DealGuidanceRuleEntry__c(
                        Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__GuidanceRuleId__c=dealGuidanceMap.Id,
                        Apttus_DealMgr__Dimension2Value__c='Partner',Apttus_DealMgr__Band1Value__c='21',Apttus_DealMgr__Band2Value__c='22',
                        Apttus_DealMgr__Band3Value__c='23',Apttus_DealMgr__Band4Value__c='24');
        insert dealGuidanceEntryMap2;
        */
    }

    @isTest static void test_LineItemDerivationsOne() {
        // Implement test code
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        // setup the billTo and shipTo on prdocut configuration.
        Apttus_Config2__ProductConfiguration__c testProdConfig = new Apttus_Config2__ProductConfiguration__c(Id = testCartId);
        testProdConfig.Apttus_Config2__BillToAccountId__c = testAccount.Id;
        testProdConfig.Apttus_Config2__ShipToAccountId__c = testAccount.Id;
        update testProdConfig;

        System.assertEquals(0, [Select Count() From Apttus_Config2__LineItem__c]);

        // Add line items to cart.
        testLineItems = APTS_TestUtil.createLineItems(testProdConfig.Id, testPriceList.Id, testProducts);
        
        // Validate Derivation 1: Apttus_Config2__BillToAccountId__c, Apttus_Config2__ShipToAccountId__c
        System.assertEquals(testLineItems.size(), [Select Count() From Apttus_Config2__LineItem__c
                                                            Where Id IN :testLineItems]);
        for(Apttus_Config2__LineItem__c li : [Select Id, Apttus_Config2__BillToAccountId__c, Apttus_Config2__ShipToAccountId__c From Apttus_Config2__LineItem__c]){
            System.assertEquals(li.Apttus_Config2__BillToAccountId__c, testAccount.Id);
            System.assertEquals(li.Apttus_Config2__ShipToAccountId__c, testAccount.Id);
        }
    }
    
    @isTest static void test_LineItemDerivationThree(){
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        List<Apttus_Proposal__Proposal_Line_Item__c>  testProposalLines = APTS_TestUtil.createProposalLineItems(testProposal, testProducts);
        System.assertEquals(testProposalLines.size(), [Select Count() From Apttus_Proposal__Proposal_Line_Item__c
                                                                        Where Id IN :testProposalLines]);
        List<Apttus_Config2__AssetLineItem__c> testAssetLineItems = APTS_TestUtil.createassetlineItems(testProposal, testProposalLines);
        System.assertEquals(testAssetLineItems.size(), [Select Count() From Apttus_Config2__AssetLineItem__c
                                                                        Where Id IN :testAssetLineItems]);

        testLineItems = APTS_TestUtil.createLineItems(testCartId, testPriceList.Id, testProducts);
        
        // Add line items to cart with asset line linked.
        List<Apttus_Config2__LineItem__c> testLineItemsClone = testLineItems.deepclone(false);
        Test.startTest();
        Integer counter = 0;
        for(Apttus_Config2__LineItem__c li : testLineItemsClone){
            li.Apttus_Config2__PrimaryLineNumber__c = testLineItems.size()+counter+1;
            li.Apttus_Config2__LineNumber__c = testLineItems.size()+counter+1;
            li.Apttus_Config2__AssetLineItemId__c = testAssetLineItems.get(counter).Id;
            li.Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_RENEWED;
            counter ++;
        }
        testLineItemsClone[0].Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_CANCELLED;
        insert testLineItemsClone;

        System.assertEquals(testLineItemsClone.size()*2, [Select Count() From Apttus_Config2__LineItem__c]);
        // Validate Derivation 3: Apttus_Config2__Quantity__c - asset quantity in testutils should be set to 100.
        for(Apttus_Config2__LineItem__c li : [Select Id, APTS_Total_Ramp_Quantity__c,Apttus_Config2__Quantity__c 
                                                From Apttus_Config2__LineItem__c
                                                    Where Id IN :testLineItemsClone AND Apttus_Config2__LineStatus__c =: APTS_CONSTANTS.LI_STATUS_RENEWED]){
            System.assertEquals(li.Apttus_Config2__Quantity__c, 100);
        }
        Test.stopTest();
    }

    @isTest static void test_LineItemDerivationsFour() {
        // Implement test code
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        System.assertEquals(0, [Select Count() From Apttus_Config2__LineItem__c]);

        // Add line items to cart.
        testLineItems = APTS_TestUtil.createLineItems(testCartId, testPriceList.Id, testProducts);
        System.assertEquals(testLineItems.size(), [Select Count() From Apttus_Config2__LineItem__c
                                                                    Where Id IN :testLineItems]);
        for(Apttus_Config2__LineItem__c li : testLineItems){
            li.Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_RENEWED;
            li.Apttus_Config2__Quantity__c = 11;           
        }
        update testLineItems;

        // Validate Derivation 4: Apttus_Config2__IsAssetPricing__c
        for(Apttus_Config2__LineItem__c li : [Select Id, Apttus_Config2__IsAssetPricing__c 
                                                        From Apttus_Config2__LineItem__c]){
            System.assertEquals(li.Apttus_Config2__IsAssetPricing__c, false);
        }
    }

    @isTest static void test_LineItemDerivationsFive() {
        // Implement test code
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        System.assertEquals(0, [Select Count() From Apttus_Config2__LineItem__c]);

        // Add line items to cart.
        testLineItems = APTS_TestUtil.createLineItems(testCartId, testPriceList.Id, testProducts);
        // clone and create the lines again.
        List<Apttus_Config2__LineItem__c> testLineItemsClone = testLineItems.deepClone(false);
        Integer counter = 1;
        for(Apttus_Config2__LineItem__c li : testLineItemsClone){
            li.Apttus_Config2__PrimaryLineNumber__c = testLineItems.size()+counter;
            li.Apttus_Config2__LineNumber__c = testLineItems.size()+counter;
            counter ++;
        }
        insert testLineItemsClone;

        // Validate Derivation 5: APTS_Total_Ramp_Quantity__c
        for(Apttus_Config2__LineItem__c li : [Select Id, APTS_Total_Ramp_Quantity__c, Apttus_Config2__Quantity__c, Apttus_Config2__EndDate__c 
                                                From Apttus_Config2__LineItem__c
                                                    where Id IN :testLineItemsClone]){
            System.assertEquals(li.Apttus_Config2__Quantity__c*2, li.APTS_Total_Ramp_Quantity__c);
        }
    }

    @isTest static void test_LineItemDerivationsSix() {
        // Implement test code
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        System.assertEquals(0, [Select Count() From Apttus_Config2__LineItem__c]);

        // Add line items to cart.
        testLineItems = APTS_TestUtil.createLineItems(testCartId, testPriceList.Id, testProducts);
        
        // clone and create the lines again.
        List<Apttus_Config2__LineItem__c> testLineItemsClone = testLineItems.deepClone(false);
        Integer counter = 1;
        for(Apttus_Config2__LineItem__c li : testLineItemsClone){
            li.Apttus_Config2__PrimaryLineNumber__c = testLineItems.size()+counter;
            li.Apttus_Config2__LineNumber__c = testLineItems.size()+counter;
            li.Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_RENEWED; 
            counter ++;
        }
        insert testLineItemsClone;

        // Validate Derivation 6: APTS_Total_Ramp_Quantity__c
        for(Apttus_Config2__LineItem__c li : [Select Id, APTS_Manual_Discount__c 
                                                    From Apttus_Config2__LineItem__c
                                                            Where Id IN :testLineItemsClone]){
        //    System.assertEquals(li.APTS_Manual_Discount__c, 0);
        }
    }

    @isTest static void test_LineItemDerivationsSeven() {
        // Implement test code
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        System.assertEquals(0, [Select Count() From Apttus_Config2__LineItem__c]);

        // Add line items to cart.
        testLineItems = APTS_TestUtil.createLineItems(testCartId, testPriceList.Id, testProducts);
        
        // clone and create the lines again.
        List<Apttus_Config2__LineItem__c> testLineItemsClone = testLineItems.deepClone(false);
        Integer counter = 1;
        for(Apttus_Config2__LineItem__c li : testLineItemsClone){
            li.Apttus_Config2__PrimaryLineNumber__c = testLineItems.size()+counter;
            li.Apttus_Config2__LineNumber__c = testLineItems.size()+counter;
            li.Apttus_Config2__SellingFrequency__c = APTS_CONSTANTS.LI_FREQUENCY_ONETIME; 
            counter ++;
        }
        insert testLineItemsClone;

        // Validate Derivation 7: Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c
        for(Apttus_Config2__LineItem__c li : [Select Id, Apttus_Config2__StartDate__c,  Apttus_Config2__EndDate__c
                                                    From Apttus_Config2__LineItem__c
                                                            Where Id IN :testLineItemsClone]){
            System.assertEquals(li.Apttus_Config2__StartDate__c, null);
            System.assertEquals(li.Apttus_Config2__EndDate__c, null);
        }
    }
    
    static testMethod void testcopyDealGuidanceZScaler() {
        Test.startTest();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP1' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Zscaler');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
       
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;
        
        String proposalId = proposal.Id;
        
        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;          
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        
        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();

        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId = lineItemList[0].Id;
        configId = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem1.Apttus_Config2__ExtendedPrice__c=NULL;
        }
        update lineItemList; 
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=50;
            lineItem1.Apttus_Config2__ExtendedPrice__c=1000;
       //     lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
         for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=9;
       //      lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-26;
        } 
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-51;
        } 
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-61;
        }
        update lineItemList;
       Test.stopTest();
    }
    
    static testMethod void testcopyDealGuidancePartner() {
        Test.startTest();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP1' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Partner');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
       
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;
        
        String proposalId = proposal.Id;
        
        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;          
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        
        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();

        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId = lineItemList[0].Id;
        configId = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem1.Apttus_Config2__ExtendedPrice__c=NULL;
        }
        update lineItemList; 
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            
            lineItem1.Apttus_Config2__ExtendedPrice__c=1000;
            lineItem1.APTS_Total_Discount_Percentage__c=9;
       //      lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=50;
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-1;
        } 
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-6;
        } 
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-11;
        }
        update lineItemList;
        Test.stopTest();
    }
    
    static testMethod void summaryGroupCredit() {
        Test.startTest();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        
        Product2 tp = new Product2();
        tp.Name = 'test product 1';
        tp.Apttus_Config2__ConfigurationType__c = 'Standalone';
        tp.ProductCode = 'ZSC-SIP';
        tp.Family = 'Zscaler Products';
        tp.Product_Line__c = 'Support';
        tp.IsActive = true;
        tp.Product_Line__c = 'Support';
        insert tp;
        
        Map<id,product2> prdlistMap = new map<Id,product2> ( [Select Id From Product2 Where ProductCode = 'ZSC-SIP' ]);
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
                
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;
        
        String proposalId = proposal.Id;
        
        APTS_TestUtil.createProposalLineItem(proposalId, tp.id);
        
        Apttus_Config2__PriceListItem__c PriceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;    
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c IN : prdlistMap.keySet() And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;          
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        
        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();

        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        
        List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId1 = lineItemList[0].Id;
        configId1 = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__LineStatus__c = 'Cancelled';
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
        }
        update lineItemList;
        
        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId1 + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 2;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__SellingFrequency__c = 'One Time';
        lineItemToInsert.Apttus_Config2__SellingTerm__c = 12;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        lineItemToInsert.Apttus_Config2__LineStatus__c = 'Cancelled';
        lineItemToInsert.Apttus_Config2__PriceAdjustment__c = 100;
        insert lineItemToInsert;
        
        List<Apttus_Config2__SummaryGroup__c> summaryGroupList = new List<Apttus_Config2__SummaryGroup__c>();
        Apttus_Config2__SummaryGroup__c summaryGroup1 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup1.Name = 'Total (Yearly)';
        summaryGroup1.Apttus_Config2__LineNumber__c = 1;
        summaryGroup1.APTS_Credit__c = 100;
        summaryGroup1.Apttus_Config2__NetPrice__c = 100;
        summaryGroup1.Apttus_Config2__ConfigurationId__c = configId1;
        summaryGroup1.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup1);
        
        Apttus_Config2__SummaryGroup__c summaryGroup2 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup2.Name = 'Total (One Time)';
        summaryGroup2.Apttus_Config2__LineNumber__c = 2;
        summaryGroup2.APTS_Credit__c = 100;
        summaryGroup2.Apttus_Config2__NetPrice__c = 100;
        summaryGroup2.Apttus_Config2__ConfigurationId__c = configId1;
        summaryGroup2.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup2);
        
        Apttus_Config2__SummaryGroup__c summaryGroup3 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup3.Name = 'Grand Total';
        summaryGroup3.Apttus_Config2__LineNumber__c = 3;
        summaryGroup3.APTS_Credit__c = 200;
        summaryGroup3.Apttus_Config2__NetPrice__c = 200;
        summaryGroup3.Apttus_Config2__ConfigurationId__c = configId1;
        summaryGroup3.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup3);
        
        insert summaryGroupList;
        String soqlQuery1 = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId1 + '\'');
        Apttus_Config2__LineItem__c lineItemToClone1 = (Apttus_Config2__LineItem__c)Database.query(soqlQuery1);
        Apttus_Config2__LineItem__c lineItemToInsert1 = lineItemToClone1.clone(false,true,false,false);
        lineItemToInsert1.Apttus_Config2__ItemSequence__c = 3;
        lineItemToInsert1.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert1.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert1.Apttus_Config2__EndDate__c = Date.today() + 365;
        insert lineItemToInsert1;
        
        Test.stopTest();
    }
    
    private static String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
}