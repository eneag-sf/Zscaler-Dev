public class APTS_ProposalApprovalControllerProdConf {
    
    Public ID proposalID{get; set;}    
    Public ID prodConfigID{get; set;}
    //Public String InstanceURL{get; set;}
    Private List<string> ListOfReasons;
    Private Apttus_Proposal__Proposal__c proposalSO;
    Private Apttus_Config2__ProductConfiguration__c prodConfigSO;
    Private List<Apttus_Config2__LineItem__c> ListOfLineItems;
    Private Boolean  boolListOfReasons;
    Private Boolean  boolproposalSO;
    Private Boolean  boolprodConfigSO;
    Private Boolean  boolListOfLineItems;
    
    Public APTS_ProposalApprovalControllerProdConf (){
        ListOfReasons = new List<string>();
        proposalSO = new Apttus_Proposal__Proposal__c();
        prodConfigSO = new Apttus_Config2__ProductConfiguration__c();
        ListOfLineItems = new List<Apttus_Config2__LineItem__c>();
        boolListOfReasons = false;
        boolproposalSO = false;
        boolprodConfigSO = false;
        boolListOfLineItems = false;
    }
    
    Public List<string> getListOfReasons(){
        if(boolListOfReasons)
            return ListOfReasons;
        boolean PaymentTerm = True;
        boolean BillingFrequency = True;
        boolean Discount = True;
        boolean SupportDiscount = True;
        boolean CustomTerms = True;
        boolean RampSchedule = True;
        boolean Term_3Years = True;
        boolean SubscriptionUplift = True;
        boolean CoTerm = True;
        boolean DecreaseinRenewalMRR = True;
        boolean DecreaseinRenewalTCV = True;
        boolean DASSeatsMismatchCustomerSuccess = True;
        boolean BuyBackCreditDealDesk = True;
        boolean NFRDealDesk = True;
        boolean OnsiteTAMCustomerSuccess = True;
        boolean ZscalerExtendTransactionLogProductManagement = True; 
        
        for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                                                         Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                                         Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                                         Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c
                                                         from Apttus_Approval__Approval_Request__c
                                                         Where Apttus_CQApprov__CartId__c =: prodConfigID])
        {
            if(appr.Apttus_Approval__Step_Name__c.contains('Support Discount') && SupportDiscount ){
                ListOfReasons.add('Support Discount');
                SupportDiscount = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Discount') && Discount ){
                ListOfReasons.add('Discount');
                Discount = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Payment Term') && PaymentTerm ){
                ListOfReasons.add('Payment Term');
                PaymentTerm = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Billing Frequency') && BillingFrequency ){
                ListOfReasons.add('Billing Frequency');
                BillingFrequency = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms') && CustomTerms ){
                ListOfReasons.add('Custom Terms');
                CustomTerms = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Ramp Schedule') && RampSchedule ){
                ListOfReasons.add('Ramp Schedule');
                RampSchedule = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Term < 3 Years') && Term_3Years ){
                ListOfReasons.add('Term < 3 Years');
                Term_3Years  = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Subscription Uplift ') && SubscriptionUplift ){
                ListOfReasons.add('Subscription Uplift ');
                SubscriptionUplift = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Co-Term') && CoTerm ){
                ListOfReasons.add('Co-Term');
                CoTerm = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal MRR') && DecreaseinRenewalMRR ){
                ListOfReasons.add('Decrease in Renewal MRR');
                DecreaseinRenewalMRR = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal TCV') && DecreaseinRenewalTCV ){
                ListOfReasons.add('Decrease in Renewal TCV');
                DecreaseinRenewalTCV = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('DAS Seats Mismatch - Customer Success') && DASSeatsMismatchCustomerSuccess ){
                ListOfReasons.add('DAS Seats Mismatch - Customer Success');
                DASSeatsMismatchCustomerSuccess = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Buy Back Credit - Deal Desk') && BuyBackCreditDealDesk ){
                ListOfReasons.add('Buy Back Credit - Deal Desk');
                BuyBackCreditDealDesk = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('NFR - Deal Desk') && NFRDealDesk ){
                ListOfReasons.add('NFR - Deal Desk');
                NFRDealDesk = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Onsite TAM - Customer Success') && OnsiteTAMCustomerSuccess ){
                ListOfReasons.add('Onsite TAM - Customer Success');
                OnsiteTAMCustomerSuccess = false;
            }else if(appr.Apttus_Approval__Step_Name__c.contains('Zscaler Extend Transaction Log - Product Management') && ZscalerExtendTransactionLogProductManagement ){
                ListOfReasons.add('Zscaler Extend Transaction Log - Product Management');
                ZscalerExtendTransactionLogProductManagement = false;
            }            
        }
        boolListOfReasons = true;
        return ListOfReasons;
    }
    
    Public Apttus_Proposal__Proposal__c getproposalSO(){
        if(boolproposalSO)
            return proposalSO;
        List<Apttus_Proposal__Proposal__c> proposals  = [SELECT Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Name,
                                                         Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c,
                                                         Apttus_Proposal__Payment_Term__c, APTS_Billing_Frequency__c, APTS_Record_Type_Name__c,
                                                         Apttus_Proposal__Opportunity__r.Name, APTS_Subscription_Term__c, APTS_Proposal_Net_Price__c,
                                                         APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Approval_Reason__c, No_of_Users__c,
                                                         Apttus_Proposal__Special_Terms__c, Apttus_QPConfig__BillToAccountId__r.Name, APTS_ACV__c,
                                                         Apttus_Proposal__Opportunity__r.VMO_Play__c
                                                         FROM Apttus_Proposal__Proposal__c 
                                                         WHERE Id =: proposalID]; 
        boolproposalSO = true;
        if(proposals.size() > 0) 
            proposalSO = proposals[0];
        return proposalSO;
    }
    
    Public Apttus_Config2__ProductConfiguration__c getprodConfigSO(){
        if(boolprodConfigSO)
            return prodConfigSO;
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE ID = :prodConfigID];
        boolprodConfigSO = true;
        if(prodConfigs.size() > 0) 
            prodConfigSO = prodConfigs[0];
        return prodConfigSO;
    }
        
    Public List<Apttus_Config2__LineItem__c> getListOfLineItems(){
        if(boolListOfLineItems)
            return ListOfLineItems;
        
        ListOfLineItems = [Select Id, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c, Apttus_Config2__StartDate__c, 
                             Apttus_Config2__EndDate__c, Apttus_Config2__PaymentTermId__c, Apttus_Config2__PaymentTermId__r.Name, Apttus_Config2__Guidance__c, APTS_Partner_Disc__c, 
                             APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c, APTS_Manual_Discount__c, Apttus_Config2__AdjustmentType__c, APTS_Total_Discount_Percentage__c, 
                             Apttus_Config2__NetPrice__c, APTS_MRR__c, APTS_Prev_MRR__c, APTS_Manual_Discount_Approvals__c, APTS_Selling_Term__c, APTS_Total_Partner_Discount__c
                             from Apttus_Config2__LineItem__c
                             Where Apttus_Config2__ConfigurationId__c =: prodConfigID];
        boolListOfLineItems = true;
        return ListOfLineItems ;
              
    }
    
}