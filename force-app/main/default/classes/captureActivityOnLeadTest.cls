/*****************************************************************************************
Name: captureActivityOnLeadTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for captureActivityOnLead Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/


@isTest(SeeAllData=false)
private class captureActivityOnLeadTest{

    @isTest(SeeAllData=false)
    static void testCaptureActivityDetail(){
        test.startTest();
        ZscalerSetting__c zs = new ZscalerSetting__c();
         zs.Name = 'CampaignExceptions1';
         zs.Value__c = '70170000000cGzmAAE';
         insert zs;

        ZscalerSetting__c zs1 = new ZscalerSetting__c();
         zs1.Name = 'CampaignExceptions2';
         zs1.Value__c = '70170000000cGzmAAE';
         insert zs1;

        Contact con = new Contact(
                          FirstName = 'Robin',
                          LastName = 'Koehler'
                          //AccountId = acct.Id
                          );
        insert con;



        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry');

        insert lead;

        Campaign camp = new Campaign(
                            Name = 'Test',
                            IsActive = TRUE);
        insert camp;

        CampaignMember m1 = new CampaignMember(
            ContactId = con.Id,
            CampaignId = camp.Id
        );
        insert m1;

        CampaignMember m2 = new CampaignMember(
            LeadId = lead.Id,
            CampaignId = camp.Id
        );
        insert m2;

        List<Task> tasks = new List<Task>();
        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(),
        Status='In Progress')
        );

        tasks.add(new Task(
        ActivityDate = Date.today().addDays(7),
        Subject='call',
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        Status='In Progress')
        );
        insert tasks;
        
        List<Event> events = new List<Event>();
        events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='call',
        WhoId = con.Id,
        OwnerId = UserInfo.getUserId(), 
        DurationInMinutes = 90)
        );

        events.add(new Event(
        ActivityDate = Date.today().addDays(7),
        ActivityDateTime = Date.today().addDays(7),
        Subject='call',
        WhoId = lead.Id,
        OwnerId = UserInfo.getUserId(),
        DurationInMinutes = 90));
        insert events;
        test.stopTest();

    }
}