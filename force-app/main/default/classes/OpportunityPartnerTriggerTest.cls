@isTest
private class OpportunityPartnerTriggerTest {
	
    private static testMethod void testInsert() {
        Account acc = creatAccount ();
        Opportunity opp = createOpportunity (acc.Id);
        Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Tech Partner',true);
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',true);
	}
    
	private static testMethod void testUpdate() {
        
        Account acc = creatAccount ();
        Opportunity opp = createOpportunity (acc.Id);
        Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,acc.id,'Tech Partner',false);
        OppDistributorPartner.Is_Primary__c = true;
        update OppDistributorPartner;
        
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,acc.id,'Reseller',false);
        OppResellerPartner.Is_Primary__c = true;
        update OppResellerPartner;
	}
	
	public static opportunity createOpportunity (string accountId) {
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = Label.Stage_1_Alignment /*'0 - Initial Prospecting'*/;
        opp.closedate =  Date.today();
        opp.accountId = accountId;
        insert opp;
        return opp;
    }
    
    private static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        insert acc;
        return acc;
    }
    
    public static Opportunity_Partner__c createPartner (string oppId,string accountId, string partnerType , boolean isPrimary) {
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
        OppPartner.Is_Primary__c = isPrimary;
        OppPartner.Opportunity__c = oppId;
        OppPartner.Partner_Type__c = partnerType;
        OppPartner.Account__c = accountId;
        
        insert OppPartner;
        return OppPartner;
    }

}