@isTest
public class opportunityShareEngineStarterTest {
   	@TestSetup static void setuprecs(){     
        
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
		TriggerUtility.prospectTypeUpdExecuted();
		
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc.Id, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp2;
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc.Id, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp3;
        
        list<Opportunity_Share__c> oppshareList = new list<Opportunity_Share__c>();
        Opportunity_Share__c oppShare = new Opportunity_Share__c(Opportunity_Id__c =opp.Id,Status__c='Ready To Share');
        oppshareList.add(oppShare);
        Opportunity_Share__c oppShare2 = new Opportunity_Share__c(Opportunity_Id__c =opp2.Id,Status__c='Ready To Share');
        oppshareList.add(oppShare2);
        Opportunity_Share__c oppShare3 = new Opportunity_Share__c(Opportunity_Id__c =opp3.Id,Status__c='Ready To Share');
        oppshareList.add(oppShare3);
        insert oppshareList;
    
   	}
    static testmethod void test1() {
		Test.startTest();
        user usr = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        Opportunity opp = [select id from Opportunity where Name = 'Test opportunity'];
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id);
        //insert oppSplit; 
        //delete oppSplit;
        test.stopTest();
    }
    
        static testmethod void test2() {
        test.startTest();
        List<Opportunity_Share__c> oppShareRecords = [Select Id,
                                                      Opportunity_Id__c,
                                                      Status__c
                                                      from
                                                      Opportunity_Share__c ];
        List<Id> oppShareIds = new List<Id>();
        for(Opportunity_Share__c oppShareRec : oppShareRecords){
                oppShareIds.add(oppShareRec.Id);
        }
        if(!oppShareIds.isEmpty()){
            opportunityShareEngineStarter.InnerJob Incls= new opportunityShareEngineStarter.InnerJob(oppShareIds);
            OpportunityShareTriggerHandler.shareQuoteAndProdConfigToOppTeamMembers(oppShareIds);
        }
        test.stopTest();
    }
}