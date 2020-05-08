/* APTS_LineItemUtils_Master
* Bulkied methods which do the processing of Line Item(Apttus_Config2__LineItem__c) dml's.
*
* Developer: Harish Emmadi, APTTUS - 10/31/2016
* Business Owner:
*
* Scenario:
*
*
*
* History:
* Harish Emmadi, APTTUS 11/04/2016 - Added Derivation 2.
* Harish Emmadi, APTTUS 11/08/2016 - Added Derivation 3.
* Harish Emmadi, APTTUS 11/10/2016 - Added Derivation 4, Derivation 5.
* Harish Emmadi, APTTUS 11/15/2016 - Commented Derivation 2.
* Harish Emmadi, APTTUS 11/18/2016 - Commented Derivation 6, Derivation 7.
* Harish Emmadi, APTTUS 11/30/2016 - Commented Derivation 8, Derivation 9.
* Harish Emmadi, APTTUS 11/30/2016 - Updated Derivation 5 to include APTS_Total_Term__c.
* Harish Emmadi, APTTUS 12/09/2016 - Updated Derivation 9.
* Harish Emmadi, APTTUS 12/14/2016 - Updated Derivation 6. - [ZSCAL-203]
* Harish Emmadi, APTTUS 12/19/2016 - Updated Derivation 6. - [ZSCAL-203]
* Harish Emmadi, APTTUS 12/27/2016 - Added Derivation 10, Derivation 11.
* Shishir,       APTTUS 12/28/2016 - Added Derivation 12.
* Harish Emmadi, APTTUS 12/29/2016 - Updated Derivation 11.
* Harish Emmadi, APTTUS 01/03/2017 - Updated Derivation 4.
* Harish Emmadi, APTTUS 01/19/2017 - Updated Derivation 11 to remove the recodtype check.
* Kunal Raj, Zscaler 01/23/2017 - Update the approval criteria to be greater than 20%
* Vijay Prakash, Zscaler 01/25/2017 - Updated Derivation 11 to handle Discount Approval suppression logic
* Vijay Prakash, Zscaler 01/31/2017 - Updated Derivation 11 to mark One Time Credit (PROD_SKU_Z_CREDIT) as approval required
* Kunal Raj, Zscaler 05/05/2017 - Update Derivation 12 to calculate correct start date, end date & selling term for Termnation/Swap.
* Vijay Prakash, Zscaler 07/20 - Fixed Total Ramp Quantity getting calculated incorrectly upon editing any ramp lines (except first and last)
*

*/
public without sharing class APTS_LineItemUtils_Master {
    private APTS_LineItemUtils_Master() {

    }

    // Supports only before insert/update trigger.
    // Params: liSOs - Trigger.new
    // Derivation 1. Populate Bill to(Apttus_Config2__BillToAccountId__c), Ship to(Apttus_Config2__ShipToAccountId__c) from product configuration.(Apttus_Config2__ProductConfiguration__c) - looks cant be done through config.
    // Derivation 2. For upsell quotes Populate Apttus_Config2__AssetLineItemId__c from active assets on account if product is (Premium support, NSS, DLP).
    //               Set Apttus_Config2__LineStatus__c to Amended if new product exists in assets.
    //                Populate the pricing fields from asset lines, start and end date from product configuration.
    // Derivation 3: For the Swap(Upgraded) and renew(renewed): quantity should be populated from last ramp asset if ramped else from the primary asset line.
    // Derivation 4: Set Is Asset Pricing(Apttus_Config2__IsAssetPricing__c)to true if line status is Amend, Cancelled, Renewed.
    // Derivation 5: Calculate for all lines except cancelled.
    //               APTS_Total_Ramp_Quantity__c: sum of all lines with same product, if ramped then last ramp quantity is accounted towards the quantity of line.
    //               APTS_Ramp_End_Date__c: Max of all lines with same product, if ramped then last ramp end date is accounted towards the ramp end date.
    //               APTS_Total_Term__c: Sum of all the selling terms where productId is same.
    // Derivation 6: [APTS_Manual_Discount__c]: Drop the manual discount if line status is Renewed on creation and for DAS products.
    // Derivation 7: [Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c]: For one time products remove the Dates.
    // Derivation 8: [APTS_Selling_Term__c]: Apttus_Config2__SellingTerm__c(yearly)*12.
    // Derivation 9: [APTS_MRR__c, APTS_ACV__c]Calculate MRR and ACV for cancelled lines as pricing callback will not be invoked for cancelled lines.
    // Derivation 10: [APTS_User_Manager__c, APTS_User_Geo__c]: populate from proposal owner.
    // Derivation 11: [Apttus_CQApprov__Approval_Status__c]: set the approval status to retrigger the approvals based on field changes. Added detailed description at the actual derivation below.
    // Derivation 12: Setting APTS_No_Co_Term__c, APTS_Ramp_Over_6_Months__c, APTS_Ramped_Months__c
    // Derivation 13: Resetting ZIA_Premium_Support__c, ZIA_Premium_Support_ACV__c, ZPA_Premium_Support__c, ZPA_Premium_Support_ACV__c
    // Derivation 14: Resetting Is Asset Pricing flag for renewed lines
    // Derivation 15: Update the Buy Back Months attribute value in line item

    public static void doBeforeDerivations(List<Apttus_Config2__LineItem__c> liSOs, Map<Id, Apttus_Config2__LineItem__c> liIdToliSOOldMap, Boolean isAfter){
        Set<Id> configIdSet = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Map<Id, Apttus_Config2__ProductConfiguration__c> configIdtoConfigSOMap = new Map<Id, Apttus_Config2__ProductConfiguration__c>();
        Map<Id, List<Apttus_Config2__AssetLineItem__c>> accIdIdtoALISOsMap = new Map<Id, List<Apttus_Config2__AssetLineItem__c>>();
        Map<Id, Decimal> productIdTOTotalRampQuantityMap = new Map<Id, Decimal>();// used to populate total ramp quantity on ramp lines.
        Map<Id, Date> productIdTOEndDateMap = new Map<Id, Date>();// used to populate total ramp quantity on ramp lines.
        Map<Id, Double> productIdTOTotalTermMap = new Map<Id, Double>();// used to populate total term on ramp lines.
        Map<Id, String> productIdTOLineNumberMap = new Map<Id, String>();// used to populate total ramp quantity on ramp lines.
        Map<Id, User> userIdToUserSOMap = new Map<Id, User>();
        Set<String> productCodeSet = new Set<String>{
                                                        APTS_CONSTANTS.PROD_SKU_NSS,
                                                        APTS_CONSTANTS.PROD_SKU_PSUPPORT,
                                                        APTS_CONSTANTS.PROD_SKU_DLP
                                                    };

        // If line item exists in cart with same product that got updated then populate APTS_Total_Ramp_Quantity__c, APTS_Ramp_End_Date__c on existing lines.
        Map<Id, Apttus_Config2__LineItem__c> liIdtolItemSOTobeUpdatedMap = new Map<Id, Apttus_Config2__LineItem__c>();

        for(Apttus_Config2__LineItem__c liSO : liSOs){
            if(liSO.Apttus_Config2__ConfigurationId__c != null){
                configIdSet.add(liSO.Apttus_Config2__ConfigurationId__c);


                // For Derivation 5 - only required on insert or update(Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c)
                // collect the quantity and end dates from current trigger collection, lines from DB are captured below.
                // Assumption1: if ramped, last ramp will always have a highest end date.
                // Assumption2: If a product is added twice to cart then end date will be same.
                Apttus_Config2__LineItem__c liSOOld = liIdToliSOOldMap.get(liSO.Id);
                System.debug('liSO is: '+liSO.Apttus_Config2__LineStatus__c+' liSO.Apttus_Config2__ProductId__c:'+liSO.Apttus_Config2__ProductId__c+' liSO.Apttus_Config2__StartDate__c:'+liSO.Apttus_Config2__StartDate__c+' liSO.Apttus_Config2__EndDate__c:'+liSO.Apttus_Config2__EndDate__c+'liSOOld: '+liSOOld);

                if (liSOOld != null 
                    && liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_100SEATS_PROMO
                    && liSO.Apttus_Config2__StartDate__c != null
                    && liSO.Is_ZPA_100_Seats_Promo_Term_Updated__c != true) {
                    Date endDate = liSO.Apttus_Config2__StartDate__c.addYears(1) - 1;
                    // Date farthestRenewalDueDate = liSO.Farthest_Renewal_Due_Date__c;
                    Date maxEndDate = liSO.Max_End_Date__c > liSO.Farthest_Renewal_Due_Date__c ? liSO.Max_End_Date__c : liSO.Farthest_Renewal_Due_Date__c;
                    System.debug('>>>> endDate: ' + endDate);
                    System.debug('>>>> maxEndDate: ' + maxEndDate);
                    liSO.Apttus_Config2__EndDate__c = endDate < maxEndDate ? endDate : maxEndDate;
                    liSO.Is_ZPA_100_Seats_Promo_Term_Updated__c = true;
                }

                // Vijay - 07/20: Added End Date check to include all ramp lines while calculating the Total Ramp Quantity
                if(liSO.Apttus_Config2__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                   && (liSOOld == null
                       || liSO.Apttus_Config2__Quantity__c != liSOOld.Apttus_Config2__Quantity__c
                       || liSO.Apttus_Config2__StartDate__c != liSOOld.Apttus_Config2__StartDate__c
                       || liSO.Apttus_Config2__EndDate__c != liSOOld.Apttus_Config2__EndDate__c
                       || (productIdTOEndDateMap.containsKey(liSO.Apttus_Config2__ProductId__c) && liSO.Apttus_Config2__EndDate__c > productIdTOEndDateMap.get(liSO.Apttus_Config2__ProductId__c)))){
                           Id productId = liSO.Apttus_Config2__ProductId__c;
                           Date liStartDate = liSO.Apttus_Config2__StartDate__c;
                           Date liEndDate = liSO.Apttus_Config2__EndDate__c;
                           Double liQuantity = liSO.Apttus_Config2__Quantity__c;
                           Double liSellingTerm = liStartDate != null && liEndDate != null ? liStartDate.daysBetween(liEndDate)/365 : 0;
                           String liNumber = liSO.Apttus_Config2__LineNumber__c+''+liSO.Apttus_Config2__ItemSequence__c;
                           if(productIdTOEndDateMap.containsKey(productId))
                           {
                               // replace the quantity if its a ramped line, last ramped line will always have a highest end date of all ramps.
                               if(productIdTOEndDateMap.get(productId) < liEndDate){
                                   productIdTOTotalRampQuantityMap.put(productId, liQuantity);
                                   productIdTOEndDateMap.put(productId, liEndDate);
                               }
                               else if(productIdTOEndDateMap.get(productId) == liEndDate)// add the quantity if a different line with same product on the cart.
                                   productIdTOTotalRampQuantityMap.put(productId, productIdTOTotalRampQuantityMap.get(productId)+liQuantity);

                               productIdTOTotalTermMap.put(productId, productIdTOTotalTermMap.get(productId)+liSellingTerm);
                           }else{
                               productIdTOTotalRampQuantityMap.put(productId, liQuantity);
                               productIdTOEndDateMap.put(productId, liEndDate);
                               productIdTOTotalTermMap.put(productId, liSellingTerm);
                           }
                           productIdTOLineNumberMap.put(productId, liNumber);
                       }
               // System.debug('*** 1 - liSO.Apttus_Config2__AssetQuantity__c: ' + liSO.Apttus_Config2__AssetQuantity__c);
               // if (liSO.Apttus_Config2__AssetQuantity__c != null) {
               //     liSO.Asset_Quantity__c = liSO.Apttus_Config2__AssetQuantity__c;
               // }
            }
        }


        List<Apttus_Config2__ProductConfiguration__c> productConfigList = new List<Apttus_Config2__ProductConfiguration__c> ();

        productConfigList = [Select Id, Apttus_Config2__ShipToAccountId__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__BillToAccountId__r.Name,
                                       Apttus_Config2__AccountId__c, APTS_Record_Type__c, Apttus_Config2__ExpectedStartDate__c,
                                       Apttus_Config2__ExpectedEndDate__c, APTS_Asset_SKU__c, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.OwnerID,
                                       Apttus_Config2__NumberOfItems__c,
                                       APTS_Number_Of_Items_Cancelled__c, APTS_Total_Credit_One_Time__c,
                                       APTS_Total_Credit_One_Time_for_buy_b__c,
                                       APTS_Total_Credit_Yearly__c, APTS_Total_Net_Price_One_Time__c,
                                       APTS_Total_Net_Price_Yearly__c, One_Time_SKUs_List_Price__c,
                                       (Select Id, Name, APTS_Credit__c, Apttus_Config2__NetPrice__c
                                        From Apttus_Config2__SummaryGroups__r),
                                       (Select Id, Apttus_Config2__ProductId__c, Apttus_Config2__Quantity__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
                                            APTS_Total_Ramp_Quantity__c, APTS_Ramp_End_Date__c, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c,
                                            Apttus_Config2__SellingTerm__c, Buyback_Months_Formula__c, Buyback_Months__c, APTS_Product_Code__c
                                            From Apttus_Config2__LineItems__r
                                                Where Id NOT IN :liSOs
                                                      AND Apttus_Config2__LineStatus__c != :APTS_CONSTANTS.LI_STATUS_CANCELLED)
                                            From Apttus_Config2__ProductConfiguration__c
                                                Where Id IN :configIdSet];
        // get all the product configuration SO for the given lines.
        if(isAfter != true) {
            for(Apttus_Config2__ProductConfiguration__c pConfig : productConfigList ){

                configIdtoConfigSOMap.put(pConfig.Id, pConfig);
                userIdToUserSOMap.put(pConfig.Apttus_QPConfig__Proposald__r.OwnerId, null);
                accountIds.add(pConfig.Apttus_Config2__AccountId__c);

                // For Derivation 5.
                for(Apttus_Config2__LineItem__c liSO : pConfig.Apttus_Config2__LineItems__r){
                    // collect the quantity and end dates from existing lines which are not in the trigger collection.
                    // Assumption1: if ramped, last ramp will always have a highest end date.
                    // Assumption2: If a product is added twice to cart then end date will be same.
                    Id productId = liSO.Apttus_Config2__ProductId__c;
                    Date liStartDate = liSO.Apttus_Config2__StartDate__c;
                    Date liEndDate = liSO.Apttus_Config2__EndDate__c;
                    Double liSellingTerm = liStartDate != null && liEndDate != null ? liStartDate.daysBetween(liEndDate)/365 : 0;
                    Double liQuantity = liSO.Apttus_Config2__Quantity__c;
                    String liNumber = liSO.Apttus_Config2__LineNumber__c+''+liSO.Apttus_Config2__ItemSequence__c;
                    if(productIdTOEndDateMap.containsKey(productId)
                        && productIdTOLineNumberMap.get(productId) != liNumber)
                    {
                        // replace the quantity if its a ramped line, last ramped line will always have a highest end date of all ramps.
                        if(productIdTOEndDateMap.get(productId) < liEndDate){
                            productIdTOTotalRampQuantityMap.put(productId, liQuantity);
                            productIdTOEndDateMap.put(productId, liEndDate);
                        }
                        else if(productIdTOEndDateMap.get(productId) == liEndDate)// add the quantity if a different line with same product on the cart.
                        productIdTOTotalRampQuantityMap.put(productId, productIdTOTotalRampQuantityMap.get(productId)+liQuantity);

                        productIdTOTotalTermMap.put(productId, productIdTOTotalTermMap.get(productId)+liSellingTerm);

                        // if any other line item with same product in trigger set exists in DB then it should be updated.
                        liIdtolItemSOTobeUpdatedMap.put(liSO.Id, liSO);
                    }
                    if((liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_BUYBACK || liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK) && liSO.Buyback_Months_Formula__c != liSO.Buyback_Months__c && !liIdtolItemSOTobeUpdatedMap.containsKey(liSO.Id)){
                        liIdtolItemSOTobeUpdatedMap.put(liSO.Id, liSO);
                    }
                }
            }

            // get all User.manager and Geo fields.
            if(!userIdToUserSOMap.isEmpty()){
                userIdToUserSOMap = new Map<Id, User>([Select Id, ManagerId, Geo__c
                                                       From User
                                                       Where Id IN :userIdToUserSOMap.keySet()]);
            }

            // get all Active assets belong to the account where product code is one of (Premium support, NSS, DLP).
            // should be ordered by line number, Apttus_Config2__ItemSequence__c - used to populate quantity on Renewed and Upgraded lines.
            for(Apttus_Config2__AssetLineItem__c aliSO : [Select Id, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.ProductCode,
                                                          Apttus_Config2__AccountId__c, Apttus_Config2__Quantity__c, Apttus_Config2__BundleAssetId__c,
                                                          Apttus_Config2__PriceListId__c, Apttus_Config2__PriceListItemId__c,
                                                          Apttus_Config2__ListPrice__c, Apttus_Config2__BasePrice__c, Apttus_Config2__PriceUom__c,
                                                          Apttus_Config2__PriceType__c, Apttus_Config2__PriceMethod__c, Apttus_Config2__EndDate__c
                                                          From Apttus_Config2__AssetLineItem__c
                                                          Where Apttus_Config2__AccountId__c IN :accountIds
                                                          AND Apttus_Config2__AssetStatus__c = :APTS_CONSTANTS.ALI_STATUS_ACTIVATED
                                                          Order by Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c]){
                                                              Id accountId = aliSO.Apttus_Config2__AccountId__c;
                                                              List<Apttus_Config2__AssetLineItem__c> aliSOList =  accIdIdtoALISOsMap.containsKey(accountId) ? accIdIdtoALISOsMap.get(accountId) : new List<Apttus_Config2__AssetLineItem__c>();
                                                              aliSOList.add(aliSO);
                                                              accIdIdtoALISOsMap.put(accountId, aliSOList);

                    // For Derivation 5.
                    // Add all the active assets with same end date and product to lines in the cart.
                    // productIdTOTotalRampQuantityMap, productIdTOEndDateMap will hold the similar information from line items collection.
                    // use productIdTOEndDateMap to get the validating the end date of asset, asset end date should match with current line in cart.
                    Id prodId = aliSO.Apttus_Config2__ProductId__c;
                    Decimal assetQt = aliSO.Apttus_Config2__Quantity__c;
                    Date assetEndDate = aliSO.Apttus_Config2__EndDate__c;
                    if(prodId != null
                        && productIdTOEndDateMap.containsKey(prodId)
                        && productIdTOEndDateMap.get(prodId) == assetEndDate){
                        productIdTOTotalRampQuantityMap.put(prodId, productIdTOTotalRampQuantityMap.get(prodId)+assetQt);
                }
            }

            System.debug('productIdTOEndDateMap is: '+productIdTOEndDateMap);
            // actual derivations in this loop.
            Boolean approvalRequired = false;
            for(Apttus_Config2__LineItem__c liSO : liSOs){
                Id configId = liSO.Apttus_Config2__ConfigurationId__c;
                Apttus_Config2__LineItem__c liSOOld = liIdToliSOOldMap.get(liSO.Id);
                if(configId != null
                   && configIdtoConfigSOMap.containsKey(configId))
                {

                    // Derivation 1: [Apttus_Config2__BillToAccountId__c, Apttus_Config2__ShipToAccountId__c]
                    Apttus_Config2__ProductConfiguration__c configSO = configIdtoConfigSOMap.get(configId);
                    liSO.Apttus_Config2__BillToAccountId__c = configSO.Apttus_Config2__BillToAccountId__c;
                    liSO.Apttus_Config2__ShipToAccountId__c = configSO.Apttus_Config2__ShipToAccountId__c;

                    // Derivation 13: Resetting ZIA_Premium_Support__c, ZIA_Premium_Support_ACV__c, ZPA_Premium_Support__c, ZPA_Premium_Support_ACV__c
                    if (Trigger.isBefore && Trigger.isInsert) {
                        liSO.ZIA_Premium_Support__c = liSO.ZIA_Premium_Support_ACV__c = liSO.ZPA_Premium_Support__c = liSO.ZPA_Premium_Support_ACV__c = 0.0;
                    //added for fulfilment & Architectural Workshop Margin
                           
                        //Added by minkesh for new requirement 3 start 
                        if((liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                            || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                            || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED)
                            && liSO.Fulfilment__c != null) {
                            
                            liSO.Fulfilment_Margin__c = liSO.Fulfilment__c;
                        }
                        else{
                            liSO.Fulfilment_Margin__c = 0;  
                        }
                        //end
                    //end fulfilment & Architectural Workshop Margin
                    }
                    
                    
                    //assigning buyback months in line item level to take it up to config for uplift logic
                    if(Trigger.isBefore && liSO.Apttus_Config2__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED && (liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_BUYBACK || liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK) && liSO.Buyback_Months__c != liSO.Buyback_Months_Formula__c){
                       liSO.Buyback_Months__c = liSO.Buyback_Months_Formula__c;
                    }

                    // System.debug('*** liSO.Apttus_Config2__IsAssetPricing__c: ' + liSO.Apttus_Config2__IsAssetPricing__c);
                    // System.debug('*** 2 - liSO.Apttus_Config2__AssetQuantity__c: ' + liSO.Apttus_Config2__AssetQuantity__c);
                    // if (liSO.Apttus_Config2__AssetQuantity__c != null) {
                    //     liSO.Asset_Quantity__c = liSO.Apttus_Config2__AssetQuantity__c;
                    // }

                    // Derivation 2: [Apttus_Config2__AssetLineItemId__c, Apttus_Config2__LineStatus__c] - applicable for upsell quotes.
                    // Derivation 3: [Apttus_Config2__Quantity__c]
                    Id accountId = configSO.Apttus_Config2__AccountId__c;
                    if(accIdIdtoALISOsMap.containsKey(accountId)){
                        Double assetLineQuantity = 0;// it should be the quantity from latest ramp asset(largest Apttus_Config2__ItemSequence__c).
                        Date assetEndDate = null;// it should be the end date of latest ramp asset(largetst Apttus_Config2__ItemSequence__c).
                        for(Apttus_Config2__AssetLineItem__c aliSO : accIdIdtoALISOsMap.get(accountId)){
                            /*if((configSO.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL
                                || configSO.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_RENEWAL)
                                && liSO.Apttus_Config2__AssetLineItemId__c == null
                                && liSO.Apttus_Config2__ProductId__c == aliSO.Apttus_Config2__ProductId__c
                                && productCodeSet.contains(aliSO.Apttus_Config2__ProductId__r.ProductCode)){
                                //liSO.Apttus_Config2__AssetLineItemId__c = aliSO.Id;
                                //liSO.Apttus_Config2__LineStatus__c = APTS_CONSTANTS.LI_STATUS_AMENDED;

                                // Fields used for pricing the line in cart.
                                //liSO.Apttus_Config2__PriceListId__c = aliSO.Apttus_Config2__PriceListId__c;
                                //liSO.Apttus_Config2__PriceListItemId__c = aliSO.Apttus_Config2__PriceListItemId__c;
                                //liSO.Apttus_Config2__ListPrice__c = aliSO.Apttus_Config2__ListPrice__c;
                                //liSO.Apttus_Config2__BasePrice__c = aliSO.Apttus_Config2__BasePrice__c;
                                //liSO.Apttus_Config2__PriceUom__c = aliSO.Apttus_Config2__PriceUom__c;
                                //liSO.Apttus_Config2__PriceType__c = aliSO.Apttus_Config2__PriceType__c;
                                //liSO.Apttus_Config2__PriceMethod__c = aliSO.Apttus_Config2__PriceMethod__c;

                                // start and end date suppose to be populated by OOB.
                                liSO.Apttus_Config2__StartDate__c = configSO.Apttus_Config2__ExpectedStartDate__c;
                                liSO.Apttus_Config2__EndDate__c = configSO.Apttus_Config2__ExpectedEndDate__c;
                                }*/

                            if(liSO.Apttus_Config2__AssetLineItemId__c == aliSO.Id
                               || liSO.Apttus_Config2__AssetLineItemId__c == aliSO.Apttus_Config2__BundleAssetId__c){
                                   assetLineQuantity = aliSO.Apttus_Config2__Quantity__c;
                                   assetEndDate = aliSO.Apttus_Config2__EndDate__c;
                               }
                        }

                        // For the Swap(Upgraded) and renew(renewed): quantity should be populated from last ramp asset if ramped else from the primary asset line.
                        if((liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                            || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED)
                           && liSO.Apttus_Config2__AssetLineItemId__c != null
                           && Trigger.isInsert
                           && assetLineQuantity != 0){
                            if (!liSO.APTS_Updated_Quantity__c) {
                              liSO.Apttus_Config2__Quantity__c = assetLineQuantity;
                            } else {
                              liSO.Apttus_Config2__Quantity__c = liSO.Apttus_Config2__Quantity__c - 1;
                            }
                               // liSO.Apttus_Config2__PricingStatus__c = APTS_CONSTANTS.LI_PRICINGSTATUS_PENDING;
                           }

                        // Derivation 9: [APTS_MRR__c, APTS_ACV__c]Calculate MRR and ACV for cancelled lines as pricing callback will not be invoked for cancelled lines.
                        // Update: HE, 12/09: use asset end date as line item end date for cancelled lines.
                        if(liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_CANCELLED){
                            Date liStartDate = liSO.Apttus_Config2__EndDate__c;
                            Date liEndDate = assetEndDate;//liSO.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__EndDate__c;

                            Double liSellingTerm = 0;
                            if(liEndDate != null && liStartDate != null)
                                liSellingTerm = (Integer)Math.roundToLong(((liStartDate.daysBetween(liEndDate))/30.25));

              // Derivation 12: To calculate start date, end date & Selling term on termination/swap.

                            if(liStartDate != assetEndDate){
                                APTS_PricingHelper.calculateACVnMRR(liSO, liSellingTerm);
                                liSO.Apttus_Config2__EndDate__c = liEndDate;
                                liSO.APTS_Selling_Term__c = liSellingTerm;
                                liSO.Apttus_Config2__StartDate__c = liStartDate.addDays(1);
                            }

                        }
                    }

                    // Derivation 4: [Apttus_Config2__IsAssetPricing__c]: set to true if line status is Amend, Cancelled, Renewed.
                    // Update: HE, 01/03/2016 - clear the asset pricing status when quantity of renewed or amended lines are changed.
                    if((liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_CANCELLED)
                       && liSOOld == null)
                    {
                        liSO.Apttus_Config2__IsAssetPricing__c = true;
                        // Renewed and Amended lines should not use Asset Pricing
                        // || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED
                        // || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                    }
                    if((liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED)
                        && liSOOld != null
                        && liSO.Apttus_Config2__Quantity__c != liSOOld.Apttus_Config2__Quantity__c){
                        liSO.Apttus_Config2__IsAssetPricing__c = false;
                    }
                    if ((liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED)
                        && liSOOld != null
                        && liSO.Apttus_Config2__IsAssetPricing__c != liSOOld.Apttus_Config2__IsAssetPricing__c
                        && !(liSO.Apttus_Config2__Quantity__c != liSOOld.Apttus_Config2__Quantity__c)) {
                        liSO.Apttus_Config2__Quantity__c = liSOOld.Apttus_Config2__Quantity__c;
                    }

                    //Derivation 5: APTS_Total_Ramp_Quantity__c: sum of all lines with same product, if ramped then last ramp quantity is accounted towards the quantity of line.
                    Id productId = liSO.Apttus_Config2__ProductId__c;
                    if(productIdTOTotalRampQuantityMap.containsKey(productId)) {
                        liSO.APTS_Total_Ramp_Quantity__c = productIdTOTotalRampQuantityMap.get(productId);
                    }
                    if(productIdTOEndDateMap.containsKey(productId)) {
                        liSO.APTS_Ramp_End_Date__c = productIdTOEndDateMap.get(productId);
                    }
                    if(productIdTOTotalTermMap.containsKey(productId)) {
                        liSO.APTS_Total_Term__c = productIdTOTotalTermMap.get(productId);
                    }

                    //Derivation 6: APTS_Manual_Discount__c: Drop the manual discount if line status is Renewed on creation.
                    // Update: HE, 12/14/2016 - Drop the manual discount for DAS products. - ZSCAL-203
                    // Update: HE, 12/19/2016 - Drop the manual discount for all products where APTS_DisableManualAdjustments__c is set to true. - ZSCAL-203
                    // Commented to retain the manual discount for renewal quotes.
                    /* if((liSOOld == null
                        && liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED)
                       || liSO.APTS_DisableManualAdjustments__c == true) {
                           liSO.APTS_Manual_Discount__c = 0;
                    }
                    */
                    //Derivation 7:[Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c]For one time products remove the Dates.
                    if (liSOOld == null
                        && liSO.Apttus_Config2__SellingFrequency__c == APTS_CONSTANTS.LI_FREQUENCY_ONETIME) {
                            liSO.Apttus_Config2__StartDate__c = null;
                            liSO.Apttus_Config2__EndDate__c = null;
                    }

                    // Derivation 8: [APTS_Selling_Term__c]: Apttus_Config2__SellingTerm__c(yearly)*12.
                    /*if(liSO.Apttus_Config2__SellingTerm__c != null)
                    {
                        liSO.APTS_Selling_Term__c = (liSO.Apttus_Config2__SellingTerm__c * 12).round(System.RoundingMode.FLOOR);
                    }*/

                    //// Derivation 15: To update Buy Back Months from product attribute value to line item
                    // if (liSO.Buyback_Months_Formula__c != null) {
                    //     liSO.Buyback_Months__c = liSO.Buyback_Months_Formula__c;
                    // }

                    // Derivation 10: [APTS_User_Manager__c, APTS_User_Geo__c]: populate from proposal owner.
                    if(liSOOld == null
                       && userIdToUserSOMap.containsKey(configSO.Apttus_QPConfig__Proposald__r.OwnerId)){
                           User proposalOwner = userIdToUserSOMap.get(configSO.Apttus_QPConfig__Proposald__r.OwnerId);
                           liSO.APTS_User_Manager__c = proposalOwner.ManagerId;
                           liSO.APTS_User_Geo__c = proposalOwner.Geo__c;
                       }

                    // Derivation 11: [Apttus_CQApprov__Approval_Status__c]:
                    /*  •   The SKU does not have Suppress Discount Approval flag set. If it is set, no approval is required.
                        •   Manual Discount (Approvals) > 0 & Bill To Account does not contain Zscaler & Product Code not In (ZCES-PRO-SVC,ZCES-DAS-PKG1, ZCES-DAS-PKG2, ZCES-DAS-PKG3, ZCES-DAS-PKG4, ZCES-SUP-PREM-SP, ZCES-SUP-PREM) & Record Type = New Business or Upsell - On Create, Update(Manual Discount(Approvals), Bill to Account)
                        •   Manual Discount (Approvals) > 25 & Bill to Account contains Zscaler & Product Code not In (ZCES-PRO-SVC,ZCES-DAS-PKG1, ZCES-DAS-PKG2, ZCES-DAS-PKG3, ZCES-DAS-PKG4, ZCES-SUP-PREM-SP, ZCES-SUP-PREM) & Record Type = New Business or Upsell - On Create, Update (Manual Discount(Approvals), Bill to Account)
                        •   [Total Discount >= 20 & Product Code in (ZCES-PRO-SVC,ZCES-DAS-PKG1, ZCES-DAS-PKG2, ZCES-DAS-PKG3, ZCES-DAS-PKG4, ZCES-SUP-PREM-SP)] or Product Code = ZCES-SUP-PREM -  On Create, Update (Manual Discount(Approvals))
                        •   Product Code in (ZCR-BuyBack, ZCES-SUP-OTAM, ZSC-LOG-EXTSUBS, ZSC-NFR-WEB, ZCES-PRO-SVC ) & Is Primary Line = True - on Create
                        •   Product Code in (ZCR-UPY4, ZCR-UPY5) & Manual Discount (Approvals) = 100 - On Create, Update
                        •   DAS Seats Mismatch > 0 & Is Primary Line = True - on Create, Update
                        •   Ramped Months > 6 & Is Primary Line = True - on Create, Update
                        •   No Co-Term = True & Line Status != Cancelled & Is Primary Line = True - on Create, Update
                    */
                    approvalRequired = false;
                    if(liSO.Supress_Discount_Approval__c != true
                        && (liSOOld == null
                            || liSO.APTS_Total_Discount_Percentage__c != liSOOld.APTS_Total_Discount_Percentage__c
                            || liSO.Apttus_Config2__BillToAccountId__c != liSOOld.Apttus_Config2__BillToAccountId__c)){
                        if((liSO.APTS_Total_Discount_Percentage__c > 40
                                && liSO.APTS_Manual_Discount__c > 0
                                && (liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_CS8D
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS1
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS2
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS3
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS4
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS_ESSENTIAL
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS_ADVANCED
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE_PLUS
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_HEALTH_CHECK
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT
                                    && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_MPSUPPORT))
                            ||(liSO.APTS_Manual_Discount_Approvals__c == 100
                                && (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4
                                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5))) {
                           // liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if((approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        )){
                      if(liSO.APTS_Partner_Disc__c > 0
                                && (liSO.Apttus_Config2__AdjustmentType__c == '% Discount'
                                    || liSO.Apttus_Config2__AdjustmentType__c == 'Discount Amount'
                                    || liSO.Apttus_Config2__AdjustmentType__c == 'Price Override')
                                && liSO.APTS_Manual_Discount__c > 0
                                && (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT
                                  || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                                  || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                                  || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_AAC
                                  || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_CUSTCERT)){

                         //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                      }

                    }


                    if(approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        && (liSOOld == null
                            || liSO.APTS_Total_Discount_Percentage__c != liSOOld.APTS_Total_Discount_Percentage__c)){
                        if((liSO.APTS_Total_Discount_Percentage__c > 20
                             && (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CS8D
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS1
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS2
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS3
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS4
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS_ADVANCED
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE_PLUS
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS_ESSENTIAL
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_HEALTH_CHECK
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_MPSUPPORT))){
                          //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if(approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        && liSOOld == null){
                        if(liSO.Apttus_Config2__IsPrimaryLine__c == true
                            && (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_BUYBACK
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_OTAM
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_LEXTSUBS
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_NFRWEB
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_NFRZPA
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CS8D)){
                          //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if(approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        && (liSOOld == null
                            || liSO.APTS_DAS_Seats_Mismatch__c != liSOOld.APTS_DAS_Seats_Mismatch__c)){
                        if(liSO.APTS_DAS_Seats_Mismatch__c > 0
                            && liSO.Apttus_Config2__IsPrimaryLine__c == true){
                           // liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if(approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        && (liSOOld == null
                            || liSO.APTS_Ramped_Months__c != liSOOld.APTS_Ramped_Months__c)){
                        if(liSO.APTS_Ramped_Months__c > 6
                            && liSO.Apttus_Config2__IsPrimaryLine__c == true){
                          //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if(approvalRequired == false
                        && liSO.Supress_Discount_Approval__c != true
                        &&(liSOOld == null
                            || liSO.APTS_No_Co_Term__c != liSOOld.APTS_No_Co_Term__c)){
                        if(liSO.APTS_No_Co_Term__c == true
                            && liSO.Apttus_Config2__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                            && liSO.Apttus_Config2__IsPrimaryLine__c == true){
                          //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }
                    //System.debug('>>>> approvalRequired:' + approvalRequired);
                    //System.debug('>>>> liSO.APTS_ProductCode__c:' + liSO.APTS_ProductCode__c);
                    if(approvalRequired == false
                        && liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_Z_CREDIT
                        &&(liSOOld == null
                            || (liSOOld.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_Z_CREDIT
                                && liSOOld.APTS_Manual_Discount__c != liSO.APTS_Manual_Discount__c))){
                        if(liSO.Apttus_Config2__IsPrimaryLine__c == true){
                          //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_REQUIRED;
                            approvalRequired = true;
                        }else{
                            //liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                        }
                    }

                    if (approvalRequired == false
                        && liSO.Requires_PM_Approval__c == true) {
                       // liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.P_APPROVALSTATUS_REQUIRED;
                        approvalRequired = true;
                    }

                    // System.debug('>>>> approvalRequired:' + approvalRequired);
                    // System.debug('>>>> liSO.APTS_ProductCode__c:' + liSO.APTS_ProductCode__c);
                    // System.debug('>>>> liSO.Apttus_CQApprov__Approval_Status__c: ' + liSO.Apttus_CQApprov__Approval_Status__c);

                    // reset the approval status.
                    if (liSO.Requires_PM_Approval__c
                        && liSO.Apttus_CQApprov__Approval_Status__c == APTS_CONSTANTS.LI_APPROVALSTATUS_APPROVED) {
                       // liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                    }

                    Boolean hasZPA = false;
                    if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_AAC
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_CUSTCERT){
                      hasZPA = true;
                      if(((liSO.Apttus_Config2__AdjustmentType__c == '% Discount'
                            || liSO.Apttus_Config2__AdjustmentType__c == 'Discount Amount'
                            || liSO.Apttus_Config2__AdjustmentType__c == 'Price Override' )
                            &&liSO.APTS_Manual_Discount__c == 0)
                        || (liSO.Apttus_Config2__AdjustmentType__c != '% Discount'
                            && liSO.Apttus_Config2__AdjustmentType__c != 'Discount Amount'
                            && liSO.Apttus_Config2__AdjustmentType__c != 'Price Override')){
                      //  liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                      }

                    }

                    if((((liSO.APTS_Total_Discount_Percentage__c <= 40
                            || liSO.APTS_Manual_Discount__c <= 0)
                            && (liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_CS8D
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS1
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS2
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS3
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_DAS4
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT
                                && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_MPSUPPORT
                                ))
                         || (liSO.APTS_Total_Discount_Percentage__c < 20
                              &&(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CS8D
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS1
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS2
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS3
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_DAS4
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_MPSUPPORT)))
                            && liSO.APTS_No_Co_Term__c != True
                            && liSO.APTS_DAS_Seats_Mismatch__c == 0
                            && liSO.APTS_Ramp_Over_6_Months__c != True
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_BUYBACK
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_OTAM
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_NFRWEB
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_NFRZPA
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_LEXTSUBS
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_CS8D
                            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_Z_CREDIT
                            && liSO.Apttus_Config2__IsPrimaryLine__c == True
                            && liSO.Apttus_CQApprov__Approval_Status__c != APTS_CONSTANTS.LI_APPROVALSTATUS_APPROVED
                            && !hasZPA
                            && liSO.Requires_PM_Approval__c != True){
                       // liSO.Apttus_CQApprov__Approval_Status__c = APTS_CONSTANTS.LI_APPROVALSTATUS_NONE;
                    }


                }
            }



            /*  for(Apttus_Proposal__Proposal__c prop : [select Id, Name, Apttus_Proposal__ExpectedEndDate__c  from Apttus_Proposal__Proposal__c
                                                                                    where Id in: configProposalMap.values()])
                {
                    proposalMap.put(prop.Id, prop);
                }

                List<Apttus_Config2__LineItem__c> lineItemListToUpdate = new List<Apttus_Config2__LineItem__c>();
                for(Id configId : configLineItemsMap.keySet())
                {
                    List<Apttus_Config2__LineItem__c> lineItemList = configLineItemsMap.get(configId);
                    Map<Id, Apttus_Config2__LineItem__c> lineItemValidationMap = new Map<Id, Apttus_Config2__LineItem__c>();
                    Map<Id, Apttus_Config2__LineItem__c> primaryLineItemValidationMap = new Map<Id, Apttus_Config2__LineItem__c>();


                    for(Apttus_Config2__LineItem__c lineItemSO : lineItemList){
                        if(lineItemValidationMap.containsKey(lineItemSO.Apttus_Config2__ProductId__c) && lineItemSO.Apttus_Config2__ItemSequence__c > lineItemValidationMap.get(lineItemSO.Apttus_Config2__ProductId__c).Apttus_Config2__ItemSequence__c){
                            lineItemValidationMap.put(lineItemSO.Apttus_Config2__ProductId__c, lineItemSO);
                        }else{
                            lineItemValidationMap.put(lineItemSO.Apttus_Config2__ProductId__c, lineItemSO);
                        }

                        if(lineItemSO.Apttus_Config2__IsPrimaryLine__c){
                            primaryLineItemValidationMap.put(lineItemSO.Apttus_Config2__ProductId__c, lineItemSO);
                        }
                    }

                    // Update: HE, 11/30/2016 - (ZSCAL-112) reset the APTS_No_Co_Term__c to false prior to re-calculation to fix the inconsitency of the flag
                    // No Co-Term flag is not getting reset based on Quote header dates after the configuration re-finalization.
                    for(Id productId : primaryLineItemValidationMap.keySet()){
                        Apttus_Config2__LineItem__c primaryLineItem = primaryLineItemValidationMap.get(productId);
                        Apttus_Config2__LineItem__c lineItemToCompare = lineItemValidationMap.get(productId);

                        Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(Id = primaryLineItem.Id, APTS_No_Co_Term__c = false);
                        if(primaryLineItem.Id == lineItemToCompare.Id
                            && proposalMap.get(configProposalMap.get(configId)).Apttus_Proposal__ExpectedEndDate__c != primaryLineItem.Apttus_Config2__EndDate__c){
                            //lineItemListToUpdate.add(new Apttus_Config2__LineItem__c(Id = primaryLineItem.Id, APTS_No_Co_Term__c = true));
                            lineItemSO.APTS_No_Co_Term__c = true;
                        }else if(primaryLineItem.Id != lineItemToCompare.Id){
                            Boolean noCoTerm = false;
                            Boolean rampOver6Months = false;
                            if(proposalMap.get(configProposalMap.get(configId)).Apttus_Proposal__ExpectedEndDate__c != lineItemToCompare.Apttus_Config2__EndDate__c){
                                noCoTerm = true;
                            }

                            if(primaryLineItem.Apttus_Config2__StartDate__c.monthsBetween(lineItemToCompare.Apttus_Config2__StartDate__c) > 6){
                                rampOver6Months = true;
                            }

                            if(noCoTerm || rampOver6Months){
                                //lineItemListToUpdate.add(new Apttus_Config2__LineItem__c(Id = primaryLineItem.Id, APTS_No_Co_Term__c = noCoTerm, APTS_Ramp_Over_6_Months__c = rampOver6Months));
                                lineItemSO.APTS_No_Co_Term__c = noCoTerm;
                                lineItemSO.APTS_Ramp_Over_6_Months__c = rampOver6Months;
                            }

                            lineItemSO.APTS_Ramped_Months__c = primaryLineItem.Apttus_Config2__StartDate__c.monthsBetween(lineItemToCompare.Apttus_Config2__StartDate__c);
                        }
                        lineItemListToUpdate.add(lineItemSO);
                    }
                }

                if(!lineItemListToUpdate.isEmpty())
                    update lineItemListToUpdate;
            */


            for(Id lItemId : liIdtolItemSOTobeUpdatedMap.keySet()){
                Apttus_Config2__LineItem__c liSO = liIdtolItemSOTobeUpdatedMap.get(lItemId);
                Id productId = liSO.Apttus_Config2__ProductId__c;
                // Derivation 5 APTS_Total_Ramp_Quantity__c: sum of all lines with same product, if ramped then last ramp quantity is accounted towards the quantity of line.
                if (productIdTOTotalRampQuantityMap.containsKey(productId)) {
                    liSO.APTS_Total_Ramp_Quantity__c = productIdTOTotalRampQuantityMap.get(productId);
                }
                if (productIdTOEndDateMap.containsKey(productId)) {
                    liSO.APTS_Ramp_End_Date__c = productIdTOEndDateMap.get(productId);
                }
                if (productIdTOTotalTermMap.containsKey(productId)) {
                    liSO.APTS_Total_Term__c = productIdTOTotalTermMap.get(productId);
                }
                if((liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_BUYBACK || liSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK) && liSO.Buyback_Months_Formula__c != liSO.Buyback_Months__c ){
                    liSO.Buyback_Months__c = liSO.Buyback_Months_Formula__c ;
                }
            }
            // be aware as it might cause recursion. - never update the same set of lines from trigger.new collection.
            if(!liIdtolItemSOTobeUpdatedMap.isEmpty()) {
                update liIdtolItemSOTobeUpdatedMap.values();
            }

            CopyDealGuidance (liSOs, liIdToliSOOldMap);
            //updateMarginRenewalandUpsell(liSOs); //added by Minkesh Patel due to Requirement 3 29/4/2020
            calculateStackMarginTotal (liSOs); //added by Minkesh Patel 01/04/2020

        }else {
            SummaryGroupCreditHandler (liSOs,productConfigList );

            // Apttus_Config2__LineItem__c lineItem = null;
            // for (Apttus_Config2__LineItem__c liSO : liSOs) {
            //     if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_100SEATS_PROMO
            //         && liSO.Apttus_Config2__StartDate__c != null) {
            //         liSO.Apttus_Config2__EndDate__c = liSO.Apttus_Config2__StartDate__c.addYears(1);
            //         lineItem = liSO;
            //     }
            // }

            // if (lineItem != null) {
            //     TriggerUtility.apttusLineItemTriggerExecuted();
            //     Database.update(lineItem);
            // }
        }
    }

    public static void CopyDealGuidance (List<Apttus_Config2__LineItem__c> lineitems, Map<Id, Apttus_Config2__LineItem__c> liIdToliSOOldMap){
       /*
        List<Id> configId = new List<Id>();
        List<Apttus_Config2__ProductConfiguration__c> configuration = new List<Apttus_Config2__ProductConfiguration__c>();
        //system.debug('============Hiu '+lineitems[0].Name);

        Map<Id,Apttus_DealMgr__DealGuidanceRule__c> dealGuidanceMap=new Map<Id,Apttus_DealMgr__DealGuidanceRule__c>([select name, id from Apttus_DealMgr__DealGuidanceRule__c where Apttus_DealMgr__BusinessObject__c ='Apttus_Config2__LineItem__c']);
        //system.debug('HHH 222 '+dealGuidanceMap);
        List<Apttus_DealMgr__DealGuidanceRuleEntry__c> dealGuidanceEntryMap = [select id,name,Apttus_DealMgr__Band1Value__c,Apttus_DealMgr__Band2Value__c,Apttus_DealMgr__Band3Value__c,Apttus_DealMgr__Band4Value__c,Apttus_DealMgr__Dimension2Value__c ,Apttus_DealMgr__GuidanceRuleId__c from Apttus_DealMgr__DealGuidanceRuleEntry__c where Apttus_DealMgr__GuidanceRuleId__c  In : dealGuidanceMap.keySet()];
        Map<String,Apttus_DealMgr__DealGuidanceRuleEntry__c> mapRuleEntry =  new Map<String,Apttus_DealMgr__DealGuidanceRuleEntry__c>();
        for(Apttus_DealMgr__DealGuidanceRuleEntry__c rEntry : dealGuidanceEntryMap){
            mapRuleEntry.put(rEntry.Apttus_DealMgr__Dimension2Value__c,rEntry);
        }
        //system.debug('HHH '+mapRuleEntry);

        if(lineitems!=null && lineitems.size() > 0){
            //system.debug('HHH 1');
            for(Apttus_Config2__LineItem__c lineItem : lineitems){
                //system.debug('HHH 2' +lineItem);


                if(lineItem.APTS_Account_Type__c=='Zscaler' && (lineItem.APTS_Total_Discount_Percentage__c <= 100 )){
                    //system.debug('HHH 3');
                    if(lineItem.Apttus_Config2__ExtendedPrice__c == null){
                        return;
                    }
                    if(lineItem.APTS_Total_Discount_Percentage__c ==null){
                        lineItem.APTS_Total_Discount_Percentage__c=0;
                    }
                    if(lineItem.Apttus_Config2__NetAdjustmentPercent__c ==null){
                        lineItem.Apttus_Config2__NetAdjustmentPercent__c=0;
                    }
                    //system.debug('============called trigger Zscaler');
                    Apttus_DealMgr__DealGuidanceRuleEntry__c ruleEntry=mapRuleEntry.get('Zscaler');

                    if(ruleEntry != null
                    && ruleEntry.Apttus_DealMgr__Dimension2Value__c=='Zscaler'){
                        //system.debug('HHH 4');
                        Decimal greenDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c)) / 100;

                        Decimal greenTo = lineItem.Apttus_Config2__ExtendedPrice__c - greenDiscount;
                        Decimal greenFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal yellowDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c)) / 100;
                        Decimal yellowTo = lineItem.Apttus_Config2__ExtendedPrice__c - yellowDiscount;
                        Decimal yellowFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal orangeDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c)) / 100;
                        Decimal orangeTo = lineItem.Apttus_Config2__ExtendedPrice__c - orangeDiscount;
                        Decimal orangeFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal redDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band4Value__c)) / 100;
                        Decimal redTo = lineItem.Apttus_Config2__ExtendedPrice__c - redDiscount;
                        Decimal redFrom = lineItem.Apttus_Config2__ExtendedPrice__c;



                        Boolean isGreen = false;
                        Boolean isYellow = false;
                        Boolean isOrange = false;
                        Boolean isRed = false;
                        //system.debug('>>>>>> '+lineItem.Apttus_Config2__NetAdjustmentPercent__c);
                        if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) >= 0) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 25)){
                            //   lineItem.Apttus_Config2__Guidance__c = 'Green';
                            isGreen = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 25) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 50)){
                            //  lineItem.Apttus_Config2__Guidance__c = 'Yellow';
                            isYellow = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 35) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 60)){
                            //  lineItem.Apttus_Config2__Guidance__c = 'Orange';
                            isOrange = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 45) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 100)){
                            //  lineItem.Apttus_Config2__Guidance__c = 'Red';
                            isRed = true;
                        }

                        List<APTS_DealGuidanceJSON.Cls_Entries> entries = new List<APTS_DealGuidanceJSON.Cls_Entries>();

                        APTS_DealGuidanceJSON.Cls_Entries entry1 = new APTS_DealGuidanceJSON.Cls_Entries(1,'Green','Preferred',greenTo,greenFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c),Decimal.valueOf(0),'LowHigh','#387C35', isGreen);
                        APTS_DealGuidanceJSON.Cls_Entries entry2 = new APTS_DealGuidanceJSON.Cls_Entries(2,'Yellow','Unlikely',yellowTo,yellowFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c),'LowHigh','#FFE512', isYellow);
                        APTS_DealGuidanceJSON.Cls_Entries entry3 = new APTS_DealGuidanceJSON.Cls_Entries(3,'Orange','Risky',orangeTo,orangeFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c),'LowHigh','#E36F1E', isOrange);
                        APTS_DealGuidanceJSON.Cls_Entries entry4 = new APTS_DealGuidanceJSON.Cls_Entries(4,'Red','Rare',redTo,redFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band4Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c),'LowHigh','#B2102C', isRed);
                        entries.add(entry1);
                        entries.add(entry2);
                        entries.add(entry3);
                        entries.add(entry4);
                        APTS_DealGuidanceJSON dealGuidance = new APTS_DealGuidanceJSON(entries);

                        //system.debug('###dealGuidance:' + System.JSON.serialize(dealGuidance));

                        lineItem.Apttus_Config2__PricingGuidance__c = System.JSON.serialize(dealGuidance);
                    }
                } else if(lineItem.APTS_Account_Type__c=='Partner' && lineItem.APTS_Total_Discount_Percentage__c <= 100 ){
                    if(lineItem.Apttus_Config2__ExtendedPrice__c == null){
                        return;
                    }
                    if(lineItem.APTS_Total_Discount_Percentage__c ==null){
                        lineItem.APTS_Total_Discount_Percentage__c=0;
                    }
                    if(lineItem.Apttus_Config2__NetAdjustmentPercent__c ==null){
                        lineItem.Apttus_Config2__NetAdjustmentPercent__c=0;
                    }
                    //system.debug('============called trigger Partner');
                    Apttus_DealMgr__DealGuidanceRuleEntry__c ruleEntry=mapRuleEntry.get('Partner');

                    if(ruleEntry != null
                    && ruleEntry.Apttus_DealMgr__Dimension2Value__c=='Partner'){
                        Decimal greenDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c)) / 100;

                        Decimal greenTo = lineItem.Apttus_Config2__ExtendedPrice__c - greenDiscount;
                        Decimal greenFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal yellowDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c)) / 100;
                        Decimal yellowTo = lineItem.Apttus_Config2__ExtendedPrice__c - yellowDiscount;
                        Decimal yellowFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal orangeDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c)) / 100;
                        Decimal orangeTo = lineItem.Apttus_Config2__ExtendedPrice__c - orangeDiscount;
                        Decimal orangeFrom = lineItem.Apttus_Config2__ExtendedPrice__c;

                        Decimal redDiscount  = (lineItem.Apttus_Config2__ExtendedPrice__c * Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band4Value__c)) / 100;
                        Decimal redTo = lineItem.Apttus_Config2__ExtendedPrice__c - redDiscount;
                        Decimal redFrom = lineItem.Apttus_Config2__ExtendedPrice__c;


                        Boolean isGreen = false;
                        Boolean isYellow = false;
                        Boolean isOrange = false;
                        Boolean isRed = false;

                        if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) >= 0) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 0)){
                            // lineItem.Apttus_Config2__Guidance__c = 'Green';
                            isGreen = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 0) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 5)){
                            //  lineItem.Apttus_Config2__Guidance__c = 'Yellow';
                            isYellow = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 5) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 10)){
                            //   lineItem.Apttus_Config2__Guidance__c = 'Orange';
                            isOrange = true;
                        }else if((lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) > 10) && (lineItem.Apttus_Config2__NetAdjustmentPercent__c*(-1) <= 100)){
                            //   lineItem.Apttus_Config2__Guidance__c = 'Red';
                            isRed = true;
                        }

                        List<APTS_DealGuidanceJSON.Cls_Entries> entries = new List<APTS_DealGuidanceJSON.Cls_Entries>();

                        APTS_DealGuidanceJSON.Cls_Entries entry1 = new APTS_DealGuidanceJSON.Cls_Entries(1,'Green','Preferred',greenTo,greenFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c),Decimal.valueOf(0),'LowHigh','#387C35', isGreen);
                        APTS_DealGuidanceJSON.Cls_Entries entry2 = new APTS_DealGuidanceJSON.Cls_Entries(2,'Yellow','Unlikely',yellowTo,yellowFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band1Value__c),'LowHigh','#FFE512', isYellow);
                        APTS_DealGuidanceJSON.Cls_Entries entry3 = new APTS_DealGuidanceJSON.Cls_Entries(3,'Orange','Risky',orangeTo,orangeFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band2Value__c),'LowHigh','#E36F1E', isOrange);
                        APTS_DealGuidanceJSON.Cls_Entries entry4 = new APTS_DealGuidanceJSON.Cls_Entries(4,'Red','Rare',redTo,redFrom,Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band4Value__c),Decimal.valueOf(ruleEntry.Apttus_DealMgr__Band3Value__c),'LowHigh','#B2102C', isRed);
                        entries.add(entry1);
                        entries.add(entry2);
                        entries.add(entry3);
                        entries.add(entry4);
                        APTS_DealGuidanceJSON dealGuidance = new APTS_DealGuidanceJSON(entries);

                        //system.debug('###dealGuidance:' + System.JSON.serialize(dealGuidance));

                        lineItem.Apttus_Config2__PricingGuidance__c = System.JSON.serialize(dealGuidance);
                    }

                    configId.add(lineItem.Apttus_Config2__ConfigurationId__c);
                }
            }
        }*/
       if(liIdToliSOOldMap.size() == 0) {
           CopyQuantityOnRenewal(lineitems,liIdToliSOOldMap);
       } else {
           for(Apttus_Config2__LineItem__c li :lineitems) {
              if(li.Apttus_Config2__LineStatus__c == 'Upgraded' && !li.APTS_Updated_Quantity__c) {
                   li.Apttus_Config2__Quantity__c = li.Apttus_Config2__Quantity__c - 1;
                   li.APTS_Updated_Quantity__c = true;
              }
           }
       }
    }


    public static void CopyQuantityOnRenewal (List<Apttus_Config2__LineItem__c> lineitemlist, Map<Id, Apttus_Config2__LineItem__c> liIdToliSOOldMap)
    {

        Map<id,Apttus_Config2__LineItem__c> litemToUpdateMap = new Map<id,Apttus_Config2__LineItem__c> ();
        for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            if(litem.Apttus_Config2__DerivedFromId__c != null && litem.Apttus_Config2__LineStatus__c == 'Renewed') {
                litemToUpdateMap.put(litem.Apttus_Config2__DerivedFromId__c,litem);
            }
        }

        if(litemToUpdateMap.size() > 0) {
            List<Apttus_Config2__LineItem__c> lineitemDerivedFromlist  = new List<Apttus_Config2__LineItem__c>();
            lineitemDerivedFromlist = [select id,Apttus_Config2__Quantity__c,APTS_Manual_Discount__c from Apttus_Config2__LineItem__c where id IN:litemToUpdateMap.keyset()];
            for(Apttus_Config2__LineItem__c litem : lineitemDerivedFromlist) {
                litemToUpdateMap.get(litem.id).Apttus_Config2__Quantity__c = litem.Apttus_Config2__Quantity__c;
                litemToUpdateMap.get(litem.id).APTS_Manual_Discount__c= litem.APTS_Manual_Discount__c;
            }
        }
    }

    public static void SummaryGroupCreditHandler (List<Apttus_Config2__LineItem__c> Newlineitemlist,List<Apttus_Config2__ProductConfiguration__c> productConfigList ) {
        Set<Id> configurationIds = new Set<Id>();
        Boolean hasCancelledLineItem = false;

        for(Apttus_Config2__LineItem__c lineItem : Newlineitemlist){
            configurationIds.add(lineItem.Apttus_Config2__ConfigurationId__c);
        }



        for(Apttus_Config2__ProductConfiguration__c productConfig : productConfigList){
            List<Apttus_Config2__SummaryGroup__c> summaryGroupList = productConfig.Apttus_Config2__SummaryGroups__r;
            List<Apttus_Config2__SummaryGroup__c> summaryGroupToUpsert = new List<Apttus_Config2__SummaryGroup__c>();
            Map<String, Apttus_Config2__SummaryGroup__c> summaryGroupMap = new Map<String, Apttus_Config2__SummaryGroup__c>();



            if(!summaryGroupList.isEmpty()){
                for(Apttus_Config2__SummaryGroup__c summaryGroup : summaryGroupList){
                    summaryGroupMap.put(summaryGroup.Name, summaryGroup);
                }
            }

            Integer lineNumber = 1;

            if(productConfig.APTS_Total_Credit_One_Time__c != 0.0 || productConfig.APTS_Total_Net_Price_One_Time__c != 0.0 || productconfig.APTS_Total_Credit_One_Time_for_buy_b__c != 0.0){
                if(summaryGroupMap.containsKey('Total (One Time)')){
                    Apttus_Config2__SummaryGroup__c summaryGroup = summaryGroupMap.get('Total (One Time)');
                    summaryGroup.Apttus_Config2__LineNumber__c = lineNumber;
                    summaryGroup.APTS_Credit__c = productConfig.APTS_Total_Credit_One_Time__c + productconfig.APTS_Total_Credit_One_Time_for_buy_b__c;
                    if(summaryGroup.Apttus_Config2__BaseExtendedPrice__c == null) {
                        summaryGroup.Apttus_Config2__BaseExtendedPrice__c = 0;
                    }
                    summaryGroup.Apttus_Config2__BaseExtendedPrice__c =productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Net_Price_One_Time__c + (-1 * productconfig.APTS_Total_Credit_One_Time_for_buy_b__c) ;
                    summaryGroup.Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Net_Price_One_Time__c + (-1 * productconfig.APTS_Total_Credit_One_Time_for_buy_b__c) ;
                    summaryGroupToUpsert.add(summaryGroup);
                }else{
                    summaryGroupToUpsert.add(new Apttus_Config2__SummaryGroup__c(Name = 'Total (One Time)', Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = lineNumber, Apttus_Config2__LineType__c = 'Total', Apttus_Config2__GroupType__c = 'Category', Apttus_Config2__ConfigurationId__c = productConfig.Id, Apttus_Config2__Frequency__c = 'One Time', APTS_Credit__c = productConfig.APTS_Total_Credit_One_Time__c + productconfig.APTS_Total_Credit_One_Time_for_buy_b__c, Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Net_Price_One_Time__c, Apttus_Config2__BaseExtendedPrice__c = productConfig.APTS_Total_Net_Price_One_Time__c, Apttus_Config2__NetAdjustmentPercent__c = 0));
                }
                lineNumber++;
            }

            if(productConfig.APTS_Total_Credit_Yearly__c != 0.0 || productConfig.APTS_Total_Net_Price_Yearly__c != 0.0){
                if(summaryGroupMap.containsKey('Total (Yearly)')){
                    Apttus_Config2__SummaryGroup__c summaryGroup = summaryGroupMap.get('Total (Yearly)');
                    summaryGroup.Apttus_Config2__LineNumber__c = lineNumber;
                    summaryGroup.APTS_Credit__c = productConfig.APTS_Total_Credit_Yearly__c;
                    summaryGroup.Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Credit_Yearly__c + productConfig.APTS_Total_Net_Price_Yearly__c;
                    summaryGroupToUpsert.add(summaryGroup);
                }else{
                    summaryGroupToUpsert.add(new Apttus_Config2__SummaryGroup__c(Name = 'Total (Yearly)', Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = lineNumber, Apttus_Config2__LineType__c = 'Total', Apttus_Config2__GroupType__c = 'Category', Apttus_Config2__ConfigurationId__c = productConfig.Id, Apttus_Config2__Frequency__c = 'Yearly', APTS_Credit__c = productConfig.APTS_Total_Credit_Yearly__c, Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Credit_Yearly__c + productConfig.APTS_Total_Net_Price_Yearly__c, Apttus_Config2__BaseExtendedPrice__c = productConfig.APTS_Total_Net_Price_Yearly__c, Apttus_Config2__NetAdjustmentPercent__c = 0));
                }
                lineNumber++;
            }



            if(summaryGroupMap.containsKey('Grand Total')){
                Apttus_Config2__SummaryGroup__c summaryGroup = summaryGroupMap.get('Grand Total');
                summaryGroup.Apttus_Config2__LineNumber__c = lineNumber;
                summaryGroup.APTS_Credit__c = productConfig.APTS_Total_Credit_One_Time__c + productconfig.APTS_Total_Credit_One_Time_for_buy_b__c +  productConfig.APTS_Total_Credit_Yearly__c;
                summaryGroup.Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Net_Price_One_Time__c + productConfig.APTS_Total_Net_Price_Yearly__c + productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Credit_Yearly__c;
                summaryGroupToUpsert.add(summaryGroup);
            }else{
                summaryGroupToUpsert.add(new Apttus_Config2__SummaryGroup__c(Name = 'Grand Total', Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = lineNumber, Apttus_Config2__LineType__c = 'Grand Total', Apttus_Config2__GroupType__c = 'Category', Apttus_Config2__ConfigurationId__c = productConfig.Id, Apttus_Config2__Frequency__c = null, APTS_Credit__c = productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Credit_Yearly__c + productconfig.APTS_Total_Credit_One_Time_for_buy_b__c, Apttus_Config2__NetPrice__c = productConfig.APTS_Total_Net_Price_One_Time__c + productConfig.APTS_Total_Net_Price_Yearly__c + productConfig.APTS_Total_Credit_One_Time__c + productConfig.APTS_Total_Credit_Yearly__c, Apttus_Config2__BaseExtendedPrice__c = productConfig.APTS_Total_Net_Price_One_Time__c + productConfig.APTS_Total_Net_Price_Yearly__c, Apttus_Config2__NetAdjustmentPercent__c = 0));
            }

            if(!summaryGroupToUpsert.isEmpty()){
                upsert summaryGroupToUpsert;
            }
        }
    }
    public static void calculateStackMarginTotal (List<Apttus_Config2__LineItem__c> Newlineitemlist) {
        if(!Newlineitemlist.isEmpty()){
            for(Apttus_Config2__LineItem__c lineItem : Newlineitemlist){
                if(lineItem.Id != Null){
                    Decimal povM = lineItem.POV__c != null ? lineItem.POV__c : 0;
                    Decimal fulfM = lineItem.Fulfilment_Margin__c != null ? lineItem.Fulfilment_Margin__c : 0;
                    Decimal dealM = lineItem.Partner_Summit_Deal_Reg__c != null ? lineItem.Partner_Summit_Deal_Reg__c : 0;
                    Decimal awM = lineItem.AW_Margin_Formula__c != null ? lineItem.AW_Margin_Formula__c : 0;
                    Decimal fourMargins =  povM + fulfM + dealM + awM;
                    String ProdConfigId = lineItem.Apttus_Config2__ConfigurationId__c;
                    /*Apttus_Config2__ProductConfiguration__c ProdConfigObj = [SELECT Id,
                                                                                    Apttus_QPConfig__Proposald__c,
                                                                                    Apttus_QPConfig__Proposald__r.Model_Type_Partner__c
                                                                            FROM Apttus_Config2__ProductConfiguration__c 
                                                                            WHERE Id =: ProdConfigId];
                        String PartnerProgOnProp = ProdConfigObj.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;                                                               
                        String PartnerProgOnOpp = lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c;
                    */
                    if(lineItem.Partner_Adjustment__c == Null){
                    lineItem.Partner_Adjustment__c = 0; 
                    }
                    if(lineItem.Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT){
                        if((lineItem.Partner_Adjustment_Type__c != '' 
                            || lineItem.Partner_Adjustment_Type__c != Null)){
            
                            if(lineItem.Partner_Adjustment_Type__c == APTS_CONSTANTS.LI_ADJUSTMENT_PRICEOVERRIDE && lineItem.Partner_Adjustment__c > 0){
                                lineItem.Total_Stackable_Margin__c = ((lineItem.Apttus_Config2__NetPrice__c - lineItem.Partner_Adjustment__c) / lineItem.Apttus_Config2__NetPrice__c * 100);
                                
                            }else{
                                lineItem.Total_Stackable_Margin__c = fourMargins;
                                
                            }
            
                            if(lineItem.Partner_Adjustment_Type__c == APTS_CONSTANTS.LI_ADJUSTMENT_DISCOUNT){
                                lineItem.Total_Stackable_Margin__c = lineItem.Partner_Adjustment__c + fourMargins;
                            }
                        }else{
                            lineItem.Total_Stackable_Margin__c = fourMargins;
                        }
                    }else{
                        lineItem.Total_Stackable_Margin__c = fourMargins;
                    }
                }
            }
        }
    }
    public static void updateMarginRenewalandUpsell(List<Apttus_Config2__LineItem__c> lineitemlist){
    /*    System.debug('In===============Method====================updateMarginRenewalandUpsell ===');
        List<Apttus_Config2__LineItem__c> updateLineItemlist = new List<Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c lineItem : lineitemlist){

            Apttus_Config2__ProductConfiguration__c ProdConfigObj = [SELECT Id,
                                                                            Apttus_QPConfig__Proposald__c,
                                                                            Apttus_QPConfig__Proposald__r.Model_Type_Partner__c
                                                                     FROM Apttus_Config2__ProductConfiguration__c 
                                                                     WHERE Id =: lineItem.Apttus_Config2__ConfigurationId__c];
            String PartnerProgOnProp = ProdConfigObj.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
            String RecordTypeOnProp = ProdConfigObj.Apttus_QPConfig__Proposald__r.RecordTypeId;
            if(PartnerProgOnProp == 'Partner Summit' && RecordTypeOnProp != 'New Business'){
                if(lineItem.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED){
                    lineItem.POV__c = 0;
                    lineItem.Partner_Summit_Deal_Reg__c = 0;
                    lineItem.AW_Margin_Formula__c = 0;
                }else if(lineItem.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_CANCELLED){
                    lineItem.POV__c = 0;
                    lineItem.Fulfilment__c = 0;
                    lineItem.Partner_Summit_Deal_Reg__c = 0;
                    lineItem.AW_Margin_Formula__c = 0;
                }
            }
            updateLineItemlist.add(lineItem);
            
                // LI_STATUS_NEW                =   'New';
                // LI_STATUS_AMENDED            =   'Amended';
                // LI_STATUS_UPGRADED           =   'Upgraded';
                // LI_STATUS_RENEWED            =   'Renewed';
                // LI_STATUS_CANCELLED          =   'Cancelled';
            
        }
        if(!updateLineItemlist.isEmpty()){
            update updateLineItemlist;
        }
    */    
    }
}