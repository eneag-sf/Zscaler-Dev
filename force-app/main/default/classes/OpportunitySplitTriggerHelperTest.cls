/*****************************************************************************************
Name: OpportunitySplitTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for OpportunitySplitTriggerHelper class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Oct-2015    Initial Development
******************************************************************************************/ 
@isTest(SeeAllData=false)
private class OpportunitySplitTriggerHelperTest {
    static testmethod void testInsert() {
        
        user usr = [select id from user where IsActive = true AND Profile.Name = 'System Administrator' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        test.startTest();
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id);
        insert oppSplit;
        //delete oppSplit;
        test.stopTest();
    }
    
}