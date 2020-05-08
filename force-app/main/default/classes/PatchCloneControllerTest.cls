@isTest
public class PatchCloneControllerTest
{
    @isTest static void test()
    {
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, Field__c='Company', Operation__c='equals', Value__c='acme');
        insert rule;
        PatchMatchList__c ml = new PatchMatchList__c(PatchCriteriaRule__c=rule.Id, Name='acme');
        insert ml;
        
        Test.startTest();
        PatchCloneController controller = new PatchCloneController(new ApexPages.StandardController(patch));
        controller.clonePatch();
        
        PatchDataModel.PatchInfo pi = PatchRuleHelper.getPatch(patch.Id);
        pi.deepClone();
        List<Patch__c> patches = [select Id, PatchName__c from Patch__c where Id != :patch.Id limit 1];
        System.assertEquals(1, patches.size());
        List<PatchCriteriaRule__c> rules = [select Id, Field__c, Operation__c, Value__c, (select Name from PatchMatchLists__r) from PatchCriteriaRule__c where Patch__c=:patches[0].Id];
        System.assertEquals(1, rules.size());
        System.assertEquals('Company', rules[0].Field__c);
        System.assertEquals('equals', rules[0].Operation__c);
        System.assertEquals('acme', rules[0].Value__c);
        System.assertEquals(1, rules[0].PatchMatchLists__r.size());
        System.assertEquals('acme', rules[0].PatchMatchLists__r[0].Name);
        Test.stopTest();
    }
}