/*****************************************************************************************
Name: ReleaseAnnouncementControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for ReleaseAnnouncementController Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            13-Oct-2015    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)
private class ReleaseAnnouncementControllerTest{
    @isTest(SeeAllData=false)
    static void testReleaseAnnouncementController(){
     test.startTest();
        Release_Announcement__c rel = new Release_Announcement__c ();
        rel.active__c = true;
        rel.Announcement__c  = 'Test Data';
        insert rel;
        PageReference ref = new PageReference('/apex/ReleaseAnnouncement');
        Test.setCurrentPage(ref);
        ReleaseAnnouncementController cont = new ReleaseAnnouncementController();
      test.stopTest();
    }
}