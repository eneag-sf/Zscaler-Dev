trigger TechnologyPartnerTrigger on Technology_Partner__c (before insert,before update,after insert) {
    
    if(Trigger.Isbefore && Trigger.IsInsert){
        TechnologyPartnerTriggerHandler.onBeforeInsert(Trigger.new);
    } 
    if(Trigger.Isbefore && Trigger.IsUpdate){
        TechnologyPartnerTriggerHandler.onbeforeupdate(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.IsAfter && Trigger.IsInsert){
        TechnologyPartnerTriggerHandler.onAfterInsert(Trigger.new);
    }
}