/*****************************************************************************************
Name: ApprovalItemsController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Controller class for ApprovalItems VF Page.

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            5-May-2017    Initial Development
******************************************************************************************/


public class ApprovalItemsController {

    public List<Apttus_Approval__Approval_Request__c> approvalReqList{get; set;}
    public string sortField {get;set;}
    public string sortOrder {get;set;}
    public string prevSortField {get; set;}
    public string sortBy ;
    public string userid = UserInfo.getUserId();
    public String status = 'Assigned';
    public String status1 = 'Reassigned';

    public string queryString = 'Select Id, Apttus_QPApprov__ProposalId__r.Abs_Total_Discount__c, APTSC_Approval_Action__c, Apttus_QPApprov__ProposalId__c, Apttus_QPApprov__ProposalId__r.Name, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__c, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__r.Name, Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__r.CloseDate, Apttus_Approval__DateAssigned__c, Apttus_QPApprov__ProposalId__r.APTS_ACV__c, Apttus_QPApprov__ProposalId__r.APTS_Proposal_Net_Price__c, Apttus_QPApprov__ProposalId__r.APTS_Subscription_Term__c, Name FROM Apttus_Approval__Approval_Request__c WHERE (Apttus_Approval__Assigned_To_Id__c =: userid OR Apttus_Approval__DelegateApproverIds__c LIKE \'%' + userid + '%\') AND (Apttus_Approval__Approval_Status__c =: status OR Apttus_Approval__Approval_Status__c =: status1) AND (Apttus_QPApprov__ProposalId__r.Apttus_Proposal__Opportunity__r.Stagename not in (\'6 - Closed Won\',\'7 - Closed Lost\'))'; 

    public ApprovalItemsController(){
        approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
        sortBy = ' ORDER BY APTS_Submitted_Date__c';
        sortOrder  = ' DESC ';
        prevSortField = '';
        sortField = '';
        set<string> quoteNumberSet = new set<string>();
        for(Apttus_Approval__Approval_Request__c appReq : Database.query(queryString+sortBy+sortOrder)){
            if(appReq.Apttus_QPApprov__ProposalId__c != null && !quoteNumberSet.contains(appReq.Apttus_QPApprov__ProposalId__c)){
                quoteNumberSet.add(appReq.Apttus_QPApprov__ProposalId__c);
                approvalReqList.add(appReq);

            }
        }
    }


    public void doSorting(){

        if( prevSortField != '' && prevSortField == sortField){
            sortBy = ' ORDER BY ' + sortField;
            sortOrder = ' ASC ';
            prevSortField = '';
        }else{
            sortBy = ' ORDER BY ' + sortField;
            sortOrder = ' DESC ';
            prevSortField = sortField;
        }
        set<string> quoteNumberSet = new set<string>();
        approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
        System.debug('# Query String : '+(queryString+sortBy+sortOrder));
        for(Apttus_Approval__Approval_Request__c appReq : Database.query(queryString+sortBy+sortOrder)){
            system.debug('# quoteNumberSet : '+quoteNumberSet);
            if( appReq.Apttus_QPApprov__ProposalId__c != null && !quoteNumberSet.contains(appReq.Apttus_QPApprov__ProposalId__c)){
                quoteNumberSet.add(appReq.Apttus_QPApprov__ProposalId__c);
                approvalReqList.add(appReq);
            }
        }
    }

    public void refereshAppReq(){
        set<string> quoteNumberSet = new set<string>();
        approvalReqList = new List<Apttus_Approval__Approval_Request__c>();
        for(Apttus_Approval__Approval_Request__c appReq : Database.query(queryString+sortBy+sortOrder)){
            if(appReq.Apttus_QPApprov__ProposalId__c != null && !quoteNumberSet.contains(appReq.Apttus_QPApprov__ProposalId__c)){
                quoteNumberSet.add(appReq.Apttus_QPApprov__ProposalId__c);
                approvalReqList.add(appReq);

            }
        }
    }
}