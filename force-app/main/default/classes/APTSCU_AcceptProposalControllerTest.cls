@isTest
private class APTSCU_AcceptProposalControllerTest
{
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
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        TriggerUtility.prospectTypeUpdExecuted();
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
        
        PageReference tpageRef = Page.APTSCU_AcceptProposal;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', prop.Id);
        
        APTSCU_AcceptProposalController controller = new APTSCU_AcceptProposalController() ;
        
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
    
    @isTest static void delteOpportunityLineItem() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        APTSCU_AcceptProposalController.getQueryStringWithAllFields('Opportunity',null);
        APTSCU_AcceptProposalController.delteOpportunityLineItem(primaryprop.id,opp.id);
        Test.stopTest();
    }
    
    @isTest static void acceptproposal() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        APTSCU_AcceptProposalUtil obj = new APTSCU_AcceptProposalUtil();
        APTSCU_AcceptProposalController.acceptproposal( prop.Id);
        //APTSCU_AcceptProposalController.generateDocument(prop.Id, 'https://mergews.apttus.net/cgi-bin/MergeServer/Bin/MMCGI.exe',
        //                                                 'a3qS0000000ANzS',UserInfo.getSessionId());
        Test.stopTest();
    }

    @isTest static void changeOpportunityStatus() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        APTSCU_AcceptProposalController.changeOpportunityStatus(prop.id,opp.id);
        Test.stopTest();
    }
    
    @isTest static void createRenewalOpportunity() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        //opp.APTS_Primary_Proposal__c=NULL;
        //update opp;
        newProposalId = APTSCU_AcceptProposalController.createRenewalOpportunity(prop.id,acc.id,opp.id,acc.id);
     
        
        
        newcartId = APTSCU_AcceptProposalController.CreateCartForProposal(newProposalId );
        //this line was commented
        List<Apttus_Config2__LineItem__c> listOfLineItem = APTS_TestUtil.createLineItems(newcartId, pricelist.Id, APTS_TestUtil.createProducts(2));
       // APTSCU_AcceptProposalController.addAssetLineItemsToCart(newcartId,newProposalId,acc.id);
        APTSCU_AcceptProposalController.deleteRampLineItem(newcartId,acc.id);
        APTSCU_AcceptProposalController.repriceCart(newcartId);
      
        Test.stopTest();
    }
    
    @isTest static void gettingAllData() {
        Test.startTest(); 
        TriggerUtility.prospectTypeUpdExecuted();
        Product2 prod= new Product2(name='ZScaler Product',productcode='ZCES-SUP-PREM', family = 'Zscaler Products');
        insert prod;
        String str1 = APTSCU_AcceptProposalController.getAlldata(acc.id, 0);
        String str2 = APTSCU_AcceptProposalController.getAlldata(acc.id, 1);
        String str3 = APTSCU_AcceptProposalController.getAlldata(acc.id, 2);
        String str4 = APTSCU_AcceptProposalController.getAlldata(acc.id, 3);
        String str5 = APTSCU_AcceptProposalController.getAlldata(acc.id, 4);
        List<Product2> listOfProd = APTS_TestUtil.createProducts(2);
        List<Apttus_Config2__LineItem__c> listOfLineItem = APTS_TestUtil.createLineItems(cartId, pricelist.Id, listOfProd);
        Apttus_Proposal__Proposal_Line_Item__c testPli = APTS_TestUtil.createProposalLineItem (prop.Id, listOfProd[0].id);
        Apttus_Config2__AssetLineItem__c  testAli = APTS_TestUtil.createassetlineItems(prop.Id, acc.Id, listOfProd[0].id, testPli.Id);
        Boolean flag1 = APTSCU_AcceptProposalController.renewIndividualAssetLineItem(2, cartId, str3, str4, str5);
        Boolean flag2 = APTSCU_AcceptProposalController.renewIndividualAssetLineItem(3, cartId, str3, str4, str5);
        Boolean flag3 = APTSCU_AcceptProposalController.renewIndividualAssetLineItem(4, cartId, str3, str4, str5);
        Test.stopTest();
    }
    
    @isTest static void addPremiumsupport(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        APTSCU_AcceptProposalController.addPremiumsupport(cartId, APTS_TestUtil.createProduct ());
        Test.stopTest();
    }
    
    @isTest static void finalizeProposal(){
        Test.startTest();
        Pricebook2 standardPricebook = new Pricebook2(
    Id = Test.getStandardPricebookId(),
    IsActive = true
);
 
//Execute an update DML on the Pricebook2 record, to make IsStandard to true
Update standardPricebook;
        TriggerUtility.prospectTypeUpdExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        List<Apttus_Config2__LineItem__c> listOfLineItem = APTS_TestUtil.createLineItems(cartId, pricelist.Id, APTS_TestUtil.createProducts(2));
        listOfLineItem[0].Apttus_Config2__NetPrice__c = 10.00;
        listOfLineItem[1].Apttus_Config2__NetPrice__c = 20.00;
        listOfLineItem[0].Apttus_Config2__SellingTerm__c = 1;
        listOfLineItem[1].Apttus_Config2__SellingTerm__c = 2;
        update listOfLineItem;
        APTSCU_AcceptProposalController controller = new APTSCU_AcceptProposalController();
        APTSCU_AcceptProposalController.finalizeProposal(cartId,controller.templateId);
        Test.stopTest();
    }
    
    @isTest static void repriceCart(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        Boolean flag = APTSCU_AcceptProposalController.repriceCart(cartId);
        Test.stopTest();
    }
    
    @isTest static void deleteRampLineItem(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        APTSCU_AcceptProposalController.deleteRampLineItem(cartId, acc.Id);
        Test.stopTest();
    }
    
    @isTest static void calculateOldACV(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        List<Product2> listOfProd = APTS_TestUtil.createProducts(2);
        List<Apttus_Config2__LineItem__c> lineItem = APTS_TestUtil.createLineItems(cartId, pricelist.Id, listOfProd);
        Apttus_Proposal__Proposal_Line_Item__c testPli = APTS_TestUtil.createProposalLineItem (prop.Id, listOfProd[0].id);
        Apttus_Config2__AssetLineItem__c  testAli = APTS_TestUtil.createassetlineItems(prop.Id, acc.Id, listOfProd[0].id, testPli.Id);
        APTSCU_AcceptProposalController.calculateOldACV(cartId, acc.Id);
        Test.stopTest();
    }
    
   
}