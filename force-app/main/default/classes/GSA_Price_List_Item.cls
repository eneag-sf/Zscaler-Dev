public class GSA_Price_List_Item {
    public static Set<Id> checkiframp = new Set<Id>();
    @InvocableMethod
    public static void createGSAentry(List<Id> ProposalLineitemid){
        Double premiumSupportTerm_Days = 0;// used to prorate assets and calculation of premium support price.
        Date premiumSupportStartDate;
        Date premiumSupportEndDate;
        Map<Id, Decimal> productIdToPremiumSupportNetPriceMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productIdToPremiumSupportListPriceMap = new Map<Id, Decimal>();
        Decimal sellingTerm = 0;
        String supportsource = '';
        Decimal supportpercent = 0.0;
        
        Set<String> setDASCodes = new Set<String>(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('DAS_SKUs').SKU_Codes__c.split(';'));
        
        Map<Id, Apttus_Proposal__Proposal_Line_Item__c> mappli = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>([Select Id, ZIA_List_Price_Premium_Support__c, APTS_Ramp_End_Date__c, Apttus_Proposal__Proposal__r.Exclude_Assets_From_Prem_Support_Calc__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.APTS_Asset_SKU__c, Apttus_QPConfig__LineStatus__c, DAS_Seats_Mismatch_Fedramp__c, Apttus_QPConfig__IsPrimaryLine__c, APTS_Selling_Term__c, ZPA_List_Price_Premium_Support__c, GSA_Price_Per_Unit__c, Apttus_Proposal__Product__c, Proposal_SKU__c, APTS_Quantity__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_Total_Discount_Percentage__c, ZIA_Premium_Support__c, ZPA_Premium_Support__c, Apttus_Proposal__Product__r.Zscaler_Product_Family__c, Apttus_Proposal__Proposal__c, Apttus_Proposal__Proposal__r.Support_Products__c, Apttus_Proposal__Product__r.Name, Apttus_QPConfig__PriceListItemId__c, APTS_Base_Price_override__c, APTS_Net_Price__c, Apttus_QPConfig__IsPrimaryRampLine__c, APTS_Total_Ramp_Quantity__c, Apttus_Proposal__Proposal__r.Apttus_QPConfig__BillToAccountId__r.Premium_Support__c, Apttus_Proposal__Proposal__r.Apttus_QPConfig__BillToAccountId__r.Premium_Support_Source__c, Apttus_QPConfig__SellingTerm__c, Apttus_Proposal__Proposal__r.Apply_GSA_Schedule__c, Apttus_Proposal__Proposal__r.Contains_FED_Platform_SKUs__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c, Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__PriceGroup__c from Apttus_Proposal__Proposal_Line_Item__c where Id in :ProposalLineitemid]);
        Boolean isPremsupportexist = false;
        Boolean isGSAquote = false;
        Apttus_Proposal__Proposal_Line_Item__c premsupli = new Apttus_Proposal__Proposal_Line_Item__c();
        
        List<GSA_Price_List_Item__c> mappliidgsa = new List<GSA_Price_List_Item__c>();
        Map<Id, List<Apttus_Config2__PriceMatrixEntry__c>> mapplitopme = new Map<Id, List<Apttus_Config2__PriceMatrixEntry__c>>();
        Set<Id> pricelistitemIds = new Set<Id>();
        Map<Id, Decimal> pdtqtymap = new Map<Id, Decimal>();
        Map<Id, Date> pdtendatemap = new Map<Id, Date>();
        
        for(Apttus_Proposal__Proposal_Line_Item__c pli: mappli.values()){
            if(pdtqtymap.containskey(pli.Apttus_Proposal__Product__c) && pdtqtymap.get(pli.Apttus_Proposal__Product__c) < pli.APTS_Quantity__c){
                pdtqtymap.put(pli.Apttus_Proposal__Product__c, pli.APTS_Quantity__c);
            }else if(!pdtqtymap.containskey(pli.Apttus_Proposal__Product__c)){
                pdtqtymap.put(pli.Apttus_Proposal__Product__c, pli.APTS_Quantity__c);
            }
            
            if(pdtendatemap.containskey(pli.Apttus_Proposal__Product__c) && pdtendatemap.get(pli.Apttus_Proposal__Product__c) < pli.Apttus_QPConfig__EndDate__c){
                pdtendatemap.put(pli.Apttus_Proposal__Product__c, pli.Apttus_QPConfig__EndDate__c);
            }else if(!pdtendatemap.containskey(pli.Apttus_Proposal__Product__c)){
                pdtendatemap.put(pli.Apttus_Proposal__Product__c, pli.Apttus_QPConfig__EndDate__c);
            }
            
            pricelistitemIds.add(pli.Apttus_QPConfig__PriceListItemId__c);
            if(pli.Proposal_SKU__c == APTS_CONSTANTS.PROD_SKU_PSUPPORT){
                isPremsupportexist = true;
                premsupli = pli;
                premiumSupportTerm_Days = pli.Apttus_QPConfig__SellingTerm__c*365;
                premiumSupportStartDate = pli.Apttus_QPConfig__StartDate__c;
                premiumSupportEndDate = pli.Apttus_QPConfig__EndDate__c;
                sellingTerm = pli.Apttus_QPConfig__SellingTerm__c != null ? pli.Apttus_QPConfig__SellingTerm__c : 0;
            }
            if(pli.Apttus_Proposal__Proposal__r.Apply_GSA_Schedule__c || pli.Apttus_Proposal__Proposal__r.Contains_FED_Platform_SKUs__c || pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.Federal_Deal_Approved_OP__c){
                isGSAquote = true;
            }
        }
        if(isPremsupportexist){
            for(Apttus_Proposal__Proposal_Line_Item__c pli: mappli.values()){
                if(pli.Apttus_QPConfig__LineStatus__c == APTS_CONSTANTS.LI_STATUS_NEW
                   || pli.Apttus_QPConfig__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED
                   || pli.Apttus_QPConfig__LineStatus__c == APTS_CONSTANTS.LI_STATUS_UPGRADED
                   || pli.Apttus_QPConfig__LineStatus__c == APTS_CONSTANTS.LI_STATUS_AMENDED){
                       if(pli.Proposal_SKU__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT && pli.Proposal_SKU__c != null && !setDASCodes.contains(pli.Proposal_SKU__c)){
                           Double sellingTerm_Days = pli.Apttus_QPConfig__StartDate__c != null && pli.Apttus_QPConfig__EndDate__c != null ? pli.Apttus_QPConfig__StartDate__c.daysBetween(pli.Apttus_QPConfig__EndDate__c) : 0;
                           Date premiumSupportEffectiveStartDate = pli.Apttus_QPConfig__StartDate__c != null && premiumSupportStartDate != null ? (pli.Apttus_QPConfig__StartDate__c < premiumSupportStartDate ? premiumSupportStartDate : pli.Apttus_QPConfig__StartDate__c) : null;
                           Date premiumSupportEffectiveEndDate = pli.Apttus_QPConfig__EndDate__c != null && premiumSupportEndDate != null ? (pli.Apttus_QPConfig__EndDate__c > premiumSupportEndDate ? premiumSupportEndDate : pli.Apttus_QPConfig__EndDate__c) : null;
                           Double premiumSupportApplicableDays = premiumSupportEffectiveStartDate != null && premiumSupportEffectiveEndDate != null ? premiumSupportEffectiveStartDate.daysBetween(premiumSupportEffectiveEndDate) : 0;
                           
                           if (premiumSupportApplicableDays > 0 && sellingTerm_Days != 0) {
                               
                               if(pli.Apttus_QPConfig__BaseExtendedPrice__c !=  null){
                                   if (productIdToPremiumSupportListPriceMap.containsKey(pli.Apttus_Proposal__Product__c)) {
                                       productIdToPremiumSupportListPriceMap.put(pli.Apttus_Proposal__Product__c, productIdToPremiumSupportListPriceMap.get(pli.Apttus_Proposal__Product__c) + (pli.Apttus_QPConfig__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days)));
                                   } else {
                                       productIdToPremiumSupportListPriceMap.put(pli.Apttus_Proposal__Product__c, pli.Apttus_QPConfig__BaseExtendedPrice__c*(premiumSupportApplicableDays/sellingTerm_Days));
                                   }
                               }
                               if(pli.APTS_Net_Price__c != null){
                                   if (productIdToPremiumSupportNetPriceMap.containsKey(pli.Apttus_Proposal__Product__c)) {
                                       productIdToPremiumSupportNetPriceMap.put(pli.Apttus_Proposal__Product__c, productIdToPremiumSupportNetPriceMap.get(pli.Apttus_Proposal__Product__c) + (pli.APTS_Net_Price__c*(premiumSupportApplicableDays/sellingTerm_Days)));
                                   } else {
                                       productIdToPremiumSupportNetPriceMap.put(pli.Apttus_Proposal__Product__c, pli.APTS_Net_Price__c*(premiumSupportApplicableDays/sellingTerm_Days));
                                   }
                               }
                           }
                       }
                   }
            }
        }
        if(premsupli != null){
            List<Apttus_QPConfig__ProposalProductAttributeValue__c> attributevalueinfo = [Select Id, Support_Percent__c, Support_Source__c from Apttus_QPConfig__ProposalProductAttributeValue__c where Apttus_QPConfig__LineItemId__c = :premsupli.Id];
            
            if(attributevalueinfo.isempty() && !isGSAquote){
                supportsource = premsupli.Apttus_Proposal__Proposal__r.Apttus_QPConfig__BillToAccountId__r.Premium_Support_Source__c;
                supportpercent = premsupli.Apttus_Proposal__Proposal__r.Apttus_QPConfig__BillToAccountId__r.Premium_Support__c;
            }else if(isGSAquote){
                supportsource = APTS_CONSTANTS.ACC_SUPPORTSOURCE_LIST;
                supportpercent = APTS_CONSTANTS.PAV_PERCENT_GSA;
            }else{
                supportsource = attributevalueinfo[0].Support_Source__c;
                supportpercent = attributevalueinfo[0].Support_Percent__c;
            }
        }
        
        if(!mappli.values().isEmpty() && mappli.values()[0] != null && mappli.values()[0].Apttus_Proposal__Proposal__c != null){
            delete [Select Id from GSA_Price_List_Item__c where Quote_Proposal__c = :mappli.values()[0].Apttus_Proposal__Proposal__c];
        }
        Decimal totalGSAsupportlineprice = 0;
        for(Apttus_Config2__PriceMatrixEntry__c pme: [Select Id, Apttus_Config2__Dimension1Value__c, Apttus_Config2__PriceMatrixId__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c from Apttus_Config2__PriceMatrixEntry__c where Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c in :pricelistitemIds and Apttus_Config2__Dimension1Value__c != null]){
            if(pme.Apttus_Config2__PriceMatrixId__c != null && pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c != null){
                if(!mapplitopme.containskey(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c)){
                    mapplitopme.put(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c, new List<Apttus_Config2__PriceMatrixEntry__c>{pme});
                }else if(mapplitopme.get(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c) != null){
                    mapplitopme.get(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c).add(pme);
                }
            }
        }
        Integer countofDASmismatch = 0;
        for(Apttus_Proposal__Proposal_Line_Item__c pli: mappli.values()){
            String lowerlimit = '1';
            String Upperlimit = '';
            if(pli.DAS_Seats_Mismatch_Fedramp__c > 0 && pli.Apttus_QPConfig__IsPrimaryLine__c){
                countofDASmismatch++;
            }
            if(mapplitopme.containskey(pli.Apttus_QPConfig__PriceListItemId__c) && mapplitopme.get(pli.Apttus_QPConfig__PriceListItemId__c) != null){
                for(Apttus_Config2__PriceMatrixEntry__c pme: mapplitopme.get(pli.Apttus_QPConfig__PriceListItemId__c)){
                    if(pdtqtymap.containskey(pli.Apttus_Proposal__Product__c) && pdtqtymap.get(pli.Apttus_Proposal__Product__c) > Decimal.valueOf(pme.Apttus_Config2__Dimension1Value__c)){
                        lowerlimit = String.valueOf(math.round(Decimal.valueOf(pme.Apttus_Config2__Dimension1Value__c)/10) * 10);
                    }else{
                        Upperlimit = pme.Apttus_Config2__Dimension1Value__c;
                        break;
                    }
                }
            }else{
                lowerlimit = '';
            }
            if(pli.Proposal_SKU__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT && pli.Proposal_SKU__c != null && !setDASCodes.contains(pli.Proposal_SKU__c)){
                GSA_Price_List_Item__c gsarec = new GSA_Price_List_Item__c();
                gsarec.Product__c = pli.Apttus_Proposal__Product__c;
                gsarec.Proposal_Line_Item__c = pli.Id;
                gsarec.Quote_Proposal__c = pli.Apttus_Proposal__Proposal__c;
                //gsarec.Product_Name__c = pli.Apttus_Proposal__Product__r.Name + (lowerlimit != '' && Upperlimit != '' ? ' ('+ lowerlimit + '-' + Upperlimit + ' Users)' : '');
                gsarec.Product_Name__c = pli.Apttus_Proposal__Product__r.Name + (lowerlimit != ''? ' ('+ lowerlimit + ' Users)' : '');
                gsarec.Proposal_SKU__c = lowerlimit != ''? pli.Proposal_SKU__c + '-'+ lowerlimit : pli.Proposal_SKU__c;
                //gsarec.Proposal_SKU__c = lowerlimit != '' && Upperlimit != '' ? pli.Proposal_SKU__c + '-'+ lowerlimit + '-' + Upperlimit : pli.Proposal_SKU__c;
                gsarec.Quantity__c = pli.APTS_Quantity__c;
                gsarec.Start_Date__c = pli.Apttus_QPConfig__StartDate__c;
                gsarec.End_Date__c = pli.Apttus_QPConfig__EndDate__c;
                gsarec.Net_Price__c = pli.APTS_Net_Price__c;
                gsarec.List_Price__c = pli.APTS_Base_Price_override__c;
                gsarec.Total_Discount__c = pli.APTS_Total_Discount_Percentage__c;
                gsarec.Price_Per_Unit__c = pli.GSA_Price_Per_Unit__c;
                gsarec.APTS_Selling_Term__c = pli.APTS_Selling_Term__c;
                mappliidgsa.add(gsarec);
            }   
            if(pli.Proposal_SKU__c != APTS_CONSTANTS.PROD_SKU_PSUPPORT && pli.Proposal_SKU__c != null && !setDASCodes.contains(pli.Proposal_SKU__c)){
                if(isPremsupportexist && ((pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA' && pli.ZIA_Premium_Support__c > 0) || (pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA' && pli.ZPA_Premium_Support__c> 0) || pli.Apttus_QPConfig__LineStatus__c == 'Cancelled')){
                    GSA_Price_List_Item__c gsarec1 = new GSA_Price_List_Item__c();
                    Id productId = pli.Apttus_Proposal__Product__c;
                    gsarec1.Product__c = pli.Apttus_Proposal__Product__c;
                    gsarec1.Proposal_Line_Item__c = pli.Id;
                    gsarec1.Quote_Proposal__c = pli.Apttus_Proposal__Proposal__c;
                    //gsarec1.Product_Name__c = 'Premium Support, ' + pli.Apttus_Proposal__Product__r.Name + (lowerlimit != '' && Upperlimit != '' ? ' ('+ lowerlimit + '-' + Upperlimit + ' Users)' : '');
                    gsarec1.Product_Name__c = 'Premium Support, ' + pli.Apttus_Proposal__Product__r.Name + (lowerlimit != ''? ' ('+ lowerlimit + ' Users)' : '');
                    gsarec1.Proposal_SKU__c = 'ZCES-SUP-PREM-'+ (lowerlimit != ''?  pli.Proposal_SKU__c + '-'+ lowerlimit : pli.Proposal_SKU__c);
                    //gsarec1.Proposal_SKU__c = 'ZCES-SUP-PREM-'+ (lowerlimit != '' && Upperlimit != '' ?  pli.Proposal_SKU__c + '-'+ lowerlimit + '-' + Upperlimit : pli.Proposal_SKU__c);
                    if(pdtqtymap.containskey(pli.Apttus_Proposal__Product__c)){
                        gsarec1.Quantity__c = pdtqtymap.get(pli.Apttus_Proposal__Product__c);
                    }
                    gsarec1.Start_Date__c = pli.Apttus_QPConfig__StartDate__c;
                    if(pdtendatemap.containskey(pli.Apttus_Proposal__Product__c)){
                        gsarec1.End_Date__c = pdtendatemap.get(pli.Apttus_Proposal__Product__c);
                    }
                    /*if(pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA'){
gsarec1.Net_Price__c = pli.ZIA_Premium_Support__c;
}else{
gsarec1.Net_Price__c = pli.ZPA_Premium_Support__c;
}
if(pli.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA'){
gsarec1.List_Price__c = pli.ZIA_List_Price_Premium_Support__c;
}else{
gsarec1.List_Price__c = pli.ZPA_List_Price_Premium_Support__c;
}*/
                    Double sellingTerm_Days = pli.Apttus_QPConfig__StartDate__c.daysBetween(pli.Apttus_QPConfig__EndDate__c);
                    Date premiumSupportEffectiveStartDate = (pli.Apttus_QPConfig__StartDate__c < premiumSupportStartDate ? premiumSupportStartDate : pli.Apttus_QPConfig__StartDate__c);
                    Date premiumSupportEffectiveEndDate = (pli.Apttus_QPConfig__EndDate__c > premiumSupportEndDate ? premiumSupportEndDate : pli.Apttus_QPConfig__EndDate__c);
                    Double premiumSupportApplicableDays = premiumSupportEffectiveStartDate.daysBetween(premiumSupportEffectiveEndDate);
                    
                    if(supportsource == 'List'){
                        //Decimal listPrice = pli.Apttus_QPConfig__BaseExtendedPrice__c * (premiumSupportApplicableDays/sellingTerm_Days);
                        Decimal listPrice = (!productIdToPremiumSupportListPriceMap.isEmpty()) && productIdToPremiumSupportListPriceMap.containsKey(productId) && productIdToPremiumSupportListPriceMap.get(productId) != null ? productIdToPremiumSupportListPriceMap.get(productId) : pli.Apttus_QPConfig__BaseExtendedPrice__c * (premiumSupportApplicableDays/sellingTerm_Days);
                        Decimal lpsupportValue = (listPrice * (supportpercent/100)).setScale(2);
                        Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((listPrice * (supportpercent/100)).setScale(2), premsupli.APTS_Total_Discount_Percentage__c);
                        gsarec1.List_Price__c = lpsupportValue;
                        gsarec1.Net_Price__c = supportValue;
                    }else{
                        //Decimal netPriceli = pli.APTS_Net_Price__c * (premiumSupportApplicableDays/sellingTerm_Days);
                        Decimal netPriceli =  (!productIdToPremiumSupportNetPriceMap.isEmpty()) && productIdToPremiumSupportNetPriceMap.containsKey(productId) && productIdToPremiumSupportNetPriceMap.get(productId) != null ? productIdToPremiumSupportNetPriceMap.get(productId) : pli.APTS_Net_Price__c * (premiumSupportApplicableDays/sellingTerm_Days);
                        Decimal lpsupportValue = (netPriceli * (supportpercent/100)).setScale(2);
                        
                        Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((netPriceli * (supportpercent/100)).setScale(2), premsupli.APTS_Total_Discount_Percentage__c);
                        gsarec1.List_Price__c = lpsupportValue;
                        gsarec1.Net_Price__c = supportValue;
                    }
                    
                    
                    gsarec1.Total_Discount__c = premsupli.APTS_Total_Discount_Percentage__c;
                    gsarec1.Price_Per_Unit__c = pli.GSA_Price_Per_Unit__c;
                    gsarec1.APTS_Selling_Term__c = pli.APTS_Selling_Term__c;
                    
                    
                    //gsarec1.Range__c = lowerlimit != 'Upto ' && Upperlimit != '' ? 'for ' + lowerlimit + ' to ' + Upperlimit + ' users': Upperlimit != '' ? lowerlimit + Upperlimit + ' users' : '';
                    //gsarec1.Lower_Range__c = lowerlimit != 'Upto ' ? '-' + lowerlimit : '';
                    mappliidgsa.add(gsarec1);
                }
            }
        }
        
        
        
        
        
        if(premsupli != null && (String.isBlank(premsupli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.APTS_Asset_SKU__c) || !premsupli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.APTS_Asset_SKU__c.contains(APTS_CONSTANTS.PROD_SKU_PSUPPORT)) && premsupli.Apttus_Proposal__Proposal__r.Exclude_Assets_From_Prem_Support_Calc__c == false && premiumSupportTerm_Days != 0){
            
            
            Map<Id, Apttus_Config2__AssetLineItem__c> aliIdtoALISOMap = new Map<Id, Apttus_Config2__AssetLineItem__c>([Select Id, Apttus_Config2__Quantity__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__ProductId__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceType__c, Apttus_Config2__ProductId__r.name, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, APTS_Total_Ramp_Quantity__c, APTS_Ramp_End_Date__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__SellingTerm__c, Apttus_QPConfig__ProposalLineItemId__c, APTS_MRR__c, Apttus_Config2__ListPrice__c, APTS_Selling_Term__c,  Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, Exclude_From_Premium_Support_Calculation__c, Product_Code__c, Apttus_Config2__PriceListItemId__c, APTS_Total_Discount_Percentage__c From Apttus_Config2__AssetLineItem__c Where Apttus_Config2__AccountId__c = :premsupli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c AND Apttus_Config2__AssetStatus__c = 'Activated'  Order by Apttus_Config2__LineNumber__c asc, CreatedDate desc]);
            
            pricelistitemIds = new Set<Id>();
            for(Apttus_Config2__AssetLineItem__c pli: aliIdtoALISOMap.values()){
                pricelistitemIds.add(pli.Apttus_Config2__PriceListItemId__c);
            }
            mapplitopme = new Map<Id, List<Apttus_Config2__PriceMatrixEntry__c>>();
            for(Apttus_Config2__PriceMatrixEntry__c pme: [Select Id, Apttus_Config2__Dimension1Value__c, Apttus_Config2__PriceMatrixId__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c from Apttus_Config2__PriceMatrixEntry__c where Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c in :pricelistitemIds and Apttus_Config2__Dimension1Value__c != null]){
                if(pme.Apttus_Config2__PriceMatrixId__c != null && pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c != null){
                    if(!mapplitopme.containskey(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c)){
                        mapplitopme.put(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c, new List<Apttus_Config2__PriceMatrixEntry__c>{pme});
                    }else if(mapplitopme.get(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c) != null){
                        mapplitopme.get(pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c).add(pme);
                    }
                }
            }
            
            
            for(Id aliId : aliIdtoALISOMap.keySet()){
                Apttus_Config2__AssetLineItem__c aliSO = aliIdtoALISOMap.get(aliId);
                if(aliSO.Apttus_Config2__ChargeType__c == APTS_CONSTANTS.PROD_CHARGETYPE_SFEE
                   && aliSO.Apttus_Config2__PriceType__c == APTS_CONSTANTS.PROD_PRICETYPE_RECURRING
                   && aliSO.Apttus_Config2__ProductId__r.ProductCode != APTS_CONSTANTS.PROD_SKU_PSUPPORT
                   && aliSO.Exclude_From_Premium_Support_Calculation__c != true){
                       
                       Double baseExtended = aliSO.Apttus_Config2__BaseExtendedPrice__c;
                       Double netPrice = aliSO.Apttus_Config2__NetPrice__c;
                       Double sellingTerm_Days = aliSO.Apttus_Config2__StartDate__c.daysBetween(aliSO.Apttus_Config2__EndDate__c);
                       Date premiumSupportEffectiveStartDate = (aliSO.Apttus_Config2__StartDate__c < premiumSupportStartDate ? premiumSupportStartDate : aliSO.Apttus_Config2__StartDate__c);
                       Date premiumSupportEffectiveEndDate = (aliSO.Apttus_Config2__EndDate__c > premiumSupportEndDate ? premiumSupportEndDate : aliSO.Apttus_Config2__EndDate__c);
                       Double premiumSupportApplicableDays = premiumSupportEffectiveStartDate.daysBetween(premiumSupportEffectiveEndDate);
                       
                       String lowerlimit = '1';
                       String Upperlimit = '';
                       if(mapplitopme.containskey(aliSO.Apttus_Config2__PriceListItemId__c) && mapplitopme.get(aliSO.Apttus_Config2__PriceListItemId__c) != null){
                           for(Apttus_Config2__PriceMatrixEntry__c pme: mapplitopme.get(aliSO.Apttus_Config2__PriceListItemId__c)){
                               if(aliSO.Apttus_Config2__Quantity__c > Decimal.valueOf(pme.Apttus_Config2__Dimension1Value__c)){
                                   lowerlimit = String.valueOf(math.round(Decimal.valueOf(pme.Apttus_Config2__Dimension1Value__c)/10) * 10);
                               }else{
                                   Upperlimit = pme.Apttus_Config2__Dimension1Value__c;
                                   break;
                               }
                           }
                       }else{
                           lowerlimit = '';
                       }
                       
                       if(sellingTerm_Days != 0
                          && premiumSupportApplicableDays != 0
                          && premiumSupportApplicableDays > 0){
                              
                              GSA_Price_List_Item__c gsarec1 = new GSA_Price_List_Item__c();
                              gsarec1.Product__c = aliSO.Apttus_Config2__ProductId__c;
                              gsarec1.Proposal_Line_Item__c = aliSO.Apttus_QPConfig__ProposalLineItemId__c;
                              gsarec1.Quote_Proposal__c = premsupli.Apttus_Proposal__Proposal__c;
                              //gsarec1.Product_Name__c = 'Premium Support, ' + aliSO.Apttus_Config2__ProductId__r.Name + (lowerlimit != '' && Upperlimit != '' ? ' ('+ lowerlimit + '-' + Upperlimit + ' Users)' : '');
                              gsarec1.Product_Name__c = 'Premium Support, ' + aliSO.Apttus_Config2__ProductId__r.Name + (lowerlimit != ''? ' ('+ lowerlimit + ' Users)' : '');
                              gsarec1.Proposal_SKU__c = 'ZCES-SUP-PREM-'+ (lowerlimit != '' ?  aliSO.Product_Code__c + '-'+ lowerlimit : aliSO.Product_Code__c);
                              //gsarec1.Proposal_SKU__c = 'ZCES-SUP-PREM-'+ (lowerlimit != '' && Upperlimit != '' ?  aliSO.Product_Code__c + '-'+ lowerlimit + '-' + Upperlimit : aliSO.Product_Code__c);
                              gsarec1.Quantity__c = aliSO.Apttus_Config2__Quantity__c;
                              gsarec1.Start_Date__c = premsupli.Apttus_QPConfig__StartDate__c;
                              gsarec1.End_Date__c = premsupli.Apttus_QPConfig__EndDate__c;
                              if(supportsource == 'List'){
                                  Decimal listPrice = baseExtended*(premiumSupportApplicableDays/sellingTerm_Days);
                                  Decimal lpsupportValue = (listPrice * (supportpercent/100)).setScale(2);
                                  Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((listPrice * (supportpercent/100)).setScale(2), premsupli.APTS_Total_Discount_Percentage__c);
                                  gsarec1.List_Price__c = lpsupportValue;
                                  gsarec1.Net_Price__c = supportValue;
                                  gsarec1.Price_Per_Unit__c = aliSO.Apttus_Config2__Quantity__c != null &&  aliSO.Apttus_Config2__Quantity__c != 0 ? supportValue / aliSO.Apttus_Config2__Quantity__c: 0;
                              }else{
                                  Decimal netPriceli = netPrice*(premiumSupportApplicableDays/sellingTerm_Days);
                                  Decimal lpsupportValue = (netPriceli * (supportpercent/100)).setScale(2);
                                  
                                  Decimal supportValue = APTS_PricingHelper.applyDiscountForPremiumSupport((netPriceli * (supportpercent/100)).setScale(2), premsupli.APTS_Total_Discount_Percentage__c);
                                  gsarec1.List_Price__c = lpsupportValue;
                                  gsarec1.Net_Price__c = supportValue;
                                  gsarec1.Price_Per_Unit__c =  aliSO.Apttus_Config2__Quantity__c != null &&  aliSO.Apttus_Config2__Quantity__c != 0 ? supportValue / aliSO.Apttus_Config2__Quantity__c: 0;
                              }
                              gsarec1.Total_Discount__c = premsupli.APTS_Total_Discount_Percentage__c;
                              gsarec1.APTS_Selling_Term__c = aliSO.APTS_Selling_Term__c;
                              
                              mappliidgsa.add(gsarec1);
                          }
                   }
                
            }
        }
        List<GSASort> gsl = new List<GSASort>();
        for(GSA_Price_List_Item__c gsa: mappliidgsa){
            gsl.add(new GSASort(gsa));
        }
        gsl.sort();
        mappliidgsa.clear();
        for(GSASort gs: gsl){
            mappliidgsa.add(gs.gsarec1);
        }
        insert mappliidgsa;
        List<Apttus_Proposal__Proposal__c> proplst = new List<Apttus_Proposal__Proposal__c>();
        if(!mappli.values().isEmpty() && mappli.values()[0] != null && mappli.values()[0].Apttus_Proposal__Proposal__c != null){
            Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c(id = mappli.values()[0].Apttus_Proposal__Proposal__c);
            prop.DAS_Seat_Mismatch_Line_Items_FedRamp__c = countofDASmismatch;
            proplst.add(prop);
        }
        if(!proplst.isEmpty()){
            update proplst;
        }
        
    }
    
    public class GSASort implements Comparable {
        public GSA_Price_List_Item__c gsarec1;
        
        public GSASort(GSA_Price_List_Item__c rec1){
            gsarec1 = rec1;
        }
        
        public Integer compareTo(Object compareTo) {
            GSASort gsarec2 = (GSASort)compareTo;
            if(gsarec1.Product__c == gsarec2.gsarec1.Product__c && !checkiframp.add(gsarec2.gsarec1.Product__c) && gsarec1.Quantity__c >= gsarec2.gsarec1.Quantity__c){
                return 1;
            }else{
                return 0;
            }
        }
    }
}