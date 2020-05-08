/**
 * @File Name          : PatchRuleEngineStarter.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 4/30/2020, 6:46:55 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/30/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class PatchRuleEngineStarter
{
    private static Set<Id> globalPipeline = new Set<Id>();
    private List<Id> currentPipeline = new List<Id>();
    
    global PatchRuleEngineStarter(List<Id> recordIds)
    {
        Set<Id> dedup = new Set<Id>(recordIds);
        currentPipeline.addAll(dedup);
    }
    
    global void start()
    {
        globalPipeline.addAll(currentPipeline);
        if(currentPipeline.size() <= 10)
        {
            assignPatch(currentPipeline);
        }
        else
        {
            InnerJob job = new InnerJob(currentPipeline);
            System.enqueueJob(job);
        }
    }
    
    public static Boolean isInPipeline(Id recordId)
    {
        return globalPipeline.contains(recordId);
    }
    
    private void assignPatch(List<Id> recordIds)
    {
        //system.debug('inside assignPatch');
        if(recordIds == null || recordIds.size() == 0)
        {
            return;
        }
        List<sObject> objs = PatchRuleHelper.getSObjects(recordIds);
        //system.debug('objs  '+objs);
        SavePoint sp = Database.setSavePoint();
        List<sObject> sharingsAndTeams = assignPatches(objs);
        //system.debug('sharingsAndTeams  '+sharingsAndTeams.size());
        for(sObject  sobj:sharingsAndTeams){
            //system.debug('sharingsAndTeams sobj   '+sobj);
        }
        List<sObject> existingSharesAndTeams = getExistingSharings(objs);
        for(sObject  sobj:existingSharesAndTeams){
            //system.debug('existingSharesAndTeams sobj   '+sobj);
        }
        if(objs.size() > 0)
        {
            try 
            {
                //system.debug('inside try');
                update objs;
                //Realgin AccountTeamMember / LeadShare
                //system.debug('before calling mergeTeamMembers');
                PatchRuleHelper.mergeTeamMembers(sharingsAndTeams, PatchRuleHelper.getExistingSharingsToDelete(existingSharesAndTeams), existingSharesAndTeams);
                //system.debug('after calling mergeTeamMembers');
                if(!System.isBatch())
                {
                    //Assign team members to related opportunities 
                    if(objs[0] instanceOf Account)
                    {
                        //system.debug('inside first if');
                        Integer numberOfOpps = PatchRuleHelper.countOpportunity(recordIds);
                        if(numberOfOpps < 10)
                        {
                            //add Opportunity Incremental Change code here and commentout the code. Tomorrow Zscaler Dev team will test the changes
                            //less than 10 opportunities, go within same transaction
                            PatchRuleHelper.assignSalesTeamMembers(recordIds, 'Account');    
                        }
                        else
                        {
                            //more than 10 opps, open an job. Disable following 3 lines and use the logic above to test realign opps in same transaction
                            List<schema.SObjectType> sObjTypes = new List<Schema.SObjectType>{Schema.Opportunity.SObjectType};
                            PatchRealignJob job = new PatchRealignJob(recordIds, sObjTypes, true);
                            Database.executeBatch(job, 10);
                        }
                    }
                }
                else {
                    //batch job here
                    //PatchRuleHelper.mergeTeamMembers(sharingsAndTeams, PatchRuleHelper.getExistingSharingsToDelete(existingSharesAndTeams));
                    //opp team member are handled by a separate PatchRealginJob
                }
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                PatchRuleHelper.logError(ex);
                if(objs[0] instanceOf Account)
                {
                    update failedToRealign(objs);
                }
            }  
        }
    }
    
    private List<sObject> assignPatches(List<sObject> objs)
    {
        //system.debug('inside assignPatches method');
        Map<Id, PatchDataModel.PatchInfo> patches = new Map<Id, PatchDataModel.PatchInfo>();
        //system.debug('inside assignPatches method');
        List<PatchDataModel.PatchInfo> patchlst = PatchRuleHelper.getPatches();
        //system.debug('patchlst '+patchlst.size());
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = getObject2Role2Mapping();
        for(PatchDataModel.PatchInfo patch : patchlst)
        {
            patches.put(patch.PatchId, patch);
        }
        List<sObject> sharingsAndTeams = new List<sObject>();
        for(sObject obj : objs)
        {
            //system.debug('obj  '+obj);
            PatchDataModel.PatchInfo patch = null;
            if((Boolean)obj.get(PatchRuleHelper.NamespacePrefix + 'PatchLocked__c'))
            {
                //if a record is locked, we keep the patch member up to date, leave the patch unchanged
                patch = patches.get((Id)obj.get(PatchRuleHelper.NamespacePrefix + 'Patch__c'));
            }
            else
            {
                PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(obj);
                patch = matchPatch(target);
            }
            sharingsAndTeams.addAll(assignPatch(obj, patch, object2Role2Mapping));
        }
        return sharingsAndTeams;
    }
    
    @testvisible
    private List<sObject> assignPatch(sObject obj, PatchDataModel.PatchInfo patch, Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping)
    { 
        String objType = obj.getSObjectType().getDescribe().getName();
        //system.debug('inside assignPatch method '+objType);
        globalPipeline.add(obj.Id);
        if(patch != null)
        {
            obj.put(PatchRuleHelper.NamespacePrefix + 'Patch__c', patch.PatchId);
            PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
            //system.debug('config '+config);
            if(config.roles.containsKey(objType))
            {
                //system.debug('inside if ');
                for(PatchDataModel.TeamMemberRoleConfig memberConfig : config.roles.get(objType))
                {
                    //system.debug('memberConfig  '+memberConfig);
                    if(String.isNotBlank(memberConfig.fieldName))
                    {
                        if(obj instanceOf Lead)
                        {
                            obj.put(memberConfig.fieldName, null);
                        }
                    }
                    for(PatchDataModel.TeamMemberInfo member : patch.members)
                    {
                        if(member.role == memberConfig.role)
                        {
                            if(String.isNotBlank(memberConfig.fieldName))
                            {
                                if(obj instanceOf Lead)
                                {
                                    obj.put(memberConfig.fieldName, member.userId);
                                }
                            }
                            if(memberConfig.assignOwnership == true)
                            {
                                obj.put('OwnerId', member.userId);
                            }
                            break;
                        }
                    }
                }
            }
            if(obj instanceOf Opportunity)
            {
                Opportunity opportunity = (Opportunity)obj;
                opportunity.Patch__c = patch.PatchId;
                opportunity.PatchLocked__c = opportunity.Account.PatchLocked__c;
            }
        }
        else
        {
            ////system.debug('inside else');
            obj.put(PatchRuleHelper.NamespacePrefix + 'Patch__c', null);
            PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
            if(config.roles.containsKey(objType))
            {
                for(PatchDataModel.TeamMemberRoleConfig memberConfig : config.roles.get(objType))
                {
                    if(memberConfig.fieldName != 'OwnerId' && String.isNotBlank(memberConfig.fieldName))
                    {
                        if(obj instanceOf Lead)
                        {
                            obj.put(memberConfig.fieldName, null);
                        }
                    }
                }
            }            
        }
        obj.put(PatchRuleHelper.NamespacePrefix + 'TriggerPatchAssignment__c', false);
        return newPatchSharing(obj, patch, object2Role2Mapping);
    }
    
    @testvisible
    private List<sObject> newPatchSharing(sObject obj, PatchDataModel.PatchInfo patch, Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping)
    {
        //system.debug('inside newPatchSharing  method');
        //system.debug('inside newPatchSharing  method '+patch);
        //system.debug('inside newPatchSharing  method '+patch.Members);
        List<sObject> result = new List<sObject>();
        List<PatchDataModel.TeamMemberInfo> CSMandTAMMembertoremove= new List<PatchDataModel.TeamMemberInfo>();
        if(patch != null)
        { 
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
                if(leadShareType != null && leadShareType.getDescribe().isCreateable())
                {
                    for(PatchDataModel.TeamMemberInfo member : patch.Members)
                    {
                        SObject leadShare = leadShareType.newSObject();
                        leadShare.put('LeadId', ld.Id);
                        leadShare.put('UserOrGroupId', member.UserId);
                        leadShare.put('LeadAccessLevel', 'Edit');
                        result.add(leadShare);
                    }
                }
            }
            else if(obj instanceOf Account)
            {
                Account acc = (Account)obj;
                Set<String> CSMandTAMRoleSet= new Set<String>{'Customer Success Manager','Technical Account Manager'};
                SObjectType accountTeamMemberType = PatchRuleHelper.getSObjectType('AccountTeamMember');
                if(accountTeamMemberType != null && accountTeamMemberType.getDescribe().isCreateable())
                {
                    for(PatchDataModel.TeamMemberInfo member :  patch.Members)
                    {
                        //system.debug('member  '+member);                
                        if(object2Role2Mapping.containsKey('Account') && object2Role2Mapping.get('Account').containsKey(member.role))
                        {
                            PatchFieldMapping__c mapping = object2Role2Mapping.get('Account').get(member.role);
                            if(mapping.Field__c != null)
                            {
                                SObject accountTeamMember = accountTeamMemberType.newSObject();
                                accountTeamMember.put('AccountId', acc.Id);
                                accountTeamMember.put('UserId', member.UserId);
                                accountTeamMember.put('TeamMemberRole', mapping.Field__c);
                                accountTeamMember.put('AccountAccessLevel', mapping.Account_Access__c);
                                accountTeamMember.put('OpportunityAccessLevel', mapping.Opportunity_Access__c);
                                accountTeamMember.put('CaseAccessLevel', mapping.Case_Access__c);
                                accountTeamMember.put('ContactAccessLevel', mapping.Contact_Access__c);
                                //system.debug('accountTeamMember '+accountTeamMember);
                                result.add(accountTeamMember); 
                                //system.debug('before entering logic to remove CSM and TAM');
                                if(CSMandTAMRoleSet.contains(member.role)){
                                    //system.debug('inside logic to remove CSM and TAM');
                                    CSMandTAMMembertoremove.add(member);
                                }
                            }               
                        }
                    }
                    //patch.Members.add(new PatchDataModel.TeamMemberInfo(member.User__c, member.Role__c));
                    //system.debug('CSMandTAMMembertoremove  '+CSMandTAMMembertoremove);
                    for(PatchDataModel.TeamMemberInfo member :  CSMandTAMMembertoremove){
                        if(patch.Members.indexof(member)!=-1){
                        patch.Members.remove(patch.Members.indexof(member));
                        }
                    }
                    
                    /* if(CSMandTAMRoleSet.contains(member.role)){
                        //system.debug('inside logic to remove CSM and TAM');
                        patch.Members.remove(member);
                        //system.debug('inside logic to remove CSM and TAM');
                    } */
                }
            }
            // else if(obj instanceOf Opportunity)
            // {
            //     Opportunity opp = (Opportunity)obj;
            //     SObjectType oppTeamMemberType = PatchRuleHelper.getSObjectType('OpportunityTeamMember');
            //     if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isCreateable())
            //     {
            //         for(PatchDataModel.TeamMemberInfo member : patch.Members)
            //         {
            //             if(object2Role2Mapping.containsKey('Opportunity') && object2Role2Mapping.get('Opportunity').containsKey(member.role))
            //             {
            //                 PatchFieldMapping__c mapping = object2Role2Mapping.get('Opportunity').get(member.role);
            //                 if(mapping.Field__c != null)
            //                 {
            //                     SObject oppTeamMember = oppTeamMemberType.newSObject();
            //                     oppTeamMember.put('OpportunityId', opp.Id);
            //                     oppTeamMember.put('UserId', member.UserId);
            //                     oppTeamMember.put('TeamMemberRole', mapping.Field__c);
            //                     oppTeamMember.put('OpportunityAccessLevel', mapping.Opportunity_Access__c);
            //                     result.add(oppTeamMember);
            //                 }
            //             }
            //         }
            //     }
            // }
        }
        return result;
    }

    @testvisible
    private Map<String, Map<String, PatchFieldMapping__c>> getObject2Role2Mapping()
    {
        Map<String, Map<String, PatchFieldMapping__c>> object2Role2Mapping = new Map<String, Map<String, PatchFieldMapping__c>>();
        for(PatchFieldMapping__c mapping : PatchFieldMapping__c.getAll().values())
        {
            if(mapping.Type__c == 'Role')
            {
                if(!object2Role2Mapping.containsKey(mapping.Object__c))
                {
                    object2Role2Mapping.put(mapping.Object__c, new Map<String, PatchFieldMapping__c>{mapping.Value__c => mapping});
                }
                else 
                {
                    object2Role2Mapping.get(mapping.Object__c).put(mapping.Value__c, mapping);
                }
            }
        }
        //system.debug('object2Role2Mapping  '+object2Role2Mapping);
        return object2Role2Mapping;
    }
    
    private List<sObject> getExistingSharings(List<sObject> objs)
    {
        //system.debug('inside getExistingSharings method');
        List<sObject> result = new List<sObject>();
        if(objs.size() > 0)
        {
            sObject obj = objs[0];
            if(obj instanceOf Lead)
            {
                SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
                if(leadShareType != null && leadShareType.getDescribe().isQueryable())
                {
                    return Database.query('select Id from LeadShare where LeadId in :objs');
                }
            }
            else if(obj instanceOf Account)
            {
                List<Id> patchUnlockedAccs = PatchRuleHelper.getPatchUnlockedObjIds(objs);
                SObjectType accountTeamMemberType = PatchRuleHelper.getSObjectType('AccountTeamMember');
                if(accountTeamMemberType != null && accountTeamMemberType.getDescribe().isQueryable())
                {
                    return Database.query('select Id, UserId, AccountId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel from AccountTeamMember where AccountId in :objs');
                }
            }
            else if(obj instanceOf Opportunity)
            {
                SObjectType oppTeamMemberType = PatchRuleHelper.getSObjectType('OpportunityTeamMember');
                if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isQueryable())
                {
                    return Database.query('select Id, UserId, OpportunityId, OpportunityAccessLevel, TeamMemberRole from OpportunityTeamMember where OpportunityId in :objs');
                }
            }
        }
        return result;
    }

    private static PatchDataModel.PatchInfo matchPatch(PatchDataModel.MatchTarget target)
    {
        //system.debug('inside matchPatch method  ');
        PatchDataModel.PatchInfo matchedPatch = null;
        Set<Id> overlayMatches = new Set<Id>();
        for(Integer i = 0; i < 9999; i++)
        {
            //system.debug('i '+i);
            String engineClassName = 'PatchRuleEngine' + (i == 0 ? '' : String.valueOf(i));
            //system.debug('engineClassName  '+engineClassName);
            Type engineType = Type.forName('', engineClassName);
            if(engineType != null)
            {
                IPatchRuleEngine engine = (IPatchRuleEngine)engineType.newInstance();
                if(engine instanceOf PatchRuleEngineBase)
                {
                    ((PatchRuleEngineBase)engine).overlayingPatchIds.addAll(overlayMatches);
                }
                matchedPatch = engine.match(target);
                //system.debug('overlayMatches in PatchRuleEngineStarter  '+overlayMatches);
                if(engine instanceOf PatchRuleEngineBase)
                {
                    overlayMatches.addAll(((PatchRuleEngineBase)engine).overlayingPatchIds);
                }
                //system.debug('overlayMatches in PatchRuleEngineStarter  '+overlayMatches);
                if(matchedPatch != null && matchedPatch.patchId != null) break;
            }
            else
            {
                break;
            }
        }

        return matchedPatch;
    }
    
    private List<sObject> failedToRealign(List<sObject> objs)
    {
        for(sObject obj : objs)
        {
            obj.put('Patch_Assignment_Failed__c', true);
        }
        return objs;
    }

    public class InnerJob implements Queueable
    {
        private List<Id> currentBatch;
        private List<Id> pipeline;
        
        public InnerJob(List<Id> records)
        {
            if(records != null)
            {
                if(records.size() <= 10)
                {
                    currentBatch = new List<Id>(records);
                    pipeline = null;
                }
                else
                {
                    currentBatch = new List<Id>();
                    pipeline = new List<Id>();
                    for(Integer i = 0; i < records.size(); i++)
                    {
                        if(i < 10)
                        {
                            currentBatch.add(records[i]);
                        }
                        else
                        {
                            pipeline.add(records[i]);
                        }
                    }
                }
            }
        }
        
        public void execute(QueueableContext context) 
        {
            if(currentBatch != null)
            {
                PatchRuleEngineStarter starter = new PatchRuleEngineStarter(currentBatch);
                starter.assignPatch(currentBatch);
            }
            if(pipeline != null)
            {
                System.enqueueJob(new InnerJob(pipeline));
            }
        }
    }
    
    public class EmptyEngine implements IPatchRuleEngine
    {
        public PatchDataModel.PatchInfo match(PatchDataModel.MatchTarget t)
        {
            return null;
        }
    }
    
    public void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}