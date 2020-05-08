@isTest
private class TechnologyPartnerTriggerHandlerTest {
    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        insert acc;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        
        Technology_Partner__c tp = new Technology_Partner__c();
        tp.opportunity__c=opp.id;
        tp.IsPrimary__c = true;
        insert tp;
        
        
    }
    private static testMethod void test() {
        opportunity opp =[select id,name from opportunity limit 1];
        List<Technology_Partner__c> techpartnerlist = [Select id,name,Account__c,Opportunity__c,Opportunity__r.id,IsPrimary__c from Technology_Partner__c where IsPrimary__c=true and Opportunity__c =:opp.id limit 1];
        TechnologyPartnerTriggerHandler.onBeforeInsert(techpartnerlist);
        List<Technology_Partner__c> oldlist = new List<Technology_Partner__c>();
        oldlist.add(techpartnerlist[0]);
        update oldlist;
        //TechnologyPartnerTriggerHandler.onbeforeupdate(techpartnerlist,oldlist);
        
    }
    
}