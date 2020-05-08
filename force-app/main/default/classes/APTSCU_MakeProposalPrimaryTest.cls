@isTest
private class APTSCU_MakeProposalPrimaryTest {
    
    private static testMethod void init2()
    {
        Test.startTest();
        Account acc = creatAccount ();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus_Config2__PriceList__c  pricelist = createpricelist ();
        
        Opportunity opp = createOpportunity (acc.Id,pricelist.Id);
        Opportunity oppNew = createOpportunity (acc.Id,pricelist.Id);
        
        Apttus_Proposal__Proposal__c prop = createproposal(opp.id,acc.id,pricelist.id,false);
        
        Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Distributor',true);
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',true);
        Opportunity_Partner__c OppResellerPartnerNew = createPartner(prop.Apttus_Proposal__Opportunity__c,acc.id,'Reseller',true);
        
        PageReference tpageRef = Page.APTSCU_MakeProposalPrimary;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', prop.Id);
        
        
        APTSCU_MakeProposalPrimary controller = new APTSCU_MakeProposalPrimary() ;
        controller.init();
        Test.stopTest();
    }
    
    private static testMethod void init1()
    {
        Test.startTest();
        Account acc = creatAccount ();
        Account acc1 = creatAccount1();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus_Config2__PriceList__c  pricelist = createpricelist ();
        
        Opportunity opp = createOpportunity (acc.Id,pricelist.Id);
        
        Apttus_Proposal__Proposal__c prop = createproposal(opp.id,acc.id,pricelist.id,false);
        prop.Distributor__c = acc1.Id;
        update prop;  
        
        /*Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',true);*/
        Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Distributor',true);
        
        PageReference tpageRef = Page.APTSCU_MakeProposalPrimary;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', prop.Id);
        
        
        APTSCU_MakeProposalPrimary controller = new APTSCU_MakeProposalPrimary() ;
        controller.init();
        Test.stopTest();
    }
    
    private static testMethod void initNew()
    {
        Test.startTest();
        Account acc = creatAccount ();
        Account acc1 = creatAccount1();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus_Config2__PriceList__c  pricelist = createpricelist ();
        
        Opportunity opp = createOpportunity (acc.Id,pricelist.Id);
        
        Apttus_Proposal__Proposal__c prop = createproposal(opp.id,acc.id,pricelist.id,false);
        prop.Distributor__c = acc1.Id;
        update prop;  
        
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',true);
        /*Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Distributor',true);*/
        
        PageReference tpageRef = Page.APTSCU_MakeProposalPrimary;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', prop.Id);
        
        
        APTSCU_MakeProposalPrimary controller = new APTSCU_MakeProposalPrimary() ;
        controller.init();
        Test.stopTest();
    }
    
    
    
    private static testMethod void init()
    {
        Test.startTest();
        Account acc = creatAccount ();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus_Config2__PriceList__c  pricelist = createpricelist ();
        
        Opportunity opp = createOpportunity (acc.Id,pricelist.Id);
        
        Apttus_Proposal__Proposal__c prop = createproposal(opp.id,acc.id,pricelist.id,false);
        
        /*Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Distributor',true);
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',true);*/
        
        PageReference tpageRef = Page.APTSCU_MakeProposalPrimary;
        Test.setCurrentPage(tpageRef);
        ApexPages.currentPage().getParameters().put('Id', prop.Id);
        
        
        APTSCU_MakeProposalPrimary controller = new APTSCU_MakeProposalPrimary() ;
        controller.init();
        Test.stopTest();
    }
    
    
    
    
      private static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }
    
    private static Account creatAccount1 () {
        Account acc = new Account ();
        acc.Name = 'Test Account1';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }
    
    public static Apttus_Config2__PriceList__c createpricelist () {
        Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'test price list';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;
        return pricelist;
    }
    
    public static opportunity createOpportunity (string accountId,string pricelistId) {
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = Label.Stage_1_Alignment /*'0 - Initial Prospecting'*/;
        opp.closedate =  Date.today();
        opp.accountId = accountId;
        opp.Price_List__c = pricelistId;
        insert opp;
        return opp;
    }
    
    public static Apttus_Proposal__Proposal__c createproposal (string oppId,string accountId, string pricelistId , boolean isPrimary) {
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();
       
        prop.Apttus_QPConfig__PriceListId__c = pricelistId;
        prop.Apttus_QPConfig__BillToAccountId__c = accountId;
        prop.Apttus_QPConfig__ShipToAccountId__c = accountId;
        prop.Apttus_Proposal__Opportunity__c = oppId;
        prop.Apttus_Proposal__Primary__c  = isPrimary;
        prop.Apttus_Proposal__Approval_Stage__c = 'Accepted';
        prop.Distributor__c = accountId;
        
        insert prop;
        return prop;
    }
    
    public static Opportunity_Partner__c createPartner (string oppId,string accountId, string partnerType , boolean isPrimary) {
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
        OppPartner.Is_Primary__c = isPrimary;
        OppPartner.Opportunity__c = oppId;
        OppPartner.Partner_Type__c = partnerType;
        OppPartner.Account__c = accountId;
        
        insert OppPartner;
        return OppPartner;
    }
}