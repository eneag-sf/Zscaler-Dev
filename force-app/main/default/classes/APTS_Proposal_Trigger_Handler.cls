/**
* APTTUS
* @author           Sanjay Nair
* Description:      Class that will manage almost all events for Proposal Trigger.
*                   This is master trigger handler, and deprecating existing triggers to merge in one master
* Changes (Version)
* -------------------------------------
*           No.                       Autor                   Descripción
*           -----   ----------      --------------------    ---------------
* @version   1.0    13-Nov-2016     Sanjay Nair             Creating Master trigger Class
* @version   1.1    18-Oct-2016     Hormese  Ambookken      Added function to find TCV and ACV
* @version   1.2    02-Nov-2016     Meera Kant              Changes to setQuoteDefaultValues(Date,Owner,Manager,BillToAcc,BillFreq,PayTerm)
* @version   1.3    04-Nov-2016     Harish Emmadi           Indented whole class and renamed setAccountPlatformValues method to doAccountCalculations.
*                                                           Refactored doAccountCalculations and added Account.APTS_Asset_SKU__c derivation upon quote Accept.
* @version   1.4    15-Nov-2016     Harish Emmadi           Updated setQuoteDefaultValues to change the derivation of Apttus_Proposal__Valid_Until_Date__c, Apttus_Proposal__ExpectedEndDate__c(upsell quote).
* @version   1.5    09-Dec-2016     Harish Emmadi           Updated setQuoteDefaultValuesAfterInsert to change the derivation of Apttus_Proposal__ExpectedEndDate__c(Renewal).
* @version   1.6    20-Dec-2016     Harish Emmadi           Updated setProposalFlags to add configuration Id derivation to be used in approvals.
* @version   1.7    31-Dec-2016     Harish Emmadi           Updated doAccountCalculations only include non-cancelled proposal lines, active assets from account for aseet sku codes. - [ZSCAL-260]
* @version   1.8    25-Mar-2017     Vijay Prakash           Updated updateFieldOnCart to update Start and End Dates in Product Configuration
* @version   1.9    11-May-2017     Vijay Prakash           Updated updateOpportunityValuesForPrimaryQuote method to stop updating the Opportunity's Amount field
* @version   2.0    30-03-2018      Vijay Prakash           Implemented the new year wise splits and commented out the existing year wise splits code
*************************************************************************************************************/

public class APTS_Proposal_Trigger_Handler{
    public void APTS_Proposal_Trigger_Handler(){}

