@isTest
public class APTS_SummaryGroupCreditHandlerTest{
    
    private static Id lineItemId;
    private static Id configId;
    
    @testSetup static void setup() {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.fsAccountOwnerIdUpdateExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateContactRoleCountExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.opportunityOwnershipChangeExecuted();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.updateAccountForApprovedPZENExecuted();
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment, Type = 'New Business');
        insert opportunity;

        Product2 tp = new Product2();
        tp.Name = 'test product 1';
        tp.Apttus_Config2__ConfigurationType__c = 'Standalone';
        tp.ProductCode = 'ZSC-SIP';
        tp.Family = 'Zscaler Products';
        tp.Product_Line__c = 'Support';
        tp.IsActive = true;
        tp.Product_Line__c = 'Support';
        insert tp;

    }
    
    static{
        /**TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.fsAccountOwnerIdUpdateExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateContactRoleCountExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.opportunityOwnershipChangeExecuted();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.updateAccountForApprovedPZENExecuted();
        //Account account = new Account(Name = 'Test Account');
        //insert account;
        //insert TestDatafactory_Zscaler.liketolike();
        //insert TestDatafactory_Zscaler.skusNSInteg();
        
        Account accountRec = [Select Id from Account Where Name = 'Test Account' LIMIT 1];

        opportunity opportunityRec = [Select Id from opportunity where Name = 'Test Opportunity' LIMIT 1];
        
        Product2 productRec = [Select Id from Product2 Where Name = 'test product 1' LIMIT 1];
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        //Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment, Type = 'New Business');
        //insert opportunity;**/
        
        
        //Price List
        /**Apttus_Config2__PriceList__c testPriceList = new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List',
                                                                                    Apttus_Config2__AccountId__c = accountRec.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041992',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList;

        Map<id,product2> prdlistMap = new map<Id,product2> ( [Select Id From Product2 Where ProductCode = 'ZSC-SIP' ]);
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = accountRec.Id, Apttus_Proposal__Opportunity__c = opportunityRec.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        String proposalId = proposal.Id;

        APTS_TestUtil.createProposalLineItem(proposalId, productRec.id);

        Apttus_Config2__PriceListItem__c PriceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c IN : prdlistMap.keySet() And Apttus_Config2__Active__c = true Limit 1][0].Id;

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
            lineItem1.Apttus_Config2__LineStatus__c = 'Cancelled';
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
        }
        update lineItemList;

        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 2;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__SellingFrequency__c = 'One Time';
        lineItemToInsert.Apttus_Config2__SellingTerm__c = 12;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        lineItemToInsert.Apttus_Config2__LineStatus__c = 'Cancelled';
        lineItemToInsert.Apttus_Config2__PriceAdjustment__c = 100;
        insert lineItemToInsert;

        List<Apttus_Config2__SummaryGroup__c> summaryGroupList = new List<Apttus_Config2__SummaryGroup__c>();
        Apttus_Config2__SummaryGroup__c summaryGroup1 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup1.Name = 'Total (Yearly)';
        summaryGroup1.Apttus_Config2__LineNumber__c = 1;
        summaryGroup1.APTS_Credit__c = 100;
        summaryGroup1.Apttus_Config2__NetPrice__c = 100;
        summaryGroup1.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup1.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup1);

        Apttus_Config2__SummaryGroup__c summaryGroup2 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup2.Name = 'Total (One Time)';
        summaryGroup2.Apttus_Config2__LineNumber__c = 2;
        summaryGroup2.APTS_Credit__c = 100;
        summaryGroup2.Apttus_Config2__NetPrice__c = 100;
        summaryGroup2.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup2.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup2);

        Apttus_Config2__SummaryGroup__c summaryGroup3 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup3.Name = 'Grand Total';
        summaryGroup3.Apttus_Config2__LineNumber__c = 3;
        summaryGroup3.APTS_Credit__c = 200;
        summaryGroup3.Apttus_Config2__NetPrice__c = 200;
        summaryGroup3.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup3.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup3);

        insert summaryGroupList;**/
    }

    static testMethod void summaryGroupCredit() {
        
        Account accountRec = [Select Id from Account Where Name = 'Test Account' LIMIT 1];

        opportunity opportunityRec = [Select Id from opportunity where Name = 'Test Opportunity' LIMIT 1];
        
        Product2 productRec = [Select Id from Product2 Where Name = 'test product 1' LIMIT 1];
        
        
        Apttus_Config2__PriceList__c testPriceList = new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List',
                                                                                    Apttus_Config2__AccountId__c = accountRec.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041992',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList;

        Map<id,product2> prdlistMap = new map<Id,product2> ( [Select Id From Product2 Where ProductCode = 'ZSC-SIP' ]);
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = accountRec.Id, Apttus_Proposal__Opportunity__c = opportunityRec.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        String proposalId = proposal.Id;

        APTS_TestUtil.createProposalLineItem(proposalId, productRec.id);

        Apttus_Config2__PriceListItem__c PriceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c IN : prdlistMap.keySet() And Apttus_Config2__Active__c = true Limit 1][0].Id;

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
            lineItem1.Apttus_Config2__LineStatus__c = 'Cancelled';
            lineItem1.Apttus_Config2__PriceAdjustment__c = 100;
        }
        update lineItemList;

        String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Test.startTest();
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 2;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__SellingFrequency__c = 'One Time';
        lineItemToInsert.Apttus_Config2__SellingTerm__c = 12;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        lineItemToInsert.Apttus_Config2__LineStatus__c = 'Cancelled';
        lineItemToInsert.Apttus_Config2__PriceAdjustment__c = 100;
        insert lineItemToInsert;

        List<Apttus_Config2__SummaryGroup__c> summaryGroupList = new List<Apttus_Config2__SummaryGroup__c>();
        Apttus_Config2__SummaryGroup__c summaryGroup1 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup1.Name = 'Total (Yearly)';
        summaryGroup1.Apttus_Config2__LineNumber__c = 1;
        summaryGroup1.APTS_Credit__c = 100;
        summaryGroup1.Apttus_Config2__NetPrice__c = 100;
        summaryGroup1.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup1.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup1);

        Apttus_Config2__SummaryGroup__c summaryGroup2 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup2.Name = 'Total (One Time)';
        summaryGroup2.Apttus_Config2__LineNumber__c = 2;
        summaryGroup2.APTS_Credit__c = 100;
        summaryGroup2.Apttus_Config2__NetPrice__c = 100;
        summaryGroup2.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup2.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup2);

        Apttus_Config2__SummaryGroup__c summaryGroup3 = new Apttus_Config2__SummaryGroup__c();
        summaryGroup3.Name = 'Grand Total';
        summaryGroup3.Apttus_Config2__LineNumber__c = 3;
        summaryGroup3.APTS_Credit__c = 200;
        summaryGroup3.Apttus_Config2__NetPrice__c = 200;
        summaryGroup3.Apttus_Config2__ConfigurationId__c = configId;
        summaryGroup3.Apttus_Config2__ItemSequence__c = 1;
        summaryGroupList.add(summaryGroup3);

        insert summaryGroupList;
        
        /**String soqlQuery = getCreatableFieldsSOQL('Apttus_Config2__LineItem__c','id=\''+ lineItemId + '\'');
        Apttus_Config2__LineItem__c lineItemToClone = (Apttus_Config2__LineItem__c)Database.query(soqlQuery);
        Test.startTest();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.fsAccountOwnerIdUpdateExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateContactRoleCountExecuted();
        Apttus_Config2__LineItem__c lineItemToInsert = lineItemToClone.clone(false,true,false,false);
        lineItemToInsert.Apttus_Config2__ItemSequence__c = 3;
        lineItemToInsert.Apttus_Config2__IsPrimaryLine__c = false;
        lineItemToInsert.Apttus_Config2__StartDate__c = Date.today();
        lineItemToInsert.Apttus_Config2__EndDate__c = Date.today() + 365;
        insert lineItemToInsert;**/

        Test.stopTest();
    }

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