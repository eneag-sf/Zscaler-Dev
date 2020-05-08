@isTest(seeAllData=false)
public class GenerateMarginControllerTest {
    private static testMethod void GenerateMarginControllerTest() {
        Test.startTest();
        TriggerUtility.skipentireproposaltriggerExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        //Insert Account
        Account account = new Account ();
        account.Name = 'Zscaler';//APTS_CONSTANTS.ACC_NAME_ZSCALER;
        account.APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000);
        account.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';//APTS_CONSTANTS.PROD_SKU_PSUPPORT;
        account.Premium_Support_Source__c = 'List';//APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
        insert account;
        Id accountId = account.Id;
        
        //Insert Partner Account
        Account paccount = new Account ();
        paccount.Name = 'Partner Account ABC';
        paccount.APTS_Platform_Subscription_End_Date__c = Date.today();
        paccount.APTS_Asset_SKU__c = 'ZCES-SUP-PREM';//APTS_CONSTANTS.PROD_SKU_PSUPPORT;
        paccount.Premium_Support_Source__c = 'List'; //APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
        paccount.AW_Margin__c = 5;
        paccount.Partner_Summit_Deg_Reg_Margin__c = 10;
        paccount.POV_Margin__c = 15;
        insert paccount;
        
        // Insert Price List 
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler Price List';
        pricelist.Apttus_Config2__Active__c = true;
        pricelist.Apttus_Config2__AccountId__c =  account.Id;
        pricelist.APTS_Ext_ID__c = '03041992';  
        insert pricelist;
        
