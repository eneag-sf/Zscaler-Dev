@isTest(seeAllData=false)
private class GenerateMarginDocumentControllerTest {

	private static testMethod void GenerateMarginDocumentControllerTest() {
        Test.startTest();
        
        //Insert Account
        Account account = new Account ();
        account.Name = 'Zscaler';//APTS_CONSTANTS.ACC_NAME_ZSCALER;
        account.APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000);
        account.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';//APTS_CONSTANTS.PROD_SKU_PSUPPORT;
        account.Premium_Support_Source__c = 'List';//APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
        insert account;
        Id accountId = account.Id;
        
         // Insert Product
        Product2 prod = new Product2();
        prod.Name = 'Product Test';
        prod.ProductCode = 'TESTSKU';
        prod.Product_Term__c = 12;
        prod.PS_Deal_Reg__c = true;
        prod.AW__c = true;
        prod.POV__c = true;
        Insert prod;
        
        // Insert Price List 
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler Price List';
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Apttus_Config2__AccountId__c =  account.Id;
        pricelist.APTS_Ext_ID__c = '03041992';  
        insert pricelist;
        
        //Insert Opportunity
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = label.Stage_6_Closed_Won;//'0 - Initial Prospecting'
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = account.Id;
        opp.Price_List__c = pricelist.Id;
        opp.type ='Existing Customer (Renewal)';
        opp.pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        // Insert Proposal
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
        prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        prop.Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(365);
        prop.Apttus_Proposal__Primary__c = true;
        prop.Apttus_Proposal__Valid_Until_Date__c = Date.today();
        //prop.APTS_SBQuote_Id__c = SBQuote.Id;
        insert prop;
        
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = System.Label.Margin_Template_Name;
        template.Apttus__Type__c = 'Proposal';
        template.Apttus__Agreement_Types__c = 'Default; New Business; Upsell; NFR (Not For Resale); Renewal';
        template.Apttus__Category__c = 'Default';
        template.Apttus__Subcategory__c = 'Default';
        template.Apttus__Language__c = 'English';
        template.Apttus__Locale__c = 'English (United States)';
        template.Apttus__FrameworkFormat__c = 'FX2';
        insert template;
        
        // Generate Instance of VF Page to pass parameter so Controller will get the Id
        PageReference generateMarginDocPage = Page.GenerateMarginDocumentPage;
        Test.setCurrentPage(generateMarginDocPage);
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',prop.Id);
        ApexPages.currentPage().getParameters().put('type','pdf');
        // Define Controller
        GenerateMarginDocumentController gmdc = new GenerateMarginDocumentController();
        gmdc.DocGen();
        
        ApexPages.currentPage().getParameters().put('id',prop.Id);
        ApexPages.currentPage().getParameters().put('type','');
        // Define Controller
        GenerateMarginDocumentController gmdc1 = new GenerateMarginDocumentController();
        gmdc1.DocGen();
        
        
        
        Test.stopTest();
	}

}