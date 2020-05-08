@isTest
public class PatchUserReplaceControllerTest
{
    @isTest
    static void test()
    {
        PatchTeam__c team = new PatchTeam__c(Name='acme');
        insert team;
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1, PatchTeam__c=team.Id);
        insert patch;
        
        PageReference ref = new PageReference('/apex/PatchUserReplace?uid=' + UserInfo.getUserId() + '&pid=' + patch.Id);
        Test.setCurrentPage(ref);
        PatchUserReplaceController controller = new PatchUserReplaceController();
        List<SelectOption> teams = controller.Teams;
        System.assertEquals(2, teams.size());
        controller.save();
    }
}