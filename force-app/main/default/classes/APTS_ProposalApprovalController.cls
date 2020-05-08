global class APTS_ProposalApprovalController{

    Public String ProposalId{get; set;}    
    Public String InstanceURL{get; set;}
    Public ID ApprovalRequestId{get; set;}
    //Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;}
    //Public List<string> ListOfReasons{get; set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfTermApprovalLineItems{get; set;}
    public Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public Apttus_Config2__ProductConfiguration__c prodConfig {get;set;}
    private ID prodConfigID;
    private ID proposalID2;
    Public APTS_ProposalApprovalController(){}
    
    Public List<string> getListOfReasons(){
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

        
        List<string> ListOfReasons = new List<string>();
        
        for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where ID =: ApprovalRequestId])
                                   //Where Apttus_QPApprov__ProposalId__c =: ProposalId])
       {
         prodConfigID = appr.Apttus_CQApprov__CartId__c;
           proposalID2 = appr.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c;
          if(appr.Apttus_Approval__Step_Name__c.contains('Support Discount') && SupportDiscount )
         {
             ListOfReasons.add('Support Discount');
             SupportDiscount = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Discount') && Discount )
         {
             ListOfReasons.add('Discount');
             Discount = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Payment Term') && PaymentTerm )
         {
             ListOfReasons.add('Payment Term');
             PaymentTerm = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Billing Frequency') && BillingFrequency )
         {
             ListOfReasons.add('Billing Frequency');
             BillingFrequency = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms') && CustomTerms )
         {
             ListOfReasons.add('Custom Terms');
             CustomTerms = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Ramp Schedule') && RampSchedule )
         {
             ListOfReasons.add('Ramp Schedule');
             RampSchedule = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Term < 3 Years') && Term_3Years )
         {
             ListOfReasons.add('Term < 3 Years');
             Term_3Years  = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Subscription Uplift ') && SubscriptionUplift )
         {
             ListOfReasons.add('Subscription Uplift ');
             SubscriptionUplift = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Co-Term') && CoTerm )
         {
             ListOfReasons.add('Co-Term');
             CoTerm = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal MRR') && DecreaseinRenewalMRR )
         {
             ListOfReasons.add('Decrease in Renewal MRR');
             DecreaseinRenewalMRR = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal TCV') && DecreaseinRenewalTCV )
         {
             ListOfReasons.add('Decrease in Renewal TCV');
             DecreaseinRenewalTCV = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('DAS Seats Mismatch - Customer Success') && DASSeatsMismatchCustomerSuccess )
         {
             ListOfReasons.add('DAS Seats Mismatch - Customer Success');
             DASSeatsMismatchCustomerSuccess = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Buy Back Credit - Deal Desk') && BuyBackCreditDealDesk )
         {
             ListOfReasons.add('Buy Back Credit - Deal Desk');
             BuyBackCreditDealDesk = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('NFR - Deal Desk') && NFRDealDesk )
         {
             ListOfReasons.add('NFR - Deal Desk');
             NFRDealDesk = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Onsite TAM - Customer Success') && OnsiteTAMCustomerSuccess )
         {
             ListOfReasons.add('Onsite TAM - Customer Success');
             OnsiteTAMCustomerSuccess = false;
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Zscaler Extend Transaction Log - Product Management') && ZscalerExtendTransactionLogProductManagement )
         {
             ListOfReasons.add('Zscaler Extend Transaction Log - Product Management');
             ZscalerExtendTransactionLogProductManagement = false;
         }
         
       }
        return ListOfReasons;
       
          
    }
    
   
    Public Apttus_Proposal__Proposal__c GetProposal(){
        System.debug('Bose ProposalID: ' + ProposalID);
        List<Apttus_Proposal__Proposal__c> proposals = new List<Apttus_Proposal__Proposal__c>();
        proposals = [SELECT Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Name,
                      Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c,
                      Apttus_Proposal__Payment_Term__c, APTS_Billing_Frequency__c, APTS_Record_Type_Name__c,
                      Apttus_Proposal__Opportunity__r.Name, APTS_Subscription_Term__c, APTS_Proposal_Net_Price__c,
                      APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Approval_Reason__c, No_of_Users__c,
                      Apttus_Proposal__Special_Terms__c, Apttus_QPConfig__BillToAccountId__r.Name, APTS_ACV__c,
                      Apttus_Proposal__Opportunity__r.VMO_Play__c, Brand_Ambassador__c, Abs_Total_Discount__c
                      FROM Apttus_Proposal__Proposal__c 
                      WHERE Id =: proposalID2]; 
                     //WHERE Id =: ProposalId]; 
        proposalSO = new Apttus_Proposal__Proposal__c();
        if(proposals.size() > 0) {
            proposalSO =  proposals[0];
              
        }
        
        return  proposalSO;               
    }
    
    public Apttus_Config2__ProductConfiguration__c getProductConfig() {
        //List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE Apttus_QPConfig__Proposald__c =: ProposalID ORDER BY Apttus_Config2__VersionNumber__c Desc];
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c WHERE ID = :prodConfigID];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        
        return prodConfig;
    }
    
    Public List<Apttus_Config2__LineItem__c> GetListOfLineItems(){
    
        //System.debug('Bose ProposalID: ' + ProposalID);
        System.debug('Bose ProposalID: ' + proposalID2);
        
        List<Apttus_Config2__LineItem__c> ListOfLineItems = new List<Apttus_Config2__LineItem__c>();
        List<Apttus_Config2__ProductConfiguration__c> prodConfigs = [SELECT Id
                                                                     FROM Apttus_Config2__ProductConfiguration__c 
                                                                     where ID  = :prodConfigID];
                                                                     //WHERE Apttus_QPConfig__Proposald__c =: ProposalID
                                                                     //ORDER BY Apttus_Config2__VersionNumber__c Desc];
        prodConfig = new Apttus_Config2__ProductConfiguration__c();
        if(prodConfigs.size() > 0) {
            prodConfig = prodConfigs[0];
        }
        if(prodConfig != null) {
            ListOfLineItems=[Select Id, Apttus_Config2__ProductId__c, Apttus_Config2__ProductId__r.Name, Apttus_Config2__ListPrice__c, Apttus_Config2__Quantity__c, Apttus_Config2__StartDate__c, 
            Apttus_Config2__EndDate__c, Apttus_Config2__PaymentTermId__c, Apttus_Config2__PaymentTermId__r.Name, Apttus_Config2__Guidance__c, APTS_Partner_Disc__c, 
            APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c, APTS_Manual_Discount__c, Apttus_Config2__AdjustmentType__c, APTS_Total_Discount_Percentage__c, 
            Apttus_Config2__NetPrice__c, APTS_MRR__c, APTS_Prev_MRR__c, APTS_Manual_Discount_Approvals__c, APTS_Selling_Term__c, APTS_Total_Partner_Discount__c
                             from Apttus_Config2__LineItem__c
                             Where Apttus_Config2__ConfigurationId__c =: prodConfig.Id];
        }        
        return ListOfLineItems;
    
    }
/*
    Public List<string> GetListOfReasons(){
    
        ListOfReasons = new List<string>();
         ListOfReasons.add('pehlse'); 
        for(Apttus_Approval__Approval_Request__c appr : [Select Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, 
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where ID =: ApprovalRequestId])
                                   //Where Apttus_QPApprov__ProposalId__c =: ProposalID and Apttus_QPApprov__ProposalId__c  != null])
       {
          ListOfReasons.add('Khali hai');  
         if(appr.Apttus_Approval__Step_Name__c.contains('Support Discount'))
         {
             ListOfReasons.add('Support Discount');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Discount'))
         {
             ListOfReasons.add('Discount');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Payment Term'))
         {
             ListOfReasons.add('Payment Term');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Billing Frequency'))
         {
             ListOfReasons.add('Billing Frequency');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms'))
         {
             ListOfReasons.add('Custom Terms');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Ramp Schedule'))
         {
             ListOfReasons.add('Ramp Schedule');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Term < 3 Years'))
         {
             ListOfReasons.add('Term < 3 Years');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Subscription Uplift '))
         {
             ListOfReasons.add('Subscription Uplift ');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Co-Term'))
         {
             ListOfReasons.add('Co-Term');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal MRR'))
         {
             ListOfReasons.add('Decrease in Renewal MRR');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Decrease in Renewal TCV'))
         {
             ListOfReasons.add('Decrease in Renewal TCV');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('DAS Seats Mismatch'))
         {
             ListOfReasons.add('DAS Seats Mismatch');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Buy Back Credit'))
         {
             ListOfReasons.add('Buy Back Credit');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('NFR'))
         {
             ListOfReasons.add('NFR');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Onsite TAM'))
         {
             ListOfReasons.add('Onsite TAM');
         }
         else if(appr.Apttus_Approval__Step_Name__c.contains('Zscaler Extend Transaction Log'))
         {
             ListOfReasons.add('Zscaler Extend Transaction Log');
         }
         
       }
       
       System.debug('Bose ListOfReasons ' + ListOfReasons );
        return ListOfReasons ;
    
    }

*/
}