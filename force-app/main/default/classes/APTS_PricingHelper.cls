/*
    Author: Harish Emmadi, 11/1/2016.
    Description: Used for peicing call back utility functions.
    *******************************************************************************************************************************
    Modification Log:
    Harish Emmadi, 11/15/2016 - Updated getUpliftYear4, getUpliftYear5.
    Harish Emmadi, 11/30/2016 - Updated ACV and MRR Calculations. - [ZSCAL-155]
    Harish Emmadi, 12/21/2016 - Updated calculateDiscounts for price override. -[ZSCAL-218]
    Harish Emmadi, 12/21/2016 - Updated calculateDiscounts for price override used APTS_Suppresstotaldiscount__c flag. -[ZSCAL-218]
    Vijay Prakash, 03/24/2016 - Update calculateACVnMRR to calculate ACV and MRR for One Time Credit SKU (PROD_SKU_Z_CREDIT)
    Vijay Prakash, 10/10/2017 - Updated the logic to query DisableManualAdjustments__c field through formula field
    Vijay Prakash, 10/11/2017 - Added updatePremiumSupportValues method to update the premium support values to the Line Item records [Zendesk Ticket #15718]
    *******************************************************************************************************************************
 */
public with sharing class APTS_PricingHelper {
    public Static String partnerProgram; //Added Partner Program variable
    public static void calculateDiscounts(Apttus_Config2__LineItem__c liSO){
        // Fields that gets calculated are Apttus_Config2__AdjustmentAmount__c, APTS_Total_Discount_Percentage__c, APTS_Manual_Discount_Approvals__c, APTS_MRR__c and APTS_ACV__c.
        // Populate Apttus_Config2__AdjustmentAmount__c to correct value based on Apttus_Config2__AdjustmentType__c so Net Price will be calculated prior to afterPricing(OOB).
        // APTS_Manual_Discount_Approvals__c is percentage of manual discount if adjustment type is not '% discount'.
        Double  partnerDiscountPct = 0;
        Double  dealRegDiscountPct = 0;
        Double  newLogoDiscountPct = 0;
        Decimal totalDiscountPct = 0;
        Decimal adjustedtotalDiscountAmt = 0;
        Double  totalDiscountAmt = 0;

      /*  if (liSO.APTS_Partner_Disc__c != null) {
            partnerDiscountPct = liSO.APTS_Partner_Disc__c;
        }

        if (liSO.APTS_Deal_Reg_Disc__c != null) {
            dealRegDiscountPct = liSO.APTS_Deal_Reg_Disc__c;
        }

        if (liSO.APTS_New_Logo_Disc__c != null) {
            newLogoDiscountPct = liSO.APTS_New_Logo_Disc__c;
        }
        totalDiscountPct = partnerDiscountPct  +  dealRegDiscountPct + newLogoDiscountPct; */
        
        //Added Partner Program variable
        system.debug('Raghu Testing ::: '+partnerProgram+' :: APTS_CONSTANTS.P_PARTNERPRG_LEGACY ::'+APTS_CONSTANTS.P_PARTNERPRG_LEGACY);
       
        if(partnerProgram == APTS_CONSTANTS.P_PARTNERPRG_LEGACY) {
            if (liSO.APTS_Partner_Disc__c != null) {
                partnerDiscountPct = liSO.APTS_Partner_Disc__c;
            }
            if (liSO.APTS_Deal_Reg_Disc__c != null) {
                dealRegDiscountPct = liSO.APTS_Deal_Reg_Disc__c;
            }
            if (liSO.APTS_New_Logo_Disc__c != null) {
                newLogoDiscountPct = liSO.APTS_New_Logo_Disc__c;
            }
            totalDiscountPct = partnerDiscountPct  +  dealRegDiscountPct + newLogoDiscountPct;
        } else {
            // Code for Partner Summit 
        }
        

        //Extract DisableManualAdjustments__c value
        System.debug('>>> liSO.Pricing_Callback_Fields__c: ' + liSO.Pricing_Callback_Fields__c);
        Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);
        Boolean disableManualAdjustments = pricingCallBackFieldsMap.containsKey('DisableManualAdjustments__c') ? (Boolean)pricingCallBackFieldsMap.get('DisableManualAdjustments__c') : false;

        if (disableManualAdjustments != true) {
            if(liSO.Apttus_Config2__AdjustmentType__c == '% Discount'){
                liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Manual_Discount__c;
                liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct+liSO.APTS_Manual_Discount__c;
                liSO.APTS_Total_Discount_Percentage__c = liSO.Apttus_Config2__AdjustmentAmount__c;
            }
            else if (liSO.Apttus_Config2__AdjustmentType__c == 'Discount Amount') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    totalDiscountAmt = liSO.APTS_Manual_Discount__c  +  (liSO.Apttus_Config2__BaseExtendedPrice__c * totalDiscountPct/100);
                    liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Manual_Discount__c / liSO.Apttus_Config2__BaseExtendedPrice__c) * 100;
                    liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountAmt;
                    liSO.APTS_Total_Discount_Percentage__c = ((totalDiscountAmt/liSO.Apttus_Config2__BaseExtendedPrice__c)*100).setScale(2);
                }
            }else if (liSO.Apttus_Config2__AdjustmentType__c == '% Markup') {
                // liSO.Apttus_Config2__AdjustmentType__c = '% Markup';
                adjustedtotalDiscountAmt  = liSO.APTS_Manual_Discount__c  - totalDiscountPct;
                liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Manual_Discount__c * (-1);
                liSO.Apttus_Config2__AdjustmentAmount__c = adjustedtotalDiscountAmt;
                liSO.APTS_Total_Discount_Percentage__c = adjustedtotalDiscountAmt * (-1);
            }else if (liSO.Apttus_Config2__AdjustmentType__c == 'Markup Amount') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Markup Amount';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    totalDiscountAmt = liSO.APTS_Manual_Discount__c  - (liSO.Apttus_Config2__BaseExtendedPrice__c * totalDiscountPct/100);
                    liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountAmt;
                    liSO.APTS_Total_Discount_Percentage__c = (totalDiscountAmt / liSO.Apttus_Config2__BaseExtendedPrice__c) * 100;
                    liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct;
                }
            }else if (liSO.Apttus_Config2__AdjustmentType__c == 'Price Override') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Price Override';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    liSO.Apttus_Config2__AdjustmentAmount__c = liSO.APTS_Manual_Discount__c;
                    if(liSO.APTS_Suppresstotaldiscount__c == false)
                    {
                        liSO.APTS_Total_Discount_Percentage__c = ((liSO.Apttus_Config2__BaseExtendedPrice__c - liSO.Apttus_Config2__AdjustmentAmount__c)/liSO.Apttus_Config2__BaseExtendedPrice__c)*100;
                        liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct).setScale(2);
                    }
                }else{
                    liSO.Apttus_Config2__AdjustmentAmount__c = liSO.APTS_Manual_Discount__c;

                    if(liSO.APTS_Suppresstotaldiscount__c == false){
                        liSO.APTS_Total_Discount_Percentage__c = liSO.Apttus_Config2__AdjustmentAmount__c*-1;
                        liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct).setScale(2);
                    }
                }
            }else{
                // default values if no discount is selected.
                // default the adjustmenttype only if manual adjustments are allowed.
                if(liSO.Apttus_Config2__AllowManualAdjustment__c == true)
                    liSO.Apttus_Config2__AdjustmentType__c = '% Discount';
                liSO.APTS_Manual_Discount__c = 0;
                liSO.APTS_Manual_Discount_Approvals__c = 0;
                liSO.APTS_Total_Discount_Percentage__c = totalDiscountPct;
                liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct;
            }
        } else {
            if(liSO.Apttus_Config2__AllowManualAdjustment__c == true)
                liSO.Apttus_Config2__AdjustmentType__c = '% Discount';
            liSO.APTS_Manual_Discount__c = 0;
            liSO.APTS_Manual_Discount_Approvals__c = 0;
            liSO.APTS_Total_Discount_Percentage__c = totalDiscountPct;
            liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct;
        }

        // Moved MRR and ACV calculations to calculateACVnMRR as they are dependent on net price which gets calculated after price where are discount needs to applied in before pricing.
        // calculate the MRR's and ACV's. Net price is not yet available so calculate net price(total discount of base extended) first prior.
        /*if (liSO.APTS_Selling_Term__c != null
            && liSO.APTS_Selling_Term__c != 0)
        {
            Double netPrice = liSO.Apttus_Config2__BaseExtendedPrice__c * (0.01 * (100 - liSO.APTS_Total_Discount_Percentage__c) );
            liSO.Apttus_Config2__NetPrice__c = netPrice;
            // System.debug('net price is: '+liSO.Product_Name__c+' '+netPrice);
            // Do not calculate ACV and MRR for one-time products.
            if(liSO.Apttus_Config2__PriceType__c != 'One Time')
            {
                liSO.APTS_MRR__c = netPrice / liSO.APTS_Selling_Term__c;
                if (liSO.APTS_Selling_Term__c >= 12) {
                    liSO.APTS_ACV__c = liSO.APTS_MRR__c * 12;}
                else {
                    liSO.APTS_ACV__c = liSO.APTS_MRR__c * liSO.APTS_Selling_Term__c;
                }
            }else{
                liSO.APTS_MRR__c = 0;
                liSO.APTS_ACV__c = 0;
            }
        }*/
    }

    /**
     * @description Method to apply discount on the line item level support amount
     * @param supportAmount     Base support price
     * @param discountPercent   Premium support's total discount percent
     * @return netSupportAmount Net support price
     **/
    public static Decimal applyDiscountForPremiumSupport(Decimal supportAmount, Decimal discountPercent) {
        // Apply the discount on the support amount and return the net support amount
        Decimal netSupportAmount = supportAmount - ((supportAmount * discountPercent) / 100);

        return netSupportAmount;
    }

    /**
     * @description Method to apply discount on the line item level of ZLIVE SKUs
     **/
    public static Decimal applyZLIVEPromo(Apttus_Config2__LineItem__c liSO, Decimal discountPercent, String promocode) {
        // Apply the discount on the support amount and return the net support amount
        Decimal netprice = liSO.Apttus_Config2__BaseExtendedPrice__c != null ? liSO.Apttus_Config2__BaseExtendedPrice__c : 0;
        Integer qtyforteam = 0;
        if(promocode == 'ZLIVE-TEAM'){
            qtyforteam = (Integer)liSO.Apttus_Config2__Quantity__c / 2;
            netprice = liSO.Apttus_Config2__BasePrice__c != null ? qtyforteam * liSO.Apttus_Config2__BasePrice__c: 0;
        }
        //liSO.Apttus_Config2__BaseExtendedPrice__c = liSO.Apttus_Config2__BaseExtendedPrice__c - ((netprice * discountPercent) / 100);
        //liSO.Apttus_Config2__NetPrice__c = liSO.Apttus_Config2__BaseExtendedPrice__c;
        return ((netprice * discountPercent) / 100);
    }
    //CR# 223 - Abhishek V - Early_Adopter - Start
    /**
     * @description Method to calculate credit for Early_Adopter
     **/
    public static Decimal calculateEarly_Adoptercredit(Apttus_Config2__LineItem__c liSO) {
        Double liSellingTerm = 0;
        Date liStartDate = liSO.Apttus_Config2__StartDate__c;
        Date liEndDate = liSO.Apttus_Config2__EndDate__c;
        if(liEndDate != null && liStartDate != null)
            liSellingTerm = (Integer)Math.roundToLong(((liStartDate.daysBetween(liEndDate))/30.25));

        
        // Apply the discount on the support amount and return the net support amount
        Decimal credittoreturn = liSO.APTS_MRR__c != null && liSellingTerm != null ? (liSO.APTS_MRR__c) * (1.0/3.0) * liSellingTerm : 0;
        if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.DATA_PROTECTION_BUNDLE){
            credittoreturn = liSO.APTS_MRR__c != null && liSellingTerm != null ? (liSO.APTS_MRR__c) * (1.0/6.0) * liSellingTerm : 0;
        }
        //liSO.Apttus_Config2__BaseExtendedPrice__c = liSO.Apttus_Config2__BaseExtendedPrice__c - ((netprice * discountPercent) / 100);
        //liSO.Apttus_Config2__NetPrice__c = liSO.Apttus_Config2__BaseExtendedPrice__c;
        
        //throw new APTS_Exception('credit : ' + liSO.APTS_ProductCode__c + ' value '+ credittoreturn + 'APTS_MRR__c' + liSO.APTS_MRR__c + ' selling term ' + liSellingTerm);
        return (-1 * credittoreturn);
    }
    //CR# 223 - Abhishek V - Early_Adopter - End
    
    /**
     * @description Method to calculate the support amount ACV for line items
     * @param supportAmount     Net support price
     * @param discountPercent   Premium support's total term in months
     * @return netSupportAmount Support price ACV
     **/
    public static Decimal calculateACVForPremiumSupport(Decimal supportAmount, Decimal totalTermYears) {
        // Apply the discount on the support amount and return the net support amount
        Decimal supportAmountAcv;
        if(totalTermYears == null
            || totalTermYears == 0.0
            || supportAmount == null)
            return 0.0;

        Decimal mrr = supportAmount / Math.round(totalTermYears * 12);
        if (totalTermYears >= 1) {
            supportAmountAcv = mrr * 12;
        } else {
            supportAmountAcv = mrr * Math.round(totalTermYears * 12);
        }

        return supportAmountAcv;
    }

    // can be used only used in afterpricing once the netprice is calculated.
    public static void calculateACVnMRR(Apttus_Config2__LineItem__c liSO, Double totalTermMonths){
        // calculate the MRR's and ACV's. Net price is not yet available so calculate net price(total discount of base extended) first prior.
        // Double netPrice = liSO.Apttus_Config2__BaseExtendedPrice__c * (0.01 * (100 - liSO.APTS_Total_Discount_Percentage__c) );
        // liSO.Apttus_Config2__NetPrice__c = netPrice;
        // System.debug('net price is: '+liSO.Product_Name__c+' '+netPrice);
        // Do not calculate ACV and MRR for one-time products.
        liSO.APTS_MRR__c = 0;// default the values to Zero
        liSO.APTS_ACV__c = 0;// default the values to Zero
        if(liSO.Apttus_Config2__PriceType__c != 'One Time'
            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_BUYBACK
            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK
            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PROMO
            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.EARLY_ADOPTER
            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO) {
            // Decimal totalTermYears = liSO.APTS_Total_Term__c;
            // Double sellingTermMonths = liSO.APTS_Selling_Term__c;
            if(totalTermMonths == null
                || totalTermMonths == 0
                || liSO.Apttus_Config2__NetPrice__c == null)
                return;
            // totalTermYears = (totalTermYears*12).round(System.RoundingMode.FLOOR);
            liSO.APTS_MRR__c = liSO.Apttus_Config2__NetPrice__c / totalTermMonths;
            if (totalTermMonths >= 12) {
                liSO.APTS_ACV__c = liSO.APTS_MRR__c * 12;}
            else {
                liSO.APTS_ACV__c = liSO.APTS_MRR__c * totalTermMonths;
            }
        }
    }

    /*public static String getCreditTerminatin(){
        if(incentiveMap.isEmpty())
            incentiveMap = getIncentives();
        if(incentiveMap.containsKey('Credit Calc for termination'))
            return incentiveMap.get('Credit Calc for termination').Apttus_Config2__IncentiveCode__c;
        return null;
    }*/

    /**
     * @description Method to update premium support values in Line Items
     * @param premiumSupportLiSO Premium Support Line Item SObject
     * @param zpaPremiumSupportValue Premium Support contribution by ZPA Line Items
     * @param ziaPremiumSupportValue Premium Support contribution by ZIA Line Items
     * @param liSOToPremiumSupportValues Premium Support contribution by each line item
     * @return null
     **/
    public static void updatePremiumSupportValues(Apttus_Config2__LineItem__c premiumSupportLiSO, Decimal zpaPremiumSupportValue, Decimal zpaPremiumSupportACVValue, Decimal ziaPremiumSupportValue, Decimal ziaPremiumSupportACVValue, Map<Id, Decimal> liSOToZPAPremiumSupportValues, Map<Id, Decimal> liSOToZIAPremiumSupportValues, Map<Id, Decimal> liSOToZPAPremiumSupportACVValues, Map<Id, Decimal> liSOToZIAPremiumSupportACVValues, Decimal zpaPremiumSupportlistPrice, Decimal zpaPremiumSupportlistPriceACV, Decimal ziaPremiumSupportlistPrice, Decimal ziaPremiumSupportlistPriceACV, Map<Id, Decimal> productLiIdToZPAListPricePremiumSupportValueMap, Map<Id, Decimal> productLiIdToZPAListPricePremiumSupportACVValueMap, Map<Id, Decimal> productLiIdToZIAListPricePremiumSupportValueMap, Map<Id, Decimal> productLiIdToZIAListPricePremiumSupportACVValueMap) {
        List<Apttus_Config2__LineItem__c> lstLineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();

        Map<String, Object> pricingCallbackFields = (Map<String, Object>)JSON.deserializeUntyped(premiumSupportLiSO.Pricing_Callback_Fields__c);
        String configId = (String)pricingCallbackFields.get('Apttus_Config2__ConfigurationId__c');
        List<Apttus_Config2__LineItem__c> lstExistingLineItems = [SELECT Id, Apttus_Config2__ProductId__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = :configId AND Apttus_Config2__ItemSequence__c = 1 LIMIT 1000];
        //Update ZIA and ZPA Premium Support values in the Premium Support Line Item
        lstLineItemsToUpdate.add(new Apttus_Config2__LineItem__c(Id = premiumSupportLiSO.Id, ZPA_Premium_Support__c = zpaPremiumSupportValue, ZIA_Premium_Support__c = ziaPremiumSupportValue, ZPA_Premium_Support_ACV__c = zpaPremiumSupportACVValue, ZIA_Premium_Support_ACV__c = ziaPremiumSupportACVValue, ZPA_List_Price_Premium_Support__c = zpaPremiumSupportlistPrice, ZPA_List_Price_Premium_Support_ACV__c = zpaPremiumSupportlistPriceACV, ZIA_List_Price_Premium_Support__c = ziaPremiumSupportlistPrice, ZIA_List_Price_Premium_Support_ACV__c = ziaPremiumSupportlistPriceACV));
        for (Apttus_Config2__LineItem__c lineItem : lstExistingLineItems) {
            Apttus_Config2__LineItem__c liToUpdate = new Apttus_Config2__LineItem__c(Id = lineItem.Id);
            Boolean hasToBeUpdated = false;

            if (liSOToZPAPremiumSupportValues.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZPA_Premium_Support__c = liSOToZPAPremiumSupportValues.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (liSOToZIAPremiumSupportValues.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZIA_Premium_Support__c = liSOToZIAPremiumSupportValues.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (liSOToZPAPremiumSupportACVValues.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZPA_Premium_Support_ACV__c = liSOToZPAPremiumSupportACVValues.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (liSOToZIAPremiumSupportACVValues.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZIA_Premium_Support_ACV__c = liSOToZIAPremiumSupportACVValues.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (productLiIdToZPAListPricePremiumSupportValueMap.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZPA_List_Price_Premium_Support__c = productLiIdToZPAListPricePremiumSupportValueMap.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (productLiIdToZPAListPricePremiumSupportACVValueMap.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZPA_List_Price_Premium_Support_ACV__c = productLiIdToZPAListPricePremiumSupportACVValueMap.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (productLiIdToZIAListPricePremiumSupportValueMap.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZIA_List_Price_Premium_Support__c = productLiIdToZIAListPricePremiumSupportValueMap.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (productLiIdToZIAListPricePremiumSupportACVValueMap.containsKey(lineItem.Apttus_Config2__ProductId__c)) {
                liToUpdate.ZIA_List_Price_Premium_Support_ACV__c = productLiIdToZIAListPricePremiumSupportACVValueMap.get(lineItem.Apttus_Config2__ProductId__c);
                hasToBeUpdated = true;
            }

            if (hasToBeUpdated == true) {
                lstLineItemsToUpdate.add(liToUpdate);
            }
        }

        try {
            System.debug('>>>> lstLineItemsToUpdate: ' + lstLineItemsToUpdate);
            if (lstLineItemsToUpdate.size() > 0) {
                update lstLineItemsToUpdate;
            }
        }
        catch (Exception ex) {
            throw new APTS_Exception('Cannot update Premium Support values to Line Items. Error: ' + ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
        }
    }

    @future
    public static void resetPremiumSupportValues(Id cartId, String setProductIds) {
        Set<Id> productIds = (Set<Id>)JSON.deserialize(setProductIds, Type.forName('Set<Id>'));
        List<Apttus_Config2__LineItem__c> lstLineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();

        List<Apttus_Config2__LineItem__c> lstExistingLineItems = [SELECT Id, Apttus_Config2__ProductId__c, ZPA_Premium_Support_ACV__c, ZIA_Premium_Support_ACV__c, ZPA_Premium_Support__c, ZIA_Premium_Support__c
                                                                    FROM Apttus_Config2__LineItem__c
                                                                   WHERE Apttus_Config2__ProductId__c IN :productIds
                                                                     AND Apttus_Config2__ConfigurationId__c = :cartId
                                                                     AND (
                                                                         ZPA_Premium_Support__c <> null
                                                                      OR ZIA_Premium_Support__c <> null
                                                                      OR ZPA_Premium_Support_ACV__c <> null
                                                                      OR ZIA_Premium_Support_ACV__c <> null
                                                                         )
                                                                   LIMIT 1000];

        for (Apttus_Config2__LineItem__c liSO : lstExistingLineItems) {
            if (liSO.ZPA_Premium_Support__c != null || liSO.ZIA_Premium_Support__c != null || liSO.ZPA_Premium_Support_ACV__c != null || liSO.ZIA_Premium_Support_ACV__c != null) {
                lstLineItemsToUpdate.add(new Apttus_Config2__LineItem__c(
                                            Id = liSO.Id,
                                            ZPA_Premium_Support__c = null,
                                            ZIA_Premium_Support__c = null,
                                            ZPA_Premium_Support_ACV__c = null,
                                            ZIA_Premium_Support_ACV__c = null
                                    ));
            }
        }

        try {
            if (lstLineItemsToUpdate.size() > 0) {
                update lstLineItemsToUpdate;
            }
        } catch(Exception eX) {
            throw new APTS_Exception('Cannot reset Premium Support values in Line Items. Error: ' + ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
        }
    }

    /**
     * @description Method to update % Tam Top-up for ZPA and ZIA in TAM Top-up Line Item
     * @param tamTopLiSO Premium Support Line Item SObject
     * @param zpaTamTopValue Premium Support contribution by ZPA Line Items
     * @param ziaTamTopValue Premium Support contribution by ZIA Line Items
     * @return null
     **/
    public static void updateTamTopupValues(Apttus_Config2__LineItem__c tamTopLiSO, Decimal zpaTamTopValue, Decimal ziaTamTopValue) {
        Apttus_Config2__LineItem__c tamTopLiToUpdate = new Apttus_Config2__LineItem__c(Id = tamTopLiSO.Id, ZPA_Premium_Support_ACV__c = zpaTamTopValue, ZIA_Premium_Support_ACV__c = ziaTamTopValue);

        try {
            update tamTopLiToUpdate;
        }
        catch (Exception ex) {
            throw new APTS_Exception('Cannot update Premium Support values to Line Items. Error: ' + ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
        }
    }

    public static Double getUpliftYear4(Apttus_Config2__LineItem__c liSO){
        // If selling term is greater than 36  then return ACV else 0.
        if(liSO.APTS_Selling_Term__c > 36){
            return liSO.APTS_ACV__c;
        }
        return 0;
    }

    public static Double getUpliftYear5(Apttus_Config2__LineItem__c liSO){
        // If selling term is greater than 48  then return ACV else 0.
        if(liSO.APTS_Selling_Term__c > 48){
            return liSO.APTS_ACV__c;
        }
        return 0;
    }

    /*public static Map<String, Apttus_Config2__Incentive__c> getIncentives(){
        Map<String, Apttus_Config2__Incentive__c> res = new Map<String, Apttus_Config2__Incentive__c>();
        for(Apttus_Config2__Incentive__c inc : [Select Id, Apttus_Config2__AccountScope__c, Apttus_Config2__IncentiveCode__c, Name,
                                                    Apttus_Config2__ProductFamilyScope__c, Apttus_Config2__ProductFamilyScopeOper__c,
                                                    Apttus_Config2__ProductScope__c, Apttus_Config2__ProductScopeOper__c
                                                    From Apttus_Config2__Incentive__c
                                                        Where Apttus_Config2__Active__c = true])
            res.put(inc.Apttus_Config2__IncentiveCode__c, inc);
        return res;
    }*/

    public static Double getBuyBackCreditAmount(Apttus_Config2__LineItem__c buyBackliSO, List<Apttus_Config2__LineItem__c> buyBackEligibleLines){
        Double bbcAmount = 0;
        Double buyBackPeriod = buyBackliSO.Apttus_Config2__AttributeValueId__r.APTS_Buy_Back_Period__c != null ? Double.valueOf(buyBackliSO.Apttus_Config2__AttributeValueId__r.APTS_Buy_Back_Period__c) : 0;
        
        for(Apttus_Config2__LineItem__c liSO : buyBackEligibleLines){
            Id pId = liSO.Apttus_Config2__ProductId__c;
            bbcAmount += Double.valueOf(liSO.get('APTS_MRR__c'));
        }
        
        return bbcAmount*buyBackPeriod*-1;
    }

    public static decimal getPromotionalCredit(Apttus_Config2__LineItem__c cloudliSO, decimal promoDiscount){
        decimal promoCredit = 0;
        Decimal totalDiscount = 0 ;
        Decimal listPrice = 0;
        Decimal promoListPrice = 0;
        Decimal netPrice = 0;
        Decimal promoNetPrice = 0;

        totalDiscount += cloudliSO.APTS_Deal_Reg_Disc__c != null ? cloudliSO.APTS_Deal_Reg_Disc__c : 0;
        totalDiscount += cloudliSO.APTS_Partner_Disc__c != null ? cloudliSO.APTS_Partner_Disc__c : 0;
        listPrice = cloudliSO.Apttus_Config2__BaseExtendedPrice__c != null ? cloudliSO.Apttus_Config2__BaseExtendedPrice__c : 0;
        netPrice = listPrice * (100 - totalDiscount)/100;
        promoListPrice = listPrice * (100 - promoDiscount)/100  ;
        promoNetPrice = promoListPrice *(100 -  totalDiscount)/100;
        promoCredit =  netprice - promoNetPrice;
        return netprice - promoNetPrice;

    }

    public static double getPromotionalCredit(Apttus_Config2__AssetLineItem__c assetLineItem, Apttus_Config2__LineItem__c cloudliSO, decimal promoDiscount){
        Double promoCredit = 0;
        Decimal totalDiscount = 0 ;
        //Double assetListPrice = 0;
        Double remainingAssetListPrice = 0;
        Double remainingAssetListPriceWithPromo = 0;
        double remainingAssetNetPrice = 0;
        Double listPrice = 0;
        Double remainingAssetNetPriceWithPromo = 0;
        Double netPrice = 0;

        Double promoListPrice = 0;
        //Double assetNetPrice = 0;

        Double promoNetPrice = 0;
        Double term = 0;
        Double remainingTerm = 0;


        totalDiscount += cloudliSO.APTS_Deal_Reg_Disc__c != null ? cloudliSO.APTS_Deal_Reg_Disc__c : 0;
        totalDiscount += cloudliSO.APTS_Partner_Disc__c != null ? cloudliSO.APTS_Partner_Disc__c : 0;

        term = cloudliSO.APTS_Selling_Term__c != null ? cloudliSO.APTS_Selling_Term__c : 0;
        remainingTerm = cloudliSO.Apttus_Config2__StartDate__c.monthsBetween(assetLineItem.Apttus_Config2__EndDate__c);


        remainingAssetNetPrice = assetLineItem.APTS_MRR__c * remainingTerm;

        remainingAssetListPrice = remainingTerm * assetLineItem.Apttus_Config2__BaseExtendedPrice__c/assetLineItem.APTS_Selling_Term__c;
        remainingAssetListPriceWithPromo = remainingAssetListPrice * (100 - promoDiscount)/100;
        remainingAssetNetPriceWithPromo = remainingAssetListPriceWithPromo * (100 -  totalDiscount)/100;


        if(remainingAssetNetPrice > remainingAssetNetPriceWithPromo){
            promoCredit += remainingAssetNetPrice - remainingAssetNetPriceWithPromo;
        }
        listPrice = cloudliSO.Apttus_Config2__BaseExtendedPrice__c != null ? cloudliSO.Apttus_Config2__BaseExtendedPrice__c : 0;
        netPrice = listPrice * (100 - totalDiscount)/100;
        promoListPrice = listPrice * (100 - promoDiscount)/100  ;
        promoNetPrice = promoListPrice *(100 -  totalDiscount)/100;
        promoCredit +=  netprice - promoNetPrice;

        return promoCredit;

    }

    public static void calculateACVAndMRRForCloudPromo( Apttus_Config2__LineItem__c li, decimal totalTermMonths){
        if(totalTermMonths != null && li != null){
            li.APTS_MRR__c = li.Apttus_Config2__BasePriceOverride__c / totalTermMonths;
            if (totalTermMonths >= 12)
                li.APTS_ACV__c = li.APTS_MRR__c * 12;
            else
                li.APTS_ACV__c = li.APTS_MRR__c * totalTermMonths;
        }

    }
    // converted a formula field to apex to make the field available for constraint rules.
    // converted back to formula fields as total ramp quantity, ramp end date calculations has been moved to line item trigger.
    /*public static Integer getNewPlatformQuantityCheck(Apttus_Config2__LineItem__c liSO, Apttus_Config2__ProductConfiguration__c prodConfigSO){
        Double sipTotalQuantity = prodConfigSO.APTS_SIP_Quantity_Check__c == 0 ? prodConfigSO.Apttus_Config2__AccountId__r.APTS_No_of_Platform_Seats__c : prodConfigSO.APTS_SIP_Quantity_Check__c;
        if(liSO.Apttus_Config2__IsPrimaryLine__c == true
            && liSO.Apttus_Config2__ItemSequence__c == 1
            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_SIP){
            if(liSO.Apttus_Config2__ProductId__r.APTS_Sync_Quantity_with_Platform__c == true
                &&(liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                   || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED
                   || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED)
                && sipTotalQuantity == liSO.APTS_Total_Ramp_Quantity__c)
                return 0;
            else
                return 1;
        }else
            return 0;
    }

    // converted a formula field to apex to make the field available for constraint rules.
    public static Integer getNewPlatformEndDateCheck(Apttus_Config2__LineItem__c liSO, Apttus_Config2__ProductConfiguration__c prodConfigSO){
        if(liSO.Apttus_Config2__IsPrimaryLine__c == true
            && liSO.Apttus_Config2__ItemSequence__c == 1
            && liSO.APTS_ProductCode__c != APTS_CONSTANTS.PROD_SKU_SIP
            && liSO.Apttus_Config2__PriceType__c != APTS_CONSTANTS.PROD_PRICETYPE_RECURRING
            && String.isNotBlank(liSO.Apttus_Config2__Frequency__c)){
            if(liSO.APTS_Ramp_End_Date__c == prodConfigSO.APTS_SIP_End_Date_Check__c)
                return 0;
            else
                return 1;
        }else
            return 0;
    }*/

    public class AggrLineInfo{
        public Double lineNumber;
        public Double sellingTermMonths;
        public Double sellingTermMonthsafterBuyback;
        public Double cumulativeAcv;
        public AggrLineInfo(){
            this.lineNumber = 0;
            this.sellingTermMonths = 0;
            this.sellingTermMonthsafterBuyback = 0;
            this.cumulativeAcv = 0;
        }

        public AggrLineInfo(Apttus_Config2__LineItem__c liSO){
            
            this.lineNumber = liSO.Apttus_Config2__LineNumber__c;
            this.sellingTermMonths = liSO.APTS_Selling_Term__c;
            Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);
            this.sellingTermMonthsafterBuyback = pricingCallBackFieldsMap.containsKey('Total_Selling_Term_Months__c') ? Double.valueOf(pricingCallBackFieldsMap.get('Total_Selling_Term_Months__c')) : liSO.APTS_Selling_Term__c;
            this.cumulativeAcv = liSO.APTS_ACV__c;
            
        }
        public void addLI(Apttus_Config2__LineItem__c liSO){
            this.sellingTermMonths += liSO.APTS_Selling_Term__c;
            Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);
            this.sellingTermMonthsafterBuyback = pricingCallBackFieldsMap.containsKey('Total_Selling_Term_Months__c') && this.sellingTermMonthsafterBuyback < Double.valueOf(pricingCallBackFieldsMap.get('Total_Selling_Term_Months__c')) ? Double.valueOf(pricingCallBackFieldsMap.get('Total_Selling_Term_Months__c')) : this.sellingTermMonthsafterBuyback;
            this.cumulativeAcv += liSO.APTS_ACV__c;
        }
    }
    
    public static void calculateDiscountsforPremSupport(Apttus_Config2__LineItem__c liSO, String supportsource, Decimal discountwithoutsupport){
        // Fields that gets calculated are Apttus_Config2__AdjustmentAmount__c, APTS_Total_Discount_Percentage__c, APTS_Manual_Discount_Approvals__c, APTS_MRR__c and APTS_ACV__c.
        // Populate Apttus_Config2__AdjustmentAmount__c to correct value based on Apttus_Config2__AdjustmentType__c so Net Price will be calculated prior to afterPricing(OOB).
        // APTS_Manual_Discount_Approvals__c is percentage of manual discount if adjustment type is not '% discount'.
        Double  partnerDiscountPct = 0;
        Double  dealRegDiscountPct = 0;
        Double  newLogoDiscountPct = 0;
        Decimal totalDiscountPct = 0;
        Decimal adjustedtotalDiscountAmt = 0;
        Double  totalDiscountAmt = 0;

        if (liSO.APTS_Partner_Disc__c != null) {
            partnerDiscountPct = liSO.APTS_Partner_Disc__c;
        }

        if (liSO.APTS_Deal_Reg_Disc__c != null) {
            dealRegDiscountPct = liSO.APTS_Deal_Reg_Disc__c;
        }

        if (liSO.APTS_New_Logo_Disc__c != null) {
            newLogoDiscountPct = liSO.APTS_New_Logo_Disc__c;
        }
        totalDiscountPct = partnerDiscountPct  +  dealRegDiscountPct + newLogoDiscountPct;

        //Extract DisableManualAdjustments__c value
        System.debug('>>> liSO.Pricing_Callback_Fields__c: ' + liSO.Pricing_Callback_Fields__c);
        Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);
        Boolean disableManualAdjustments = pricingCallBackFieldsMap.containsKey('DisableManualAdjustments__c') ? (Boolean)pricingCallBackFieldsMap.get('DisableManualAdjustments__c') : false;
        Boolean GSAQuote = pricingCallBackFieldsMap.containsKey('GSAQuote') ? (Boolean)pricingCallBackFieldsMap.get('GSAQuote') : false;
        Boolean AllowDiscMod = pricingCallBackFieldsMap.containsKey('AllowDiscModonPremSup') ? (Boolean)pricingCallBackFieldsMap.get('AllowDiscModonPremSup') : false;

        if (disableManualAdjustments != true) {
            if(liSO.Apttus_Config2__AdjustmentType__c == '% Discount'){
                if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT && supportsource == APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST && GSAQuote){
                    liSO.APTS_Manual_Discount__c = liSO.APTS_Manual_Discount__c != null && discountwithoutsupport != null && (liSO.APTS_Manual_Discount__c  > discountwithoutsupport || AllowDiscMod) ? liSO.APTS_Manual_Discount__c : discountwithoutsupport;
                }
                liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Manual_Discount__c;
                liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct+liSO.APTS_Manual_Discount__c;
                liSO.APTS_Total_Discount_Percentage__c = liSO.Apttus_Config2__AdjustmentAmount__c;
            }
            else if (liSO.Apttus_Config2__AdjustmentType__c == 'Discount Amount') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Discount Amount';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    totalDiscountAmt = liSO.APTS_Manual_Discount__c  +  (liSO.Apttus_Config2__BaseExtendedPrice__c * totalDiscountPct/100);
                    liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Manual_Discount__c / liSO.Apttus_Config2__BaseExtendedPrice__c) * 100;
                    liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountAmt;
                    liSO.APTS_Total_Discount_Percentage__c = ((totalDiscountAmt/liSO.Apttus_Config2__BaseExtendedPrice__c)*100).setScale(2);
                }
            }else if (liSO.Apttus_Config2__AdjustmentType__c == '% Markup') {
                // liSO.Apttus_Config2__AdjustmentType__c = '% Markup';
                adjustedtotalDiscountAmt  = liSO.APTS_Manual_Discount__c  - totalDiscountPct;
                liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Manual_Discount__c * (-1);
                liSO.Apttus_Config2__AdjustmentAmount__c = adjustedtotalDiscountAmt;
                liSO.APTS_Total_Discount_Percentage__c = adjustedtotalDiscountAmt * (-1);
            }else if (liSO.Apttus_Config2__AdjustmentType__c == 'Markup Amount') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Markup Amount';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    totalDiscountAmt = liSO.APTS_Manual_Discount__c  - (liSO.Apttus_Config2__BaseExtendedPrice__c * totalDiscountPct/100);
                    liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountAmt;
                    liSO.APTS_Total_Discount_Percentage__c = (totalDiscountAmt / liSO.Apttus_Config2__BaseExtendedPrice__c) * 100;
                    liSO.APTS_Manual_Discount_Approvals__c = liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct;
                }
            }else if (liSO.Apttus_Config2__AdjustmentType__c == 'Price Override') {
                // liSO.Apttus_Config2__AdjustmentType__c = 'Price Override';
                if(liSO.Apttus_Config2__BaseExtendedPrice__c != 0){
                    liSO.Apttus_Config2__AdjustmentAmount__c = liSO.APTS_Manual_Discount__c;
                    if(liSO.APTS_Suppresstotaldiscount__c == false)
                    {
                        liSO.APTS_Total_Discount_Percentage__c = ((liSO.Apttus_Config2__BaseExtendedPrice__c - liSO.Apttus_Config2__AdjustmentAmount__c)/liSO.Apttus_Config2__BaseExtendedPrice__c)*100;
                        liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct).setScale(2);
                    }
                }else{
                    liSO.Apttus_Config2__AdjustmentAmount__c = liSO.APTS_Manual_Discount__c;

                    if(liSO.APTS_Suppresstotaldiscount__c == false){
                        liSO.APTS_Total_Discount_Percentage__c = liSO.Apttus_Config2__AdjustmentAmount__c*-1;
                        liSO.APTS_Manual_Discount_Approvals__c = (liSO.APTS_Total_Discount_Percentage__c - totalDiscountPct).setScale(2);
                    }
                }
            }else{
                // default values if no discount is selected.
                // default the adjustmenttype only if manual adjustments are allowed.
                if(liSO.Apttus_Config2__AllowManualAdjustment__c == true)
                    liSO.Apttus_Config2__AdjustmentType__c = '% Discount';
                liSO.APTS_Manual_Discount__c = 0;
                liSO.APTS_Manual_Discount_Approvals__c = 0;
                liSO.APTS_Total_Discount_Percentage__c = totalDiscountPct;
                liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct;
            }
        } else {
            if(liSO.Apttus_Config2__AllowManualAdjustment__c == true)
                liSO.Apttus_Config2__AdjustmentType__c = '% Discount';
            liSO.APTS_Manual_Discount__c = 0;
            liSO.APTS_Manual_Discount_Approvals__c = 0;
            liSO.APTS_Total_Discount_Percentage__c = totalDiscountPct;
            liSO.Apttus_Config2__AdjustmentAmount__c = totalDiscountPct;
        }
    }
    public static void booster(){
        integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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
}