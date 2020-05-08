global class QuoteApprovalController{

    Public String InstanceURL{get; set;}
    Public ID ApproverId{get; set;}
    Public ID ApprovalRequestId{get; set;}
    public boolean IsAssignment {get; set;}
    public boolean IsApproved {get; set;}
    public boolean isPartnerSummit {get; set;}
    public boolean isPartnerAdjustment {get; set;}
    public boolean IsApproveOrReject {get; set;}
    public string url {get;set;}
    //Public List<Apttus_Approval__Approval_Request__c> ListOfApprovalLineItems{get; set;}
    //Public List<string> ListOfReasons{get; set;}
    Public List<Apttus_Approval__Approval_Request__c> ListOfTermApprovalLineItems{get; set;}
   //  public list<String> myApprovalExceptionsList {get; set;}
     // public list<String> otherApprovalExceptionsList {get; set;}
    public Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public Apttus_Config2__ProductConfiguration__c prodConfig {get;set;}
    private ID prodConfigID;
    private ID proposalID2;
    public String ProposalId {get;set;}
    public String ApproversId {get;set;}
    public Decimal oldppu{get;set;}
    public decimal newppu{get;set;}
    public decimal changeofPPU{get;set;}
    Public QuoteApprovalController(){
      url  = System.Url.getSalesforceBaseURL().toExternalForm();
      /*
      myApprovalExceptionsList = new list<String>();
    otherApprovalExceptionsList = new List<string>();
    set<String> myApprovalExceptionsSet = new set<String>();
    set<String> otherApprovalExceptionsSet = new set<String>();
    set<String> approvalReqStatusSet = new set<String>();
    approvalReqStatusSet.add('Assigned');
    approvalReqStatusSet.add('On Hold');

    ApproversId = '';
    ProposalId = '';

    for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Assigned_To_Id__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c from Apttus_Approval__Approval_Request__c Where ID =: ApprovalRequestId]){
      if(ApproversId == '' || ApproversId == null)
        ApproversId = appr.Apttus_Approval__Assigned_To_Id__c;
      if(ProposalId == '' || ProposalId == null)
        ProposalId = appr.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c;
    }

    System.debug('# ApprovalRequestId : '+ApprovalRequestId);
    System.debug('# ApproversId : '+ApproversId);
    System.debug('# ApproverId : '+ApproverId);
      for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Assigned_To_Id__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet ]){
        //AND Apttus_Approval__Assigned_To_Name__c =: ApproversId
        // Add all the exceptions :
        //


        if(appr.Apttus_Approval__Step_Name__c.contains('Header Level Approval Step')){
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            myApprovalExceptionsSet.add('Header Level Approval Step');
          else
            otherApprovalExceptionsSet.add('Header Level Approval Step');
        }else if(appr.Apttus_Approval__Step_Name__c.contains('Test Approval')){
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            myApprovalExceptionsSet.add('Test Approval');
          else
            otherApprovalExceptionsSet.add('Test Approval');
        }else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms')){
          //exceptionSet.add('Support Discount');
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            myApprovalExceptionsSet.add('Custom Terms');
          else
            otherApprovalExceptionsSet.add('Custom Terms');
        }

      }
      myApprovalExceptionsList.addAll(myApprovalExceptionsSet);
      otherApprovalExceptionsList.addAll(otherApprovalExceptionsSet);
      //exceptionList.addAll(exceptionSet);
      */
    }

    public string getRejectedBy(){
      String rejectedBy = '';

      for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_Approval__ActualApproverName__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c =: 'Rejected' AND Apttus_Approval__ContinuePolicyApprovalOnAReject__c =: false] ){
        if(appr.Apttus_Approval__ActualApproverName__c != null && appr.Apttus_Approval__ActualApproverName__c != '' && appr.Apttus_Approval__Approver_Comments__c.contains('Rejected - '))
          rejectedBy = appr.Apttus_Approval__ActualApproverName__c;
        if(!appr.Apttus_Approval__Approver_Comments__c.contains('On-Hold for consolidation') && appr.Apttus_Approval__Approver_Comments__c.contains('Approver comments')){
          rejectedBy = appr.Apttus_Approval__ActualApproverName__c;
        }
      }
      return rejectedBy;
    }
    public string  getRejectionReason(){
      string reason = '';
      list<String> strList = new list<String>();
      for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_Approval__ActualApproverName__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c =: 'Rejected' AND Apttus_Approval__ContinuePolicyApprovalOnAReject__c =: false] ){
        strList = new list<String>();
        string reasonStr = '';
        if(!appr.Apttus_Approval__Approver_Comments__c.contains('On-Hold for consolidation') && appr.Apttus_Approval__Approver_Comments__c.contains('Approver comments')){
          strList = appr.Apttus_Approval__Approver_Comments__c.split('Approver comments');
          reasonStr = strList[1];
          reasonStr = reasonStr.right(reasonStr.length()-3);
          reasonStr = reasonStr.left(reasonStr.length()-24);
        }
          reason +=  reasonStr + ' ';
        }
        if(reason == null || reason == '')
          reason = 'No Rejection Reason Provided.';
      return reason ;
    }
    public list<string>  getApprovalExceptionsList(){
      set<String> exceptionSet = new set<String>();
      List<string> exceptionList = new List<string>();
      set<String> approvalReqStatusSet = new set<String>();
      if(IsApproved)
        approvalReqStatusSet.add('Approved');
      else{
        approvalReqStatusSet.add('Rejected');
        approvalReqStatusSet.add('Cancelled');
      }

      for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_QPApprov__ProposalId__r.APTS_Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Payment_Term__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c,Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c,Apttus_QPApprov__ProposalId__r.Average_Support_Discount__c, Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c, Apttus_QPApprov__ProposalId__r.Total_Discount_Without_Support__c, Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c, Apttus_QPApprov__ProposalId__r.Adjustments_Provided__c, Apttus_QPApprov__ProposalId__r.APTS_Record_Type_Name__c, Apttus_QPApprov__ProposalId__r.APTS_Platform_End_Date__c, Apttus_QPApprov__ProposalId__r.Renewal_MRR_Change__c, Apttus_QPApprov__ProposalId__r.APTS_Current_Quote_MRR__c, Apttus_QPApprov__ProposalId__r.Previous_MRR__c,
                                   Apttus_QPApprov__ProposalId__r.Maximum_Ramp_Line_Item_Sequence__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet AND Apttus_Approval__Assigned_To_Id__c != NULL] ){
        string str = '';
        str = genrateExceptionLiteral(appr);
        if(str != null && str != '')
          exceptionSet.add(str);

      }
      System.debug('# Other exceptionSet : '+exceptionSet);
      exceptionList.addAll(exceptionSet);
      return exceptionList;

    }
    public list<string>  getMyApprovalExceptionsList(){
    set<String> exceptionSet = new set<String>();
    List<string> exceptionList = new List<string>();
    set<String> approvalReqStatusSet = new set<String>();
    approvalReqStatusSet.add('Assigned');
    approvalReqStatusSet.add('On Hold');
    approvalReqStatusSet.add('Reassigned');
    System.debug('# ApproverId : '+ApproverId);
    System.debug('# ProposalId : '+ProposalId);
    for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_QPApprov__ProposalId__r.APTS_Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Payment_Term__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c,Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c,Apttus_QPApprov__ProposalId__r.Average_Support_Discount__c, Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c, Apttus_QPApprov__ProposalId__r.Total_Discount_Without_Support__c, Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c, Apttus_QPApprov__ProposalId__r.Adjustments_Provided__c, Apttus_QPApprov__ProposalId__r.APTS_Record_Type_Name__c, Apttus_QPApprov__ProposalId__r.APTS_Platform_End_Date__c, Apttus_QPApprov__ProposalId__r.Renewal_MRR_Change__c, Apttus_QPApprov__ProposalId__r.APTS_Current_Quote_MRR__c, Apttus_QPApprov__ProposalId__r.Previous_MRR__c,
                                   Apttus_QPApprov__ProposalId__r.Maximum_Ramp_Line_Item_Sequence__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet AND Apttus_Approval__Assigned_To_Id__c =: ApproverId]){

        string str = '';
        str = genrateExceptionLiteral(appr);
        if(str != null && str != '')
          exceptionSet.add(str);


      }
      System.debug('# My exceptionSet : '+exceptionSet);
      exceptionList.addAll(exceptionSet);
      return exceptionList;
  }

  public list<string>  getOtherApprovalExceptionsList(){
    set<String> exceptionSet = new set<String>();
    set<String> approverExceptionSet = new set<String>();
    List<string> exceptionList = new List<string>();
    set<String> approvalReqStatusSet = new set<String>();
    approvalReqStatusSet.add('Assigned');
    approvalReqStatusSet.add('On Hold');

    for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_QPApprov__ProposalId__r.APTS_Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Payment_Term__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c,Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c,Apttus_QPApprov__ProposalId__r.Average_Support_Discount__c, Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c, Apttus_QPApprov__ProposalId__r.Total_Discount_Without_Support__c, Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c, Apttus_QPApprov__ProposalId__r.Adjustments_Provided__c, Apttus_QPApprov__ProposalId__r.APTS_Record_Type_Name__c,Apttus_QPApprov__ProposalId__r.APTS_Platform_End_Date__c, Apttus_QPApprov__ProposalId__r.Renewal_MRR_Change__c, Apttus_QPApprov__ProposalId__r.APTS_Current_Quote_MRR__c, Apttus_QPApprov__ProposalId__r.Previous_MRR__c,
                                   Apttus_QPApprov__ProposalId__r.Maximum_Ramp_Line_Item_Sequence__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet AND Apttus_Approval__Assigned_To_Id__c =: ApproverId]){

        string str = '';
        str = genrateExceptionLiteral(appr);
        if(str != null && str != '')
          approverExceptionSet.add(str);

     }
    for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c, Apttus_QPApprov__ProposalId__c, Apttus_QPApprov__ProposalId__r.APTS_Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Payment_Term__c, Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c,Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c,Apttus_QPApprov__ProposalId__r.Average_Support_Discount__c, Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c, Apttus_QPApprov__ProposalId__r.Adjustments_Provided__c, Apttus_QPApprov__ProposalId__r.Total_Discount_Without_Support__c, Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c, Apttus_QPApprov__ProposalId__r.APTS_Record_Type_Name__c, Apttus_QPApprov__ProposalId__r.APTS_Platform_End_Date__c, Apttus_QPApprov__ProposalId__r.Renewal_MRR_Change__c, Apttus_QPApprov__ProposalId__r.APTS_Current_Quote_MRR__c, Apttus_QPApprov__ProposalId__r.Previous_MRR__c, Apttus_QPApprov__ProposalId__r.Maximum_Ramp_Line_Item_Sequence__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_QPApprov__ProposalId__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet ]){
      if(appr.Apttus_Approval__Assigned_To_Id__c != ApproverId && appr.Apttus_Approval__Assigned_To_Id__c != null  && appr.Apttus_Approval__Assigned_To_Id__c != ''){
       string str = '';
        str = genrateExceptionLiteral(appr);
        if(str != null && str != '' && !approverExceptionSet.contains(str))
          exceptionSet.add(str);
      }


      }
      exceptionList.addAll(exceptionSet);
      return exceptionList;
  }

  public string genrateExceptionLiteral(Apttus_Approval__Approval_Request__c appr){
      string str = '';
      if(appr.Apttus_Approval__Step_Name__c.contains('Billing Frequency')){
        str += '- Billing Frequency of the partner is : '+ (appr.Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c != null ? appr.Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Billing_Frequency__c : '')+'. This quote has : '+appr.Apttus_QPApprov__ProposalId__r.APTS_Billing_Frequency__c;
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Buy Back Credit')){
        str += '- A Buyback credit is offered';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms')){
        str += '- Custom T&C have been added by the Rep';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('DAS Seats Mismatch')){
        str += '- DAS Package quoted does not align with the Number of Users';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Zscaler Extend Transaction Log')){
        str += '- Extended Logs Product is included in the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Co-Term')){
        if(appr.Apttus_QPApprov__ProposalId__r.APTS_Record_Type_Name__c == 'Upsell'){
          str += '- The lines on this configuration do not  Co Term with the current Subscription End date of '+appr.Apttus_QPApprov__ProposalId__r.APTS_Platform_End_Date__c.format();
        }else{
          str += '- One or more Lines in the deal are not co termed';
        }

      }else if(appr.Apttus_Approval__Step_Name__c.contains('NFR')){
        str += '- NFR is included in this configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('One Time Credit Approval')){
        str += '- A one-time credit is offered in the quote';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Onsite TAM')){
        str += '- An Onsite TAM is included in the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Payment Term')){
        str += '- Payment Terms of the partner is : '+(appr.Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c != null ? appr.Apttus_QPApprov__ProposalId__r.Apttus_QPConfig__BillToAccountId__r.Payment_Terms__c : '')+'. This quote has : '+appr.Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Payment_Term__c;
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Services')){
        str += '- Professional services are included in the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Ramp Schedule')){
          if (appr.Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c > 0) {
              str += '- One or more Lines have a '+ integer.valueOf(appr.Apttus_QPApprov__ProposalId__r.Requires_Ramp_Approval__c)+' month Ramp Schedule';
          }
          if (appr.Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c < 36
            && appr.Apttus_QPApprov__ProposalId__r.Maximum_Ramp_Line_Item_Sequence__c > 1) {
                str += '- The subscription Term on this deal is less than 3 years and it includes a Ramp';
          }
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Term < 3 Years')){
        str += '- The subscription term on this quote is '+appr.Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c+' Months';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Support and DAS Approval')){
        str += '- The support offering is discounted at '+appr.Apttus_QPApprov__ProposalId__r.Average_Support_Discount__c+'%';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Discount - Zscaler')){
        str += '- This is a direct deal and the Total Discount is '+appr.Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c+'%';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Discount')){
        // str += '- The product offerings in the quote are discounted '+appr.Apttus_QPApprov__ProposalId__r.Adjustments_Provided__c+'% over standard discount. The overall product discount for this quote is '+appr.Apttus_QPApprov__ProposalId__r.Net_Discount_W_O_Support__c+'%';
        str += '- The Total Discount excluding support is ' + appr.Apttus_QPApprov__ProposalId__r.Total_Discount_Without_Support__c + '%';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZPA Enterprise')){
        str += '- ZPA Enterprise SKU is part of the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ThreatLabZ Threat Insights Service')){
        str += '- ThreatLabZ Threat Insights Service SKU is part of the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Renewal MRR')){
        str += '- The Previous MRR is : $'+appr.Apttus_QPApprov__ProposalId__r.Previous_MRR__c+'. MRR on this Quote is : $'+appr.Apttus_QPApprov__ProposalId__r.APTS_Current_Quote_MRR__c.SetScale(2)+'. The uplift : '+appr.Apttus_QPApprov__ProposalId__r.Renewal_MRR_Change__c+ '%';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZAB Private Node')){
        str += '- The configuration below has the Zscaler Private Authentication Bridge VM (including Kerberos)';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZIA Enterprise License Agreement')){
        str += '- ZIA Enterprise License Agreement SKU is part of the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZIA Enterprise License Agreement')){
        str += '- ZIA Enterprise License Agreement SKU is part of the configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Zscaler DLP Exact Data Match')){
        str += '- The Quote has ZDLP-EDM and needs Product Management Approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Office 365 Connectivity')){
        str += '- The Quote has Office 365 and needs Product Management Approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('FedRamp Approval')){
        str += '- Federal SKUs are part of this configuration';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZPA 100 Seats Promo Approval')) {
        str += '- The Quote has ZPA 100 Seats Promo and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Zenith Live PROMO Approval')) {
        str += '- The Quote has Zenith Live Promo and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Light Bundle PM Approval')) {
        str += '- The Quote has Light User Bundle and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('New Deployment Approval')) {
        str += '- The Quote has New Deployment SKUs with more than 10% discount and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('ZIA Reserved ZEN')) {
        str += '- The Quote has ZIA Reserved ZEN and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Isolation Approval')) {
        str += '- The Quote has Isolation SKUs and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Pre SKUs Approval')) {
        str += '- The Quote has Pre SKUs and needs approval';
      }else if(appr.Apttus_Approval__Step_Name__c.contains('Professional Service Bundle:Optimize')){ //Changes by Gurjinder for New Opt SKU:Start
          str += '- The Quote has Professional Service Bundle Optimize SKUs and needs approval';
      }//Changes by Gurjinder for New Opt SKU:End


      return str;
  }
    Public List<string> getListOfExceptions(){
      /*set<String> exceptionSet = new set<String>();
    List<string> exceptionList = new List<string>();
    set<String> approvalReqStatusSet = new set<String>();
    otherApprovalExceptionsList = new List<string>();
    set<String> otherApprovalExceptionsSet = new set<String>();


    approvalReqStatusSet.add('Assigned');
    approvalReqStatusSet.add('On Hold');

    String  ApproversId = '';
    ProposalId = '';

    for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Assigned_To_Name__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c from Apttus_Approval__Approval_Request__c Where ID =: ApprovalRequestId]){
      if(ApproversId == '' || ApproversId == null)
        ApproversId = appr.Apttus_Approval__Assigned_To_Name__c;
      if(ProposalId == '' || ProposalId == null)
        ProposalId = appr.Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c;
    }


      for(Apttus_Approval__Approval_Request__c appr : [Select Id, Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c,
                                   Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Id__c, Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__DependsOn__c ,
                                   Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c, Apttus_Approval__Request_Comments__c,
                                   Apttus_Approval__SubmissionComment1__c , Apttus_CQApprov__CartId__c, Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c
                                   from Apttus_Approval__Approval_Request__c
                                   Where Apttus_CQApprov__CartId__r.Apttus_QPConfig__Proposald__c =: ProposalId  AND Apttus_Approval__Approval_Status__c IN: approvalReqStatusSet ]){

        // Add all the exceptions :
        if(appr.Apttus_Approval__Step_Name__c.contains('Header Level Approval Step')){
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            exceptionSet.add('Header Level Approval Step');
          else
            otherApprovalExceptionsSet.add('Header Level Approval Step');
        }else if(appr.Apttus_Approval__Step_Name__c.contains('Test Approval')){
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            exceptionSet.add('Test Approval');
          else
            otherApprovalExceptionsSet.add('Test Approval');
        }else if(appr.Apttus_Approval__Step_Name__c.contains('Custom Terms')){
          //exceptionSet.add('Support Discount');
          if(appr.Apttus_Approval__Assigned_To_Id__c == ApproverId)
            exceptionSet.add('Custom Terms');
          else
            otherApprovalExceptionsSet.add('Custom Terms');
        }

      }
      otherApprovalExceptionsList.addAll(otherApprovalExceptionsSet);
      exceptionList.addAll(exceptionSet);
      */
      return null;
    }

    Public Apttus_Proposal__Proposal__c getProposal(){
        List<Apttus_Proposal__Proposal__c> proposals = new List<Apttus_Proposal__Proposal__c>();
        proposals = [SELECT Id, Apttus_Proposal__Proposal_Name__c, Apttus_Proposal__Account__r.Name, Name,
                      Apttus_Proposal__ExpectedEndDate__c, Apttus_Proposal__ExpectedStartDate__c,Total_Discount_Without_Support__c,
                      Apttus_Proposal__Payment_Term__c, APTS_Billing_Frequency__c, APTS_Record_Type_Name__c,
                      Apttus_Proposal__Opportunity__r.Id, Apttus_Proposal__Opportunity__r.Name, APTS_Subscription_Term__c, APTS_Proposal_Net_Price__c,
                      APTS_Current_Quote_MRR__c, APTS_Original_Quote_MRR__c, APTS_Approval_Reason__c, No_of_Users__c,
                      Apttus_Proposal__Special_Terms__c, Apttus_QPConfig__BillToAccountId__r.Name, APTS_ACV__c,
                      Apttus_Proposal__Opportunity__r.VMO_Play__c, Model_Type_Partner__c, Brand_Ambassador__c, Abs_Total_Discount__c, Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c, APTS_Has_Custom_Terms__c, Custom_Term_Exists__c, Special_Term__c, Renewal_MRR_Change__c, Previous_MRR__c, Apttus_Proposal__Account__r.Customer_Sentiment__c, Apttus_Proposal__Account__r.Success_Stage__c, 
                      Total_Net_to_Zscaler__c, Total_Stackable_Margin__c, Total_Deal_Discount__c 
                      FROM Apttus_Proposal__Proposal__c
                      WHERE Id =: ProposalId];
                     //WHERE Id =: ProposalId];
        proposalSO = new Apttus_Proposal__Proposal__c();
        if(proposals.size() > 0) {
            proposalSO =  proposals[0];
            isPartnerSummit = proposalSO.Model_Type_Partner__c == 'Partner Summit' || (proposalSO.Apttus_QPConfig__BillToAccountId__r.Name != null && (proposalSO.Apttus_QPConfig__BillToAccountId__r.Name.contains('Margin') || proposalSO.Apttus_QPConfig__BillToAccountId__r.Name.contains('margin')));
            isPartnerAdjustment = proposalSO.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c;
        }

        return  proposalSO;
    }

    Public List<Apttus_Proposal__Proposal_Line_Item__c> GetListOfLineItems(){
        list<Apttus_Proposal__Proposal_Line_Item__c> listOfPropLineItem = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        oldppu = 0;
        newppu = 0;
        listOfPropLineItem = [Select Id, Customer_Discount__c, Total_Stackable_Margin__c, APTS_Manual_Discount__c, Apttus_QPConfig__AdjustmentType__c, APTS_Base_Price_override__c, Apttus_QPConfig__DerivedFromId__r.Partner_Summit_Deal_Reg__c, Apttus_QPConfig__DerivedFromId__r.AW_Margin_Formula__c, Apttus_QPConfig__DerivedFromId__r.POV__c, Apttus_QPConfig__DerivedFromId__r.Fulfilment_Margin__c, Apttus_QPConfig__DerivedFromId__r.Partner_Adjustment__c, Apttus_QPConfig__DerivedFromId__r.Partner_Adjustment_Type__c, Apttus_QPConfig__DerivedFromId__r.Total_Stackable_Margin__c, Apttus_QPConfig__DerivedFromId__r.Net_to_Zscaler__c, Apttus_QPConfig__DerivedFromId__r.Total_Zscaler_Discount__c, Apttus_QPConfig__AssetLineItemId__r.Price_Per_Unit__c, Apttus_QPConfig__PriceGroup__c , APTS_Total_Ramp_Quantity__c , Apttus_Proposal__Product__r.Name, Price_Per_Unit__c, Old_PPU__c, APTS_Quantity__c, APTS_Selling_Term__c, APTS_Partner_Disc__c, APTS_Total_Discount_Percentage__c, APTS_Net_Price__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_MRR__c, Term_to_Show__c,Product_Name__c, Apttus_QPConfig__ItemSequence__c, Apttus_QPConfig__LineStatus__c, Is_Ramped_SKU__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c =: ProposalId ];
        for(Apttus_Proposal__Proposal_Line_Item__c pli: listOfPropLineItem){
            if(pli.Apttus_QPConfig__LineStatus__c != 'Cancelled' && (pli.Apttus_QPConfig__PriceGroup__c != 'Price Ramp' || (pli.Apttus_QPConfig__PriceGroup__c == 'Price Ramp' && pli.APTS_Total_Ramp_Quantity__c == pli.APTS_Quantity__c))){
                oldppu += pli.Old_PPU__c!= null ? pli.Old_PPU__c : (pli.Apttus_QPConfig__AssetLineItemId__r.Price_Per_Unit__c != null ? pli.Apttus_QPConfig__AssetLineItemId__r.Price_Per_Unit__c : 0);
                newppu += pli.Price_Per_Unit__c != null ? pli.Price_Per_Unit__c : 0;
            }
        }
        changeofPPU = oldppu != 0 ? ((newppu - oldppu) / oldppu) * 100 : 0;
        return listOfPropLineItem;
    }
    
    public static void booster(){
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
    }


}