trigger opportunitySplitTrigger on OpportunitySplit (after insert, after delete) {
    
    if(trigger.isAfter && trigger.isinsert){
        opportunitySplitTriggerHandler.afterInsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isDelete){opportunitySplitTriggerHandler.afterDelete(trigger.old);
    }
}