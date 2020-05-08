@isTest
public class APTSCU_CopyDealGuidanceTest{
    private static Id lineItemId;
    private static Id configId;
    private static Id accountId;
    //Commented by Anay Bhande
  /*  static{
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        System.debug('productId '+productId);
        System.debug('priceListId '+priceListId);
        test.startTest();
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'ZSCALER Test Account');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = '1 - Qualified and Budgeted', Type = 'New Business');
        insert opportunity;
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
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
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId = lineItemList[0].Id;
        configId = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
        }
        update lineItemList;
        test.stopTest();
    }
*/
    static{
        Apttus_Config2__PriceList__c Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;    
        /*Apttus_DealMgr__DealGuidanceRule__c dealGuidanceMap=new Apttus_DealMgr__DealGuidanceRule__c(Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__BusinessObject__c ='Apttus_Config2__LineItem__c');
        insert dealGuidanceMap;
        Apttus_DealMgr__DealGuidanceRuleEntry__c dealGuidanceEntryMap1=new Apttus_DealMgr__DealGuidanceRuleEntry__c(
            Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__GuidanceRuleId__c=dealGuidanceMap.Id,
            Apttus_DealMgr__Dimension2Value__c='Zscaler',Apttus_DealMgr__Band1Value__c='21',Apttus_DealMgr__Band2Value__c='22',
            Apttus_DealMgr__Band3Value__c='23',Apttus_DealMgr__Band4Value__c='24');
        insert dealGuidanceEntryMap1;
        Apttus_DealMgr__DealGuidanceRuleEntry__c dealGuidanceEntryMap2=new Apttus_DealMgr__DealGuidanceRuleEntry__c(
            Apttus_DealMgr__Sequence__c=1,Apttus_DealMgr__GuidanceRuleId__c=dealGuidanceMap.Id,
            Apttus_DealMgr__Dimension2Value__c='Partner',Apttus_DealMgr__Band1Value__c='21',Apttus_DealMgr__Band2Value__c='22',
            Apttus_DealMgr__Band3Value__c='23',Apttus_DealMgr__Band4Value__c='24');
        insert dealGuidanceEntryMap2;
        */
    }
    //*****************************************
    //Added by Anay Bhande
    static testMethod void testcopyDealGuidanceZScaler() {
        
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP1' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Zscaler');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
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
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        system.debug('Queries used testcopyDealGuidanceZScaler before: ' +Limits.getQueries());
        Test.startTest();
        
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId = lineItemList[0].Id;
        configId = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem1.Apttus_Config2__ExtendedPrice__c=NULL;
        }
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=50;
            lineItem1.Apttus_Config2__ExtendedPrice__c=1000;
       //     lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
         for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=9;
       //      lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-26;
        } 
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-51;
        } 
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-61;
        }
        update lineItemList;
        system.debug('Queries used testcopyDealGuidanceZScaler : ' +Limits.getQueries());
       Test.stopTest();
        system.debug('Queries used testcopyDealGuidanceZScaler after: ' +Limits.getQueries());
    }
    static testMethod void testcopyDealGuidancePartner() {
        
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP1' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Partner');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
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
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        system.debug('Queries used testcopyDealGuidancePartner before: ' +Limits.getQueries());
        Test.startTest();
        
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ConfigStatus__c,
                Apttus_Config2__PricingStatus__c, Apttus_Config2__SyncStatus__c, Apttus_Config2__SellingFrequency__c, 
                Apttus_Config2__SellingTerm__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceListId__c,
                Apttus_Config2__PriceListItemId__c, Apttus_Config2__LineStatus__c, Apttus_Config2__PriceAdjustment__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
            
        lineItemId = lineItemList[0].Id;
        configId = cartId;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__Quantity__c = 100;
            lineItem1.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            lineItem1.Apttus_Config2__PriceListId__c = priceListId;
            lineItem1.Apttus_Config2__PriceListItemId__c = priceListItemId;
            lineItem1.Apttus_Config2__ConfigStatus__c = 'Complete';
            lineItem1.Apttus_Config2__PricingStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SyncStatus__c = 'Complete';
            lineItem1.Apttus_Config2__SellingFrequency__c = 'Yearly';
            lineItem1.Apttus_Config2__SellingTerm__c = 12;
            lineItem1.Apttus_Config2__StartDate__c = Date.today();
            lineItem1.Apttus_Config2__EndDate__c = Date.today() + 365;
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
            lineItem1.Apttus_Config2__ExtendedPrice__c=NULL;
        }
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            
            lineItem1.Apttus_Config2__ExtendedPrice__c=1000;
            lineItem1.APTS_Total_Discount_Percentage__c=9;
       //      lineItem1.Apttus_Config2__NetAdjustmentPercent__c=900;
        }
        update lineItemList;
        
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.APTS_Total_Discount_Percentage__c=50;
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-1;
        } 
        update lineItemList;
       for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
             lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-6;
        } 
        update lineItemList;
        for(Apttus_Config2__LineItem__c lineItem1 : lineItemList){
            lineItem1.Apttus_Config2__NetAdjustmentPercent__c=-11;
        }
        update lineItemList;
        system.debug('Queries used testcopyDealGuidancePartner: ' +Limits.getQueries());
        Test.stopTest();
        system.debug('Queries used testcopyDealGuidancePartner: after ' +Limits.getQueries());
    }
    //*****************************************
//Commented by Anay Bhande
/*    
    static testMethod void copyDealGuidance() {
        Test.startTest();
        
        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 3;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        insert lineItemToInsert;
        
        lineItemToInsert.Apttus_Config2__NetAdjustmentPercent__c = -30;
        lineItemToInsert.APTS_Total_Discount_Percentage__c = 30;
        lineItemToInsert.Apttus_Config2__ExtendedPrice__c = 1000;
        update lineItemToInsert;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Id = configId, Apttus_Config2__BillToAccountId__c = accountId);
        update prodConfig;
        
        lineItemToInsert.Apttus_Config2__NetAdjustmentPercent__c = -40;
        lineItemToInsert.APTS_Total_Discount_Percentage__c = 40;
        lineItemToInsert.Apttus_Config2__ExtendedPrice__c = 1000;
        update lineItemToInsert;
        
        Test.stopTest();
    }*/
    
    private static String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
}