global class APTS_TestUtil {

   public static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
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
        //opp.StageName = '0 - Initial Prospecting';
        opp.StageName = Label.Stage_1_Alignment;
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = accountId;
        opp.Price_List__c = pricelistId;
        opp.type ='Existing Customer (Renewal)';
        insert opp;
        return opp;
    }

    public static Apttus_Proposal__Proposal__c createproposal (string oppId,string accountId, string pricelistId , boolean isPrimary) {
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();

        prop.Apttus_QPConfig__PriceListId__c = pricelistId;
        prop.Apttus_Proposal__Account__c = accountId;
        prop.Apttus_QPConfig__BillToAccountId__c = accountId;
        prop.Apttus_QPConfig__ShipToAccountId__c = accountId;
        prop.Apttus_Proposal__Opportunity__c = oppId;
        prop.Apttus_Proposal__Primary__c  = isPrimary;
        prop.Apttus_Proposal__Approval_Stage__c = 'Accepted';
        prop.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        prop.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(36);



        insert prop;
        return prop;
    }

    public static string createProduct () {
        product2 prd = new product2 ();
        prd.name = 'test product';
        prd.Apttus_Config2__ConfigurationType__c = 'Standalone';
        insert prd;
        return prd.id;
    }

    public static Apttus_Config2__AssetLineItem__c createassetlineItems (string proposalId,string accountid,string productid,string proposallineitemid) {
        Apttus_Config2__AssetLineItem__c asset = new Apttus_Config2__AssetLineItem__c();
        asset.Apttus_QPConfig__ProposalId__c = proposalId;
        asset.Apttus_Config2__ProductId__c = productid;
        asset.Apttus_Config2__AccountId__c=accountId;
        asset.Apttus_Config2__ChargeType__c='Subscription Fee';
        asset.Apttus_Config2__AssetStatus__c='Activated';
        asset.Apttus_Config2__Quantity__c = 1;
        asset.Apttus_Config2__StartDate__c  = Date.today().addDays(-365);
        asset.Apttus_Config2__EndDate__c  = Date.today();
        asset.Apttus_Config2__IsPrimaryLine__c = true;
        asset.Apttus_QPConfig__ProposalLineItemId__c = proposallineitemid;
        asset.APTS_ACV__c = 5;
        insert asset;
        return asset;
    }

    public static Apttus_Proposal__Proposal_Line_Item__c  createProposalLineItem (string proposalId, string productId) {
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        Apttus_Proposal__Proposal_Line_Item__c prl = new Apttus_Proposal__Proposal_Line_Item__c();
        prl.Apttus_Proposal__Proposal__c = proposalId;
        prl.APTS_MRR__c = 5;
        prl.APTS_ACV__c = 200;
        prl.Apttus_Proposal__Product__c = productId;
        prl.Apttus_QPConfig__NetPrice__c = 200;
        insert prl;
        return prl;
    }


    public static List<product2> createProducts(Integer pcount) {
        List<product2> testProducts = new List<product2>();
        for(Integer i = 0; i < pcount; i++){
            product2 tp = new product2();
            tp.Name = 'test product '+i;
            tp.Apttus_Config2__ConfigurationType__c = 'Standalone';
            tp.ProductCode = 'ZSEC-SKU'+i;
            tp.Family = 'Zscaler Products';
            tp.IsActive = true;
            testProducts.add(tp);
        }
        insert testProducts;
        return testProducts;
    }

    public static List<Apttus_Config2__LineItem__c> createLineItems(Id pConfigSOId, Id pricelistId, List<product2> testProducts){
        List<Apttus_Config2__LineItem__c> testLineItems = new List<Apttus_Config2__LineItem__c>();
        Integer counter = 1;
        for(product2 p : testProducts){
            Apttus_Config2__LineItem__c tli = new Apttus_Config2__LineItem__c();
            tli.Apttus_Config2__ConfigurationId__c = pConfigSOId;
            tli.Apttus_Config2__ProductId__c = p.Id;
            tli.Apttus_Config2__Quantity__c = 10;
            tli.Apttus_Config2__StartDate__c = Date.today();
            tli.Apttus_Config2__EndDate__c = Date.today().addYears(2);
            tli.Apttus_Config2__PrimaryLineNumber__c = counter;
            tli.Apttus_Config2__LineNumber__c = counter;
            tli.Apttus_Config2__ItemSequence__c = 1;
            tli.Apttus_Config2__PriceListId__c = pricelistId;
            tli.Apttus_Config2__SellingFrequency__c = 'Yearly';
            testLineItems.add(tli);
            counter ++;
        }
        insert testLineItems;
        return testLineItems;
    }

    public static List<Apttus_Proposal__Proposal_Line_Item__c>  createProposalLineItems(Apttus_Proposal__Proposal__c proposalSO, List<product2> testProducts){
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        List<Apttus_Proposal__Proposal_Line_Item__c> testProposalLines = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(product2 p : testProducts){
            Apttus_Proposal__Proposal_Line_Item__c pli = new Apttus_Proposal__Proposal_Line_Item__c();
            pli.Apttus_Proposal__Proposal__c = proposalSO.Id;
            pli.Apttus_Proposal__Product__c = p.Id;
            pli.Apttus_QPConfig__NetPrice__c = 200;
            pli.APTS_MRR__c = 5;
            pli.APTS_ACV__c = 200;
            testProposalLines.add(pli);
        }
        insert testProposalLines;
        return testProposalLines;
    }

    public static List<Apttus_Config2__AssetLineItem__c> createassetlineItems(Apttus_Proposal__Proposal__c proposalSO, List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems){
        List<Apttus_Config2__AssetLineItem__c> testAssetLines = new List<Apttus_Config2__AssetLineItem__c>();
        for(Apttus_Proposal__Proposal_Line_Item__c pLI : proposalLineItems){
            Apttus_Config2__AssetLineItem__c assetLI = new Apttus_Config2__AssetLineItem__c();
            assetLI.Apttus_QPConfig__ProposalId__c = proposalSO.Id;
            assetLI.Apttus_QPConfig__ProposalLineItemId__c = pLI.Id;
            assetLI.Apttus_Config2__ProductId__c = pLI.Apttus_Proposal__Product__c;
            assetLI.Apttus_Config2__AccountId__c = proposalSO.Apttus_Proposal__Account__c;
            assetLI.Apttus_Config2__ChargeType__c = 'Subscription Fee';
            assetLI.Apttus_Config2__AssetStatus__c = 'Activated';
            assetLI.Apttus_Config2__Quantity__c = 100;
            assetLI.Apttus_Config2__StartDate__c  = Date.today().addDays(-365);
            assetLI.Apttus_Config2__EndDate__c  = Date.today();
            assetLI.Apttus_Config2__IsPrimaryLine__c = true;
            assetLI.APTS_ACV__c = 5;
            assetLI.Apttus_Config2__DeltaQuantity__c = 2;
            testAssetLines.add(assetLI);
        }
        insert testAssetLines;
        return testAssetLines;
    }
}