@isTest
public class APTSCU_CreateProposalUtilityTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string cartId;
    public static list<Apttus_Config2__AssetLineItem__c> assetList;
    public static string prdId;
    public static string PricebookID;
    public static Apttus__APTS_Template__c template;

   static
    {
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        //insert TestDatafactory_Zscaler.liketolike();
        //insert TestDatafactory_Zscaler.skusNSInteg();
        assetList = new list<Apttus_Config2__AssetLineItem__c>();

        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        Apttus__ComplySystemProperties__c customSetting1  = new Apttus__ComplySystemProperties__c(Name = 'System Properties');
        customSetting1.Apttus__MergeWebserviceEndpoint__c = 'https://mergews.apttus.net/cgi-bin/MergeServer/Bin/MMCGI.exe';
        insert customSetting1;

        Apttus_Config2__ConfigSystemProperties__c customSetting2 = new Apttus_Config2__ConfigSystemProperties__c(Name = 'System Properties');
        customSetting2.Apttus_Config2__InstanceUrl__c = System.URL.getSalesforceBaseURL().toExternalForm();
        insert customSetting2;

        Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;

        /*template=new Apttus__APTS_Template__c(Name = 'Zscaler Proposal Template');
        insert template;

        Blob b = Blob.valueOf('Test Data');

        Attachment attachment = new Attachment();
        attachment.ParentId = template.Id;
        attachment.Name = 'Test Attachment for Parent.docx';
        attachment.Body = b;

        insert(attachment);
        */
        acc = APTS_TestUtil.creatAccount ();
        //pricelist = APTS_TestUtil.createpricelist ();
        PricebookID=Test.getStandardPricebookId();
        //PricebookID=[Select Id from PriceBook2 where IsStandard = FALSE LIMIT 1].Id;
        opp = APTS_TestUtil.createOpportunity (acc.Id,pricelist.Id);
        opp.Pricebook2Id=PricebookID;
        update opp;


        Opportunity opp1 = [select Id,Pricebook2Id from  Opportunity where id = :opp.ID];
        PricebookID = opp1.Pricebook2Id;

        prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);

        prdId = APTS_TestUtil.createProduct ();
        PricebookEntry entry;
        Apttus_Config2__AssetLineItem__c  asset;
        Apttus_Proposal__Proposal_Line_Item__c prl;
        try{
            entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=PricebookID,
                                                    Product2Id=prdId,UnitPrice=100.0);
            insert entry;

        prl = APTS_TestUtil.createProposalLineItem(prop.Id,prdId);
        asset = APTS_TestUtil.createassetlineItems (prop.Id,acc.id,prdId,prl.id);
        assetList = [select id,Apttus_Config2__SellingTerm__c,APTS_ACV__c,Apttus_QPConfig__ProposalId__c,Apttus_Config2__ProductId__c,Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__StartDate__c,
                                                                  Apttus_Config2__EndDate__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__BundleAssetId__c, CreatedDate from Apttus_Config2__AssetLineItem__c where id=:asset.id];


        cartid = APTSCU_CreateProposalUtility.CreateCartForProposal(prop.id);
        }
        catch(Exception e){}

    }

    //*** Added by Anay
    @isTest static void createOpportunityProduct(){
        Test.startTest();


        Product2 prodOpt=new Product2(Name='OptProd1',ProductCode='OPT-SIP1');
        insert prodOpt;
        PricebookEntry entry;
        try{
            entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=PricebookID,
                                                Product2Id=prodOpt.Id,UnitPrice=100.0);
            insert entry;
        }
        catch(Exception e){}
        Apttus_Proposal__Proposal_Line_Item__c prl = APTS_TestUtil.createProposalLineItem(prop.Id,prodOpt.Id);
        prl.Apttus_QPConfig__OptionId__c=prdId;
        update prl;
        try{
            APTSCU_CreateProposalUtility.createOpportunityProduct(prop.Id,opp.Id);
        }
        catch(Exception e){}
        Test.stopTest();
    }
    //@isTest static void generateDocument(){
      //  Test.startTest();
