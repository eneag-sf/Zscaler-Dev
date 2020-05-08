public class ApprovalStatusUpdateTriggerHandler {
	public ApprovalStatusUpdateTriggerHandler() {

	}

    public static void updateApprovalStatus(Map<Id, Apttus_Approval__Approval_Request__c> oldMap, List<Apttus_Approval__Approval_Request__c> newList) {
        Set<Id> setZABApprovedProposalIds = new Set<Id>();
        Set<Id> setELAApprovedProposalIds = new Set<Id>();

        List<Account> lstAccountsToBeUpdated = new List<Account>();
        List<Opportunity> lstOpportunitiesToBeUpdated = new List<Opportunity>();

        for (Apttus_Approval__Approval_Request__c request : newList) {
            if (oldMap.get(request.Id) != null
                && oldMap.get(request.Id).Apttus_Approval__Approval_Status__c != request.Apttus_Approval__Approval_Status__c
                && request.Apttus_Approval__Approval_Status__c == 'Approved'
                && (request.Apttus_Approval__Step_Name__c.equalsIgnoreCase('ZAB Private Node - Product Management')
                    || request.Apttus_Approval__Step_Name__c.equalsIgnoreCase('ZIA Enterprise License Agreement Approval'))) {
                if (request.Apttus_Approval__Step_Name__c.equalsIgnoreCase('ZAB Private Node - Product Management')) {
                    setZABApprovedProposalIds.add(request.Apttus_QPApprov__ProposalId__c);
                } else if (request.Apttus_Approval__Step_Name__c.equalsIgnoreCase('ZIA Enterprise License Agreement Approval')) {
                    setELAApprovedProposalIds.add(request.Apttus_QPApprov__ProposalId__c);
                }
            }
        }

        for (Apttus_Proposal__Proposal__c proposal : [SELECT Id, Apttus_Proposal__Account__c, Apttus_Proposal__Opportunity__c, Name
                                                        FROM Apttus_Proposal__Proposal__c
                                                       WHERE Id IN :setZABApprovedProposalIds
                                                          OR Id IN :setELAApprovedProposalIds]) {
            if (setZABApprovedProposalIds.contains(proposal.Id) && proposal.Apttus_Proposal__Account__c != null) {
                lstAccountsToBeUpdated.add(new Account(Id = proposal.Apttus_Proposal__Account__c, ZAB_Approved_Account__c = true));
            }

            if (setELAApprovedProposalIds.contains(proposal.Id) && proposal.Apttus_Proposal__Opportunity__c != null) {
                lstOpportunitiesToBeUpdated.add(new Opportunity(Id = proposal.Apttus_Proposal__Opportunity__c, ELA_Approved_Opportunity__c = true, ELA_Approved_Quote_ID__c = proposal.Name));
            }
        }

        try {
            Database.update(lstAccountsToBeUpdated, false);
            Database.update(lstOpportunitiesToBeUpdated, false);
        } catch(Exception ex) {
            System.debug('Apttus Approval Request Trigger: Error occurred while updating account / opportunity. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}