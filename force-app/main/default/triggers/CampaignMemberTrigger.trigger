/*
 * Author : Raghu Manchiraju
 * Date : 01/16/2018
 * Change : User added to ZPA FeVa Campaign need to added to ZPA Provisioning Request. 
 * 
 * 
 */ 

trigger CampaignMemberTrigger on CampaignMember (before insert, before update, after insert, after update ) {
    if(CampaignMemberTriggerHelper.cmTriggerSkip == false)
    {
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
            for(lead le : [Select Id, Territory__c,Territory__r.Name, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
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
    }
        
    if(CampaignMemberTriggerHelper.cmTriggerSkip == false)
    {
        if(trigger.isAfter && trigger.isInsert){
        CampaignMemberTriggerHelper.cmTriggerSkip = true;
        Map<Id,String> LeadTerritory = new Map<Id,String>();
         list<id> leadIdlist = new list<Id>();
        for(CampaignMember camp : trigger.new){
            if(camp.leadId != null)
                leadIdlist.add(camp.leadId);
        }
        
        if(!leadIdlist.isEmpty()){
            for(lead le : [Select Id, Territory__c,Territory__r.Name, Patch__c, Patch__r.PatchTeam__c from Lead where ID IN: leadIdList AND Patch__c != null]){
                 if(le.Territory__c != null && le.Territory__r.Name.contains('Catch All'))
                   {
                       LeadTerritory.put(le.Id, le.Territory__r.Name);
                   }
            }
        }
        if(!TriggerUtility.isUpdateLeadContactForCampExecuted())
        {
            CampaignMemberTriggerHelper.updateLeadContactForCamp(trigger.new);
            //CampaignMemberTriggerHelper.createZPAProvisioningRequest(trigger.new);
            CampaignMemberTriggerHelper.createCase(trigger.new,LeadTerritory);
        }
    }
    }
    
}