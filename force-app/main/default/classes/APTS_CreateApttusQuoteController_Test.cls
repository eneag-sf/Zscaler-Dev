@isTest
private class APTS_CreateApttusQuoteController_Test {
    
    public static testmethod void testconstructor(){
        List<SBQQ__Quote__c> listSBQuote = [select Id from SBQQ__Quote__c Limit 1];
        if(listSBQuote.size()>0){
            SBQQ__Quote__c SBQuote = listSBQuote[0];
            
            Apttus_Config2__PriceList__c priceList = [Select ID from Apttus_Config2__PriceList__c Limit 1];
            APTS_CreateApttusQuoteController quoteController = new APTS_CreateApttusQuoteController();
            //APTS_CreateApttusQuoteController.createProposal(SBQuote.Id);
            APTS_CreateApttusQuoteController.deleteOldProposal(SBQuote.ID);
            String propId = APTS_CreateApttusQuoteController.createproposal(SBQuote.Id);//, priceList.Id, quoteController.sbQuoteMapJSON,quoteController.fieldMapSettingJSON,quoteController.recordTypeMapJSON);
            String cartId = APTS_CreateApttusQuoteController.CreateCartForProposal(propId);
            Integer Counter = APTS_CreateApttusQuoteController.CreateCartlineItem(cartId ,SBQuote.Id);//, quoteController.sbQuoteLineMapJSON, quoteController.productToReplaceMapJSON );
            System.debug('***** Counter : '+Counter);
            System.assertEquals(Counter,2,'All Line Item not copied');
            Boolean Updated = APTS_CreateApttusQuoteController.updatelineitem(cartId ,SBQuote.Id,counter);// quoteController.sbQuoteLineMapJSON, quoteController.productToReplaceMapJSON , counter );
            System.debug('***** Updated : '+Updated );
            System.assertEquals(Updated ,true,'Line Item not updated');
            
            APTS_CreateApttusQuoteController.updateTermOnlineitem(cartId ,SBQuote.Id);//, quoteController.sbQuoteLineMapJSON, quoteController.productToReplaceMapJSON );
            APTS_CreateApttusQuoteController.repriceCart(cartId);
            test.starttest();
            APTS_CreateApttusQuoteController.finalizeCart(cartId);
        }
    }
    
