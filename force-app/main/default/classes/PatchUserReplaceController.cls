/*
 * Controller of page PatchUserReplace
 */
public class PatchUserReplaceController 
{
    public PatchUserReplaceController()
    {
        String teamId = ApexPages.currentPage().getParameters().get('tid');
        if(String.isNotBlank(teamId) && teamId instanceOf Id)
        {
            SelectedTeam = teamId;
        }
        SourceTemp = new PatchTeamMember__c();
        TargetTemp = new PatchTeamMember__c();
        String userId = ApexPages.currentPage().getParameters().get('uid');
        if(String.isNotBlank(userId) && userId instanceOf Id)
        {
            SourceTemp.User__c = userId;
        }
    }
    
    public PatchTeamMember__c SourceTemp { get; set; } //used for quick data bound.
    public PatchTeamMember__c TargetTemp { get; set; } //used for quick data bound.
    public Id SelectedTeam { get; set; }
    public Boolean Realign { get; set; }
    
    public List<SelectOption> Teams
    {
        get
        {
            List<SelectOption> result = new List<SelectOption>();
            result.add(new SelectOption('', '- All Teams -'));
            for(PatchTeam__c team : [select Id, Name from PatchTeam__c])
            {
                result.add(new SelectOption(team.Id, team.Name));
            }
            return result;
        }
    }
    
    public PageReference save()
    {
        if(SourceTemp.User__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select a source user to be replaced.'));
            return null;
        }
        List<PatchTeamMember__c> members = new List<PatchTeamMember__c>();
        if(String.isNotBlank(SelectedTeam))
        {
            members.addAll([select Id, User__c, PatchTeam__c from PatchTeamMember__c where User__c=:SourceTemp.User__c and PatchTeam__c =:SelectedTeam]);
        }
        else
        {
            members.addAll([select Id, User__c, PatchTeam__c from PatchTeamMember__c where User__c=:SourceTemp.User__c]);
        }
        Set<Id> updatedTeamIds = new Set<Id>();
        for(PatchTeamMember__c member : members)
        {
            member.User__c = TargetTemp.User__c;
            updatedTeamIds.add(member.PatchTeam__c);
        }
        try
        {
            List<Patch__c> updatedPatches = [select Id from Patch__c where PatchTeam__c in :updatedTeamIds];
            List<Id> updatedPatchIds = new List<Id>();
            for(Patch__c p : updatedPatches)
            {
                updatedPatchIds.add(p.Id);
            }   
            update members;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'User has been replaced.'));
            if(Realign)
            {
                return new PageReference('/apex/PatchRealign?pids=' + String.join(updatedPatchIds, ',') + '&start=1');
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
}