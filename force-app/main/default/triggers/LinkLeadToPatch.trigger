/*
 * Links lead to a matching patch on new lead insert or certain fields update.
 */
trigger LinkLeadToPatch on Lead (after insert, after update, before delete)
{
    List<Id> leadNeedsPatchAssign = new List<Id>();
    if(leadTriggerHelper.skipTrigger == false)
    {
    if(Trigger.isInsert)
    {
        for(Lead ld : Trigger.new)
        {
            leadNeedsPatchAssign.add(ld.Id);
        }
    }
    else if(Trigger.isUpdate)
    {
        for(Lead ld : Trigger.new)
        {
            if(!PatchRuleEngineStarter.isInPipeline(ld.Id))
            {
                Lead oldLead = Trigger.oldMap.get(ld.Id);
                if(!ld.IsConverted)
                {
                    PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(ld);
                    PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldLead);
                    if(ld.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget))
                    {
                        leadNeedsPatchAssign.add(ld.Id);
                    }
                }
            }
        }
    }
    }
    if(leadNeedsPatchAssign.size() > 0)
    {
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(leadNeedsPatchAssign);
        starter.start();
    }

    List<Id> ZPAInteractiveList = new List<Id>();
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
    {
        if(Trigger.isInsert)
        {
            for(Lead led : Trigger.new)
            {
                if(led.ZPA_Interactive_Lead__c)
                {
                    ZPAInteractiveList.add(led.Id);
                }
            }
        }
        else
        {
            for(Lead led : Trigger.new)
            {

                if(led.ZPA_Interactive_Lead__c != Trigger.oldMap.get(led.Id).ZPA_Interactive_Lead__c)
                {
                    ZPAInteractiveList.add(led.Id);
                }
            }
        }
    }

    if(ZPAInteractiveList.size() > 0)
    {
        System.enqueueJob(new ZPAInteractiveRequest('Lead',ZPAInteractiveList));
    }

	if(leadTriggerHelper.skipTrigger == false)
    {

    if(trigger.isUpdate && trigger.isAfter){
        map<id, id> leadIdTerritoryIdMap = new map<Id, Id>();
        map<Id, Id> leadAccManagerIdMap = new map<Id, Id>();
        for(lead le : trigger.new){
            if(le.Territory__c != trigger.oldMap.get(le.Id).Territory__c)
                leadIdTerritoryIdMap.put(le.id, Le.Territory__c);
            if(le.Lead_Development__c != null && trigger.OldMap.get(le.Id).Lead_Development__c != le.Lead_Development__c)
                leadAccManagerIdMap.put(le.Id, le.Lead_Development__c);
        }
        if(leadIdTerritoryIdMap != null && leadIdTerritoryIdMap.keySet().Size() > 0)
            CampaignMemberPatchManager.getPatchInformation(leadIdTerritoryIdMap,'Lead');

        if(!TriggerUtility.isCaseCreationForLeadTerrirtory())
           leadTriggerHelper.caseCreationForDefaultTerrirtory(trigger.new, trigger.oldMap);
        leadTriggerHelper.updateDealRegAfterLeadConversion(trigger.OldMap, trigger.NewMap);

        if(!System.isFuture() && !System.isBatch() && leadAccManagerIdMap.size() > 0)
        leadTriggerHelper.changeLeadOwnership(leadAccManagerIdMap);

    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        if (!TriggerUtility.isUpdateLeadSalesTeamEmailFieldsExecuted()) {
            leadTriggerHelper.updateSalesTeamEmailFields(Trigger.oldMap, Trigger.newMap);
        }

        // Commented this code as the logic should not be based on Bizible Account field 
        // if (!TriggerUtility.isUpdateLeadNoOfEmployeesExecuted()) {
        //     leadTriggerHelper.updateNumberOfEmployees(Trigger.new);
        // }
    }

    if(trigger.isBefore && trigger.isDelete)
        leadTriggerHelper.dealRegValidation(trigger.oldMap);
    }
    leadTriggerHelper.skipTrigger = true;
}