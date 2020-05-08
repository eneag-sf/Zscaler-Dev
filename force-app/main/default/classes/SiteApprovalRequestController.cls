public with sharing class SiteApprovalRequestController {
    public Id equipmentRequestRecordId { get; set; }
	public List<Site_Request__c> lstSiteRequests { get; set; }

    public SiteApprovalRequestController() {
		getSiteRequests();
	}

    public List<Site_Request__c> getSiteRequests() {
        lstSiteRequests = new List<Site_Request__c>();

        for (Site_Request__c request : [SELECT Contact_Email__c,Contact_Name__c,Contact_phone__c,Country_for_ME_Node__c,
                                               Customer_City__c,Customer_Country_New__c,Customer_Name__c,Customer_Name__r.Name,Customer_State__c,
                                               Customer_Street_Address__c,Domain_Name__c,Estimated_Start_Date__c,
                                               Estimated_Stop_Date__c,Id,ISP_Used__c,ME_Equipment_Request__c,Name,
                                               Number_of_users__c,Zscaler_Suite_and_any_Add_ons_to_be_quot__c, Is_this_for_a_POC__c
                                          FROM Site_Request__c
                                         WHERE ME_Equipment_Request__c = :equipmentRequestRecordId]) {
            lstSiteRequests.add(request);
        }

        return lstSiteRequests;
    }
}