        //Price List
        Apttus_Config2__PriceList__c testPriceList = new Apttus_Config2__PriceList__c(Name = 'US Price List',
                                                                                    Apttus_Config2__AccountId__c = account.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041991',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList;
        
        // Insert Product
        Product2 prod = new Product2();
        prod.Name = 'Product Test';
        prod.ProductCode = 'TESTSKU';
        prod.Product_Term__c = 12;
        prod.PS_Deal_Reg__c = true;
        prod.AW__c = true;
        prod.POV__c = true;
        Insert prod;
        
        //Products
        Product2 testProduct1 = new Product2(Name = 'Test Support Product');
        testProduct1.Product_Line__c = 'Support';
        testProduct1.ProductCode = 'ZIA-PRO-BUNDLE';
        testProduct1.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct1.IsActive = true;
        testProduct1.Zscaler_Product_Family__c = 'ZIA';

        Product2 testProduct2 = new Product2(Name = 'Test Support Product');
        testProduct2.Product_Line__c = 'Support';
        testProduct2.ProductCode = 'ZIA-BUS-BUNDLE';
        testProduct2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct2.IsActive = true;
        testProduct2.Zscaler_Product_Family__c = 'ZIA';

        Product2 testProduct3 = new Product2(Name = 'Test Support Product');
        testProduct3.Product_Line__c = 'Support';
        testProduct3.ProductCode = 'ZIA-TRANS-BUNDLE';
        testProduct3.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct3.IsActive = true;
        testProduct3.Zscaler_Product_Family__c = 'ZPA';

        Product2 testProduct4 = new Product2(Name = 'Test Support Product');
        testProduct4.Product_Line__c = 'Support';
        testProduct4.ProductCode = 'ZPA-PRO';
        testProduct4.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct4.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'ZPA';

        Product2 testProduct5 = new Product2(Name = 'Test Support Product');
        testProduct5.Product_Line__c = 'Support';
        testProduct5.ProductCode = 'ZPA-BUS';
        testProduct5.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct5.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Support';

        Product2 testProduct6 = new Product2(Name = 'Test Support Product');
        testProduct6.Product_Line__c = 'Support';
        testProduct6.ProductCode = 'ZPA-ENT';
        testProduct6.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct6.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Deployment';

        List<Product2> listProduct=new List<Product2>();
        listProduct.add(testProduct1);
        listProduct.add(testProduct2);
        listProduct.add(testProduct3);
        listProduct.add(testProduct4);
        listProduct.add(testProduct5);
        listProduct.add(testProduct6);
        insert listProduct;

        Id standardPB = Test.getStandardPricebookId();
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
        
        // Create Opportunity Partner
        Opportunity_Partner__c partner = new Opportunity_Partner__c();
        partner.Account__c = paccount.Id;
        partner.Is_Primary__c = true;
        partner.Opportunity__c = opp.Id;
        partner.Partner_Type__c = 'Deal Reg';
        insert partner;
        
        Opportunity_Partner__c partner2 = new Opportunity_Partner__c();
        partner2.Account__c = paccount.Id;
        partner2.Opportunity__c = opp.Id;
        partner2.Partner_Type__c = 'POV';
        insert partner2;
        
        Opportunity_Partner__c partner3 = new Opportunity_Partner__c();
        partner3.Account__c = paccount.Id;
        partner3.Opportunity__c = opp.Id;
        partner3.Partner_Type__c = 'Architecture Workshop';
        insert partner3;
        
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
        
        // Insert Proposal Line Item
        Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = prop.Id;
        pli.Apttus_QPConfig__ItemSequence__c = 1;
        pli.Apttus_QPConfig__LineNumber__c = 1;
        pli.Apttus_QPConfig__SellingFrequency__c = 'Yearly';
        pli.APTS_Selling_Term__c = 36;
        pli.Apttus_QPConfig__BillToAccountId__c = account.Id;
        pli.Apttus_Proposal__Product__c = prod.Id;
        pli.Apttus_QPConfig__ExtendedPrice__c = 100;
        pli.Apttus_QPConfig__BaseExtendedPrice__c = 100;
        pli.APTS_Product_Code__c = 'ZIA-BUS';
        pli.ZIA_Premium_Support__c = 343.33;
        pli.Apttus_QPConfig__StartDate__c = prop.Apttus_Proposal__ExpectedStartDate__c;
        pli.Apttus_QPConfig__EndDate__c = prop.Apttus_Proposal__ExpectedEndDate__c;
        pli.Apttus_QPConfig__SellingTerm__c = 1.0;
        pli.APTS_Total_Discount_Percentage__c = 1.0;
        pli.Apttus_QPConfig__Quantity2__c = 10;
        //insert pli;
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemLst = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Integer i=0; i<listProduct.size(); i++){
            //Price List Item
            Apttus_Proposal__Proposal_Line_Item__c proposalLine = new Apttus_Proposal__Proposal_Line_Item__c();
            proposalLine.Apttus_Proposal__Proposal__c = prop.Id;
            proposalLine.Apttus_QPConfig__ExtendedPrice__c = 100;
            proposalLine.Apttus_QPConfig__BaseExtendedPrice__c = 100;
            proposalLine.Apttus_Proposal__Product__c = listProduct[i].ID;
            proposalLine.APTS_Product_Code__c = 'ZIA-BUS';
            proposalLine.ZIA_Premium_Support__c = 343.33;
            proposalLine.Apttus_QPConfig__StartDate__c = prop.Apttus_Proposal__ExpectedStartDate__c;
            proposalLine.Apttus_QPConfig__EndDate__c = prop.Apttus_Proposal__ExpectedEndDate__c;
            proposalLine.Apttus_QPConfig__SellingTerm__c = 1.0;
            proposalLine.APTS_Total_Discount_Percentage__c = 1.0;
            proposalLineItemLst.add(proposalLine);
        }
        proposalLineItemLst[1].APTS_Product_Code__c = 'ZCES-SUP-PREM';
        insert proposalLineItemLst;
        
        
        // Generate Instance of VF Page to pass parameter so Controller will get the Id
        PageReference generateMarginPage = Page.GenerateMarginPage;
        Test.setCurrentPage(generateMarginPage);
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',prop.Id);
        // Define Controller
        GenerateMarginController gmc = new GenerateMarginController();
        gmc.selectedPartner = partner.Account__c;
        gmc.selectedAccAction();
        
        Test.stopTest();
        
    }
}