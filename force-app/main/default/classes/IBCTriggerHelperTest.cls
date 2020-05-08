/*****************************************************************************************
Name: IBCTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for IBCTriggerHelperTest
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            13-Jan-2017    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)   
public class IBCTriggerHelperTest{
    @isTest(SeeAllData=false)
    static void testIBCTriggerHelper(){
        
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.TAM_Email__c = 'abc@abc.com';
        insert acc;
         
        Opportunity opp = new Opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;

        ecosystems_svcs__IBC__c ibc = new ecosystems_svcs__IBC__c();
        ibc.Name = 'Test Data';
        ibc.ecosystems_svcs__Account__c = Acc.id;
        ibc.ecosystems_svcs__Opportunity__c = opp.Id;
        ibc.ecosystems_svcs__salesPlay__c = 'VMO';
        ibc.ecosystems_svcs__extId__c = 1234;
        ibc.ecosystems_svcs__extOwner__c = 'abc@abc.com';
        insert ibc;


        ecosystems_svcs__IBC__c ibc1 = new ecosystems_svcs__IBC__c();
        ibc1.Name = 'Test Data';
        ibc1.ecosystems_svcs__Account__c = Acc.id;
        ibc1.ecosystems_svcs__Opportunity__c = opp.Id;
        ibc1.ecosystems_svcs__salesPlay__c = 'Direct';
        ibc1.ecosystems_svcs__extId__c = 12345;
        ibc1.ecosystems_svcs__extOwner__c = 'abc@abc.co.in';
        insert ibc1;
        TriggerUtility.updateLatestIBConOppReset();

        ibc1.ecosystems_svcs__salesPlay__c = 'Call';
        update ibc1;
        TriggerUtility.updateLatestIBConOppReset();
        delete ibc1;        
        
    }
}