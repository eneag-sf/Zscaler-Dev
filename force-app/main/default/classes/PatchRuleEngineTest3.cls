@isTest
public class PatchRuleEngineTest3
{
    @isTest static void testMatch()
    {
        PatchDataModel.MatchTarget t = new PatchDataModel.MatchTarget(null);
        PatchRuleEngine3 engine = new PatchRuleEngine3();
        engine.match(t);
    }

    @isTest static void testOp()
    {
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true);
        insert patch;
        PatchRuleEngine3 engine = new PatchRuleEngine3();
        engine.processResult(patch.Id);
        System.assert(engine.opIn('a', new Set<String> {'a', 'b'}));
        System.assert(engine.opInRange('11111', '00000', '22222'));
        System.assert(engine.opInRange('90145', '00000', '90200'));
        System.assert(engine.opEqual('a', 'A'));
        System.assert(engine.opStart('abcd', new Set<String> {'a'}));
        System.assert(engine.opEnd('dcba', new Set<String> {'a'}));
        System.assert(engine.opContain('abcd', 'A')); 
    }
}