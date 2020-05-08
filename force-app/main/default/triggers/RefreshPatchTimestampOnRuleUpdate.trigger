/*
 * Refreshes timestamp on patch after rule is updated
 */
trigger RefreshPatchTimestampOnRuleUpdate on PatchCriteriaRule__c (after insert, after update, after delete, after undelete) 
{
    Set<Id> patchIds = new Set<Id>();
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
    {
        for(PatchCriteriaRule__c rule : Trigger.new)
        {
            patchIds.add(rule.Patch__c);
        }
    }
    else if(Trigger.isDelete)
    {
        for(PatchCriteriaRule__c rule : Trigger.old)
        {
            patchIds.add(rule.Patch__c);
        }
    }
    PatchRuleHelper.refreshPatchTimestamp(patchIds);
}