    public void onBeforeUpdate(list<Apttus_Proposal__Proposal__c> lstNewProp, map<id,Apttus_Proposal__Proposal__c> mapOfOldProp){
        if(Test.isRunningTest()){
            booster();
        }
        if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
            Set<Id> billToAccount = new Set<Id>();
            List<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
            //    ThrowErrorForQuoteOnLockedOpty(lstNewProp);
            if(!TriggerUtility.isUpdatedQuoteExecuted()){
                TriggerUtility.oldQuoteMap = mapOfOldProp;
                TriggerUtility.UpdatedQuoteExecuted();
            }
            
            List<Id> userIdList = new List<Id>();
            Map<Id, Id> userIdManagerIdMap  = new Map<Id, Id>();
            for(Apttus_Proposal__Proposal__c prop : lstNewProp){
                if(prop.OwnerId != mapOfOldProp.get(prop.Id).OwnerId){
                    userIdList.add(prop.OwnerId);
                }
            }
            
            if(!userIdList.isEmpty()){
                for(User usr : [Select Id, ManagerId From User Where ManagerId != NULL AND Id IN: userIdList]){
                    userIdManagerIdMap.put(usr.Id, usr.ManagerId);
                }
            }
            
            for(Apttus_Proposal__Proposal__c prop : lstNewProp)
                setOwnerManagerOnQuote(prop, userIdManagerIdMap.get(prop.OwnerId));
            
            if(lstNewProp!=NULL && lstNewProp.size()>0)
            {
                list<Apttus_Proposal__Proposal__c> finalizationProposals = new list<Apttus_Proposal__Proposal__c>();
                list<Apttus_Proposal__Proposal__c> finalizationProposalsWithPrimaryQuote = new list<Apttus_Proposal__Proposal__c>();
                for(Apttus_Proposal__Proposal__c p : lstNewProp)
                {
                    setGeoVP(p);
                    
                    if(mapOfOldProp.get(p.id).Apttus_QPConfig__ConfigurationFinalizedDate__c != p.Apttus_QPConfig__ConfigurationFinalizedDate__c)
                    {
                        if(p.Apttus_Proposal__Primary__c) {
                            finalizationProposals.add(p);
                        }
                        finalizationProposalsWithPrimaryQuote.add(p);
                    }
                    
                    
                    
                    //Updating the frequency and payment terms from Bill to Account
                    if(p.Distributor__c != null
                       && mapOfOldProp.get(p.Id) != null
                       && p.Distributor__c != mapOfOldProp.get(p.Id).Distributor__c)
                    {
                        billToAccount.add(p.Distributor__c);
                        proposalsToBeUpdated.add(p);
                    }
                    
                    
                    // System.debug('Bose Old Status: mapOfOldProp.get(p.id).Apttus_Proposal__Approval_Stage__c: ' + mapOfOldProp.get(p.id).Apttus_Proposal__Approval_Stage__c);
                    // System.debug('Bose Old Status: p.Apttus_Proposal__Approval_Stage__c: ' + p.Apttus_Proposal__Approval_Stage__c);
                    
                    if(mapOfOldProp.get(p.id).Apttus_Proposal__Approval_Stage__c == 'Denied' &&
                       p.Apttus_Proposal__Approval_Stage__c == 'Approval Required')
                    {
                        p.Apttus_Proposal__Approval_Stage__c = 'Denied';
                    }
                    
                    if(mapOfOldProp.get(p.id).Apttus_Proposal__Approval_Stage__c == 'Cancelled' &&
                       p.Apttus_Proposal__Approval_Stage__c == 'Approval Required')
                    {
                        p.Apttus_Proposal__Approval_Stage__c = 'Cancelled';
                    }
                    
                    if(TriggerUtility.oldQuoteMap.get(p.id) != null && p.Apttus_Proposal__Approval_Stage__c == 'Approved' && TriggerUtility.oldQuoteMap.get(p.id).Apttus_Proposal__Approval_Stage__c != 'Approved'){
                        setApprovedValues(p, TriggerUtility.oldQuoteMap.get(p.id));
                    }
                    //(p.Apttus_Proposal__Approval_Stage__c == 'Cancelled' && TriggerUtility.oldQuoteMap.get(p.id).Apttus_Proposal__Approval_Stage__c != 'Cancelled')
                    boolean hasCancelledOrRejected = false;
                    
                    // if(p.Apttus_Proposal__Approval_Stage__c != 'Cancelled' && p.Apttus_QPApprov__Approval_Status__c == 'Cancelled' && mapOfOldProp.get(p.id).Apttus_QPApprov__Approval_Status__c != 'Cancelled'){
                    //     p.Apttus_Proposal__Approval_Stage__c = 'Cancelled';
                    //     hasCancelledOrRejected = true;
                    // }
                    
                    if(p.Apttus_QPApprov__Approval_Status__c == 'Cancelled'  &&  TriggerUtility.oldQuoteMap.get(p.id) != null && TriggerUtility.oldQuoteMap.get(p.id).Apttus_QPApprov__Approval_Status__c != 'Cancelled'){
                        p.Apttus_Proposal__Approval_Stage__c = 'Cancelled';
                        //    hasCancelledOrRejected = true;
                    }
                    
                    
                    if((p.Apttus_Proposal__Approval_Stage__c == 'Rejected' || p.Apttus_Proposal__Approval_Stage__c == 'Denied')  &&  TriggerUtility.oldQuoteMap.get(p.id) != null && (TriggerUtility.oldQuoteMap.get(p.id).Apttus_Proposal__Approval_Stage__c != 'Rejected' && TriggerUtility.oldQuoteMap.get(p.id).Apttus_Proposal__Approval_Stage__c != 'Denied')){
                        p.Apttus_Proposal__Approval_Stage__c = 'Rejected';
                        hasCancelledOrRejected = true;
                    }
                    
                    
                    if(p.Apttus_Proposal__Approval_Stage__c == 'Cancelled' || p.Apttus_Proposal__Approval_Stage__c == 'Rejected'){
                        //    p.Apttus_QPApprov__Approval_Status__c = '';
                    }
                    
                    if(p.Apttus_Proposal__Approval_Stage__c != 'In Review'){
                        p.Old_Approval_Process__c = false;
                    }
                    if(p.APTS_PLI_Count__c > 0 && TriggerUtility.oldQuoteMap.get(p.id) != null && p.Apttus_Proposal__Approval_Stage__c != 'In Review' && !hasCancelledOrRejected  && !p.Manual_Approval__c)
                        setResetApprovalRequired(p, TriggerUtility.oldQuoteMap.get(p.id));
                    //|| (p.Requires_Ramp_Approval__c != mapOfOldProp.get(p.id).Requires_Ramp_Approval__c && p.Requires_Ramp_Approval__c > mapOfOldProp.get(p.id).Requires_Ramp_Approval__c) || (p.No_Co_Term__c != mapOfOldProp.get(p.id).No_Co_Term__c && p.No_Co_Term__c > mapOfOldProp.get(p.id).No_Co_Term__c)
                    //if((p.Adjustments_Provided__c != mapOfOldProp.get(p.id).Adjustments_Provided__c && p.Adjustments_Provided__c > mapOfOldProp.get(p.id).Adjustments_Provided__c) ){
                    //    p.Apttus_QPApprov__Approval_Status__c = 'Approval Required';
                    //}
                }
                
                if(finalizationProposals.size() > 0)
                {
                    updateOpportunityValuesForPrimaryQuote(finalizationProposals);
                    updateOpportunityLineItemsForPrimaryQuote(finalizationProposals);
                }
                
                if(proposalsToBeUpdated.size() > 0)
                {
                    updateFromBillToAccount(billToAccount,proposalsToBeUpdated);
                }
                
                if(finalizationProposalsWithPrimaryQuote.size() > 0)
                {
                    calculateTotalofProposal(finalizationProposalsWithPrimaryQuote);
                    setFlagsForTemplates(finalizationProposalsWithPrimaryQuote);
                    updateEffectiveStartAndEndDates(finalizationProposalsWithPrimaryQuote);
                    updateliketolikewithAssetlinesfield(finalizationProposalsWithPrimaryQuote);
                    invokesalesordercalculation(finalizationProposalsWithPrimaryQuote);
                    invokePartnerMarginCalculation(finalizationProposalsWithPrimaryQuote);
                    invokeLegalLanguageExecution(finalizationProposalsWithPrimaryQuote);
                }
            }
            
            
            //CR #238
            updateSourceIPLicensingFlag(lstNewProp);        
        }
    }
    
    //CR #238
    private void updateSourceIPLicensingFlag(list<Apttus_Proposal__Proposal__c> lstNewProp){
        System.debug('---updateSourceIPLicensingFlag--called');
        
        set<ID> newUpsellDealIds = new set<ID>();
       
        Id newRecId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'New Business');
        Id upsellRecId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Upsell');
        
        for(Apttus_Proposal__Proposal__c prop : lstNewProp){
            //Quote Stage == New/Upsell Deals
            if(prop.RecordTypeId == newRecId || prop.RecordTypeId == upsellRecId){
                newUpsellDealIds.add(prop.Id);
            }else{
                prop.ZPA_AAC_Approval__c = false;
            }
        }
        
        System.debug('--newUpsellDealIds--'+newUpsellDealIds); 
        
        if(newUpsellDealIds.size()>0){
            
            
            Set<ID> proposalsWhereSKUPresent = new Set<ID>();
            MAP<ID, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalLineItemMAP = new  MAP<ID, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            
            for(Apttus_Proposal__Proposal_Line_Item__c ppl : [Select id,Apttus_Proposal__Proposal__c,name,APTS_Product_Code__c,Apttus_QPConfig__AssetLineItemId__c from Apttus_Proposal__Proposal_Line_Item__c 
                                                              where  Apttus_Proposal__Proposal__c in : newUpsellDealIds ])
            {
                //Chekc if To the existing ZPA Connector SKU ZPA-AAC-M1 
                if(ppl.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_AAC){
                    proposalsWhereSKUPresent.add(ppl.Apttus_Proposal__Proposal__c);
                }
                
                //Fill MAP [Apttus_Proposal__Proposal__c.ID---List<Apttus_Proposal__Proposal_Line_Item__c>]
                List<Apttus_Proposal__Proposal_Line_Item__c>  lineItemList = null;
                if(proposalLineItemMAP.containskey(ppl.Apttus_Proposal__Proposal__c)){
                    lineItemList = proposalLineItemMAP.get(ppl.Apttus_Proposal__Proposal__c);
                }else{
                    lineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                }
                lineItemList.add(ppl);
                proposalLineItemMAP.put(ppl.Apttus_Proposal__Proposal__c, lineItemList);
            }
            
            System.debug('--proposalsWhereSKUPresent--'+proposalsWhereSKUPresent); 
            
            //Get bill to Account ID Set
            MAP<ID,ID> AccountMAP = new MAP<ID,ID>();
            for(Apttus_Proposal__Proposal__c aptc : lstNewProp){
                if(proposalsWhereSKUPresent.contains(aptc.id) && aptc.Apttus_Proposal__Account__c != null){
                    AccountMAP.put(aptc.id,aptc.Apttus_Proposal__Account__c);
                }
            }
            
            //Fill Bill To Account with SKU
            MAP<ID,String> billToSKU = new MAP<ID,String>();
            for(Apttus_Config2__AssetLineItem__c asset : [Select ID,name, Product_Code__c, Apttus_Config2__AssetStatus__c,
                                                          Apttus_Config2__AccountId__c 
                                                          from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AssetStatus__c = 'Activated' and Apttus_Config2__AccountId__c in : AccountMAP.values()])
            {
                if(billToSKU.containskey(asset.Apttus_Config2__AccountId__c))
                {
                    String skuCode = billToSKU.get(asset.Apttus_Config2__AccountId__c) + ',' +asset.Product_Code__c;
                    billToSKU.put(asset.Apttus_Config2__AccountId__c, skuCode);
                }else {
                    billToSKU.put(asset.Apttus_Config2__AccountId__c, asset.Product_Code__c);
                }
            }
            
            for(Apttus_Proposal__Proposal__c proposal : lstNewProp){ 
                if(proposalsWhereSKUPresent.contains(proposal.id)){
                    
                    if(proposalLineItemMAP.containskey(proposal.id) && 
                        proposalLineItemMAP.get(proposal.id) != null)
                    {
                        boolean shouldGoForApproval =  false;
                        
                        String checkOne = '';
                        for(Apttus_Proposal__Proposal_Line_Item__c pplitem : proposalLineItemMAP.get(proposal.id)){
                            checkOne+=pplitem.APTS_Product_Code__c+'#';
                        }
                        System.debug('checkOne----'+checkOne);
                        if(checkOne.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_PRO) ||
                           checkOne.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_BUS) ||
                           checkOne.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU) ||
                           checkOne.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZB2B_PRO_PRE) ||
                           checkOne.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZB2B_BUS_PRE) 
                          )
                        {
                            shouldGoForApproval = false;
                        }else{
                            shouldGoForApproval = true; 
                        }
                        System.debug('InCheck 1----shouldGoForApproval--'+shouldGoForApproval);
                        
                        if(shouldGoForApproval){
                            //check for Install Base.
                            String checkTwo = '';
                            if(AccountMAP.containskey(proposal.id) && AccountMAP.get(proposal.id) != null){
                                checkTwo = billToSKU.get(AccountMAP.get(proposal.id));
                            }
                            if(checkTwo != null &&
                               (
                                   checkTwo.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_PRO) ||
                                   checkTwo.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_BUS) ||
                                   checkTwo.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU) ||
                                   checkTwo.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZB2B_PRO_PRE) ||
                                   checkTwo.containsIgnoreCase(APTS_CONSTANTS.PROD_SKU_ZB2B_BUS_PRE)   
                               )
                              )
                            {
                                shouldGoForApproval = false;
                            }else{
                                shouldGoForApproval = true; 
                            }
                            System.debug('InCheck 2----shouldGoForApproval--'+shouldGoForApproval);
                        }
                        System.debug('shouldGoForApproval----'+shouldGoForApproval);
                        if(shouldGoForApproval){
                            proposal.ZPA_AAC_Approval__c = true;
                        }else{
                            proposal.ZPA_AAC_Approval__c = false;
                        }
                    }   
                    
                }else{
                    proposal.ZPA_AAC_Approval__c = false;
                }
            }
        }
    } 
    
    
        public static void setGeoVP(Apttus_Proposal__Proposal__c  newProp){
            String userGeo  = (newProp.APTS_User_Geo__c != '' || newProp.APTS_User_Geo__c != null) ? newProp.APTS_User_Geo__c : '';
            string salesVPUserId = '';
            if(userGeo == 'Americas'){
                salesVPUserId  = ZscalerSetting__c.getValues('AMER Sales VP').Value__c;
            }else if(userGeo == 'EMEA'){
                salesVPUserId  = ZscalerSetting__c.getValues('EMEA Sales VP').Value__c;
            }else if(userGeo == 'APAC'){
                salesVPUserId  = ZscalerSetting__c.getValues('APAC Sales VP').Value__c;
            }
            newProp.GEO_VP__c = salesVPUserId == '' ? null  :  salesVPUserId;
        }
        public static void resetApprovedFieldValues(Apttus_Proposal__Proposal__c  newProp){
            newProp.Approved_Adjustment_Over_Partners__c = 0;
            newProp.Approved_Net_Discount_W_O_Support__c = 0 ;
            newProp.Approved_TCV__c = 0 ;
            newProp.Approved_Total_Discount__c = 0 ;
            newProp.Approved_Total_Support_Discount__c = 0;
            newProp.Approved_Subscription_Term__c = 0;
            newProp.Approved_Ramp_Value__c = 0;
            newProp.Approved_No_Co_Term__c = 0;
            newProp.Approved_No_Co_Term_ZPA__c = 0;
            newProp.Approved_Buy_Back__c = 0;
            newProp.Approved_DAS_Seat_Mismatch_Line_Items__c = 0;
            newProp.Approved_DAS_Seat_Mismatch_Lines_FedRamp__c = 0;
            newProp.Approved_NFR__c = 0;
            newProp.Approved_One_Time_Credit__c = 0;
            newProp.Approved_Professional_Services__c = 0;
            newProp.Approved_Total_ZPA_Adjustment__c = 0;
            newProp.Approved_Zscaler_Extend_Transaction_Log__c = 0;
            newProp.Approved_ZPA_Enterprise__c = 0;
            newProp.Approved_Billing_Frequency__c = false;
            newProp.Approved_Payment_Term__c = false;
            newProp.Approved_Renewal_MRR_Decrease__c = 0;
            newProp.Approved_ZAB_Count__c = 0;
            newProp.Approved_ThreatLabz_Count__c = 0;
            newProp.Approved_Z_O365_PRE__c = false;
            newProp.Approved_Light_Bundles__c = '';
            newProp.Approved_VIP_Promotion__c = false;
            newProp.Approved_Special_Guest_Promotion__c = false;
            newProp.Approved_FedRamp_Products__c = false;
            newProp.Approved_ZDLP_EDM__c = false;
            newProp.Approved_ACV__c = 0;
            newProp.Is_ZPA_100_Seats_Promo_Approved__c = 0;
            newProp.Approved_New_DAS_with_more_than_10_Disc__c = false;
            newProp.Approved_ZIA_Reserved_ZEN__c = false;
            newProp.Approved_Isolation_SKUs__c = false;
            
            //CR# 223 - Abhishek V - Early_Adopter - Start
            newProp.Approved_Early_Adopter__c = false;
            //CR# 223 - Abhishek V - Early_Adopter - End
            //CR# 222 -Minkesh Patel - Approved_WFH_Promo__c - Start
            newProp.Approved_WFH_Promo__c = false;
            //CR# 222 - Minkesh Patel - Approved_WFH_Promo__c - End
            
            //Changes by Gurjinder for New Pre SKU:Start
            newProp.Approved_Data_Protection_Bundle__c = false;
            newProp.Approved_Saas_CASB_API__c = false;
            //Changes by Gurjinder for New Pre SKU:End
        }

    public static void setApprovedValues(Apttus_Proposal__Proposal__c  newProp, Apttus_Proposal__Proposal__c oldProp){
        newProp.Approved_Adjustment_Over_Partners__c = oldProp.Adjustments_Provided__c   ;
        newProp.Approved_Net_Discount_W_O_Support__c = oldProp.Net_Discount_W_O_Support__c ;
        newProp.Approved_TCV__c = oldProp.Net_TCV__c ;
        //APTS_Proposal_Net_Price__c
        newProp.Approved_Total_Discount__c = oldProp.Total_Discount_Without_Support__c ;
        newProp.Approved_Total_Support_Discount__c = oldProp.Average_Support_Discount__c ;
        // Add Logic for Record type
        if((newProp.APTS_Record_Type_Name__c == APTS_CONSTANTS.P_RT_NBUSINESS || newProp.APTS_Record_Type_Name__c == APTS_CONSTANTS.P_RT_RENEWAL) && newProp.APTS_Enterprise_Account__c )
            newProp.Approved_Subscription_Term__c = oldProp.APTS_Subscription_Term__c ;
        newProp.Approved_Ramp_Value__c = oldProp.Requires_Ramp_Approval__c;
        newProp.Approved_No_Co_Term__c = oldProp.No_Co_Term__c;
        newProp.Approved_No_Co_Term_ZPA__c = oldProp.No_Co_Term_ZPA__c;
        newProp.Approved_Buy_Back__c = oldProp.Buy_Back__c;
        newProp.Approved_DAS_Seat_Mismatch_Line_Items__c = oldProp.DAS_Seat_Mismatch_Line_Items__c;
        newProp.Approved_DAS_Seat_Mismatch_Lines_FedRamp__c = oldProp.DAS_Seat_Mismatch_Line_Items_FedRamp__c;
        newProp.Approved_NFR__c = oldProp.NFR__c;
        newProp.Approved_One_Time_Credit__c = oldProp.One_Time_Credit__c;
        newProp.Approved_Professional_Services__c = oldProp.Professional_Services__c;
        newProp.Approved_ZAB_Count__c = oldProp.ZAB_Count__c;
        newProp.Approved_Total_ZPA_Adjustment__c = oldProp.Total_ZPA_Adjustment__c;
        newProp.Approved_Zscaler_Extend_Transaction_Log__c = oldProp.Zscaler_Extend_Transaction_Log__c;
        newProp.Approved_ZPA_Enterprise__c = oldProp.ZPA_Enterprise__c;
        newProp.Approved_Renewal_MRR_Difference__c = oldProp.Renewal_MRR_Difference__c;
        if(newProp.Partner_Involved__c){
            newProp.Approved_Billing_Frequency__c = oldProp.APTS_Partner_Billing_Frequency__c ? false : true;
            newProp.Approved_Payment_Term__c = oldProp.APTS_Partner_Payment_Term__c ? false : true;
        }
        newProp.Approved_ThreatLabz_Count__c = oldProp.ThreatLabz_Service_SKU_Count__c;
        newProp.Approved_ZDLP_EDM__c = oldProp.ZDLP_EDM__c;
        newProp.Approved_ACV__c = oldProp.APTS_ACV__c;
        newProp.Approved_Z_O365_PRE__c = oldProp.Z_O365_PRE__c;
        newProp.Approved_Light_Bundles__c = oldProp.Light_Bundle_Family_Cart__c;
        newProp.Approved_Special_Guest_Promotion__c = oldProp.Contains_Special_Guest_Promotion__c;
        newProp.Approved_VIP_Promotion__c = oldProp.Contains_VIP_Promotion__c;
        newProp.Approved_FedRamp_Products__c = oldProp.Fedramp_SKU_Present__c;
        newProp.Approved_Maximum_Ramp_Line_Item_Sequence__c = oldProp.Maximum_Ramp_Line_Item_Sequence__c;
        newProp.Is_ZPA_100_Seats_Promo_Approved__c = oldProp.Is_ZPA_100_Seats_Promo_Present__c;
        newProp.Approved_New_DAS_with_more_than_10_Disc__c = oldProp.Contains_New_DAS_with_more_than_10_Disc__c;
        newProp.Approved_ZIA_Reserved_ZEN__c = oldProp.Contains_ZIA_Reserved_ZEN__c;
        //newProp.Approved_Isolation_SKUs__c = oldProp.Contains_Isolation_SKUs__c;//Minkesh Patel CR#35
        //commented 4/5/2020
        //newProp.Approved_Isolation_SKUs__c = oldProp.Contains_PRE_SKU__c;//Minkesh Patel CR#35
        //Changes by Gurjinder for New Pre SKU:Start
        newProp.Approved_Data_Protection_Bundle__c = oldProp.Contains_Data_Protection_Bundle__c;
        newProp.Approved_Saas_CASB_API__c = oldProp.Contains_Saas_CASB_API__c;
        //Changes by Gurjinder for New Pre SKU:End
        //CR# 223 - Abhishek V - Early_Adopter - Start
        newProp.Approved_Early_Adopter__c = oldProp.Contains_Early_PROMO__c;
        //CR# 223 - Abhishek V - Early_Adopter - End
        //CR# 222
        newProp.Approved_Early_Adopter__c = oldProp.Contains_WFH_Promo__c;
        //CR# 222
    }

    public void setOwnerManagerOnQuote(Apttus_Proposal__Proposal__c  newProp, Id managerId){
        if(managerId != null)
            newProp.APTS_User_Manager__c = managerId;
    }
    
    public void setResetApprovalRequired(Apttus_Proposal__Proposal__c  newProp, Apttus_Proposal__Proposal__c oldProp){
        
        boolean approvalRequired = false;
        boolean isUnderApprovalorReq = false;
        
        boolean hasChangesApprovalReq = false;
        
        if(newProp.Apttus_Proposal__Approval_Stage__c == 'In Review'){
            isUnderApprovalorReq = true;
        }
        
        if(!approvalRequired && ((newProp.Adjustments_Provided__c > 5 && (newProp.Approved_Adjustment_Over_Partners__c ==  null || newProp.Approved_Adjustment_Over_Partners__c == 0)) ||
                                 (newProp.Adjustments_Provided__c > 5 && newProp.Approved_Adjustment_Over_Partners__c < newProp.Adjustments_Provided__c )))
        {
            system.debug(' # Adjustment : '+approvalRequired);
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        /*
            if(!approvalRequired && ((newProp.Net_Discount_W_O_Support__c > 25 && (newProp.Approved_Net_Discount_W_O_Support__c ==  null || newProp.Approved_Net_Discount_W_O_Support__c == 0)) ||
            (newProp.Net_Discount_W_O_Support__c > 25 && newProp.Approved_Net_Discount_W_O_Support__c < newProp.Net_Discount_W_O_Support__c ) )){
            approvalRequired = true;
            hasChangesApprovalReq = true;
            }
        */
        if(!approvalRequired && ((newProp.Net_TCV__c > 25000 && (newProp.Approved_TCV__c ==  null || newProp.Approved_TCV__c == 0)) ||
                                 (newProp.Net_TCV__c > 25000 && newProp.Approved_TCV__c < newProp.Net_TCV__c ) &&
                                 ((newProp.Total_Discount_Without_Support__c > 60 && (newProp.Approved_Total_Discount__c ==  null || newProp.Approved_Total_Discount__c == 0)) ||
                                  (newProp.Total_Discount_Without_Support__c > 60 && newProp.Approved_Total_Discount__c < newProp.Total_Discount_Without_Support__c ))))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Renewal_MRR_Difference__c > 0 && (newProp.Approved_Renewal_MRR_Difference__c ==  null || newProp.Approved_Renewal_MRR_Difference__c == 0)) ||
                                 (newProp.Renewal_MRR_Difference__c > 0 && newProp.Approved_Renewal_MRR_Difference__c < newProp.Renewal_MRR_Difference__c )))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Average_Support_Discount__c > 20 && (newProp.Approved_Total_Support_Discount__c ==  null || newProp.Approved_Total_Support_Discount__c == 0)) ||
                                 (newProp.Average_Support_Discount__c > 20 && newProp.Approved_Total_Support_Discount__c < newProp.Average_Support_Discount__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Requires_Ramp_Approval__c > 0 && (newProp.Approved_Ramp_Value__c ==  null || newProp.Approved_Ramp_Value__c == 0)) ||
                                 (newProp.Requires_Ramp_Approval__c > 0 && newProp.Approved_Ramp_Value__c < newProp.Requires_Ramp_Approval__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Maximum_Ramp_Line_Item_Sequence__c > 0 && newProp.APTS_Subscription_Term__c < 36 && (newProp.Approved_Maximum_Ramp_Line_Item_Sequence__c ==  null || newProp.Approved_Maximum_Ramp_Line_Item_Sequence__c == 0)) ||
                                 (newProp.Maximum_Ramp_Line_Item_Sequence__c > 0 && newProp.APTS_Subscription_Term__c < 36 && newProp.Approved_Ramp_Value__c < newProp.Requires_Ramp_Approval__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && newProp.APTS_Enterprise_Account__c && (newProp.APTS_Record_Type_Name__c == APTS_CONSTANTS.P_RT_NBUSINESS || newProp.APTS_Record_Type_Name__c == APTS_CONSTANTS.P_RT_RENEWAL) && ((newProp.APTS_Subscription_Term__c < 36 && (newProp.Approved_Subscription_Term__c ==  null || newProp.Approved_Subscription_Term__c == 0)) ||
                                                                                                                                                                                                                 (newProp.APTS_Subscription_Term__c < 36 && newProp.Approved_Subscription_Term__c > newProp.APTS_Subscription_Term__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.No_Co_Term__c > 0 && (newProp.Approved_No_Co_Term__c ==  null || newProp.Approved_No_Co_Term__c == 0)) ||
                                 (newProp.No_Co_Term__c > 0 && newProp.Approved_No_Co_Term__c < newProp.No_Co_Term__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.No_Co_Term_ZPA__c > 0 && (newProp.Approved_No_Co_Term_ZPA__c ==  null || newProp.Approved_No_Co_Term_ZPA__c == 0)) ||
                                 (newProp.No_Co_Term_ZPA__c > 0 && newProp.Approved_No_Co_Term_ZPA__c < newProp.No_Co_Term_ZPA__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Buy_Back__c > 0 && (newProp.Approved_Buy_Back__c ==  null || newProp.Approved_Buy_Back__c == 0)) ||
                                 (newProp.Buy_Back__c > 0 && newProp.Approved_Buy_Back__c < newProp.Buy_Back__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.DAS_Seat_Mismatch_Line_Items__c > 0 && (newProp.Approved_DAS_Seat_Mismatch_Line_Items__c ==  null || newProp.Approved_DAS_Seat_Mismatch_Line_Items__c == 0)) ||
                                 (newProp.DAS_Seat_Mismatch_Line_Items__c > 0 && newProp.Approved_DAS_Seat_Mismatch_Line_Items__c < newProp.DAS_Seat_Mismatch_Line_Items__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.DAS_Seat_Mismatch_Line_Items_FedRamp__c > 0 && (newProp.Approved_DAS_Seat_Mismatch_Lines_FedRamp__c ==  null || newProp.Approved_DAS_Seat_Mismatch_Lines_FedRamp__c == 0)) ||
                                 (newProp.DAS_Seat_Mismatch_Line_Items_FedRamp__c > 0 && newProp.Approved_DAS_Seat_Mismatch_Lines_FedRamp__c < newProp.DAS_Seat_Mismatch_Line_Items_FedRamp__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.NFR__c > 0 && (newProp.Approved_NFR__c ==  null || newProp.Approved_NFR__c == 0)) ||
                                 (newProp.NFR__c > 0 && newProp.Approved_NFR__c < newProp.NFR__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.One_Time_Credit__c > 0 && (newProp.Approved_One_Time_Credit__c ==  null || newProp.Approved_One_Time_Credit__c == 0)) ||
                                 (newProp.One_Time_Credit__c > 0 && newProp.Approved_One_Time_Credit__c < newProp.One_Time_Credit__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Professional_Services__c > 0 && (newProp.Approved_Professional_Services__c ==  null || newProp.Approved_Professional_Services__c == 0)) ||
                                 (newProp.Professional_Services__c > 0 && newProp.Approved_Professional_Services__c < newProp.Professional_Services__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.ZAB_Approved_Account__c != true && ((newProp.ZAB_Count__c > 0 && (newProp.Approved_ZAB_Count__c ==  null || newProp.Approved_ZAB_Count__c == 0)) ||
                                                                             (newProp.ZAB_Count__c > 0 && newProp.Approved_ZAB_Count__c < newProp.ZAB_Count__c )))) 
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.ELA_Approved_Opportunity__c != true && newProp.Has_ZIA_ELA_SKU__c == true)) 
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.Total_ZPA_Adjustment__c > 0 && (newProp.Approved_Total_ZPA_Adjustment__c ==  null || newProp.Approved_Total_ZPA_Adjustment__c == 0)) ||
                                 (newProp.Total_ZPA_Adjustment__c > 0 && newProp.Approved_Total_ZPA_Adjustment__c < newProp.Total_ZPA_Adjustment__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && newProp.APTS_User_Geo__c != null && newProp.APTS_User_Geo__c.equalsIgnoreCase('AMERICAS') && ((newProp.Zscaler_Extend_Transaction_Log__c > 0 && (newProp.Approved_Zscaler_Extend_Transaction_Log__c ==  null || newProp.Approved_Zscaler_Extend_Transaction_Log__c == 0)) ||
                                                                                                                              (newProp.Zscaler_Extend_Transaction_Log__c > 0 && newProp.Approved_Zscaler_Extend_Transaction_Log__c < newProp.Zscaler_Extend_Transaction_Log__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((newProp.ZPA_Enterprise__c > 0 && (newProp.Approved_ZPA_Enterprise__c ==  null || newProp.Approved_ZPA_Enterprise__c == 0)) ||
                                 (newProp.ZPA_Enterprise__c > 0 && newProp.Approved_ZPA_Enterprise__c < newProp.ZPA_Enterprise__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && newProp.Contains_New_DAS_with_more_than_10_Disc__c && !newProp.Approved_New_DAS_with_more_than_10_Disc__c )
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        
        if(!approvalRequired && newProp.Special_Term__c != null && newProp.Special_Term__c != '' && newProp.Special_Term__c != oldProp.Special_Term__c ){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }else if((newProp.Special_Term__c == '' || newProp.Special_Term__c == NULL) && newProp.Special_Term__c != oldProp.Special_Term__c )
        {
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && !newProp.APTS_Partner_Billing_Frequency__c && !newProp.Approved_Billing_Frequency__c && newProp.Partner_Involved__c){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && !newProp.APTS_Partner_Payment_Term__c && !newProp.Approved_Payment_Term__c && newProp.Partner_Involved__c){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (((newProp.ThreatLabz_Service_SKU_Count__c > 0) && (newProp.Approved_ThreatLabz_Count__c ==  null || newProp.Approved_ThreatLabz_Count__c == 0)) ||
                                 (newProp.ThreatLabz_Service_SKU_Count__c > 0 && newProp.Approved_ThreatLabz_Count__c < newProp.ThreatLabz_Service_SKU_Count__c ) ))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.Z_O365_PRE__c) && (newProp.Approved_Z_O365_PRE__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        //Changes by Gurjinder for Adding New Pre Sku:Start
        if(!approvalRequired && (newProp.Contains_Data_Protection_Bundle__c) && (newProp.Approved_Data_Protection_Bundle__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.Contains_Saas_CASB_API__c) && (newProp.Approved_Saas_CASB_API__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        } 
        //Changes by Gurjinder for Adding New Pre Sku:End
        
        if(!approvalRequired && (newProp.Contains_ZIA_Reserved_ZEN__c) && (newProp.Approved_ZIA_Reserved_ZEN__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        //CR# 223 - Abhishek V - Early_Adopter - Start
        if(!approvalRequired && (newProp.Contains_Early_PROMO__c) && (newProp.Approved_Early_Adopter__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        //CR# 223 - Abhishek V - Early_Adopter - End
        //CR# 222
        if(!approvalRequired && (newProp.Allow_Work_from_Home_Promo__c) && (newProp.Approved_WFH_Promo__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        //CR# 222
        
        
        // if(!approvalRequired && (newProp.Contains_Isolation_SKUs__c) && (newProp.Approved_Isolation_SKUs__c == false)){
        //     approvalRequired = true;
        //     hasChangesApprovalReq = true;
        // }//commented for CR#35
        
        // //CR#35 - Minkesh //commented 4/5/2020
        // if( !approvalRequired && (newProp.Contains_PRE_SKU__c) && (newProp.Approved_Isolation_SKUs__c == false) )
        // {
        //     if(newProp.APTS_Record_Type_Name__c == 'Renewal' && newProp.Isolation_SKUs__c == false){
        //         approvalRequired = true;
        //         hasChangesApprovalReq = true;
        //     }
        //     else{
        //         approvalRequired = true;
        //         hasChangesApprovalReq = true;   
        //     }
        // }
        // //CR#35 - Minkesh - end
        
        
        if(!approvalRequired && newProp.Approved_Light_Bundles__c != newProp.Light_Bundle_Family_Cart__c){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.Contains_Special_Guest_Promotion__c) && (newProp.Approved_Special_Guest_Promotion__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.Contains_VIP_Promotion__c) && (newProp.Approved_VIP_Promotion__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.Fedramp_SKU_Present__c) && (newProp.Approved_FedRamp_Products__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && (newProp.ZDLP_EDM__c) && (newProp.Approved_ZDLP_EDM__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if(!approvalRequired && ((((newProp.APTS_ACV__c > 25000 && newProp.APTS_ACV__c <= 100000)
                                   && (newProp.APTS_Record_Type_Name__c == 'Upsell' || newProp.APTS_Record_Type_Name__c == 'Renewal'))
                                  || (newProp.APTS_ACV__c > 0 && newProp.APTS_ACV__c <= 25000))
                                 && (newProp.Approved_ACV__c == 0 || newProp.Approved_ACV__c < newProp.APTS_ACV__c)))
        {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        
        if (!approvalRequired && (newProp.Is_ZPA_100_Seats_Promo_Present__c == 1 && newProp.Is_ZPA_100_Seats_Promo_Approved__c != 1)) {
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        //Added By Minkesh for Work from Home Promo
        if(!approvalRequired && (newProp.Allow_Work_from_Home_Promo__c) && (newProp.Approved_WFH_Promo__c == false)){
            approvalRequired = true;
            hasChangesApprovalReq = true;
        }
        //End for Work from Home Promo
        
        if(hasChangesApprovalReq ){
            
            if(approvalRequired && !isUnderApprovalorReq){
                newProp.Apttus_Proposal__Approval_Stage__c = APTS_CONSTANTS.P_APPROVALSTATUS_REQUIRED;
                newProp.Apttus_QPApprov__Approval_Status__c = APTS_CONSTANTS.P_APPROVALSTATUS_REQUIRED;
            }else if(!approvalRequired && !isUnderApprovalorReq ){
                newProp.Apttus_Proposal__Approval_Stage__c = 'Approved';
                newProp.Apttus_QPApprov__Approval_Status__c = 'Approved';
            }
        }
    }

    private void setFlagsForTemplates(list<Apttus_Proposal__Proposal__c> lstNewProp)
    {
        Map<Id,Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        for(Apttus_Proposal__Proposal__c proposal : lstNewProp)
        {
            proposalMap.put(proposal.Id, proposal);
        }
        Boolean hasRecurring = false;
        Set<String> SKUcodes = new Set<String>{APTS_CONSTANTS.PROD_SKU_Z_CREDIT,APTS_CONSTANTS.PROD_SKU_WFH_PROMO, APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO, APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO, APTS_CONSTANTS.PROD_SKU_ZPA_PROMO, APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU, APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU, APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU, APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU, APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU, APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU};
            Map<Id, List<Apttus_Config2__LineItem__c>> proposalLineItems  = new Map<Id, List<Apttus_Config2__LineItem__c>>();
        for(Apttus_Config2__LineItem__c lineItem : [Select id,name,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.ProductCode,                                                           Apttus_Config2__PriceType__c, Apttus_Config2__LineStatus__c, 
                                                    Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c,         Apttus_Config2__StartDate__c
                                                    From Apttus_Config2__LineItem__c
                                                    Where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN :lstNewProp
                                                    AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'
                                                    and (Apttus_Config2__PriceType__c='One Time' OR Apttus_Config2__PriceType__c='Recurring'
                                                         OR Apttus_Config2__ProductId__r.ProductCode in :SKUcodes/*APTS_CONSTANTS.PROD_SKU_Z_CREDIT
                                                        OR Apttus_Config2__ProductId__r.ProductCode = :APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO
                                                        OR Apttus_Config2__ProductId__r.ProductCode = :APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO
                                                        OR Apttus_Config2__ProductId__r.ProductCode = :APTS_CONSTANTS.PROD_SKU_ZPA_PROMO*/)
                                                    order by Apttus_Config2__StartDate__c])
        {
            if(proposalLineItems.containsKey(lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c))
            {
                proposalLineItems.get(lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).add(lineItem);
            }
            else
            {
                List<Apttus_Config2__LineItem__c> tmpList = new List<Apttus_Config2__LineItem__c>();
                tmpList.add(lineItem);
                proposalLineItems.put(lineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, tmpList);
            }
        }
        
        for(Id proposalId : proposalLineItems.keySet())
        {
            Apttus_Proposal__Proposal__c proposal = proposalMap.get(proposalId);
            proposal.APTS_Buy_Back_Present__c = false;
            proposal.APTS_One_Time_Products_Present__c = false;
            proposal.One_Time_Credit_Present__c = false;
            proposal.Light_Bundle_Family_Cart__c = '';
            proposal.Contains_Data_Protection_Bundle__c=false;  //Added by Gurjinder for New Pre SKU        
            proposal.Contains_Saas_CASB_API__c=false;           //Added by Gurjinder for New Pre SKU
            Boolean iszialightbundlepresent = false;
            Boolean iszpalightbundlepresent = false;
            
            //#222 added by Minkesh
            proposal.Allow_Work_from_Home_Promo__c = false;
            Boolean isWorkFromHomePresent = false;
            
            List<Apttus_Config2__LineItem__c> lineItems = proposalLineItems.get(proposalId);
            for(Apttus_Config2__LineItem__c lineItem : lineItems){
                //if(lineItem.Apttus_Config2__PriceType__c == 'One Time'){
                if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_BUYBACK
                   || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_BUYBACK) {
                       proposal.APTS_Buy_Back_Present__c = true;
                   }
                else if (lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_Z_CREDIT ||lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_WFH_PROMO || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_PROMO || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_CFWZPA_PROMO)
                {
                    proposal.One_Time_Credit_Present__c = true;
                }
                else if (lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_CLOUD_PROMO || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZLIVE_VIPC || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZLIVE_SPG || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZLIVE_TEAM || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZLIVE_WOMENINTECH || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZLIVE_EARLYBIRD)
                {
                    proposal.One_Time_Credit_Present__c = true;
                }
                else if(lineItem.Apttus_Config2__PriceType__c == 'One Time')
                {
                    proposal.APTS_One_Time_Products_Present__c = true;
                }
                //}
                if(lineItem.Apttus_Config2__PriceType__c == 'Recurring'){       
                    hasRecurring = true;     
                }
                if(lineItem.Apttus_Config2__LineStatus__c != 'Cancelled' ){
                    if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU
                       || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU){       
                           iszpalightbundlepresent = true; 
                       }else if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                                || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                                || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                                || lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU){       
                                    iszialightbundlepresent = true;    
                                }
                    //#222 Added By minkesh
                    else if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_WFH_PROMO)
                    {
                        proposal.Allow_Work_from_Home_Promo__c =true;
                    }
                    //Added by Gurjinder for New Pre SKU
                    if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.DATA_PROTECTION_BUNDLE){
                        proposal.Contains_Data_Protection_Bundle__c=true;
                    }
                    if(lineItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.SAAS_CASB_API){
                        proposal.Contains_Saas_CASB_API__c=true;
                    }
                    //Added by Gurjinder for New Pre SKU
                }
            }
            proposal.No_Subscription_in_Quote__c = !hasRecurring;
            proposal.Light_Bundle_Family_Cart__c = iszpalightbundlepresent && iszialightbundlepresent ? 'ZIA/ZPA' : iszialightbundlepresent ? 'ZIA' : iszpalightbundlepresent ? 'ZPA' : '';
        }
    }

    public void onBeforeInsert(list<Apttus_Proposal__Proposal__c> lstNewProp){
        //    ThrowErrorForQuoteOnLockedOpty(lstNewProp);
        if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
            setQuoteDefaultValues(lstNewProp);
            System.debug('>>>> : TriggerUtility.isUpdateProposalPriceListExecuted(): ' + TriggerUtility.isUpdateProposalPriceListExecuted());
            if (!TriggerUtility.isUpdateProposalPriceListExecuted()) {
                setQuotePriceListFromAdminSetting(lstNewProp);
            }
            TriggerUtility.updateProposalPriceListExecuted();
        }
    }


    public void onAfterUpdate(list<Apttus_Proposal__Proposal__c> lstNewProp, map<id,Apttus_Proposal__Proposal__c> mapOfOldProp){
        if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
                // updateFieldOnCart(){
                /*List<Apttus_Config2__ProductConfiguration__c> listOfUpdatedCart = new List<Apttus_Config2__ProductConfiguration__c>();

                for(Apttus_Proposal__Proposal__c p: [SELECT Id, Name, Apttus_Proposal__ExpectedStartDate__c, APTS_Billing_Frequency__c,
                                                        APTS_Has_Custom_Terms__c, APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Current_Quote_TCV__c,
                                                        Apttus_Proposal__Payment_Term__c, APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c,
                                                        APTS_User_Manager__c, APTS_Record_Type_Name__c, Apttus_Proposal__ExpectedEndDate__c,
                                                        (SELECT Id, APTS_Payment_Term__c, APTS_Billing_Frequency__c, APTS_Has_Custom_Terms__c,
                                                            APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Current_Quote_TCV__c,
                                                            APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c, APTS_User_Manager__c, APTS_Quote_Record_Type__c
                                                            FROM Apttus_QPConfig__Configurations__r
                                                            WHERE Apttus_Config2__Status__c = 'Saved' ORDER BY LastModifiedDate desc LIMIT 1)
                                                    FROM Apttus_Proposal__Proposal__c where Id IN: lstNewProp]){
                    if(p.Apttus_QPConfig__Configurations__r.size() > 0
                        && (mapOfOldProp.get(p.Id).Apttus_Proposal__Payment_Term__c != p.Apttus_Proposal__Payment_Term__c
                        || mapOfOldProp.get(p.Id).APTS_Billing_Frequency__c != p.APTS_Billing_Frequency__c
                        || mapOfOldProp.get(p.Id).APTS_Has_Custom_Terms__c != p.APTS_Has_Custom_Terms__c
                        || mapOfOldProp.get(p.Id).APTS_Current_Quote_MRR__c != p.APTS_Current_Quote_MRR__c
                        || mapOfOldProp.get(p.Id).APTS_Original_Quote_MRR__c != p.APTS_Original_Quote_MRR__c
                        || mapOfOldProp.get(p.Id).APTS_Current_Quote_TCV__c != p.APTS_Current_Quote_TCV__c
                        || mapOfOldProp.get(p.Id).APTS_Original_Quote_TCV__c != p.APTS_Original_Quote_TCV__c
                        || mapOfOldProp.get(p.Id).APTS_Enterprise_Account__c != p.APTS_Enterprise_Account__c
                        || mapOfOldProp.get(p.Id).APTS_User_Manager__c != p.APTS_User_Manager__c
                        || mapOfOldProp.get(p.Id).APTS_Record_Type_Name__c != p.APTS_Record_Type_Name__c)
                    ){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Payment_Term__c = p.Apttus_Proposal__Payment_Term__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Billing_Frequency__c = p.APTS_Billing_Frequency__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Has_Custom_Terms__c = Boolean.valueOf(p.APTS_Has_Custom_Terms__c);
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Current_Quote_MRR__c = p.APTS_Current_Quote_MRR__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Original_Quote_MRR__c = p.APTS_Original_Quote_MRR__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Current_Quote_TCV__c = p.APTS_Current_Quote_TCV__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Original_Quote_TCV__c = p.APTS_Original_Quote_TCV__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Enterprise_Account__c = Boolean.valueOf(p.APTS_Enterprise_Account__c);
                        p.Apttus_QPConfig__Configurations__r[0].APTS_User_Manager__c = p.APTS_User_Manager__c;
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Quote_Record_Type__c = p.APTS_Record_Type_Name__c;
                        listOfUpdatedCart.add(p.Apttus_QPConfig__Configurations__r[0]);
                    }
                }
                if(listOfUpdatedCart.size()>0){
                    update listOfUpdatedCart;
                }*/

            list<Apttus_Proposal__Proposal__c> acceptedProposals = new list<Apttus_Proposal__Proposal__c>();
            list<Apttus_Proposal__Proposal__c> primaryProposals = new list<Apttus_Proposal__Proposal__c>();
            list<Apttus_Proposal__Proposal__c> finalizationProposals = new list<Apttus_Proposal__Proposal__c>();
            map<id,Apttus_Proposal__Proposal__c> proposalMap = new map<id,Apttus_Proposal__Proposal__c>();
            list<Apttus_Proposal__Proposal__c> proposalSetToPrimary = new list<Apttus_Proposal__Proposal__c>();
            Map<Id, Apttus_Proposal__Proposal__c> primaryProposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
            List<Apttus_Proposal__Proposal__c> proposalsToGenerateYearWiseSplit = new List<Apttus_Proposal__Proposal__c>();
            Set<Id> proposalIds = new Set<Id>();
            if(lstNewProp != NULL
                && lstNewProp.size() > 0)
            {
                for(Apttus_Proposal__Proposal__c p : lstNewProp)
                {
                    if(p.Apttus_Proposal__Approval_Stage__c == label.Apttus_Config2.Accepted
                        &&  mapOfOldProp.get(p.id).Apttus_Proposal__Approval_Stage__c != p.Apttus_Proposal__Approval_Stage__c)
                        acceptedProposals.add(p);
                    if(p.Apttus_Proposal__Primary__c == true)
                        primaryProposals.add(p);
                    if(mapOfOldProp.get(p.id).Apttus_QPConfig__ConfigurationFinalizedDate__c!=p.Apttus_QPConfig__ConfigurationFinalizedDate__c)
                    {
                        finalizationProposals.add(p);
                        proposalIds.add(p.Id);
                    }

                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__Payment_Term__c != p.Apttus_Proposal__Payment_Term__c
                    || mapOfOldProp.get(p.Id).APTS_Billing_Frequency__c != p.APTS_Billing_Frequency__c
                    || mapOfOldProp.get(p.Id).Apttus_Proposal__Special_Terms__c!= p.Apttus_Proposal__Special_Terms__c
                    || mapOfOldProp.get(p.Id).APTS_Current_Quote_MRR__c != p.APTS_Current_Quote_MRR__c
                    || mapOfOldProp.get(p.Id).APTS_Original_Quote_MRR__c != p.APTS_Original_Quote_MRR__c
                    || mapOfOldProp.get(p.Id).APTS_Current_Quote_TCV__c != p.APTS_Current_Quote_TCV__c
                    || mapOfOldProp.get(p.Id).APTS_Original_Quote_TCV__c != p.APTS_Original_Quote_TCV__c
                    || mapOfOldProp.get(p.Id).APTS_Enterprise_Account__c != p.APTS_Enterprise_Account__c
                    || mapOfOldProp.get(p.Id).APTS_User_Manager__c != p.APTS_User_Manager__c
                    || mapOfOldProp.get(p.Id).APTS_Record_Type_Name__c != p.APTS_Record_Type_Name__c
                    || mapOfOldProp.get(p.Id).Apttus_Proposal__ExpectedStartDate__c != p.Apttus_Proposal__ExpectedStartDate__c
                    || mapOfOldProp.get(p.Id).Apttus_Proposal__ExpectedEndDate__c != p.Apttus_Proposal__ExpectedEndDate__c
                    || mapOfOldProp.get(p.Id).Apttus_QPConfig__PriceListId__c != p.Apttus_QPConfig__PriceListId__c)
                    {
                        proposalMap.put(p.Id,p);
                    }

                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__Primary__c != p.Apttus_Proposal__Primary__c)
                    {
                        proposalSetToPrimary.add(p);
                    }

                    if (mapOfOldProp.get(p.Id).No_of_Users__c != p.No_of_Users__c
                            || mapOfOldProp.get(p.Id).APTS_Subscription_Term__c != p.APTS_Subscription_Term__c) {
                        primaryProposalMap.put(p.Id, p);
                    }

                    if (mapOfOldProp.get(p.Id).Generate_Year_Wise_Split__c != p.Generate_Year_Wise_Split__c
                        || mapOfOldProp.get(p.Id).Year_Wise_Split_Source__c != p.Year_Wise_Split_Source__c) {
                        proposalsToGenerateYearWiseSplit.add(p);
                    }
                }
            }
            if(acceptedProposals != NULL
                && acceptedProposals.size() > 0)
                doAccountCalculations(acceptedProposals);
            if(finalizationProposals != NULL
                && finalizationProposals.size() > 0)
                {
                    // Commented this to replace this with the new yearwise split implementation
                    // setYearWiseSplitValues(finalizationProposals);
                    if (!TriggerUtility.isGenerateYearWiseSplitExecuted()) {
                        YearWiseSplitUtil.generateYearWiseSplitForProposals(finalizationProposals);
                    }
                    setProposalFlags(proposalIds);
                }

            if(proposalMap.size() > 0)
            {
            updateFieldOnCart(mapOfOldProp, proposalMap);

            }
            // if (!System.isFuture()) {
            //         updateQuoteStartAndEndDatesInLineItems(JSON.serialize(mapOfOldProp.keySet()));
            //       }

            if(proposalSetToPrimary.size() > 0)
            {
                setOpportunityPrimaryProposal(proposalSetToPrimary);
            }

            if (primaryProposalMap.size() > 0) {
                updateOpportunityFields(primaryProposalMap);
            }

            if (proposalsToGenerateYearWiseSplit.size() > 0) {
                if (!TriggerUtility.isGenerateYearWiseSplitExecuted()) {
                    YearWiseSplitUtil.generateYearWiseSplitForProposals(proposalsToGenerateYearWiseSplit);
                }
            }
        }
    }

        // Update: HE, 12/20/2016 - rewrote the function and added APTS_Configuration_Id__c derivation on proposal for approvals.
    private void setProposalFlags(Set<Id> proposalIds)
    {
        /*Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalsMap = new
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Apttus_Proposal__Proposal__c tempProposal;
        List<Apttus_Proposal__Proposal_Line_Item__c> tempList;
        List<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new List<Apttus_Proposal__Proposal__c>();

        Map<Id, Apttus_Proposal__Proposal__c> proposalsToBeUpdatedMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        //for(Apttus_Proposal__Proposal__c proposal : [select Id,APTS_Is_Ramp_Present__c, APTS_Deal_Reg_Present__c,APTS_New_Logo_Present__c, (Select Id From Apttus_QPConfig__Configurations__r Order by Apttus_Config2__VersionNumber__c DESC limit 1) From Apttus_Proposal__Proposal__c where Id in : proposalIds ])
        for(Apttus_Proposal__Proposal__c proposal : [select Id,APTS_Is_Ramp_Present__c, APTS_Deal_Reg_Present__c,APTS_New_Logo_Present__c From Apttus_Proposal__Proposal__c where Id in : proposalIds ])
        {
            proposalsToBeUpdatedMap.put(proposal.Id, proposal);
        }

        for(Apttus_Proposal__Proposal_Line_Item__c propLineItem : [select Apttus_QPConfig__PriceGroup__c,APTS_Product_Code__c, APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c, Apttus_Proposal__Proposal__c from
            Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in : proposalIds ])
        {
                if(proposalsMap.containsKey(propLineItem.Apttus_Proposal__Proposal__c))
                {
                    tempList = proposalsMap.get(propLineItem.Apttus_Proposal__Proposal__c);
                    tempList.add(propLineItem);
                    proposalsMap.remove(propLineItem.Apttus_Proposal__Proposal__c);
                    proposalsMap.put(propLineItem.Apttus_Proposal__Proposal__c, tempList);
                }
                else
                {
                    tempList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
                    tempList.add(propLineItem);
                    proposalsMap.put(propLineItem.Apttus_Proposal__Proposal__c, tempList);
                }
        }
        // Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalsMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        //List<Apttus_Proposal__Proposal_Line_Item__c> tempList;

        for(Id proposalId : proposalsMap.keySet())
        {
            tempProposal = proposalsToBeUpdatedMap.get(proposalId);
            tempProposal.APTS_Is_Ramp_Present__c = false;
            tempProposal.APTS_Deal_Reg_Present__c = false;
            tempProposal.APTS_New_Logo_Present__c = false;
            tempProposal.APTS_DAS_Package_Included__c = false;
            tempProposal.APTS_Professional_Services_Included__c = false;
            tempProposal.APTS_EDU_Credits_Included__c = false;

            tempList = proposalsMap.get(proposalId);

            if(tempList != null && tempList.size() > 0)
            {
                for(Apttus_Proposal__Proposal_Line_Item__c lineItem : tempList)
                {
                    if(lineItem.Apttus_QPConfig__PriceGroup__c != null
                            && lineItem.Apttus_QPConfig__PriceGroup__c == 'Price Ramp')
                    {
                        tempProposal.APTS_Is_Ramp_Present__c = true;
                    }

                    if(lineItem.APTS_Deal_Reg_Disc__c != null && lineItem.APTS_Deal_Reg_Disc__c > 0)
                    {
                        tempProposal.APTS_Deal_Reg_Present__c = true;
                    }

                    if(lineItem.APTS_New_Logo_Disc__c != null && lineItem.APTS_New_Logo_Disc__c > 0)
                    {
                        tempProposal.APTS_New_Logo_Present__c = true;
                    }

                    //Setting Other flags based on product
                    if(lineItem.APTS_Product_Code__c == 'ZCES-DAS-PKG1' || lineItem.APTS_Product_Code__c == 'ZCES-DAS-PKG2'
                    || lineItem.APTS_Product_Code__c == 'ZCES-DAS-PKG3' || lineItem.APTS_Product_Code__c == 'ZCES-DAS-PKG4')
                    {
                        tempProposal.APTS_DAS_Package_Included__c = true;
                    }
                    else if(lineItem.APTS_Product_Code__c == 'ZCES-PRO-SVC')
                    {
                        tempProposal.APTS_Professional_Services_Included__c = true;
                    }
                    else if(lineItem.APTS_Product_Code__c == 'ZCES-EDU-CREDIT' || lineItem.APTS_Product_Code__c == 'ZCES-EDU-LABCREDIT')
                    {
                        tempProposal.APTS_EDU_Credits_Included__c = true;
                    }
                }
            }

            proposalsToBeUpdated.add(tempProposal);
        }*/
        Map<Id, Apttus_Proposal__Proposal__c> proposalIdToProposalSOMap = new Map<Id, Apttus_Proposal__Proposal__c>([Select Id, APTS_Is_Ramp_Present__c, APTS_Deal_Reg_Present__c, APTS_New_Logo_Present__c,
                                                                                                                        (Select Id, Number_of_Entitled_ZPA_Connectors__c From Apttus_QPConfig__Configurations__r Order by Apttus_Config2__VersionNumber__c DESC LIMIT 1),
                                                                                                                        (Select Apttus_Proposal__Proposal__r.Apttus_QPConfig__BillToAccountId__r.Program_type__c, Apttus_QPConfig__IsPrimaryLine__c,Apttus_QPConfig__PriceGroup__c,Apttus_QPConfig__ItemSequence__c,APTS_Product_Code__c, APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c,
                                                                                                                        Apttus_Proposal__Proposal__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__r.Description, Apttus_Proposal__Product__r.Zscaler_Product_Family__c, 
                                        
                                                                                                                        Apttus_QPConfig__ExtendedPrice__c, Apttus_QPConfig__LineStatus__c, APTS_Total_Discount_Percentage__c, Apttus_QPConfig__NetPrice__c From Apttus_Proposal__R00N70000001yUfBEAU__r  )
                                                                                                                            From Apttus_Proposal__Proposal__c where Id in : proposalIds]);
        List<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new List<Apttus_Proposal__Proposal__c>();

        for(Id proposalId : proposalIdToProposalSOMap.keySet())
        {
            Apttus_Proposal__Proposal__c proposal_DB = proposalIdToProposalSOMap.get(proposalId);

            Apttus_Proposal__Proposal__c proposalSOTobeUpdated = new Apttus_Proposal__Proposal__c(Id = proposalId);
            proposalSOTobeUpdated.APTS_Is_Ramp_Present__c = false;
            proposalSOTobeUpdated.APTS_Deal_Reg_Present__c = false;
            proposalSOTobeUpdated.APTS_New_Logo_Present__c = false;
            proposalSOTobeUpdated.APTS_DAS_Package_Included__c = false;
            proposalSOTobeUpdated.APTS_Professional_Services_Included__c = false;
            proposalSOTobeUpdated.APTS_EDU_Credits_Included__c = false;
            proposalSOTobeUpdated.Has_ZIA_ELA_SKU__c = false;
            proposalSOTobeUpdated.ThreatLabz_Service_SKU_Count__c = 0;
            proposalSOTobeUpdated.Included_DAS_Package__c = '';
            proposalSOTobeUpdated.Is_ZPA_100_Seats_Promo_Present__c = 0;

            // Executive Proposal Fields
            proposalSOTobeUpdated.Subscription_to_Zscaler_Internet_Access__c = 0;
            proposalSOTobeUpdated.Subscription_to_Zscaler_Private_Access__c = 0;
            proposalSOTobeUpdated.One_Time_Services__c = 0;
            proposalSOTobeUpdated.Premium_Support__c = 0;
            proposalSOTobeUpdated.OTS_Products__c = '';
            proposalSOTobeUpdated.Support_Products__c = '';
            proposalSOTobeUpdated.ZPA_Products__c = '';
            proposalSOTobeUpdated.ZIA_Products__c = '';
            proposalSOTobeUpdated.Proposal_Bundle_Items__c = '';
            proposalSOTobeUpdated.Maximum_Ramp_Line_Item_Sequence__c = 1;
            proposalSOTobeUpdated.Ramped_SKU_Codes__c = '';
            proposalSOTobeUpdated.Contains_New_DAS_with_more_than_10_Disc__c = false;
            Set<String> setProductsAdded = new Set<String>();
            Map<String, Integer> mapProductsCount = new Map<String, Integer>();

            // Update: HE, 12/20/2016 - Added APTS_Configuration_Id__c for approvals.
            // Assumption: Last configuration on quote is finalized when ordered by Apttus_Config2__VersionNumber__c DESC.
            if(!proposal_DB.Apttus_QPConfig__Configurations__r.isEmpty())
            {
                proposalSOTobeUpdated.APTS_Configuration_Id__c = proposal_DB.Apttus_QPConfig__Configurations__r.get(0).Id;
                proposalSOTobeUpdated.Number_Of_Entitled_ZPA_Connectors__c = proposal_DB.Apttus_QPConfig__Configurations__r.get(0).Number_Of_Entitled_ZPA_Connectors__c;
            }

            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLinesList = proposal_DB.Apttus_Proposal__R00N70000001yUfBEAU__r;
            if(proposalLinesList != null
                && proposalLinesList.size() > 0)
            {
                for(Apttus_Proposal__Proposal_Line_Item__c pliSO : proposalLinesList)
                {

                    if(!pliSO.Apttus_QPConfig__IsPrimaryLine__c && pliSO.Apttus_QPConfig__PriceGroup__c != null
                            && pliSO.Apttus_QPConfig__PriceGroup__c == 'Price Ramp')
                    {
                        system.debug('@@@@@---'+pliSO);
                        proposalSOTobeUpdated.APTS_Is_Ramp_Present__c = true;
                    }

                    if(pliSO.APTS_Deal_Reg_Disc__c != null
                        && pliSO.APTS_Deal_Reg_Disc__c > 0)
                    {
                        proposalSOTobeUpdated.APTS_Deal_Reg_Present__c = true;
                    }

                    if(pliSO.APTS_New_Logo_Disc__c != null
                        && pliSO.APTS_New_Logo_Disc__c > 0)
                    {
                        proposalSOTobeUpdated.APTS_New_Logo_Present__c = true;
                    }

                    //Setting Other flags based on product
                    if(pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS1
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS2
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS3
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS4
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS6
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS0
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ADVANCED
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE_PLUS
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ESSENTIAL
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_HEALTH_CHECK
                        /*|| pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE*/)
                    {
                        proposalSOTobeUpdated.APTS_DAS_Package_Included__c = true;
                    }
                    else if(pliSO.APTS_Product_Code__c == 'ZCES-PRO-SVC')
                    {
                        proposalSOTobeUpdated.APTS_Professional_Services_Included__c = true;
                    }
                    else if(pliSO.APTS_Product_Code__c == 'ZCES-EDU-CREDIT'
                            || pliSO.APTS_Product_Code__c == 'ZCES-EDU-LABCREDIT')
                    {
                        proposalSOTobeUpdated.APTS_EDU_Credits_Included__c = true;
                    }

                    if (pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_100SEATS_PROMO) {
                        proposalSOTobeUpdated.Is_ZPA_100_Seats_Promo_Present__c = 1;
                    }

                    if(pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE) {
                        proposalSOTobeUpdated.Has_ZIA_ELA_SKU__c = true;
                    }

                    if(pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_THREATLABZ) {
                        proposalSOTobeUpdated.ThreatLabz_Service_SKU_Count__c++;
                    }

                    //Setting the included DAS package product code
                    if (pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS1
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS2
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS3
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS4
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS0
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS6
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ADVANCED
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE_PLUS
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ESSENTIAL
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_HEALTH_CHECK
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_FED_DAS1
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_FED_DAS2
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_FED_DAS3) {
                            system.debug('inside DAS condition');
                            
                        system.debug('proposalSOTobeUpdated.Included_DAS_Package__c  '+proposalSOTobeUpdated.Included_DAS_Package__c);
                        if(proposalSOTobeUpdated.Included_DAS_Package__c==null || proposalSOTobeUpdated.Included_DAS_Package__c==''){
                            proposalSOTobeUpdated.Included_DAS_Package__c = pliSO.APTS_Product_Code__c;
                        }
                        else{
                            proposalSOTobeUpdated.Included_DAS_Package__c = proposalSOTobeUpdated.Included_DAS_Package__c + ',' +pliSO.APTS_Product_Code__c;
                        }
                        system.debug('proposalSOTobeUpdated.Included_DAS_Package__c  '+proposalSOTobeUpdated.Included_DAS_Package__c);
                    }/* else if (pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE) {
                        proposalSOTobeUpdated.Included_DAS_Package__c = APTS_CONSTANTS.PROD_SKU_DAS6;
                    }*/
                    
                    if((pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ADVANCED
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ENTERPRISE_PLUS
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_DAS_ESSENTIAL
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_HEALTH_CHECK) && pliSO.APTS_Total_Discount_Percentage__c > 10){
                            proposalSOTobeUpdated.Contains_New_DAS_with_more_than_10_Disc__c = true;
                    }

                    //Setting the ZPA SKU Name to be displayed in the Proposal Document
                    if (pliso.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_100SEATS_PROMO) {
                        proposalSOTobeUpdated.ZPA_SKU_Name__c = pliSO.Apttus_Proposal__Product__r.Name;
                    }

                    // Executive Proposal fields update logic
                    System.debug('*** setProductsAdded: ' + setProductsAdded);
                    if (pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA') {
                        proposalSOTobeUpdated.Subscription_to_Zscaler_Internet_Access__c += pliSO.Apttus_QPConfig__ExtendedPrice__c;
                        if (!setProductsAdded.contains(pliSO.Apttus_Proposal__Product__r.Name)) {
                            proposalSOTobeUpdated.ZIA_Products__c = proposalSOTobeUpdated.ZIA_Products__c + pliSO.Apttus_Proposal__Product__r.Name + ',\r\n';
                        }
                    } else if (pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA') {
                        proposalSOTobeUpdated.Subscription_to_Zscaler_Private_Access__c += pliSO.Apttus_QPConfig__ExtendedPrice__c;
                        if (!setProductsAdded.contains(pliSO.Apttus_Proposal__Product__r.Name)) {
                            proposalSOTobeUpdated.ZPA_Products__c = proposalSOTobeUpdated.ZPA_Products__c + pliSO.Apttus_Proposal__Product__r.Name + ',\r\n';
                        }
                    } else if (pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Support'
                        || pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Premium Support') {
                        proposalSOTobeUpdated.Premium_Support__c += pliSO.Apttus_QPConfig__ExtendedPrice__c;
                        if (!setProductsAdded.contains(pliSO.Apttus_Proposal__Product__r.Name)) {
                            proposalSOTobeUpdated.Support_Products__c = proposalSOTobeUpdated.Support_Products__c + pliSO.Apttus_Proposal__Product__r.Name + ',\r\n';
                        }
                    } else if (pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Deployment'
                        || pliSO.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Education') {
                        proposalSOTobeUpdated.One_Time_Services__c += pliSO.Apttus_QPConfig__ExtendedPrice__c;
                        if (!setProductsAdded.contains(pliSO.Apttus_Proposal__Product__r.Name)) {
                            proposalSOTobeUpdated.OTS_Products__c = proposalSOTobeUpdated.OTS_Products__c + pliSO.Apttus_Proposal__Product__r.Name + ',\r\n';
                        }
                    }
                    setProductsAdded.add(pliSO.Apttus_Proposal__Product__r.Name);

                    if (pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_PRO
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZPA_ENT) {
                        proposalSOTobeUpdated.Proposal_Bundle_Items__c += pliSO.Apttus_Proposal__Product__r.Name + ' - ' + pliSO.Apttus_Proposal__Product__r.Description + '; \n';
                    }

                    // pliSO.Apttus_QPConfig__LineStatus__c != APTS_CONSTANTS.LI_STATUS_RENEWED 
                    //     && pliSO.Apttus_QPConfig__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                    //     && 
                    if (mapProductsCount.containsKey(pliSO.APTS_Product_Code__c)) {
                        mapProductsCount.put(pliSO.APTS_Product_Code__c, mapProductsCount.get(pliSO.APTS_Product_Code__c) + 1);
                    } else {
                        mapProductsCount.put(pliSO.APTS_Product_Code__C, 1);
                    }
                }

                proposalSOTobeUpdated.ZIA_Products__c = (proposalSOTobeUpdated.ZIA_Products__c.length() > 3 ? proposalSOTobeUpdated.ZIA_Products__c.substring(0, proposalSOTobeUpdated.ZIA_Products__c.length() - 3) : proposalSOTobeUpdated.ZIA_Products__c);
                proposalSOTobeUpdated.ZPA_Products__c = (proposalSOTobeUpdated.ZPA_Products__c.length() > 3 ? proposalSOTobeUpdated.ZPA_Products__c.substring(0, proposalSOTobeUpdated.ZPA_Products__c.length() - 3) : proposalSOTobeUpdated.ZPA_Products__c);
                proposalSOTobeUpdated.Support_Products__c = (proposalSOTobeUpdated.Support_Products__c.length() > 3 ? proposalSOTobeUpdated.Support_Products__c.substring(0, proposalSOTobeUpdated.Support_Products__c.length() - 3) : proposalSOTobeUpdated.Support_Products__c);
                proposalSOTobeUpdated.OTS_Products__c = (proposalSOTobeUpdated.OTS_Products__c.length() > 3 ? proposalSOTobeUpdated.OTS_Products__c.substring(0, proposalSOTobeUpdated.OTS_Products__c.length() - 3) : proposalSOTobeUpdated.OTS_Products__c);

                for (String key : mapProductsCount.keySet()) {
                    if (proposalSOTobeUpdated.Maximum_Ramp_Line_Item_Sequence__c < mapProductsCount.get(key)) {
                        proposalSOTobeUpdated.Maximum_Ramp_Line_Item_Sequence__c = mapProductsCount.get(key);
                    }

                    if (mapProductsCount.get(key) > 1) {
                        proposalSOTobeUpdated.Ramped_SKU_Codes__c += (key + ',');
                    }
                }

                if (proposalSOTobeUpdated.Ramped_SKU_Codes__c.length() > 0) {
                    proposalSOTobeUpdated.Ramped_SKU_Codes__c = proposalSOTobeUpdated.Ramped_SKU_Codes__c.substring(0, proposalSOTobeUpdated.Ramped_SKU_Codes__c.length() - 1);
                }
            }

            proposalsToBeUpdated.add(proposalSOTobeUpdated);
        }

        if(!proposalsToBeUpdated.isEmpty())
        {
            update proposalsToBeUpdated;
        }
    }

    public void calculateTotalofProposal(list<Apttus_Proposal__Proposal__c> proposalList) {
        List<Apttus_Config2__LineItem__c> lineitemsList = [Select id,name,Apttus_Config2__ProductId__c,Apttus_Config2__LineStatus__c,APTS_MRR__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
                                                                  Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, ACV_Premium_Support__c, APTS_ACV__c, Apttus_Config2__ProductId__r.ProductCode,
                                                                  ZPA_Premium_Support_ACV__c, ZIA_Premium_Support_ACV__c
                                                                            From Apttus_Config2__LineItem__c
                                                                                Where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN :proposalList
                                                                                      AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'];
        Map<string, Decimal> MRRTotalMap = new Map<string, Decimal>();
        Map<string, Decimal> TCVTotalMap = new Map<string, Decimal>();
        Map<String, Decimal> ZIAACVTotal = new Map<String, Decimal>();
        Map<String, Decimal> ZPAACVTotal = new Map<String, Decimal>();
        Map<Id, Id> proposalsWithOverriddenACV = new Map<Id, Id>();
        for(Apttus_Config2__LineItem__c lItem : lineitemsList ) {
            Decimal totalMRR = 0;
            Decimal totalTCV = 0;
            Decimal ziaACV = 0;
            Decimal zpaACV = 0;
            if(MRRTotalMap.get(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                totalMRR = MRRTotalMap.get(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
            }
            if(lItem.APTS_MRR__c != null && lItem.Apttus_Config2__LineStatus__c != 'Cancelled') {
                totalMRR = totalMRR  + lItem.APTS_MRR__c;
            }
            MRRTotalMap.put(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15),totalMRR);
            if(TCVTotalMap.get(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                totalTCV = TCVTotalMap.get(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
            }
            if(lItem.APTS_MRR__c != null) {
                totalTCV = totalTCV + lItem.Apttus_Config2__NetPrice__c;
            }

            TCVTotalMap.put(string.valueof(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15),totalTCV );
            System.debug('>>>> ziaACV calculation');
            if (lItem.Apttus_Config2__ProductId__r.ProductCode == APTS_CONSTANTS.PROD_SKU_TAMTOP) {
                if (ZPAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                    zpaACV = ZPAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
                }

                if (lItem.ZPA_Premium_Support_ACV__c != null) {
                    zpaACV += lItem.ZPA_Premium_Support_ACV__c;
                }
                ZPAACVTotal.put(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15), zpaACV);

                if (ZIAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                    ziaACV = ZIAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
                }

                if (lItem.ZIA_Premium_Support_ACV__c != null) {
                    ziaACV += lItem.ZIA_Premium_Support_ACV__c;
                }
                ZIAACVTotal.put(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15), ziaACV);
            } else if (lItem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZIA) {
                if (ZIAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                    ziaACV = ZIAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
                }

                if (lItem.ACV_Premium_Support__c != null) {
                    ziaACV += lItem.ACV_Premium_Support__c;
                }
                ZIAACVTotal.put(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15), ziaACV);
            } else if (lItem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == APTS_CONSTANTS.PROD_FAMILY_ZPA) {
                if (ZPAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15)) != null) {
                    zpaACV = ZPAACVTotal.get(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15));
                }

                if (lItem.ACV_Premium_Support__c != null) {
                    zpaACV += lItem.ACV_Premium_Support__c;
                }
                ZPAACVTotal.put(String.valueOf(lItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).substring(0, 15), zpaACV);
            }
            System.debug('>>>> ziaACV / zpaACV calculation done. ' + JSON.serialize(ZIAACVTotal) + ' ' + JSON.serialize(ZPAACVTotal));
        }
        for(Apttus_Proposal__Proposal__c Proposal : proposalList) {
            Proposal.Total_ZIA_ACV__c = Proposal.Total_ZPA_ACV__c = 0;
            if(TCVTotalMap.get(string.valueof(Proposal.id).substring(0,15)) != null) {
                Proposal.APTS_Current_Quote_TCV__c = TCVTotalMap.get(string.valueof(Proposal.id).substring(0,15));
            }
            if(TCVTotalMap.get(string.valueof(Proposal.id).substring(0,15)) != null) {
                Proposal.APTS_Current_Quote_MRR__c = MRRTotalMap.get(string.valueof(Proposal.id).substring(0,15));
            }
            if (ZIAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15)) != null) {
                Proposal.Total_ZIA_ACV__c = ZIAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15));
            }
            if (ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0, 15)) != null) {
                System.debug('>>>> Proposal.Total_ZPA_ACV__c: ' + (Proposal.Total_ZPA_ACV__c));
                System.debug('>>>> ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15)): ' + (ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15))));
                System.debug('>>>> ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15)) != Proposal.Total_ZPA_ACV__c: ' + (ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15)) != Proposal.Total_ZPA_ACV__c));
                if (ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15)) != Proposal.Total_ZPA_ACV__c && Proposal.Override_Renewal_Upsell_ACV_Values__c) {
                    proposalsWithOverriddenACV.put(Proposal.Id, Proposal.Apttus_Proposal__Opportunity__c);
                }
                Proposal.Total_ZPA_ACV__c = ZPAACVTotal.get(String.valueOf(Proposal.Id).substring(0,15));
            }
        }

        if (proposalsWithOverriddenACV.size() > 0) {
            CaseCreationForAccountAndOpportunity.overrideACVValuesResetCaseCreation(proposalsWithOverriddenACV.values(), false);
        }
    }

    public void onAfterInsert(list<Apttus_Proposal__Proposal__c> lstNewProp){
        if(!TriggerUtility.isskipentireproposaltriggerExecuted()){
            setQuoteDefaultValuesAfterInsert(lstNewProp);
            setOpportunityPrimaryProposal(lstNewProp);
        //Set<Id> oppIds = new Set<Id>();
        }
        //Added as apart of RBAC
        if(!lstNewProp.isEmpty()){
            shareProposalToOppTeam(lstNewProp);
        }
    }
    
    //Method Added as apart of RBAC
    public void shareProposalToOppTeam(List<Apttus_Proposal__Proposal__c> newProposals){
        Set<Id> oppIds = new Set<Id>();
        for(Apttus_Proposal__Proposal__c proposalRec : newProposals){
            oppIds.add(proposalRec.Apttus_Proposal__Opportunity__c);
        }
        List<OpportunityTeamMember> oppTeamMembers = [Select Id, UserId, OpportunityId from OpportunityTeamMember Where OpportunityId IN: oppIds];
        Map<Id, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
        for(OpportunityTeamMember teamMemberRec : oppTeamMembers){
            if(oppTeamMembersMap.get(teamMemberRec.OpportunityId) == null){
                List<OpportunityTeamMember> tempList = new List<OpportunityTeamMember>();
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
            else{
                List<OpportunityTeamMember> tempList = oppTeamMembersMap.get(teamMemberRec.OpportunityId);
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
        }
        List<Apttus_Proposal__Proposal__Share> proposalSharesToInsert = new List<Apttus_Proposal__Proposal__Share>();
        for(Apttus_Proposal__Proposal__c proposalRec : newProposals){
            if(oppTeamMembersMap.get(proposalRec.Apttus_Proposal__Opportunity__c) != null){
                for(OpportunityTeamMember oppTeamRec : oppTeamMembersMap.get(proposalRec.Apttus_Proposal__Opportunity__c)){
                    Apttus_Proposal__Proposal__Share proposalShareRec = new Apttus_Proposal__Proposal__Share();
                    proposalShareRec.ParentId = proposalRec.id;
                    proposalShareRec.AccessLevel = 'EDIT';
                    proposalShareRec.UserOrGroupId = oppTeamRec.UserId;
                    proposalSharesToInsert.add(proposalShareRec);
                }
            }
        }
        if(!proposalSharesToInsert.isEmpty()){
            Database.insert(proposalSharesToInsert, false);
        }
    }
    
    private void setOpportunityPrimaryProposal(list<Apttus_Proposal__Proposal__c> lstNewProp)
    {
        Map<Id, Id> opportunityMap = new Map<Id, Id>();
        Map<Id, string> proposalNames = new Map<Id, string>();
        Map<Id, string> proposalpartnerprogram = new Map<Id, string>();
        for(Apttus_Proposal__Proposal__c prop : lstNewProp)
        {
            if(prop.Apttus_Proposal__Primary__c)
            {
                //oppIds.add(prop.Apttus_Proposal__Opportunity__C);
                opportunityMap.put(prop.Apttus_Proposal__Opportunity__C, prop.Id);
                proposalNames.put(prop.Id, prop.Name);
                proposalpartnerprogram.put(prop.Id, prop.Model_Type_Partner__c);
            }
        }

        if(opportunityMap.size() > 0)
        {
            List<Opportunity> oppListToBeUpdated = new List <Opportunity>();
            for(Opportunity opp : [Select ID, APTS_Primary_Proposal__c,APTS_Primary_Proposal_Lookup__c, Start_Date__c, CloseDate, OwnerId From Opportunity Where ID = :opportunityMap.keySet() ])
            {
                opp.APTS_Primary_Proposal__c = proposalNames.get(opportunityMap.get(opp.Id));
                opp.Primary_Partner_Program__c = proposalpartnerprogram.get(opportunityMap.get(opp.Id));
                opp.APTS_Primary_Proposal_Lookup__c = opportunityMap.get(opp.Id);
                oppListToBeUpdated.add(opp);
            }

            if(oppListToBeUpdated.size() > 0)
            {
                update oppListToBeUpdated;
            }
        }
    }

    /**
        Functionality:
        1. Populate Platform Subscription End Date and Number of Platform Seats on Account.
        2. Populate Asset SKU on Account if proposal line item has NSS, premium support or DLP.
    **/
    public void doAccountCalculations(list<Apttus_Proposal__Proposal__c> acceptedProposals)
    {
        system.debug('inside doAccountCalculations method');
        Set<Id> accountIdSet = new set<Id>();
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalIdTolineItemsMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalIdToAddonlineItemsMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>> proposalIdToZPAlineItemsMap = new Map<Id, List<Apttus_Proposal__Proposal_Line_Item__c>>();
        Map<Id, Account> accIdToAccountSOMap = new Map<Id, Account>();
        Set<String> productCodeSet = new Set<String>{
                                                        APTS_CONSTANTS.PROD_SKU_NSS,
                                                        APTS_CONSTANTS.PROD_SKU_PSUPPORT,
                                                        APTS_CONSTANTS.PROD_SKU_DLP,
                                                        APTS_CONSTANTS.PROD_SKU_SIP,
                                                        APTS_CONSTANTS.PROD_SKU_SIP_LOC,
                                                        APTS_CONSTANTS.PROD_SKU_ZBUSINESSSUITE,
                                                        APTS_CONSTANTS.PROD_SKU_ZPROSUITE,
                                                        APTS_CONSTANTS.PROD_SKU_ZENTSUITE,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU,
                                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU
                                                    };

        Set<String> setAddonSKUCodes = new Set<String> {
                                            APTS_CONSTANTS.PROD_SKU_CLOUD_FIREWALL,
                                            APTS_CONSTANTS.PROD_SKU_CLOUD_SANDBOX,
                                            APTS_CONSTANTS.PROD_SKU_NSS,
                                            APTS_CONSTANTS.PROD_SKU_STDFWLOGING,
                                            APTS_CONSTANTS.PROD_SKU_STDFWLOGING,
                                            APTS_CONSTANTS.PROD_SKU_BWCTRL,
                                            APTS_CONSTANTS.PROD_SKU_ENCVPN,
                                            APTS_CONSTANTS.PROD_SKU_SSLINT,
                                            APTS_CONSTANTS.PROD_SKU_ZWEB2_0,
                                            APTS_CONSTANTS.PROD_SKU_ZWAC,
                                            APTS_CONSTANTS.PROD_SKU_DLP
                                                    };

        Set<String> setZPAProductCodes = new Set<String> {
                                            APTS_CONSTANTS.PROD_SKU_ZPA_PRO,
                                            APTS_CONSTANTS.PROD_SKU_ZPA_BUS,
                                            APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU,
                                            APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU,
                                            APTS_CONSTANTS.PROD_SKU_ZPA_ENT
                                        };

        for(Apttus_Proposal__Proposal__c pSO : acceptedProposals)
        {
            accountIdSet.add(pSO.Apttus_Proposal__Account__c);
        }

        //Map with key Proposal Id and value:corresponding list of Line Items
        for(Apttus_Proposal__Proposal_Line_Item__c pliSO : [Select Id, APTS_Standard_Platform_End_Date__c, APTS_Ramp_End_Date__c, Apttus_QPConfig__LineStatus__c,
                                                                   APTS_Total_Ramp_Quantity__c, Apttus_Proposal__Proposal__c, APTS_Product_Code__c,Apttus_QPConfig__AssetLineItemId__c
                                                                        From Apttus_Proposal__Proposal_Line_Item__c
                                                                             Where Apttus_Proposal__Proposal__c IN :acceptedProposals
                                                                                       AND (APTS_Product_Code__c IN :productCodeSet
                                                                                        OR APTS_Product_Code__c IN :setAddonSKUCodes
                                                                                        OR APTS_Product_Code__c IN :setZPAProductCodes)]){
            Id proposalId = pliSO.Apttus_Proposal__Proposal__c;
                if (productCodeSet.contains(pliSO.APTS_Product_Code__c)) {
                    List<Apttus_Proposal__Proposal_Line_Item__c> pliList = proposalIdTolineItemsMap.containsKey(proposalId) ? proposalIdTolineItemsMap.get(proposalId) : new List<Apttus_Proposal__Proposal_Line_Item__c>();
                    pliList.add(pliSO);
                    proposalIdTolineItemsMap.put(proposalId, pliList);
                } else if (setAddonSKUCodes.contains(pliSO.APTS_Product_Code__c)) {
                    List<Apttus_Proposal__Proposal_Line_Item__c> pliAddonsList = proposalIdToAddonlineItemsMap.containsKey(proposalId) ? proposalIdToAddonlineItemsMap.get(proposalId) : new List<Apttus_Proposal__Proposal_Line_Item__c>();
                    pliAddonsList.add(pliSO);
                    proposalIdToAddonlineItemsMap.put(proposalId, pliAddonsList);
                } else if (setZPAProductCodes.contains(pliSO.APTS_Product_Code__c)) {
                    List<Apttus_Proposal__Proposal_Line_Item__c> zpaPliList = proposalIdToZPAlineItemsMap.containsKey(proposalId) ? proposalIdToZPAlineItemsMap.get(proposalId) : new List<Apttus_Proposal__Proposal_Line_Item__c>();
                    zpaPliList.add(pliSO);
                    proposalIdToZPAlineItemsMap.put(proposalId, zpaPliList);
                }
        }

        accIdToAccountSOMap  = new Map<Id, Account>([Select Id,DAS_SKU__c, APTS_Platform_Subscription_End_Date__c, APTS_No_of_Platform_Seats__c, Addon_SKUs__c, ZPA_Asset_SKU__c, 
                                                            APTS_Asset_SKU__c, ELA_Approved_Account__c, 
                                                            (Select Id, Apttus_Config2__AccountId__c, Product_Code__c From Apttus_Config2__AssetLineItems__r Where Apttus_Config2__AssetStatus__c = :APTS_CONSTANTS.ALI_STATUS_ACTIVATED)
                                                                From Account
                                                                    Where id IN :accountIdSet]);

        // Calculate the platform seats, subscription end date, Asset SKU's based on all the proposal line items when propsal config stage is Accepted.
        // Update:HE, 01/09/2017 - Update APTS_No_of_Platform_Seats__c seats only if sip exists in cart(upsell scenarios).
            Map<Id, Account> accountsTobeUpdated = new Map<Id, Account>();
        for(Apttus_Proposal__Proposal__c pSO : acceptedProposals)
        {
            Double totalSeats = 0;
            Boolean sipExistsinCart = false;
            Boolean isELABundleFound = false;
            List<Date> dateList = new List<Date>();
            Id accountId = pSO.Apttus_Proposal__Account__c;
            Account accountSO = accIdToAccountSOMap.containsKey(accountId) ? accIdToAccountSOMap.get(accountId) : null;

            Set<String> productSKUs = new Set<String>();//APTS_UtilityFns.splitString_toset(accountSO.APTS_Asset_SKU__c, ', ');// capture the existing SKU codes on account.
            if(accountSO != null
                && proposalIdTolineItemsMap.containsKey(pSO.id))
            {
                Set<Id> cancelledAssetIdSet = new Set<Id>();
                for(Apttus_Proposal__Proposal_Line_Item__c pliSO : proposalIdTolineItemsMap.get(pSO.id))
                {
                    
                    if(pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_SIP
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_SIP_LOC
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE_LU
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE_LU
                        || pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE_LU)
                    {
                        sipExistsinCart = true;
                        if(pliSO.APTS_Total_Ramp_Quantity__c != null){
                            totalSeats += pliSO.APTS_Total_Ramp_Quantity__c;
                        }
                        if(pliSO.APTS_Ramp_End_Date__c != null)
                            dateList.add(pliSO.APTS_Ramp_End_Date__c);

                        if (pliSO.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE) {
                            isELABundleFound = true;
                        }
                    }

                        if(pliSO.Apttus_QPConfig__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                            && productCodeSet.contains(pliSO.APTS_Product_Code__c))
                        productSKUs.add(pliSO.APTS_Product_Code__c);
                    else
                        cancelledAssetIdSet.add(pliSO.Apttus_QPConfig__AssetLineItemId__c);
                }

                // get the SKU codes from active asset lines. - [ZSCAL-256]
                // Update:HE, 01/03/2017 - do not include assets that are cancelled for current cart.
                // Update:HE, 01/09/2017 - only include productCodeSet from assets.
                for(Apttus_Config2__AssetLineItem__c aliSO : accountSO.Apttus_Config2__AssetLineItems__r){
                    if(!cancelledAssetIdSet.contains(aliSO.Id)
                        && productCodeSet.contains(aliSO.Product_Code__c))
                        productSKUs.add(aliSO.Product_Code__c);
                }

                if(sipExistsinCart == true)
                    accountSO.APTS_No_of_Platform_Seats__c = totalSeats;

                //Update Account's ELA Approved Account field if the ZIA-ELA-Bundle SKU is part of the asset line item
                if (isELABundleFound) {
                    accountSO.ELA_Approved_Account__c = true;
                }

                dateList.sort();
                if(dateList.size() > 0)
                    accountSO.APTS_Platform_Subscription_End_Date__c = dateList.get(0);

                accountSO.APTS_Asset_SKU__c = APTS_UtilityFns.flattenSet(productSKUs, ', ');
                // accountSO.
                    accountsTobeUpdated.put(accountSO.Id, accountSO);
            }

            Set<String> addonProductSKUs = new Set<String>();
            if (accountSO != null
                && proposalIdToAddonlineItemsMap.containsKey(pSO.Id)) {
                for(Apttus_Proposal__Proposal_Line_Item__c pliSO : proposalIdToAddonlineItemsMap.get(pSO.id)) {
                    Set<Id> cancelledAssetIdSet = new Set<Id>();
                    if(pliSO.Apttus_QPConfig__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                        && setAddonSKUCodes.contains(pliSO.APTS_Product_Code__c))
                        addonProductSKUs.add(pliSO.APTS_Product_Code__c);
                    else
                    cancelledAssetIdSet.add(pliSO.Apttus_QPConfig__AssetLineItemId__c);

                    for(Apttus_Config2__AssetLineItem__c aliSO : accountSO.Apttus_Config2__AssetLineItems__r){
                        if(!cancelledAssetIdSet.contains(aliSO.Id)
                            && setAddonSKUCodes.contains(aliSO.Product_Code__c))
                            addonProductSKUs.add(aliSO.Product_Code__c);
                    }

                    System.debug('>>>> addonProductSKUs: ' + addonProductSKUs);
                    String addonSkus = APTS_UtilityFns.flattenSet(addonProductSKUs, ', ');
                    if (accountsTobeUpdated.containsKey(accountSO.Id)) {
                        accountsTobeUpdated.get(accountSO.Id).Addon_SKUs__c = addonSkus;
                    } else {
                        accountSO.Addon_SKUs__c = addonSkus;
                        accountsTobeUpdated.put(accountSO.Id, accountSO);
                    }
                }
            }

            Set<String> zpaProductSKUs = new Set<String>();
            if (accountSO != null
              && proposalIdToZPAlineItemsMap.containsKey(pSO.Id)) {
              for (Apttus_Proposal__Proposal_Line_Item__c pliSO : proposalIdToZPAlineItemsMap.get(pSO.Id)) {
                  Set<Id> cancelledAssetIdSet = new Set<Id>();

                  if (pliSO.Apttus_QPConfig__LineStatus__c != APTS_CONSTANTS.LI_STATUS_CANCELLED
                      && setAddonSKUCodes.contains(pliSO.APTS_Product_Code__c)) {
                      addonProductSKUs.add(pliSO.APTS_Product_Code__c);
                  } else {
                      cancelledAssetIdSet.add(pliSO.Apttus_QPConfig__AssetLineItemId__c);
                  }

                  for (Apttus_Config2__AssetLineItem__c aliSO : accountSO.Apttus_Config2__AssetLineItems__r) {
                      if(!cancelledAssetIdSet.contains(aliSO.Id)
                          && setZPAProductCodes.contains(aliSO.Product_Code__c))
                          zpaProductSKUs.add(aliSO.Product_Code__c);
                  }

                  String zpaSkus = APTS_UtilityFns.flattenSet(zpaProductSKUs, ', ');
                  if (accountsTobeUpdated.containsKey(accountSO.Id)) {
                      accountsTobeUpdated.get(accountSO.Id).ZPA_Asset_SKU__c = zpaSkus;
                  } else {
                      accountSO.ZPA_Asset_SKU__c = zpaSkus;
                      accountsTobeUpdated.put(accountSO.Id, accountSO);
                  }
              }
            }
            
            system.debug('accountSO.DAS_SKU__c  '+accountSO.DAS_SKU__c);
            //Added by Gurjinder for updating the DAS SKU on account:Start
            Set<String> DASSKUSet= new Set<String>();
            if(accountSO.DAS_SKU__c!=null && accountSO.DAS_SKU__c!=''){
                DASSKUSet.addall(accountSO.DAS_SKU__c.split(','));
            }
            accountSO.DAS_SKU__c='';
            if(pSO.Included_DAS_Package__c!=null && pSO.Included_DAS_Package__c!=''){
                DASSKUSet.addall(pSO.Included_DAS_Package__c.split(','));
            }
            String FinalDASSKUString='';
            for(String str:DASSKUSet){
                if(FinalDASSKUString==null || FinalDASSKUString==''){
                    FinalDASSKUString=str;
                }
                else{
                    FinalDASSKUString=FinalDASSKUString+','+str;
                }
            }
            
            if (accountsTobeUpdated.containsKey(accountSO.Id)) {
                accountsTobeUpdated.get(accountSO.Id).DAS_SKU__c = FinalDASSKUString;
            } else{
                accountSO.DAS_SKU__c = FinalDASSKUString;
                accountsTobeUpdated.put(accountSO.Id, accountSO);
            }
            system.debug('accountsTobeUpdated '+accountsTobeUpdated);
        }
        try
        {
            if(!accountsTobeUpdated.isEmpty())
                    update accountsTobeUpdated.values();
        }
        catch(DmlException e)
        {
           // System.debug(e);
        }
    }


    public class Yearsplitwrapper{
        Public decimal amount;
        public date startdate;
        public date enddate;
        public Yearsplitwrapper( decimal amount,date startdate,date enddate){
            this.amount =amount;
            this.startdate = startdate;
            this.enddate = enddate;
        }
    }

    /**
    Method to update the year wise split items
    **/

    // Vijay - 03/28/2018: Commenting the below as the logic has been moved to YearWiseSplitUtil class
    //  public void setYearWiseSplitValues(list<Apttus_Proposal__Proposal__c> primaryProposals)
    // { //Deleting Existing Year wise split records
    //
    //     Map<id,List<date>> MapPropDatess = new Map<id,List<date>>();
    //     list<APTS_Year_Wise_Split__c> yearWiseDeleteList = new list<APTS_Year_Wise_Split__c>();
    //     map<Id,List<Apttus_Config2__LineItem__c>> proposalLineItemMap =new map<id,List<Apttus_Config2__LineItem__c>>();
    //     yearWiseDeleteList = [Select id From APTS_Year_Wise_Split__c Where APTS_Proposal__c IN :primaryProposals];
    //     list<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new list<Apttus_Proposal__Proposal__c>();
    //
    //     Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>();
    //     for(Apttus_Proposal__Proposal__c prop : [select Id, APTS_Years_Split__c from Apttus_Proposal__Proposal__c
    //         where Id in: primaryProposals])
    //     {
    //         proposalMap.put(prop.Id, prop);
    //     }
    //
    //
    //
    //
    //     if(yearWiseDeleteList.size()>0)
    //     {
    //         try{
    //             delete yearWiseDeleteList;
    //         }catch(DmlException e){System.debug('Error'+e);}
    //     }
    //
    //     //New Year Wise Splits after deletion
    //     List<Apttus_Config2__LineItem__c> lineitems = [Select id,name,Apttus_Config2__ProductId__c,Apttus_Config2__PriceType__c,
    //                                                             Apttus_Config2__EndDate__c, Apttus_Config2__StartDate__c ,Apttus_Config2__NetPrice__c,Apttus_Config2__ProductId__r.Product_Line__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,
    //                                                             Apttus_Config2__SellingTerm__c,
    //                                                             Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c, APTS_Product_Code__c
    //                                                                     From Apttus_Config2__LineItem__c
    //                                                                         Where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c IN :primaryProposals
    //                                                                               AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c='Finalized'
    //                                                                                     order by Apttus_Config2__StartDate__c];
    //    // System.debug('lineitems1'+lineitems);
    //     for(Apttus_Config2__LineItem__c apLine: lineitems)
    //     {
    //         if(proposalLineItemMap.containsKey(apLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c))
    //             proposalLineItemMap.get(apLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c).add(apLine);
    //         else
    //         {
    //             list<Apttus_Config2__LineItem__c> lineList = new list<Apttus_Config2__LineItem__c>();
    //             lineList.add(apLine);
    //             proposalLineItemMap.put(apLine.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,lineList);
    //         }
    //     }
    //    // System.debug('lineitems2'+proposalLineItemMap);
    //     //Getting year wise split values
    //     map<id,map<integer,Yearsplitwrapper>> yearWiseMap = new map<id,map<integer,Yearsplitwrapper>>();
    //     list<APTS_Year_Wise_Split__c> yearWiseInsertList = new list<APTS_Year_Wise_Split__c>();
    //
    //     Map<Id, Map<Integer,Integer>>yearMap = new Map<Id, Map<Integer,Integer>>();
    //     for(Apttus_Proposal__Proposal__c p : primaryProposals)
    //     {
    //
    //
    //
    //         //change to line Items
    //         Date pStartDate = p.Apttus_Proposal__ExpectedStartDate__c;//=proposalLineItemMap.get(p.id)[0].Apttus_Config2__StartDate__c;
    //         Date pEndDate = p.Apttus_Proposal__ExpectedEndDate__c;//proposalLineItemMap.get(p.id)[0].Apttus_Config2__EndDate__c;
    //         MapPropDatess.put(p.id, New List<date>{pStartDate, PEndDate});
    //         Integer yearNumber = 1;
    //         Date tempdate= p.Apttus_Proposal__ExpectedStartDate__c;
    //
    //         do
    //         {
    //             if(yearMap.containsKey(p.id))
    //                 yearMap.get(p.id).put(tempdate.year(),yearNumber);
    //             else
    //                 yearMap.put(p.id, new Map<Integer,Integer>{tempdate.year()=>yearNumber});
    //
    //             yearNumber = yearNumber+1;
    //             tempdate = tempdate.addYears(1);
    //
    //         }while(tempdate <= pEndDate);
    //         // BReak For loop
    //     }
    //
    //     //Identifying Support Products
    //     Map<ID,Apttus_Config2__LineItem__c> supportIDs = new Map<ID,Apttus_Config2__LineItem__c>();
    //     for(Apttus_Config2__LineItem__c LineItem : lineitems)
    //     {
    //         if(LineItem.Apttus_Config2__ProductId__r.Product_Line__c == 'Support')
    //         {
    //             supportIDs.put(LineItem.id, LineItem);
    //         }
    //
    //
    //     }
    //    // System.debug('supportMap---->'+supportIDs);
    //     map<integer,Yearsplitwrapper> newMap = new map<integer,Yearsplitwrapper>();
    //     map<id,map<integer,Yearsplitwrapper>> ProductnewMap = new map<id,map<integer,Yearsplitwrapper>>();
    //     map<id,map<id,map<integer,Yearsplitwrapper>>> PRoposalProductnewMap = new map<id,map<id,map<integer,Yearsplitwrapper>>>();
    //     List<APTS_Year_Wise_Split__c> YearWiseSplitList = new List<APTS_Year_Wise_Split__c>();
    //     Map<ID,Map<Integer,Decimal>> supportAmountMap = new Map<ID,Map<Integer,Decimal>>();
    //     Decimal supportTotalAmount = 0;
    //     Boolean oneTimeProductFlag = false;
    //
    //     for(Apttus_Config2__LineItem__c LineItem : lineitems)
    //     {
    //         //Calculation for non support products
    //         if(!supportIDs.containsKey(LineItem.id))
    //         {
    //
    //            // System.debug('lineitems4'+LineItem.Apttus_Config2__StartDate__c);
    //             Date pEndDate=LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;
    //             Date OriginalStartDate = LineItem.Apttus_Config2__StartDate__c;
    //             Date OriginalStartDate1 = LineItem.Apttus_Config2__StartDate__c;
    //             Date proratedProposalStartDate = MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0];
    //             Date OriginalEndDate= LineItem.Apttus_Config2__EndDate__c;
    //             Date OriginalEndDate1= LineItem.Apttus_Config2__EndDate__c;
    //             Date LineStartDate = LineItem.Apttus_Config2__StartDate__c;
    //
    //             Date proratedProposalEndDate;
    //             if(pEndDate<proratedProposalStartDate.addyears(1))
    //                 proratedProposalEndDate=pEndDate;
    //             else
    //                 proratedProposalEndDate=proratedProposalStartDate.addyears(1).addDays(-1);
    //
    //             // Date LineItemStartDate= LineItem.Apttus_Config2__StartDate__c;
    //             Date LineEndDate = LineItem.Apttus_Config2__EndDate__c;
    //             //Date nextYeardate = LineStartDate.addMonths(12);
    //             date PriceStart,PriceEnd;
    //             Yearsplitwrapper Tempwrapper;
    //
    //             //Flag to identify first year in iterations
    //             BOOLEAN counter = false;
    //             //Flag to identify one time products
    //             oneTimeProductFlag = false;
    //             //Number of days left in the year if duration is less than a year
    //             Integer daysCounter = 0;
    //             //Flag if difference between LineStartDate and LineEndDate is less than 365 days
    //             Boolean isSpecialCase = false;
    //
    //             while( (LineStartDate<pEndDate && LineStartDate<LineEndDate) || (LineItem.Apttus_Config2__PriceType__c == 'One Time' && !oneTimeProductFlag))
    //             {
    //                 isSpecialCase = false;
    //
    //                // System.debug('Loop 1---'+LineItem.id+'------'+LineStartDate+'------'+LineEndDate);
    //                 Decimal avgprice;
    //
    //                 //Calculation of proratedProposalStartDate and proratedProposalEndDate
    //                 while(proratedProposalStartDate.addYears(1)<=LineStartDate)
    //                 {
    //                    proratedProposalStartDate= proratedProposalStartDate.addYears(1);
    //                     if(pEndDate<proratedProposalStartDate.addyears(1))
    //                         proratedProposalEndDate=pEndDate;
    //                     else
    //                         proratedProposalEndDate=proratedProposalStartDate.addyears(1).addDays(-1);
    //
    //                 }
    //
    //                 if( LineItem.Apttus_Config2__PriceType__c != 'One Time' && (OriginalStartDate1.daysBetween(OriginalEndDate1) + 1)<365 )
    //                 {
    //                     daysCounter = daysCounter + OriginalStartDate1.daysBetween(OriginalEndDate1) + 1;
    //                 }
    //
    //                 if( LineItem.Apttus_Config2__PriceType__c != 'One Time' && (OriginalStartDate1.daysBetween(OriginalEndDate1) + 1)<365)
    //                 {
    //                     isSpecialCase = true;
    //                 }
    //
    //                 //Setting data for year wise split when price type is One Time
    //                 if(LineItem.Apttus_Config2__PriceType__c == 'One Time'){
    //                     oneTimeProductFlag = true;
    //                     avgprice = LineItem.Apttus_Config2__NetPrice__c;
    //
    //                     //Difference between start date and end date will be one as price has to be calculated only one time
    //                     PriceStart = proratedProposalStartDate;
    //                     PriceEnd = proratedProposalStartDate;
    //                     proratedProposalStartDate = MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0];
    //                     proratedProposalEndDate = MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1];
    //
    //                     //Condition for particular products
    //                     if(LineItem.APTS_Product_Code__c == 'ZCR-BuyBack'){
    //                         Decimal diffOfYears = (proratedProposalStartDate.daysBetween(proratedProposalEndDate)/365.25);
    //                         Integer noOfYears = (Integer) diffOfYears.round(System.RoundingMode.DOWN);
    //                         proratedProposalStartDate = proratedProposalStartDate.addYears(noOfYears);
    //                         if(proratedProposalEndDate > proratedProposalStartDate.addYears(1)){
    //                             proratedProposalEndDate = proratedProposalStartDate.addYears(1).addDays(-1);
    //                         }
    //                     }
    //                     else if(LineItem.APTS_Product_Code__c == 'ZCR-UPY4'){
    //                         proratedProposalStartDate = proratedProposalStartDate.addYears(3);
    //                         if(proratedProposalEndDate > proratedProposalStartDate.addYears(1)){
    //                             proratedProposalEndDate = proratedProposalStartDate.addYears(1).addDays(-1);
    //                         }
    //                     }
    //                     else if(LineItem.APTS_Product_Code__c == 'ZCR-UPY5'){
    //                         proratedProposalStartDate = proratedProposalStartDate.addYears(4);
    //                         if(proratedProposalEndDate > proratedProposalStartDate.addYears(1)){
    //                             proratedProposalEndDate = proratedProposalStartDate.addYears(1).addDays(-1);
    //                         }
    //                     }
    //                     else if(proratedProposalEndDate > proratedProposalStartDate.addYears(1)){
    //                         proratedProposalEndDate = proratedProposalStartDate.addYears(1).addDays(-1);
    //                     }
    //                 }
    //                 //Calculation for products which are not One Time
    //                 else
    //                 {
    //                     if(LineStartDate>=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0]&&LineEndDate<=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]){
    //                         if (LineItem.APTS_Product_Code__c == APTS_CONSTANTS.PROD_SKU_Z_CREDIT) {
    //                             avgprice = LineItem.Apttus_Config2__NetPrice__c/(365 * (LineItem.Apttus_Config2__SellingTerm__c / 12));
    //                         } else {
    //                             avgprice = LineItem.Apttus_Config2__NetPrice__c/(365 * LineItem.Apttus_Config2__SellingTerm__c);
    //                         }
    //                        // System.debug('AVGprice--------------------'+LineItem.Apttus_Config2__NetPrice__c);
    //
    //                         PriceStart= LineStartDate;
    //                         PriceEnd = LineStartDate.addyears(1)>LineEndDate?LineEndDate:proratedProposalEndDate;
    //                        // System.debug(avgprice +'AVGprice--------------------'+PriceStart+'+======'+PriceEnd);
    //                     }
    //                     else if(LineStartDate<MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0]&&LineEndDate<=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]){
    //                         avgprice = LineItem.Apttus_Config2__NetPrice__c/(365 * LineItem.Apttus_Config2__SellingTerm__c);
    //                        // System.debug(avgprice +'AVGprice--------------------');
    //                         IF(!counter)
    //                         LineStartDate=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0];
    //
    //                         PriceStart = LineStartDate;
    //                         PriceEnd = LineStartDate.addyears(1)>LineEndDate?LineEndDate:proratedProposalEndDate;
    //                         //PriceEnd = LineStartDate.addyears(1)>LineEndDate?LineEndDate:LineStartDate.addyears(1);
    //                     }else if(LineStartDate>=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0]&&LineEndDate>MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]){
    //                         avgprice = LineItem.Apttus_Config2__NetPrice__c/(365 * LineItem.Apttus_Config2__SellingTerm__c);
    //
    //                         LineEndDate = MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1];
    //                         PriceStart = LineStartDate;
    //                         PriceEnd = LineStartDate.addyears(1)>MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]?MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]:proratedProposalEndDate;
    //                     }
    //                     else if(LineStartDate<MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0]&&LineEndDate>MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[1]){
    //                         avgprice = LineItem.Apttus_Config2__NetPrice__c/(365 * LineItem.Apttus_Config2__SellingTerm__c);
    //                         LineStartDate=MapPropDatess.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)[0];
    //                         LineEndDate = proratedProposalEndDate;
    //                         PriceStart = LineStartDate;
    //                         PriceEnd = proratedProposalEndDate;
    //                     }
    //                     else {
    //                         break;
    //                     }
    //                 }
    //
    //                // System.debug('Bose PriceStart: ' + PriceStart);
    //                // System.debug('Bose avgprice: ' + avgprice);
    //                // System.debug('Bose PriceEnd: ' + PriceEnd);
    //                // System.debug('Bose daysCounter: ' + daysCounter);
    //                // System.debug('ProdMap--------------------'+PRoposalProductnewMap);
    //
    //                 //Creation of Year Wise Split using Yearsplitwrapper
    //                 if(PRoposalProductnewMap.containskey(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c)){
    //                     ProductnewMap = PRoposalProductnewMap.get(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c);
    //                     if(ProductnewMap.containskey(LineItem.Apttus_Config2__ProductId__c)){
    //                         newmap = ProductnewMap.get(LineItem.Apttus_Config2__ProductId__c);
    //                         if(newmap.containskey(proratedProposalStartDate.year())){
    //                             Tempwrapper = newmap.get(proratedProposalStartDate.year());
    //
    //                             if((PriceStart.daysBetween(PriceEnd) + 1)<365 &&
    //                                     LineItem.Apttus_Config2__PriceType__c != 'One Time' && counter){
    //                                 Tempwrapper.amount = Tempwrapper.amount + (avgprice * ((365 * LineItem.Apttus_Config2__SellingTerm__c) - daysCounter));
    //                             }
    //                             else if(isSpecialCase)
    //                             {
    //                                 Tempwrapper.amount = Tempwrapper.amount + LineItem.Apttus_Config2__NetPrice__c;
    //                             }
    //                             else{
    //                                 decimal temp = ((decimal)PriceStart.daysBetween(PriceEnd) + 1)/365;
    //                                 Decimal rounded = temp.setScale(2, RoundingMode.HALF_UP);
    //                                 Tempwrapper.amount = Tempwrapper.amount + (avgprice * 365 * rounded);
    //                             }
    //
    //                             //Tempwrapper.amount = Tempwrapper.amount+(avgprice*(PriceStart.daysBetween(PriceEnd) + 1));
    //                             Tempwrapper.startdate = proratedProposalStartDate;//Tempwrapper.startdate<PriceStart?Tempwrapper.startdate:PriceStart;
    //                             Tempwrapper.enddate = proratedProposalEndDate;//Tempwrapper.enddate>PriceEnd?Tempwrapper.enddate:PriceEnd;
    //                             newmap.put(proratedProposalStartDate.year(),Tempwrapper);
    //                           // System.debug(LineItem.Apttus_Config2__ProductId__c+'1------'+proratedProposalStartDate.year()+'----'+newmap.get(LineStartDate.year())+(avgprice*PriceStart.daysBetween(PriceEnd)));
    //                         }
    //                         else{
    //                             if((PriceStart.daysBetween(PriceEnd) + 1)<365 && LineItem.Apttus_Config2__PriceType__c != 'One Time' && counter){
    //                                 Tempwrapper = new Yearsplitwrapper((avgprice * ((365 * LineItem.Apttus_Config2__SellingTerm__c) - daysCounter)), proratedProposalStartDate, proratedProposalEndDate);
    //                             }
    //                             else if(isSpecialCase)
    //                             {
    //                                 Tempwrapper = new Yearsplitwrapper(LineItem.Apttus_Config2__NetPrice__c, proratedProposalStartDate, proratedProposalEndDate);
    //                             }
    //                             else{
    //                                 decimal temp = ((decimal)PriceStart.daysBetween(PriceEnd) + 1)/365;
    //                                 Decimal rounded = temp.setScale(2, RoundingMode.HALF_UP);
    //                                 Tempwrapper = new Yearsplitwrapper(avgprice * 365 * rounded, proratedProposalStartDate, proratedProposalEndDate);
    //                             }
    //
    //                             newmap.put(proratedProposalStartDate.year(),Tempwrapper );
    //                            // System.debug(LineItem.Apttus_Config2__ProductId__c+'2------'+proratedProposalStartDate.year()+'----'+(avgprice*PriceStart.daysBetween(PriceEnd)));
    //                         }
    //                         ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,newmap);
    //                     }
    //                     else{
    //                         if((PriceStart.daysBetween(PriceEnd) + 1)<365 && LineItem.Apttus_Config2__PriceType__c != 'One Time' && counter){
    //
    //                                 ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper((avgprice * ((365 * LineItem.Apttus_Config2__SellingTerm__c) - daysCounter)), proratedProposalStartDate, proratedProposalEndDate)});
    //                             }
    //                             else if(isSpecialCase)
    //                             {
    //                                 ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(LineItem.Apttus_Config2__NetPrice__c, proratedProposalStartDate, proratedProposalEndDate)});
    //
    //                             }
    //                             else if(oneTimeProductFlag){
    //                                 ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(avgprice, proratedProposalStartDate, proratedProposalEndDate)});
    //                             }
    //                             else{
    //                                 decimal temp = ((decimal)PriceStart.daysBetween(PriceEnd) + 1)/365;
    //                                 Decimal rounded = temp.setScale(2, RoundingMode.HALF_UP);
    //                                 ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(avgprice * 365 * rounded, proratedProposalStartDate, proratedProposalEndDate)});
    //                             }
    //
    //
    //
    //                        // System.debug(LineItem.Apttus_Config2__ProductId__c+'3------'+proratedProposalStartDate.year()+'----'+(avgprice*PriceStart.daysBetween(PriceEnd)));
    //
    //
    //                     }
    //
    //                     PRoposalProductnewMap.put(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c,ProductnewMap);
    //                 }
    //                 else{
    //
    //                     if((PriceStart.daysBetween(PriceEnd) + 1)<365 && LineItem.Apttus_Config2__PriceType__c != 'One Time' && counter){
    //
    //                         PRoposalProductnewMap.put(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, new map<id,map<integer,Yearsplitwrapper>>{LineItem.Apttus_Config2__ProductId__c=>new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper((avgprice * ((365 * LineItem.Apttus_Config2__SellingTerm__c) - daysCounter)), proratedProposalStartDate, proratedProposalEndDate)}});
    //                     }
    //                     else if(isSpecialCase)
    //                     {
    //                         PRoposalProductnewMap.put(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, new map<id,map<integer,Yearsplitwrapper>>{LineItem.Apttus_Config2__ProductId__c=>new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(LineItem.Apttus_Config2__NetPrice__c, proratedProposalStartDate, proratedProposalEndDate)}});
    //
    //                     }
    //                     else if(oneTimeProductFlag){
    //                         PRoposalProductnewMap.put(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, new map<id,map<integer,Yearsplitwrapper>>{LineItem.Apttus_Config2__ProductId__c=>new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(avgprice, proratedProposalStartDate, proratedProposalEndDate)}});
    //                     }
    //                     else{
    //
    //                         decimal temp = ((decimal)PriceStart.daysBetween(PriceEnd) + 1)/365;
    //                         Decimal rounded = temp.setScale(2, RoundingMode.HALF_UP);
    //                         PRoposalProductnewMap.put(LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, new map<id,map<integer,Yearsplitwrapper>>{LineItem.Apttus_Config2__ProductId__c=>new map<integer,Yearsplitwrapper>{proratedProposalStartDate.year()=> new Yearsplitwrapper(avgprice * 365 * rounded, proratedProposalStartDate, proratedProposalEndDate)}});
    //                     }
    //
    //
    //                    // System.debug(LineItem.Apttus_Config2__ProductId__c+'4------'+proratedProposalStartDate.year()+'----'+(avgprice*PriceStart.daysBetween(PriceEnd)));
    //                 }
    //                // System.debug('Bose PRoposalProductnewMap: ' + PRoposalProductnewMap);
    //
    //                 //to count support product calculations
    //                 if(!supportIDs.isEmpty() && LineItem.Apttus_Config2__PriceType__c != 'One Time')
    //                 {
    //                     for(Id lineId : supportIDs.keyset())
    //                     {
    //                         Decimal avgpriceSupport;
    //
    //
    //
    //                        avgpriceSupport= avgprice*PriceStart.daysBetween(PriceEnd);
    //                         supportTotalAmount += avgpriceSupport;
    //
    //                         if(supportAmountMap.containskey(lineId))
    //                         {
    //                             if(supportAmountMap.get(lineId) != null
    //                                 && supportAmountMap.get(lineId).containskey(LineStartDate.year()))
    //                             {
    //                                 decimal tempamnt = supportAmountMap.get(lineId).get(LineStartDate.year());
    //                                 tempamnt += avgpriceSupport;
    //                                 supportAmountMap.get(lineId).put(LineStartDate.year(),tempamnt);
    //                             }
    //                             else
    //                                 supportAmountMap.get(lineId).put(LineStartDate.year(),avgpriceSupport);
    //
    //                         }
    //                         else
    //                         {
    //                             if(supportIDs.get(lineID).Apttus_Config2__StartDate__c != null)
    //                             supportAmountMap.put(lineId, new Map<Integer,Decimal>{supportIDs.get(lineID).Apttus_Config2__StartDate__c.year()=>avgpriceSupport})   ;
    //                         }
    //
    //                     }
    //                 }
    //
    //                 // Logic for finding the dates:
    //                 proratedProposalStartDate=proratedProposalStartDate.addyears(1);
    //                 LineStartDate = PriceEnd.addDays(1);
    //                 if(pEndDate<proratedProposalStartDate.addyears(1))
    //                     proratedProposalEndDate=pEndDate;
    //                 else
    //                     proratedProposalEndDate=proratedProposalStartDate.addyears(1).addDays(-1);
    //
    //                 counter = true;
    //
    //                 if(!(LineItem.Apttus_Config2__PriceType__c != 'One Time' && (OriginalStartDate1.daysBetween(OriginalEndDate1) + 1)<365 ))
    //                 {
    //                     daysCounter = daysCounter + 365;
    //                 }
    //
    //                // System.debug('Bose PRoposalProductnewMap: ' + PRoposalProductnewMap);
    //             }
    //         }
    //     }
    //
    //     //calculate for product line items
    //    // System.debug(supportTotalAmount+'lineMap--->'+supportAmountMap);
    //     for(Id lineId : supportIDs.keyset())
    //     {
    //         Apttus_Config2__LineItem__c LineItem =supportIDs.get(lineId);
    //
    //
    //         Date pEndDate=LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;
    //         Date pStartDate=LineItem.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c;
    //         Date OriginalStartDate = LineItem.Apttus_Config2__StartDate__c;
    //         Date OriginalEndDate= LineItem.Apttus_Config2__EndDate__c;
    //
    //
    //         while(pStartDate<OriginalEndDate && pStartDate <=pEndDate)
    //         {
    //
    //             Decimal proratedAmount;
    //     if(supportAmountMap.containsKey(lineId))
    //       proratedAmount = supportAmountMap.get(lineId).get(pStartDate.year());
    //             if(proratedAmount == null)
    //             {
    //                 proratedAmount = 0;
    //             }
    //
    //     Decimal supportamnt = 0;
    //             if(supportTotalAmount != null && supportTotalAmount > 0)
    //               supportamnt = proratedAmount*LineItem.Apttus_Config2__NetPrice__c/supportTotalAmount;
    //             Date endYear=pStartDate.addYears(1);
    //             if(!ProductnewMap.containskey(LineItem.Apttus_Config2__ProductId__c))
    //                 ProductnewMap.put(LineItem.Apttus_Config2__ProductId__c,new map<integer,Yearsplitwrapper>{pStartDate.year()=> new Yearsplitwrapper(supportamnt, pStartDate, endYear)});
    //             else
    //             {
    //                 ProductnewMap.get(LineItem.Apttus_Config2__ProductId__c).put(pStartDate.year(),new Yearsplitwrapper(supportamnt, pStartDate, endYear));
    //             }
    //             pStartDate=pStartDate.addYears(1);
    //            // System.debug('support--->'+supportamnt);
    //         }
    //     }
    //
    //     //Map to store maximum year number along with the proposal Id
    //     map<id, integer> maxYearNumberMap = new map<Id, integer>();
    //
    //     //Calculation of Maximum Year Number
    //     for(id Prop: PRoposalProductnewMap.keyset()){
    //         maxYearNumberMap.put(Prop, 0);
    //         ProductnewMap = PRoposalProductnewMap.get(Prop);
    //         for(id Productid: ProductnewMap.keyset()){
    //             for(integer year: ProductnewMap.get(Productid).keyset()){
    //                 if(maxYearNumberMap.get(Prop) <= yearMap.get(Prop).get(year)){
    //                     maxYearNumberMap.put(Prop, yearMap.get(Prop).get(year));
    //                 }
    //             }
    //         }
    //         Apttus_Proposal__Proposal__c proposal = proposalMap.get(Prop);
    //         proposal.APTS_Years_Split__c = maxYearNumberMap.get(Prop);
    //         proposalsToBeUpdated.add(proposal);
    //     }
    //
    //
    //     //list<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new list<Apttus_Proposal__Proposal__c>();
    //
    //     //Map<Id, Apttus_Proposal__Proposal__c> proposalMap
    //
    //     //Condition for particular One Time products
    //     Product2[] buyBackProducts = [SELECT Id from Product2 where ProductCode = 'ZCR-BuyBack'];
    //     Id buyBackProductId = null;
    //
    //     if(!buyBackProducts.isEmpty())
    //     {
    //         buyBackProductId = buyBackProducts[0].Id;
    //     }
    //
    //     buyBackProducts = [SELECT Id from Product2 where ProductCode = 'ZCR-UPY4'];
    //     Id upliftYear4 = null;
    //
    //     if(!buyBackProducts.isEmpty())
    //     {
    //         upliftYear4 = buyBackProducts[0].Id;
    //     }
    //
    //     buyBackProducts = [SELECT Id from Product2 where ProductCode = 'ZCR-UPY5'];
    //     Id upliftYear5 = null;
    //
    //     if(!buyBackProducts.isEmpty())
    //     {
    //         upliftYear5 = buyBackProducts[0].Id;
    //     }
    //
    //     //Adding year numnber, year start date and year end date in yearwisesplit wrapper
    //     for(id Prop: PRoposalProductnewMap.keyset()){
    //         ProductnewMap = PRoposalProductnewMap.get(Prop);
    //         for(id Productid: ProductnewMap.keyset()){
    //             for(integer year: ProductnewMap.get(Productid).keyset()){
    //                 APTS_Year_Wise_Split__c ywsObj = new APTS_Year_Wise_Split__c();
    //                 if(Productid == buyBackProductId){
    //                     ywsObj.APTS_Year__c =  'Year '+ maxYearNumberMap.get(Prop);
    //                 }
    //                 else if(Productid == upliftYear4)
    //                 {
    //                     ywsObj.APTS_Year__c =  'Year 4';
    //                 }
    //                 else if(Productid == upliftYear5)
    //                 {
    //                     ywsObj.APTS_Year__c =  'Year 5';
    //                 }
    //                 else{
    //                     ywsObj.APTS_Year__c = 'Year '+yearMap.get(Prop).get(year);
    //                 }
    //                 ywsObj.APTS_Year_End_Date__c =ProductnewMap.get(Productid).get(year).enddate;
    //                 ywsObj.APTS_Start_Date__c=ProductnewMap.get(Productid).get(year).startdate;
    //                 ywsObj.Product__c  = Productid;
    //                 ywsObj.APTS_Proposal__c = Prop;
    //                 ywsObj.APTS_Amount__c = ProductnewMap.get(Productid).get(year).amount;
    //                 yearWiseInsertList.add(ywsObj);
    //             }
    //         }
    //     }
    //
    //     Map<Id, Map<string,decimal>> subTotalMap = new Map<Id, Map<string,decimal>>();
    //      //subTotalMap = new Map<string,decimal>();
    //     decimal subTotal = 0;
    //     Map<string,decimal> tempYearMap;
    //     if(yearWiseInsertList!=NULL && yearWiseInsertList.size()>0)
    //     {
    //         //Create a yearwise sub total map
    //         for(APTS_Year_Wise_Split__c split : yearWiseInsertList)
    //         {
    //             subTotal = 0;
    //             tempYearMap = new Map<string,decimal>();
    //             if(subTotalMap.containskey(split.APTS_Proposal__c))
    //             {
    //                 tempYearMap = subTotalMap.get(split.APTS_Proposal__c);
    //
    //                 if(tempYearMap.containskey(split.APTS_Year__c))
    //                 {
    //                     subTotal = tempYearMap.get(split.APTS_Year__c);
    //                     subTotal = subTotal + split.APTS_Amount__c;
    //                     tempYearMap.remove(split.APTS_Year__c);
    //                     tempYearMap.put(split.APTS_Year__c, subTotal);
    //
    //                     subTotalMap.remove(split.APTS_Proposal__c);
    //                     subTotalMap.put(split.APTS_Proposal__c, tempYearMap);
    //                 }
    //                 else
    //                 {
    //                     tempYearMap.put(split.APTS_Year__c, split.APTS_Amount__c);
    //                     subTotalMap.remove(split.APTS_Proposal__c);
    //                     subTotalMap.put(split.APTS_Proposal__c, tempYearMap);
    //                 }
    //             }
    //             else
    //             {
    //                 tempYearMap.put(split.APTS_Year__c, split.APTS_Amount__c);
    //                 subTotalMap.put(split.APTS_Proposal__c, tempYearMap);
    //             }
    //         }
    //
    //         if(subTotalMap.size() > 0)
    //         {
    //             for(Id proposalId : subTotalMap.keySet())
    //             {
    //                 tempYearMap = subTotalMap.get(proposalId);
    //                 for(string yearNo : tempYearMap.keySet())
    //                 {
    //                     APTS_Year_Wise_Split__c ywsObj = new APTS_Year_Wise_Split__c();
    //                     ywsObj.APTS_Year__c = yearNo;
    //                     ywsObj.APTS_Year_Wise_Sub_Total__c= tempYearMap.get(yearNo);
    //                     ywsObj.APTS_Proposal__c = proposalId;
    //                     yearWiseInsertList.add(ywsObj);
    //                 }
    //             }
    //         }
    //     }
    //
    //     if(yearWiseInsertList!=NULL && yearWiseInsertList.size()>0)
    //     {
    //         try{
    //             insert yearWiseInsertList;
    //         }catch(DmlException e){System.debug('Error:'+e);}
    //     }
    //
    //     if(proposalsToBeUpdated.size()>0)
    //     {
    //         try{
    //             update proposalsToBeUpdated;
    //         }catch(DmlException e){System.debug('Error:'+e);}
    //     }
    //
    // }
    /**
    Method to set the Quote /Proposal Start/End Date From Opportunity
    Start Date should be Opty End date + 1
    End Date should be Start Date + 3 years
    // Update: HE, 12/09/2016 - changed proposal end date to be always startdate+3 years -1day.
    **/

    public void setQuoteDefaultValues(list<Apttus_Proposal__Proposal__c> lstNewProp){

        ID opty = lstNewProp[0].Apttus_Proposal__Opportunity__C;
        Apttus_Proposal__Proposal__c[] primaryProposal;
        //CR# 223 - Abhishek V - Early_Adopter - Start
        List <Opportunity> OpList = [Select ID, Start_Date__c, CloseDate, OwnerId, AccountId, Account.APTS_Platform_Subscription_End_Date__c, Opportunity_Sales_Territory__c, Opportunity_Sales_Territory__r.Regional_VP__c, Account.Sales_Territory__r.Regional_VP__c, Account.Sales_Territory__r.Area_VP__c,Is_Federal_Opportunity_Sync__c From Opportunity Where ID = :opty ];
        //CR# 223 - Abhishek V - Early_Adopter - End
        //List<OpportunityPartner> oppyPartRec = new List<OpportunityPartner>();
        List<Opportunity_Partner__c> oppyPartners = new List<Opportunity_Partner__c>();
        
        Opportunity_Partner__c oppResellerPartner = new Opportunity_Partner__c();
        Opportunity_Partner__c oppDistributorPartner = new Opportunity_Partner__c();
        
        Account acct = new Account();
        Id ownerID = OpList[0].OwnerId;
        Opportunity parentOppty = OpList.get(0);

        User usr = new User();
        usr = [Select ManagerId
                    From User
                        Where Id =: ownerID];
        oppyPartners = [Select Account__c, Partner_Type__c
                                From Opportunity_Partner__c
                                    Where Opportunity__c = :opty
                                          AND Is_Primary__c = true 
                                          AND (Partner_Type__c = 'Reseller' OR Partner_Type__c = 'Distributor')];
        for(Opportunity_Partner__c oppPartnerRec : oppyPartners){
            if(oppPartnerRec.Partner_Type__c == 'Distributor'){
                oppDistributorPartner = oppPartnerRec;
            }
            else if(oppPartnerRec.Partner_Type__c == 'Reseller'){
                oppResellerPartner = oppPartnerRec;
            }
        }
        
        System.debug('the oppDistributorPartner are' + oppDistributorPartner);
        System.debug('the oppResellerPartner are' + oppResellerPartner);
        
        

        Date opDate;
        Id rvpuser = null;
        Id avpuser = null;
        if(OpList !=null && OpList .size()>0)
        {
            opDate = OpList[0].CloseDate;
            //CR# 223 - Abhishek V - Early_Adopter - Start
            rvpuser = OpList[0].Account.Sales_Territory__r.Regional_VP__c;
            avpuser = OpList[0].Account.Sales_Territory__r.Area_VP__c;
            //CR# 223 - Abhishek V - Early_Adopter - End
        }

        for(Apttus_Proposal__Proposal__c proposal : lstNewProp) {
            resetApprovedFieldValues(proposal);
            proposal.Apttus_QPConfig__AutoActivateOrder__c   = True;
            proposal.Regional_VP__c = rvpuser;
            proposal.Area_VP__c = avpuser;
            if (opDate !=null)
            {
                date propStart = Date.today();
                if (opDate >= propStart)
                    propStart = opDate.addDays(1);

                Id recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Renewal');
                if(recordTypeId != null && recordTypeId == proposal.RecordTypeId)
                {
                    //propStart = OpList[0].Start_Date__c;
                    //propend = OpList[0].CloseDate;
                }

                //Modified by sagar jogi start- 15-11-2016
                if(proposal.OwnerId == null)
                proposal.OwnerId = ownerID;

                //Modified by sagar jogi end- 15-11-2016

                if (proposal.Apttus_Proposal__Approval_Stage__c == null) {
                    proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
                }

                if (proposal.Apttus_QPApprov__Approval_Status__c == null) {
                    proposal.Apttus_QPApprov__Approval_Status__c = 'Approval Required';
                }
                
                /*if (oppDistributorPartner.Account__c != null){
                    proposal.Apttus_QPConfig__BillToAccountId__c = oppDistributorPartner.Account__c;
                }*/
                
                if(oppResellerPartner.Account__c != null){
                    proposal.Apttus_QPConfig__BillToAccountId__c = oppResellerPartner.Account__c;
                }
                
                if (oppDistributorPartner.Account__c != null){
                    proposal.Distributor__c = oppDistributorPartner.Account__c;
                }
                else if(oppDistributorPartner.Account__c == null && oppResellerPartner.Account__c != null){
                    proposal.Distributor__c = oppResellerPartner.Account__c;
                }
                
                //Added by Sateesh for Primary Partner Changes
                if(proposal.Distributor__c != null){
                    acct = [Select Billing_Frequency__c, 
                                    Payment_Terms__c, 
                                    APTS_Platform_Subscription_End_Date__c
                                    From Account
                                    Where Id =: proposal.Distributor__c];
                }
                
                if (acct != null){
                    if (acct.Billing_Frequency__c != null)
                        proposal.APTS_Billing_Frequency__c = acct.Billing_Frequency__c;
                    if (acct.Payment_Terms__c != null)
                        proposal.Apttus_Proposal__Payment_Term__c = acct.Payment_Terms__c;
                }
                if (usr != null
                    && usr.ManagerId != null)
                    proposal.APTS_User_Manager__c = usr.ManagerId;
                if(proposal.Apttus_Proposal__ExpectedStartDate__c == null)
                    proposal.Apttus_Proposal__ExpectedStartDate__c = propStart;
                
                Date propend;
                if(parentOppty.Is_Federal_Opportunity_Sync__c){
                    propend = proposal.Apttus_Proposal__ExpectedStartDate__c.addyears(1); // Changes to make Contract Term of 1 year for Fed Quotes
                }else{
                    propend = proposal.Apttus_Proposal__ExpectedStartDate__c.addyears(3);
                }
                
                propend = propend.addDays(-1);
                proposal.Apttus_Proposal__ExpectedEndDate__c = propend;

               // System.debug('111111111111  22 ' + propend);

                // Update, HE 11/15/2016 - set Apttus_Proposal__ExpectedEndDate__c to opportunity.account.APTS_Platform_Subscription_End_Date__c for upsell quotes.
                recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Upsell');
                if(/* !parentOppty.Is_Federal_Opportunity_Sync__c &&  */recordTypeId != null && recordTypeId == proposal.RecordTypeId
                     && parentOppty.AccountId != null
                     && parentOppty.Account.APTS_Platform_Subscription_End_Date__c != null)
                {
                    //proposal.Apttus_Proposal__ExpectedStartDate__c = Date.today();
                    proposal.Apttus_Proposal__ExpectedEndDate__c = parentOppty.Account.APTS_Platform_Subscription_End_Date__c;//acct.APTS_Platform_Subscription_End_Date__c;
                   // System.debug('111111111111  33 ' + proposal.Apttus_Proposal__ExpectedEndDate__c);
                }

                //proposal.Apttus_Proposal__Valid_Until_Date__c = propStart.addDays(30);
                // Update, HE 11/15/2016 - : Set Valid until date to today+30 for all proposal types.
                proposal.Apttus_Proposal__Valid_Until_Date__c = Date.today().addDays(30);
            }

            //Handling for Primary
            primaryProposal = null;
            primaryProposal = [select Id, Name,Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c
            where Apttus_Proposal__Opportunity__C =: proposal.Apttus_Proposal__Opportunity__C
            and Apttus_Proposal__Primary__c = true];

            if(primaryProposal.isEmpty())
            {
                proposal.Apttus_Proposal__Primary__c = true;
            }
            proposal.Ramped_SKU_Codes__c = null;

        }
    }



    public void setQuoteDefaultValuesAfterInsert(list<Apttus_Proposal__Proposal__c> lstNewProp){

        ID opty = lstNewProp[0].Apttus_Proposal__Opportunity__C;
        Apttus_Proposal__Proposal__c[] primaryProposal;
        List <Opportunity> OpList = [Select ID,  Start_Date__c, CloseDate, OwnerId,Is_Federal_Opportunity_Sync__c From Opportunity Where ID = :opty ];
        List<OpportunityPartner> oppyPartRec = new List<OpportunityPartner>();
        Account acct = new Account();
        Id ownerID = OpList[0].OwnerId;
        Date propStart;
        Date propend;
        List<Apttus_Proposal__Proposal__c> proposalsToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c propToBeUpdated;
        for(Apttus_Proposal__Proposal__c proposal : lstNewProp) {


            Id recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Renewal');
            /** Commented by sagar jogi - 29/11 start
            if(recordTypeId != null && recordTypeId == proposal.RecordTypeId)
            {
                propStart = OpList[0].Start_Date__c;
                propend = OpList[0].CloseDate;

                propToBeUpdated = [select Id, Apttus_Proposal__ExpectedStartDate__c, Apttus_Proposal__ExpectedEndDate__c,
                                    Apttus_Proposal__Valid_Until_Date__c from Apttus_Proposal__Proposal__c where Id =: proposal.Id];

                propToBeUpdated.Apttus_Proposal__ExpectedStartDate__c = propStart;
                propToBeUpdated.Apttus_Proposal__ExpectedEndDate__c = propend;
                propToBeUpdated.Apttus_Proposal__Valid_Until_Date__c = propStart.addDays(30);



                proposalsToBeUpdated.add(propToBeUpdated);
            }
             Commented by sagar jogi - 29/11 end **/
            recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Upsell');
            if(/* !OpList[0].Is_Federal_Opportunity_Sync__c && */ recordTypeId != null && recordTypeId == proposal.RecordTypeId
                 && acct.APTS_Platform_Subscription_End_Date__c != null)
            {
                propToBeUpdated = [select Id, Apttus_Proposal__ExpectedStartDate__c, Apttus_Proposal__ExpectedEndDate__c,
                                    Apttus_Proposal__Valid_Until_Date__c from Apttus_Proposal__Proposal__c where Id =: proposal.Id];
              // System.debug('111111111111' + acct.APTS_Platform_Subscription_End_Date__c);
                propToBeUpdated.Apttus_Proposal__ExpectedEndDate__c = acct.APTS_Platform_Subscription_End_Date__c;
                //propToBeUpdated.Apttus_Proposal__ExpectedStartDate__c = Date.today();
                proposalsToBeUpdated.add(propToBeUpdated);
            }
        }

        if(proposalsToBeUpdated.size() > 0)
        {
            update proposalsToBeUpdated;
        }

    }


    private ID getRecordTypeIdForName(String sObjectName, String recordTypeName) {
        try {

            Id devRecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

            /*// get the record type
            List<RecordType> recordTypes = [SELECT Id
                                            FROM RecordType
                                            WHERE SobjectType = :sObjectName AND
                                                  (Name = :recordTypeName OR
                                                   DeveloperName = :recordTypeName)
                                            LIMIT 1];

            return (!recordTypes.isEmpty() ? recordTypes[0].Id : null);*/
            return (devRecordTypeId != null ? devRecordTypeId : null);
        }
        catch(Exception ex) {
            return null;
        }
    }
    // /**
    // Method to update the opportunity values based on primary quote
    //     TCV to be sum of net price of all line items below the opportunity
    //     ACV to be figured

    // **/
    // public void checkupdateOppValuesforPrimaryQuote(Map<ID,Apttus_Proposal__Proposal__c> mapNewProp,boolean isInsert)
    // {
    //     list<Apttus_Proposal__Proposal__c> lstNewProp = new list<Apttus_Proposal__Proposal__c> ();
    //     if(!isInsert)
    //     {
    //         for(Apttus_Proposal__Proposal__c prop :mapNewProp.values() )
    //         {
    //             //adds only the primary quotes for update
    //              if(prop.Apttus_Proposal__Primary__c)
    //              {

    //               lstNewProp.add(prop);
    //              }
    //         }

    //     }
    //     else
    //     {
    //         //add all primary quotes on insert.
    //         lstNewProp.addAll(mapNewProp.values());
    //     }
    //     if(!lstNewProp.isEmpty())
    //     updateOpportunityValuesForPrimaryQuote(lstNewProp);
    // }
    /**
    Method to update the opportunity values based on primary quote
    TCV to be sum of net price of all line items below the opportunity
    ACV to be figured

    **/

    public void updateOpportunityValuesForPrimaryQuote(list<Apttus_Proposal__Proposal__c> lsttrigProp){

        Map<ID,ID> QuoteOpportunityIDs= new Map<ID,ID>();
        Map<ID,Opportunity> QuoteOpportunity= new Map<ID,Opportunity>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        Map<Id, Opportunity> oppUpdateMap = new Map<Id, Opportunity>();
        list<Apttus_Proposal__Proposal__c> lstNewProp = new list<Apttus_Proposal__Proposal__c> ();
        //  Apttus_Proposal__Unit_Net_Price__c
        //  TCV__c
        for(Apttus_Proposal__Proposal__c prop:lsttrigProp )
        {
            //adds only the primary quotes for update

            lstNewProp.add(prop);
            QuoteOpportunityIDs.put(prop.id,prop.Apttus_Proposal__Opportunity__C);
        }
        //ID opty = lstNewProp[0].Apttus_Proposal__Opportunity__C;

        Map <ID,Opportunity> OpList = new Map<id, Opportunity>([Select ID, AccountId, Account.Non_Coterminous_Contracts__c, CloseDate,TCV__c From Opportunity Where ID IN :QuoteOpportunityIDs.values() ]);
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        for(Opportunity opp : OpList.values())
        {
            for(Id quoteid: QuoteOpportunityIDs.keyset())
            {
                if(QuoteOpportunityIDs.get(quoteid)==opp.id)
                {
                    QuoteOpportunity.put(quoteid,opp);

                }
            }

            if (opp.Account.Non_Coterminous_Contracts__c) {
                setAccountIds.add(opp.AccountId);
                setOpportunityIds.add(opp.Id);
            }
        }

        //query to sum total net price. Need to be updated for ACV
        AggregateResult[] groupedResults = [Select Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C oppQuote, SUM(APTS_ACV__c) netAcv,SUM(Apttus_Proposal__Unit_Net_Price__c) netPrice
                                                                From Apttus_Proposal__Proposal_Line_Item__c
                                                                    Where Apttus_Proposal__Proposal__c IN :QuoteOpportunityIDs.keyset()
                                                                        GROUP BY Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C ];

        for (AggregateResult ar : groupedResults)  {
            if(ar.get('oppQuote')!=null && OpList.containsKey((ID)ar.get('oppQuote')))
            {
                Opportunity opp = OpList.get((ID)ar.get('oppQuote'));
                //[Version 1.9: Commented out this to stop updating the Opportunity Amount value through Apttus.]
                //opp.Amount=(Decimal)ar.get('netAcv');
                //Need to update field
                opp.Apttus_TCV__c= (Decimal)ar.get('netPrice');
                oppUpdateMap.put(opp.Id, opp);
            }

        }

        if (setAccountIds.size() > 0) {
            Map<Id, Opportunity> mapOpportunityContractEndDates = OppotunityTriggerHelper.getOpportunityContractEndDates(new List<Id>(setAccountIds), new List<Id>(setOpportunityIds));
            for (Id oppId : mapOpportunityContractEndDates.keySet()) {
                if (oppUpdateMap.containsKey(oppId)) {
                    oppUpdateMap.get(oppId).Contract_End_Date_New__c = mapOpportunityContractEndDates.get(oppId).Contract_End_Date_New__c;
                }
            }
        }

        //add same logic for opportunity products

        try {
            update oppUpdateMap.values();
        }
        catch (Exception e)
        {
           // System.debug('An exception occurred '+e.getmessage());
        }
    }

    /**
    Method to update the opportunity line items based on primary quote


    **/

    public void updateOpportunityLineItemsForPrimaryQuote(list<Apttus_Proposal__Proposal__c> lstNewProp){

        Set<ID> oppIDS = new Set<ID> ();
        Set<ID> quoteids = new Set<ID>();
        Map<ID,ID> QuoteOpportunityIDs = new Map<ID,ID>();
        Map<ID,Opportunity> QuoteOpportunity = new Map<ID,Opportunity>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();

        //  Apttus_Proposal__Unit_Net_Price__c
        //  TCV__c
        for(Apttus_Proposal__Proposal__c prop:lstNewProp )
        {
            if(prop.Apttus_Proposal__Primary__c)
            {
                quoteids.add(prop.id);
            }
        }



        list<id>  opportunityidList = getrelatedOpportunityIDs(lstNewProp);
        List<Apttus_Proposal__Proposal_Line_Item__c> proposallineItemlist=  [Select id,Apttus_Proposal__Product__c,Apttus_QPConfig__OptionId__c,APTS_Product_Code__c,APTS_Selling_Term__c,Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__BasePrice__c, APTS_ACV__c, APTS_Net_Price__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_MRR__c, APTS_Prev_MRR__c, APTS_Partner_Disc__c, APTS_New_Logo_Disc__c,
                                                                                Partner_Adjustment_Type__c,
                                                                                Partner_Adjustment__c,
                                                                                Total_Stackable_Margin__c,
                                                                                Net_to_Zscaler__c,
                                                                                Total_Zscaler_Discount__c,
                                                                                Partner_Summit_Deal_Reg__c,
                                                                                AW_Margin_Formula__c,
                                                                                Fulfilment_Margin__c,
                                                                                POV__c,
                                                                                APTS_Deal_Reg_Disc__c, APTS_Manual_Discount__c, Apttus_QPApprov__Approval_Status__c, APTSCU_Renewal_ACV__c,
                                                                                Apttus_QPConfig__BaseExtendedPrice__c,
                                                                                APTS_Total_Discount_Percentage__c,
                                                                                Apttus_QPConfig__NetPrice__c,Name,Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C
                                                                              From Apttus_Proposal__Proposal_Line_Item__c
                                                                              Where Apttus_Proposal__Proposal__c IN :quoteids];


        //add new opportnity line items with the mappings
        List<OpportunityLineItem> newOppLineItemList = new List<OpportunityLineItem> ();
        list<opportunity> opportunitylist= getOpportunitylist(opportunityidList);
        list<PricebookEntry> pricebookentrylist = getPricebookentry(proposallineItemlist,opportunitylist);
        //Map<Id, Map<Id, decimal>> accountsWithAssetACV = getAccountAssetsACV(opportunitylist);
        Id opportunityAccountId = null;
        for(Apttus_Proposal__Proposal__c quote: lstNewProp){
            for(Apttus_Proposal__Proposal_Line_Item__c lineItemSO : proposallineItemlist){
                if(quote.id == lineitemso.Apttus_Proposal__Proposal__c){
                    OpportunityLineItem oppLineItem= new OpportunityLineItem();
                    opportunityAccountId = null;
                    for(Opportunity opp :opportunitylist){
                        if(opp.id == quote.Apttus_Proposal__Opportunity__c){
                            for(PricebookEntry entry: pricebookentrylist){
                                //system.debug('Inner loop check*********************'+((entry.Product2Id == lineItemSO.Apttus_Proposal__Product__c)&&(entry.Pricebook2Id == opp.Pricebook2Id)));

                                if(entry.Product2Id == lineItemSO.Apttus_Proposal__Product__c
                                && entry.Pricebook2Id == opp.Pricebook2Id){
                                    //if(entry.Product2Id == lineItemSO.Apttus_Proposal__Product__c){
                                    //system.debug('Inner loop check*********************'+entry.id);
                                    //system.debug('Inner loop check*********************'+entry.id);
                                    oppLineItem.PricebookEntryId = entry.id;
                                    // oppLineItem.UnitPrice=entry.UnitPrice;
                                    //oppLineItemSO.List_Price__c = lineitemSO.Apttus_QPConfig__BasePrice__c;
                                }
                            }

                            opportunityAccountId = opp.AccountId;

                        }
                    }
                   // oppLineItem.Product2Id = lineitemso.Apttus_Proposal__Product__c;
                    oppLineItem.Quantity=lineitemso.Apttus_QPConfig__Quantity2__c;
                    system.debug('line2620=class=proposal_Trigger_Handler=lineitemso.Apttus_QPConfig__BasePrice__c'+lineitemso.Apttus_QPConfig__BasePrice__c);
                    oppLineItem.US_List_Price__c=lineitemso.Apttus_QPConfig__BasePrice__c;
                    //oppLineItem.UnitPrice=quotelineitem.APTS_ACV__c;
                    //oppLineItem.TotalPrice=lineitemso.Apttus_QPConfig__NetPrice__c;
                    //   oppLineItem.SBQQ__QuoteLine__c=quotelineitem.id;
                    oppLineItem.Opportunityid=lineitemso.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C ;

                    oppLineItem.Apttus_Approval__Approval_Status__c = lineItemSO.Apttus_QPApprov__Approval_Status__c;
                    oppLineItem.APTS_Term__c = lineItemSO.APTS_Selling_Term__c;
                    oppLineItem.Discount = lineItemSO.APTS_Total_Discount_Percentage__c;
                    oppLineItem.APTS_List_Price__c = lineItemSO.Apttus_QPConfig__BaseExtendedPrice__c;
                    oppLineItem.APTS_Proposal_Line_Item__c = lineItemSO.Id;
                    /*
                    // === Due to Partner Summit Program (added by Minkesh patel)(Start)===
                    oppLineItem.Partner_Adjustment__c = lineItemSO.Partner_Adjustment__c;
                    oppLineItem.Partner_Adjustment_Type__c = lineItemSO.Partner_Adjustment_Type__c;
                    oppLineItem.Total_Stackable_Margin__c = lineItemSO.Total_Stackable_Margin__c;
                    oppLineItem.Net_to_Zscaler__c = lineItemSO.Net_to_Zscaler__c;
                    oppLineItem.Total_Zscaler_Discount__c = lineItemSO.Total_Zscaler_Discount__c;
                    oppLineItem.Partner_Summit_Deal_Reg__c = lineItemSO.Partner_Summit_Deal_Reg__c;
                    oppLineItem.AW_Margin_Formula__c = lineItemSO.AW_Margin_Formula__c;
                    //oppLineItem.Fulfilment_Margin__c = lineItemSO.Fulfilment_Margin__c;
                    oppLineItem.POV__c = lineItemSO.POV__c;
                    // ===(End)===
                    */
                    oppLineItem.TotalPrice = lineItemSO.APTS_ACV__c;
                    oppLineItem.APTS_TCV__c = lineItemSO.APTS_Net_Price__c;
                    oppLineItem.APTS_Start_Date__c = lineItemSO.Apttus_QPConfig__StartDate__c;
                    oppLineItem.APTS_End_Date__c = lineItemSO.Apttus_QPConfig__EndDate__c;
                    oppLineItem.APTS_MRR__c = lineItemSO.APTS_MRR__c;
                    oppLineItem.APTS_Previous_MRR__c = lineItemSO.APTS_Prev_MRR__c;
                    oppLineItem.APTS_Partner_Disc__c = lineItemSO.APTS_Partner_Disc__c;
                    oppLineItem.APTS_New_Logo__c = lineItemSO.APTS_New_Logo_Disc__c;
                    oppLineItem.APTS_Deal_Reg_Discount__c = lineItemSO.APTS_Deal_Reg_Disc__c;
                    oppLineItem.APTS_Manual_Discount__c = lineItemSO.APTS_Manual_Discount__c;
                    oppLineItem.APTSCU_New_ACV__c = lineItemSO.APTS_ACV__c;
                    oppLineItem.APTSCU_Old_ACV__c = lineItemSO.APTSCU_Renewal_ACV__c;

                    /*if(opportunityAccountId != null && accountsWithAssetACV.get(opportunityAccountId) != null &&
                        accountsWithAssetACV.get(opportunityAccountId).get(lineItemSO.Apttus_Proposal__Product__c) != null)
                        {
                            oppLineItem.APTSCU_Old_ACV__c = accountsWithAssetACV.get(opportunityAccountId).get(lineItemSO.Apttus_Proposal__Product__c);
                        }*/
                    newOppLineItemList.add(oppLineItem);
                }
            }
        }


        //  OppLineItemList = createOpportunityLineItem(proposal,proposallineItemlist,opportunitylist,pricebookentrylist);
        //   for(Apttus_Proposal__Proposal_Line_Item__c quotelineitem :quotelineItemList)
        //   {
        //       OpportunityLineItem oppLineItem= new OpportunityLineItem();

        //               oppLineItem.PricebookEntryId=pbs.get(quotelineitem.Apttus_Proposal__Product__c).id;
        //           //  oppLineItem.ProductCode=quotelineitem.APTS_Product_Code__c;

        //             //  oppLineItem.Committed_Months__c=quotelineitem.APTS_Selling_Term__c;
        //   }

        List<OpportunityLineItem> opplineItemList=  [Select id,Product2id, ProductCode,Committed_Months__c,Quantity,US_List_Price__c,UnitPrice,TotalPrice,SBQQ__QuoteLine__c
                                                                        From OpportunityLineItem
                                                                            Where Opportunityid IN :opportunityidList];
       // System.debug('Hormese '+newOppLineItemList);
        if(opplineItemList!=null)
        {
            try {
                delete opplineItemList;
            }
            catch (Exception e)
            {
               // System.debug('An exception occurred '+e.getmessage());
            }

        }
        if(newOppLineItemList!=null)
        {
            try {
                insert newOppLineItemList;
            }
            catch (Exception e)
            {
               // System.debug('An exception occurred '+e.getmessage());
            }

        }
        //ID opty = lstNewProp[0].Apttus_Proposal__Opportunity__C;

    }

    /// This method updates the Billing Frequency and Payment Terms of Quote bases on Bill To Account field
    private void updateFromBillToAccount(Set<Id> billToAccount, List<Apttus_Proposal__Proposal__c> proposalsToBeUpdated)
    {
        Map<Id, Account> billToAccounts = new Map<Id, Account>();

        if(billToAccount.size() > 0 && proposalsToBeUpdated.size() > 0)
        {
            for(Account acct : [Select Id, Billing_Frequency__c, Payment_Terms__c From Account Where Id IN :billToAccount])
            {
                billToAccounts.put(acct.Id, acct);
            }

            Account billToAcct;
            for(Apttus_Proposal__Proposal__c proposal : proposalsToBeUpdated)
            {
                if(billToAccounts.get(proposal.Distributor__c) != null)
                {
                    billToAcct = billToAccounts.get(proposal.Distributor__c);
                    if(billToAcct.Payment_Terms__c != null)
                    {
                        proposal.Apttus_Proposal__Payment_Term__c = billToAcct.Payment_Terms__c;
                    }
                    else
                    {
                        proposal.Apttus_Proposal__Payment_Term__c = 'Net 30';
                    }

                    if(billToAcct.Billing_Frequency__c != null)
                    {
                        proposal.APTS_Billing_Frequency__c = billToAcct.Billing_Frequency__c;
                    }
                    else
                    {
                        proposal.APTS_Billing_Frequency__c = 'Quarterly';
                    }
                }
            }
        }
    }

    public list<opportunity> getOpportunitylist(list<id> opplist) {

        // get the opportunity price book id
        list<opportunity>  opportunitylist = [Select id,Pricebook2Id, AccountId
                                                        From Opportunity
                                                            Where Id IN :opplist];

        return opportunitylist;
    }

    //Method to get opportunity related to proposal
    //@param: Proposal List
    //@return: Opportunity List
    public list<id> getrelatedOpportunityIDs(list<Apttus_Proposal__Proposal__c> proposalList){
        list<id>opportunityidList = new list<id>();
        for(Apttus_Proposal__Proposal__c quote: proposalList){
            if(quote.Apttus_Proposal__Opportunity__c == null){

            }
            else{
                opportunityidList.add(quote.Apttus_Proposal__Opportunity__c);
            }
        }
        return opportunityidList;
    }


    public void setQuotePriceListFromAdminSetting(list<Apttus_Proposal__Proposal__c> lstNewProp){
        String PriceListName='';
        List<Apttus_Config2__PriceList__c> ListOfPriceList;
        Id recordTypeId = getRecordTypeIdForName('' + Apttus_Proposal__Proposal__c.getSObjectType(), 'Renewal');
        List<Apttus__APTS_Admin__c> ListOfAdmin = [Select id,Name,Apttus__Code__c,Apttus__Value__c
                                                            From Apttus__APTS_Admin__c
                                                                Where Name = 'APTS_DefaultPriceList'
                                                                      AND Apttus__Value__c != null
                                                                      AND Apttus__Value__c != ''];

        if(ListOfAdmin!=null && ListOfAdmin.size()>0)
            PriceListName=ListOfAdmin[0].Apttus__Value__c ;

        If(PriceListName!='')
            ListOfPriceList=[Select id
                                From Apttus_Config2__PriceList__c
                                    Where Name=:PriceListName];
        

        if(ListOfPriceList!=null && ListOfPriceList.size()>0)
        {
            for(Apttus_Proposal__Proposal__c Proposal: lstNewProp) {
                if (Proposal.Price_List_Id__c != null) {
                    Proposal.Apttus_QPConfig__PriceListId__c = Proposal.Price_List_Id__c;
                } else if(!(Proposal.RecordTypeId == recordTypeId && Proposal.Apttus_QPConfig__PriceListId__c != null)){
                    Proposal.Apttus_QPConfig__PriceListId__c = ListOfPriceList[0].ID;
                }
            }
        }
    }

    /**
    * Method to set error for records which not valid for creation/edit.
    * For example, if opportunity is closed, record should not created/edited.
    Method Skeleton for Locked Quote
    **/
    public void ThrowErrorForQuoteOnLockedOpty(List<Apttus_Proposal__Proposal__c> newProposalList) {

        // Add error if Opportunity is closed (record is locked).
        for(Apttus_Proposal__Proposal__c proposal : newProposalList) {
            //     if(proposal.Locked_for_Edit__c) {
            proposal.addError('Opportunity is closed. Quote creation/editing is not allowed.');
            //      }
        }
    }

    //Method to get pricebook entry for each proposal line item
    //@param: Prposal Line item,opportunity list
    //@return: Price book Entry
    public list<PricebookEntry> getPricebookentry(list<Apttus_Proposal__Proposal_Line_Item__c> lineitem, list<opportunity> opplist){
        list<id> pricebookIDlist = new list<id>();
        for(Opportunity opp : opplist){
            pricebookIDlist.add(opp.Pricebook2Id);
        }

        list<id> productIDlist = new list<id>();
        for(Apttus_Proposal__Proposal_Line_Item__c proposalLine: lineitem){
            productIDlist.add(proposalLine.Apttus_Proposal__Product__c);
            if(proposalLine.Apttus_QPConfig__OptionId__c <> null){
                productIDlist.add(proposalLine.Apttus_QPConfig__OptionId__c);
            }
        }
        list<PricebookEntry>pricebookentrylist = [Select Id,Name, IsActive,Pricebook2Id,Product2Id,ProductCode,
                                                         UnitPrice,UseStandardPrice
                                                            From PricebookEntry
                                                                Where Product2Id IN :productIDlist];

       // System.debug('$$$$$$$$ productIDlist'+productIDlist);
        list<Pricebook2> pricebook = [Select Id
                                            From Pricebook2
                                                Where IsStandard = TRUE
                                                      AND id IN :pricebookIDlist];
        if(pricebook.size()==0){
            pricebook = [Select Id
                            From Pricebook2
                                Where IsStandard = TRUE];
        }

        for(Opportunity opp : opplist){
            // Set Price Book
            if(opp.Pricebook2Id == null)
                opp.Pricebook2Id = pricebook[0].id;

            // Set Updated by Apttus Flag
            //opp.APTPS_Updated_by_Apttus__c = true;
            // Commented out until deployed in production
        }
        update opplist;

      /*  list<Product2> product = [Select id
                                        From Product2
                                        Where id IN :productIDlist];*/

        list<PricebookEntry> pricebookentrylist1 = new list<PricebookEntry>();
        for(Pricebook2 book : pricebook){
            for(Id prod: productIDlist){
                boolean is_exist = false;
                for(PricebookEntry entry : pricebookentrylist){
                    if(book.id == entry.Pricebook2Id
                        && prod == entry.Product2Id){
                        is_exist = true;
                    }
                }

               // System.debug('$$$$$$$$$$'+is_exist);
                if(!is_exist){
                    PricebookEntry pbEntry = new PricebookEntry();
                    pbEntry.Pricebook2Id = book.id;
                    pbEntry.Product2Id = prod;
                    pbEntry.unitPrice = 0;
                    pbEntry.IsActive = true;
                    pricebookentrylist1.add(pbEntry);
                }
            }
        }
        insert pricebookentrylist1;



        /*for(Pricebook2 book : pricebook){
        for(Product2 prod: product){
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = book.id;
        pbEntry.Product2Id = prod.Id;
        pbEntry.unitPrice = 0;
        pbEntry.IsActive = true;
        pricebookentrylist.add(pbEntry);
        }

        }
        upsert pricebookentrylist;*/
        pricebookentrylist.clear();
        return pricebookentrylist = [Select Id,Name,IsActive,Pricebook2Id,
                                            Product2Id,ProductCode,UnitPrice,UseStandardPrice
                                                From PricebookEntry
                                                    Where Product2Id IN :productIDlist ];
    }

    /*private Map<Id, Map<Id, decimal>> getAccountAssetsACV(List<opportunity> opportunitylist)
    {
        Set<Id> accountIdSet = new Set<Id>();
        for(opportunity op : opportunitylist)
        {
            if(!accountIdSet.contains(op.AccountId))
            {
                accountIdSet.add(op.AccountId);
            }
        }

        Map<Id, Map<Id, decimal>> accountAssetsACV = new Map<Id, Map<Id, decimal>>();
        Decimal ACV = 0;
        Map<Id, decimal> productACV = new Map<Id, decimal>();
        for(Apttus_Config2__AssetLineItem__c asset : [select Id, Name, APTS_ACV__c, Apttus_Config2__ProductId__c,        Apttus_Config2__AccountId__c from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c in : accountIdSet])
        {
            if(accountAssetsACV.containsKey(asset.Apttus_Config2__AccountId__c))
            {
                productACV = accountAssetsACV.get(asset.Apttus_Config2__AccountId__c);
                if(productACV.containsKey(asset.Apttus_Config2__ProductId__c))
                {
                    ACV = productACV.get(asset.Apttus_Config2__ProductId__c);
                    if(asset.APTS_ACV__c != null)
                    {
                        ACV = ACV + asset.APTS_ACV__c;
                    }
                    productACV.remove(asset.Apttus_Config2__ProductId__c);
                    productACV.put(asset.Apttus_Config2__ProductId__c, ACV);

                    accountAssetsACV.remove(asset.Apttus_Config2__AccountId__c);
                    accountAssetsACV.put(asset.Apttus_Config2__AccountId__c, productACV);
                }
                else
                {
                    productACV = new Map<Id, decimal>();
                    ACV = 0;
                    if(asset.APTS_ACV__c != null)
                    {
                        ACV = asset.APTS_ACV__c;
                    }

                    productACV.put(asset.Apttus_Config2__ProductId__c, ACV);

                    accountAssetsACV.remove(asset.Apttus_Config2__AccountId__c);
                    accountAssetsACV.put(asset.Apttus_Config2__AccountId__c, productACV);
                }

            }
            else
            {
                productACV = new Map<Id, decimal>();
                ACV = 0;
                if(asset.APTS_ACV__c != null)
                {
                    ACV = asset.APTS_ACV__c;
                }

                productACV.put(asset.Apttus_Config2__ProductId__c, ACV);

                accountAssetsACV.put(asset.Apttus_Config2__AccountId__c, productACV);
            }
        }

        return accountAssetsACV;
    }

    private Map<Id, Map<Id, decimal>> getProposalssWithLineItemACV(List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems)
    {
        Map<Id, Map<Id, decimal>> proposalssWithLineItemACV = new Map<Id, Map<Id, decimal>>();
        Decimal ACV = 0;
        Map<Id, decimal> productACV = new Map<Id, decimal>();

        for(Apttus_Proposal__Proposal_Line_Item__c item : proposalLineItems)
        {
            if(proposalssWithLineItemACV.containsKey(item.Apttus_Proposal__Proposal__c))
            {
                productACV = proposalssWithLineItemACV.get(item.Apttus_Proposal__Proposal__c);
                if(productACV.containsKey(item.Apttus_Proposal__Product__c))
                {
                    ACV = productACV.get(item.Apttus_Proposal__Product__c);
                    if(item.APTS_ACV__c != null)
                    {
                        ACV = ACV + item.APTS_ACV__c;
                    }
                    productACV.remove(item.Apttus_Proposal__Product__c);
                    productACV.put(item.Apttus_Proposal__Product__c, ACV);

                    proposalssWithLineItemACV.remove(item.Apttus_Proposal__Proposal__c);
                    proposalssWithLineItemACV.put(item.Apttus_Proposal__Proposal__c, productACV);
                }
                else
                {
                    productACV = new Map<Id, decimal>();
                    ACV = 0;
                    if(item.APTS_ACV__c != null)
                    {
                        ACV = item.APTS_ACV__c;
                    }

                    productACV.put(item.Apttus_Proposal__Product__c, ACV);

                    proposalssWithLineItemACV.remove(item.Apttus_Proposal__Proposal__c);
                    proposalssWithLineItemACV.put(item.Apttus_Proposal__Proposal__c, productACV);
                }

            }
            else
            {
                productACV = new Map<Id, decimal>();
                ACV = 0;
                if(item.APTS_ACV__c != null)
                {
                    ACV = item.APTS_ACV__c;
                }

                productACV.put(item.Apttus_Proposal__Product__c, ACV);

                proposalssWithLineItemACV.put(item.Apttus_Proposal__Proposal__c, productACV);
            }
        }
        return proposalssWithLineItemACV;
    }*/

    //Written by Pranjal Mittal on 20 Dec 2016 for New Approval Changes
    //This method updates fields on Product Configuration in updated on Quote/Proposal
    private void updateFieldOnCart(map<id,Apttus_Proposal__Proposal__c> mapOfOldProp, map<id,Apttus_Proposal__Proposal__c> mapOfNewProp){

        List<Apttus_Config2__ProductConfiguration__c> listOfUpdatedCart = new List<Apttus_Config2__ProductConfiguration__c>();
        Boolean needToUpdate = false;
        for(Apttus_Proposal__Proposal__c p: [SELECT Id, Name, APTS_Billing_Frequency__c, Apttus_Proposal__Special_Terms__c,
                                                        APTS_Has_Custom_Terms__c, APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Current_Quote_TCV__c,
                                                        Apttus_Proposal__Payment_Term__c, APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c,
                                                        APTS_User_Manager__c, APTS_Record_Type_Name__c, Apttus_Proposal__ExpectedEndDate__c,
                                                        (SELECT Id, APTS_Payment_Term__c, APTS_Billing_Frequency__c, APTS_Has_Custom_Terms__c,
                                                                APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Current_Quote_TCV__c,Apttus_Config2__PriceListId__c,
                                                            APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c, APTS_User_Manager__c, APTS_Quote_Record_Type__c
                                                            FROM Apttus_QPConfig__Configurations__r
                                                            )
                from Apttus_Proposal__Proposal__c where Id IN: mapOfNewProp.keySet()]){
                needToUpdate = false;
                if(p.Apttus_QPConfig__Configurations__r.size() > 0)
                {
                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__Payment_Term__c != mapOfNewProp.get(p.Id).Apttus_Proposal__Payment_Term__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Payment_Term__c = mapOfNewProp.get(p.Id).Apttus_Proposal__Payment_Term__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Billing_Frequency__c != mapOfNewProp.get(p.Id).APTS_Billing_Frequency__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Billing_Frequency__c = mapOfNewProp.get(p.Id).APTS_Billing_Frequency__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__Special_Terms__c!= mapOfNewProp.get(p.Id).Apttus_Proposal__Special_Terms__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Has_Custom_Terms__c = true;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Current_Quote_MRR__c != mapOfNewProp.get(p.Id).APTS_Current_Quote_MRR__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Current_Quote_MRR__c = mapOfNewProp.get(p.Id).APTS_Current_Quote_MRR__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Original_Quote_MRR__c != mapOfNewProp.get(p.Id).APTS_Original_Quote_MRR__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Original_Quote_MRR__c = mapOfNewProp.get(p.Id).APTS_Original_Quote_MRR__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Current_Quote_TCV__c != mapOfNewProp.get(p.Id).APTS_Current_Quote_TCV__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Current_Quote_TCV__c = mapOfNewProp.get(p.Id).APTS_Current_Quote_TCV__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Original_Quote_TCV__c != mapOfNewProp.get(p.Id).APTS_Original_Quote_TCV__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Original_Quote_TCV__c = mapOfNewProp.get(p.Id).APTS_Original_Quote_TCV__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Enterprise_Account__c != mapOfNewProp.get(p.Id).APTS_Enterprise_Account__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Enterprise_Account__c = Boolean.valueOf(mapOfNewProp.get(p.Id).APTS_Enterprise_Account__c);
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_User_Manager__c != mapOfNewProp.get(p.Id).APTS_User_Manager__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_User_Manager__c = mapOfNewProp.get(p.Id).APTS_User_Manager__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).APTS_Record_Type_Name__c != mapOfNewProp.get(p.Id).APTS_Record_Type_Name__c){
                        p.Apttus_QPConfig__Configurations__r[0].APTS_Quote_Record_Type__c = mapOfNewProp.get(p.Id).APTS_Record_Type_Name__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__ExpectedStartDate__c != mapOfNewProp.get(p.Id).Apttus_Proposal__ExpectedStartDate__c){
                        p.Apttus_QPConfig__Configurations__r[0].Apttus_Config2__ExpectedStartDate__c = mapOfNewProp.get(p.Id).Apttus_Proposal__ExpectedStartDate__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).Apttus_Proposal__ExpectedEndDate__c != mapOfNewProp.get(p.Id).Apttus_Proposal__ExpectedEndDate__c){
                        p.Apttus_QPConfig__Configurations__r[0].Apttus_Config2__ExpectedEndDate__c = mapOfNewProp.get(p.Id).Apttus_Proposal__ExpectedEndDate__c;
                        needToUpdate = true;
                    }
                    if(mapOfOldProp.get(p.Id).Apttus_QPConfig__PriceListId__c != mapOfNewProp.get(p.Id).Apttus_QPConfig__PriceListId__c){
                        p.Apttus_QPConfig__Configurations__r[0].Apttus_Config2__PriceListId__c = mapOfNewProp.get(p.Id).Apttus_QPConfig__PriceListId__c;
                        needToUpdate = true;
                    }

                    if(needToUpdate)
                        listOfUpdatedCart.add(p.Apttus_QPConfig__Configurations__r[0]);
                }
            }


        if(listOfUpdatedCart.size()>0){
            update listOfUpdatedCart;
        }
    }

    public void updateOpportunityFields(Map<Id, Apttus_Proposal__Proposal__c> primaryProposalMap) {
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
        System.debug('>>>> updateOpportunityFields: ');
        for (Opportunity oppty : [SELECT Id, Primary_quote_updates__c, Proposed_Number_of_Users__c, Expected_Term_Months__c, APTS_Primary_Proposal_Lookup__c FROM Opportunity WHERE APTS_Primary_Proposal_Lookup__c IN :primaryProposalMap.keySet()]) {
            if (oppty.Proposed_Number_of_Users__c != primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).No_of_Users__c
                || oppty.Expected_Term_Months__c != primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).APTS_Subscription_Term__c) {
                opportunityList.add(new Opportunity(Id = oppty.Id, Primary_quote_updates__c = false));
                opportunityListToUpdate.add(new Opportunity(Id = oppty.Id, Primary_quote_updates__c = true, Proposed_Number_of_Users__c = (primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).No_of_Users__c != null ? primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).No_of_Users__c : 0), Expected_Term_Months__c = primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).APTS_Subscription_Term__c, DAS_Package__c = primaryProposalMap.get(oppty.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c));
            }
        }

        try {
            update opportunityList;
            System.debug('>>>> updateOpportunityFields: ' + JSON.serialize(opportunityListToUpdate));
            update opportunityListToUpdate;
        } catch(Exception ex) {
            System.debug('>>> Error:' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    
        private void updateEffectiveStartAndEndDates(List<Apttus_Proposal__Proposal__c> finalizedProposals) {
            Map<Id, Date> mapProposalStartDate = new Map<Id, Date>();
            Map<Id, Date> mapProposalEndDate = new Map<Id, Date>();
            for (AggregateResult proposalLineItem : [SELECT Apttus_Proposal__Proposal__c, MIN(Apttus_QPConfig__StartDate__c) startDate, MAX(Apttus_QPConfig__EndDate__c) endDate
                                                        FROM Apttus_Proposal__Proposal_Line_Item__c
                                                     WHERE Apttus_Proposal__Proposal__c IN :finalizedProposals
                                                      GROUP BY Apttus_Proposal__Proposal__c]) {
                System.debug('>>>> proposalLineItem: ' + JSON.serialize(proposalLineItem));
                Date startDate = (Date)proposalLineItem.get('startDate');
                Date endDate = (Date)proposalLineItem.get('endDate');
                if (startDate != null && endDate != null) {
                    mapProposalStartDate.put((Id)proposalLineItem.get('Apttus_Proposal__Proposal__c'), startDate);
                    mapProposalEndDate.put((Id)proposalLineItem.get('Apttus_Proposal__Proposal__c'), endDate);
                }
            }

            System.debug('>>>>> mapProposalStartDate: ' + JSON.serialize(mapProposalStartDate));
            if (!mapProposalStartDate.isEmpty() && !mapProposalEndDate.isEmpty()) {
                for (Apttus_Proposal__Proposal__c proposal : finalizedProposals) {
                    if (mapProposalStartDate.containsKey(proposal.Id) && mapProposalEndDate.containsKey(proposal.Id)) {
                        proposal.Apttus_Proposal__ExpectedStartDate__c = mapProposalStartDate.get(proposal.Id);
                        proposal.Apttus_Proposal__ExpectedEndDate__c = mapProposalEndDate.get(proposal.Id);
                        proposal.Allow_Subscription_Term_Change__c = !proposal.Allow_Subscription_Term_Change__c;
                    }
                }

                List<Apttus_Config2__ProductConfiguration__c> lstConfigsToUpdate = new List<Apttus_Config2__ProductConfiguration__c>();
                for (Apttus_Config2__ProductConfiguration__c configuration : [SELECT Id, Apttus_QPConfig__Proposald__c, Apttus_Config2__ExpectedStartDate__c, Apttus_Config2__ExpectedEndDate__c
                                                                                FROM Apttus_Config2__ProductConfiguration__c
                                                                               WHERE Apttus_QPConfig__Proposald__c IN :mapProposalStartDate.keySet()]) {
                    lstConfigsToUpdate.add(new Apttus_Config2__ProductConfiguration__c(
                                                Id = configuration.Id,
                                                Apttus_Config2__ExpectedStartDate__c = mapProposalStartDate.get(configuration.Apttus_QPConfig__Proposald__c),
                                                Apttus_Config2__ExpectedEndDate__c = mapProposalEndDate.get(configuration.Apttus_QPConfig__Proposald__c)
                                        ));
                }

                try {
                    update lstConfigsToUpdate;
                } catch(Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }

        // @future
        // private static void updateQuoteStartAndEndDatesInLineItems(String proposalIdsJSON) {
        //     List<Id> proposalIds = (List<Id>)JSON.deserialize(proposalIdsJSON, Type.forName('List<Id>'));
        //     List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLineItems = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        //
        //     for (Apttus_Proposal__Proposal_Line_Item__c pli : [SELECT Id, Apttus_Proposal__Proposal__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__ExpectedStartDate__c, Apttus_Proposal__Proposal__r.Allow_Subscription_Term_Change__c,
        //                                                               Apttus_Proposal__Proposal__r.Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__Proposal__r.APTS_Platform_End_Date__c, Quote_Start_Date__c, Quote_End_Date__c
        //                                                          FROM Apttus_Proposal__Proposal_Line_Item__c
        //                                                         WHERE Apttus_Proposal__Proposal__c IN :proposalIds]) {
        //         lstProposalLineItems.add(new Apttus_Proposal__Proposal_Line_Item__c(
        //                                     Id = pli.Id,
        //                                     Quote_Start_Date__c = pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__ExpectedStartDate__c,
        //                                     Quote_End_Date__c = pli.Apttus_Proposal__Proposal__r.APTS_Platform_End_Date__c
        //                                 ));
        //     }
        //
        //     System.debug('## lstProposalLineItems: ' + lstProposalLineItems);
        //     try {
        //         update lstProposalLineItems;
        //     } catch (Exception ex) {
        //         System.debug('## Exception occurred while updating quote start and end dates in Proposal LI: ' + ex.getMessage() + ' \n' + ex.getStackTraceString());
        //     }
        // }
        
        public void updateliketolikewithAssetlinesfield(list<Apttus_Proposal__Proposal__c> lstprop){
            Set<String> CreditSKUs = new Set<String>();
            CreditSKUs.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Credit_SKUs').SKU_Codes__c.split(';'));
            Map<Id, Map<String, Decimal>> mapaccountIdtoProposallineitemdetails = new Map<Id, Map<String, Decimal>>();
            Map<Id, Map<String, Decimal>> mapaccountIdtoAssetlineitemQty = new Map<Id, Map<String, Decimal>>();
            Map<Id, Decimal> mapaccountIdtoZsuiteAssetQty = new Map<Id,Decimal>();
            Map<Id, Decimal> mapaccountIdtoZsuiteBundlePLIQty = new Map<Id, Decimal>();
            Map<Id, Set<String>> mapaccIdtomatchingzsuite = new Map<Id,Set<String>>();
            Map<Id, Set<String>> mapaccIdtomatchingzsuiteforremoval = new Map<Id,Set<String>>();
            Map<Id, Map<String, Date>> mapaccountIdtoAssetlineitemdate = new Map<Id, Map<String, Date>>();
            Map<Id, Apttus_Proposal__Proposal__c> mapAccountIdtoProposal = new Map<Id, Apttus_Proposal__Proposal__c>();
            Map<Id, Boolean> mapAccountIdtoadditionalPropLines = new Map<Id, Boolean>();
            Set<Id> propIdSet = new Set<Id>();
            map<Id, Set<String>> LineItemSKUs = new Map<Id, Set<String>>();
            map<Id, Set<String>> LineItemSKUsforQty = new Map<Id, Set<String>>();
            Map<String, Like_to_Like_Asset_Mapping_for_ZSUITE__c> mapliketolikeassetmap = Like_to_Like_Asset_Mapping_for_ZSUITE__c.getAll();
            for(Apttus_Proposal__Proposal__c prop: lstprop){
                propIdSet.add(prop.Id);
                system.debug('+++'+prop.Line_Item_SKU__c);
                mapAccountIdtoProposal.put(prop.Apttus_Proposal__Account__c, prop);
                
                
            }
            
            List<Apttus_Proposal__Proposal_Line_Item__c> plilst = [Select Id,Apttus_QPConfig__AssetLineItemId__c, APTS_Ramp_End_Date__c, Apttus_QPConfig__LineStatus__c, Apttus_QPConfig__IsPrimaryLine__c, APTS_Selling_Term__c, ZPA_List_Price_Premium_Support__c, GSA_Price_Per_Unit__c, Apttus_Proposal__Product__c, Proposal_SKU__c, APTS_Quantity__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_Total_Discount_Percentage__c, Apttus_Proposal__Product__r.Zscaler_Product_Family__c, Apttus_Proposal__Product__r.ProductCode, Apttus_Proposal__Product__r.Price_Type__c, Apttus_Proposal__Proposal__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.Sales_Territory__r.Area_VP__c, Apttus_Proposal__Product__r.Name, APTS_Base_Price_override__c, APTS_Net_Price__c, Apttus_QPConfig__IsPrimaryRampLine__c, APTS_Total_Ramp_Quantity__c, Apttus_QPConfig__SellingTerm__c, Apttus_QPConfig__BaseExtendedPrice__c, Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c in :propIdSet];
            //CR# 223 - Abhishek V - Early_Adopter - Start
            if(!plilst.isEmpty()){
                Map<Id, String> mapProptoAVP = new Map<Id, String>();
                for(Apttus_Proposal__Proposal_Line_Item__c pli: plilst){

                    if(pli.Apttus_Proposal__Proposal__c != null && !mapProptoAVP.containsKey(pli.Apttus_Proposal__Proposal__c)){
                        mapProptoAVP.put(pli.Apttus_Proposal__Proposal__c, pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__r.Sales_Territory__r.Area_VP__c);
                    }
                }
                updateAVPonFinalization(mapProptoAVP, lstprop);
            }
            //CR# 223 - Abhishek V - Early_Adopter - End
            Map<Id, Set<String>> mapaccIdtoPLISKUCodes = new Map<Id, Set<String>>();
            for(Apttus_Proposal__Proposal_Line_Item__c pli: plilst){
                
                 
                if(!mapaccIdtoPLISKUCodes.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c)){
                    mapaccIdtoPLISKUCodes.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, new Set<String>{pli.Apttus_Proposal__Product__r.ProductCode});
                }else{
                    Set<String> propSKUset = mapaccIdtoPLISKUCodes.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c);
                    propSKUset.add(pli.Apttus_Proposal__Product__r.ProductCode);
                    mapaccIdtoPLISKUCodes.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,  propSKUset);
                }
            }
            
            Set<Id> checkedaccount = new Set<Id>();
            for(Apttus_Config2__AssetLineItem__c ali: [Select Id, Apttus_Config2__Quantity__c, Apttus_Config2__BaseExtendedPrice__c, Apttus_Config2__ProductId__c, Apttus_Config2__NetPrice__c, Apttus_Config2__ChargeType__c, Apttus_Config2__PriceType__c, Apttus_Config2__ProductId__r.name, Apttus_Config2__ProductId__r.ProductCode, Apttus_Config2__ProductId__r.Price_Type__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, APTS_Total_Ramp_Quantity__c, APTS_Ramp_End_Date__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__SellingTerm__c, Apttus_QPConfig__ProposalLineItemId__c, APTS_MRR__c, Apttus_Config2__ListPrice__c, APTS_Selling_Term__c,  Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, Exclude_From_Premium_Support_Calculation__c, Product_Code__c, Apttus_Config2__PriceListItemId__c, APTS_Total_Discount_Percentage__c, Apttus_Config2__AccountId__c, Apttus_Config2__AccountId__r.Asset_SKU_Codes__c, Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceType__c From Apttus_Config2__AssetLineItem__c Where Apttus_Config2__AccountId__c = :mapAccountIdtoProposal.keyset() AND Apttus_Config2__AssetStatus__c = 'Activated' ]){
                
                if(!checkedaccount.contains(ali.Apttus_Config2__AccountId__c)){
                    Set<String> assetskucodes = ali.Apttus_Config2__AccountId__r.Asset_SKU_Codes__c != null ? new Set<String>(ali.Apttus_Config2__AccountId__r.Asset_SKU_Codes__c.split(', ')) : new Set<String>();
                    system.debug('+++'+assetskucodes);
                    Like_to_Like_Asset_Mapping_for_ZSUITE__c matchedllam = new Like_to_Like_Asset_Mapping_for_ZSUITE__c();
                    Boolean containsallSKUs = false;
                    List<String> lstcstosort = new List<String>();
                    lstcstosort.addAll(mapliketolikeassetmap.keyset());
                    lstcstosort.sort();
                    Set<String> propcodes = mapaccIdtoPLISKUCodes.containsKey(ali.Apttus_Config2__AccountId__c) ? mapaccIdtoPLISKUCodes.get(ali.Apttus_Config2__AccountId__c) : new Set<String>();
                    Set<String> customsettingcodes;
                    Set<String> customsettingcodesforQty;
                    for(String s: lstcstosort){
                        matchedllam = mapliketolikeassetmap.get(s);
                        customsettingcodes = new Set<String>(matchedllam.Proposal_Line_Item_SKU_Codes__c.split(';'));
                        customsettingcodesforQty = new Set<String>(matchedllam.Proposal_Line_Item_Quantity_SKU_Codes__c.split(';'));
                        checkedaccount.add(ali.Apttus_Config2__AccountId__c);
                        Set<String> cssassetskus = new Set<String>(matchedllam.Asset_SKU_Codes__c.split(';'));
                        /*for(String s1: cssassetskus){
                            system.debug('+++'+s1);
                            system.debug('+++'+assetskucodes.contains(s1));
                            if(!assetskucodes.contains(s1)){
                                containsallSKUs = false;
                                break;
                            }else{
                                containsallSKUs = true;
                            }
                        }
                        system.debug('+++'+containsallSKUs);*/
                        if(assetskucodes.containsAll(cssassetskus)){
                            if(propcodes.containsAll(customsettingcodes)){
                                containsallSKUs = true;
                                break;
                            }
                        }
                    }
                    system.debug('+++'+containsallSKUs);
                    if(containsallSKUs){
                        Boolean containslines = false;
                        mapaccIdtomatchingzsuiteforremoval.put(ali.Apttus_Config2__AccountId__c, new Set<String>(matchedllam.Asset_SKU_Codes__c.split(';')));
                        mapaccIdtomatchingzsuite.put(ali.Apttus_Config2__AccountId__c, new Set<String>(matchedllam.Asset_SKU_Qty_codes__c.split(';')));
                        
                        /*for(String s: customsettingcodes){
                            if(!propcodes.contains(s)){
                                containslines = false;
                                break;
                            }else{
                                containslines = true;
                            }
                        }*/
                        if(propcodes.containsAll(customsettingcodes)){
                            LineItemSKUs.put(ali.Apttus_Config2__AccountId__c, customsettingcodes);
                            LineItemSKUsforQty.put(ali.Apttus_Config2__AccountId__c, customsettingcodesforQty);
                        }
                    }
                }
                
                if(mapaccIdtomatchingzsuite != null && mapaccIdtomatchingzsuite.containsKey(ali.Apttus_Config2__AccountId__c)){
                    if(mapaccIdtomatchingzsuite.get(ali.Apttus_Config2__AccountId__c) != null && mapaccIdtomatchingzsuite.get(ali.Apttus_Config2__AccountId__c).contains(ali.Apttus_Config2__ProductId__r.ProductCode)){
                        if(mapaccountIdtoZsuiteAssetQty != null && mapaccountIdtoZsuiteAssetQty.containsKey(ali.Apttus_Config2__AccountId__c) && mapaccountIdtoZsuiteAssetQty.get(ali.Apttus_Config2__AccountId__c) != null && ali.Apttus_Config2__Quantity__c != null){
                            mapaccountIdtoZsuiteAssetQty.put(ali.Apttus_Config2__AccountId__c,mapaccountIdtoZsuiteAssetQty.get(ali.Apttus_Config2__AccountId__c) + ali.Apttus_Config2__Quantity__c);
                        }else if(ali.Apttus_Config2__Quantity__c != null){
                            mapaccountIdtoZsuiteAssetQty.put(ali.Apttus_Config2__AccountId__c, ali.Apttus_Config2__Quantity__c);
                        }
                    }
                }
                
                
                if(mapaccountIdtoAssetlineitemQty.containsKey(ali.Apttus_Config2__AccountId__c)){
                    Map<String, Decimal> mapskutoqty =  mapaccountIdtoAssetlineitemQty.get(ali.Apttus_Config2__AccountId__c);
                    Map<String, Date> mapskutodate =  mapaccountIdtoAssetlineitemdate.get(ali.Apttus_Config2__AccountId__c);
                    if(ali.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && !CreditSKUs.contains(ali.Apttus_Config2__ProductId__r.ProductCode)){
                        if(!mapskutoqty.containsKey(ali.Apttus_Config2__ProductId__r.ProductCode) || mapskutodate.get(ali.Apttus_Config2__ProductId__r.ProductCode) < ali.Apttus_Config2__EndDate__c){
                            mapskutoqty.put(ali.Apttus_Config2__ProductId__r.ProductCode, ali.Apttus_Config2__Quantity__c);
                            mapskutodate.put(ali.Apttus_Config2__ProductId__r.ProductCode, ali.Apttus_Config2__EndDate__c);
                        }else if(mapskutodate.get(ali.Apttus_Config2__ProductId__r.ProductCode) == ali.Apttus_Config2__EndDate__c && ali.Apttus_Config2__Quantity__c != null && mapskutoqty.get(ali.Apttus_Config2__ProductId__r.ProductCode) != null){
                            mapskutoqty.put(ali.Apttus_Config2__ProductId__r.ProductCode, mapskutoqty.get(ali.Apttus_Config2__ProductId__r.ProductCode) + ali.Apttus_Config2__Quantity__c);
                        }
                    }
                    mapaccountIdtoAssetlineitemQty.put(ali.Apttus_Config2__AccountId__c, mapskutoqty);
                    mapaccountIdtoAssetlineitemdate.put(ali.Apttus_Config2__AccountId__c, mapskutodate);
                }else if(ali.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && !CreditSKUs.contains(ali.Apttus_Config2__ProductId__r.ProductCode)){
                    mapaccountIdtoAssetlineitemQty.put(ali.Apttus_Config2__AccountId__c, new Map<String, Decimal>{ali.Apttus_Config2__ProductId__r.ProductCode => ali.Apttus_Config2__Quantity__c});
                    mapaccountIdtoAssetlineitemdate.put(ali.Apttus_Config2__AccountId__c, new Map<String, Date>{ali.Apttus_Config2__ProductId__r.ProductCode => ali.Apttus_Config2__EndDate__c});
                }
            }
            system.debug('++++'+mapaccountIdtoAssetlineitemQty);
            system.debug('++++'+mapaccountIdtoZsuiteAssetQty);
            system.debug('++++'+LineItemSKUs);
            system.debug('++++'+LineItemSKUsforQty);
            system.debug('++++'+mapaccIdtomatchingzsuite);
            
            
            for(Apttus_Proposal__Proposal_Line_Item__c pli: plilst){
                if(LineItemSKUsforQty != null && LineItemSKUsforQty.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) && LineItemSKUsforQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) != null && LineItemSKUsforQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c).contains(pli.Apttus_Proposal__Product__r.ProductCode)){
                    if(mapaccountIdtoZsuiteBundlePLIQty != null && mapaccountIdtoZsuiteBundlePLIQty.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) && mapaccountIdtoZsuiteBundlePLIQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) != null && pli.APTS_Quantity__c != null){
                        mapaccountIdtoZsuiteBundlePLIQty.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c,mapaccountIdtoZsuiteBundlePLIQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) + pli.APTS_Quantity__c);
                    }else if(pli.APTS_Quantity__c != null){
                        mapaccountIdtoZsuiteBundlePLIQty.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, pli.APTS_Quantity__c);
                    }
                }
                
            }
                            
            for(Apttus_Proposal__Proposal_Line_Item__c pli: plilst){
                Map<String, Decimal> mapassetskutoqty = mapaccountIdtoAssetlineitemQty.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) ? mapaccountIdtoAssetlineitemQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) : new Map<String, Decimal>();
                if(pli.Apttus_QPConfig__PriceListItemId__r.Apttus_Config2__PriceType__c != 'One Time' && !CreditSKUs.contains(pli.Apttus_Proposal__Product__r.ProductCode) && !mapAccountIdtoadditionalPropLines.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c)){
                    if(mapassetskutoqty.containsKey(pli.Apttus_Proposal__Product__r.ProductCode) && mapassetskutoqty.get(pli.Apttus_Proposal__Product__r.ProductCode) == pli.APTS_Quantity__c){
                        mapassetskutoqty.remove(pli.Apttus_Proposal__Product__r.ProductCode);
                    }else if(mapaccountIdtoZsuiteBundlePLIQty.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) && mapaccountIdtoZsuiteAssetQty.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) && mapaccountIdtoZsuiteBundlePLIQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) == mapaccountIdtoZsuiteAssetQty.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c)){
                        for(String s: mapaccIdtomatchingzsuiteforremoval.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c)){
                            mapassetskutoqty.remove(s);
                        }
                    }else if(!mapassetskutoqty.containsKey(pli.Apttus_Proposal__Product__r.ProductCode) && LineItemSKUs != null && LineItemSKUs.containsKey(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) && LineItemSKUs.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c) != null && !LineItemSKUs.get(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c).contains(pli.Apttus_Proposal__Product__r.ProductCode)){
                        mapAccountIdtoadditionalPropLines.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, true);
                    }
                }
                mapaccountIdtoAssetlineitemQty.put(pli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Account__c, mapassetskutoqty);
            }
            system.debug('+++'+mapaccountIdtoAssetlineitemQty);
            system.debug('+++'+mapAccountIdtoadditionalPropLines);
            
            for(Id accId: mapAccountIdtoProposal.keyset()){
                Boolean ismapassetforaccounthasnoSKUs = false;
                Map<String, Decimal> mapassetskutoqty;
                if(mapaccountIdtoAssetlineitemQty.containsKey(accId)){
                    mapassetskutoqty = mapaccountIdtoAssetlineitemQty.get(accId);
                }else{
                    ismapassetforaccounthasnoSKUs = true;
                }
                    
                if(!mapAccountIdtoadditionalPropLines.containsKey(accId) && !ismapassetforaccounthasnoSKUs && mapassetskutoqty.isEmpty()){
                    mapAccountIdtoProposal.get(accId).Is_Like_to_Like_Match_with_Asset__c = true;
                }else{
                    mapAccountIdtoProposal.get(accId).Is_Like_to_Like_Match_with_Asset__c = false;
                }
            }
            
        }
        
        public void invokePartnerMarginCalculation(List<Apttus_Proposal__Proposal__c> proplst)
        {
            if(!proplst.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isQueueable() && !test.isRunningTest()){
                system.enqueuejob(new InvokePartnerMarginCalc(proplst[0].Id, proplst[0].Apttus_Proposal__Opportunity__C));
            }
        }

        public void invokesalesordercalculation(List<Apttus_Proposal__Proposal__c> proplst){
            if(!proplst.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isQueueable() && !test.isRunningTest()){
                system.enqueuejob(new InvokeSalesOrderCalc(proplst[0].Id, proplst[0].Apttus_Proposal__Opportunity__C));
            }
        }
        
        //CR# 223 - Abhishek V - Early_Adopter - Start
        public void updateAVPonFinalization(Map<Id, String> mapquotetoAVP, List<Apttus_Proposal__Proposal__c> proplst){
            for(Apttus_Proposal__Proposal__c prop: proplst){
                if(mapquotetoAVP != null && !mapquotetoAVP.isEmpty() && mapquotetoAVP.containsKey(prop.Id)){
                    prop.Area_VP__c = mapquotetoAVP.get(prop.Id);
                }
            }
        }
        //CR# 223 - Abhishek V - Early_Adopter - End
        
        //CR# 305 - Parth Doshi - Legal language for Word Document - Start
        public void invokeLegalLanguageExecution(List<Apttus_Proposal__Proposal__c> proplst){
            if(!proplst.isEmpty() && !system.isFuture() && !system.isBatch() && !system.isQueueable() && !test.isRunningTest()){
                system.enqueuejob(new InvokeLegalLanguageLogic(proplst[0].Id));
            }
        }
        //CR# 305 - Parth Doshi - Legal language for Word Document - End
        
        public void booster(){
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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