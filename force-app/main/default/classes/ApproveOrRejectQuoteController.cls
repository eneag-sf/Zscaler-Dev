public class ApproveOrRejectQuoteController {
	public string approvalComments {get; set;}
	public Apttus_Approval__Approval_Request__c approverReq {get; set;}
	public id userId {get; set;}
	public ApproveOrRejectQuoteController(){
		approverReq = new Apttus_Approval__Approval_Request__c();
		userId = userInfo.getUserId();
		string appReqId = '';
		appReqId = ApexPages.currentPage().getParameters().get('Id');
		if(appReqId != null && appReqId != '')
			approverReq = [Select id, Apttus_QPApprov__ProposalId__c, APTS_Instance_URL__c  from Apttus_Approval__Approval_Request__c where Id =: appReqId];

	}
	public void approveQuote(){
        if(approverReq != null){
            Apttus_Approval.ApprovalsWebService.approveRequest(approverReq.Id, approvalComments);
           // isApprovedOrRejected = true;
        }
    }
    public void rejectQuote(){
        if(approverReq != null){
            system.debug('# approverReq : '+approverReq);
            system.debug('# approvalComments : '+approvalComments);
            Apttus_Approval.ApprovalsWebService.rejectRequest(approverReq.Id, approvalComments);
           // isApprovedOrRejected = true;
        }
    }
}