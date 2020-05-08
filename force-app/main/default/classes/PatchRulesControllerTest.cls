@isTest
public class PatchRulesControllerTest
{
    @isTest
    static void test()
    {
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, Field__c='Email Domain');
        insert rule;
        
        PatchRulesController controller = new PatchRulesController();
        System.assert(controller.PatchToDisplay != null);
        System.assertEquals(true, controller.IsAdmin);
        Long d = controller.LastDeploymentDate;
    }
}