trigger SurveyTrigger on Survey__c (after delete, after insert, after undelete, 
                                    after update, before delete, before insert, before update) 
{
    
    if(!(SurveyTriggerHelper.skipTrigger))
    {
        
        SurveyTriggerHelper handler = new SurveyTriggerHelper();
        if(Trigger.isInsert && Trigger.isBefore)
        {
            handler.OnBeforeInsert(Trigger.new);
        }
        
        if(Trigger.isInsert && Trigger.isAfter)
        {
            handler.OnAfterInsert(Trigger.new);
        }
        
        if(Trigger.isUpdate && Trigger.isBefore)
        {
            handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
        
        if(Trigger.isUpdate && Trigger.isAfter)
        {
            handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        
        if(Trigger.isDelete && Trigger.isBefore)
        {
            handler.onBeforeDelete(Trigger.oldMap);
        }
        
        if(Trigger.isDelete && Trigger.isAfter)
        {
            handler.onAfterDelete(Trigger.oldMap);
        }
        
        if(Trigger.isUndelete && Trigger.isAfter)
        {
            handler.onAfterUndelete(Trigger.newMap);
        }
    }
}