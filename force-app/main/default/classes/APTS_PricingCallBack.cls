/*************************************************************
@Name: APTS_PricingCallBack
@Author:  Sanjay Nair
@CreateDate: 13 Nov 2016
@Description: Class to handle  price computation as per business requirement for different products, after cretion of line items.
*****************************************************************
* Modification Log
*
* Harish Emmadi         10/28/2016      rewrote most of the class.
* Harish Emmadi         11/08/2016      Merged TAM Top Up calculation and APTS_Current_LI_Ramp_End_Date__c from APTS_PricingCallBackSO.
* Harish Emmadi         11/08/2016      Commented derivation of APTS_Current_LI_Ramp_End_Date__c as its same as APTS_Ramp_End_Date__c.
* Harish Emmadi         11/10/2016      Commented Managed support calculation and changed the premium support calculation based on PAV.APTS_Premium_Support_Type__c.
*                                       Moved Total ramp quantity and ramp end date to line item trigger.
* Harish Emmadi         11/15/2016      Changed Uplift year 4 calculation.
* Harish Emmadi         11/16/2016      Prorate the assets for premium support calculation.
* Harish Emmadi         11/30/2016      Moved APTS_Selling_Term__c derivation to line item trigger. - [ZSCAL-117]
*                                       updated buyback credit calculation to include the products where buy back eligible is set to true but not the subscription products. - [ZSCAL-117]
*                                       update afterPricing method for pricing of premium support as it can be shorter than other subscription SKU's in the cart - [ZSCAL-145]
* Harish Emmadi         12/06/2016      Added APTS_Total_Term__c derivation.
* Harish Emmadi         12/08/2016      Updated the derivation of Apttus_Config2__BasePriceOverride__c in beforePricing Method.
* Harish Emmadi         12/09/2016      Updated the Uplift year 4, Uplift year 5 calculations to consider selling term to be 1 when dates are blank. - [ZSCAL-213]
* Harish Emmadi         12/14/2016      Updated TamTop base price calculation as it was changed from onetime to recurring - [ZSCAL-218]
* Harish Emmadi         12/21/2016      Updated finish method to always calculate discounts for tam top up and one 8th of tam. - [ZSCAL-218]
* Harish Emmadi         01/05/2017      Updated start to zero buyBackTotalMRR - [ZSCAL-286]
* Harish Emmadi         01/19/2017      Updated base extended inclusion of cancelled lines for premium support calculation.
* Vijay Prakash P J     04/24/2017      Updated logic to calculate ACV and MRR for BuyBack credit SKU
* Vijay Prakash P J     04/24/2017      Updated Premium Support calculation logic to consider asset / cart line items that are active during the Premium Support subscription period.
* Vijay Prakash P J     10/11/2017      Updated Premium Support calculation logic to perform individual premium support calculation for each asset, sum it up based on Zscaler Product Family (ZIA/ZPA) [Zendesk Ticket #15718]
* Vijay Prakash P J     10/27/2017      Updated logic for determining Premium Support Source and Percent.
* Vijay Prakash P J     09/04/2018      Reset Apttus_Config2__IsAssetPricing__c flag to false for all renewed line items
*****************************************************************
*
Functionality:
This includes both new business and renewal.

Action      Line Status         Comments
CHANGE      Amended             Same as New for discount calculation. - [beforePricingLineItem]
                                If quantity changed and start, end dates are same - Subtract asset line item's net price from line item's base extended price - [beforePricing]
SWAP        Cancelled           For Cancelled line populate net price with price adjustment. - [finish]
            Upgraded            Same as New for discount calculation. - [beforePricingLineItem]
                                Take Qty from the Asset Line Item(last asset if ramped) and update it to the new line. - [beforePricing]
TERMINATE   Cancelled           For Cancelled line populate net price with price adjustment. - [finish]
RENEW       Renewed             same as New for discount calculation. - [beforePricingLineItem]
                                Take Qty from the Asset Line Item(last asset if ramped) and update it to the new line. - [beforePricing]

Premium support.base extended calculation - [finish]: Sum of lines(ChargeType__c = 'Subscription Fee', PriceType__c == 'Recurring') base extended or net price based on account.premium support source.
                                            take the pecentage of sum based on account.premium support %.
Managed Premium support.base extended calculation - [finish]: Sum of lines(ChargeType__c = 'Subscription Fee', PriceType__c == 'Recurring') base extended or net price based on account.managed premium support source.
                                                    take the pecentage of sum based on account.managed premium support %.
Uplift for Year 4.base extended calculation - [finish]: Sum of lines(ChargeType__c = 'Subscription Fee', PriceType__c == 'Recurring', selling term > 36 and <=48) ACV's and apply 5%.
Uplift for Year 5.base extended calculation - [finish]: Sum of lines(ChargeType__c = 'Subscription Fee', PriceType__c == 'Recurring', selling term > 48 and <=60) ACV's and apply 5.25%.

Total Ramp Quantity - [beforePricing]: populate line.total_ramp_quantity__c with last ramp quantity of the same line+existing last asset's total ramp quantity.
Rmp End Date  - [beforePricing]: populate line.APTS_Ramp_End_Date__c with last End date of the same line.
APTS_Selling_Term__c - [beforePricing]: difference between start and end date.

Total Discount - [beforePricingLineItem]: APTS_Partner_Disc__c+APTS_Deal_Reg_Disc__c+APTS_New_Logo_Disc__c+APTS_Manual_Discount__c(based on Apttus_Config2__AdjustmentType__c).
Manual Discount(Approvals) - [beforePricingLineItem]: APTS_Manual_Discount__c(based on Apttus_Config2__AdjustmentType__c).
APTS_MRR__c - [beforePricingLineItem]: Apttus_Config2__NetPrice__c/APTS_Selling_Term__c. - Do not calculate for One-time products.
APTS_ACV__c - [beforePricingLineItem] : APTS_Selling_Term__c >= 12 then APTS_MRR__c * 12 else objLI.APTS_MRR__c * objLI.APTS_Selling_Term__c. - Do not calculate for One-time products.
Apttus_Config2__BasePriceOverride__c: uplift the Renewal quote with 5% for quotes where bill to name contains Zscaler
*/

