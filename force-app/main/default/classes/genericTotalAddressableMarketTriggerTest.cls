/*****************************************************************************************
Name: ManageWhiteSpacekeyContactsTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for genericTotalAddressableMarketTrigger Trigger.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            18-July-2016    Initial Development
******************************************************************************************/ 
@isTest(SeeAllData=false)   
public class genericTotalAddressableMarketTriggerTest{
    static testMethod void testTotalAddMarktTrigger(){
        test.startTest();
            Account acc = new account();
            Acc.Name = 'Test Data';
            insert acc;
            contact con = new contact();
            con.FirstName = 'Test';
            con.lastName = 'Contact';
            con.AccountId = acc.Id;
            //con.Head_of_IT__c = true;
            //con.Head_of_networking__c = true;
            //con.Procurement_Contact__c = true;
            //con.Head_of_Security__c = true;
            //con.Budget_Authority__c = true;
            insert con;
            
            
            Whitespace__c whiteSpace = new Whitespace__c();
            whiteSpace.Account_Name__c = acc.Id;
            whiteSpace.No_of_Locations__c = 10;
            whiteSpace.No_of_Egress_Points__c = 10;
            //whiteSpace.Head_of_IT__c = con.Id;
            //whiteSpace.Head_of_Security__c = con.Id;
            //whiteSpace.Head_of_networking__c = con.Id;
            //whiteSpace.Procurement_Contact__c = con.Id;
            //whiteSpace.Budget_Authority__c = con.Id;
            whiteSpace.state__c = 'Test Data';
            insert whiteSpace;
            TriggerUtility.conWhiteSpaceUpdateReset();
            
            contact con1 = new contact();
            con1.FirstName = 'Test';
            con1.lastName = 'Contact';
            con1.AccountId = acc.Id;
            con1.Head_of_IT__c = true;
            con1.Head_of_networking__c = true;
            con1.Procurement_Contact__c = true;
            con1.Head_of_Security__c = true;
            con1.Budget_Authority__c = true;
            insert con1;
            
            contact con2 = new contact();
            con2.FirstName = 'Test';
            con2.lastName = 'Contact';
            con2.AccountId = acc.Id;
            insert con2;
            
            TriggerUtility.conWhiteSpaceUpdateReset();
            //whiteSpace.Head_of_IT__c = con2.Id;
            //whiteSpace.Head_of_Security__c = con2.Id;
            //whiteSpace.Head_of_networking__c = con2.Id;
            //whiteSpace.Procurement_Contact__c = con2.Id;
            //whiteSpace.Budget_Authority__c = con2.Id;
            //Update whiteSpace;
            
            TriggerUtility.conWhiteSpaceUpdateReset();
            con.Head_of_IT__c = false;
            con.Head_of_networking__c = false;
            con.Procurement_Contact__c = false;
            con.Head_of_Security__c = false;
            con.Budget_Authority__c = false;
            Update con;
            TriggerUtility.conWhiteSpaceUpdateReset();
            
            con.Head_of_IT__c = true;
            con.Head_of_networking__c = true;
            con.Procurement_Contact__c = true;
            con.Head_of_Security__c = true;
            con.Budget_Authority__c = true;
            Update con;
            
        test.stopTest();
    }
}