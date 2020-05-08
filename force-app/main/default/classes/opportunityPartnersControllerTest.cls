@isTest
public class opportunityPartnersControllerTest {
    
    @testSetup static void setup(){
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Add On)');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller');
        insert OppPartner;
    }
    
    public static testMethod void TestController(){
        Opportunity_Partner__c Partner = [select Id,Opportunity__c from Opportunity_Partner__c limit 1];
        ApexPages.StandardController stdPartner = new ApexPages.StandardController(Partner);
        opportunityPartnersController controller = new opportunityPartnersController(stdPartner);
    }
}