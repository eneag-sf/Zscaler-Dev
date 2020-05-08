public with sharing class PatchCloneController 
{
    private Id patchId;
    
    public PatchCloneController(ApexPages.StandardController controller)
    {
        patchId = controller.getId();
    }
    
    public PageReference clonePatch()
    {
        SavePoint sp = Database.setSavePoint();
        try
        {
            PatchDataModel.PatchInfo pi = PatchRuleHelper.getPatch(patchId);
            Patch__c patch = pi.getSObject();
            patch.PatchName__c += ' (Clone)';
            insert patch;
            List<PatchCriteriaRule__c> rules = new List<PatchCriteriaRule__c>();
            for(PatchDataModel.RuleInfo ri : pi.rules)
            {
                rules.add(ri.getSObject(patch.Id));
            }
            insert rules;
            Map<Id, Id> ruleMapping = new Map<Id, Id>();
            for(Integer i = 0; i < rules.size(); i++)
            {
                ruleMapping.put(pi.rules[i].ruleId, rules[i].Id);
            }
            List<PatchMatchList__c> matchList = new List<PatchMatchList__c>();
            for(PatchMatchList__c existing : [select Id, Name, PatchCriteriaRule__c from PatchMatchList__c where PatchCriteriaRule__r.Patch__c=:patchId])
            {
                matchList.add(new PatchMatchList__c(PatchCriteriaRule__c=ruleMapping.get(existing.PatchCriteriaRule__c), Name=existing.Name));
            }
            insert matchList;
            return new PageReference('/' + patch.Id);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
    }
}