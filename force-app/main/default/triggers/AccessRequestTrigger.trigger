trigger AccessRequestTrigger on Access_Request__c (before update, after update) {
    
    if(Trigger.isUpdate && Trigger.isBefore){
        AccessRequestTriggerHandler.beforeUpdate(trigger.newMap, trigger.oldMap);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        AccessRequestTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
    }
}