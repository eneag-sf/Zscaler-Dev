@isTest
public class DeleteOpportunityPartner_Test {
    static Testmethod void test1(){
        List<Account> accListForInsert = new List<Account>(); 
        Account account = new Account(Name = 'ZScaler');
        accListForInsert.add(account);
        //insert account;
        Account PartnerAccount = new Account(Name = 'Partner', Type='Partner');
        //insert PartnerAccount;
        accListForInsert.add(PartnerAccount);
        insert accListForInsert;
        Id accountId = accListForInsert[0].Id;
        Id OppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',RecordTypeId = OppRecTypeId,AccountId = account.Id,  CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'Existing Customer (Renewal)');
        insert opportunity;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opportunity.Id,Partner_Type__c = 'Reseller',Account__c = account.Id);
        insert OppPartner;  
        DeleteOpportunityPartner.deleteopppart(new List<Opportunity_Partner__c>{OppPartner});
    }
}