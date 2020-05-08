/*****************************************************************************************
Name: SCITriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for SCITriggerHelperTest
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            13-Jan-2017    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)   
public class SCITriggerHelperTest{
    @isTest(SeeAllData=false)
    static void testSCItriggerHelper(){
        
        test.startTest();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.TAM_Email__c = 'abc@abc.com';
        insert acc;
         
        Opportunity opp = new Opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;

        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci.Date__c = system.today();
        sci.Interaction_With__c = 'Test Data';
        sci.I_am_the__c = 'Organizer';
        sci.Next_Steps__c = 'F2F Meeting';
        sci.Meeting_Notes__c = 'Important conv';
        sci.Account_Name__c = acc.Id;
        sci.Primary_Topic_Covered__c = 'Solution Architecture';
        sci.Opportunity_Name__c = opp.Id;
        insert sci;
        TriggerUtility.SCIOppUpdateReset();
        Significant_Customer_Interaction__c sci1 = new Significant_Customer_Interaction__c();
        sci1.Date__c = system.today();
        sci1.Interaction_With__c = 'Test Data';
        sci1.I_am_the__c = 'Organizer';
        sci1.Next_Steps__c = 'F2F Meeting';
        sci1.Meeting_Notes__c = 'Important conv';
        sci1.Account_Name__c = acc.Id;
        sci1.Primary_Topic_Covered__c = 'Test';
        sci1.Opportunity_Name__c = opp.Id;
        insert sci1;
        TriggerUtility.SCIOppUpdateReset();
        sci.Primary_Topic_Covered__c = 'Test';
        update sci;
        TriggerUtility.SCIOppUpdateReset();
        sci1.Primary_Topic_Covered__c = 'Solution Architecture';
        update sci1;
        TriggerUtility.SCIOppUpdateReset();
        delete sci1;
        test.stopTest();

    }
}