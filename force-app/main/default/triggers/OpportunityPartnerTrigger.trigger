trigger OpportunityPartnerTrigger on Opportunity_Partner__c (before insert,before update,after insert,before delete,after delete) {
    
    /*if(Trigger.IsAfter && Trigger.IsInsert){
        OpportunityPartnerTriggerHandler.onAfterInsert(Trigger.new);
    }*/
    if(Trigger.Isbefore && Trigger.IsInsert){
        OpportunityPartnerTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.Isbefore && Trigger.IsUpdate){
        OpportunityPartnerTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    /*if(Trigger.IsAfter && Trigger.IsDelete){
        OpportunityPartnerTriggerHandler.onBeforeDelete(Trigger.old);
    }*/
}