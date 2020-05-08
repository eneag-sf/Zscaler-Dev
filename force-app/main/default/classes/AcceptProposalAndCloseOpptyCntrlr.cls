public class AcceptProposalAndCloseOpptyCntrlr {
    public String salesOrderInternalId { get; set; }
    public String proposalId { get; set; }

    public AcceptProposalAndCloseOpptyCntrlr() {
        this.proposalId = ApexPages.currentPage().getParameters().get('id');
        this.salesOrderInternalId = ApexPages.currentPage().getParameters().get('NSSOId');
    }

    public PageReference pageLoad() {
        PageReference ref;
        Id opportunityId;

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.Closed_Resolution__c, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Id = :this.proposalId LIMIT 1];
        if (proposal != null && proposal.Apttus_Proposal__Opportunity__c != null) {
            opportunityId = proposal.Apttus_Proposal__Opportunity__c;
            
            // Integer countOfOpenCases = Database.countQuery('SELECT Count() FROM Case WHERE (Opportunity_Name__c = :opportunityId OR Proposal__c = :proposalId) AND IsClosed != true');
            // System.debug('>>> countOfOpenCases ' + countOfOpenCases);
            if (proposal.Apttus_Proposal__Opportunity__r.Closed_Resolution__c != null && (proposal.Apttus_Proposal__Opportunity__r.Closed_Resolution__c.equalsIgnoreCase('Requires Sales Ops Fix')
                || proposal.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('draft')
                || proposal.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('approval required')
                || proposal.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('in review'))) {
                // Close the opportunity
                ref = null;
            } else {
                if (proposal.Apttus_Proposal__Opportunity__r.Closed_Resolution__c == null || proposal.Apttus_Proposal__Approval_Stage__c.equalsIgnoreCase('accepted')) {
                    ref = new PageReference('/apex/APTSCU_AcceptProposal?id=' + this.proposalId + '&NSSOId=' + this.salesOrderInternalId);
                } else {
                    ref = redirect();
                }
            }
        }

        return ref;
    }

    @RemoteAction
    public static void closeOpportunity(Id proposalId) {
        Id opportunityId;
        Opportunity opptyToUpdate;

        try {
            Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.StageName FROM Apttus_Proposal__Proposal__c WHERE Id = :proposalId LIMIT 1];

            if (proposal != null && proposal.Apttus_Proposal__Opportunity__c != null 
                && proposal.Apttus_Proposal__Opportunity__r.StageName != label.Stage_6_Closed_Won) {
                opptyToUpdate = new Opportunity(Id = proposal.Apttus_Proposal__Opportunity__c, StageName = label.Stage_6_Closed_Won);
                update opptyToUpdate;
            }
        }
        catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Error occurred while closing the opportunity. Error: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
            throw new AcceptProposalAndCloseOpptyException('Error occurred while closing the opportunity. Please contact your administrator.');
        }
    }

    public PageReference redirect() {
        String retUrl = ZscalerSetting__c.getAll().get('NSSOUrl').Value__c + this.salesOrderInternalId;
        PageReference ref = new PageReference(retUrl);
        
        return ref;
    }

    public class AcceptProposalAndCloseOpptyException extends Exception {}
}