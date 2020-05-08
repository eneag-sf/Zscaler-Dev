trigger NFRLicenceTrigger on NFR__c (before insert, before update, after insert, after update) {
    if(trigger.isInsert){
        if(Trigger.isAfter){
            NFRLicenceTriggerHandler.OnAfterInsert(trigger.New);
        }
        if(Trigger.isBefore){
            NFRLicenceTriggerHandler.onBeforeInsert(trigger.New);
        }
    }
    if(trigger.isUpdate){
        if(Trigger.isAfter){
            NFRLicenceTriggerHandler.OnAfterUpdate(trigger.New, Trigger.OldMap);
        }
        if(Trigger.isBefore){
            NFRLicenceTriggerHandler.OnBeforeUpdate(trigger.New, Trigger.OldMap);
        }
    }
}