/*
 * Controller of page PatchMatchListQuickAdd
 */
public with sharing class PatchMatchListQuickAddController 
{
    private PatchCriteriaRule__c rule;
    
    public PatchMatchListQuickAddController()
    {
        String ruleId = ApexPages.currentPage().getParameters().get('ruleId');
        if(ruleId != null && ruleId instanceOf Id)
        {
            List<PatchCriteriaRule__c> rules = [select Id from PatchCriteriaRule__c where Id=:ruleId limit 1];
            if(rules.size() > 0)
            {
                rule = rules[0];
            }
        }
    }
    
    public String Values { get; set; }
    
    public PageReference save()
    {
        if(rule == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You should open the page in a normal way.'));
        }
        else
        {
            if(String.isBlank(Values))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Value required'));
            }
            else
            {
                Set<String> existingEntries = new Set<String>();
                for(PatchMatchList__c pml : [select Id, Name from PatchMatchList__c where PatchCriteriaRule__c=:rule.Id])
                {
                    existingEntries.add(pml.Name);
                }
                List<String> entries = Values.split('[\r\n]');
                List<PatchMatchList__c> newEntries = new List<PatchMatchList__c>();
                for(String entry : entries)
                {
                    if(String.isNotBlank(entry) && !existingEntries.contains(entry))
                    {
                        newEntries.add(new PatchMatchList__c(PatchCriteriaRule__c=rule.Id, Name=entry));
                    }
                }
                if(newEntries.size() > 0)
                {
                    try
                    {
                        insert newEntries;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'New entries saved<script>opener.location="/'+rule.Id+'";setTimeout("window.close()", 3000);</script>'));
                    }
                    catch(Exception ex)
                    {
                        ApexPages.addMessages(ex);
                    }
                }
            }
        }
        return null;
    }
}