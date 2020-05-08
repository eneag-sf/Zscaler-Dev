trigger genericDealRegTrigger  on Deal_Reg__c (before insert, before update, after insert, after update) {
    if(trigger.isBefore && trigger.isInsert && !TriggerUtility.isDealRegBeforeInsertExecuted()){
        DealRegTriggerHelper.beforeInsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isDealRegAfterInsertExecuted()){
        DealRegTriggerHelper.afterInsert(trigger.new);
    }

    if (Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isDealRegAfterUpdateExecuted()) {
        DealRegTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.New);
    }

    if (Trigger.isBefore && Trigger.isUpdate && !TriggerUtility.isDealRegBeforeUpdateExecuted()) {
        DealRegTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.New);
    }
}