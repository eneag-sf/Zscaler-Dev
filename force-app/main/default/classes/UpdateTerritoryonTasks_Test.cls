@isTest
public class UpdateTerritoryonTasks_Test{
    static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        Task t1 = new Task(WhoId = lead.Id,Call_Disposition__c = 'meeting scheduled');
        Task t2 = new Task(WhoId = con.Id,Call_Disposition__c = 'meeting scheduled');
        List<Task> tsklst = new List<Task>();
        tsklst.add(t1);
        tsklst.add(t2);
        insert tsklst;
        UpdateTerritoryonTasks batch;
        date sd = Date.Today();
        date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        String NonRecurringTaskBatchQuery ='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from Task where IsRecurrence=False and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate';
        batch = new UpdateTerritoryonTasks(startdate,enddate,NonRecurringTaskBatchQuery);
        Database.executeBatch(batch,200);
    }

}