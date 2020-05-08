trigger genericCampaignMemberTrigger on CampaignMember (before insert, before update, after insert, after update ) {
    if(trigger.isbefore && (trigger.isUpdate || trigger.isInsert)){
        list<id> conIdlist = new list<Id>();
        list<id> leadIdlist = new list<Id>();
        map<id, id> conleadIdterritoryIdMap = new map<Id, Id>();
        for(CampaignMember camp : trigger.new){
            if(camp.ContactId != null)
                conIdlist.add(camp.ContactId);
            if(camp.leadId != null)
                leadIdlist.add(camp.leadId);
        }
        
        if(!leadIdlist.isEmpty()){
            for(lead le : [Select Id, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
                conleadIdterritoryIdMap.put(le.Id, Le.Patch__r.PatchTeam__c);
            }
        }
        
        if(!conIdlist.isEmpty()){
            for(Contact con : [Select Id, Patch__c, Patch__r.PatchTeam__c from Contact where ID IN: conIdlist AND Patch__c != null]){
                conleadIdterritoryIdMap.put(con.Id, con.Patch__r.PatchTeam__c);
            }
        }
        
        for(CampaignMember camp : trigger.new){
            if(camp.ContactId != null)
                camp.Territory__c = conleadIdterritoryIdMap.get(camp.ContactId);
            if(camp.leadId != null)
                camp.Territory__c = conleadIdterritoryIdMap.get(camp.leadId);
        }
    }

    if(trigger.isAfter && trigger.isInsert){
        if(CampaignMemberTriggerHelper.skipTrigger == false)
        {
            if(!TriggerUtility.isUpdateLeadContactForCampExecuted())
            {
                CampaignMemberTriggerHelper.updateLeadContactForCamp(trigger.new);
                CampaignMemberTriggerHelper.skipTrigger = true;
            }
            
        }
        
    }
}