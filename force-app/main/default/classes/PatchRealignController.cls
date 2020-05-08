/*
 * Controller of page PatchRealign
 */
public with sharing class PatchRealignController 
{
    private List<Patch__c> patches;
    
    public PatchRealignController(ApexPages.StandardController controller) 
    {
        String patchIds = ApexPages.currentPage().getParameters().get('pids');
        if(String.isNotBlank(patchIds))
        {
            patches = [select Id from Patch__c where Id in :patchIds.split(',')];
        }
        else
        {
            patches = [select Id from Patch__c where Id=:controller.getId() limit 1];
        }
        aborted = false;
        LeadCount = [select count() from Lead where Patch__c in :patches and Patch__c!=null and IsConverted=false limit 1000];
        OpportunityCount = [select count() from Opportunity where Patch__c in :patches and Patch__c!=null limit 1000];
        AccountCount = [select count() from Account where Patch__c in :patches and Patch__c!=null limit 1000];
        DateTime ruleEngineDeployDate = DateTime.newInstance(PatchRuleHelper.LastDeploymentDate);
        HasPendingUpdate = [select Id from Patch__c where Id in :patches and Timestamp__c>:ruleEngineDeployDate limit 1].size() > 0;
    }

    public Boolean InProgress 
    {
        get
        {
            return [select Id from AsyncApexJob where ApexClassID in (select Id from ApexClass where Name='PatchRealignJob') and Status in ('Holding', 'Queued', 'Preparing', 'Processing') limit 1].size() > 0;
        }
    }
    
    public Boolean HasPendingUpdate { get; set; }
    public Integer LeadCount { get; set; }
    public Integer OpportunityCount { get; set; }
    public Integer AccountCount { get; set; }
    public Boolean aborted { get; set; }
    
    public PageReference init()
    {
        Boolean autoStart = ApexPages.currentPage().getParameters().get('start') == '1';
        if(autoStart)
        {
            startProcess();
        }
        return null;
    }
    
    public PageReference startProcess()
    {
        String realignType = ApexPages.currentPage().getParameters().get('realigntype');
        if( (!InProgress && !HasPendingUpdate) || Test.isRunningTest() )
        {
            List<Id> patchIds = new List<Id>();
            List<schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
            for(Patch__c patch : patches)
            {
                patchIds.add(patch.Id);
            }
            if(realignType == 'Account')
            {
                sObjTypes.add(Schema.Account.SObjectType);
                sObjTypes.add(Schema.Opportunity.SObjectType);
            }
            else if(realignType == 'Lead')
            {
                sObjTypes.add(Schema.Lead.SObjectType);
            }
            else
            {
                sObjTypes.add(Schema.Account.SObjectType);
                sObjTypes.add(Schema.Opportunity.SObjectType);
                sObjTypes.add(Schema.Lead.SObjectType);
            }
            PatchRealignJob job = new PatchRealignJob(patchIds, sObjTypes);
            if(patchIds.size() == 0)
            {
                job.reassignEverything = true;
            }
            Integer batchSize = 10;
            Database.executeBatch(job, batchSize);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'The patch realignment job is submitted. You can close this window now. An email will be sent to you after the job is complete.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must wait the pending process complete to start a new realignment job.'));
        }
        return null;
    }
    
    public PageReference abortProcess()
    {
        List<AsyncApexJob> jobs = [select Id from AsyncApexJob where ApexClassID in (select Id from ApexClass where Name='PatchRealignJob') and Status in ('Holding', 'Queued', 'Preparing', 'Processing') limit 1];
        if(jobs.size() > 0)
        {
            System.abortJob(jobs[0].Id);
            aborted = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Realignment process is aborted.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No process found.'));
        }
        return null;
    }
}