    @testSetup
    static void SetupTestData() {
        try{
            //Insert Custom Setting
            List<APTS_Create_Apttus_Quote_Setting__c> listQuoteSetting = new List<APTS_Create_Apttus_Quote_Setting__c>();
            listQuoteSetting.add(createQuoteSetting('1','Apttus_Proposal__Account__c','SBQQ__Account__c'));
            listQuoteSetting.add(createQuoteSetting('2','Apttus_Proposal__Primary__c','SBQQ__Primary__c'));
            listQuoteSetting.add(createQuoteSetting('3','Apttus_Proposal__ExpectedStartDate__c','SBQQ__StartDate__c'));
            listQuoteSetting.add(createQuoteSetting('4','Apttus_Proposal__Opportunity__C','SBQQ__Opportunity2__c'));
            listQuoteSetting.add(createQuoteSetting('5','Apttus_QPConfig__BillToAccountId__c ','SBQQ__Partner__c'));
            insert listQuoteSetting;
            
            //Insert Account
            Account account = new Account ();
            account.Name = 'Test Account';
            account.APTS_Platform_Subscription_End_Date__c = Date.today();
            Id accountId = account.Id;
            
            //Insert PriceBook
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            
            //Insert PriceList
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            
            Pricebook2 standardPB1 = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
            insert standardPB1 ;
            
            Id standardPB = Test.getStandardPricebookId();
            //Insert Products
            List<Product2> listProduct = new list<Product2>();
            listProduct.add(createProduct('Product1', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM-SP', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product11', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM-S', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
            insert listProduct;
            
            //Insert Procebookentry
            List<PricebookEntry> listPBEntry = new List<PricebookEntry>();
            listPBEntry.add(createPriceBookEntry(listProduct[0],standardPB));
            listPBEntry.add(createPriceBookEntry(listProduct[1],standardPB ));
            listPBEntry.add(createPriceBookEntry(listProduct[2],standardPB ));
            insert listPBEntry;
            
            //create PriceListIteams
            List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[0].ID));
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[1].Id));
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[2].Id));
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[3].ID));
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[4].Id));
            listPLI.add(createPriceListItem(pricelist.Id, listProduct[5].Id));
            insert listPLI;
            
            //Insert Opportunity
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.StageName = label.Stage_1_Alignment;
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = account.Id;
            opp.Price_List__c = pricelist.Id;
            opp.type ='Existing Customer (Renewal)';
            opp.pricebook2Id = standardPB;
            insert opp;       
            
            //Insert SB Quote
            SBQQ__Quote__c SBQuote = new SBQQ__Quote__c();
            SBQuote.Quote_Name__c = 'Test Sb Quote';
            SBQuote.SBQQ__Status__c = 'Draft';
            //SBQuote.SBQQ__Opportunity__c = opp.Id;
            SBQuote.SBQQ__Opportunity2__c = opp.id;
            SBQuote.QuoteExpirationDate__c =  Date.today().addyears(1);
            SBQuote.SBQQ__PaymentTerms__c =  'Net 30';
            SBQuote.Migrate_to_Apttus__c = true;
            SBQuote.Subscription_Start_Date__c = Date.Today();
            insert SBQuote; 
            
            //Insert Apttus Proposal
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();       
            prop.Apttus_QPConfig__PriceListId__c = pricelist.Id;
            prop.Apttus_Proposal__Account__c = accountId;
            prop.Apttus_QPConfig__BillToAccountId__c = accountId;
            prop.Apttus_QPConfig__ShipToAccountId__c = accountId;
            prop.Apttus_Proposal__Opportunity__c = opp.Id;
            prop.Apttus_Proposal__Primary__c  = true;
            prop.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
            prop.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(36);
            prop.APTS_SBQuote_Id__c = SBQuote.Id;
            insert prop;
            
            
            //Create Sb Quote LineItems
            List<SBQQ__QuoteLine__c> SBQuoteLines = new List<SBQQ__QuoteLine__c>();
            SBQuoteLines.add(createSBQuoteLine(SBQuote.Id, listProduct[0].Id));
            SBQuoteLines.add(createSBQuoteLine(SBQuote.Id, listProduct[1].Id));
            //SBQuoteLines.add(createSBQuoteLine(SBQuote.Id, listProduct[2].Id));
            insert SBQuoteLines;
        }
        catch(Exception ex){
            system.debug('Exception catched :'+ ex);
        }
    }
    
    public static APTS_Create_Apttus_Quote_Setting__c createQuoteSetting(String name, String strAPTSField , String strSBField){
        APTS_Create_Apttus_Quote_Setting__c quoteSetting = new APTS_Create_Apttus_Quote_Setting__c();
        quoteSetting.Name = name;
        quoteSetting.APTS_Apttus_Quote_Field_API__c = strAPTSField;
        quoteSetting.APTS_SBQuote_Field_API__c = strSBField;
        return quoteSetting;
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
        return productSO;
    }
    
    public static PricebookEntry createPriceBookEntry(Product2 prod, Id pricBookID){
        PricebookEntry PBEntry = new PricebookEntry();
        PBEntry.IsActive =true;
        PBEntry.UnitPrice = 100;
        PBEntry.Product2Id = Prod.Id;
        PBEntry.Pricebook2Id = pricBookID;
        return PBEntry;
    }
    
    public static SBQQ__QuoteLine__c createSBQuoteLine(Id SBQuoteID ,Id productID){
        SBQQ__QuoteLine__c SBQuoteLine = new SBQQ__QuoteLine__c();
        SBQuoteLine.SBQQ__Quote__c = SBQuoteID;
        SBQuoteLine.SBQQ__Product__c = productID;
        SBQuoteLine.SBQQ__Optional__c = false ;
        SBQuoteLine.SBQQ__Quantity__c =1 ;
        SBQuoteLine.SBQQ__SubscriptionTerm__c = 12;
        //SBQuoteLine.Start_Date__c = Date.Today();
        return SBQuoteLine;
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
        return priceListItem;
    }    
    
}