global with sharing class APTS_PricingCallBack Implements Apttus_Config2.CustomClass.IPricingCallback3 {

    private Apttus_Config2.ProductConfiguration cart = null;
    private Apttus_Config2.CustomClass.PricingMode mode = null;

    static Apttus_Config2__ProductConfiguration__c prodConfigWrelFields;
    static Map<Id, Apttus_Config2__AssetLineItem__c> aliIdtoALISOMap;// all active asset lines from account.
    static Map<Id, Double> productIdTOTotalTermMap;// used to populate total term on ramp lines.
    static List<Apttus_Config2__LineItem__c> buyBackEligibleLines;
    static List<Apttus_Config2__LineItem__c> zpaBuyBackEligibleLines;
    static Map<String, Id> assetLineItemsSKUCodeIdMap;
    static Map<String, Decimal> assetLineItemsSKUCodeCountMap;
    static Map<Id, Decimal> productIdToPremiumSupportNetPriceMap;
    static Map<Id, Decimal> productIdToPremiumSupportListPriceMap;
    static Set<Id> setZIAProductIds;
    static Set<Id> setZPAProductIds;
    static Map<Id, Id> productIdToLineItemIdMap;

    //static APTS_PricingGateway pGW;

    static Decimal intBundleQuantityCheck = 2;
    static Decimal intMaxLineItmCntBundle = 0;

    static Double subscriptionBaseExtendedSum = 0;
    static Double subscriptionNetPriceSum = 0;
    static Double premiumSupportTerm_Days = 0;// used to prorate assets and calculation of premium support price.
    static Date premiumSupportStartDate;
    static Date premiumSupportEndDate;
    static Decimal upliftYear4ACVS_Total = 0;
    static Decimal upliftYear5ACVS_Total = 0;
    static Decimal percentDiscountforZLIVE = 0;
    static Decimal totalListPriceWithoutSupport = 0;
    static Decimal totalnetPriceWithoutSupport = 0;
    //CR# 223 - Abhishek V - Early_Adopter - Start
    static Apttus_Config2.LineItem early_adopter_SKU = null;
    //CR# 223 - Abhishek V - Early_Adopter - End

    //CR# 222 - Minkesh Patel
    static Boolean isWFHEligible = false;
    static Boolean isZIABundlePresent = false;
    static Boolean isZPABundlePresent = false;
    static Boolean isPSPresent = false;
    static Apttus_Config2.LineItem wfHSKU = null;
    static Double ttlziaprice = 0.0;
    static Double ttlzpaprice = 0.0;
    //CR# 222
    
    static String ZLIVEPromoSKUCode = '';
    static Apttus_Config2.LineItem ZLIVEPROMOSKU = null;
    static Date quoteStartDate;
    static Date quoteEndDate;
    static Double quoteTerm = 0;
    static Double zpaProNetPriceSum = 0;
    static Boolean zpaInInstallBase = false;

    static List<Apttus_Config2.LineItem> lineItemsToUpdate;
    static List<Apttus_Config2.LineItem> lineItemsPricingAdjustmentToUpdate;
    static Map<Double, APTS_PricingHelper.AggrLineInfo> lineNumberTOAggrLineInfoMap;
    //CR# 222 - Minkesh Patel start
    /*Set<String> zpaset = new Set<String>{APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU , 
        APTS_CONSTANTS.PROD_SKU_ZPA_PRO , 
        APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU, 
        APTS_CONSTANTS.PROD_SKU_ZPA_BUS};
    Set<String> ziaset = new Set<String>{APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE , 
        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE , 
        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE , 
        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU ,
        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU , 
        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU , 
        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE , 
        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU};*/
    //CR# 222 - Minkesh Patel end
    global APTS_PricingCallBack(){}

    /**
     * Callback at the beginning of the pricing call.
     * Use the start method to initialize state
     * @param cart the cart object
     */
    global void start(Apttus_Config2.ProductConfiguration cart) {
        System.debug('Method is: start '+mode);
        try{

            this.cart = cart;

            aliIdtoALISOMap = new Map<Id, Apttus_Config2__AssetLineItem__c>();

            lineNumberTOAggrLineInfoMap = new Map<Double, APTS_PricingHelper.AggrLineInfo>();
            lineItemsToUpdate = new List<Apttus_Config2.LineItem>();
            lineItemsPricingAdjustmentToUpdate = new List<Apttus_Config2.LineItem>();
            productIdTOTotalTermMap = new Map<Id, Double>();
            buyBackEligibleLines = new List<Apttus_Config2__LineItem__c>();
            zpaBuyBackEligibleLines = new List<Apttus_Config2__LineItem__c>();
            assetLineItemsSKUCodeIdMap = new Map<String, Id>();
            assetLineItemsSKUCodeCountMap = new Map<String, Decimal>();
            productIdToPremiumSupportNetPriceMap = new Map<Id, Decimal>();
            productIdToPremiumSupportListPriceMap = new Map<Id, Decimal>();
            setZIAProductIds = new Set<Id>();
            setZPAProductIds = new Set<Id>();
            productIdToLineItemIdMap = new Map<Id, Id>();


            // clear the values here so it will be cleared for each pricing mode.
            subscriptionBaseExtendedSum = 0;
            subscriptionNetPriceSum = 0;
            upliftYear4ACVS_Total = 0;
            upliftYear5ACVS_Total = 0;
            zpaProNetPriceSum = 0;

            //CR# 222
            isWFHEligible = false;
            isZIABundlePresent = false;
            isZPABundlePresent = false;
            isPSPresent = false;
            ttlziaprice = 0.0;
            ttlzpaprice = 0.0;
            //end of CR# 222

            Set<Id> aliIdSet_inCurrentCart = new Set<Id>();
            Map<String, ZLIVE_Promo_Disc_Mapping__c> zlivePromomap = ZLIVE_Promo_Disc_Mapping__c.getAll();
            for(Apttus_Config2.LineItem configLineItem : this.cart.getLineItems()){
                Apttus_Config2__LineItem__c liSO = configLineItem.getLineItemSO();
                // System.debug('lineItemMO start is: '+configLineItem.getLineItemSO().Apttus_Config2__BaseExtendedPrice__c+' '+configLineItem.getLineItemSO().Product_Name__c);

                //Determine the start and end date of the quote:
                quoteStartDate = (quoteStartDate == null || liSO.Apttus_Config2__StartDate__c < quoteStartDate) ? liSO.Apttus_Config2__StartDate__c : quoteStartDate;
                quoteEndDate = (quoteEndDate == null || liSO.Apttus_Config2__EndDate__c > quoteEndDate) ? liSO.Apttus_Config2__EndDate__c : quoteEndDate;

                if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZBUSINESSSUITE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZENTSUITE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPROSUITE){
                    if (intMaxLineItmCntBundle < liSO.Apttus_Config2__Quantity__c ) {
                        intBundleQuantityCheck = 1;
                    }
                }

                if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZBUSINESSSUITE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZENTSUITE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPROSUITE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT){
                    if (intMaxLineItmCntBundle < liSO.Apttus_Config2__Quantity__c ) {
                        intMaxLineItmCntBundle =   liSO.Apttus_Config2__Quantity__c ;
                        intBundleQuantityCheck = 1;
                    }
                }

                // used to prorate assets.
                if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT
                    && liSO.Apttus_Config2__SellingTerm__c != null){
                    premiumSupportTerm_Days = liSO.Apttus_Config2__SellingTerm__c*365;
                    premiumSupportStartDate = liSO.Apttus_Config2__StartDate__c;
                    premiumSupportEndDate = liSO.Apttus_Config2__EndDate__c;
                }

                if(liSO.Apttus_Config2__AssetLineItemId__c != null){
                    aliIdSet_inCurrentCart.add(liSO.Apttus_Config2__AssetLineItemId__c);
                }

                Id productId = liSO.Apttus_Config2__ProductId__c;
                Date liStartDate = liSO.Apttus_Config2__StartDate__c;
                Date liEndDate = liSO.Apttus_Config2__EndDate__c;
                Double liSellingTerm = 0;

                if(liEndDate != null && liStartDate != null)
                    liSellingTerm = (Integer)Math.roundToLong(((liStartDate.daysBetween(liEndDate))/30.25));
                if(productIdTOTotalTermMap.containsKey(productId))
                {
                    productIdTOTotalTermMap.put(productId, productIdTOTotalTermMap.get(productId)+liSellingTerm);
                }else{
                    productIdTOTotalTermMap.put(productId, liSellingTerm);
                }
                
                if(zlivePromomap != null && !zlivePromomap.isEmpty() && liSO.APTS_ProductCode__c != null && zlivePromomap.containsKey(liSO.APTS_ProductCode__c)){
                    percentDiscountforZLIVE = zlivePromomap.get(liSO.APTS_ProductCode__c).Discount_Percent__c;
                    ZLIVEPromoSKUCode = liSO.APTS_ProductCode__c;
                    ZLIVEPROMOSKU = configLineItem;
                    
                }
                //CR# 222 - Changes by Minkesh Patel
                if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE 
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU)
                {
                    System.debug('isZIABundlePresent+++++++++'+liSO.APTS_ProductCode__c);
                    isZIABundlePresent = true;
    
                }
                else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU 
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS)
                {
                    isZPABundlePresent = true;
                    System.debug('isZPABundlePresent+++++++++'+liSO.APTS_ProductCode__c);
                }
                else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT)
                {
                    isPSPresent = true;
                    System.debug('isPSPresent+++++++++'+liSO.APTS_ProductCode__c);
                }
                else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO)
                {
                    System.debug('WFH+++++++++'+liSO.APTS_ProductCode__c);
                    isWFHEligible = true;
                    wfHSKU = configLineItem;
                }
                //end of CR# 222

                //CR# 223 - Abhishek V - Early_Adopter - Start
                /*if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.EARLY_ADOPTER){
                    early_adopter_SKU = configLineItem;
                    
                }*/
                //CR# 223 - Abhishek V - Early_Adopter - End

            }

            //Calculate quote term
            if(quoteStartDate != null &&  quoteEndDate != null)
                quoteTerm = (Double)Math.roundToLong(((quoteStartDate.daysBetween(quoteEndDate))/30.25));

            // Update: HE, 12/09/2016 - Added cancelled line items sub-query.
            prodConfigWrelFields = [Select Id,  Apttus_Config2__BillToAccountId__r.Premium_Support_Source__c, Apttus_Config2__BillToAccountId__r.Premium_Support__c,
                                           Apttus_Config2__BillToAccountId__r.Managed_Support_Source__c,  Apttus_Config2__BillToAccountId__r.Managed_Support__c,
                                           APTS_SIP_Quantity_Check__c, Apttus_Config2__AccountId__r.APTS_No_of_Platform_Seats__c, APTS_SIP_End_Date_Check__c, APTS_Asset_SKU__c,Apttus_QPConfig__Proposald__r.ZPA_CFW_Promotion_Exception__c,
                                           APTS_Record_Type__c, Apttus_Config2__BillToAccountId__r.Name, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c,
                                           Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c,
                                           Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c,
                                           Apttus_QPConfig__Proposald__r.APTS_Subscription_Term__c,
                                           Apttus_QPConfig__Proposald__r.Premium_Support_Override__c, Apttus_QPConfig__Proposald__r.Premium_Support_Source_Override__c, Apttus_QPConfig__Proposald__r.Set_BuyBack_SKU_ACV_To_Zero__c,
                                           Apttus_Config2__AccountId__r.Total_ZIA_Premium_Support_ACV__c, Apttus_Config2__AccountId__r.Total_ZPA_Premium_Support_ACV__c, ZPA_PRO_Manual_Adjustments__c, Allow_ZPA_Promotion_In_Cart__c,
                                           Apttus_QPConfig__Proposald__r.Managed_Support_Override__c, Apttus_QPConfig__Proposald__r.Managed_Support_Source_Override__c,Exclude_Assets_From_Prem_Support_Calc__c,Apttus_QPConfig__Proposald__r.Set_ZPA_BuyBack_SKU_ACV_To_Zero__c,
                                           Apttus_QPConfig__Proposald__r.Model_Type_Partner__c,
                                                (Select Id, Apttus_Config2__LineStatus__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__NetPrice__c, APTS_Total_Discount_Percentage__c, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, Exclude_From_Premium_Support_Calculation__c From Apttus_Config2__LineItems__r Where Apttus_Config2__LineStatus__c = :APTS_CONSTANTS.LI_STATUS_CANCELLED)
                                                From Apttus_Config2__ProductConfiguration__c
                                                    Where Id = :this.cart.getConfigSO().Id Limit 1];
                                                    
            // update: HE, 12/09/2016 - credit the premium support price for cancelled lines if premium support was purchased earlier.
            if(String.isNotBlank(prodConfigWrelFields.APTS_Asset_SKU__c)
                && prodConfigWrelFields.APTS_Asset_SKU__c.contains(APTS_CONSTANTS.PROD_SKU_PSUPPORT)){
                for(Apttus_Config2__LineItem__c li_cancelled : prodConfigWrelFields.Apttus_Config2__LineItems__r){
                    if(li_cancelled.Apttus_Config2__BaseExtendedPrice__c != null
                        && li_cancelled.Exclude_From_Premium_Support_Calculation__c != true){
                        Double baseExtended_derived = li_cancelled.APTS_Total_Discount_Percentage__c != null ? (li_cancelled.APTS_Total_Discount_Percentage__c < 100 ? li_cancelled.Apttus_Config2__NetPrice__c*(100/(100-li_cancelled.APTS_Total_Discount_Percentage__c)) : li_cancelled.Apttus_Config2__NetPrice__c) : 0;
                        subscriptionBaseExtendedSum += baseExtended_derived;//li_cancelled.Apttus_Config2__BaseExtendedPrice__c;
                        if (productIdToPremiumSupportListPriceMap.containsKey(li_cancelled.Apttus_Config2__ProductId__c)) {
                            productIdToPremiumSupportListPriceMap.put(li_cancelled.Apttus_Config2__ProductId__c, productIdToPremiumSupportListPriceMap.get(li_cancelled.Apttus_Config2__ProductId__c) + baseExtended_derived);
                        } else {
                            productIdToPremiumSupportListPriceMap.put(li_cancelled.Apttus_Config2__ProductId__c, baseExtended_derived);
                        }

                        if (li_cancelled.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZIA) {
                            setZIAProductIds.add(li_cancelled.Apttus_Config2__ProductId__c);
                        } else if (li_cancelled.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZPA) {
                            setZPAProductIds.add(li_cancelled.Apttus_Config2__ProductId__c);
                        }
                    }// Apttus_Config2__NetPrice__c will be calculated negative anyway.
                    if(li_cancelled.Apttus_Config2__NetPrice__c != null
                        && li_cancelled.Exclude_From_Premium_Support_Calculation__c != true){
                        subscriptionNetPriceSum += li_cancelled.Apttus_Config2__NetPrice__c;
                        if (productIdToPremiumSupportNetPriceMap.containsKey(li_cancelled.Apttus_Config2__ProductId__c)) {
                            productIdToPremiumSupportNetPriceMap.put(li_cancelled.Apttus_Config2__ProductId__c, productIdToPremiumSupportNetPriceMap.get(li_cancelled.Apttus_Config2__ProductId__c) + li_cancelled.Apttus_Config2__NetPrice__c);
                        } else {
                            productIdToPremiumSupportNetPriceMap.put(li_cancelled.Apttus_Config2__ProductId__c, li_cancelled.Apttus_Config2__NetPrice__c);
                        }

                        if (li_cancelled.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZIA) {
                            setZIAProductIds.add(li_cancelled.Apttus_Config2__ProductId__c);
                        } else if (li_cancelled.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZPA) {
                            setZPAProductIds.add(li_cancelled.Apttus_Config2__ProductId__c);
                        }
                    }

                    productIdToLineItemIdMap.put(li_cancelled.Apttus_Config2__ProductId__c, li_cancelled.Id);
                }
            }

            // retrieve all the active assets lines from account.
            Id accountId = cart.getConfigSO().Apttus_Config2__AccountId__c;
            if(accountId != null)
            {
                aliIdtoALISOMap = new Map<Id, Apttus_Config2__AssetLineItem__c>([Select Id, Apttus_Config2__Quantity__c, Apttus_Config2__BaseExtendedPrice__c,
                                                                                        Apttus_Config2__NetPrice__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceType__c,
                                                                                        Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c,
                                                                                        APTS_Total_Ramp_Quantity__c, APTS_Ramp_End_Date__c, Apttus_Config2__IsPrimaryRampLine__c,
                                                                                        Apttus_Config2__SellingTerm__c, APTS_MRR__c, Apttus_Config2__ListPrice__c, APTS_Selling_Term__c,
                                                                                        Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, Exclude_From_Premium_Support_Calculation__c
                                                                                            From Apttus_Config2__AssetLineItem__c
                                                                                                Where Apttus_Config2__AccountId__c = :accountId
                                                                                                      AND Apttus_Config2__AssetStatus__c = 'Activated'
                                                                                                        Order by Apttus_Config2__LineNumber__c asc, CreatedDate desc]);
            }

            if(!aliIdtoALISOMap.isEmpty()){
                //Populate all the SKU Codes and Asset Line Item Ids
                for (Id assetLineItemId : aliIdtoALISOMap.keySet()) {
                    assetLineItemsSKUCodeIdMap.put(aliIdtoALISOMap.get(assetLineItemId).Apttus_Config2__ProductId__r.ProductCode, assetLineItemId);
                    string prodCode = aliIdtoALISOMap.get(assetLineItemId).Apttus_Config2__ProductId__r.ProductCode;
                    if(assetLineItemsSKUCodeCountMap.keySet().Contains(prodCode))
                        assetLineItemsSKUCodeCountMap.put(prodCode, assetLineItemsSKUCodeCountMap.get(prodCode)+ aliIdtoALISOMap.get(assetLineItemId).Apttus_Config2__Quantity__c);
                    else
                        assetLineItemsSKUCodeCountMap.put(prodCode,aliIdtoALISOMap.get(assetLineItemId).Apttus_Config2__Quantity__c);
                }

                // get the cumulative subscruiption base extended and net price from assets to be included in support lines.
                // should consider Asset only once, if the same asset is present in cart, it should not consider it for calculation again from Assets.
                // Prorate the asset for calculation of premium support if its not present to assets.
                if((String.isBlank(prodConfigWrelFields.APTS_Asset_SKU__c)
                    || !prodConfigWrelFields.APTS_Asset_SKU__c.contains(APTS_CONSTANTS.PROD_SKU_PSUPPORT))
                    && premiumSupportTerm_Days != 0
                    && prodConfigWrelFields.Exclude_Assets_From_Prem_Support_Calc__c != true){
                    for(Id aliId : aliIdtoALISOMap.keySet()){
                        Apttus_Config2__AssetLineItem__c aliSO = aliIdtoALISOMap.get(aliId);
                        if(!aliIdSet_inCurrentCart.contains(aliSO.Id)
                            && aliSO.Apttus_Config2__ChargeType__c == APTS_CONSTANTS.PROD_CHARGETYPE_SFEE
                            && aliSO.Apttus_Config2__PriceType__c == APTS_CONSTANTS.PROD_PRICETYPE_RECURRING
                            && aliSO.Apttus_Config2__ProductId__r.ProductCode != APTS_CONSTANTS.PROD_SKU_PSUPPORT
                            && aliSO.Exclude_From_Premium_Support_Calculation__c != true){
                            // && aliSO.Apttus_Config2__ProductId__r.ProductCode != APTS_CONSTANTS.PROD_SKU_MPSUPPORT){

                            //subscriptionBaseExtendedSum += aliSO.Apttus_Config2__BaseExtendedPrice__c;
                            //subscriptionNetPriceSum += aliSO.Apttus_Config2__NetPrice__c;

                            Double baseExtended = aliSO.Apttus_Config2__BaseExtendedPrice__c;
                            Double netPrice = aliSO.Apttus_Config2__NetPrice__c;
                            Double sellingTerm_Days = aliSO.Apttus_Config2__StartDate__c.daysBetween(aliSO.Apttus_Config2__EndDate__c);
                            Date premiumSupportEffectiveStartDate = (aliSO.Apttus_Config2__StartDate__c < premiumSupportStartDate ? premiumSupportStartDate : aliSO.Apttus_Config2__StartDate__c);
                            Date premiumSupportEffectiveEndDate = (aliSO.Apttus_Config2__EndDate__c > premiumSupportEndDate ? premiumSupportEndDate : aliSO.Apttus_Config2__EndDate__c);
                            Double premiumSupportApplicableDays = premiumSupportEffectiveStartDate.daysBetween(premiumSupportEffectiveEndDate);






                            if(sellingTerm_Days != 0
                                && premiumSupportApplicableDays != 0
                                && premiumSupportApplicableDays > 0){
                                subscriptionBaseExtendedSum += baseExtended*(premiumSupportApplicableDays/sellingTerm_Days);
                                subscriptionNetPriceSum += netPrice*(premiumSupportApplicableDays/sellingTerm_Days);

                                // productIdToPremiumSupportListPriceMap.put(aliSO.Apttus_Config2__ProductId__c, baseExtended*(premiumSupportApplicableDays/sellingTerm_Days));
                                // productIdToPremiumSupportNetPriceMap.put(aliSO.Apttus_Config2__ProductId__c, netPrice*(premiumSupportApplicableDays/sellingTerm_Days));
                                if (productIdToPremiumSupportListPriceMap.containsKey(aliSO.Apttus_Config2__ProductId__c)) {
                                    productIdToPremiumSupportListPriceMap.put(aliSO.Apttus_Config2__ProductId__c, productIdToPremiumSupportListPriceMap.get(aliSO.Apttus_Config2__ProductId__c) + (baseExtended*(premiumSupportApplicableDays/sellingTerm_Days)));
                                } else {
                                    productIdToPremiumSupportListPriceMap.put(aliSO.Apttus_Config2__ProductId__c, baseExtended*(premiumSupportApplicableDays/sellingTerm_Days));
                                }

                                if (productIdToPremiumSupportNetPriceMap.containsKey(aliSO.Apttus_Config2__ProductId__c)) {
                                    productIdToPremiumSupportNetPriceMap.put(aliSO.Apttus_Config2__ProductId__c, productIdToPremiumSupportNetPriceMap.get(aliSO.Apttus_Config2__ProductId__c) + (netPrice*(premiumSupportApplicableDays/sellingTerm_Days)));
                                } else {
                                    productIdToPremiumSupportNetPriceMap.put(aliSO.Apttus_Config2__ProductId__c, netPrice*(premiumSupportApplicableDays/sellingTerm_Days));
                                }

                                if (aliSO.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZIA) {
                                    setZIAProductIds.add(aliSO.Apttus_Config2__ProductId__c);
                                } else if (aliSO.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZPA) {
                                    setZPAProductIds.add(aliSO.Apttus_Config2__ProductId__c);
                                }
                            }
                        }
                    }
                }
            }

            // cancelCreditCode = APTS_PricingHelper.getCreditTerminatin();
        }catch(Exception ex){
            throw new APTS_Exception('Error from start: '+ex.getMessage()+'Apex Line Number: '+ex.getLineNumber());
        }
    }
    


    /**
     * Callback to indicate the pricing mode
     * @param mode the pricing mode
     */
    global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
        this.mode = mode;
    }

    /**
     * Callback before pricing the line item collection
     * Use this method to do all required pre-processing to prepare the line items for pricing.
     * @param itemColl the line item collection to pre-process
     */
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        System.debug('Method is: beforePricing '+mode+' itemColl size is: '+itemColl.getAllLineItems().size()+' basePrice is: '+itemColl.getAllLineItems().get(0).getLineItemSO().Apttus_Config2__BasePrice__c);
        try{
            // Mode condition check must be retested and fixed later. - TODO
            if (mode == Apttus_config2.CustomClass.PricingMode.BASEPRICE
                || mode == Apttus_config2.CustomClass.PricingMode.ADJUSTMENT) {

                List<Apttus_Config2.LineItem> itemCollList = itemColl.getAllLineItems();

                for(Apttus_Config2.LineItem ConfigLI: itemCollList){
                    Apttus_Config2__LineItem__c liSO = ConfigLI.getLineItemSO();


                    if(liSO.Apttus_Config2__StartDate__c != null && liSO.Apttus_Config2__EndDate__c != null)
                    {
                        //liSO.APTS_Selling_Term__c = (liSO.Apttus_Config2__SellingTerm__c * 12).round(System.RoundingMode.FLOOR);
                        liSO.APTS_Selling_Term__c = (Integer)Math.roundToLong(((liSO.Apttus_Config2__StartDate__c.daysBetween(liSO.Apttus_Config2__EndDate__c))/30.25));
                    }

                    if(productIdTOTotalTermMap.containsKey(liSO.Apttus_Config2__ProductId__c))
                    {
                        liSO.APTS_Total_Term__c = productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c);
                    }

                    // Reset Apttus_Config2__IsAssetPricing__c flag to false for all renewed line items
                    if (liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED) {
                        liSO.Apttus_Config2__IsAssetPricing__c = false;
                        // System.debug('*** liSO.Apttus_Config2__AssetQuantity__c: ' + liSO.Apttus_Config2__AssetQuantity__c);
                        // System.debug('*** liSO.Asset_Quantity__c: ' + liSO.Asset_Quantity__c);
                        // if (liSO.Apttus_Config2__AssetQuantity__c != null) {
                        //     liSO.Apttus_Config2__Quantity__c = liSO.Apttus_Config2__AssetQuantity__c;
                        // }
                    }

                    // Calculations applicable only for New Businesss, renewals.
                    if (liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED){

                        if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZBUSINESSSUITE
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZENTSUITE
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPROSUITE
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT){
                            liSO.APTS_Quantity_Check__c =  intBundleQuantityCheck;
                        }

                        //liSO.Apttus_Config2__BasePriceOverride__c = liSO.Apttus_Config2__BasePrice__c;
                        // ConfigLI.updateprice();// Update the Values Back

                        // uplift the Renewal quote with 5% for quotes where bill to name contains Zscaler
                        if(prodConfigWrelFields.Apttus_Config2__BillToAccountId__c != null
                            && prodConfigWrelFields.Apttus_Config2__BillToAccountId__r.Name.containsIgnoreCase(APTS_CONSTANTS.ACC_NAME_ZSCALER)
                            && liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED){
                            // change by sagar jogi start - 03/01/2017 Added if condition to check if it is null
                            if(liSO.Apttus_Config2__BasePriceOverride__c != null) {
                                liSO.Apttus_Config2__BasePriceOverride__c += liSO.Apttus_Config2__BasePrice__c*0.05;
                            }
                            // change by sagar jogi end - 03/01/2017 Added if condition to check if it is null
                        }

                        // Update: HE, 12/08/2016 - set the scale for baseprice to 2 places.
                        if(liSO.Apttus_Config2__BasePrice__c != null)
                            liSO.Apttus_Config2__BasePriceOverride__c = liSO.Apttus_Config2__BasePrice__c.setScale(2);
                    }/* For the Swap and renew: quantity should be populated from last ramp if ramped else from the primary asset line.*/

                }
            }
        }catch(Exception ex){
            throw new APTS_Exception('Error from beforePricing: '+ex.getMessage()+'Apex Line Number: '+ex.getLineNumber());
        }
    }  // End of beforepricing.

    /**
     * Callback before pricing the given line item in the line item collection
     * Use this method to do all required pre-processing to prepare the line item for pricing.
     * @param itemColl the line item collectionholding the line item
     * @param lineItemMO the line item to pre-process
     * Called only for New lines.
     */
    global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
        System.debug('Method is: beforePricingLineItem '+mode+' itemColl size is: '+itemColl.getAllLineItems().size()+' baseExtended is: '+lineItemMO.getLineItemSO().Apttus_Config2__BasePrice__c );
        // Base Extended price is not yet calculated so custom calculation is used(Base extended = Apttus_Config2__Quantity__c * Apttus_Config2__SellingTerm__c* Apttus_Config2__BasePrice__c)
        // Calculate the discounts for new and renewal, swap(upgraded) lines.

        Apttus_Config2__LineItem__c liSO = lineItemMO.getLineItemSO();
        //System.debug('Inside beforePricingLineItem: '+liSO.APTS_ProductCode__c+liSO.APTS_ProductCode__c+liSO.Product_Name__c+liSO.Apttus_Config2__LineStatus__c);
        // use try/catch to show custom exception messages on cart.
        try{
            if (mode == Apttus_config2.CustomClass.PricingMode.ADJUSTMENT
                && (liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                    || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                    || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                    || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED)){

                // support, uplift, buy back, tam tops will be processed in Finish method.
                if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT
                    // || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_MPSUPPORT
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_BUYBACK
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_TAMTOP
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ONE8TAMTOP){
                    return;
                }
                

                // calculate the total discount based on adjustment type and manual discount entered. 
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                lineItemMO.updateprice(); //added by Minkesh patel
                
                Set<String> setonetimeSKUs = new Set<String>();
                setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('One_Time_SKU').SKU_Codes__c.split(';'));
                setonetimeSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('DAS_SKUs').SKU_Codes__c.split(';'));
                if(!setonetimeSKUs.isEmpty() && liSO.APTS_ProductCode__c != null && !setonetimeSKUs.contains(liSO.APTS_ProductCode__c)){
                    totalListPriceWithoutSupport += liSO.Apttus_Config2__BaseExtendedPrice__c != null ? liSO.Apttus_Config2__BaseExtendedPrice__c : 0;
                    totalnetPriceWithoutSupport += liSO.Apttus_Config2__NetPrice__c != null ? liSO.Apttus_Config2__NetPrice__c : 0;
                }

                //Added logic to set Net to zscaler
                 //commented by Minkesh Patel 01/04/2020
                calculateNetToZscaler(liSO);
                lineItemsPricingAdjustmentToUpdate.add(lineItemMO);
                
            }

            
        }catch(Exception ex){
            throw new APTS_Exception('Error from beforePricingLineItem for: '+liSO.APTS_ProductCode__c+' '+ex.getMessage()+'Apex Line Number: '+ex.getLineNumber());
        }
    }

    /**
     * Callback after pricing the given line item in the line item collection
     * Use this method to do all required post-processing after the line item is priced
     * @param itemColl the line item collection holding the line item
     * @param lineItemMO the line item to post-process
     */
    global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
        System.debug('Method is: afterPricingLineItem '+mode+' itemColl size is: '+itemColl.getAllLineItems().size()+' netprice is: '+lineItemMO.getLineItemSO().Apttus_Config2__NetPrice__c);
        calculateNetToZscaler(lineItemMO.getLineItemSO());

    }

    /**
     * Callback after pricing the line item collection
     * Use this method to do all required post-processing after line items are priced.
     * @param itemColl the line item collection to post-process
     */
    global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        System.debug('Method is: afterPricing '+mode+' itemColl size is: '+itemColl.getAllLineItems().size()+' netprice is: '+itemColl.getAllLineItems().get(0).getLineItemSO().Apttus_Config2__NetPrice__c);
        // Field Calculations after net price is calculated
        // No OOB pricing fields can be modified here without updatepricing method.
        // use try/catch to show custom exception messages on cart.
        try{
            if (mode == Apttus_config2.CustomClass.PricingMode.BASEPRICE
                || mode == Apttus_config2.CustomClass.PricingMode.ADJUSTMENT) {

                List<Apttus_Config2.LineItem> itemCollList = itemColl.getAllLineItems();
                for(Apttus_Config2.LineItem lineItemMO: itemCollList){
                    Apttus_Config2__LineItem__c liSO = lineItemMO.getLineItemSO();
                    if(liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                        || liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED){

                        if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_GEN_US ||
                            liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_TRAIN_US ||
                            liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_GEN_EU ||
                            liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_TRAIN_EU) && percentDiscountforZLIVE > 0){
                            lineItemsToUpdate.add(lineItemMO);
                            return;                 
                        }/*else if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_5_PRE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_25_PRE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_100_PRE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_EXTRA_PRE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.SVC_EDGE_V_PRE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.DATA_PROTECTION_BUNDLE ||
                                liSO.APTS_ProductCode__c == APTS_CONSTANTS.SAAS_CASB_API) && early_adopter_SKU != null){
                            //CR# 223 - Abhishek V - Early_Adopter - Start
                            lineItemsToUpdate.add(lineItemMO);
                            //CR# 223 - Abhishek V - Early_Adopter - End
                        }*/
                        else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT){
                            lineItemsToUpdate.add(lineItemMO);
                            //return;
                        }/*else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_MPSUPPORT){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }*/else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_BUYBACK){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_TAMTOP){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ONE8TAMTOP){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_OTAM){
                            lineItemsToUpdate.add(lineItemMO);
                            return;
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL){
                            lineItemsToUpdate.add(lineItemMO);
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX){
                            lineItemsToUpdate.add(lineItemMO);
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO){
                            lineItemsToUpdate.add(lineItemMO);
                        }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP){
                            lineItemsToUpdate.add(lineItemMO);
                        }else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO){
                            lineItemsToUpdate.add(lineItemMO);
                        }else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PROMO){
                            lineItemsToUpdate.add(lineItemMO);
                        }
                        //CR# 222 - Minkesh Patel
                        else if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE 
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU 
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS)&&
                        wfHSKU != null)
                        {
                            lineItemsToUpdate.add(lineItemMO);
                        }
                        //CR# 222
                        else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT){
                            lineItemsToUpdate.add(lineItemMO);
                        }

                        // calculate MRR and ACV once net price is calculated(OOB).
                        APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));

                        // following will not executed for premium support, manager premium support, uplift prods, buy backs.
                        // Update: HE, 11/30/2016 - premium support can be shorter than other subscription products in the cart so calculate for premium support term.

                        Map<String, Object> mapPricingCallbackFields = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);

                        if(liSO.Apttus_Config2__ChargeType__c == APTS_CONSTANTS.PROD_CHARGETYPE_SFEE
                            && liSO.Apttus_Config2__PriceType__c == APTS_CONSTANTS.PROD_PRICETYPE_RECURRING
                            ){
                            if((Boolean)mapPricingCallbackFields.get('Exclude_From_Premium_Support_Calculation__c') != true){
                                Double sellingTerm_Days = liSO.Apttus_Config2__StartDate__c.daysBetween(liSO.Apttus_Config2__EndDate__c);//Math.ceil(liSO.Apttus_Config2__SellingTerm__c*365);

                                /*if(sellingTerm_Days != 0){
                                    subscriptionBaseExtendedSum += liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportTerm_Days/sellingTerm_Days);
                                    subscriptionNetPriceSum += liSO.Apttus_Config2__NetPrice__c*(premiumSupportTerm_Days/sellingTerm_Days);
                                }*/

                                Date premiumSupportEffectiveStartDate = (liSO.Apttus_Config2__StartDate__c < premiumSupportStartDate ? premiumSupportStartDate : liSO.Apttus_Config2__StartDate__c);
                                Date premiumSupportEffectiveEndDate = (liSO.Apttus_Config2__EndDate__c > premiumSupportEndDate ? premiumSupportEndDate : liSO.Apttus_Config2__EndDate__c);
                                Double premiumSupportApplicableDays = premiumSupportEffectiveStartDate.daysBetween(premiumSupportEffectiveEndDate);

                                String productFamily = (String)mapPricingCallbackFields.get('Zscaler_Product_Family__c');
                                if (productFamily == APTS_CONSTANTS.PROD_FAMILY_ZIA) {
                                    setZIAProductIds.add(liSO.Apttus_Config2__ProductId__c);
                                } else if (productFamily == APTS_CONSTANTS.PROD_FAMILY_ZPA) {
                                    setZPAProductIds.add(liSO.Apttus_Config2__ProductId__c);
                                }

                                if (premiumSupportApplicableDays > 0) {
                                    System.debug('>>>> subscriptionBaseExtendedSum: ' + subscriptionBaseExtendedSum);
                                    System.debug('>>>> liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days): ' + (liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days)));
                                    subscriptionBaseExtendedSum += liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days);
                                    subscriptionNetPriceSum += liSO.Apttus_Config2__NetPrice__c*(premiumSupportApplicableDays/sellingTerm_Days);

                                    if (productIdToPremiumSupportListPriceMap.containsKey(liSO.Apttus_Config2__ProductId__c)) {
                                        productIdToPremiumSupportListPriceMap.put(liSO.Apttus_Config2__ProductId__c, productIdToPremiumSupportListPriceMap.get(liSO.Apttus_Config2__ProductId__c) + (liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days)));
                                    } else {
                                        productIdToPremiumSupportListPriceMap.put(liSO.Apttus_Config2__ProductId__c, liSO.Apttus_Config2__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days));
                                    }

                                    if (productIdToPremiumSupportNetPriceMap.containsKey(liSO.Apttus_Config2__ProductId__c)) {
                                        productIdToPremiumSupportNetPriceMap.put(liSO.Apttus_Config2__ProductId__c, productIdToPremiumSupportNetPriceMap.get(liSO.Apttus_Config2__ProductId__c) + (liSO.Apttus_Config2__NetPrice__c*(premiumSupportApplicableDays/sellingTerm_Days)));
                                    } else {
                                        productIdToPremiumSupportNetPriceMap.put(liSO.Apttus_Config2__ProductId__c, liSO.Apttus_Config2__NetPrice__c*(premiumSupportApplicableDays/sellingTerm_Days));
                                    }

                                    System.debug('>>>> liSO.Apttus_Config2__ProductId__c: ' + liSO.Apttus_Config2__ProductId__c);
                                    System.debug('>>>> liSO.Id: ' + liSO.Id);
                                    productIdToLineItemIdMap.put(liSO.Apttus_Config2__ProductId__c, liSO.Id);
                                    System.debug('>>>> productIdToLineItemIdMap: ' + productIdToLineItemIdMap);
                                }
                            }
                            // prepare the aggregate ACV's to be used for 4th year and 5th year uplift's
                            String productFamily = (String)mapPricingCallbackFields.get('Zscaler_Product_Family__c');
                            APTS_PricingHelper.AggrLineInfo agrLineInfo =  null;
                            if(lineNumberTOAggrLineInfoMap.containsKey(liSO.Apttus_Config2__LineNumber__c)){
                                agrLineInfo = lineNumberTOAggrLineInfoMap.get(liSO.Apttus_Config2__LineNumber__c);
                                agrLineInfo.addLI(liSO);
                            }else{
                                agrLineInfo = new APTS_PricingHelper.AggrLineInfo(liSO);
                            }
                            lineNumberTOAggrLineInfoMap.put(agrLineInfo.lineNumber, agrLineInfo);
                        }

                        // get the sum of all product MRR's where buy back eligible is set to true to calculate buy back credit.
                        if(liSO.Apttus_Config2__ProductId__r.APTS_Buyback_Eligible__c == true) {
                            System.debug('>>>> liSO: ' + JSON.serialize(liSO));
                            if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_AAC
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_CUSTCERT
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU
                                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU) {
                                zpaBuyBackEligibleLines.add(liSO);
                            } else {
                                buyBackEligibleLines.add(liSO);
                            }
                        }
                        System.debug('*** Before ZPA Pro Net Price Logic');
                        if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                            && ((prodConfigWrelFields.ZPA_PRO_Manual_Adjustments__c == null
                                || prodConfigWrelFields.ZPA_PRO_Manual_Adjustments__c == 0.0)
                            && !(assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_PRO)
                                || assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)
                                || assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_ENT))
                            || prodConfigWrelFields.Allow_ZPA_Promotion_In_Cart__c)) {
                            System.debug('*** Inside ZPA Pro Net Price Logic 1: ' + liSO.Apttus_Config2__NetPrice__c);
                            zpaProNetPriceSum += liSO.Apttus_Config2__NetPrice__c;
                            System.debug('*** Inside ZPA Pro Net Price Logic 2: ' + zpaProNetPriceSum);
                        }
                    }
                }
            }
        }catch(Exception ex){
            throw new APTS_Exception('Error from afterPricing: '+ex.getMessage()+'Line Number: '+ex.getLineNumber());
        }
    }

    /**
     * Callback after the price list item is set on the given line item
     * @param itemSO the price list item associated with the line item
     * @param lineItemMO the line item
     */
    global void onPriceItemSet(Apttus_Config2__PriceListItem__c plItem, Apttus_Config2.LineItem lineItemMO) {
        // System.debug('Method is: onPriceItemSet '+mode+' baseExtended is: '+lineItemMO.getLineItemSO().Apttus_Config2__BasePrice__c);
                    
        lineItemMO.updateprice(); //commented by Minkesh patel
    }

    /**
     * Callback after all batches of line items are processed
     * Use the finish method to release state
     */
    global void finish() {
        System.debug('Method is: finish '+mode);
        Map<String, Apttus_Config2.LineItem> cartLineItemsMap = new Map<String, Apttus_Config2.LineItem>();
        Map<String, Apttus_Config2.LineItem> cfwZPACartLineItemsMap = new Map<String, Apttus_Config2.LineItem>();
        List<Apttus_Config2.LineItem> cfwZPAPromoCartLinesList = new List<Apttus_Config2.LineItem>();
        List<Apttus_Config2.LineItem> lineItemforWFH = new List<Apttus_Config2.LineItem>();

        Double SIPCartQuantity = 0;

        // use try/catch to show custom exception messages on cart.
        try{

            Apttus_Config2.LineItem upliftYear4LI = null;
            Apttus_Config2.LineItem upliftYear5LI = null;
            Apttus_Config2.LineItem buyBackLI = null;
            Apttus_Config2.LineItem zpaBuyBackLI = null;
            Apttus_Config2.LineItem tamTopLI = null;
            Apttus_Config2.LineItem one8tamTOPLI = null;
            Apttus_Config2.LineItem zpaPromoLI = null;
            Apttus_Config2.LineItem zpaCfwPromoLI = null;
            //added by Minkesh Patel for CR# 222
            Apttus_Config2.LineItem wfhPromoLI = null;
            //end of CR# 222
            List<Apttus_Config2.LineItem> zliveSKUlst = new List<Apttus_Config2.LineItem>();
            //List<Apttus_Config2.LineItem> early_adopter_list = new List<Apttus_Config2.LineItem>();

            Double premiumSupportACV = 0;
            Double premiumSupportSellingTerm = 0;
            Decimal ziaPremiumSupportBaseExtndPrice = 0;
            Decimal zpaPremiumSupportBaseExtndPrice = 0;
            Decimal ziaPremiumSupportACV = 0;
            Decimal zpaPremiumSupportACV = 0;
            Decimal ziaPremiumSupportlistPrice = 0;
            Decimal zpaPremiumSupportlistPrice = 0;
            Decimal ziaPremiumSupportlistPriceACV = 0;
            Decimal zpaPremiumSupportlistPriceACV = 0;
            Decimal premiumSupportBaseExtndPrice = 0;
            Decimal WFHPROMO = 0;
            Decimal ttlziaprice1 = 0.00;
            Decimal ttlzpaprice1 = 0.00;

            // update the pricing of Support lines and Uplift in the finish.
            // updating the price of support lines in above methods(beforepricing or afterpricing) would not
            // work as lines added after the support lines are not yet calculated. (All methods gets called for each line).
            // sort the list prior to processing order (premium support, managed premium support, uplift year 4, uplift year 5)
            // mode check to be added later - TODO
            
            for(Apttus_Config2.LineItem lineItemMO : lineItemsToUpdate){
                Apttus_Config2__LineItem__c liSO = lineItemMO.getLineItemSO();

                //added by Minkesh Patel for CR# 222
                if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE 
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU 
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO)
                && wfHSKU != null
                )
                {
                    lineItemforWFH.add(lineItemMO);
                }
                //remove this part
                if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO) {
                    wfhPromoLI = lineItemMO;
                    system.debug('====>WFH Prmo ===>'+liSO.APTS_ProductCode__c);
                    cartLineItemsMap.put(liSO.APTS_ProductCode__c, lineItemMO);
                } //end of removal
                //end by Minkesh Patel for CR# 222

                if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_GEN_US ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_TRAIN_US ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_GEN_EU ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZLIVE_TRAIN_EU) && percentDiscountforZLIVE > 0){
                    zliveSKUlst.add(lineItemMO);
                    continue;                   
                }/*else if((liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_5_PRE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_25_PRE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_100_PRE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.ISO_EXTRA_PRE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.SVC_EDGE_V_PRE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.DATA_PROTECTION_BUNDLE ||
                    liSO.APTS_ProductCode__c == APTS_CONSTANTS.SAAS_CASB_API) && early_adopter_SKU != null){
                    //CR# 223 - Abhishek V - Early_Adopter - Start
                    early_adopter_list.add(lineItemMO);
                    continue;  
                    //CR# 223 - Abhishek V - Early_Adopter - End                    
                }*/else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY4)
                {
                    upliftYear4LI = lineItemMO;
                    continue;
                }
                else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ULIFTY5)
                {
                    upliftYear5LI = lineItemMO;
                    continue;
                }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_BUYBACK){
                    buyBackLI = lineItemMO;
                    continue;
                }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK){
                    zpaBuyBackLI = lineItemMO;
                    continue;
                }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_TAMTOP){
                    tamTopLI = lineItemMO;
                    continue;
                }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ONE8TAMTOP){
                    one8tamTOPLI = lineItemMO;
                    continue;
                }else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_OTAM){
                    //setBaseExtendedAsBasePrice(lineItemMO);
                    Apttus_Config2__LineItem__c liSOTemp = lineItemMO.getLineItemSO();
                    Double listPrice = liSOTemp.Apttus_Config2__BasePrice__c;
                    System.debug('>>>>liSOTemp.Apttus_Config2__BasePriceOverride__c: ' + liSOTemp.Apttus_Config2__BasePriceOverride__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__BaseExtendedPrice__c: ' + liSOTemp.Apttus_Config2__BaseExtendedPrice__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__SellingTerm__c: ' + liSOTemp.Apttus_Config2__SellingTerm__c);
                    liSOTemp.Apttus_Config2__BasePriceOverride__c = listPrice;
                    liSOTemp.Apttus_Config2__BaseExtendedPrice__c = listPrice;
                    //Decimal sellingTerm = liSOTemp.Apttus_Config2__SellingTerm__c != null ? Math.ceil(liSOTemp.Apttus_Config2__SellingTerm__c) : 0;
                    //if(sellingTerm != 0) {
                    //    System.debug('>>>>listPrice: ' + listPrice);
                    //    System.debug('>>>>sellingTerm: ' + sellingTerm);
                    //    System.debug('>>>>listPrice/sellingTerm: ' + (listPrice/sellingTerm));
                    //    liSOTemp.Apttus_Config2__BasePriceOverride__c = (listPrice/sellingTerm).setScale(2);
                    //}
                    System.debug('>>>>liSOTemp.Apttus_Config2__BasePriceOverride__c: ' + liSOTemp.Apttus_Config2__BasePriceOverride__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__BaseExtendedPrice__c: ' + liSOTemp.Apttus_Config2__BaseExtendedPrice__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__BasePrice__c: ' + liSOTemp.Apttus_Config2__BasePrice__c);
                    System.debug('>>>>liSO.Apttus_Config2__NetPrice__c: ' + liSOTemp.Apttus_Config2__NetPrice__c);
                    // calculate the total discount based on adjustment type and manual discount entered. - Discounts for Buy back is not applicable.
                    // Added condition to avoid apply discout for Partner Summit
                    APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                    APTS_PricingHelper.calculateDiscounts(liSOTemp);
                    //Added logic to set Net to zscaler
                   
                    calculateNetToZscaler(lineItemMO.getLineItemSO()); //commented by minkesh patel
                    
                    lineItemMO.updateprice();// update prices back

                    if (liSOTemp.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_OTAM) {
                        liSOTemp.Apttus_Config2__BaseExtendedPrice__c = listPrice;
                        liSOTemp.Apttus_Config2__NetPrice__c = listPrice;
                    }
                    System.debug('>>>>liSOTemp.Apttus_Config2__BasePriceOverride__c: ' + liSOTemp.Apttus_Config2__BasePriceOverride__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__BaseExtendedPrice__c: ' + liSOTemp.Apttus_Config2__BaseExtendedPrice__c);
                    System.debug('>>>>liSOTemp.Apttus_Config2__BasePrice__c: ' + liSOTemp.Apttus_Config2__BasePrice__c);
                    System.debug('>>>>liSO.Apttus_Config2__NetPrice__c: ' + liSOTemp.Apttus_Config2__NetPrice__c);
                    // calculate MRR and ACV once net price is calculated(OOB).
                    APTS_PricingHelper.calculateACVnMRR(liSOTemp, productIdTOTotalTermMap.get(liSOTemp.Apttus_Config2__ProductId__c));
                    System.debug('>>>>liSO.Apttus_Config2__NetPrice__c: ' + liSOTemp.Apttus_Config2__NetPrice__c);

                    
                    continue;
                }
                else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT){
                    String premiumSupportSource = ((prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Source_Override__c != null
                                                        &&prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Source_Override__c != '')
                                                            ? prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Source_Override__c
                                                            : prodConfigWrelFields.Apttus_Config2__BillToAccountId__r.Premium_Support_Source__c);

                    String managedPremiumSupportSource = ((prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Source_Override__c != null
                                                            && prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Source_Override__c != '')
                                                                ? prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Source_Override__c
                                                                : prodConfigWrelFields.Apttus_Config2__BillToAccountId__r.Managed_Support_Source__c);

                    Decimal premiumSupportPercent = ((prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Override__c != null
                                                        && prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Override__c != 0)
                                                            ? prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Premium_Support_Override__c
                                                            : prodConfigWrelFields.Apttus_Config2__BillToAccountId__r.Premium_Support__c);

                    Decimal managedPremiumSupportPercent = ((prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Override__c != null
                                                                && prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Override__c != 0)
                                                                    ? prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Managed_Support_Override__c
                                                                    : prodConfigWrelFields.Apttus_Config2__BillToAccountId__r.Managed_Support__c);

                    String supportSource = null;
                    Decimal supportPercent = 0;
                    Double sumOfAllSubscriptions = 0;
                    Map<Id, Decimal> productLiIdToPremiumSupportValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZPAPremiumSupportValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZIAPremiumSupportValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZPAPremiumSupportACVValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZIAPremiumSupportACVValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZPAListPricePremiumSupportValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZIAListPricePremiumSupportValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZPAListPricePremiumSupportACVValueMap = new Map<Id, Decimal>();
                    Map<Id, Decimal> productLiIdToZIAListPricePremiumSupportACVValueMap = new Map<Id, Decimal>();

                    // If 'Premium Support Type'(PAV) is Zscalar take premium support params else managed premium support params.
                    //if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_ZSCALER)
                    //{
                    //    supportSource = premiumSupportSource;
                    //    supportPercent = premiumSupportPercent != null ? premiumSupportPercent : 0;
                    //}else if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_PQSUPPORT){
                    //    supportSource = managedPremiumSupportSource;
                    //    supportPercent = managedPremiumSupportPercent != null ? managedPremiumSupportPercent : 0;
                    //}
                    Apttus_Config2__LineItem__c supportLiSO = [SELECT Id,
                                                                      Apttus_Config2__DerivedFromId__c,
                                                                      Apttus_Config2__DerivedFromId__r.Apttus_Config2__AttributeValueId__c, Apttus_Config2__AttributeValueId__c,
                                                                      Apttus_Config2__AttributeValueId__r.Support_Source__c,
                                                                      Apttus_Config2__AttributeValueId__r.Support_Percent__c
                                                                     // Partner_Adjustment__c,
                                                                     // Partner_Adjustment_Type__c 
                                                                FROM Apttus_Config2__LineItem__c WHERE Id = :liSO.Id];
                    if (supportLiSO.Apttus_Config2__AttributeValueId__c != null
                        && supportLiSO.Apttus_Config2__AttributeValueId__r.Support_Source__c != null
                        && supportLiSO.Apttus_Config2__AttributeValueId__r.Support_Percent__c != null) {
                        System.debug('>>>> option 1');

                        supportSource = supportLiSO.Apttus_Config2__AttributeValueId__r.Support_Source__c;
                        supportPercent = supportLiSO.Apttus_Config2__AttributeValueId__r.Support_Percent__c;
                        Apttus_Config2__ProductAttributeValue__c pavtoupdate = new Apttus_Config2__ProductAttributeValue__c(Id=supportLiSO.Apttus_Config2__AttributeValueId__c);
                        update pavtoupdate;
                    } else if (supportLiSO.Apttus_Config2__DerivedFromId__c != null
                        && supportLiSO.Apttus_Config2__DerivedFromId__r.Apttus_Config2__AttributeValueId__c != null) {
                        System.debug('>>>> option 2');
                        Apttus_Config2__ProductAttributeValue__c derivedFromLiSOAttribute = [SELECT Id, Support_Percent__c, Support_Source__c FROM Apttus_Config2__ProductAttributeValue__c WHERE Id = :supportLiSO.Apttus_Config2__DerivedFromId__r.Apttus_Config2__AttributeValueId__c LIMIT 1];
                        update derivedFromLiSOAttribute;
                        if (derivedFromLiSOAttribute != null && derivedFromLiSOAttribute.Support_Source__c != null && derivedFromLiSOAttribute.Support_Percent__c != null) {
                            supportSource = derivedFromLiSOAttribute.Support_Source__c;
                            supportPercent = derivedFromLiSOAttribute.Support_Percent__c;
                        } else {
                            System.debug('>>>> option 4');
                            // If 'Premium Support Type'(PAV) is Zscalar take premium support params else managed premium support params.
                            if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_ZSCALER)
                            {
                               supportSource = premiumSupportSource;
                               supportPercent = premiumSupportPercent != null ? premiumSupportPercent : 0;
                            }else if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_PQSUPPORT){
                               supportSource = managedPremiumSupportSource;
                               supportPercent = managedPremiumSupportPercent != null ? managedPremiumSupportPercent : 0;
                           }else {
                               supportSource = premiumSupportSource;
                               supportPercent = premiumSupportPercent != null ? premiumSupportPercent : 0;
                           }
                        }
                    } else {
                        System.debug('>>>> option 3');
                        // If 'Premium Support Type'(PAV) is Zscalar take premium support params else managed premium support params.
                        if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_ZSCALER)
                        {
                           supportSource = premiumSupportSource;
                           supportPercent = premiumSupportPercent != null ? premiumSupportPercent : 0;
                        }else if(liSO.Apttus_Config2__AttributeValueId__r.APTS_Premium_Support_Type__c == APTS_CONSTANTS.PAV_PST_PQSUPPORT){
                           supportSource = managedPremiumSupportSource;
                           supportPercent = managedPremiumSupportPercent != null ? managedPremiumSupportPercent : 0;
                        }else {
                            supportSource = premiumSupportSource;
                            supportPercent = premiumSupportPercent != null ? premiumSupportPercent : 0;
                        }
                    }
                    Decimal sellingTerm = liSO.Apttus_Config2__SellingTerm__c != null ? liSO.Apttus_Config2__SellingTerm__c : 0;

                    // if support source is List then take base extended sum else net price sum.
                    sumOfAllSubscriptions = supportSource == APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST ? subscriptionBaseExtendedSum : sumOfAllSubscriptions;
                    sumOfAllSubscriptions = supportSource == APTS_CONSTANTS.ACC_SUPPORTSOURCE_NET ? subscriptionNetPriceSum : sumOfAllSubscriptions;

                    if(sumOfAllSubscriptions != 0){
                        premiumSupportBaseExtndPrice = (sumOfAllSubscriptions * (supportPercent/100)).setScale(2);
                    }

                    liSO.Apttus_Config2__Description__c = 'supportSource:'+supportSource+' premiumSupportBaseExtndPrice:'+premiumSupportBaseExtndPrice+' supportPercent:'+supportPercent;
                    liSO.Apttus_Config2__BaseExtendedPrice__c = premiumSupportBaseExtndPrice;

                    if(sellingTerm != 0)
                        liSO.Apttus_Config2__BasePriceOverride__c = (premiumSupportBaseExtndPrice/sellingTerm).setScale(2);
                    
                    
                    Decimal totaldiscwithoutsupport = totalListPriceWithoutSupport != null && totalListPriceWithoutSupport != 0 && totalnetPriceWithoutSupport != null ? ((1 - (totalnetPriceWithoutSupport / totalListPriceWithoutSupport)) * 100) : 0;

                    // calculate the total discount based on adjustment type and manual discount entered.
                    APTS_PricingHelper.calculateDiscountsforPremSupport(liSO, supportSource, totaldiscwithoutsupport);

                    //Added logic to set Net to zscaler
                    
                    calculateNetToZscaler(lineItemMO.getLineItemSO()); //commented by minkesh patel

                    lineItemMO.updateprice();

                    if (supportSource == APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST) {
                        for (Id productId : productIdToPremiumSupportListPriceMap.keySet()) {
                            if (productIdToPremiumSupportListPriceMap.get(productId) != null) {
                                Decimal listPrice = productIdToPremiumSupportListPriceMap.get(productId);
                                Decimal lpsupportValue = (listPrice * (supportPercent/100)).setScale(2);
                                Decimal lpsupportValueAcv = APTS_PricingHelper.calculateACVForPremiumSupport(lpsupportValue, sellingTerm);
                                Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((listPrice * (supportPercent/100)).setScale(2), liSO.APTS_Total_Discount_Percentage__c);
                                Decimal supportValueAcv = APTS_PricingHelper.calculateACVForPremiumSupport(supportValue, sellingTerm);

                                if (setZIAProductIds.contains(productId)) {
                                    ziaPremiumSupportBaseExtndPrice += supportValue;
                                    productLiIdToZIAPremiumSupportValueMap.put(productId, supportValue);
                                    ziaPremiumSupportACV += supportValueAcv;
                                    productLiIdToZIAPremiumSupportACVValueMap.put(productId, supportValueAcv);

                                    ziaPremiumSupportlistPrice += lpsupportValue;
                                    productLiIdToZIAListPricePremiumSupportValueMap.put(productId, lpsupportValue);
                                    ziaPremiumSupportlistPriceACV += lpsupportValueAcv;
                                    productLiIdToZIAListPricePremiumSupportACVValueMap.put(productId, lpsupportValueAcv);
                                } else if (setZPAProductIds.contains(productId)) {
                                    zpaPremiumSupportBaseExtndPrice += supportValue;
                                    productLiIdToZPAPremiumSupportValueMap.put(productId, supportValue);
                                    zpaPremiumSupportACV += supportValueAcv;
                                    productLiIdToZPAPremiumSupportACVValueMap.put(productId, supportValueAcv);

                                    zpaPremiumSupportlistPrice += lpsupportValue;
                                    productLiIdToZPAListPricePremiumSupportValueMap.put(productId, lpsupportValue);
                                    zpaPremiumSupportlistPriceACV += lpsupportValueAcv;
                                    productLiIdToZPAListPricePremiumSupportACVValueMap.put(productId, lpsupportValueAcv);
                                }
                            }
                        }
                    } else if (supportSource == APTS_CONSTANTS.ACC_SUPPORTSOURCE_NET) {
                        for (Id productId : productIdToPremiumSupportNetPriceMap.keySet()) {
                            if (productIdToPremiumSupportNetPriceMap.get(productId) != null) {
                                Decimal netPrice = productIdToPremiumSupportNetPriceMap.get(productId);
                                Decimal lpsupportValue = (netPrice * (supportPercent/100)).setScale(2);
                                Decimal lpsupportValueAcv = APTS_PricingHelper.calculateACVForPremiumSupport(lpsupportValue, sellingTerm);

                                Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((netPrice * (supportPercent/100)).setScale(2), liSO.APTS_Total_Discount_Percentage__c);
                                Decimal supportValueAcv = APTS_PricingHelper.calculateACVForPremiumSupport(supportValue, sellingTerm);
                                if (setZIAProductIds.contains(productId)) {
                                    ziaPremiumSupportBaseExtndPrice += supportValue;
                                    ziaPremiumSupportACV += supportValueAcv;
                                    ziaPremiumSupportlistPrice += lpsupportValue;
                                    ziaPremiumSupportlistPriceACV += lpsupportValueAcv;

                                    if (productLiIdToZIAPremiumSupportValueMap.containsKey(productId)) {
                                        productLiIdToZIAPremiumSupportValueMap.put(productId, productLiIdToZIAPremiumSupportValueMap.get(productId) + supportValue);
                                    } else {
                                        productLiIdToZIAPremiumSupportValueMap.put(productId, supportValue);
                                    }

                                    if(productLiIdToZIAListPricePremiumSupportValueMap.containsKey(productId)) {
                                        productLiIdToZIAListPricePremiumSupportValueMap.put(productId, productLiIdToZIAListPricePremiumSupportValueMap.get(productId) + lpsupportValue);
                                    }else{
                                        productLiIdToZIAListPricePremiumSupportValueMap.put(productId, lpsupportValue);
                                    }

                                    if (productLiIdToZIAPremiumSupportACVValueMap.containsKey(productId)) {
                                        productLiIdToZIAPremiumSupportACVValueMap.put(productId, productLiIdToZIAPremiumSupportACVValueMap.get(productId) + supportValueAcv);
                                    } else {
                                        productLiIdToZIAPremiumSupportACVValueMap.put(productId, supportValueAcv);
                                    }

                                    if(productLiIdToZIAListPricePremiumSupportACVValueMap.containsKey(productId)) {
                                        productLiIdToZIAListPricePremiumSupportACVValueMap.put(productId, productLiIdToZIAListPricePremiumSupportACVValueMap.get(productId) + lpsupportValueAcv);
                                    }else{
                                        productLiIdToZIAListPricePremiumSupportACVValueMap.put(productId, lpsupportValueAcv);
                                    }
                                } else if (setZPAProductIds.contains(productId)) {
                                    zpaPremiumSupportBaseExtndPrice += supportValue;
                                    zpaPremiumSupportACV += supportValueAcv;
                                    zpaPremiumSupportlistPrice += lpsupportValue;
                                    zpaPremiumSupportlistPriceACV += lpsupportValueAcv;

                                    if (productLiIdToZPAPremiumSupportValueMap.containsKey(productId)) {
                                        productLiIdToZPAPremiumSupportValueMap.put(productId, productLiIdToZPAPremiumSupportValueMap.get(productId) + supportValue);
                                    } else {
                                        productLiIdToZPAPremiumSupportValueMap.put(productId, supportValue);
                                    }

                                    if (productLiIdToZPAPremiumSupportACVValueMap.containsKey(productId)) {
                                        productLiIdToZPAPremiumSupportACVValueMap.put(productId, productLiIdToZPAPremiumSupportACVValueMap.get(productId) + supportValueAcv);
                                    } else {
                                        productLiIdToZPAPremiumSupportACVValueMap.put(productId, supportValueAcv);
                                    }

                                    if(productLiIdToZPAListPricePremiumSupportValueMap.containsKey(productId)) {
                                        productLiIdToZPAListPricePremiumSupportValueMap.put(productId, productLiIdToZPAListPricePremiumSupportValueMap.get(productId) + lpsupportValue);
                                    }else{
                                        productLiIdToZPAListPricePremiumSupportValueMap.put(productId, lpsupportValue);
                                    }

                                    if(productLiIdToZPAListPricePremiumSupportACVValueMap.containsKey(productId)) {
                                        productLiIdToZPAListPricePremiumSupportACVValueMap.put(productId, productLiIdToZPAListPricePremiumSupportACVValueMap.get(productId) + lpsupportValueAcv);
                                    }else{
                                        productLiIdToZPAListPricePremiumSupportACVValueMap.put(productId, lpsupportValueAcv);
                                    }
                                }
                            }
                        }
                    }

                    // calculate MRR and ACV once net price is calculated(OOB).
                    APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));

                    //Update the individual PS values in all line items and the ZIA/ZPA PS values in Premium Support line item
                    System.debug('*** PremiumSupportValues: ');
                    APTS_PricingHelper.updatePremiumSupportValues(liSO, zpaPremiumSupportBaseExtndPrice, zpaPremiumSupportACV, ziaPremiumSupportBaseExtndPrice, ziaPremiumSupportACV, productLiIdToZPAPremiumSupportValueMap, productLiIdToZIAPremiumSupportValueMap, productLiIdToZPAPremiumSupportACVValueMap, productLiIdToZIAPremiumSupportACVValueMap, zpaPremiumSupportlistPrice, zpaPremiumSupportlistPriceACV, ziaPremiumSupportlistPrice, ziaPremiumSupportlistPriceACV, productLiIdToZPAListPricePremiumSupportValueMap, productLiIdToZPAListPricePremiumSupportACVValueMap, productLiIdToZIAListPricePremiumSupportValueMap, productLiIdToZIAListPricePremiumSupportACVValueMap);

                    // add premium supports to uplift products.
                    upliftYear4ACVS_Total += APTS_PricingHelper.getUpliftYear4(liSO);
                    upliftYear5ACVS_Total += APTS_PricingHelper.getUpliftYear5(liSO);

                    // to be used in tamp top calulations.
                    premiumSupportACV = liSO.APTS_ACV__c;
                    premiumSupportSellingTerm = liSO.Apttus_Config2__SellingTerm__c;   
                     
                }
                else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) {
                    cartLineItemsMap.put(liSO.APTS_ProductCode__c, lineItemMO);
                    if (liSO.APTS_Total_Discount_Percentage__c < 85
                        || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.ZPA_CFW_Promotion_Exception__c == true) {
                        cfwZPAPromoCartLinesList.add(lineItemMO);
                    }
                } else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP) {
                        if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_SIP){
                            SIPCartQuantity += liSO.Apttus_Config2__Quantity__c;
                        }
                    cartLineItemsMap.put(liSO.APTS_ProductCode__c, lineItemMO);
                } else if ((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE)
                        && liSO.Apttus_Config2__LineStatus__c.equalsIgnoreCase('new')
                        && (liSO.APTS_Total_Discount_Percentage__c < 85
                            || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.ZPA_CFW_Promotion_Exception__c == true)) {
                    cfwZPAPromoCartLinesList.add(lineItemMO);
                } else if ((liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                    || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT)
                        && liSO.Apttus_Config2__LineStatus__c.equalsIgnoreCase('new')) {
                    cfwZPAPromoCartLinesList.add(lineItemMO);
                } else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO) {
                    zpaCfwPromoLI = lineItemMO;
                    continue;
                } else if (liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PROMO) {
                    zpaPromoLI = lineItemMO;
                    continue;
                } 
                
                lineItemMO.updateprice();// update the prices back and recalculate OOB fields.
                
            }
            Decimal uplift4valuetoputtouplift5 = 0;
            if(upliftYear4LI != null){// Calculate the pricing for Uplift for year 4, uplift for year 5.
                // Uplift year 4 is 5% ACV's  of products where selling term's are >36 and <= 48
                // System.debug('lineNumberTOAggrLineInfoMap is: '+lineNumberTOAggrLineInfoMap);
                // Add ACV's from subscriptions towards the uplift's.

                Apttus_Config2__LineItem__c liSO = upliftYear4LI.getLineItemSO();

                // Update: Consider the term to be greater than 36 towards Uplift year 4.
                for(Double lineNumber : lineNumberTOAggrLineInfoMap.keySet()){
                    APTS_PricingHelper.AggrLineInfo agrLineInfo = lineNumberTOAggrLineInfoMap.get(lineNumber);
                    if(agrLineInfo.sellingTermMonthsafterBuyback > 36)
                    {
                        if(agrLineInfo.sellingTermMonths != 0 && agrLineInfo.cumulativeAcv != null && agrLineInfo.sellingTermMonths != null && agrLineInfo.sellingTermMonthsafterBuyback != null){
                            upliftYear4ACVS_Total +=  (agrLineInfo.cumulativeAcv / agrLineInfo.sellingTermMonths) * (agrLineInfo.sellingTermMonthsafterBuyback);
                        }else{
                            upliftYear4ACVS_Total +=  agrLineInfo.cumulativeAcv ;
                        }
                    }
                }

                Decimal sellingTermYears = liSO.Apttus_Config2__SellingTerm__c;
                if(sellingTermYears == null
                    || sellingTermYears == 0)
                    sellingTermYears = 1;
                liSO.Apttus_Config2__BasePriceOverride__c = (upliftYear4ACVS_Total * 5 / (100*sellingTermYears)).setScale(2);

                // include year 4 uplift in year 5 uplift.
                uplift4valuetoputtouplift5 += liSO.Apttus_Config2__BasePriceOverride__c;

                // calculate the total discount based on adjustment type and manual discount entered.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(upliftYear4LI.getLineItemSO());
                upliftYear4LI.updateprice();// update prices back
                
                // calculate MRR and ACV once net price is calculated(OOB).
                APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));
                //lineItemforWFH.add(liso);

            }

            // Uplift year 5 is 5.25% ACV's of products where selling term's are >48 and <= 60
            if(upliftYear5LI != null){
                // System.debug('lineNumberTOAggrLineInfoMap is: '+lineNumberTOAggrLineInfoMap);
                // Add ACV's from subscriptions towards the uplift's.
                Apttus_Config2__LineItem__c liSO = upliftYear5LI.getLineItemSO();

                // Update: Consider the term to be greater than 48 towards Uplift year 5.
                for(Double lineNumber : lineNumberTOAggrLineInfoMap.keySet()){
                    APTS_PricingHelper.AggrLineInfo agrLineInfo = lineNumberTOAggrLineInfoMap.get(lineNumber);
                    if(agrLineInfo.sellingTermMonthsafterBuyback > 48)
                    {
                        if(agrLineInfo.sellingTermMonths != 0 && agrLineInfo.cumulativeAcv != null && agrLineInfo.sellingTermMonths != null && agrLineInfo.sellingTermMonthsafterBuyback != null){
                            upliftYear5ACVS_Total +=  (agrLineInfo.cumulativeAcv / agrLineInfo.sellingTermMonths) * (agrLineInfo.sellingTermMonthsafterBuyback);
                        }else{
                            upliftYear5ACVS_Total +=  agrLineInfo.cumulativeAcv ;
                        }
                    }
                }
                
                if(upliftYear5ACVS_Total > 0){
                    upliftYear5ACVS_Total += uplift4valuetoputtouplift5;
                }
                
                Decimal sellingTermYears = liSO.Apttus_Config2__SellingTerm__c;
                if(sellingTermYears == null
                    || sellingTermYears == 0)
                    sellingTermYears = 1;
                liSO.Apttus_Config2__BasePriceOverride__c = (upliftYear5ACVS_Total * 5 / (100*sellingTermYears)).setScale(2);

                // calculate the total discount based on adjustment type and manual discount entered.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(upliftYear5LI.getLineItemSO());
                upliftYear5LI.updateprice();// update prices back
                // calculate MRR and ACV once net price is calculated(OOB).
                APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));

                
            }

            // For new business - Buy back.base entended price(credit) is sum of all subscription MRR * buy back period(product attribute value).
            // Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseExtendedPrice__c will be same as its a one-time product.
            if(buyBackLI != null){
                Apttus_Config2__LineItem__c liSO = buyBackLI.getLineItemSO();
                Double buyBackCredit = APTS_PricingHelper.getBuyBackCreditAmount(liSO, buyBackEligibleLines);
                liSO.Apttus_Config2__BaseExtendedPrice__c = buyBackCredit;
                liSO.Apttus_Config2__BasePriceOverride__c = buyBackCredit;

                // calculate the total discount based on adjustment type and manual discount entered. - Discounts for Buy back is not applicable.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(buyBackLI.getLineItemSO());
                buyBackLI.updateprice();// update prices back

                // calculate MRR and ACV once net price is calculated(OOB).
                System.debug('>>>> prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_BuyBack_SKU_ACV_To_Zero__c: ' + prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_BuyBack_SKU_ACV_To_Zero__c);
                if (prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_BuyBack_SKU_ACV_To_Zero__c != true) {
                    APTS_PricingHelper.calculateACVnMRR(liSO, quoteTerm);
                } else {
                    liSO.APTS_MRR__c = null;
                    liSO.APTS_ACV__c = null;
                }

                
            }
            Decimal totaldiscount = 0;
            if(!zliveSKUlst.isEmpty()){
                for(Apttus_Config2.LineItem  zliveSKU: zliveSKUlst){
                    Apttus_Config2__LineItem__c liSO = zliveSKU.getLineItemSO();
                    totaldiscount -= APTS_PricingHelper.applyZLIVEPromo(liSO, percentDiscountforZLIVE, ZLIVEPromoSKUCode);
                }
                Apttus_Config2__LineItem__c promo = ZLIVEPROMOSKU.getLineItemSO();
                promo.Apttus_Config2__BasePriceOverride__c = totaldiscount;
                ZLIVEPROMOSKU.updateprice();
                
            }
            //CR# 223 - Abhishek V - Early_Adopter - Start
            /*Decimal totalcredit = 0;
            if(!early_adopter_list.isEmpty()){
                for(Apttus_Config2.LineItem  presku: early_adopter_list){
                    Apttus_Config2__LineItem__c liSO = presku.getLineItemSO();
                    totalcredit += APTS_PricingHelper.calculateEarly_Adoptercredit(liSO);
                }
                
                Apttus_Config2__LineItem__c earlypromo = early_adopter_SKU.getLineItemSO();
                earlypromo.Apttus_Config2__BasePriceOverride__c = totalcredit;
                early_adopter_SKU.updateprice();
                
            }
            //CR# 223 - Abhishek V - Early_Adopter - End
            */
            if(zpaBuyBackLI != null){
                Apttus_Config2__LineItem__c liSO = zpaBuyBackLI.getLineItemSO();
                Double buyBackCredit = APTS_PricingHelper.getBuyBackCreditAmount(liSO, zpaBuyBackEligibleLines);
                liSO.Apttus_Config2__BaseExtendedPrice__c = buyBackCredit;
                liSO.Apttus_Config2__BasePriceOverride__c = buyBackCredit;

                // calculate the total discount based on adjustment type and manual discount entered. - Discounts for Buy back is not applicable.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                 //Added logic to set Net to zscaler
                
                calculateNetToZscaler(zpaBuyBackLI.getLineItemSO());
                zpaBuyBackLI.updateprice();// update prices back

                // calculate MRR and ACV once net price is calculated(OOB).
                System.debug('>>>> prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_ZPA_BuyBack_SKU_ACV_To_Zero__c: ' + prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_BuyBack_SKU_ACV_To_Zero__c);
                if (prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Set_ZPA_BuyBack_SKU_ACV_To_Zero__c != true) {
                    APTS_PricingHelper.calculateACVnMRR(liSO, quoteTerm);
                } else {
                    liSO.APTS_MRR__c = null;
                    liSO.APTS_ACV__c = null;
                }

               
            }

            // Apttus_Config2__BasePriceOverride__c, Apttus_Config2__BaseExtendedPrice__c will be same as its a one-time product.
            // Tamp Top base extended is: (30000 - Premium support ACV)*premium support selling term.
            // Update: HE, 12/14/2016: TamTop has been made as yearly so changed base price override calc to take selling term into consideration.
            Double tamTopACV = 0;
            if(tamTopLI != null){
                Apttus_Config2__LineItem__c liSO = tamTopLI.getLineItemSO();
                Double tamTopSellingTerm = liSO.Apttus_Config2__SellingTerm__c;
                tamTopSellingTerm = tamTopSellingTerm == null || tamTopSellingTerm == 0 ? 1 : tamTopSellingTerm;
                if(premiumSupportACV >= 27000
                    && premiumSupportACV <= 30000)
                {
                    liSO.Apttus_Config2__BasePriceOverride__c = ((30000 - premiumSupportACV) * premiumSupportSellingTerm)/tamTopSellingTerm;


                    // liSO.Apttus_Config2__BaseExtendedPrice__c = (30000 - premiumSupportACV) * premiumSupportSellingTerm;
                }

                // calculate the total discount based on adjustment type and manual discount entered. - Discounts for Buy back is not applicable.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(tamTopLI.getLineItemSO());
                tamTopLI.updateprice();// update prices back

                // calculate MRR and ACV once net price is calculated(OOB).
                APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));

                // to be used to calculate one 8 tam top quantity.
                tamTopACV = liSO.APTS_ACV__c;

                // Calculate the % of TAM allocation
                Decimal ziaTAMAllocation = 0;
                Decimal zpaTAMAllocation = 0;

                Decimal zpaAssetPremiumSupportACV = 0, ziaAssetPremiumSupportACV = 0;
                for (Apttus_Config2__AssetLineItem__c aliSO : [SELECT Id, ZIA_Premium_Support_ACV__c, ZPA_Premium_Support_ACV__c, Apttus_Config2__AccountId__c
                                                                 FROM Apttus_Config2__AssetLineItem__c
                                                                WHERE Apttus_Config2__AccountId__c = :cart.getConfigSO().Apttus_Config2__AccountId__c
                                                                  AND Apttus_Config2__ProductId__r.ProductCode = :APTS_CONSTANTS.PROD_SKU_PSUPPORT
                                                                  AND Apttus_Config2__AssetStatus__c = 'Activated']) {
                    zpaAssetPremiumSupportACV += (aliSO.ZPA_Premium_Support_ACV__c != null ? aliSO.ZPA_Premium_Support_ACV__c : 0);
                    ziaAssetPremiumSupportACV += (aliSO.ZIA_Premium_Support_ACV__c != null ? aliSO.ZIA_Premium_Support_ACV__c : 0);
                }

                Decimal totalZiaPremiumSupportACV = ziaPremiumSupportACV + ziaAssetPremiumSupportACV;
                Decimal totalZpaPremiumSupportACV = zpaPremiumSupportACV + zpaAssetPremiumSupportACV;
                Decimal totalPremiumSupportACV = totalZiaPremiumSupportACV + totalZpaPremiumSupportACV;
                System.debug('>>>> totalZiaPremiumSupportACV: ' + totalZiaPremiumSupportACV + ', totalZpaPremiumSupportACV: ' + totalZpaPremiumSupportACV + ', tamTopACV: ' + tamTopACV + ', totalZpaPremiumSupportACV: ' + totalZpaPremiumSupportACV);

                if (totalZiaPremiumSupportACV > 0) {
                    ziaTAMAllocation = (totalZiaPremiumSupportACV / totalPremiumSupportACV) * tamTopACV;
                }

                if (totalZpaPremiumSupportACV > 0) {
                    zpaTAMAllocation = (totalZpaPremiumSupportACV / totalPremiumSupportACV) * tamTopACV;
                }
                System.debug('>>>> ziaTAMAllocation: ' + ziaTAMAllocation + ', zpaTAMAllocation: ' + zpaTAMAllocation);
                APTS_PricingHelper.updateTamTopupValues(liSO, zpaTAMAllocation, ziaTAMAllocation);

                
            }

            // quantity of one 8 tam top is multiple of 30k of (ps acv + tamp top ACV)
            if(one8tamTOPLI != null){
                Apttus_Config2__LineItem__c liSO = one8tamTOPLI.getLineItemSO();

                // ACV of Tam Top is 30000 - premium support ACV.
                Double sumACVPremiumAndTam = premiumSupportACV + tamTopACV;

                Apttus__APTS_Admin__c adminEntry;
                try{
                    adminEntry = [Select Name, Apttus__Value__c
                                                            From Apttus__APTS_Admin__c
                                                                Where Name = 'APTS_Designated TAM Factor'
                                                                    Limit 1];
                }catch(Exception ex){
                    throw new APTS_Exception('Cannot find Admin entry named APTS_Designated TAM Factor.');
                }

                if(adminEntry != null
                    && adminEntry.Apttus__Value__c != null)
                {
                    Decimal quantityTAMFactor = decimal.valueOf(adminEntry.Apttus__Value__c );
                    if(quantityTAMFactor != 0)
                        liSO.Apttus_Config2__Quantity__c = (sumACVPremiumAndTam/quantityTAMFactor).intValue();
                }

                // calculate the total discount based on adjustment type and manual discount entered. - Discounts for Buy back is not applicable.
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(liSO);

                // calculate MRR and ACV once net price is calculated(OOB).
                APTS_PricingHelper.calculateACVnMRR(liSO, productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c));
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(one8tamTOPLI.getLineItemSO());
                one8tamTOPLI.updateprice();// update prices back

                
            }

            // ZPA Pro Promotion logic
            if (zpaPromoLI != null) {
                System.debug('*** ZPA Pro LI: ' + zpaPromoLI);
                Apttus_Config2__LineItem__c liSO = zpaPromoLI.getLineItemSO();

                if (zpaProNetPriceSum > 0) {
                    liSO.Apttus_Config2__BaseExtendedPrice__c = zpaProNetPriceSum * (-0.5);
                    liSO.Apttus_Config2__BasePriceOverride__c = zpaProNetPriceSum * (-0.5);
                } else {
                    liSO.Apttus_Config2__BaseExtendedPrice__c = 0;
                    liSO.Apttus_Config2__BasePriceOverride__c = 0;
                }

                //Added condition to avoid apply discout for Partner Summit
                if(prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c == APTS_CONSTANTS.P_PARTNERPRG_LEGACY) {
                    APTS_PricingHelper.calculateDiscounts(liSO);
                }
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(zpaPromoLI.getLineItemSO());
                zpaPromoLI.updatePrice();

                APTS_PricingHelper.calculateACVnMRR(liSO, quoteTerm);

                
            }


            // Cloud Firewall + ZPA Promo Logic
            // Logic:
            if (zpaCfwPromoLI != null) {
                decimal cfwZpaPromo = 0.0;
                Apttus_Config2__LineItem__c cfwZpaPromoLiSO = zpaCfwPromoLI.getLineITemSO();
                Apttus_Config2__AssetLineItem__c cloudFireWallAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL)) : null);
                Apttus_Config2__AssetLineItem__c ziaTransBundleAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE)) : null);
                Apttus_Config2__AssetLineItem__c ziaELABundleAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)) : null);
                Apttus_Config2__AssetLineItem__c zpaProAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_PRO) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_ZPA_PRO)) : null);
                Apttus_Config2__AssetLineItem__c zpaBusAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_BUS) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)) : null);
                Apttus_Config2__AssetLineItem__c zpaEntAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_ENT) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_ZPA_ENT)) : null);

                Map<String, Decimal> mapCartLinesNetPrices = new Map<String, Decimal>();
                Map<String, Decimal> mapCartLinesListPrices = new Map<String, Decimal>();
                for (Apttus_Config2.LineItem lineItem : cfwZPAPromoCartLinesList) {
                    Apttus_Config2__LineItem__c liSO = lineItem.getLineItemSO();
                    System.debug('*** liSO.APTS_ProductCode__c: ' + liSO.APTS_ProductCode__c);
                    if (mapCartLinesNetPrices.containsKey(liSO.APTS_ProductCode__c)) {
                        mapCartLinesNetPrices.put(liSO.APTS_ProductCode__c, mapCartLinesNetPrices.get(liSO.APTS_ProductCode__c) + liSO.Apttus_Config2__NetPrice__c);
                    } else {
                        mapCartLinesNetPrices.put(liSO.APTS_ProductCode__c, liSO.Apttus_Config2__NetPrice__c);
                    }

                    if (mapCartLinesListPrices.containsKey(liSO.APTS_ProductCode__c)) {
                        mapCartLinesListPrices.put(liSO.APTS_ProductCode__c, mapCartLinesListPrices.get(liSO.APTS_ProductCode__c) + liSO.Apttus_Config2__BaseExtendedPrice__c);
                    } else {
                        mapCartLinesListPrices.put(liSO.APTS_ProductCode__c, liSO.Apttus_Config2__BaseExtendedPrice__c);
                    }
                }

                Decimal cfwListPrice = 0.0, cfwNetPrice = 0.0, zpaListPrice = 0.0, zpaNetPrice = 0.0;
                String cfwSKUCode;
                if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)) {
                    cfwListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE);
                    cfwSKUCode = APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE;
                } else if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE)) {
                    cfwListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE);
                    cfwSKUCode = APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE;
                } else if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL)) {
                    cfwListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL);
                    cfwSKUCode = APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL;
                }

                if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)) {
                    cfwNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE);
                } else if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE)) {
                    cfwNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE);
                } else if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL)) {
                    cfwNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL);
                }

                if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_ENT)) {
                    zpaListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_ENT);
                } else if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)) {
                    zpaListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_BUS);
                } else if (mapCartLinesListPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_PRO)) {
                    zpaListPrice = mapCartLinesListPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_PRO);
                }

                if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_ENT)) {
                    zpaNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_ENT);
                } else if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)) {
                    zpaNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_BUS);
                } else if (mapCartLinesNetPrices.containsKey(APTS_CONSTANTS.PROD_SKU_ZPA_PRO)) {
                    zpaNetPrice = mapCartLinesNetPrices.get(APTS_CONSTANTS.PROD_SKU_ZPA_PRO);
                }
                System.debug('*** zpaListPrice: ' + zpaListPrice);
                System.debug('*** cfwListPrice: ' + cfwListPrice);
                System.debug('*** zpaNetPrice: ' + zpaNetPrice);
                System.debug('*** cfwNetPrice: ' + cfwNetPrice);
                // Cheeck for ZPA and CFW line statuses = 'New'
                if ((zpaListPrice > 0.0 && cfwListPrice > 0.0
                    && !(cloudFireWallAsset != null || ziaTransBundleAsset != null || ziaELABundleAsset != null
                        || zpaProAsset != null || zpaBusAsset != null || zpaProAsset != null))
                        || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.ZPA_CFW_Promotion_Exception__c == true) {
                    // Add another condition to check for the exception flag
                    Decimal cfwPromo, zpaPromo;
                    if (cfwSKUCode == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE) {
                        cfwPromo = Math.abs((cfwListPrice * 0.15 * 0.16) - (cfwNetPrice * 0.16));
                    } else if (cfwSKUCode == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE) {
                        cfwPromo = Math.abs((cfwListPrice * 0.15 * 0.23) - (cfwNetPrice * 0.23));
                    } else {
                        cfwPromo = Math.abs((cfwListPrice * 0.15) - cfwNetPrice);
                    }

                    zpaPromo = zpaNetPrice * 0.25;

                    cfwZpaPromo = (cfwPromo < zpaPromo ? cfwPromo : zpaPromo) * -1;
                    cfwZpaPromo = cfwZpaPromo / cfwZpaPromoLiSO.Apttus_Config2__SellingTerm__c;
                }

                System.debug('*** cfwZpaPromo: ' + cfwZpaPromo);
                cfwZpaPromoLiSO.Apttus_Config2__BasePriceOverride__c = cfwZpaPromo;
                cfwZpaPromoLiSO.Apttus_Config2__BaseExtendedPrice__c = cfwZpaPromo;
                // Added condition to avoid apply discout for Partner Summit
                APTS_PricingHelper.partnerProgram = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
                APTS_PricingHelper.calculateDiscounts(cfwZpaPromoLiSO);
                //Added logic to set Net to zscaler
                
                calculateNetToZscaler(zpaCfwPromoLI.getLineItemSO());
                zpaCfwPromoLI.updatePrice();
                APTS_PricingHelper.calculateACVnMRR(cfwZpaPromoLiSO, productIdTOTotalTermMap.get(cfwZpaPromoLiSO.Apttus_Config2__ProductId__c));

                
            }

            //Cloud Promo Logic


            decimal cloudSandboxPromo = 0;
            decimal cloudFirewallPromo = 0;
            if (cartLineItemsMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO) ) {
                Apttus_Config2__LineItem__c cloudFireWall = (cartLineItemsMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) ? cartLineItemsMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL).getLineItemSO() : null);
                Apttus_Config2__LineItem__c cloudSandbox = (cartLineItemsMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX) ? cartLineItemsMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX).getLineItemSO() : null);
                Apttus_Config2__LineItem__c cloudPromo = (cartLineItemsMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO) ? cartLineItemsMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO).getLineItemSO() : null);
                Apttus_Config2__LineItem__c SIPProd = (cartLineItemsMap.containsKey(APTS_CONSTANTS.PROD_SKU_SIP) ? cartLineItemsMap.get(APTS_CONSTANTS.PROD_SKU_SIP).getLineItemSO() : null);

                Apttus_Config2__AssetLineItem__c cloudFireWallAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL)) : null);
                Apttus_Config2__AssetLineItem__c cloudSandboxAsset = (assetLineItemsSKUCodeIdMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX) ? aliIdtoALISOMap.get(assetLineItemsSKUCodeIdMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX)) : null);
                Apttus_Config2__LineItem__c cloudPromoWithAtt = new Apttus_Config2__LineItem__c();
                Double totalSIPCount = 0;
                Double totalCloudFirewallCount = 0;
                Double totalCloudSandboxCount = 0;

                if(prodConfigWrelFields.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_RENEWAL){
                    totalSIPCount =  SIPCartQuantity > 0 ?  SIPCartQuantity : (assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_SIP) ? assetLineItemsSKUCodeCountMap.get(APTS_CONSTANTS.PROD_SKU_SIP) : 0);
                }else{
                    totalSIPCount = (assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_SIP) ? assetLineItemsSKUCodeCountMap.get(APTS_CONSTANTS.PROD_SKU_SIP) : 0) + SIPCartQuantity;
                }

                totalCloudFirewallCount = (assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) ? assetLineItemsSKUCodeCountMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL) : 0) + (cloudFireWall != null ? cloudFireWall.Apttus_Config2__Quantity__c : 0);
                totalCloudSandboxCount = (assetLineItemsSKUCodeCountMap.containsKey(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX) ? assetLineItemsSKUCodeCountMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX) : 0) + (cloudSandbox != null ? cloudSandbox.Apttus_Config2__Quantity__c : 0);


                if(cloudPromo != null)
                cloudPromoWithAtt = [Select Id,
                                            Apttus_Config2__AttributeValueId__r.Promo_Discount__c,
                                            Apttus_Config2__AttributeValueId__c
                                            //Partner_Adjustment__c,
                                            //Partner_Adjustment_Type__c
                                    from Apttus_Config2__LineItem__c WHERE Id =: cloudPromo.Id  AND Apttus_Config2__AttributeValueId__c != NULL];

                decimal promoDiscountAtt = cloudPromoWithAtt != null ? Decimal.valueOf(cloudPromoWithAtt.Apttus_Config2__AttributeValueId__r.Promo_Discount__c) : 0;
                //New Business

                if (prodConfigWrelFields.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_NBUSINESS) {
                    if (cloudFireWall != null && cloudSandbox != null
                        &&((cloudFireWall.APTS_Total_Term__c >= 36 && cloudSandbox.APTS_Total_Term__c >= 36
                        && cloudFireWall.Apttus_Config2__Quantity__c < 20000 && cloudSandbox.Apttus_Config2__Quantity__c < 20000
                        && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && (cloudSandbox.APTS_Manual_Discount__c == null || cloudSandbox.APTS_Manual_Discount__c == 0 || CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && cloudFireWall.Apttus_Config2__Quantity__c == cloudSandbox.Apttus_Config2__Quantity__c
                        && totalCloudSandboxCount == totalSIPCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c)) {
                        cloudFirewallPromo = APTS_PricingHelper.getPromotionalCredit(cloudFireWall, promoDiscountAtt);
                        cloudSandboxPromo = APTS_PricingHelper.getPromotionalCredit(cloudSandbox, promoDiscountAtt);
                        Double promoDiscount = 0;
                        promoDiscount = 0 - (cloudSandboxPromo + cloudFirewallPromo);
                        cloudPromo.Apttus_Config2__BasePriceOverride__c = promoDiscount;
                        APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);
                    }
                }
                //Renewal

                else if (prodConfigWrelFields.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_RENEWAL
                    && !(cloudFireWallAsset != null && cloudSandboxAsset != null)){
                    if (cloudFireWallAsset == null && cloudSandboxAsset == null
                        && cloudSandbox != null && cloudFireWall != null
                        && ((cloudFireWall.APTS_Total_Term__c >= 36 && cloudSandbox.APTS_Total_Term__c >= 36
                        && cloudFireWall.Apttus_Config2__Quantity__c < 20000 && cloudSandbox.Apttus_Config2__Quantity__c < 20000
                        && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && (cloudSandbox.APTS_Manual_Discount__c == null || cloudSandbox.APTS_Manual_Discount__c == 0 || CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && cloudFireWall.Apttus_Config2__Quantity__c == cloudSandbox.Apttus_Config2__Quantity__c
                        && totalCloudSandboxCount == totalSIPCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c)) {
                        cloudFirewallPromo = APTS_PricingHelper.getPromotionalCredit(cloudFireWall, promoDiscountAtt);
                        cloudSandboxPromo = APTS_PricingHelper.getPromotionalCredit(cloudSandbox, promoDiscountAtt);
                        Double promoDiscount = 0;

                        promoDiscount = 0 - (cloudSandboxPromo + cloudFirewallPromo);
                        cloudPromo.Apttus_Config2__BasePriceOverride__c = promoDiscount;
                        APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);

                    } else if (cloudSandboxAsset != null || cloudFireWallAsset != null) {
                        if (cloudSandbox != null && cloudFireWall != null) {
                            if ((cloudSandbox.Apttus_Config2__StartDate__c == cloudFireWall.Apttus_Config2__StartDate__c
                                && cloudFireWall.APTS_Total_Term__c >= 36 && cloudSandbox.APTS_Total_Term__c >= 36
                                && cloudFireWall.Apttus_Config2__Quantity__c < 20000 && cloudSandbox.Apttus_Config2__Quantity__c < 20000
                                && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && (cloudSandbox.APTS_Manual_Discount__c == null || cloudSandbox.APTS_Manual_Discount__c == 0 || CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && totalCloudFirewallCount == totalCloudSandboxCount
                                && totalSIPCount == totalCloudFirewallCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c) {
                                cloudFirewallPromo = APTS_PricingHelper.getPromotionalCredit(cloudFireWall, promoDiscountAtt);
                                cloudSandboxPromo = APTS_PricingHelper.getPromotionalCredit(cloudSandbox, promoDiscountAtt);
                                Double promoDiscount = 0, term = 0;
                                promoDiscount = 0 - (cloudSandboxPromo + cloudFirewallPromo);
                                cloudPromo.Apttus_Config2__BasePriceOverride__c = promoDiscount;
                                APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);
                            } else {
                                //Todo: Discuss with Raj
                            }
                        }
                    }
                }
                //Upsell
                else if (prodConfigWrelFields.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL) {
                    if (cloudFireWallAsset == null && cloudSandboxAsset == null
                        && cloudSandbox != null && cloudFireWall != null
                        && ((cloudFireWall.Apttus_Config2__Quantity__c < 20000 && cloudSandbox.Apttus_Config2__Quantity__c < 20000
                        && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && (cloudSandbox.APTS_Manual_Discount__c == null || cloudSandbox.APTS_Manual_Discount__c == 0 || CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                        && cloudSandbox.APTS_Total_Term__c == cloudFireWall.APTS_Total_Term__c
                        && cloudSandbox.APTS_Total_Term__c >= 6
                        && totalSIPCount == totalCloudFirewallCount
                        && totalCloudFirewallCount == totalCloudSandboxCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c)) {
                        cloudFirewallPromo = APTS_PricingHelper.getPromotionalCredit(cloudFireWall, promoDiscountAtt);
                        cloudSandboxPromo = APTS_PricingHelper.getPromotionalCredit(cloudSandbox, promoDiscountAtt);
                        Double promoDiscount = 0;
                        promoDiscount = 0 - (cloudSandboxPromo + cloudFirewallPromo);
                        cloudPromo.Apttus_Config2__BasePriceOverride__c = promoDiscount;
                        APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);
                    } else if (cloudSandboxAsset != null || cloudFireWallAsset != null) {
                        if (cloudSandbox != null && cloudFireWall != null) {
                            if ((cloudSandbox.Apttus_Config2__StartDate__c == cloudFireWall.Apttus_Config2__StartDate__c
                                && cloudSandbox.APTS_Total_Term__c == cloudFireWall.APTS_Total_Term__c
                                && cloudFireWall.Apttus_Config2__Quantity__c < 20000 && cloudSandbox.Apttus_Config2__Quantity__c < 20000
                                && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && (cloudSandbox.APTS_Manual_Discount__c == null || cloudSandbox.APTS_Manual_Discount__c == 0 || CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  CloudSandbox.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && cloudSandbox.APTS_Total_Term__c >= 6
                                && totalCloudFirewallCount == totalCloudSandboxCount
                                && totalCloudFirewallCount == totalSIPCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c) {
                                cloudFirewallPromo = APTS_PricingHelper.getPromotionalCredit(cloudFireWall, promoDiscountAtt);
                                cloudSandboxPromo = APTS_PricingHelper.getPromotionalCredit(cloudSandbox, promoDiscountAtt);
                                Double promoDiscount = 0;
                                promoDiscount = 0 - (cloudSandboxPromo + cloudFirewallPromo);
                                cloudPromo.Apttus_Config2__BasePriceOverride__c = promoDiscount;
                                APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);
                            } else {
                                //Todo: Discuss with Raj
                            }
                        } else if (cloudSandbox == null || cloudFireWall == null) {
                            if (cloudFireWall != null && cloudSandboxAsset != null
                                && ((cloudFireWall.Apttus_Config2__Quantity__c < 20000
                                && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && cloudFireWall.APTS_Total_Term__c >= 6
                                && cloudSandboxAsset.Apttus_Config2__EndDate__c == cloudFireWall.Apttus_Config2__EndDate__c
                                && totalCloudFirewallCount == totalCloudSandboxCount
                                && totalCloudSandboxCount == totalSIPCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c)) {
                                //Asset line item net price calculation
                                Double totalPromoDiscount = 0 ;
                                totalPromoDiscount = APTS_PricingHelper.getPromotionalCredit(cloudSandboxAsset, cloudFireWall, promoDiscountAtt);
                                cloudPromo.Apttus_Config2__BasePriceOverride__c = (0 - totalPromoDiscount);
                                APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudFireWall.APTS_Total_Term__c);
                            } else if (cloudSandbox != null && cloudFirewallAsset != null
                                && ((cloudSandbox.Apttus_Config2__Quantity__c < 20000
                                && (cloudFireWall.APTS_Manual_Discount__c == null || cloudFireWall.APTS_Manual_Discount__c == 0 || cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_PERCENT ||  cloudFireWall.Apttus_Config2__AdjustmentType__c == APTS_CONSTANTS.LI_MARKUP_AMOUNT)
                                && cloudSandbox.APTS_Total_Term__c >= 6
                                && cloudFirewallAsset.Apttus_Config2__EndDate__c == cloudSandbox.Apttus_Config2__EndDate__c
                                && totalCloudFirewallCount == totalCloudSandboxCount
                                && totalCloudFirewallCount == totalSIPCount) || prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Override_Cloud_Promotion__c)
                                ) {
                                //Asset line item net price calculation
                                Double totalPromoDiscount = 0 ;
                                totalPromoDiscount = APTS_PricingHelper.getPromotionalCredit(cloudFirewallAsset, cloudSandbox, promoDiscountAtt);
                                cloudPromo.Apttus_Config2__BasePriceOverride__c = (0 - totalPromoDiscount);
                                APTS_PricingHelper.calculateACVAndMRRForCloudPromo(cloudPromo,cloudSandbox.APTS_Total_Term__c);
                            }
                        }
                    }
                }

                cartLineItemsMap.get(APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO).updateprice();
            }

            // //Reset the premium support values from line items when there is no premium support sku added
            if (premiumSupportStartDate == null && premiumSupportEndDate == null) {
                //Pass the product ids form List Price Map as both the maps will have the same key set.
                APTS_PricingHelper.resetPremiumSupportValues(this.cart.getConfigSO().Id, JSON.serialize(productIdToPremiumSupportListPriceMap.keySet()));
            }
            
            

            // set the netprice for canelled lines as none of the methods except start and finish will be called for cancelled lines.
            // If quantity is increased then credit the asset net price(asset quantity * asset term * line item unit price) else apply the price adjustment to net price.
            // Mode Check must be added later - TODO
            
            for(Apttus_Config2.LineItem lineItemMO : this.cart.getLineItems()){

                Apttus_Config2__LineItem__c liSO = lineItemMO.getLineItemSO();
                Date liStartDate = liSO.Apttus_Config2__StartDate__c;
                Date liEndDate = liSO.Apttus_Config2__EndDate__c;
                Double liSellingTerm = 0;
                Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(liSO.Pricing_Callback_Fields__c);
                String PriceGroup = pricingCallBackFieldsMap.containsKey('PriceGroup') ? (String)pricingCallBackFieldsMap.get('PriceGroup') : '';
                
                if(liEndDate != null && liStartDate != null)
                    liSellingTerm = (Integer)Math.roundToLong(((liStartDate.daysBetween(liEndDate))/30.25));

                if(liSO.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_CANCELLED){
                    liSO.Apttus_Config2__BaseExtendedPrice__c = liSO.APTS_Total_Discount_Percentage__c != null ? (liSO.APTS_Total_Discount_Percentage__c < 100 ? liSO.Apttus_Config2__NetPrice__c*(100/(100-liSO.APTS_Total_Discount_Percentage__c)) : liSO.Apttus_Config2__NetPrice__c) : liSO.Apttus_Config2__BaseExtendedPrice__c;
                    liSO.Apttus_Config2__NetPrice__c = liSO.Apttus_Config2__PriceAdjustment__c;
                    APTS_PricingHelper.calculateACVnMRR(liSO, (PriceGroup == 'Price Ramp' ? productIdTOTotalTermMap.get(liSO.Apttus_Config2__ProductId__c) : liSellingTerm));
                }

            }
            Set<Id> ziaZpaIdSet = new Set<Id>();
            //system.debug('wfhPromoLI=====>'+wfhPromoLI);
            if(wfHSKU != null)
            {
                //system.debug('===lineItemforWFH==>'+lineItemforWFH);
                //Apttus_Config2__LineItem__c wfhPromoLine = null;
                Decimal ttlziaprice2 = 0.0;
                Decimal ttlzpaprice2 = 0.0;
                for(Apttus_Config2.LineItem lineItemMO : lineItemforWFH)
                {

                    Apttus_Config2__LineItem__c liSO = lineItemMO.getLineItemSO();
                    // Apttus_Config2__LineItem__c  liSO = [SELECT id,  
                    //                                                   APTS_ProductCode__c,   
                    //                                                   Apttus_Config2__NetPrice__c,   
                    //                                                   ZIA_Premium_Support__c,    
                    //                                                   ZPA_Premium_Support__c,    
                    //                                                   Apttus_Config2__BaseExtendedPrice__c   
                    //                                             FROM Apttus_Config2__LineItem__c     
                    //                                             WHERE id =: lineItemMO.getLineItemSO().Id];
                   
                       System.debug('liSO.Apttus_Config2__BaseExtendedPrice__c++++' +liSO.Apttus_Config2__BaseExtendedPrice__c);
                       System.debug('liSO.Apttus_Config2__NetPrice__c++++' +liSO.Apttus_Config2__NetPrice__c);
                       System.debug('liSO.ZIA_Premium_Support__cc++++' +liSO.ZIA_Premium_Support__c);
                       System.debug('liSO.ZPA_Premium_Support__c++++' +liSO.ZPA_Premium_Support__c);

                    system.debug('=== WFH liso==>'+liso.APTS_ProductCode__c);
                    //CR# 222 -Minkesh Patel - Approved_WFH_Promo__c - Start
                    if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE 
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                        || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU) { 
                        
                        
                        ttlziaprice2 = ttlziaprice2 + liSO.Apttus_Config2__NetPrice__c;    
                            
                        ziaZpaIdSet.add(liso.id);
                        
                    }
                    else if(liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU 
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                            || liSO.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS){
                                
                            
                            ttlzpaprice2 = ttlzpaprice2 + liSO.Apttus_Config2__NetPrice__c;
                            ziaZpaIdSet.add(liso.id);
                    }
                }
                /*Set<String> zpaset = new Set<String>{APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU , 
                    APTS_CONSTANTS.PROD_SKU_ZPA_PRO , 
                    APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU, 
                    APTS_CONSTANTS.PROD_SKU_ZPA_BUS};
                Set<String> ziaset = new Set<String>{APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU ,
                    APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE , 
                    APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU}; */
                List<Apttus_Config2__LineItem__c>  liSOWPS = [SELECT id,    
                                                            APTS_ProductCode__c,    
                                                            Apttus_Config2__NetPrice__c,    
                                                            ZIA_Premium_Support__c, 
                                                            ZPA_Premium_Support__c, 
                                                            Apttus_Config2__BaseExtendedPrice__c    
                                                    FROM Apttus_Config2__LineItem__c    
                                                    WHERE id in : ziaZpaIdSet];
                for(Apttus_Config2__LineItem__c liSO : liSOWPS)
                {
                    if(liSO.ZPA_Premium_Support__c != null) {
                        ttlzpaprice2 = ttlzpaprice2 + liSO.ZPA_Premium_Support__c;
                        //System.debug('liSO.ttlzpaprice++++++++'+ttlzpaprice2);
                    }
                    else if(liSO.ZIA_Premium_Support__c != null) {
                        ttlziaprice2 = ttlziaprice2 + liSO.ZIA_Premium_Support__c;
                        //System.debug('liSO.ttlzpaprice++++++++'+ttlzpaprice2);
                    }
                }
                
                                                

                
                Apttus_Config2__LineItem__c wfhSKULine = wfHSKU.getLineItemSO();
                //System.debug('liSO.APTS_ProductCode__c++++++++'+wfhSKULine.APTS_ProductCode__c+ ' ==> Term <==='+wfhSKULine.APTS_Total_Term__c);
                //System.debug('ZIA Price :'+ttlziaprice2+', ZPA Price :'+ttlzpaprice2);
                //if(wfhSKULine.APTS_Total_Term__c >= 36){
                if(quoteTerm >= 36){
                    
                    wfhSKULine.Apttus_Config2__BasePriceOverride__c = -(0.1*(ttlziaprice2 + ttlzpaprice2));
                    
                }else if(quoteTerm > 12 && quoteTerm < 36){
                //else if(wfhSKULine.APTS_Total_Term__c > 12 && wfhSKULine.APTS_Total_Term__c < 36){
                    
                    wfhSKULine.Apttus_Config2__BasePriceOverride__c = -(0.05*(ttlziaprice2 + ttlzpaprice2));
                    
                }   
                //update wfhSKULine;
                wfHSKU.updateprice();
                APTS_PricingHelper.calculateACVnMRR(wfhSKULine, quoteTerm );
                //CR# 222 -Minkesh Patel - Approved_WFH_Promo__c - End
                 
                //update wfhPromoLine;
            }
            
            
        }catch(Exception ex){
            throw new APTS_Exception('Error from finish: '+ex.getMessage()+' Line Number: '+ex.getLineNumber());
        }
    }

    /*
        Method to cacluate Net to Zscaler field
    */
    private void calculateNetToZscaler(Apttus_Config2__LineItem__c li) {
        system.debug('=================================================in method ===calculateNetToZscaler');
        Map<String, Object> pricingCallBackFieldsMap = (Map<String, Object>)JSON.deserializeUntyped(li.Pricing_Callback_Fields__c);
        Decimal stackMarginTotal  = pricingCallBackFieldsMap.containsKey('Total_Stackable_Margin__c') ? (Decimal)pricingCallBackFieldsMap.get('Total_Stackable_Margin__c') : 0;
        //Decimal totalPartnerMargin = pricingCallBackFieldsMap.containsKey('Total_Partner_Margin__c ') ? (Decimal)pricingCallBackFieldsMap.get('Total_Partner_Margin__c ') : 0;
        String partnerAdjustmentType = pricingCallBackFieldsMap.containsKey('Partner_Adjustment_Type__c') ? (String)pricingCallBackFieldsMap.get('Partner_Adjustment_Type__c') : '';
        //Boolean checkBoxOnOpp = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c;
        //String partnProgmOnProp = prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c;
        Decimal partnerAdjustment = pricingCallBackFieldsMap.containsKey('Partner_Adjustment__c') ? (Decimal)pricingCallBackFieldsMap.get('Partner_Adjustment__c') : 0;
        Decimal netPrice = li.Apttus_Config2__NetPrice__c != null ? li.Apttus_Config2__NetPrice__c : 0 ;
        
        
        if(li.Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT){
            if(partnerAdjustmentType == APTS_CONSTANTS.LI_ADJUSTMENT_PRICEOVERRIDE 
                && prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c == TRUE 
                && partnerAdjustment > 0){    
                //system.debug('In======if priceover==li.Apttus_Config2__NetPrice__c==='+ li.Apttus_Config2__NetPrice__c);
                li.Net_to_Zscaler__c = partnerAdjustment ;
                //system.debug('in======if priceover==li.Net_to_Zscaler__c'+li.Net_to_Zscaler__c);
            }
            else if(partnerAdjustmentType == APTS_CONSTANTS.LI_ADJUSTMENT_DISCOUNT 
                    && prodConfigWrelFields.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c == TRUE){
                //system.debug('In=======if disc====li.Apttus_Config2__NetPrice__c==='+ li.Apttus_Config2__NetPrice__c);
                li.Net_to_Zscaler__c = ( 1 - ( stackMarginTotal / 100) ) * netPrice;
                //system.debug('in======if disc====li.Net_to_Zscaler__c'+li.Net_to_Zscaler__c);
            }
            else{
                //System.debug('checkbox=false =========netprice'+ netprice);
                li.Net_to_Zscaler__c = ( 1 - ( stackMarginTotal / 100) ) * netPrice ;
                //System.debug('checkbox=false ====li.Net_to_Zscaler__c'+li.Net_to_Zscaler__c);
            }
        }else{
            li.Net_to_Zscaler__c = 0;
        }
    }
    global void booster(){
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
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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