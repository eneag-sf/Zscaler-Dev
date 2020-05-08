@isTest
private class UpdateIncumbentPartnersTest {
    
    @testSetup static void setup(){
        Account account = new Account(Name = 'ZScaler');
	    insert account;
	    
	    Account TestAcc = new Account(Name = 'ZScaler Test');
	    insert TestAcc;
	    
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',AccountId = account.Id,  CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'New Business');
        insert opportunity;
        
        Incumbent_Partner__c IncumbentPartner = new Incumbent_Partner__c(Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller',Account__c = account.Id,Incumbent_Partner_Account__c = account.Id);
        insert IncumbentPartner;
        
    }
    
	private static testMethod void test() {
	    test.startTest();
	    opportunity opportunity = [select Id,Name from Opportunity where Name='Test Opportunity'];
	    Account account = [select Id,Name from Account where Name='ZScaler Test'];
	    Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller',Account__c = account.Id);
        insert OppPartner;
        opportunity.StageName = label.Stage_6_Closed_Won;
        update opportunity; 
        test.stopTest();
	}

}