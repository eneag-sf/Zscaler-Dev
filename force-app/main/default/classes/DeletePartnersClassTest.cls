@isTest
public class DeletePartnersClassTest {
    @testSetup static void setup(){
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Add On)');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller');
        insert OppPartner;
        
        Opportunity_Partner__c OppPrimaryPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller');
        insert OppPrimaryPartner;
    }
    
    public static testMethod void testPartnerPrimary(){
        Opportunity_Partner__c oppPartner = [select Id,Is_Primary__c,Opportunity__c from Opportunity_Partner__c where Is_Primary__c = true limit 1];
        DeletePartnersClass.DeletePartner(oppPartner.Id);
    }
    
     public static testMethod void testPartnerNonPrimary(){
        Opportunity_Partner__c oppPartner = [select Id,Is_Primary__c,Opportunity__c from Opportunity_Partner__c where Is_Primary__c = false limit 1];
        DeletePartnersClass.DeletePartner(oppPartner.Id);
    }
}