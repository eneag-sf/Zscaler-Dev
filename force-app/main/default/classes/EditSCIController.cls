public with sharing class EditSCIController {

	public Significant_Customer_Interaction__c sci { get; set; }
    public Id sciId;
    public Id newExternalAttendeeId;

    public EditSCIController() {
        sciId = ('' != ApexPages.currentPage().getParameters().get('id') ? ApexPages.currentPage().getParameters().get('id') : null);
        newExternalAttendeeId = ('' != ApexPages.currentPage().getParameters().get('newExternalAttendeeId') ? ApexPages.currentPage().getParameters().get('newExternalAttendeeId') : null);
        System.debug(ApexPages.currentPage().getParameters());
    }

    public EditSCIController(ApexPages.StandardController con) {
        sciId = con.getId();
        newExternalAttendeeId = ('' != ApexPages.currentPage().getParameters().get('newExternalAttendeeId') ? ApexPages.currentPage().getParameters().get('newExternalAttendeeId') : null);
    }

    public PageReference pageLoad() {
        Id patchTeamId;
        String url;
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');

        try {
            if (null != sciId) {
                 sci = [SELECT Id, Name, RecordTypeId, RecordType.Name, Opportunity_Name__c, 
                               Interaction_With__c, Date__c, Next_Steps__c, Meeting_Notes__c, 
                               Area_of_Influence__c, Account_Name__c, Campaign__c, Lead__c, Deal_Reg__c,
                               I_am_the__c, Participation__c, Primary_Topic_Covered__c, OwnerId, Account_Name__r.Name,
                               Current_POC_Phase__c, Age_of_POC__c, POC_Start_Date__c, POC_Phases__c, 
                               POC_End_Date__c, Evaluation_Progress_Notes__c, Lead__r.Territory__c,
                               Opportunity_Name__r.Patch__c, Opportunity_Name__r.Patch__r.PatchTeam__c,
                               Account_Name__r.Sales_Territory__c, Deal_Reg__r.Sales_Territory__c
                          FROM Significant_Customer_Interaction__c 
                         WHERE Id = :sciId LIMIT 1];
                System.debug('>>>> sciId: ' + sciId);
                System.debug('>>>> sci: ' + sci.Account_Name__c);
                System.debug('>>>> sci: ' + sci.Account_Name__r.Sales_Territory__c);
                if (null != sci.Opportunity_Name__c
                    && null != sci.Opportunity_Name__r.Patch__c
                    && null != sci.Opportunity_Name__r.Patch__r.PatchTeam__c) {
                    System.debug(sci.Opportunity_Name__r.Patch__r.PatchTeam__c);
                    patchTeamId = sci.Opportunity_Name__r.Patch__r.PatchTeam__c;
                } else if (null != sci.Lead__c
                    && null != sci.Lead__r.Territory__c) {
                    System.debug(sci.Lead__r.Territory__c);
                    patchTeamId = sci.Lead__r.Territory__c;
                } else if (null != sci.Deal_Reg__c
                    && null != sci.Deal_Reg__r.Sales_Territory__c) {
                    System.debug(sci.Deal_Reg__r.Sales_Territory__c);
                    patchTeamId = sci.Deal_Reg__r.Sales_Territory__c;
                } else if (null != sci.Account_Name__c
                    && null != sci.Account_Name__r.Sales_Territory__c) {
                    System.debug(sci.Account_Name__r.Sales_Territory__c);
                    patchTeamId = sci.Account_Name__r.Sales_Territory__c;
                }

                url = '/apex/ManageSCI?id=' + sci.Id + '&edit=true&retUrl=' + retUrl + '&accountId=' 
                            + sci.Account_name__c + '&opportunityId=' + sci.Opportunity_Name__c 
                            + '&dealRegId=' + sci.Deal_Reg__c + '&leadId=' + sci.Lead__c 
                            + '&campaignId=' + sci.Campaign__c + '&patchTeamId=' + patchTeamId;
                url = url.replaceAll('null', '');
            } else if (null == sciId
                && null != newExternalAttendeeId) {
                Contact externalAttendee = [SELECT Id, AccountId, Account.Sales_Territory__c FROM Contact WHERE Id = :newExternalAttendeeId LIMIT 1];
                System.debug(externalAttendee);

                if (null != externalAttendee.AccountId
                    && null != externalAttendee.Account.Sales_Territory__c) {
                    patchTeamId = externalAttendee.Account.Sales_Territory__c;
                }

                url = '/apex/ManageSCI?edit=false&retUrl=' + retUrl + '&accountId=' 
                            + externalAttendee.AccountId + '&opportunityId=' 
                            + '&dealRegId=&leadId=&campaignId=&patchTeamId=' + patchTeamId
                            + '&newExternalAttendeeId=' + newExternalAttendeeId + '&step=4';
                url = url.replaceAll('null', '');
            }

            PageReference redirectTo = new PageReference(url);
            redirectTo.setRedirect(true);
            return redirectTo;
         } catch(Exception e) {
             System.debug(e.getMessage());
         }
        return null;
    }
}