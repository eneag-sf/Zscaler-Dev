@isTest
public class APTS_ApprovalCriteriaTriggerTest{
    private static Id lineItemId;
    private static Id configId;
    private static Id accountId;
    private static Apttus_Config2__PriceList__c Pricelist;
    private static Pricebook2 Pricebook;
    static{
        Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        //Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
        //insert Pricebook;
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
    }
//Commented by Anay Bhande
  /*     static{
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
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
                Apttus_Config2__PriceListItemId__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: cartId ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
        
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
        }
        update lineItemList;
        
        lineItemId = lineItemList[0].Id;
        configId = cartId;
    }
   
    static testMethod void checkForApprovals() {
        Test.startTest();
        
        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 2;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        insert lineItemToInsert;
        
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today() + 200;
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 565;
        update lineItemToInsert;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Id = configId, Apttus_Config2__Status__c = 'Finalized');
        update prodConfig;
        
        Test.stopTest();
    }
    */ 
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

     
        //*****************************************
    //Added by Anay Bhande
    static testMethod void testcheckForApprovals() {
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = ZSCProd.Id;
        Id priceListId = Pricelist.Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = PriceListItem1.Id;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
       
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;
        
        String proposalId = proposal.Id;

        Test.startTest();

        
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
        
        
        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 2;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today()+365;
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 730;
        insert lineItemToInsert;
        
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today() + 731;
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 1066;
        update lineItemToInsert;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c(Id = configId, Apttus_Config2__Status__c = 'Saved',Apttus_Config2__FinalizedDate__c=Date.Today()+10);
        update prodConfig;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = true;
        update lineItemToInsert;
        prodConfig = new Apttus_Config2__ProductConfiguration__c(Id = configId, Apttus_Config2__Status__c = 'Finalized',Apttus_Config2__FinalizedDate__c=Date.Today()+18);
        update prodConfig;
        
       Test.stopTest();
    }
    //*****************************************
}