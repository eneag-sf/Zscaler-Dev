@isTest
public class PatchRealignControllerTest
{
    @isTest
    static void test()
    {
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='1', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,AssignTeamOnly__c=true);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Field__c='Company Name', Operation__c='equals', Value__c='acme', Patch__c=patch.Id);
        Insert rule;
        PatchMatchList__c match = new PatchMatchList__c(Name='acme', PatchCriteriaRule__c=rule.Id);
        Insert match;
        Account acc = new Account(Name='acme', Patch__c=patch.Id, BillingStreet='street', BillingCity='city', BillingCountry='US');
        insert acc;
        apexpages.currentPage().getparameters().put('start', '1');
        apexpages.currentPage().getparameters().put('realignType', 'AL');
        PatchRealignController controller = new PatchRealignController(new ApexPages.StandardController(patch));
        controller.init();
        //controller.startProcess('AL');
        controller.startProcess();
        controller.abortProcess();
    }

    @isTest
    static void enginBasetest()
    {
        PatchRuleEngine engine = new PatchRuleEngine();
        engine.overlayingPatchIds = new List<Id>();
        System.assert(engine.opEnd('dcba', new Set<String> {'a'}));
        System.assert(engine.opContain('abcd', 'A'));
        engine.processResult(null);
    }
}