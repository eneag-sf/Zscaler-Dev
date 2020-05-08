@isTest
public class PatchRuleEngineStarterTest
{
    @isTest
    static void testLeadAssign()
    {   
        PatchFieldMapping__c mappingl = new PatchFieldMapping__c(Name='l1', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mappingl;
        PatchFieldMapping__c mappinga = new PatchFieldMapping__c(Name='a1', Object__c='Account', Type__c='Field', Field__c='BillingCountry', Value__c='Country');
        insert mappinga;
        PatchFieldMapping__c mappingo = new PatchFieldMapping__c(Name='o1', Object__c='Opportunity', Type__c='Field', Field__c='Account.BillingCountry', Value__c='Country');
        insert mappingo;
        
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> { ld.Id });
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        starter.start();
        starter.booster();
        starter.assignPatch(ld, p, object2Role2Mapping);
        
        PatchRuleEngineStarter.EmptyEngine emptyEngine = new PatchRuleEngineStarter.EmptyEngine();
        PatchDataModel.MatchTarget t = new PatchDataModel.MatchTarget(ld);
        PatchDataModel.PatchInfo info = emptyEngine.match(t);
        PatchRuleEngineStarter.InnerJob innerJob = new PatchRuleEngineStarter.InnerJob(new List<Id> { ld.Id });
        innerJob.execute(null);
    }
    
    @isTest
    static void testAccountAssign()
    {   
        PatchFieldMapping__c mappinga = new PatchFieldMapping__c(Name='a1', Object__c='Account', Type__c='Field', Field__c='BillingCountry', Value__c='Country');
        insert mappinga;
        PatchFieldMapping__c mappingb = new PatchFieldMapping__c(Name='b1', Object__c='Account', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingb;
        PatchFieldMapping__c mappingc = new PatchFieldMapping__c(Name='c1', Object__c='Opportunity', Type__c='Role', Field__c='Account Manager', Value__c='Lead Development');
        insert mappingc;
        PatchFieldMapping__c mappingo = new PatchFieldMapping__c(Name='o1', Object__c='Opportunity', Type__c='Field', Field__c='Account.BillingCountry', Value__c='Country');
        insert mappingo;

        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName= Label.Stage_1_Alignment /*'Discovery'*/, AccountId=acc.Id);
        insert opp;
        
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        
        PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id> {acc.Id, opp.Id });
        starter.start();
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = starter.getObject2Role2Mapping();
        PatchDataModel.PatchInfo p = PatchRuleHelper.getPatch(patch.Id);
        starter.assignPatch(acc, p, object2Role2Mapping);
        starter.assignPatch(opp, p, object2Role2Mapping);
        acc.BillingCountry = 'US';
        update acc;
    }

    @isTest
    static void testPatchRuleHelper()
    {
        Boolean isAdmin = PatchRuleHelper.IsAdmin;
        String NamespaceClassPrefix = PatchRuleHelper.NamespaceClassPrefix;
        Long LastDeploymentDate = PatchRuleHelper.LastDeploymentDate;
        PatchRuleHelper.getSObject(null);
        PatchRuleHelper.splitCsv('acme,ac "me');
        PatchRuleHelper.getSalesforceBaseUrl();
        PatchRuleHelper.logError('error');
    }

    @isTest
    static void testPatchDataModel()
    {
        PatchTeam__c team = new PatchTeam__c();
        insert team;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=team.Id, Role__c='Lead Development', User__c=UserInfo.getUserId());
        insert member;
        Patch__c patch = new Patch__c(PatchName__c='acme', PatchTeam__c=team.Id);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id, ProcessingSequence__c=1, Field__c='Country', Operation__c='in', Value__c='US');
        insert rule;
        PatchDataModel.PatchInfo patchInfo = new PatchDataModel.PatchInfo(patch);
        patchInfo.getSObject();
        patchInfo.deepClone();
        PatchDataModel.RuleInfo ruleInfo = new PatchDataModel.RuleInfo(rule);
        ruleInfo.getSObject(patch.Id);
        ruleInfo.deepClone();
    }
}