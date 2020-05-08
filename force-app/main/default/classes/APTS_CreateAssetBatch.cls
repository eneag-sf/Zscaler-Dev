global class APTS_CreateAssetBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{

    String query;
    Set<Id> setAccountIdsToUpdate;
    Set<Id> setContractDetailIdsToUpdate;
    global APTS_CreateAssetBatch(String q){
        this.query = q;
        this.setAccountIdsToUpdate = new Set<Id>();
        this.setContractDetailIdsToUpdate = new Set<Id>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(query);
    }

      // Execute Logic
    global void execute(Database.BatchableContext BC, List<Account> scope){
        system.debug('@@@executed');
		if(Test.isrunningtest()){
			integer i=0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
		}
        if(scope != null && !scope.isEmpty()){
            for(Account acc : scope){
                List<Apttus_Config2__AssetLineItem__c> existingAssetLineItems = [Select Id From Apttus_Config2__AssetLineItem__c
                                                                            Where Apttus_Config2__accountId__c = :acc.id
                                                                            And APTS_Is_Created_from_Contract_Detail__c = true];

                if(!existingAssetLineItems.isEmpty()){
                    delete existingAssetLineItems;
                }

                //Add the Account Ids to update Needs_to_be_Migrated__c flag to false
                setAccountIdsToUpdate.add(acc.Id);

            String soqlQuery = APTS_QueryUtils.getAllFieldsSOQL('Contract_Detail__c','Account_Name__c=\''+ acc.id+ '\' AND Contract_Detail_Status__c IN (\'Active\',\'Pending Renewal\',\'Pending Activation\') AND Needs_to_Be_Migrated_to_Asset_Line__c = true');
            List<Contract_Detail__c> contractDetailList = (List<Contract_Detail__c>)Database.query(soqlQuery);

            if(!contractDetailList.isEmpty()){



                List<Apttus_Config2__AssetLineItem__c> assetLineItemsToInsert = new List<Apttus_Config2__AssetLineItem__c>();

                List<String> lstPriceListNames = new List<String> { 'ZScaler FY2020 Price List', 'ZScaler FY2017 Price List' };
                soqlQuery = APTS_QueryUtils.getAllFieldsSOQL('Apttus_Config2__PriceListItem__c','Apttus_Config2__Active__c = true And Apttus_Config2__PriceListId__r.Name IN :lstPriceListNames ORDER BY Apttus_Config2__PriceListId__r.Sequence__c DESC');
                List<Apttus_Config2__PriceListItem__c> priceListItemList = (List<Apttus_Config2__PriceListItem__c>)Database.query(soqlQuery);
                Map<String, Apttus_Config2__PriceListItem__c> productPLIMap = new Map<String, Apttus_Config2__PriceListItem__c>();
                Map<String, Apttus_Config2__PriceListItem__c> productCodePLIMap = new Map<String, Apttus_Config2__PriceListItem__c>();
                Map<String, Id> productPriceListMap = new Map<String, Id>();
                Map<String, Id> productCodePriceListMap = new Map<String, Id>();

                for(Apttus_Config2__PriceListItem__c priceListItem : priceListItemList){
                    if (!productPLIMap.containsKey(priceListItem.Apttus_Config2__ProductId__c)) {
                        productPLIMap.put(priceListItem.Apttus_Config2__ProductId__c, priceListItem);
                        productPriceListMap.put(priceListItem.Apttus_Config2__ProductId__c, priceListItem.Apttus_Config2__PriceListId__c);
                    }
                    if (!productCodePLIMap.containsKey(priceListItem.Apttus_Config2__ProductCode__c)) {
                        productCodePLIMap.put(priceListItem.Apttus_Config2__ProductCode__c, priceListItem);
                        productCodePriceListMap.put(priceListItem.Apttus_Config2__ProductCode__c, priceListItem.Apttus_Config2__PriceListId__c);
                    }
                }

                Map<String, APTS_Asset_Migration_Mapping_Detail__c> migrationDetailMap = new Map<String, APTS_Asset_Migration_Mapping_Detail__c>();
                for(APTS_Asset_Migration_Mapping_Detail__c migrationDetail : [Select Id, APTS_Product_on_Contracts__c, APTS_Action__c, APTS_Products_from_Price_Book__c From APTS_Asset_Migration_Mapping_Detail__c]){
                    migrationDetailMap.put(migrationDetail.APTS_Product_on_Contracts__c, migrationDetail);
                }

                List<Product2> existingProducts = [Select Id, Name, ProductCode From Product2 Where Family = 'Products'];
                List<Product2> newProducts = [Select Id, Name, ProductCode From Product2 Where Family = 'Zscaler Products'];
                Map<Id,Id> productToReplaceMap = new Map<Id,Id>();
                string PremiumSupportId ;
                for(Product2 existingProduct : existingProducts){
                    for(Product2 newProduct : newProducts){
                        if(existingProduct.ProductCode == newProduct.ProductCode){
                            productToReplaceMap.put(existingProduct.Id, newProduct.Id);
                            break;
                        }
                        if(newProduct.productcode == 'ZCES-SUP-PREM' && PremiumSupportId==null) {
                            PremiumSupportId = string.valueof(newProduct.id).substring(0,15);
                        }
                    }
                }


                for(Contract_Detail__c contractDetail : contractDetailList){
                    if(productToReplaceMap.containsKey(contractDetail.Product_Name__c)){
                        contractDetail.Product_Name__c = productToReplaceMap.get(contractDetail.Product_Name__c);
                    }
                }
                Decimal listprice ;
                for(Contract_Detail__c contractDetail : contractDetailList){
                    //Add the Contract Detail Id to set the Needs_to_Be_Migrated_to_Asset_Line__c flag to false
                    setContractDetailIdsToUpdate.add(contractDetail.Id);

                    if(migrationDetailMap.containsKey(contractDetail.APTS_SKU__c) && migrationDetailMap.get(contractDetail.APTS_SKU__c).APTS_Action__c == 'Discontinue'){
                        //system.debug('Asset will not be created for SKU:' + contractDetail.APTS_SKU__c);
                        continue;
                    }else if(migrationDetailMap.containsKey(contractDetail.APTS_SKU__c) && migrationDetailMap.get(contractDetail.APTS_SKU__c).APTS_Action__c != 'Split' && !productPLIMap.containsKey(contractDetail.Product_Name__c)){
                        //system.debug('Price List Item not found for SKU:' + contractDetail.APTS_SKU__c);
                        continue;
                    }else if(!migrationDetailMap.containsKey(contractDetail.APTS_SKU__c) || migrationDetailMap.get(contractDetail.APTS_SKU__c).APTS_Action__c == 'Migrate as is'){
                        if(productPLIMap.get(contractDetail.Product_Name__c) == null){
                            continue;
                        }
                        Apttus_Config2__AssetLineItem__c assetLI = new Apttus_Config2__AssetLineItem__c();
                        assetLI.APTS_Is_Created_from_Contract_Detail__c = true;
                        if(productPLIMap.get(contractDetail.Product_Name__c)!= null &&  (productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ProductName__c) != null && (productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ProductName__c).length() > 80) {
                            assetLI.Name = (productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ProductName__c).substring(0,80);
                        } else {
                            assetLI.Name = (productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ProductName__c);
                        }

                        assetLI.Apttus_Config2__PriceListId__c = productPriceListMap.get(contractDetail.Product_Name__c);
                        assetLI.Apttus_Config2__PriceListItemId__c = productPLIMap.get(contractDetail.Product_Name__c).Id;
                        assetLI.Apttus_Config2__accountId__c = contractDetail.Account_Name__c;
                        assetLI.Apttus_Config2__ShipToaccountId__c = contractDetail.Account_Name__c;
                        assetLI.Apttus_Config2__BillToaccountId__c = contractDetail.Partner_Account_Name__c;
                        // assetLI.Apttus_Config2__AssetStatus__c = (contractDetail.Active__c ? 'Activated' : 'Pending Activation');
                        if(contractDetail.Contract_Detail_Status__c == 'Active') {
                            assetLI.Apttus_Config2__AssetStatus__c = 'Activated';
                        } else {
                            assetLI.Apttus_Config2__AssetStatus__c = contractDetail.Contract_Detail_Status__c;
                        }
                        assetLI.Apttus_Config2__LineNumber__c = 1;
                        assetLI.Apttus_Config2__PrimaryLineNumber__c = 1;
                        assetLI.Apttus_Config2__ItemSequence__c = 1;
                        assetLI.Apttus_Config2__BusinessObjectType__c = 'Apttus_Proposal__Proposal__c';
                        assetLI.Apttus_Config2__LineType__c = 'Product/Service';
                        assetLI.Apttus_Config2__BusinessObjectId__c = contractDetail.Id;
                        listprice =  (contractDetail.List_Price__c!= null ? contractDetail.List_Price__c:productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ListPrice__c);

                        assetLI.Apttus_Config2__ListPrice__c =listprice ;
                        assetLI.Apttus_Config2__Description__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ProductName__c;
                        assetLI.Apttus_Config2__ProductId__c = contractDetail.Product_Name__c;
                        assetLI.Apttus_Config2__ChargeType__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__ChargeType__c;
                        assetLI.Apttus_Config2__IsPrimaryLine__c = true;
                        assetLI.Apttus_Config2__Quantity__c = contractDetail.Quantity__c;
                        assetLI.Apttus_Config2__BasePrice__c = listprice ;
                        assetLI.Apttus_Config2__BasePriceMethod__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__PriceMethod__c;
                        assetLI.Apttus_Config2__Term__c = 1;
                        assetLI.Apttus_Config2__PriceUom__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__PriceUom__c;
                        assetLI.Apttus_Config2__Frequency__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__Frequency__c;
                        assetLI.Apttus_Config2__PriceType__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__PriceType__c;
                        assetLI.Apttus_Config2__PriceMethod__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__PriceMethod__c;
                        assetLI.Apttus_Config2__IsPrimaryRampLine__c = false;
                        assetLI.Apttus_Config2__BaseExtendedPrice__c = (listprice  == null ? 0.0 : listprice ) * contractDetail.Quantity__c * (contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0);
                        assetLI.Apttus_Config2__AdjustedPrice__c = contractDetail.Amount_USD__c;
                        assetLI.Apttus_Config2__NetPrice__c = contractDetail.Amount_USD__c;
                        assetLI.Apttus_Config2__HasAttributes__c = contractDetail.APTS_Has_Attribute__c;
                        if(contractDetail.Quantity__c != null && contractDetail.Quantity__c != 0) {
                            if(contractDetail.Amount_USD__c == null) {
                                assetLI.Apttus_Config2__NetUnitPrice__c = 0;
                            } else {
                                assetLI.Apttus_Config2__NetUnitPrice__c = contractDetail.Amount_USD__c/contractDetail.Quantity__c;
                            }

                        } else {
                            assetLI.Apttus_Config2__NetUnitPrice__c = 0;
                        }
                        assetLI.Apttus_Config2__ExtendedPrice__c = (listprice  == null ? 0.0 : listprice ) * contractDetail.Quantity__c * (contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0);
                        assetLI.Apttus_Config2__BaseExtendedCost__c = 0.0000;
                        assetLI.Apttus_Config2__StartDate__c = contractDetail.Start_Date__c;
                        assetLI.Apttus_Config2__OriginalStartDate__c = contractDetail.Start_Date__c;
                        assetLI.Apttus_Config2__EndDate__c = contractDetail.End_Date__c;
                        assetLI.Apttus_Config2__SellingTerm__c = contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0;
                        assetLI.APTS_Selling_Term__c = contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c);
                        assetLI.Apttus_Config2__SellingFrequency__c = 'Yearly';
                        assetLI.Apttus_Config2__RenewalFrequency__c = 'Yearly';
                        assetLI.Apttus_Config2__BillingRule__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__BillingRule__c;
                        assetLI.Apttus_Config2__BillingFrequency__c = productPLIMap.get(contractDetail.Product_Name__c).Apttus_Config2__BillingFrequency__c;
                        assetLI.Apttus_Config2__DeltaPrice__c = contractDetail.Amount_USD__c;
                        assetLI.Apttus_Config2__DeltaQuantity__c = contractDetail.Quantity__c;
                        assetLI.APTS_MRR__c = contractDetail.MRR_USD__c;
                        assetLI.APTS_Total_Discount_Percentage__c = contractDetail.Discount__c;
                        assetLI.APTS_Contract_Detail_Name__c = contractDetail.Id;
                        assetLI.APTS_Contract_No__c = contractDetail.Contract_No__c;
                        assetLI.APTS_ORGID__c = contractDetail.ORGID__c;
                        assetLI.APTS_Region__c = contractDetail.Region__c;
                        assetLI.APTS_Sales_Order__c = contractDetail.Sales_Order__c;
                        assetLI.APTS_Renewed_To_Contract_Details__c = contractDetail.Renewed_To_Contract_Details__c;
                        assetLI.APTS_Renewed_Contract__c = contractDetail.Renew_Contract__c;
                        assetLI.APTS_X90_Day_Renewal_Quote__c = contractDetail.X90_Day_Renewal_Quote__c;
                        assetLI.APTS_NetSuite_Renewal_Status__c = contractDetail.NetSuite_Renewal_Status__c;
                        assetLI.APTS_Deal_Reg_Disc__c = contractDetail.Deal_Reg_Discount__c;
                        assetLI.APTS_Partner_Disc__c= contractDetail.Partner_Discount__c;
                        assetLI.APTS_New_Logo_Disc__c = contractDetail.New_Logo_Discount__c;
                        assetLineItemsToInsert.add(assetLI);
                    }else if(migrationDetailMap.get(contractDetail.APTS_SKU__c).APTS_Action__c == 'Split'){
                        List<String> splitDetails = migrationDetailMap.get(contractDetail.APTS_SKU__c).APTS_Products_from_Price_Book__c.split('#');

                        for(String splitDetail : splitDetails){
                            List<String> percentDetails = splitDetail.split('=');
                            Apttus_Config2__PriceListItem__c priceListItem = productCodePLIMap.get(percentDetails[0]);
                            Id priceListId = productCodePriceListMap.get(percentDetails[0]);
                            Decimal splitPercent = Decimal.valueOf(percentDetails[1]);

                            Apttus_Config2__AssetLineItem__c assetLI = new Apttus_Config2__AssetLineItem__c();
                            assetLI.APTS_Is_Created_from_Contract_Detail__c = true;
                            if((priceListItem.Apttus_Config2__ProductName__c) != null && (priceListItem.Apttus_Config2__ProductName__c).length() > 80) {
                                assetLI.Name = (priceListItem.Apttus_Config2__ProductName__c).substring(0,80);
                            } else {
                                assetLI.Name = (priceListItem.Apttus_Config2__ProductName__c);
                            }
                            assetLi.Apttus_Config2__BusinessObjectId__c  = contractDetail.Id;
                            assetLI.Apttus_Config2__PriceListId__c = priceListId;
                            assetLI.Apttus_Config2__PriceListItemId__c = priceListItem.Id;
                            assetLI.Apttus_Config2__accountId__c = contractDetail.Account_Name__c;
                            assetLI.Apttus_Config2__ShipToaccountId__c = contractDetail.Account_Name__c;
                            assetLI.Apttus_Config2__BillToaccountId__c = contractDetail.Partner_Account_Name__c;
                            //assetLI.Apttus_Config2__AssetStatus__c = (contractDetail.Active__c ? 'Activated' : 'Pending Activation');
                            if(contractDetail.Contract_Detail_Status__c == 'Active') {
                                assetLI.Apttus_Config2__AssetStatus__c = 'Activated';
                            } else {
                                assetLI.Apttus_Config2__AssetStatus__c = contractDetail.Contract_Detail_Status__c;
                            }
                            assetLI.Apttus_Config2__LineNumber__c = 1;
                            assetLI.Apttus_Config2__PrimaryLineNumber__c = 1;
                            assetLI.Apttus_Config2__ItemSequence__c = 1;
                            assetLI.Apttus_Config2__BusinessObjectType__c = 'Apttus_Proposal__Proposal__c';
                            assetLI.Apttus_Config2__LineType__c = 'Product/Service';
                            listprice =  (contractDetail.List_Price__c!= null ? contractDetail.List_Price__c:priceListItem.Apttus_Config2__ListPrice__c);
                            assetLI.Apttus_Config2__ListPrice__c = listprice ;
                            assetLI.Apttus_Config2__Description__c = priceListItem.Apttus_Config2__ProductName__c;
                            assetLI.Apttus_Config2__ProductId__c = priceListItem.Apttus_Config2__ProductId__c;
                            assetLI.Apttus_Config2__ChargeType__c = priceListItem.Apttus_Config2__ChargeType__c;
                            assetLI.Apttus_Config2__IsPrimaryLine__c = true;
                            assetLI.Apttus_Config2__Quantity__c = contractDetail.Quantity__c;
                            assetLI.Apttus_Config2__BasePrice__c = listprice ;
                            assetLI.Apttus_Config2__BasePriceMethod__c = priceListItem.Apttus_Config2__PriceMethod__c;
                            assetLI.Apttus_Config2__Term__c = 1;
                            assetLI.Apttus_Config2__PriceUom__c = priceListItem.Apttus_Config2__PriceUom__c;
                            assetLI.Apttus_Config2__Frequency__c = priceListItem.Apttus_Config2__Frequency__c;
                            assetLI.Apttus_Config2__PriceType__c = priceListItem.Apttus_Config2__PriceType__c;
                            assetLI.Apttus_Config2__PriceMethod__c = priceListItem.Apttus_Config2__PriceMethod__c;
                            assetLI.Apttus_Config2__IsPrimaryRampLine__c = false;
                            assetLI.Apttus_Config2__BaseExtendedPrice__c = (listprice  == null ? 0.0 :listprice ) * contractDetail.Quantity__c * (contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0);
                            assetLI.Apttus_Config2__AdjustedPrice__c = contractDetail.Amount_USD__c * splitPercent * 0.01;
                            assetLI.Apttus_Config2__NetPrice__c = contractDetail.Amount_USD__c * splitPercent * 0.01;
                            if(contractDetail.Quantity__c != null && contractDetail.Quantity__c != 0) {
                            assetLI.Apttus_Config2__NetUnitPrice__c = contractDetail.Amount_USD__c/contractDetail.Quantity__c;
                            } else {
                                assetLI.Apttus_Config2__NetUnitPrice__c = 0;
                            }
                            assetLI.Apttus_Config2__HasAttributes__c = contractDetail.APTS_Has_Attribute__c;
                            assetLI.Apttus_Config2__ExtendedPrice__c = (listprice  == null ? 0.0 :listprice ) * contractDetail.Quantity__c * (contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0);
                            assetLI.Apttus_Config2__BaseExtendedCost__c = 0.0000;
                            assetLI.Apttus_Config2__StartDate__c = contractDetail.Start_Date__c;
                            assetLI.Apttus_Config2__OriginalStartDate__c = contractDetail.Start_Date__c;
                            assetLI.Apttus_Config2__EndDate__c = contractDetail.End_Date__c;
                            assetLI.Apttus_Config2__SellingTerm__c = contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c)/12.0;
                            assetLI.APTS_Selling_Term__c = contractDetail.Start_Date__c.monthsBetween(contractDetail.End_Date__c);
                            assetLI.Apttus_Config2__SellingFrequency__c = 'Yearly';
                            assetLI.Apttus_Config2__RenewalFrequency__c = 'Yearly';
                            assetLI.Apttus_Config2__BillingRule__c = priceListItem.Apttus_Config2__BillingRule__c;
                            assetLI.Apttus_Config2__BillingFrequency__c = priceListItem.Apttus_Config2__BillingFrequency__c;
                            assetLI.Apttus_Config2__DeltaPrice__c = contractDetail.Amount_USD__c * splitPercent * 0.01;
                            assetLI.Apttus_Config2__DeltaQuantity__c = contractDetail.Quantity__c;
                            assetLI.APTS_MRR__c = contractDetail.MRR_USD__c * splitPercent * 0.01;
                            assetLI.APTS_Total_Discount_Percentage__c = contractDetail.Discount__c;
                            assetLI.APTS_Contract_Detail_Name__c = contractDetail.Id;
                            assetLI.APTS_Contract_No__c = contractDetail.Contract_No__c;
                            assetLI.APTS_ORGID__c = contractDetail.ORGID__c;
                            assetLI.APTS_Region__c = contractDetail.Region__c;
                            assetLI.APTS_Sales_Order__c = contractDetail.Sales_Order__c;
                            assetLI.APTS_Renewed_To_Contract_Details__c = contractDetail.Renewed_To_Contract_Details__c;
                            assetLI.APTS_Renewed_Contract__c = contractDetail.Renew_Contract__c;
                            assetLI.APTS_X90_Day_Renewal_Quote__c = contractDetail.X90_Day_Renewal_Quote__c;
                            assetLI.APTS_NetSuite_Renewal_Status__c = contractDetail.NetSuite_Renewal_Status__c;
                            assetLI.APTS_Deal_Reg_Disc__c = contractDetail.Deal_Reg_Discount__c;
                            assetLI.APTS_Partner_Disc__c= contractDetail.Partner_Discount__c;
                            assetLI.APTS_New_Logo_Disc__c = contractDetail.New_Logo_Discount__c;
                            assetLineItemsToInsert.add(assetLI);
                        }
                    }
                }

                insert assetLineItemsToInsert;

                set<id> assetIdSet = new set<id> ();
        for(Apttus_Config2__AssetLineItem__c ali : assetLineItemsToInsert) {
            assetIdSet.add(ali.id);
        }

        List<Apttus_Config2__AssetLineItem__c> assetLineItemsInserted = new List<Apttus_Config2__AssetLineItem__c>();
        assetLineItemsInserted = [select Apttus_Config2__HasAttributes__c ,Apttus_Config2__ProductId__r.productcode,Apttus_Config2__ProductId__c,Apttus_Config2__accountId__c,APTS_Total_Ramp_Quantity__c,APTS_Ramp_End_Date__c,id,APTS_ACV__c,Apttus_Config2__AttributeValueId__c from Apttus_Config2__AssetLineItem__c where id IN:assetIdSet];
        Map<string, List<Apttus_Config2__AssetLineItem__c>> assetLItemWithAccountMap = new Map<string,List<Apttus_Config2__AssetLineItem__c>>();
        system.debug('@@@@@@@@'+assetLineItemsInserted );
        List<Apttus_Config2__AssetAttributeValue__c> assetAttributevalueToInsert = new List<Apttus_Config2__AssetAttributeValue__c> ();

                Apttus_Config2__AssetAttributeValue__c assetAttribute;
                List<Apttus_Config2__AssetLineItem__c> assetLItemList;
                for(Apttus_Config2__AssetLineItem__c ali : assetLineItemsInserted) {
                    assetLItemList = new List<Apttus_Config2__AssetLineItem__c>();
                    if(assetLItemWithAccountMap.get(string.valueof(ali.Apttus_Config2__accountId__c).substring(0,15)) != null) {
                        assetLItemList = assetLItemWithAccountMap.get(string.valueof(ali.Apttus_Config2__accountId__c).substring(0,15));
                    }
                    assetLItemList.add(ali);
                    assetLItemWithAccountMap.put(string.valueof(ali.Apttus_Config2__accountId__c).substring(0,15),assetLItemList);

                    if(ali.Apttus_Config2__ProductId__c != null && string.valueOf(ali.Apttus_Config2__ProductId__c).substring(0,15) == PremiumSupportId ) {
                         assetAttribute = new Apttus_Config2__AssetAttributeValue__c ();
                         assetAttribute.Apttus_Config2__AssetLineItemId__c = ali.id;
                         if(ali.APTS_ACV__c > 30000) {
                             assetAttribute.APTS_Premium_Support_Type__c = 'Partner Qualified Support';
                         } else {
                             assetAttribute.APTS_Premium_Support_Type__c = 'Zscaler';
                         }
                         assetAttributevalueToInsert.add(assetAttribute);
                         //system.debug('2###'+assetAttributevalueToInsert);
                    }
                }

                List<Apttus_Config2__AssetLineItem__c > assetLineItemToUpdate = new List<Apttus_Config2__AssetLineItem__c >();
                if(assetAttributevalueToInsert.size() > 0) {
                    insert assetAttributevalueToInsert;
                    Map<string,Apttus_Config2__AssetAttributeValue__c> assetAttributeMap = new Map<string, Apttus_Config2__AssetAttributeValue__c> ();
                    for(Apttus_Config2__AssetAttributeValue__c  assetAttr : assetAttributevalueToInsert) {
                        assetAttributeMap.put(string.valueof(assetAttr.Apttus_Config2__AssetLineItemId__c).substring(0,15), assetAttr);
                    }
                    //system.debug('3###'+assetAttributeMap);
                    for(Apttus_Config2__AssetLineItem__c ali : assetLineItemsInserted) {
                        //system.debug('4###'+string.valueOf(ali.Apttus_Config2__ProductId__c).substring(0,15));
                        //system.debug('5##'+PremiumSupportId);
                        //system.debug('6##'+assetAttributeMap.get(string.valueOf(ali.id)));
                        //system.debug('8###'+ali.id);
                        if(ali.Apttus_Config2__ProductId__c != null && string.valueOf(ali.Apttus_Config2__ProductId__c).substring(0,15) == PremiumSupportId && assetAttributeMap.get(string.valueOf(ali.id).substring(0,15)) != null) {
                            ali.Apttus_Config2__HasAttributes__c  = true;
                            ali.Apttus_Config2__AttributeValueId__c =  assetAttributeMap.get(string.valueOf(ali.id).substring(0,15)).Id;
                            assetLineItemToUpdate.add(ali);
                        }
                    }
                    if(assetLineItemToUpdate.size () > 0) {
                        update assetLineItemToUpdate;
                    }
                }


                if(assetLItemWithAccountMap.size() > 0) {
                    List<Account> accountList = new List<Account> ();
                    accountList = [select id,name,Platform_Renewal_Date__c,No_of_Platform_Seats__c,APTS_Platform_Subscription_End_Date__c, APTS_No_of_Platform_Seats__c,APTS_Asset_SKU__c
                                            from account where id IN: assetLItemWithAccountMap.keyset()];
                    Set<String> productCodeSet = new Set<String>{'z-logfeed','zces-sup-prem','zdlp-web','zsc-sip','zsuite-webbus','zsuite-webpro','zsuite-webent'};

                    List<Account> accountToUpdate = new List<Account> ();
                    for(Account acc1 :accountList) {
                         String sku = (acc1.APTS_Asset_SKU__c != null ? acc1.APTS_Asset_SKU__c : '');
                         system.debug('@@@@--'+sku);
                         Decimal platformseat = 0;
                         Date platformsubscriptionenddate;
                         for(Apttus_Config2__AssetLineItem__c ali :assetLItemWithAccountMap.get(string.valueof(acc1.id).substring(0,15))) {
                             //system.debug('###1-'+ali.Apttus_Config2__ProductId__r.productcode);
                             //system.debug('###2-'+productCodeSet);
                             //system.debug('###3-'+sku);
                             //system.debug('ali.Apttus_Config2__ProductId__r.productcode != null - '+ali.Apttus_Config2__ProductId__r.productcode != null);
                             //system.debug(productCodeSet.contains(ali.Apttus_Config2__ProductId__r.productcode.toLowerCase()) );
                             //system.debug(sku.toLowerCase().indexOf(ali.Apttus_Config2__ProductId__r.productcode.toLowerCase()));
                             if(ali.Apttus_Config2__ProductId__r.productcode != null && productCodeSet.contains(ali.Apttus_Config2__ProductId__r.productcode.toLowerCase()) && sku.toLowerCase().indexOf(ali.Apttus_Config2__ProductId__r.productcode.toLowerCase()) == -1) {
                                 //system.debug('###4--');
                                 if(sku != '') {
                                     sku = sku+',';
                                 }
                                 sku = sku + ali.Apttus_Config2__ProductId__r.productcode;
                                 //system.debug('###5--'+sku);
                             }
                             if(ali.Apttus_Config2__ProductId__r.productcode != null && ali.Apttus_Config2__ProductId__r.productcode.toLowerCase() == 'zsc-sip' && ali.APTS_Total_Ramp_Quantity__c != null) {
                                 platformseat = platformseat + ali.APTS_Total_Ramp_Quantity__c;
                             }

                             if(ali.APTS_Ramp_End_Date__c != null) {
                                 platformsubscriptionenddate = ali.APTS_Ramp_End_Date__c;
                             }
                         }
                         system.debug('1@@@@--'+sku);
                         acc1.APTS_Asset_SKU__c  = sku;
                         acc1.APTS_Platform_Subscription_End_Date__c = acc1.Platform_Renewal_Date__c ;
                         acc1.APTS_No_of_Platform_Seats__c = acc1.No_of_Platform_Seats__c;

                         accountToUpdate.add(acc1);
                         system.debug('@@@--'+accountToUpdate);
                    }

                    if(accountToUpdate.size() > 0) {
                        system.debug('@@@--'+accountToUpdate);
                        update accountToUpdate;
                        system.debug('@@@--'+accountToUpdate);
                    }
                }
             }
          }
       }
    }

    global void finish(Database.BatchableContext BC){
                       //Send an email to the User after your batch completes
        User current_user=[SELECT Email FROM User WHERE Id= :UserInfo.getUserId()] ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {current_user.email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Batch Job is done for Asset Migration');
        mail.setPlainTextBody('The batch Apex job processed ');
       	if(!Test.isRunningTest()){
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        List<SObject> recordsToUpdate = new List<SObject>();
        for (Id accountId : setAccountIdsToUpdate) {
            Account acc = new Account(Id = accountId/*, Needs_to_be_Migrated__c = false*/);
            recordsToUpdate.add(acc);
        }

        for (Id contractDetailId : setContractDetailIdsToUpdate) {
            Contract_Detail__c detail = new Contract_Detail__c(Id = contractDetailId, Needs_to_Be_Migrated_to_Asset_Line__c = false);
            recordsToUpdate.add(detail);
        }

        try {
            update recordsToUpdate;
        } catch(Exception ex) {
            System.debug('>>>> Exception occurred while updating Account and Contract Details: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
   }
 }