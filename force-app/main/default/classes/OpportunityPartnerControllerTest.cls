@isTest
public class OpportunityPartnerControllerTest {
    
    @testSetup static void setup() {
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc1;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Reseller',Account__c = acc.Id);
        insert OppPartner;
        
        Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'POV',Account__c = acc.Id);
        insert OppPartner1;
    }
    
    @isTest static void testOpportunityPartner(){
        Test.startTest();
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        OpportunityPartnerController.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerController.GetOpportunity(Opp.Id);
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        OpportunityPartnerController.UpdatePrimaryPartner(OppPartner.Id,'Reseller',Opp.Id);
        
        OpportunityPartnerController.UuncheckPrimaryPartner(OppPartner.Id, 'Reseller',Opp.Id );
        OpportunityPartnerController.DeletePartnerRec(OppPartner.Id);
        Test.stopTest();
    }
    
    @isTest static void testOpportunityPartner1(){
        Test.startTest();
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c != 'Reseller' limit 1];
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        OpportunityPartnerController.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerController.GetOpportunity(Opp.Id);
        
        OpportunityPartnerController.updatePartnerProgram(OppPartner.Id, 'Partner Summit',Opp.Id );
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'POV');
        OpportunityPartnerController.UpdatePrimaryPartner(OppPartner.Id,'POV',Opp.Id);
        
        OpportunityPartnerController.UuncheckPrimaryPartner(OppPartner.Id, 'POV',Opp.Id );
       
        OpportunityPartnerController.DeletePartnerRec(OppPartner.Id);
        Test.stopTest();
    }
        
}