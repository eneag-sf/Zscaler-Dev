trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete) {
    /*if(trigger.isAfter && trigger.isInsert){
        if(!TriggerUtility.isActivityleadterritoryEventinsertExecuted()){
            captureActivityOnLead.assignleadterritoryEvent(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }
    if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.isActivityleadterritoryEventupdateExecuted()){
            captureActivityOnLead.assignleadterritoryEvent(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }*/
    if(trigger.isBefore && trigger.isUpdate){
        if(!TriggerUtility.isGroove2SCIcodeexecuted){
            system.debug('before calling EventTriggerhelper.BeforeUpdateEventMethod in before update event');
            EventTriggerhelper.BeforeUpdateEventMethod(trigger.new, trigger.Oldmap);
        }
        
    }
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(!TriggerUtility.isGroove2SCIcodeexecuted){
            system.debug('before calling EventTriggerhelper.AutocreateSCI ');
            EventTriggerhelper.AutocreateSCI(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
        
    }
    if(trigger.isBefore && trigger.isDelete){
        //if(!TriggerUtility.isActivityleadterritoryEventinsertExecuted()){
            system.debug('before calling EventTriggerhelper.AutocreateSCI ');
            EventTriggerhelper.DeleteSCI(trigger.old,trigger.OldMap);
        //}
    }
}