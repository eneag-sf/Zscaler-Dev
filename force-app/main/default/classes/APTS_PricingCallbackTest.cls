/**
 * @File Name          : APTS_PricingCallbackTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/30/2020, 7:05:17 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/30/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class APTS_PricingCallbackTest {

    static testMethod void PricingcallbackTest() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        Apttus_Config2__ProductConfiguration__c configuration = [select Id from Apttus_Config2__ProductConfiguration__c Limit 1];
        Apttus_Config2.PricingWebService.computeTotalPriceForCart(configuration.Id);
        Test.stopTest();
    }
    static testMethod void PricingcallbackTest2() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        Account acc = [Select id, APTS_Asset_SKU__c from Account Limit 1];
        acc.APTS_Asset_SKU__c = '';
        update acc;
        Apttus_Config2__ProductConfiguration__c configuration = [select Id from Apttus_Config2__ProductConfiguration__c Limit 1];
        Apttus_Config2.PricingWebService.computeTotalPriceForCart(configuration.Id);
        //APTS_PricingCallBack.booster();
        Test.stopTest();
    }
	static testMethod void PricingcallbackTest3() {
		APTS_PricingCallBack booste= new APTS_PricingCallBack();
		booste.booster();
	}
    @testSetup
    static void setupTest(){
        TriggerUtility.prospectTypeUpdExecuted();
        createAllCustomSetting();

        //Insert Account
        Account account = new Account ();
        account.Name = APTS_CONSTANTS.ACC_NAME_ZSCALER;
        account.APTS_Platform_Subscription_End_Date__c = Date.today();
        account.APTS_Asset_SKU__c = APTS_CONSTANTS.PROD_SKU_PSUPPORT;
        account.Premium_Support_Source__c = APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
        insert account;
        Id accountId = account.Id;

        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;

        Id standardPB = Test.getStandardPricebookId();
        //Insert Opportunity
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = label.Stage_1_Alignment/*'0 - Initial Prospecting'*/;
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = account.Id;
        opp.Price_List__c = pricelist.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();
        prop.Apttus_QPConfig__PriceListId__c = pricelist.Id;
        prop.Apttus_Proposal__Account__c = accountId;
        prop.Apttus_QPConfig__BillToAccountId__c = accountId;
        prop.Apttus_QPConfig__ShipToAccountId__c = accountId;
        prop.Apttus_Proposal__Opportunity__c = opp.Id;
        prop.Apttus_Proposal__Primary__c  = true;
        prop.Apttus_Proposal__Approval_Stage__c = 'Draft';
        prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        prop.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(36);
        //prop.APTS_SBQuote_Id__c = SBQuote.Id;
        insert prop;

        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Product1', APTS_CONSTANTS.PROD_SKU_ZPROSUITE, 'Products', 'Standalone', 'ZIA'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_PSUPPORT, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_ULIFTY4, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_ULIFTY5, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_BUYBACK, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_TAMTOP, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_ONE8TAMTOP, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_MPSUPPORT, 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_ZPA_PRO, 'Products', 'Standalone', 'ZPA'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL, 'Products', 'Standalone', 'ZIA'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE, 'Products', 'Standalone', 'ZIA'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO, 'Products', 'Standalone', 'ZIA'));

        insert listProduct;

        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[0].ID));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[1].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[2].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[3].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[4].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[5].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[6].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[7].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[8].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[9].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[10].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[11].Id));
        listPLI[7].Apttus_Config2__ChargeType__c = APTS_CONSTANTS.PROD_CHARGETYPE_SFEE;
        listPLI[7].Apttus_Config2__PriceType__c = APTS_CONSTANTS.PROD_PRICETYPE_RECURRING;
        insert listPLI;

        Id cartId = createCart(prop.Id);

        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request2 = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        request2.CartId = cartId;
        request2.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        request2.SelectedProducts.add(createSelectProductDo(listProduct[0].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[1].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[2].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[3].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[4].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[5].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[6].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[7].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[7].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[1].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[8].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[9].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[11].Id, 1, Date.today(), Date.today().addMonths(36), 4));

        Apttus_CPQApi.CPQ.AddMultiProductResponseDO  response2 = Apttus_CPQApi.CPQWebService.addMultiProducts(request2);

        Apttus_Config2__ProductConfiguration__c configuration = [select Id from Apttus_Config2__ProductConfiguration__c Limit 1];

        List<Apttus_Config2__LineItem__c> listLineItem = [select Id, Name, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
                                                           Apttus_Config2__Quantity__c, Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.ProductCode,
                                                           Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c,Apttus_Config2__Frequency__c,
                                                           Apttus_Config2__PriceListId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__BasePriceOverride__c,
                                                           Apttus_Config2__NetUnitPrice__c, Apttus_Config2__NetPrice__c,Apttus_Config2__BillingFrequency__c,
                                                           Apttus_Config2__PriceAdjustment__c, Apttus_Config2__AdjustmentType__c, Pricing_Callback_Fields__c
                                                           from Apttus_Config2__LineItem__c
                                                           where Apttus_Config2__ConfigurationId__c =: configuration.Id
                                                          ];

        List<Apttus_Config2__ProductAttributeValue__c> listAttributeValue = new List<Apttus_Config2__ProductAttributeValue__c>();
        listAttributeValue.add(new Apttus_Config2__ProductAttributeValue__c(APTS_Buy_Back_Period__c = '3',
                                                                            APTS_Premium_Support_Type__c = APTS_CONSTANTS.PAV_PST_ZSCALER,
                                                                            Support_Source__c = 'Net',
                                                                            Support_Percent__c = 15.0,
                                                                            Apttus_Config2__LineItemId__c = listLineItem[9].ID));
        listAttributeValue.add(new Apttus_Config2__ProductAttributeValue__c(APTS_Buy_Back_Period__c = '3',
                                                                            APTS_Premium_Support_Type__c = APTS_CONSTANTS.PAV_PST_PQSUPPORT,
                                                                            Apttus_Config2__LineItemId__c = listLineItem[0].ID));
        insert listAttributeValue;

        Apttus_Config2__AssetLineItem__c AssetLineItem1 = createAssetLineItem(prop, listPLI[7].Id, listProduct[7].Id, 'Product/Service',APTS_CONSTANTS.PROD_CHARGETYPE_SFEE,
                                                                                APTS_CONSTANTS.PROD_PRICETYPE_RECURRING, 'Flat Price','Each', 100 );

        insert AssetLineItem1;

        system.debug('***** Counte Line iteam :' +listLineItem.size());
        for(Apttus_Config2__LineItem__c lineItem : listLineItem){
            if( lineItem.Apttus_Config2__StartDate__c == null)
                lineItem.Apttus_Config2__StartDate__c = Date.today();
            if( lineItem.Apttus_Config2__EndDate__c == null)
                lineItem.Apttus_Config2__EndDate__c = Date.today().addMonths(36);
            if( lineItem.Apttus_Config2__SellingTerm__c == null)
                lineItem.Apttus_Config2__SellingTerm__c = 3;
            if( lineItem.Apttus_Config2__BasePrice__c == null)
                lineItem.Apttus_Config2__BasePrice__c = 100;
            if( lineItem.Apttus_Config2__BasePriceOverride__c == null)
                lineItem.Apttus_Config2__BasePriceOverride__c = 100;
            if( lineItem.Apttus_Config2__NetUnitPrice__c == null)
                lineItem.Apttus_Config2__NetUnitPrice__c = 100;
            if( lineItem.Apttus_Config2__NetPrice__c == null)
                lineItem.Apttus_Config2__NetPrice__c = 100;
            if( lineItem.Apttus_Config2__BillingFrequency__c == null)
                lineItem.Apttus_Config2__BillingFrequency__c = 'Yearly';
            if( lineItem.Apttus_Config2__Frequency__c == null)
                lineItem.Apttus_Config2__Frequency__c = 'Yearly';
            if( lineItem.Apttus_Config2__SellingFrequency__c == null)
                lineItem.Apttus_Config2__SellingFrequency__c = 'Yearly';
            if( lineItem.Apttus_Config2__BaseExtendedPrice__c == null)
                lineItem.Apttus_Config2__BaseExtendedPrice__c = 100;

            system.debug('***** Satrt Date : ' + lineItem.Apttus_Config2__StartDate__c);
            system.debug('***** End Date : ' + lineItem.Apttus_Config2__EndDate__c);

        }
        if(listLineItem.size() > 9){
            listLineItem[9].Apttus_Config2__AttributeValueId__c = listAttributeValue[0].Id;
            listLineItem[1].Apttus_Config2__AttributeValueId__c = listAttributeValue[1].Id;
        }
        if(listLineItem.size() > 8){
            listLineItem[8].Apttus_Config2__ChargeType__c = APTS_CONSTANTS.PROD_CHARGETYPE_SFEE;
            listLineItem[8].Apttus_Config2__PriceType__c = APTS_CONSTANTS.PROD_PRICETYPE_RECURRING;
        }
        if(listLineItem.size() > 7)
            listLineItem[7].Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_CANCELLED;
        if(listLineItem.size() > 5)
            listLineItem[5].Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_AMENDED;
        if(listLineItem.size() > 4)
            listLineItem[4].Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_RENEWED;
        system.debug('***** JSON'+JSON.serialize(listLineItem));
        update listLineItem;
        listLineItem = [select Id, Name, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
                                                           Apttus_Config2__Quantity__c, Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.ProductCode,
                                                           Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c,
                                                           Apttus_Config2__PriceListId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__BasePriceOverride__c,
                                                           Apttus_Config2__PriceAdjustment__c, Apttus_Config2__AdjustmentType__c, Pricing_Callback_Fields__c
                                                           from Apttus_Config2__LineItem__c
                                                           where Apttus_Config2__ConfigurationId__c =: configuration.Id
                                                          ];
        system.debug('***** JSON'+JSON.serialize(listLineItem));


    }
    public static void createAllCustomSetting(){

        List<Apttus__APTS_Admin__c> listAdmin = new List<Apttus__APTS_Admin__c>();
        listAdmin.add(new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book'));
        listAdmin.add(new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List'));
        listAdmin.add(new Apttus__APTS_Admin__c(Name = 'APTS_Designated TAM Factor', Apttus__Value__c = '30000'));
        insert listAdmin;

        Pricebook2 standardPB1 = new Pricebook2(Name = 'Apttus Default Price Book', Description = 'Price Book 2009 Products', IsActive = true);
        insert standardPB1 ;

        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
        insert configCustomClassesProperty;

        Apttus_Config2__ConfigLineItemCustomFields__c ConfigLineItemCustomSetting = new Apttus_Config2__ConfigLineItemCustomFields__c();
        ConfigLineItemCustomSetting.name = 'System Properties';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames__c = 'Product_Name__c,APTS_ProductCode__c,Product_Category__c,APTS_MRR__c,APTS_Prev_MRR__c'
                                                                            +',APTS_ACV__c,APTS_Selling_Term__c,APTS_Quantity_Check__c,APTS_Total_Ramp_Quantity__c'
                                                                            +',APTS_Ramp_End_Date__c,APTS_New_Logo_Disc__c,APTS_Deal_Reg_Disc__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames2__c = 'APTS_Partner_Disc__c,APTS_Manual_Discount__c,APTS_Total_Discount_Percentage__c'
                                                                            +',APTS_Total_Term__c,APTS_Discount_Category_A__c,Apttus_Config2__LineNumber__c'
                                                                            +',Apttus_Config2__LineStatus__c,Apttus_Config2__Quantity__c,Apttus_Config2__ChargeType__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames3__c = 'Apttus_Config2__PriceType__c,Apttus_Config2__BasePrice__c,Apttus_Config2__SellingTerm__c'
                                                                            +',Apttus_Config2__PricingStatus__c,Apttus_Config2__AdjustmentType__c'
                                                                            +',Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__BaseExtendedPrice__c,Pricing_Callback_Fields__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames4__c = 'Apttus_Config2__AssetLineItemId__r.Apttus_Config2__Quantity__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.APTS_Partner_Disc__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.APTS_Deal_Reg_Disc__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames5__c = 'Apttus_Config2__ProductId__r.APTS_Sync_Quantity_with_Platform__c '
                                                                            +',Apttus_Config2__ProductId__r.APTS_Buyback_Eligible__c '
                                                                            +',Apttus_Config2__AttributeValueId__r.APTS_Buy_Back_Period__c '
                                                                            +',Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c';
        insert ConfigLineItemCustomSetting;
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
    }

    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        return createProduct(PRoductName, pcode, pfamily, sConfigType, 'ZIA');
    }

    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType, String zscalerProductFamily) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        productSO.Apttus_Config2__ConfigurationType__c = sConfigType;
        productSO.Apttus_Config2__HasAttributes__c = false;
        productSO.Apttus_Config2__HasOptions__c = false;
        productSO.APTS_Buyback_Eligible__c = true;
        productSO.Zscaler_Product_Family__c = zscalerProductFamily;
        productSO.APTS_DisableManualAdjustments__c = false;
        return productSO;
    }

    public static Apttus_Config2__PriceListItem__c createPriceListItem(Id PriceListId, Id ProductId) {

        Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c();
        priceListItem.Apttus_Config2__PriceListId__c = PriceListId;
        priceListItem.Apttus_Config2__ProductId__c = ProductId;
        priceListItem.Apttus_Config2__ChargeType__c = 'Standard Price';
        priceListItem.Apttus_Config2__PriceType__c = 'One Time';
        priceListItem.Apttus_Config2__PriceMethod__c = 'Flat Price';
        priceListItem.Apttus_Config2__ListPrice__c = 100;
        priceListItem.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-100);
        priceListItem.Apttus_Config2__ExpirationDate__c = Date.today().addDays(365);
        priceListItem.Apttus_Config2__Frequency__c = 'Yearly';
        priceListItem.Apttus_Config2__PriceUom__c = 'Each';
        priceListItem.Apttus_Config2__Active__c = true;
        priceListItem.Apttus_Config2__BillingFrequency__c = 'Yearly';
        priceListItem.Apttus_Config2__BillingRule__c = 'Bill In Advance';
        priceListItem.Apttus_Config2__DefaultSellingTerm__c = 2;
        return priceListItem;
    }

    public static Id createCart(Id propID){
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = propID;
        Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
        return response.CartId;
    }

    public static Apttus_CPQApi.CPQ.SelectedProductDO createSelectProductDo(Id productId, Integer quantity, date startDate, Date endDate, Integer sellingTerm){
        Apttus_CPQApi.CPQ.SelectedProductDO SelectedProductDO1 = new  Apttus_CPQApi.CPQ.SelectedProductDO();
        SelectedProductDO1.ProductId= productId;
        SelectedProductDO1.Quantity = quantity;
        SelectedProductDO1.SellingTerm = sellingTerm;
        SelectedProductDO1.StartDate = startDate;
        SelectedProductDO1.EndDate = endDate;
        return SelectedProductDO1;
    }

    public static Apttus_Config2__AssetLineItem__c createAssetLineItem(Apttus_Proposal__Proposal__c oProposal, Id PriceListItemId, Id ProductId,
                                                                        String sLineType, String sChargeType, String sPriceType,String sPriceMethod,
                                                                        String sPriceUOM, Decimal dBasePrice ){

        Apttus_Config2__AssetLineItem__c assetLine = new Apttus_Config2__AssetLineItem__c();
        assetLine.Apttus_QPConfig__ProposalId__c = oProposal.Id;
        assetLine.Apttus_Config2__AccountId__c = oProposal.Apttus_Proposal__Account__c;
        assetLine.Apttus_Config2__BillToAccountId__c = oProposal.Apttus_Proposal__Account__c;
        assetLine.Apttus_Config2__ShipToAccountId__c = oProposal.Apttus_Proposal__Account__c;
        assetLine.Apttus_Config2__PriceListId__c = oProposal.Apttus_QPConfig__PriceListId__c;
        assetLine.Apttus_Config2__StartDate__c = oProposal.Apttus_Proposal__ExpectedStartDate__c;
        assetLine.Apttus_Config2__EndDate__c = oProposal.Apttus_Proposal__ExpectedEndDate__c;
        assetLine.Apttus_Config2__BillingStartDate__c = oProposal.Apttus_Proposal__ExpectedStartDate__c;
        assetLine.Apttus_Config2__BillingEndDate__c = oProposal.Apttus_Proposal__ExpectedEndDate__c;
        assetLine.Apttus_Config2__PriceListItemId__c = PriceListItemId;
        assetLine.Apttus_Config2__ProductId__c = ProductId;
        assetLine.Apttus_Config2__LineNumber__c = 1;
        assetLine.Apttus_Config2__ItemSequence__c = 1;
        assetLine.Apttus_Config2__LineType__c = sLineType;
        //assetLine.Apttus_Config2__BillingPreferenceId__c = BillPreferenceId;
        assetLine.Apttus_Config2__BillingFrequency__c = 'Yearly';
        assetLine.Apttus_Config2__SellingFrequency__c = 'Yearly';
        assetLine.Apttus_Config2__BillingRule__c = 'Bill In Advance';
        assetLine.Apttus_Config2__ChargeType__c = sChargeType;
        assetLine.Apttus_Config2__PriceType__c = sPriceType;
        assetLine.Apttus_Config2__PriceMethod__c = sPriceMethod;
        assetLine.Apttus_Config2__PriceUom__c = sPriceUOM;
        assetLine.Apttus_Config2__BasePrice__c = dBasePrice;
        assetLine.Apttus_Config2__NetPrice__c = dBasePrice;
        assetLine.Apttus_Config2__BaseExtendedPrice__c = dBasePrice;
        assetLine.Apttus_Config2__SellingTerm__c = 4;
        assetLine.Apttus_Config2__Quantity__c = 2;
        assetLine.Apttus_Config2__IsPrimaryLine__c = true;
        assetLine.Apttus_Config2__Taxable__c = true;
        assetLine.Apttus_Config2__AssetStatus__c = 'Activated';
        assetLine.Apttus_Config2__NetUnitPrice__c = 100;

        return assetLine;
    }
    
    private static testMethod void validationCallbackTest() {

        //Insert Account
        /*Account account = new Account ();
        account.Name = APTS_CONSTANTS.ACC_NAME_ZSCALER;
        account.APTS_Platform_Subscription_End_Date__c = Date.today();
        account.APTS_Asset_SKU__c = APTS_CONSTANTS.PROD_SKU_PSUPPORT;
        account.Premium_Support_Source__c = APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
        insert account;
        Id accountId = account.Id;

        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;

        Id standardPB = Test.getStandardPricebookId();
        //Insert Opportunity
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = label.Stage_1_Alignment;//'0 - Initial Prospecting'
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = account.Id;
        opp.Price_List__c = pricelist.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.pricebook2Id = Test.getStandardPricebookId();
        insert opp;

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();
        prop.Apttus_QPConfig__PriceListId__c = pricelist.Id;
        prop.Apttus_Proposal__Account__c = accountId;
        prop.Apttus_QPConfig__BillToAccountId__c = accountId;
        prop.Apttus_QPConfig__ShipToAccountId__c = accountId;
        prop.Apttus_Proposal__Opportunity__c = opp.Id;
        prop.Apttus_Proposal__Primary__c  = true;
        prop.Apttus_Proposal__Approval_Stage__c = 'Draft';
        prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        prop.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(36);
        //prop.APTS_SBQuote_Id__c = SBQuote.Id;
        insert prop;

        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Product1', APTS_CONSTANTS.PROD_SKU_ZPROSUITE, 'Products', 'Standalone', 'ZIA'));
        listProduct.add(createProduct('Product2', APTS_CONSTANTS.PROD_SKU_MPSUPPORT, 'Products', 'Standalone'));
        
        insert listProduct;

        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[0].ID));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[1].Id));
        listPLI[1].Apttus_Config2__ChargeType__c = APTS_CONSTANTS.PROD_CHARGETYPE_SFEE;
        listPLI[1].Apttus_Config2__PriceType__c = APTS_CONSTANTS.PROD_PRICETYPE_RECURRING;
        insert listPLI;

        Id cartId = createCart(prop.Id);

        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request2 = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        request2.CartId = cartId;
        request2.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        request2.SelectedProducts.add(createSelectProductDo(listProduct[0].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        request2.SelectedProducts.add(createSelectProductDo(listProduct[1].Id, 1, Date.today(), Date.today().addMonths(36), 4));
       
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO  response2 = Apttus_CPQApi.CPQWebService.addMultiProducts(request2);

        Apttus_Config2__ProductConfiguration__c configuration = [select Id from Apttus_Config2__ProductConfiguration__c Limit 1];

        List<Apttus_Config2__LineItem__c> listLineItem = [select Id, Name, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
                                                                Apttus_Config2__Quantity__c, Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.ProductCode,
                                                                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__BasePrice__c,Apttus_Config2__Frequency__c,
                                                                Apttus_Config2__PriceListId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__BasePriceOverride__c,
                                                                Apttus_Config2__NetUnitPrice__c, Apttus_Config2__NetPrice__c,Apttus_Config2__BillingFrequency__c,
                                                                Apttus_Config2__PriceAdjustment__c, Apttus_Config2__AdjustmentType__c, Pricing_Callback_Fields__c
                                                            from Apttus_Config2__LineItem__c
                                                            where Apttus_Config2__ConfigurationId__c =: configuration.Id
                                                          ];
        
        Apttus_Config2__AssetLineItem__c assetLineItem1 = new Apttus_Config2__AssetLineItem__c(
                                                        Apttus_Config2__AccountId__c = accountId,
                                                        Apttus_Config2__ProductId__c = listProduct[0].Id,
                                                        Apttus_QPConfig__ProposalId__c = prop.Id,
                                                        Apttus_Config2__PriceListId__c = pricelist.Id,
                                                        Apttus_Config2__PriceListItemId__c = listPLI[0].Id,
                                                        Apttus_Config2__Quantity__c=1);
        insert assetLineItem1;

        Apttus_Config2__AssetLineItem__c assetLineItem2 = new Apttus_Config2__AssetLineItem__c(
                                                        Apttus_Config2__AccountId__c = accountId,
                                                        Apttus_Config2__ProductId__c = listProduct[1].Id,
                                                        Apttus_QPConfig__ProposalId__c = prop.Id,
                                                        Apttus_Config2__PriceListId__c = pricelist.Id,
                                                        Apttus_Config2__PriceListItemId__c = listPLI[1].Id,
                                                        Apttus_Config2__Quantity__c=2);
        insert assetLineItem2;

        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_PricingCallBack';
        custSetting.Name = 'System Properties';
        insert custSetting;
        
        Apttus_Config2__TempRenew__c assetItem1 = new Apttus_Config2__TempRenew__c(Apttus_Config2__AssetLineItemId__c=assetLineItem1.Id,Apttus_Config2__ActionName__c='Cancel');
        Apttus_Config2__TempRenew__c assetItem2 = new Apttus_Config2__TempRenew__c(Apttus_Config2__AssetLineItemId__c=assetLineItem2.Id,Apttus_Config2__ActionName__c='Amend',Apttus_Config2__Quantity__c=1);
        List<Apttus_Config2__TempRenew__c> assetItemList = new List<Apttus_Config2__TempRenew__c>{assetItem1,assetItem2};
        insert assetItemList;
        
        
        Test.setCurrentPage(Page.Apttus_Config2__CartDetailView);
        Test.startTest();
        Apttus_Config2.CallbackTester.testValidationCallback(configuration.Id,
                                                    new List<Apttus_Config2__LineItem__c>{listLineItem[0],listLineItem[1]},
                                                    assetItemList, 
                                                    new APTS_PricingCallBack()); 
        Test.stopTest();*/
    }
    /*TestDataHelper dataHelper=new TestDataHelper();
    
        //create and insert Account
        Account lstAccount = dataHelper.getAccount('Apttus Test 1');
        insert lstAccount;
        
        //create and insert user;
        User user = dataHelper.getUser('uniqueUser@apttus.com');
        
        //create and insert opportunity
        Opportunity opp =  dataHelper.getOpportunity('Apttus Test Opp', lstAccount, user.Id, 'Distributor');
        insert opp;
        opp = [SELECT ID,Name FROM Opportunity WHERE ID = :opp.Id]; 
        
        //create and insert products      always make sure that product created here kind of matches,real business products in your org
        Product2 testProduct = dataHelper.getProduct('BL420c Gen8 E5-2430 Standard');
        insert testProduct;
        
        //create and insert price list
        Apttus_Config2__PriceList__c priceListSO = dataHelper.getPriceList();
        insert priceListSO;
        
        
        //create and insert price list items for products that has been created for test class
        Apttus_Config2__PriceListItem__c plItem = dataHelper.getPriceListItem(priceListSO.Id, testProduct.Id, 'Standard Price', 'One Time', 'Per Unit', 9485, 9000, 10000, 'Unit Price');
        insert plItem;
        
        //create and insert quote/proposal
        Apttus_Proposal__Proposal__c proposalSO = dataHelper.getQuoteHeader('Proposal Proposal', null, Date.today(), Date.today().addMonths(12), priceListSO.Id, Date.today(), '3 Years',opp);
        insert proposalSO;
        proposalSO = [SELECT ID,Name,Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c WHERE ID = :proposalSO.Id];
        
        
        //create and insert product configuration object
        Apttus_Config2__ProductConfiguration__c configSO = dataHelper.getProductConfiguration('Product Configuration',
                                                                    1, proposalSO.Id, 'Proposal', 'Ad Hoc',
                                                                    proposalSO.Apttus_QPConfig__PriceListId__c,
                                                                    null, 'Ready For Finalization', null,
                                                                    Datetime.now(), true, 'Pricing Callback Test');
        insert configSO;   
        Apttus_Config2__AssetLineItem__c assetLineItem = new Apttus_Config2__AssetLineItem__c(Apttus_Config2__AccountId__c=lstAccount.Id,Apttus_Config2__ProductId__c=testProduct.Id,Apttus_QPConfig__ProposalId__c=proposalSO.Id,Apttus_Config2__PriceListId__c=priceListSO.Id,Apttus_Config2__PriceListItemId__c=plItem.Id,Apttus_Config2__Quantity__c=1);
        insert assetLineItem;
        
        Apttus_Config2__TempRenew__c assetItem=new Apttus_Config2__TempRenew__c(Apttus_Config2__AssetLineItemId__c=assetLineItem.Id,Apttus_Config2__ActionName__c='Cancel');
        Apttus_Config2__TempRenew__c assetItem1=new Apttus_Config2__TempRenew__c(Apttus_Config2__AssetLineItemId__c=assetLineItem.Id,Apttus_Config2__ActionName__c='Amend',Apttus_Config2__Quantity__c=2);
        List<Apttus_Config2__TempRenew__c> assetItemList=new List<Apttus_Config2__TempRenew__c>{assetItem,assetItem1};
        insert assetItemList;
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
        custSetting.Apttus_Config2__ValidationCallbackClass__c = 'APTS_ValidationCallBack';
        custSetting.Name = 'System Properties';
        insert custSetting;
        
        Apttus_Config2__ConfigSystemProperties__c configsys = new Apttus_Config2__ConfigSystemProperties__c();
        configsys.Apttus_Config2__ViewCartCustomFields__c = 'Open_Name__c,Apttus_Config2__ProductId__r.LOB__c';
        configsys.Name = 'System Properties';
        insert configsys;
        
        Test.setCurrentPage(Page.Apttus_Config2__CartDetailView);
        Test.startTest();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         User u2 = new User(Alias = 'newuser', Email='newTestUser@org.com', 
             EmailEncodingKey='UTF-8', LastName='test', LanguageLocaleKey='en_US', 
             LocaleSidKey='en_US', ProfileId = p.Id, 
             TimeZoneSidKey='America/New_York', UserName='testUser98789@apttus.com');
          
          
          
          System.runAs(u2) {
              Apttus_Config2.CallbackTester.testValidationCallback(configSO.Id,new List<Apttus_Config2__LineItem__c>{lineItemSO},assetItemList, new APTS_ValidationCallBack());
          }
          
        Test.stopTest();
    */
}