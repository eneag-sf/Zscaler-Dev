@isTest
public class PatchRealignJobTest
{
    @isTest
    static void test()
    {
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='acme', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping;
        PatchFieldMapping__c mapping2 = new PatchFieldMapping__c(Name='acme acc', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping2;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true);
        insert patch;
        Lead lead = new Lead(LastName='acme', Company='acme', Patch__c=patch.Id, IsConverted=false);
        Insert lead;
        lead.PatchLocked__c = true;
        lead.Patch__c=patch.Id;
        update lead;
        Account acc =new Account(Name='acme acc');
        Insert acc;
        acc.Patch__c = patch.Id;
        acc.PatchLocked__c = true;
        update acc;
        Test.startTest();
        PatchRealignJob job = new PatchRealignJob(new List<Id> {patch.Id}, new List<Schema.SObjectType> { Schema.Lead.SObjectType, Schema.Account.SObjectType, Schema.Opportunity.SObjectType });
        Database.executeBatch(job, 1);
        PatchRealignJob job2 = new PatchRealignJob(new List<Id> {acc.Id}, new List<Schema.SObjectType> { Schema.Opportunity.SObjectType }, true);
        Database.executeBatch(job2, 1);
        Test.stopTest();
    }
}