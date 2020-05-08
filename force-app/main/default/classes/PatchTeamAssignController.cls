public with sharing class PatchTeamAssignController 
{
    private PatchTeam__c team;
    private List<PatchInfo> patches;
    
    public PatchTeamAssignController(ApexPages.StandardController controller)
    {
        team = (PatchTeam__c)controller.getRecord();
        succeeded = false;
    }
    
    public String patchesToAssign { get; set; }
    public Boolean succeeded { get; set; }
    
    public String getPatches()
    {
        if(patches == null && team != null)
        {
            patches = new List<patchInfo>();
            for(Patch__c p : [select Id, Name, PatchName__c from Patch__c where PatchTeam__c=null order by PatchName__c])
            {
                patches.add(new PatchInfo(p));
            }
        }
        return JSON.serialize(patches);
    }
    
    public PageReference save()
    {
        patchesToAssign = String.isBlank(patchesToAssign) ? '' : patchesToAssign.trim();
        List<String> patchIds = patchesToAssign.split('\\s*,\\s*');
        List<Patch__c> ps = [select Id from Patch__c where Id in :patchIds];
        if(ps.size() > 0 && team != null)
        {
            for(Patch__c p : ps)
            {
                p.PatchTeam__c = team.Id;
            }
        }
        try
        {
            update ps;
            succeeded = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Patch assignment succeeded.'));
        }
        catch(Exception ex) 
        {
            succeeded = false;
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public class PatchInfo
    {
        public PatchInfo(Patch__c p)
        {
            this.patchId = p.Id;
            this.patchNumber = p.Name;
            this.patchName = p.PatchName__c;
        }
        
        public String patchId { get; set; }
        public String patchNumber { get; set; }
        public String patchName { get; set; }
    }
}