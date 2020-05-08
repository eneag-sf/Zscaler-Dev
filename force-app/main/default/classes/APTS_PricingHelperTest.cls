/*************************************************************************************************************************
 @Name: APTS_PricingHelperTest
 @Author: Anay Bhande
 @Created Date: 16/12/2016
 @Descripton: Test Class for APTS_PricingHelper
 @Used By:
*************************************************************************************************************************/
@isTest
public class APTS_PricingHelperTest {
    public static testMethod void TestHelper() {
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        List<Product2> prodlist=new List<Product2>();
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1', Zscaler_Product_Family__c = 'ZIA', APTS_DisableManualAdjustments__c = true);
        Product2 prod=new Product2(Name='TestProd',ProductCode = 'ZSC-SIP1', Zscaler_Product_Family__c = 'ZPA');
        prodlist.add(prod);
        prodlist.add(ZSCprod);
        insert prodlist;
        Id productId = prod.Id;
        Apttus_Config2__PriceList__c Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        Id priceListId = Pricelist.Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Apttus_Config2__PriceListItem__c PriceListItem2=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = ZscProd.Id,Apttus_Config2__Active__c = true);
        insert PriceListItem2;
        Id priceListItemId = PriceListItem1.Id;
        Account account = new Account(Name = 'Test Account');
        insert account;

        Id accountId = account.Id;

        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, Type = 'New Business');
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

        prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = ZSCProd.Id;
        requests.SelectedProducts.add(prodDO);

        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        system.debug('Queries used TestHelper before: ' +Limits.getQueries());
        Test.startTest();

        List<Apttus_Config2__LineItem__c> lineItem = [select Id, Name, Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__StartDate__c,
                Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,Apttus_Config2__IsPrimaryRampLine__c,
                Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,Apttus_Config2__PricingStatus__c,
                Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, Apttus_Config2__SellingTerm__c,
                Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c, Apttus_Config2__PriceListItemId__c,
                Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c, APTS_Partner_Disc__c, APTS_Deal_Reg_Disc__c,
                APTS_New_Logo_Disc__c, Apttus_Config2__AdjustmentType__c, Apttus_Config2__AllowManualAdjustment__c, Pricing_Callback_Fields__c
                from Apttus_Config2__LineItem__c
                where Apttus_Config2__ConfigurationId__c =: cartId
                ];
        System.debug('>>>> lineItem: ' + lineItem[0].Pricing_Callback_Fields__c);
//        lineItem.APTS_Partner_Disc__c=10;
 //       lineItem.APTS_Deal_Reg_Disc__c=10;
        APTS_PricingHelper.calculateDiscounts(lineItem[0]);
        APTS_PricingHelper.getUpliftYear4(lineItem[0]);
        APTS_PricingHelper.getUpliftYear5(lineItem[0]);
        //APTS_PricingHelper.getCreditTerminatin();
        //APTS_PricingHelper.getBuyBackCredit();
        APTS_PricingHelper.calculateDiscounts(lineItem[0]);

        lineItem[0].Apttus_Config2__AdjustmentType__c='Price Override';
        lineItem[0].Apttus_Config2__BaseExtendedPrice__c=0;
        lineItem[0].APTS_Manual_Discount__c=10;
        lineItem[0].Apttus_Config2__NetPrice__c=100;
        lineItem[0].APTS_Selling_Term__c=50;
        lineItem[1].Apttus_Config2__AdjustmentType__c='Price Override';
        lineItem[1].Apttus_Config2__BaseExtendedPrice__c=1000;
        lineItem[1].APTS_Manual_Discount__c=10;
        lineItem[1].Apttus_Config2__NetPrice__c=100;
        lineItem[1].APTS_Selling_Term__c=50;
        update lineItem;
        APTS_PricingHelper.calculateDiscounts(lineItem[0]);
        APTS_PricingHelper.calculateDiscounts(lineItem[1]);
        APTS_PricingHelper.calculateACVnMRR(lineItem[1],0);
        APTS_PricingHelper.calculateACVnMRR(lineItem[0],10);
        APTS_PricingHelper.calculateACVnMRR(lineItem[0],30);
        APTS_PricingHelper.getUpliftYear4(lineItem[0]);
        APTS_PricingHelper.getUpliftYear5(lineItem[0]);
        APTS_PricingHelper.AggrLineInfo aggr;
        aggr=new APTS_PricingHelper.AggrLineInfo(lineItem[1]);
        aggr.addLI(lineItem[1]);
        aggr=new APTS_PricingHelper.AggrLineInfo();

        lineItem[0].Apttus_Config2__BaseExtendedPrice__c=900;
        lineItem[0].Apttus_Config2__AdjustmentType__c='Markup Amount';
        lineItem[1].Apttus_Config2__AdjustmentType__c='Discount Amount';
        update lineItem;
        APTS_PricingHelper.calculateDiscounts(lineItem[0]);
        APTS_PricingHelper.calculateDiscounts(lineItem[1]);

        lineItem[0].Apttus_Config2__AdjustmentType__c='% Markup';
        update lineItem;
        APTS_PricingHelper.calculateDiscounts(lineItem[0]);
        APTS_PricingHelper.booster();
        system.debug('Queries used TestHelper: ' +Limits.getQueries());
        Test.stopTest();
    }
}