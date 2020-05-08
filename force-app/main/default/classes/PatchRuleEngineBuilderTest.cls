@isTest
public class PatchRuleEngineBuilderTest
{
    @isTest
    static void test()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        Patch__c patch2 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=2, RuleLogic__c='1 AND 2 AND 3');
        insert patch2;
        PatchCriteriaRule__c rule2 = new PatchCriteriaRule__c(Patch__c=patch2.Id, Field__c='Country', Operation__c='in', Value__c='US', ProcessingSequence__c=1);
        insert rule2;
        PatchCriteriaRule__c rule3 = new PatchCriteriaRule__c(Patch__c=patch2.Id, Field__c='Zip Code', Operation__c='in range', RangeLow__c='11111', RangeHigh__c='22222', ProcessingSequence__c=2);
        insert rule3;
        PatchCriteriaRule__c rule4 = new PatchCriteriaRule__c(Patch__c=patch2.Id, Field__c='Zip Code', Operation__c='in match list', ProcessingSequence__c=3);
        insert rule4;
        PatchCriteriaRule__c rule5 = new PatchCriteriaRule__c(Patch__c=patch2.Id, Field__c='Zip Code', Operation__c='in', ProcessingSequence__c=4);
        insert rule5;
        PatchMatchList__c match = new PatchMatchList__c(PatchCriteriaRule__c=rule4.Id, Name='11111');
        insert match;
        
        PatchRuleEngineBuilder builder = new PatchRuleEngineBuilder('', [Select Id From Patch__c]);
        System.assert(builder.build() != null);
        System.assert(builder.buildTestCoverage() != null);
    }
}