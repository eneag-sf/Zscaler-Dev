trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert, after update, before delete) {
    
    OpportunityContactRoleTriggerHelper contactRoleTriggerHelper = new OpportunityContactRoleTriggerHelper();
    
    if(trigger.isInsert && trigger.isAfter){
        contactRoleTriggerHelper.afterInsert(trigger.new);
    }
    
    if(trigger.isupdate && trigger.isAfter){
        contactRoleTriggerHelper.afterUpdate(trigger.new);
    }
    
    if(trigger.isdelete && trigger.isBefore){
        contactRoleTriggerHelper.beforeDelete(trigger.old);
    }
}