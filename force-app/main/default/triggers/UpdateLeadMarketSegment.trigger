/**
 *  This trigger is used to set Market_Segment__c on Lead.
 */

trigger UpdateLeadMarketSegment on Lead (before insert, before update)
{
    // Query the list of country names and codes for EMEA region
    ZscalerSetting__c setting = ZscalerSetting__c.getInstance('EMEACountriesPatchRuleName');
    List<String> lstPatchCriteriaRuleNames = new List<String>();
    if (setting != null && setting.Value__c != null) {
        lstPatchCriteriaRuleNames.addAll(setting.Value__c.split(','));
    }
    System.debug('*** lstPatchCriteriaRuleNames: ' + lstPatchCriteriaRuleNames);

    Set<String> setEMEACountries = new Set<String>();
    for (PatchMatchList__c countryName : [SELECT Name FROM PatchMatchList__c WHERE PatchCriteriaRule__r.Name = :lstPatchCriteriaRuleNames]) {
        setEMEACountries.add(countryName.Name.toLowerCase());
    }

    if(trigger.isInsert)
    {
        for(Lead newLead : Trigger.new)
        {
            if(!newLead.Override_Market_Segment__c)
            {
                newLead.Market_Segment__c = TriggerUtility.GetMarketSegment(newLead.No_Employees_Users__c, newLead.NumberOfEmployees, (newLead.Country != null && setEMEACountries.contains(newLead.Country.toLowerCase())));
            }
        }
    }
    else if(trigger.isUpdate)
    {
        Lead oldLead;
        for(Lead newLead : Trigger.new)
        {
            oldLead = Trigger.oldMap.get(newLead.Id);
            if(!newLead.Override_Market_Segment__c && (newLead.TriggerPatchAssignment__c || newLead.NumberOfEmployees != oldLead.NumberOfEmployees || newLead.No_Employees_Users__c != oldLead.No_Employees_Users__c || newLead.Country != oldLead.Country))
            {
                newLead.Market_Segment__c = TriggerUtility.GetMarketSegment(newLead.No_Employees_Users__c, newLead.NumberOfEmployees, (newLead.Country != null && setEMEACountries.contains(newLead.Country.toLowerCase())));
            }
        }
    }

    if((trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        set<id> patchIdSet = new Set<id>();
        map<Id, Id> patchTerritoryMap = new map<Id, Id>();
        for(lead le : trigger.new){
            if(le.Patch__c != null)
                patchIdSet.add(le.Patch__c);
        }
        for(Patch__c patch : [Select Id, PatchTeam__c from Patch__c where PatchTeam__c != null AND ID IN: patchIdSet]){
            patchTerritoryMap.put(patch.id, patch.PatchTeam__c);
        }

        for(lead le : trigger.new){
            if(le.Patch__c != null)
                le.Territory__c = patchTerritoryMap.get(le.Patch__c);
        }
    }
}