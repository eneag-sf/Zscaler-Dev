/**
    Updated BY : Sateesh U
    This class is used to get the Opportunity Id when click on 'Add / remove' on opportunity and when click on 'Edit' on partner record.
**/
public class opportunityPartnersController {
    
    public Opportunity_Partner__c oppPartner;
    public string opportunityId {get;set;}
    public opportunityPartnersController(ApexPages.StandardController stdController) {
        this.oppPartner = (Opportunity_Partner__c)stdController.getRecord();
        List<Opportunity_Partner__c> oppPartners = [Select Id, Opportunity__c from Opportunity_Partner__c Where Id =: this.oppPartner.Id];
        if(!oppPartners.isEmpty()){
            opportunityId = oppPartners[0].Opportunity__c;
        }
        else{
            if(!String.isBlank(system.currentPageReference().getParameters().get('oppId'))){
                opportunityId = system.currentPageReference().getParameters().get('oppId');
            }
        }
    }
}