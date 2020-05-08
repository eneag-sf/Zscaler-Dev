@isTest
public class CreateSalesOrderExtensionTest {
    public static Account acc;
    public static Account acc1;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string newcartId;
    public static string cartId;
    public static string prdId;
    public static List<Contract_Detail__c> contractDetailList;
    public static List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs;
    public static List<Upgrade_SKU_Mapping_NS_Integration__c> upgradecs;
    
    static
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
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
        
        primaryprop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,true);
        
        
        opp.APTS_Primary_Proposal_Lookup__c = prop.Id;
        update opp;
        prdId = APTS_TestUtil.createProduct (); 
        APTS_TestUtil.createassetlineItems ( prop.Id,acc.id,prdId,null );
        
        
        Apttus__APTS_Admin__c testAdmin = new Apttus__APTS_Admin__c(Name = 'Generate Document Email Template');
        testAdmin.Apttus__Value__c = 'Zscaler Proposal';
        insert testAdmin;
        
        ZscalerSetting__c setting = new ZscalerSetting__c(Name = 'NSSOUrl', Value__c = 'https://www.zscaler.test');
        insert setting;
        
        Partner testOpptyPartner = new Partner();
        testOpptyPartner.AccountToId = acc1.Id;
        testOpptyPartner.IsPrimary = true;
        testOpptyPartner.OpportunityId = opp.Id;
        //testOpptyPartner.Role = 'Vendor';
        insert testOpptyPartner;
        
        Order o = new Order(name = 'Test Order 1', AccountId = acc.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = acc.Id;
        contractDetail1.Product_Name__c = prdId ;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail1);
        
        
        
        insert contractDetailList;
        
        skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        
        skuscs.add(rec1);
        skuscs.add(rec2);
        skuscs.add(rec3);
        skuscs.add(rec4);
        skuscs.add(rec5);
        skuscs.add(rec6);
        skuscs.add(rec7);
        skuscs.add(rec8);
        insert skuscs;
        
        upgradecs = new List<Upgrade_SKU_Mapping_NS_Integration__c>();
        upgradecs.add(new Upgrade_SKU_Mapping_NS_Integration__c(Name = 'rec1', IsrenewalorUpsell__c ='renewalupsell', Matching_SKU_On_Cart__c ='ZIA-PRO-BUNDLE', Matching_SKU_On_IB__c ='ZSC-SIP'));
        insert upgradecs;
        
    }
    
    @isTest
    static void test2 () {
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        test.starttest();
        primaryprop.RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        update primaryprop;
        opp.APTS_Primary_Proposal_Lookup__c = primaryprop.Id;
        update opp;
        //APTS_TestUtil.createProposalLineItem ( primaryprop.Id,prdId);
        Apttus_Proposal__Proposal_Line_Item__c proposalLine = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLine.Apttus_Proposal__Proposal__c = primaryprop.Id;
        proposalLine.Apttus_QPConfig__ExtendedPrice__c = 100;
        proposalLine.Apttus_Proposal__Product__c = prdId;
        proposalLine.APTS_Product_Code__c = 'ZIA-BUS';
        proposalLine.ZIA_Premium_Support__c = 343.33;
        proposalLine.Apttus_QPConfig__StartDate__c = Date.today();
        proposalLine.Apttus_QPConfig__EndDate__c = Date.today().adddays(600);
        proposalLine.Apttus_QPConfig__SellingTerm__c = 1.0;
        proposalLine.APTS_Total_Discount_Percentage__c = 1.0;
        proposalLine.Apttus_QPConfig__NetPrice__c = 1000.0;
        proposalLine.APTS_Contract_Detail_Name__c = contractDetailList[0].Id;
        proposalLine.Additional_Contract_Details__c = contractDetailList[0].Name;
        insert proposalLine;
        Test.setCurrentPage(Page.CreateSalesOrder);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        CreateSalesOrderExtension  controller = new CreateSalesOrderExtension (stdController);
        CreateSalesOrderExtension  controller1 = new CreateSalesOrderExtension ();
        
        
        PageReference ref = controller.pageLoad();
        
        controller.overrideShipToId = false;
        controller.overrideShipToId = true;
        try{
            controller.overrideBillToId = true;
            controller.doReview();
        }catch(Exception ex){
            
        }
        try{
            controller.doSubmit();
        }catch(Exception ex){
            
        }
        try{
            controller.getPartnerInternalId();
        }catch(Exception ex){
            
        }
        controller.doCancel();
        controller.doBack();
        try{
            for(CreateSalesOrderExtension.RenewalLinesWrapper rlw: controller.lstRenewalLines){
                rlw.contractDetailName = contractDetailList[0].Name;
                rlw.addcontractDetailName = contractDetailList[0].Name;      
            }
            controller.adjustACVandTCV();
        }catch(Exception ex){
            
        }
        CreateSalesOrderExtension.searchContractDetails('',acc.Id);
        CreateSalesOrderExtension.searchContractDetails('abc',acc.Id);
        /*try{
            CreateSalesOrderExtension.sendCreateSalesOrderRequest(opp.Id);
        }catch(Exception ex){
            
        }
        try{
            CreateSalesOrderExtension.getNetSuiteCustomerDetails('28453','28453','28453','28453');
        }catch(Exception ex){
            
        }*/
        test.stoptest();
    }
    
    @isTest
    static void test3 () {
        
        test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        primaryprop.RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        update primaryprop;
        opp.APTS_Primary_Proposal_Lookup__c = primaryprop.Id;
        update opp;
        //APTS_TestUtil.createProposalLineItem ( primaryprop.Id,prdId);
        List<Apttus_Proposal__Proposal_Line_Item__c> lstprplines = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proposalLine = new Apttus_Proposal__Proposal_Line_Item__c();
        proposalLine.Apttus_Proposal__Proposal__c = primaryprop.Id;
        proposalLine.Apttus_QPConfig__ExtendedPrice__c = 100;
        proposalLine.Apttus_Proposal__Product__c = prdId;
        proposalLine.APTS_Product_Code__c = 'ZIA-BUS';
        proposalLine.ZIA_Premium_Support__c = 343.33;
        proposalLine.Apttus_QPConfig__StartDate__c = Date.today();
        proposalLine.Apttus_QPConfig__EndDate__c = Date.today().adddays(600);
        proposalLine.Apttus_QPConfig__SellingTerm__c = 1.0;
        proposalLine.APTS_Total_Discount_Percentage__c = 1.0;
        proposalLine.Apttus_QPConfig__NetPrice__c = 1000.0;
        lstprplines.add(proposalLine);
        insert lstprplines;
        Test.setCurrentPage(Page.CreateSalesOrder);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        CreateSalesOrderExtension  controller = new CreateSalesOrderExtension (stdController);
        CreateSalesOrderExtension  controller1 = new CreateSalesOrderExtension ();
        
        
        PageReference ref = controller.pageLoad();
        
        controller.overrideShipToId = false;
        controller.overrideShipToId = true;
        try{
            controller.overrideBillToId = true;
            controller.overridePartnerId = true;
            controller.overrideShipToId = true;
            controller.doReview();
        }catch(Exception ex){
            
        }
        try{
            CreateSalesOrderExtension.LinestoNS ctrl2 = new CreateSalesOrderExtension.LinestoNS(proposalLine, 'ZSCES-SUP-PREM-INT',100, 1000, true);
            CreateSalesOrderExtension.NetSuiteCustomerInfoResponse  ctrl3 = new CreateSalesOrderExtension.NetSuiteCustomerInfoResponse ();
            CreateSalesOrderExtension.NetSuiteCustomerInfoLine ctrl4 = new CreateSalesOrderExtension.NetSuiteCustomerInfoLine();
            system.debug(ctrl4.id );
            system.debug(ctrl4.name);
            system.debug(ctrl4.entityId);
            system.debug(ctrl4.type);
            system.debug(controller.billToOverriddenDetails);
            system.debug(controller.partnerIdOverriddendetails );
            system.debug(controller.shipToOverriddenDetails );
            system.debug(controller.billToDetails );
            system.debug(controller.shipToDetails);
            system.debug(controller.errors);
            CreateSalesOrderExtension.createHttpRequest('abc','abc','abc',100000);
        }catch(Exception ex){
            
        }
        try{
            controller.doSubmit();
        }catch(Exception ex){
            
        }
        try{
            controller.getPartnerInternalId();
        }catch(Exception ex){
            
        }
        controller.doCancel();
        //controller.doBack();
        try{
            for(CreateSalesOrderExtension.RenewalLinesWrapper rlw: controller.lstRenewalLines){
                rlw.contractDetailName = contractDetailList[0].Name;
                rlw.addcontractDetailName = contractDetailList[0].Name;      
            }
            controller.adjustACVandTCV();
        }catch(Exception ex){
            
        }
        CreateSalesOrderExtension.searchContractDetails('',acc.Id);
        CreateSalesOrderExtension.searchContractDetails('abc',acc.Id);
        /*try{
            CreateSalesOrderExtension.sendCreateSalesOrderRequest(opp.Id);
        }catch(Exception ex){
            
        }
        try{
            CreateSalesOrderExtension.getNetSuiteCustomerDetails('28453','28453','28453','28453');
        }catch(Exception ex){
            
        }*/
        test.stoptest();
    }
    
    @isTest
    static void test1 () {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        Test.setCurrentPage(Page.CreateSalesOrder);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        CreateSalesOrderExtension  controller = new CreateSalesOrderExtension (stdController);
        
        test.starttest();
        PageReference ref = controller.pageLoad();
        
        controller.overrideShipToId = false;
        controller.overrideShipToId = true;
        try{
            controller.doReview();
        }catch(Exception ex){
            
        }
        try{
            controller.doSubmit();
        }catch(Exception ex){
            
        }
        controller.doCancel();
        controller.doBack();
        try{
            for(CreateSalesOrderExtension.RenewalLinesWrapper rlw: controller.lstRenewalLines){
                rlw.contractDetailName = contractDetailList[0].Name;
                rlw.addcontractDetailName = contractDetailList[0].Name;      
            }
            controller.calculateACV();
        }catch(Exception ex){
            
        }
        CreateSalesOrderExtension.searchContractDetails('',acc.Id);
        CreateSalesOrderExtension.searchContractDetails('abc',acc.Id);
        CreateSalesOrderExtension.booster();
        /*try{
            CreateSalesOrderExtension.sendCreateSalesOrderRequest(opp.Id);
        }catch(Exception ex){
            
        }
        try{
            CreateSalesOrderExtension.getNetSuiteCustomerDetails('28453','28453','28453','28453');
        }catch(Exception ex){
            
        }*/
        test.stoptest();
    }
    
}