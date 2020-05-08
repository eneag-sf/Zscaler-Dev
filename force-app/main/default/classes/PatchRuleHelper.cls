/*
 * Includes helper methods for triggers and classes related to Patch Assignment and Patch Matching
 */
global class PatchRuleHelper
{
    private static PatchDataModel.PatchConfig globalConfig;
    private static Map<String, Schema.SObjectType> globalSchema;

    public static Boolean IsAdmin
    {
        get
        {
            User currentUser = [select Id, Profile.PermissionsAuthorApex from User where Id=:UserInfo.getUserId() limit 1];
            return currentUser.Profile.PermissionsAuthorApex;
        }
    }

    public static String NamespacePrefix
    {
        get
        {
            return ''; //TBD
        }
    }

    public static String NamespaceClassPrefix
    {
        get
        {
            return ''; //TBD
        }
    }
        
    public static void refreshPatchTimestamp(Set<Id> patchIds)
    {
        List<Patch__c> patches = [select Id, Timestamp__c from Patch__c where Id in :patchIds];
        for(Patch__c patch : patches)
        {
            patch.Timestamp__c = System.now();
        }
        try
        {
            update patches;
        }
        catch(Exception ex)
        {
            logError(ex);
        }
    }
    
    public static Long LastDeploymentDate
    {
        get
        {
            List<ApexClass> engineClass = [select LastModifiedDate from ApexClass where Name='PatchRuleEngine' limit 1];
            if(engineClass.size() > 0)
            {
                return engineClass[0].LastModifiedDate.getTime();
            }
            return 0;
        }
    }
    
    //supports acc/opp/lead Id
    global static sObject getSObject(Id recordId)
    {
        List<sObject> result = getSObjects(new List<Id> { recordId });
        if(result.size() > 0)
        {
            return result[0];
        }
        return null;
    }
    
    //supports acc/opp/lead Id
    global static List<sObject> getSObjects(List<Id> recordIds)
    {
        List<sObject> result = new List<sObject>();
        Set<Id> accountIds = new Set<Id>(), opportunityIds = new Set<Id>(), leadIds = new Set<Id>();
        for(Id recordId : recordIds)
        {
            if(recordId != null)
            {
                if(recordId.getSObjectType() == Schema.Account.SObjectType)
                {
                    accountIds.add(recordId);
                }
                else if(recordId.getSObjectType() == Schema.Lead.SObjectType)
                {
                    leadIds.add(recordId);
                }
                else if(recordId.getSObjectType() == Schema.Opportunity.SObjectType)
                {
                    opportunityIds.add(recordId);
                }
            }
        }
        if(accountIds.size() > 0)
        {
            String soql = buildSQLFromConfig('Account');
            result.addAll((List<sObject>)Database.query(soql));
        }
        if(leadIds.size() > 0)
        {
            String soql = buildSQLFromConfig('Lead');
            result.addAll((List<sObject>)Database.query(soql));
        }
        if(opportunityIds.size() > 0)
        {
            String soql = buildSQLFromConfig('Opportunity');
            result.addAll((List<sObject>)Database.query(soql));
        }
        return result;
    }

    private static String buildSQLFromConfig(String objectName)
    {
        PatchDataModel.PatchConfig config = getConfig();
        if(config.allFields.containsKey(objectName))
        {
            List<String> mapping = config.allFields.get(objectName);
            Set<String> fields = new Set<String>(mapping);
            fields.addAll(new List<String> {'Id', 'OwnerId', PatchRuleHelper.NamespacePrefix + 'Patch__c', PatchRuleHelper.NamespacePrefix + 'PatchLocked__c', PatchRuleHelper.NamespacePrefix + 'TriggerPatchAssignment__c'});
            return buildSQL(objectName, new List<String>(fields), new List<String> { 'Id in :' + objectName.toLowerCase() + 'Ids' });
        }
        //throw new PatchException('Setup is not complete. Object[' + objectName + '] has no field mapping configured');
        return buildSQL(objectName, new List<String>{'Id', 'PatchLocked__c'}, new List<String> { 'Id in :' + objectName.toLowerCase() + 'Ids' });
    }
    
    public static String buildSQL(String objectName, List<String> fields, List<String> criteria)
    {
        String sql = 'select ';
        if(fields == null || fields.size() == 0)
        {
            fields = new List<String> { 'Id' };
        }
        sql += String.join(fields, ', ');
        sql.removeEnd(', ');
        sql += ' from ' + objectName;
        if(criteria != null && criteria.size() > 0)
        {
            sql += ' where ' + String.join(criteria, ' and ');
            sql.removeEnd(' and ');
        }
        return sql;
    }

    private static Map<Id, PatchDataModel.PatchInfo> allPatches = null;

    global static List<PatchDataModel.PatchInfo> getPatches()
    {
        if(allPatches == null)
        {
            //cache for all
            List<PatchDataModel.PatchInfo> patches = getPatches(null);
            allPatches = new Map<Id, PatchDataModel.PatchInfo>();
            for(PatchDataModel.PatchInfo patch : patches)
            {
                allPatches.put(patch.patchId, patch);
            }
        }
        return allPatches.values();
    }
    
    global static PatchDataModel.PatchInfo getPatch(Id patchId)
    {
        List<PatchDataModel.PatchInfo> patches = getPatches(new List<Id> {patchId});
        return (patches.size() > 0) ? patches[0] : null;
    }
    
    global static List<PatchDataModel.PatchInfo> getPatches(List<Id> patchIds)
    {
        //system.debug('inside getPatches of PatchRuleHelper  ');
        //system.debug('patchIds  '+patchIds);
        List<PatchDataModel.PatchInfo> result = new List<PatchDataModel.PatchInfo>();
        if(allPatches != null)
        {
            //system.debug('allPatches are not null  ');
            if(patchIds == null || patchIds.isEmpty())
            {
                return allPatches.values();
            }
            for(Id patchId : patchIds)
            {
                PatchDataModel.PatchInfo p = allPatches.get(patchId);
                if(p != null)
                {
                    result.add(p);
                }
            }
            //system.debug('result '+result);
            return result;
        }
        List<Patch__c> ps = new List<Patch__c>();
        if(patchIds == null || patchIds.isEmpty())
        {
            ps = [select Id, Name, AssignTeamOnly__c, Active__c, Catchall__c, PatchName__c, PatchTeam__c, PatchTeam__r.Name, ProcessingSequence__c, RuleLogic__c, Type__c, Timestamp__c, (select Id, Name, Field__c, Operation__c, ProcessingSequence__c, RangeHigh__c, RangeLow__c, Value__c from PatchCriteriaRules__r order by ProcessingSequence__c) from Patch__c where Active__c=true order by ProcessingSequence__c];
        }
        else
        {
            //system.debug('inside else '+patchIds);
            ps = [select Id, Name, AssignTeamOnly__c, Active__c, Catchall__c, PatchName__c, PatchTeam__c, PatchTeam__r.Name, ProcessingSequence__c, RuleLogic__c, Type__c, Timestamp__c, (select Id, Name, Field__c, Operation__c, ProcessingSequence__c, RangeHigh__c, RangeLow__c, Value__c from PatchCriteriaRules__r order by ProcessingSequence__c) from Patch__c where Id in :patchIds order by ProcessingSequence__c];
        }

        Set<Id> patchTeamIds = new Set<Id>();
        for(Patch__c patch : ps)
        {
            //system.debug('inside patch loop '+patch);
            patchTeamIds.add(patch.PatchTeam__c);
        }
        List<PatchTeam__c> teams = [select Id, Name, (select Id, Role__c, User__c from PatchTeamMembers__r) from PatchTeam__c where Id in :patchTeamIds];

        for(Patch__c p : ps)
        {
            PatchDataModel.PatchInfo patch = new PatchDataModel.PatchInfo(p);
            for(PatchTeam__c team : teams)
            {
                if(team.Id == p.PatchTeam__c)
                {
                    //system.debug('team  '+team);
                    for(PatchTeamMember__c member : team.PatchTeamMembers__r)
                    {
                        //system.debug('member  '+member);
                        patch.Members.add(new PatchDataModel.TeamMemberInfo(member.User__c, member.Role__c));
                    }
                    break;
                }
            }
            //system.debug(' patch.Members '+patch.Members);
            result.add(patch);
        }
        return result; 
    }
    
    public static Schema.SObjectType getSObjectType(String objName)
    {
        if(globalSchema == null)
        {
            globalSchema = Schema.getGlobalDescribe();
        }
        return globalSchema.get(objName);
    }

    public static Schema.SObjectField getSObjectField(String objName, String fieldName)
    {
        Schema.SObjectType sojbectType = getSObjectType(objName);
        if(sojbectType != null)
        {
            return sojbectType.getDescribe().fields.getMap().get(fieldName);
        }
        return null;
    }
    
    public static PatchDataModel.PatchConfig getConfig()
    {
        //system.debug('inside getConfig method'+globalConfig);
        if(globalConfig == null)
        {
            globalConfig = new PatchDataModel.PatchConfig();
            for(PatchFieldMapping__c mapping : PatchFieldMapping__c.getAll().values())//[select Id, Type__c, Object__c, Field__c, Value__c, AssignOwnership__c from PatchFieldMapping__c])
            {
                if(mapping.Type__c == 'Field')
                {
                    if(!globalConfig.criteriaFields.containsKey(mapping.Object__c))
                    {
                        globalConfig.criteriaFields.put(mapping.Object__c, new Map<String, String>());
                    }
                    if(String.isNotBlank(mapping.Value__c) && String.isNotBlank(mapping.Field__c))
                    {
                        globalConfig.criteriaFields.get(mapping.Object__c).put(mapping.Value__c, mapping.Field__c);
                    }
                    if(!globalConfig.allFields.containsKey(mapping.Object__c))
                    {
                        globalConfig.allFields.put(mapping.Object__c, new List<String>());
                    }
                    if(String.isNotBlank(mapping.Field__c))
                    {
                        globalConfig.allFields.get(mapping.Object__c).add(mapping.Field__c);
                    }
                }
                else if(mapping.Type__c == 'Role')
                {
                    if(!globalConfig.roles.containsKey(mapping.Object__c))
                    {
                        globalConfig.roles.put(mapping.Object__c, new List<PatchDataModel.TeamMemberRoleConfig>());
                    }
                    if(String.isNotBlank(mapping.Value__c))
                    {
                        globalConfig.roles.get(mapping.Object__c).add(new PatchDataModel.TeamMemberRoleConfig(mapping.Value__c, mapping.Field__c, mapping.Account_Access__c, mapping.Opportunity_Access__c, mapping.Case_Access__c, mapping.Contact_Access__c, mapping.AssignOwnership__c));
                    }
                }
            }
        }
        //system.debug('globalConfig  '+globalConfig);
        return globalConfig;
    }
    
    public static void saveConfig(PatchDataModel.PatchConfig config)
    {
        //system.debug('inside saveConfig method');
        List<PatchFieldMapping__c> settings = new List<PatchFieldMapping__c>();
        Integer i = 1;
        //fields
        for(String objName : config.criteriaFields.keyset())
        {
            Map<String, String> fields = config.criteriaFields.get(objName);
            for(String criteria : fields.keyset())
            {
                String field = fields.get(criteria);
                settings.add(new PatchFieldMapping__c(Name=String.valueOf(i++), Type__c='Field', Object__c=objName, Field__c=field, Value__c=criteria));
            }
        }
        //roles
        for(String objName : config.roles.keyset())
        {
            List<PatchDataModel.TeamMemberRoleConfig> roles = config.roles.get(objName);
            for(PatchDataModel.TeamMemberRoleConfig role : roles)
            {
                settings.add(new PatchFieldMapping__c(Name=String.valueOf(i++), Type__c='Role', Object__c=objName, Field__c=role.fieldName, Value__c=role.role, Account_Access__c=role.accountAccess, Opportunity_Access__c=role.opportunityAccess, Case_Access__c=role.caseAccess, Contact_Access__c=role.contactAccess, AssignOwnership__c=role.assignOwnership));
            }
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            delete [select Id from PatchFieldMapping__c];
            insert settings;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw new PatchException('Failed to save configuration, due to ' + ex.getMessage());
        }
    }

    public static List<String> splitCsv(String line)
    {
        List<String> result = new List<String>();
        Boolean itemStarted = true;
        Boolean isQuoteItem = false;
        String tempValue = '';
        for(Integer i = 0 ; i < line.length(); i++)
        {
            String c = line.mid(i, 1);
            if(c == ',')
            {
                if(itemStarted && !isQuoteItem)
                {
                    itemStarted = false;
                    result.add(tempValue.trim());
                    tempValue = '';
                }
                else if(itemStarted && isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else if(c == ' ')
            {
                if(itemStarted)
                {
                    tempValue += c;
                }
            }
            else if(c == '"')
            {
                if(!itemStarted)
                {
                    itemStarted = true;
                    isQuoteItem = true;
                }
                else if(itemStarted && isQuoteItem)
                {
                    isQuoteItem = false;
                }
                else if(itemStarted && !isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else
            {
                itemStarted = true;
                tempValue += c;
            }
        }
        result.add(tempValue.trim());
        return result;
    }
    
    public static String getSalesforceBaseUrl()
    {
        String host = URL.getSalesforceBaseURL().getHost();
        if(host.endsWith('visual.force.com'))
        {
            String[] hostParts = host.split('\\.');
            String server = hostParts[1];
            return 'https://' + server + '.salesforce.com';
        }
        else
        {
            return host;
        }
    }
    
    public static void logError(Exception ex)
    {
        logError(ex.getMessage() + '\r\nLine: ' + ex.getLineNumber() + '\r\n\r\n' + ex.getStackTraceString());
    }
    
    public static void logError(String error)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String> { 'sfdcsupport@zscaler.com' });
        email.setBccAddresses(new List<String> { 'zscaler@snapbi.com'});
        email.setSubject('Error occured in Patch Manager');
        email.setPlainTextBody(error);
        email.setUseSignature(false);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.Email> { email }, false);
    }

    public static List<Id> getPatchUnlockedObjIds(List<sObject> objs)
    {
        List<Id> results = new List<Id>();
        for(sObject obj : objs)
        {
            if(!(Boolean)obj.get('PatchLocked__c'))
            {
                results.add((Id)obj.get('Id'));
            }
        }
        return results;
    }

    public static List<sObject> getExistingSharings(List<Opportunity> opps)
    {
        //system.debug('inside getExistingSharings method');
        List<sObject> result = new List<sObject>();
        List<Id> patchUnlockedOpps = getPatchUnlockedObjIds((List<sObject>)opps);
        SObjectType oppTeamMemberType = PatchRuleHelper.getSObjectType('OpportunityTeamMember');
        if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isQueryable())
        {
            return Database.query('select Id, UserId, OpportunityId, TeamMemberRole, OpportunityAccessLevel from OpportunityTeamMember where OpportunityId in :patchUnlockedOpps');
        }
        return result;
    }

    public static List<sObject> getExistingSharingsToDelete(List<sObject> objs)
    {
        //system.debug('inside getExistingSharingsToDelete method'+objs);
        if(objs.size() > 0)
        {
            if(objs[0] instanceOf AccountTeamMember || objs[0] instanceOf OpportunityTeamMember) 
            {
                List<sObject> objstoDelete = new List<sObject>();
                List<String> reservedRoles = getReservedTeamMemberRoles();
                if(reservedRoles.size() > 0)
                {
                    for(SObject obj : objs)
                    {                            
                        String role = (String)obj.get('TeamMemberRole');
                        role = String.isNotBlank(role) ? role : '';
                        if(!reservedRoles.contains(role.toLowerCase()))
                        {
                            objstoDelete.add(obj);
                        }
                    }
                    //system.debug('objstoDelete   '+objstoDelete);
                    return objstoDelete;
                }
            }
        }
        return objs;
    }
    
    
    public static List<sObject> getReservedTeamSharingsToUpdate(List<sObject> objs)
    {
        //system.debug('getReservedTeamSharingsToUpdate   '+objs);
        List<sObject> objstoUpdate = new List<sObject>();
        if(objs.size() > 0)
        {
            if(objs[0] instanceOf AccountTeamMember || objs[0] instanceOf OpportunityTeamMember) 
            {
                List<String> reservedRoles = getReservedTeamMemberRoles();
                if(reservedRoles.size() > 0)
                {
                    for(SObject obj : objs)
                    {                            
                        String role = (String)obj.get('TeamMemberRole');
                        role = String.isNotBlank(role) ? role : '';
                        if(reservedRoles.contains(role.toLowerCase()))
                        {
                            objstoUpdate.add(obj);
                        }
                    }
                    //system.debug('objstoUpdate   '+objstoUpdate);
                    return objstoUpdate;
                }
            }
        }
        return objstoUpdate;
    }

    public static List<String> getReservedTeamMemberRoles()
    {
        //system.debug('inside getReservedTeamMemberRoles   ');
        List<String> roles = new List<String>();
        for(Reserved_Team_Member_Role__mdt role : [SELECT Label FROM Reserved_Team_Member_Role__mdt])
        {
            roles.add((String)role.Label.toLowerCase());
        }
        //system.debug('roles   '+roles);
        return roles;
    }

    public static Integer countOpportunity(Id[] accountIds)
    {
        return [SELECT count() FROM Opportunity WHERE AccountId IN :accountIds];
    }
    
    // public static List<List<Id>> getTwoTypeAccs(Id[] recordIds)
    // {
    //     List<Id> accsToAssign = new List<Id>();
    //     List<Id> accsOppToRealign = new List<Id>();
    //     for(AggregateResult  ar : [SELECT AccountId, Count(Id) opps FROM Opportunity WHERE AccountId in :recordIds GROUP BY AccountId])
    //     {
    //         Decimal countOfOpps = (Decimal) ar.get('opps');
    //         Id accId = (Id) ar.get('AccountId');
    //         if(countOfOpps >= 10)
    //         {
    //             accsOppToRealign.add(accId);
    //         }
    //         else if(countOfOpps > 0 && countOfOpps < 10)
    //         {
    //             accsToAssign.add(accId);
    //         }
    //     }
    //     return new List<List<Id>>{accsToAssign, accsOppToRealign};
    // }

    public static List<Id> getAccIds(List<Id> oppIds)
    {
        List<Id> accIds = new List<Id>();
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds])
        {
            accIds.add(opp.AccountId);
        }
        return accIds;
    }

    public static List<Opportunity> getOpps(List<Id> objectIds, String field)
    {
        List<Opportunity> results = new List<Opportunity>();
        String query = 'SELECT Id, AccountId, Account.Patch__c, PatchLocked__c FROM Opportunity WHERE ' + field + ' IN :objectIds';
        return Database.query(query);
    }

    public static Map<Id, List<AccountTeamMember>> getAcc2TeamMembers(List<Id> accIds)
    {
        //system.debug('getAcc2TeamMembers  '+accIds);
        Map<Id, List<AccountTeamMember>> acc2TeamMembers = new Map<Id, List<AccountTeamMember>>();
        for(AccountTeamMember member : [SELECT Id, AccountId, UserId, TeamMemberRole, OpportunityAccessLevel, AccountAccessLevel, CaseAccessLevel, ContactAccessLevel FROM AccountTeamMember Where AccountId IN:accIds])
        {
            
            //system.debug('the member is' + member);
            
            if(!acc2TeamMembers.containsKey(member.AccountId))
            {
                acc2TeamMembers.put(member.AccountId, new List<AccountTeamMember>{member});
            }
            else
            {
                acc2TeamMembers.get(member.AccountId).add(member);
            }
        }
        return acc2TeamMembers;
    }

    public static void assignSalesTeamMembers(List<Id> objectIds, String type)
    {
        //system.debug('inside assignSalesTeamMembers ');
        Map<Id, List<AccountTeamMember>> acc2TeamMembers = new Map<Id, List<AccountTeamMember>>();
        List<Opportunity> opps = new List<Opportunity>();
        if(type == 'Opportunity')
        {
            List<Id> accIds = getAccIds(objectIds);
            acc2TeamMembers = getAcc2TeamMembers(accIds);
            opps = getOpps(objectIds, 'Id');
        }
        else
        {
            acc2TeamMembers = getAcc2TeamMembers(objectIds);
            opps = getOpps(objectIds, 'AccountId');
        }
        assignSalesTeamMembers(opps, acc2TeamMembers);
    }

    public static void assignSalesTeamMembers(List<Opportunity> opps, Map<Id, List<AccountTeamMember>> acc2TeamMembers)
    {
        //system.debug('inside assignSalesTeamMembers ');
        List<sObject> sharingsAndTeams = new List<sObject>();
        List<sObject> existingSharesAndTeams = getExistingSharings(opps);
        List<sObject> existingSharesAndTeamsToDelete = getExistingSharingsToDelete(existingSharesAndTeams);
        SObjectType oppTeamMemberType = getSObjectType('OpportunityTeamMember');
        if(oppTeamMemberType != null && oppTeamMemberType.getDescribe().isCreateable())
        {
            for(Opportunity opp : opps)
            {
                if(!opp.PatchLocked__c)
                {
                    if(opp.AccountId != null && acc2TeamMembers.containsKey(opp.AccountId))
                    {
                        for(AccountTeamMember member : acc2TeamMembers.get(opp.AccountId))
                        {
                            SObject oppTeamMember = oppTeamMemberType.newSObject();
                            String accessLevel = member.OpportunityAccessLevel == 'None' ? 'Read' : member.OpportunityAccessLevel;
                            oppTeamMember.put('OpportunityId', opp.Id);
                            oppTeamMember.put('UserId', member.UserId);
                            oppTeamMember.put('TeamMemberRole', member.TeamMemberRole);
                            oppTeamMember.put('OpportunityAccessLevel', accessLevel);
                            sharingsAndTeams.add(oppTeamMember);
                        }
                    }
                    opp.Patch__c = opp.Account.Patch__c;
                }
                opp.TriggerPatchAssignment__c = false;
            }
        }
        //SavePoint sp = Database.setSavePoint();
        if(opps.size() > 0)
        {
            try{
                //update opps;
                Database.update(opps, false);
            }
            catch(Exception exp){
                
            }
            mergeTeamMembers(sharingsAndTeams, existingSharesAndTeamsToDelete, existingSharesAndTeams);            
        }
    }

    public static void mergeTeamMembers(List<sObject> sharingsAndTeams, List<sObject> existingSharesAndTeamsToDelete, List<sObject> existingSharesAndTeams)
    {
        // system.debug('inside mergeTeamMembers method');
        // system.debug(' sharingsAndTeams   '+sharingsAndTeams.size());
        // system.debug(' sharingsAndTeams   '+sharingsAndTeams);
        // system.debug('existingSharesAndTeamsToDelete  '+existingSharesAndTeamsToDelete.size());
        // system.debug('existingSharesAndTeamsToDelete  '+existingSharesAndTeamsToDelete);
        SObject item = sharingsAndTeams.size() > 0 ? sharingsAndTeams[0] : existingSharesAndTeamsToDelete.size() > 0 ? existingSharesAndTeamsToDelete[0] : getSObjectType('LeadShare').newSObject();
        List<sObject> sharingsAndTeamsToUpdate = new List<sObject>();
        List<sObject> sharingsAndTeamsToInsert = new List<sObject>();
        if(item instanceOf AccountTeamMember || item instanceOf OpportunityTeamMember)
        {
            String fieldName = item instanceOf AccountTeamMember ? 'AccountId' : 'OpportunityId';
            //system.debug('fieldName   '+fieldName);
            Map<String, sObject> key2Member = getKey2TeamMember(existingSharesAndTeamsToDelete, fieldName);
            //system.debug('key2Member   ' + key2Member);
            
            
            for(sObject member : sharingsAndTeams)
            {
                //system.debug('the sharingsAndTeams member is '+ member);
                String key = member.get(fieldName) + '-' + member.get('UserId');
                if(key2Member.containsKey(key))
                {
                    //if(!isSameSObject(member, key2Member.get(key)))
                    //{
                    member.put('Id', key2Member.get(key).get('Id'));
                    sharingsAndTeamsToUpdate.add(member);
                    //}
                    key2Member.remove(key);
                }
                else
                {
                    //Avoid creating reserved team members again
                    if(!isExisting(existingSharesAndTeams, member, fieldName))
                    {
                        sharingsAndTeamsToInsert.add(member);
                    }
                    else{
                        sharingsAndTeamsToUpdate.add(member);
                    }
                }
            }
            existingSharesAndTeamsToDelete.clear();
            existingSharesAndTeamsToDelete.addAll(key2Member.values());
        }
        else
        {
            sharingsAndTeamsToInsert.addAll(sharingsAndTeams);
        }
        List<sObject> reservedTeamToUpdate = getReservedTeamSharingsToUpdate(existingSharesAndTeams);
        if(!reservedTeamToUpdate.isEmpty()){
            Database.update(reservedTeamToUpdate, false);
        }
        // system.debug('the hare records are existingSharesAndTeamsToDelete Size = ' + existingSharesAndTeamsToDelete.size());
        // system.debug('the hare records are existingSharesAndTeamsToDelete ' + existingSharesAndTeamsToDelete);
        // system.debug('the hare records are sharingsAndTeamsToUpdate Size = ' + sharingsAndTeamsToUpdate.size());
        // system.debug('the hare records are sharingsAndTeamsToUpdate ' + sharingsAndTeamsToUpdate);
        // system.debug('the hare records are sharingsAndTeamsToInsert Size = ' + sharingsAndTeamsToInsert.size());
        // system.debug('the hare records are sharingsAndTeamsToInsert ' + sharingsAndTeamsToInsert);
        
        //delete existingSharesAndTeamsToDelete;
        //insert sharingsAndTeamsToInsert;
        Database.delete(existingSharesAndTeamsToDelete, false);
        //Database.update(sharingsAndTeamsToUpdate, false);
        Database.update(sharingsAndTeamsToUpdate, false);
        Database.insert(sharingsAndTeamsToInsert, false);
    }

    public static Map<String, sObject> getKey2TeamMember(List<sObject> teamMembers, String fieldName)
    {
        Map<String, sObject> key2Member = new Map<String, sObject>();
        for(SObject member : teamMembers)
        {
            key2Member.put(member.get(fieldName) + '-' + member.get('UserId'), member);
        }
        return key2Member;
    }

    public static Boolean isSameSObject(SObject newMember, SObject oldMember)
    {
        Boolean result = true;
        if(newMember.get('TeamMemberRole') != oldMember.get('TeamMemberRole') || newMember.get('OpportunityAccessLevel') != oldMember.get('OpportunityAccessLevel'))
        {
            result = false;
        }
        if(newMember instanceOf AccountTeamMember)
        {
            if(newMember.get('AccountAccessLevel') != oldMember.get('AccountAccessLevel') || newMember.get('CaseAccessLevel') != oldMember.get('CaseAccessLevel') || newMember.get('ContactAccessLevel') != oldMember.get('ContactAccessLevel'))
            {
                result = false;
            }
        }
        return result;
    }

    //Add this method to avoid creating reserved team members again
    public static Boolean isExisting(List<SObject> existingSharesAndTeams, SObject newMember, String fieldName)
    {
        Boolean result = false;
        for(SObject oldMember : existingSharesAndTeams)
        {
            if(newMember.get('UserId') == oldMember.get('UserId') && newMember.get('TeamMemberRole') == oldMember.get('TeamMemberRole') && newMember.get(fieldName) == oldMember.get(fieldName))
            {
                result = true;
            }
        }
        return result;
    }
}