/*****************************************************************************************
Name: manageAttendeesControllerExtTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for manageAttendeesControllerExt
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)   
public class manageAttendeesControllerExtTest{
    @isTest(SeeAllData=false)
    static void testmanageAttendContExt(){
        test.startTest();
        try{
            Account acc = new account();
            Acc.Name = 'Test Data';
            insert acc;
            contact con = new contact();
            con.FirstName = 'Test';
            con.lastName = 'Contact';
            con.AccountId = acc.Id;
            insert con;
            contact con1 = new contact();
            con1.FirstName = 'Test';
            con1.lastName = 'Contact';
            con1.AccountId = acc.Id;
            insert con1;
            Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
            sci.Date__c = system.today();
            sci.Interaction_With__c = 'Test Data';
            sci.I_am_the__c = 'Organizer';
            sci.Next_Steps__c = 'F2F Meeting';
            sci.Meeting_Notes__c = 'Important conv';
            sci.Account_Name__c = acc.Id;
            insert sci;
            SCI_External_Attendee__c sciAtnd = new SCI_External_Attendee__c();
            sciAtnd.Attendee_Name__c = con.Id;
            sciAtnd.Significant_Customer_Interaction__c = sci.Id;
            insert sciAtnd;
        
            PageReference ref = new PageReference('/apex/manageAttendees?SCID=' +sci.Id);
            
            Test.setCurrentPage(ref);
            manageAttendeesControllerExt extCont = new manageAttendeesControllerExt(new ApexPages.StandardController(new Contact()));
            extCont.srchString = 'test';
            extCont.con.FirstName = 'SCI';
            extCont.con.AccountId = Sci.Account_Name__c;
            extCont.Con.LastName = 'Contact';
            extcont.createAndAddAttendee();
            extcont.searchContacts();
            extcont.conId = con1.Id;
            extCont.addAsSCI();
            extCont.clearSearch();
            extCont.addNewContact();
            extCont.cancel();
            extCont.showPopup();
            extcont.attendeeId = sciAtnd.Id;
            extcont.deleteSCIAttendee();
        }catch(exception e){}
         test.stopTest();
    }


}