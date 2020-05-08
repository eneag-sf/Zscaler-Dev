public with sharing class SubmitSiteRequestApproval {
    public String recordId { get; set; }

	public SubmitSiteRequestApproval() {
		recordId = ApexPages.currentPage().getParameters().get('Id');
	}

    public PageReference submitForApproval() {
        Equipment_Request__c equipReq = [SELECT Id, Is_Site_Request_Approval_Sent__c  
                                           FROM Equipment_Request__c
                                          WHERE Id = :recordId];

        equipReq.Is_Site_Request_Approval_Sent__c  = true;
        update equipReq;

        PageReference equipReqPage = new PageReference('/' + recordId);
        return equipReqPage;
    }
}