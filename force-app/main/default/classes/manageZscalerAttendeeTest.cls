/*****************************************************************************************
Name: manageZscalerAttendeeTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for manageZscalerAttendee Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)
private class manageZscalerAttendeeTest{
    @isTest(SeeAllData=false)
    static void testAddZscalerAttendee(){
        test.startTest();
        Account acc = new account();
        Acc.Name = 'Test Data';
        insert acc;
        list<Significant_Customer_Interaction__c> sciList = new list<Significant_Customer_Interaction__c>();
            Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
            sci.Date__c = system.today();
            sci.Interaction_With__c = 'Test Data';
            sci.I_am_the__c = 'Organizer';
            sci.Next_Steps__c = 'F2F Meeting';
            sci.Meeting_Notes__c = 'Important conv';
            sci.Account_Name__c = acc.Id;
            sciList.add(sci);
            Significant_Customer_Interaction__c sci2 = new Significant_Customer_Interaction__c();
            sci2.Date__c = system.today();
            sci2.Interaction_With__c = 'Test Data';
            sci2.I_am_the__c = 'Attendee';
            sci2.Next_Steps__c = 'F2F Meeting';
            sci2.Meeting_Notes__c = 'Important conv';
            sci2.Account_Name__c = acc.Id;
            sciList.add(sci2);
            insert sciList;
            TriggerUtility.manageZscalerAttendeeReset();
            sciList[0].I_am_the__c = 'Attendee';
            sciList[1].I_am_the__c = 'Organizer';
            update sciList;
        test.stopTest();
    }
}