global with sharing class APTS_ValidationCallBack implements Apttus_Config2.CustomClass.IValidationCallback2 {

   static Apttus_Config2__ProductConfiguration__c prodConfigWrelFields;
   global Apttus_Config2.CustomClass.ValidationResult validateCart(Apttus_Config2.ProductConfiguration cart) {
        //this.cart = cart;
        Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
        prodConfigWrelFields = [Select Id,
                                        Account_Program_Type__c,
                                        SKU_codes__c,
                                        APTS_Quote_Record_Type__c,
                                        Yearly_Subscription_SKUs_ACV__c,
                                        Apttus_QPConfig__Proposald__c,
                                        Apttus_QPConfig__Proposald__r.APTS_ACV__c,
                                        allow_configure_when_ACV_less_than_5k__c,
                                        Apttus_Config2__FinalizedDate__c 
                                FROM Apttus_Config2__ProductConfiguration__c
                                Where Id = : cart.getConfigSO().Id Limit 1];  
        

        Decimal ttlziaqty = 0;
        Decimal ttlzpaqty = 0;

        List<Apttus_Config2__LineItem__c> lineItemLst = [select id, 
                                                                APTS_ProductCode__c,
                                                                Apttus_Config2__LineStatus__c, 
                                                                Renewal_Partner_Program__c,
                                                                APTS_ACV__c,
                                                                Apttus_Config2__Quantity__c,
                                                                Apttus_Config2__BasePrice__c,
                                                                APTS_Selling_Term__c,
                                                                Apttus_Config2__ConfigurationId__c,
                                                                Apttus_Config2__ConfigurationId__r.Account_Program_Type__c,
                                                                Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c,
                                                                Apttus_Config2__ConfigurationId__r.allow_configure_when_ACV_less_than_5k__c,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Allow_Work_from_Home_Promo__c,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c,
                                                                Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c,
                                                                Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name,
                                                                Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__BillToAccountId__r.Name  
                                                            from Apttus_Config2__LineItem__c 
                                                            where Apttus_Config2__ConfigurationId__c =: cart.getConfigSO().Id];
        Map<String,Apttus_Config2__LineItem__c> productListMap = new Map<String,Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c li : lineItemLst){
            productListMap.put(li.APTS_ProductCode__c,li);

            If((li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU)
                && li.Apttus_Config2__Quantity__c != Null){
                ttlziaqty = ttlziaqty + li.Apttus_Config2__Quantity__c;
            }else if((li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU
                || li.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS)
                && li.Apttus_Config2__Quantity__c != Null){
                ttlzpaqty = ttlzpaqty + li.Apttus_Config2__Quantity__c;
            }
        }
        if(lineItemLst.size() > 0) {  
            for( Apttus_Config2__LineItem__c lineVar : lineItemLst) {
                
                if(lineVar.APTS_ProductCode__c == APTS_CONSTANTS.PROD_SKU_WFH_PROMO && lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Allow_Work_from_Home_Promo__c == false) {
                    if(lineVar.Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c == APTS_CONSTANTS.P_RT_NBUSINESS ){
                     
                        if((!prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE) 
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU))
                            &&  prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_WFH_PROMO)){
                        
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ZIA_WFH));
                            result.isSuccess =  false;

                        }
                        if((!prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU) 
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZPA_PRO)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU)
                            && !prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_ZPA_BUS))
                            &&  prodConfigWrelFields.SKU_Codes__c.contains(APTS_CONSTANTS.PROD_SKU_WFH_PROMO)){
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ZIA_WFH));
                            result.isSuccess =  false;
                        }
                        if(ttlzpaqty != Null && ttlziaqty != Null && (ttlzpaqty < (ttlziaqty/2))) {
                            result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,Label.WFH_Zia_Zpa));
                            result.isSuccess =  false;
                        }
                    }
                    else{
                        result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,Label.ZPA_WFH));
                        result.isSuccess =  false;
                    }
                    
                }
                

                if(
                    (lineVar.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_CANCELLED || lineVar.Apttus_Config2__LineStatus__c == APTS_CONSTANTS.LI_STATUS_RENEWED ) 
                && (lineVar.Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c == APTS_CONSTANTS.P_RT_RENEWAL  || 
                lineVar.Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c ==  APTS_CONSTANTS.P_RT_UPSELL )) 
                {
                    if(lineVar.Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c != lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c)
                    /*If(
                        (
                            (lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == APTS_CONSTANTS.P_PARTNERPRG_LEGACY 
                                && 
                                (lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT 
                                || lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c == null)
                            ) 
                            || 
                            (lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT 
                                && 
                                (lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_LEGACY 
                                || lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.Primary_Partner_Program__c == null)
                            )
                        ) 
                        || 
                        lineVar.Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Name  != lineVar.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_QPConfig__BillToAccountId__r.Name 
                        ) */
                        {
                            if(lineVar.Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c == APTS_CONSTANTS.P_RT_RENEWAL) {
                                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PS_RENEW));
                                result.isSuccess =  false;
                            }
                            if(lineVar.Apttus_Config2__ConfigurationId__r.APTS_Quote_Record_Type__c ==  APTS_CONSTANTS.P_RT_UPSELL) {
                                result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PS_UPSELL));
                                result.isSuccess =  false;
                            }
                            // system.debug('Inside iffffff');
                            // result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'Your Partner Program is Different than your earlier Primary Quote'));
                            // result.isSuccess =  false;
                        }
                }
            }
        }
        /*Decimal temptotalACV = 0;
         Boolean acvtemp = false;
         if(lineItemLst != null && lineItemLst.size() > 0) {  
               for( Apttus_Config2__LineItem__c lineObj : lineItemLst) {
                  if(lineObj.Apttus_Config2__Quantity__c != Null && lineObj.Apttus_Config2__BasePrice__c != Null && lineObj.APTS_Selling_Term__c != Null){
                     temptotalACV += lineObj.Apttus_Config2__Quantity__c * lineObj.Apttus_Config2__BasePrice__c * (lineObj.APTS_Selling_Term__c / 12);
                  }
                  
               }
         }
        
         if(temptotalACV < 5000) {
               acvtemp = true;
         }
         
         if( acvtemp == true
               && prodConfigWrelFields.Account_Program_Type__c != 'MSP' 
               && prodConfigWrelFields.APTS_Quote_Record_Type__c == 'New Business' 
               && prodConfigWrelFields.allow_configure_when_ACV_less_than_5k__c == False ) {
               system.debug('in if===============valid');
               result.Messages.add(new ApexPages.Message(ApexPages.Severity.ERROR,'We cannot quote a deal under 5K ACV.'));
               result.isSuccess =  false;
         }*/ 
      return result;
   }
    

   global Apttus_Config2.CustomClass.ValidationResult validateRampLineItems(Apttus_Config2.ProductConfiguration cart, 
             List<Apttus_Config2.LineItem> rampLineItems) {
                Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
                  return result;
   }

   global Apttus_Config2.CustomClass.ValidationResult validateAssetItems(Apttus_Config2.ProductConfiguration cart,
             List<Apttus_Config2__TempRenew__c> assetItems) {
                Apttus_Config2.CustomClass.ValidationResult result = new Apttus_Config2.CustomClass.ValidationResult(true);
                return result;
   }
//    global void booster(){
//     integer i=0;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
//     i++;
    
//   }

}