//        APTSCU_CreateProposalUtility.generateDocument(prop.Id,Apttus_Config2__ConfigSystemProperties__c.getAll().get('System Properties').Apttus_Config2__InstanceUrl__c + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId(),template.Id, UserInfo.getSessionId());
        //APTSCU_CreateProposalUtility.generateDocument(prop.Id,Apttus__ComplySystemProperties__c.getAll().get('System Properties').Apttus__MergeWebserviceEndpoint__c,template.Id, UserInfo.getSessionId());
       // Test.stopTest();
    //}
    @isTest static void finalizeCartRemote2() {
        TriggerUtility.prospectTypeUpdExecuted();
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = ZSCProd.Id;
        Id priceListId = pricelist.Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = PriceListItem1.Id;
        
        Account account = new Account(Name = 'Zscaler');
        insert account;
        
        Id accountId = account.Id;

        Test.startTest();
        Opportunity opportunity = new Opportunity(Pricebook2Id = PricebookID, Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        String proposalId = proposal.Id;

        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId2 = result.CartId;
        List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();
        lineitemlist = [select id, APTS_MRR__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];

        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId2;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);

        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        APTSCU_CreateProposalUtility.finalizeCartRemote(cartId2,null);
        Test.stopTest();
    }
    //*****************

  /*   @isTest static void addAssetLineItemsToCart() {
        Test.startTest();

        APTSCU_CreateProposalUtility.addAssetLineItemsToCart(acc.id,cartid,assetList);
        Test.stopTest();
    }


     @isTest static void addAssetLineItemsToCartRemoteWithoutPremier() {
        Test.startTest();

        APTSCU_CreateProposalUtility.addAssetLineItemsToCartRemote(acc.id,cartid,assetList,false,null);
        Test.stopTest();
    }

         @isTest static void addAssetLineItemsToCartRemoteWithPremier() {
        Test.startTest();

        APTSCU_CreateProposalUtility.addAssetLineItemsToCartRemote(acc.id,cartid,assetList,true,prdId);
        Test.stopTest();
    }
*/
             @isTest static void createQuoteOrProposal() {
        Test.startTest();

        APTSCU_CreateProposalUtility.createQuoteOrProposal(opp,Date.today(), null, null);
        Test.stopTest();
    }
                @isTest static void deleteRampLineItem() {
        Test.startTest();
        Apttus_Config2__LineItem__c testLineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ItemSequence__c = 1,
                                                                                    Apttus_Config2__LineNumber__c = 1,
                                                                                    Apttus_Config2__StartDate__c = Date.today().addDays(10),
                                                                                    Apttus_Config2__EndDate__c = Date.today().addDays(400),
                                                                                    Apttus_Config2__PriceType__c = 'Usage'
                                                                                   );
        testLineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
        testLineItem1.Apttus_Config2__IsPrimaryLine__c = false;
        testLineItem1.Apttus_Config2__IsPrimaryRampLine__c = false;
        testLineItem1.Apttus_Config2__LineStatus__c = 'Renewed';
        testLineItem1.Apttus_Config2__LineType__c = 'Product/Service';
        testLineItem1.Apttus_Config2__SellingTerm__c = 1;
        testLineItem1.Apttus_Config2__PriceListId__c = Pricelist.Id;
        testLineItem1.Apttus_Config2__PriceMethod__c = 'Per Unit';
        testLineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
        testLineItem1.Apttus_Config2__PricingStatus__c = 'Pending';
        testLineItem1.Apttus_Config2__ListPrice__c = 50.00;
        testLineItem1.Apttus_Config2__BasePrice__c = 10.00;
        testLineItem1.Apttus_Config2__ExtendedPrice__c = 20.00;
        testLineItem1.Apttus_Config2__NetPrice__c = 50.00;
        testLineItem1.Apttus_Config2__Quantity__c=2;
        testLineItem1.Apttus_Config2__ConfigurationId__c =cartid;
        testLineItem1.Apttus_Config2__ProductId__c = prdId;
        testLineItem1.Apttus_Config2__StartDate__c = Date.today();
        testLineItem1.Apttus_Config2__EndDate__c = Date.today().addYears(2);
        testLineItem1.Apttus_Config2__PrimaryLineNumber__c = 12;
        testLineItem1.Apttus_Config2__LineNumber__c = 12;
        testLineItem1.Apttus_Config2__ItemSequence__c = 1;
        testLineItem1.APTS_ACV__c = 200;
        testLineItem1.APTS_Renewal_Base__c=500;
        insert testLineItem1;
        APTSCU_CreateProposalUtility.deleteRampLineItem(cartid,acc.id);
        Test.stopTest();
    }
     @isTest static void repriceCart() {
        Test.startTest();
        try{
            APTSCU_CreateProposalUtility.repriceCart(cartid);
        }
        catch(Exception e){}
        Test.stopTest();
    }

                    @isTest static void finalizeCartRemote() {
        Test.startTest();
        APTSCU_CreateProposalUtility.getOpportunitySO(opp.id);
        APTSCU_CreateProposalUtility.getCartSO(cartid);
        //Apttus_Config2__ConfigSystemProperties__c config=new Apttus_Config2__ConfigSystemProperties__c(Name='System Properties',Apttus_Config2__InstanceUrl__c=URL.getSalesforceBaseUrl().toExternalForm() + '/');
        //insert config;
                        APTSCU_CreateProposalUtility.getInstanceUrl();
                        APTSCU_CreateProposalUtility.nullOrEmpty('test');
                        APTSCU_CreateProposalUtility.isNilValue('test');
                       APTSCU_CreateProposalUtility.nullValue('test','test1');
                        APTSCU_CreateProposalUtility.getRecordTypeIdForName('Apttus_Config2__AssetLineItem__c','test');
        APTSCU_CreateProposalUtility.finalizeCartRemote(cartid,null);
        Test.stopTest();
    }


}