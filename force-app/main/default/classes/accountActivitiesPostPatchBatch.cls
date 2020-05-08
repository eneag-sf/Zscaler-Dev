public class accountActivitiesPostPatchBatch implements Database.Batchable<SObject>,Database.Stateful {
    
    private List<Id> recordIds;
    
    public accountActivitiesPostPatchBatch(List<Id> patchIds){
        this.recordIds = patchIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        if(recordIds != null && recordIds.size() > 0){
            return Database.getQueryLocator('Select Id from Account Where Patch__c IN: recordIds');
        }
        else{
            return Database.getQueryLocator('Select Id from Account');
        }
    }
    
    public void execute(Database.BatchableContext context, Account[] accounts) {
        List<Task> tasklst = [Select Id, WhoId, WhatId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Task where AccountId in :accounts and isrecurrence = false];
        for(Task taskRec : tasklst){
            taskRec.Sales_Territory__c = taskRec.Account.Sales_Territory__r.Name;
            taskRec.Territory_Area__c = taskRec.Account.Sales_Territory__r.Area__c;
            taskRec.Territory_Geo__c = taskRec.Account.Sales_Territory__r.Theater__c;
            taskRec.Territory_Type__c = taskRec.Account.Territory_Type__c;
        }
            
        List<Event> eventlst = [Select Id, WhoId, WhatId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Event where AccountId in :accounts and IsChild=false and isrecurrence = false];
        for(Event eventRec : eventlst){
            eventRec.Sales_Territory__c = eventRec.Account.Sales_Territory__r.Name;
            eventRec.Territory_Area__c = eventRec.Account.Sales_Territory__r.Area__c;
            eventRec.Territory_Geo__c = eventRec.Account.Sales_Territory__r.Theater__c;
            eventRec.Territory_Type__c = eventRec.Account.Territory_Type__c;
        }
        TriggerUtility.AcctoActivityTerritoryExecuted();
        update tasklst;
        update eventlst;
    }
    
    public void finish(Database.BatchableContext context) {
        if(!test.isRunningTest()){
            Database.executeBatch(new oppTeamQuoteAndProdConfigShareBatch(), 10);
        }
    }
}