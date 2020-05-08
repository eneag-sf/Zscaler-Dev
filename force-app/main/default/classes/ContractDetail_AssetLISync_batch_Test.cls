@isTest
public class ContractDetail_AssetLISync_batch_Test{
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        //Insert Price List
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler FY2017 Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[3].ID));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[4].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[5].Id));
        insert listPLI;
        
        Opportunity opportunity = new Opportunity(Pricebook2Id = PricebookID, Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business', AccountId = account.Id, Netsuite_Sales_Order_No__c = 'Test Order 1');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=account.Id, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceList.Id);
        insert proposal;
        
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        Apttus_Config2__AssetLineItem__c asset = new Apttus_Config2__AssetLineItem__c();
        asset.Apttus_QPConfig__ProposalId__c = proposal.Id;
        asset.Apttus_Config2__ProductId__c = listProduct[0].Id;
        asset.Apttus_Config2__AccountId__c=account.Id;
        asset.Apttus_Config2__ChargeType__c='Subscription Fee';
        asset.Apttus_Config2__AssetStatus__c='Activated';
        asset.Apttus_Config2__Quantity__c = 100;
        asset.Apttus_Config2__StartDate__c  = Date.today();
        asset.Apttus_Config2__EndDate__c  = Date.today()+365;
        asset.Apttus_Config2__IsPrimaryLine__c = true;
        asset.Apttus_Config2__PriceGroup__c ='Price Ramp';
        asset.APTS_ACV__c = 5;
        insert asset;
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
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
        contractDetail1.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        contractDetailList.add(contractDetail1);
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Split';
        contractDetail2.Account_Name__c = account.Id;
        contractDetail2.Product_Name__c = listProduct[1].Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail2);
        
        insert contractDetailList;
        
        ContractDetail_AssetLISync_batch batch;
        Date sd = Date.Today();
        Date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new ContractDetail_AssetLISync_batch(startdate,enddate);
        Database.executeBatch(batch,1);
        
    }
    
    static testmethod void test2(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        //Insert Price List
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler FY2017 Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;
        
        Id PricebookID=Test.getStandardPricebookId();
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[3].ID));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[4].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[5].Id));
        insert listPLI;
        
        Opportunity opportunity = new Opportunity(Pricebook2Id = PricebookID, Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business', AccountId = account.Id, Netsuite_Sales_Order_Number__c = 'Test Order 1');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=account.Id, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceList.Id);
        insert proposal;
        
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        Apttus_Config2__AssetLineItem__c asset = new Apttus_Config2__AssetLineItem__c();
        asset.Apttus_QPConfig__ProposalId__c = proposal.Id;
        asset.Apttus_Config2__ProductId__c = listProduct[0].Id;
        asset.Apttus_Config2__AccountId__c=account.Id;
        asset.Apttus_Config2__ChargeType__c='Subscription Fee';
        asset.Apttus_Config2__AssetStatus__c='Activated';
        asset.Apttus_Config2__Quantity__c = 100;
        asset.Apttus_Config2__StartDate__c  = Date.today();
        asset.Apttus_Config2__EndDate__c  = Date.today()+365;
        asset.Apttus_Config2__IsPrimaryLine__c = true;
        asset.Apttus_Config2__PriceGroup__c ='Price Ramp';
        asset.APTS_ACV__c = 5;
        insert asset;
        
        //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
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
        contractDetail1.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        contractDetailList.add(contractDetail1);
        
        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Split';
        contractDetail2.Account_Name__c = account.Id;
        contractDetail2.Product_Name__c = listProduct[1].Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetailList.add(contractDetail2);
        
        insert contractDetailList;
        
        ContractDetail_AssetLISync_batch batch;
        Date sd = Date.Today();
        Date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new ContractDetail_AssetLISync_batch(startdate,enddate);

        batch.errorlst = new List<String>{'abc'};
        Database.executeBatch(batch,1);
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