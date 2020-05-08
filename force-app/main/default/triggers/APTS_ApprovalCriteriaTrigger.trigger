/*************************************************************
@Name: APTS_ApprovalCriteriaTrigger
@Author:  Jigar Naik
@CreateDate: 03 Nov 2016
@Description: Trigger to update line item fields which drive approval process.
Modification Log:
###########################################################################################
Harish Emmadi, APTTUS - 11/30/2016, updated the APTS_No_Co_Term__c to fix ZSCAL-112
Harish Emmadi, APTTUS - 12/27/2016, updated the Apttus_Proposal__Proposal__c query in before trigger.
###########################################################################################
******************************************************************/
trigger APTS_ApprovalCriteriaTrigger  on Apttus_Config2__ProductConfiguration__c (before update, before insert, after Update) {
    
    
    
    public static boolean runOnce = true;
    if(Trigger.isBefore && Trigger.isUpdate)
    {
      
        for(Integer index = 0; index < Trigger.new.size(); index++) {
            Apttus_Config2__ProductConfiguration__c config = Trigger.new[index];
            
            if(config.Apttus_Config2__Status__c != Trigger.Old[index].Apttus_Config2__Status__c && config.Apttus_Config2__Status__c == 'Finalized'){
                Apttus_Proposal__Proposal__c proposal = [Select Id, Name, Apttus_Proposal__ExpectedStartDate__c, 
                                                            APTS_Billing_Frequency__c, APTS_Has_Custom_Terms__c, 
                                                            APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, 
                                                            APTS_Current_Quote_TCV__c, Apttus_Proposal__Payment_Term__c,
                                                            APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c,  
                                                            APTS_User_Manager__c, APTS_Record_Type_Name__c, Apttus_Proposal__ExpectedEndDate__c
                                                                From Apttus_Proposal__Proposal__c 
                                                                    Where Id = :config.Apttus_QPConfig__Proposald__c];
                
              
               // SAVEDCOMMENTED 
                //config.Apttus_Config2__Status__c = 'Saved';               
                config.APTS_Payment_Term__c = proposal.Apttus_Proposal__Payment_Term__c;
                config.APTS_Billing_Frequency__c = proposal.APTS_Billing_Frequency__c;
                //config.APTS_Has_Custom_Terms__c = Boolean.valueOf(proposal.APTS_Has_Custom_Terms__c);
                config.APTS_Current_Quote_MRR__c = proposal.APTS_Current_Quote_MRR__c;
                config.APTS_Original_Quote_MRR__c = proposal.APTS_Original_Quote_MRR__c;
                config.APTS_Current_Quote_TCV__c = proposal.APTS_Current_Quote_TCV__c;
                config.APTS_Original_Quote_TCV__c = proposal.APTS_Original_Quote_TCV__c;
                config.APTS_Enterprise_Account__c = Boolean.valueOf(proposal.APTS_Enterprise_Account__c);
                config.APTS_User_Manager__c = proposal.APTS_User_Manager__c;
                config.APTS_Quote_Record_Type__c = proposal.APTS_Record_Type_Name__c;
                
                
            }
        }
    }
    
     if(Trigger.isAfter && Trigger.isUpdate)
     {
         
         for(Integer index = 0; index < Trigger.new.size(); index++) {
            Apttus_Config2__ProductConfiguration__c config = Trigger.new[index];
            Apttus_Config2__ProductConfiguration__c config2 = Trigger.old[index];
            // SAVEDCOMMENTED
            //if(config.Apttus_Config2__Status__c == 'Saved' && config.Apttus_Config2__FinalizedDate__c!= config2.Apttus_Config2__FinalizedDate__c){
            if( config.Apttus_Config2__FinalizedDate__c!= config2.Apttus_Config2__FinalizedDate__c){
            
                Apttus_Proposal__Proposal__c proposal = [Select Id, Name, Apttus_Proposal__ExpectedStartDate__c, 
                                                            APTS_Platform_End_Date__c,
                                                            APTS_Billing_Frequency__c, APTS_Has_Custom_Terms__c, 
                                                            APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, 
                                                            APTS_Current_Quote_TCV__c, Apttus_Proposal__Payment_Term__c,
                                                            APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c,  
                                                            APTS_User_Manager__c, APTS_Record_Type_Name__c, Apttus_Proposal__ExpectedEndDate__c
                                                                From Apttus_Proposal__Proposal__c 
                                                                    Where Id = :config.Apttus_QPConfig__Proposald__c];
                
                List<Apttus_Config2__LineItem__c> lineItemList = [select Id, Name, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__IsPrimaryLine__c, 
                APTS_Product_Code__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, APTS_Ramp_End_Date__c, Apttus_Config2__Quantity__c, APTS_Total_Ramp_Quantity__c,
                Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__ProductId__r.Zscaler_Product_Family__c from
                Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c =: config.Id And
                Apttus_Config2__ChargeType__c = 'Subscription Fee' and APTS_Product_Code__c != 'ZCR-UPY4' and APTS_Product_Code__c != 'ZCR-UPY5'  ORDER BY  Apttus_Config2__LineNumber__c,
                Apttus_Config2__ItemSequence__c];
                
                
                
                if(!lineItemList.isEmpty()){
                    DateTime startDateForCoTerm, endDateForCoTerm, startDateForCoTermZPA, endDateForCoTermZPA, dateForCoTermZIA, dateForCoTermZPA;
                    for (Apttus_Config2__LineItem__c li : lineItemList) {
                        if ((startDateForCoTerm == null
                            || startDateForCoTerm > li.Apttus_Config2__StartDate__c) && li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZIA') {
                            startDateForCoTerm = li.Apttus_Config2__StartDate__c;
                        }
                        
                        if ((startDateForCoTermZPA == null
                            || startDateForCoTermZPA > li.Apttus_Config2__StartDate__c) && li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZPA') {
                            startDateForCoTermZPA = li.Apttus_Config2__StartDate__c;
                        }

                        if ((endDateForCoTerm == null
                            || endDateForCoTerm < li.Apttus_Config2__EndDate__c) && li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZIA') {
                            endDateForCoTerm = li.Apttus_Config2__EndDate__c;
                        }
                        
                        if ((endDateForCoTermZPA == null
                            || endDateForCoTermZPA < li.Apttus_Config2__EndDate__c) && li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZPA') {
                            endDateForCoTermZPA = li.Apttus_Config2__EndDate__c;
                        }
                    }

                    if(config.APTS_Platform_Subscription_End_Date__c != null
                        && config.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL)
                    {
                        dateForCoTermZIA = config.APTS_Platform_Subscription_End_Date__c;
                    }
                    
                    if(config.APTS_Platform_Subscription_End_Date__c != null
                        && config.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL)
                    {
                        dateForCoTermZPA = config.Platform_Subscription_End_Date_ZPA__c;
                    }
                    Map<Id, Apttus_Config2__LineItem__c> lineItemValidationMap = new Map<Id, Apttus_Config2__LineItem__c>();
                    Map<Id, Apttus_Config2__LineItem__c> primaryLineItemValidationMap = new Map<Id, Apttus_Config2__LineItem__c>();
                    List<Apttus_Config2__LineItem__c> lineItemListToUpdate = new List<Apttus_Config2__LineItem__c>();
                    
                    //Creating 2 Separate list for processing Co Term and Ramp Over 6 months
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
                    
                    /*DateTime  dateForCoTerm;
                    if(config.APTS_Platform_Subscription_End_Date__c != null)
                    {
                        dateForCoTerm = config.APTS_Platform_Subscription_End_Date__c;
                    }
                    else
                    {
                        dateForCoTerm = proposal.Apttus_Proposal__ExpectedEndDate__c;
                    }*/
                    
                    
                    
                    // Update: HE, 11/30/2016 - (ZSCAL-112) reset the APTS_No_Co_Term__c to false prior to re-calculation to fix the inconsitency of the flag
                    // No Co-Term flag is not getting reset based on Quote header dates after the configuration re-finalization.
                    for(Id productId : primaryLineItemValidationMap.keySet()){
                        Apttus_Config2__LineItem__c primaryLineItem = primaryLineItemValidationMap.get(productId);
                        Apttus_Config2__LineItem__c lineItemToCompare = lineItemValidationMap.get(productId);
                        
                       
                        Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(Id = primaryLineItem.Id, APTS_No_Co_Term__c = false, No_Co_Term_ZPA__c = false);
                        if(primaryLineItem.Id == lineItemToCompare.Id && primaryLineItem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZIA' && ((dateForCoTermZIA != null && dateForCoTermZIA != primaryLineItem.APTS_Ramp_End_Date__c
                                && config.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL )
                            || (startDateForCoTerm != primaryLineItem.Apttus_Config2__StartDate__c
                                || endDateForCoTerm != primaryLineItem.APTS_Ramp_End_Date__c))){                           
                           
                            lineItemSO.APTS_No_Co_Term__c = true;
                        }else if(primaryLineItem.Id == lineItemToCompare.Id && primaryLineItem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == 'ZPA' && ((dateForCoTermZPA != null && dateForCoTermZPA != primaryLineItem.APTS_Ramp_End_Date__c
                                && config.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL )
                            || (startDateForCoTermZPA != primaryLineItem.Apttus_Config2__StartDate__c
                                || endDateForCoTermZPA != primaryLineItem.APTS_Ramp_End_Date__c))){          
                            lineItemSO.No_Co_Term_ZPA__c = true;
                        }
                        else if(primaryLineItem.Id != lineItemToCompare.Id){
                            
                            Boolean noCoTerm = false;
                            Boolean rampOver6Months = false;
                            //Commented this out to not consider the ramp lines for no co-term check.
                            //if((config.APTS_Record_Type__c == APTS_CONSTANTS.P_RT_UPSELL
                            //    && dateForCoTerm != lineItemToCompare.APTS_Ramp_End_Date__c)
                            //    || (startDateForCoTerm != lineItemToCompare.Apttus_Config2__StartDate__c
                            //        || endDateForCoTerm != lineItemToCompare.APTS_Ramp_End_Date__c)){
                            //    noCoTerm = true;
                            //}
                            
                            if(primaryLineItem.Apttus_Config2__StartDate__c.monthsBetween(lineItemToCompare.Apttus_Config2__StartDate__c) > 6){
                                rampOver6Months = true;
                            }
                            
                            if(noCoTerm || rampOver6Months){
                                lineItemSO.APTS_No_Co_Term__c = noCoTerm;
                                lineItemSO.APTS_Ramp_Over_6_Months__c = rampOver6Months;
                            }
                            
                            lineItemSO.APTS_Ramped_Months__c = primaryLineItem.Apttus_Config2__StartDate__c.monthsBetween(lineItemToCompare.Apttus_Config2__StartDate__c);
                        }
                        lineItemListToUpdate.add(lineItemSO);
                    }
                    
                    if(!lineItemListToUpdate.isEmpty()){
                        update lineItemListToUpdate;
                    }
                }
                
               
                
                
            }
        }
     }
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Integer index = 0; index < Trigger.new.size(); index++) {
            Apttus_Config2__ProductConfiguration__c config = Trigger.new[index];
            List<Apttus_Proposal__Proposal__c> proposalList = new  List<Apttus_Proposal__Proposal__c> ();
            proposalList= [Select Id, Name, Apttus_Proposal__ExpectedStartDate__c,        Apttus_Proposal__ExpectedEndDate__c, Apttus_QPConfig__ConfigurationFinalizedDate__c, Apttus_Proposal__Payment_Term__c,
                        APTS_Billing_Frequency__c, APTS_Has_Custom_Terms__c, APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c,
                        APTS_Current_Quote_TCV__c, APTS_Original_Quote_TCV__c, APTS_Enterprise_Account__c, APTS_User_Manager__c, 
                        APTS_Record_Type_Name__c From Apttus_Proposal__Proposal__c Where Id = :config.Apttus_QPConfig__Proposald__c];
                        
            if(proposalList.size() > 0) {            
                config.APTS_Payment_Term__c = proposalList[0].Apttus_Proposal__Payment_Term__c;
                config.APTS_Billing_Frequency__c = proposalList[0].APTS_Billing_Frequency__c;
                config.APTS_Has_Custom_Terms__c = Boolean.valueOf(proposalList[0].APTS_Has_Custom_Terms__c);
                config.APTS_Current_Quote_MRR__c = proposalList[0].APTS_Current_Quote_MRR__c;
                config.APTS_Original_Quote_MRR__c = proposalList[0].APTS_Original_Quote_MRR__c;
                config.APTS_Current_Quote_TCV__c = proposalList[0].APTS_Current_Quote_TCV__c;
                config.APTS_Original_Quote_TCV__c = proposalList[0].APTS_Original_Quote_TCV__c;
                config.APTS_Enterprise_Account__c = Boolean.valueOf(proposalList[0].APTS_Enterprise_Account__c);
                config.APTS_User_Manager__c = proposalList[0].APTS_User_Manager__c;
                config.APTS_Quote_Record_Type__c = proposalList[0].APTS_Record_Type_Name__c;        
            }    
           
        }
    }
    
   
}