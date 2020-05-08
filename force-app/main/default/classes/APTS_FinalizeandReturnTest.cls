@isTest
public class APTS_FinalizeandReturnTest {

    static testMethod void finalizedReturnTest() {
        Apttus_Config2__ProductConfiguration__c configuration = [select Id,Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c Limit 1];
        system.debug('***** Config'+configuration);
        //Apttus_Config2.PricingWebService.computeTotalPriceForCart(configuration.Id);
        
        PageReference myPage = new Pagereference('/');
        myPage.getParameters().put('Id',configuration.Id);
        Test.setCurrentPage(myPage);
        Test.startTest();
        myPage = APTS_FinalizeandReturn.returntoquote();
        system.debug('***** MyPage'+myPage);
        Test.stopTest();
         //Apttus_Config2__ProductConfiguration__c configuration2 = [select Id,Apttus_Config2__Status__c, Apttus_QPConfig__Proposald__c from Apttus_Config2__ProductConfiguration__c where id = :configuration.Id];
         //system.debug('***** Config'+configuration2);
    }
    
    @testSetup 
    static void setupTest(){
        createAllCustomSetting();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
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
        opp.StageName = label.Stage_1_Alignment;
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
        listProduct.add(createProduct('Product1', APTS_CONSTANTS.PROD_SKU_ZPROSUITE, 'Products', 'Standalone'));
        insert listProduct;
        
        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[0].ID));
        insert listPLI;
        
        Id cartId = createCart(prop.Id);
        
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO request2 = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        request2.CartId = cartId;
        request2.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        request2.SelectedProducts.add(createSelectProductDo(listProduct[0].Id, 1, Date.today(), Date.today().addMonths(36), 4));
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO  response2 = Apttus_CPQApi.CPQWebService.addMultiProducts(request2);
        
        Apttus_Config2__ProductConfiguration__c configuration = [select Id from Apttus_Config2__ProductConfiguration__c Limit 1];
        
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
                                                                            +',Apttus_Config2__AdjustmentAmount__c,Apttus_Config2__BaseExtendedPrice__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames4__c = 'Apttus_Config2__AssetLineItemId__r.Apttus_Config2__Quantity__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.APTS_Partner_Disc__c '
                                                                            +',Apttus_Config2__AssetLineItemId__r.APTS_Deal_Reg_Disc__c';
        ConfigLineItemCustomSetting.Apttus_Config2__CustomFieldNames5__c = 'Apttus_Config2__ProductId__r.APTS_Sync_Quantity_with_Platform__c '
                                                                            +',Apttus_Config2__ProductId__r.APTS_Buyback_Eligible__c '
                                                                            +',Apttus_Config2__AttributeValueId__r.APTS_Buy_Back_Period__c '
                                                                            +',Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c';
        insert ConfigLineItemCustomSetting;
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        productSO.Apttus_Config2__ConfigurationType__c = sConfigType;
        productSO.Apttus_Config2__HasAttributes__c = false;
        productSO.Apttus_Config2__HasOptions__c = false;
        productSO.APTS_Buyback_Eligible__c = true;
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
}