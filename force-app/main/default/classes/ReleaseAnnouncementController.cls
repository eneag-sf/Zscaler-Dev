/*****************************************************************************************
Name: ReleaseAnnouncementController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
This class is fetch all the announcement and show on the home page.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            13-Oct-2015    Initial Development
******************************************************************************************/ 

public class ReleaseAnnouncementController {
    
    public list<Release_Announcement__c> relAnnounceList {get;set;}
    public ReleaseAnnouncementController(){
        relAnnounceList = new list<Release_Announcement__c>(); 
        relAnnounceList = [select Announcement__c from Release_Announcement__c Where Active__c =: True ORDER BY CreatedDate DESC limit 10];
    }
}