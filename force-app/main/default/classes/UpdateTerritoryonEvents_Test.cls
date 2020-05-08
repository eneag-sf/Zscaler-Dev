@isTest
public class UpdateTerritoryonEvents_Test{
    static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        
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
        
        
        UpdateTerritoryonEvents batch;
        date sd = Date.Today();
        date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        String NonRecurringEventBatchQuery= 'Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from event where IsRecurrence=false and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate';
        batch = new UpdateTerritoryonEvents(startdate,enddate,NonRecurringEventBatchQuery);
        Database.executeBatch(batch,200);
    }

}