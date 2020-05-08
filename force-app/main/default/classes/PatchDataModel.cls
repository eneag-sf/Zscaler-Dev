global class PatchDataModel
{
    global class PatchInfo
    {
        global PatchInfo()
        {
            members = new List<TeamMemberInfo>();
            rules = new List<RuleInfo>();
        }

        global PatchInfo(Patch__c p)
        {
            this();
            if(p != null)
            {
                this.patchId = p.Id;
                this.patchNumber = p.Name;
                this.name = p.PatchName__c;
                this.active = (p.Active__c == true);
                this.catchall = (p.Catchall__c == true);
                this.ruleLogic = p.RuleLogic__c;
                this.teamId = p.PatchTeam__c;
                this.teamName = p.PatchTeam__r.Name;
                this.assignTeamOnly = p.AssignTeamOnly__c;
                this.timestamp = (p.Timestamp__c == null) ? 0 : p.Timestamp__c.getTime();
                this.sequence = (p.ProcessingSequence__c == null) ? null : p.ProcessingSequence__c.intValue();
                this.type = p.Type__c;
                for(PatchCriteriaRule__c criteria : p.PatchCriteriaRules__r)
                {
                    this.rules.add(new RuleInfo(criteria));
                }
            }
        }
        global Id patchId { get; set; }
        global String patchNumber { get; set; }
        global String name { get; set; }
        global Boolean active { get; set; }
        global Boolean catchall { get; set; }
        global String ruleLogic { get; set; }
        global String teamName { get; set; }
        global String teamId { get; set; }
        global Boolean assignTeamOnly { get; set; }
        global Integer sequence { get; set; }
        global Long timestamp { get; set; }
        global String type { get; set; }
        global String comments { get; set; }
        global List<RuleInfo> rules { get; set; }
        global List<TeamMemberInfo> members { get; set; }

        public Patch__c getSObject()
        {
            Patch__c patch = new Patch__c();
            patch.PatchName__c = name;
            patch.Active__c = active;
            patch.Catchall__c = catchall;
            patch.RuleLogic__c = ruleLogic;
            patch.PatchTeam__c = teamId;
            patch.AssignTeamOnly__c = assignTeamOnly;
            patch.ProcessingSequence__c = sequence;
            patch.Type__c = type;
            patch.Comments__c = comments;
            return patch;
        }

        public PatchInfo deepClone()
        {
            system.debug('inside deepClone method');
            PatchInfo result = new PatchInfo();
            result.patchId = this.patchId;
            result.patchNumber = this.patchNumber;
            result.name = this.name;
            result.active = this.active;
            result.catchall = this.catchall;
            result.ruleLogic = this.ruleLogic;
            result.teamName = this.teamName;
            result.teamId = this.teamId;
            result.assignTeamOnly = this.assignTeamOnly;
            result.sequence = this.sequence;
            result.type = this.type;
            for(RuleInfo rule : this.rules)
            {
                result.rules.add(rule.deepClone());
            }
            for(TeamMemberInfo member : this.members)
            {
                system.debug('inside deepClone method  , member '+member);
                result.members.add(member.clone());
            }
            return result;
        }
    }

    global class RuleInfo
    {
        global RuleInfo()
        {
            matchList = new Set<String>();
        }

        global RuleInfo(PatchCriteriaRule__c criteria)
        {
            this();
            if(criteria != null)
            {
                this.ruleId = criteria.Id;
                this.sequence = (criteria.ProcessingSequence__c == null) ? null : criteria.ProcessingSequence__c.intValue();
                this.field = criteria.Field__c;
                this.operation = criteria.Operation__c;
                this.value = criteria.Value__c;
                this.rangeLow = criteria.RangeLow__c;
                this.rangehigh = criteria.RangeHigh__c;
            }
        }

        global Id ruleId { get; set; }
        global Integer sequence { get; set; }
        global String field { get; set; }
        global String operation { get; set; }
        global String value { get; set; }
        global String rangeLow { get; set; }
        global String rangeHigh { get; set; }
        global Set<String> matchList { get; set; }

        public PatchCriteriaRule__c getSObject(Id patchId)
        {
            PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patchId);
            rule.ProcessingSequence__c = sequence;
            rule.Field__c = field;
            rule.Operation__c = operation;
            rule.Value__c = value;
            rule.RangeLow__c = rangeLow;
            rule.RangeHigh__c = rangeHigh;
            return rule;
        }

        public RuleInfo deepClone()
        {
            RuleInfo result = new RuleInfo();
            result.ruleId = this.ruleId;
            result.sequence = this.sequence;
            result.field = this.field;
            result.operation = this.operation;
            result.value = this.value;
            result.rangeLow = this.rangeLow;
            result.rangeHigh = this.rangeHigh;
            result.matchList.addAll(this.matchList);
            return result;
        }
    }

    global class TeamMemberInfo
    {
        global TeamMemberInfo(Id userId, String role)
        {
            system.debug('inside TeamMemberInfo method  , userId '+userId);
            system.debug('inside TeamMemberInfo method  , role '+role);
            this.role = role;
            this.userId = userId;
        }

        global String role { get; set; }
        global Id userId { get; set; }
    }

    global class MatchTarget
    {
        global MatchTarget(sObject obj)
        {
            system.debug('inside MatchTarget of Patchdatamodel'+obj);
            if(obj != null)
            {
                PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
                system.debug('config   '+config);
                String objName = obj.getSobjectType().getDescribe().getName();
                if(config.criteriaFields.containsKey(objName))
                {
                    Map<String, String> mapping = config.criteriaFields.get(objName);
                    for(String criteriaName : mapping.keyset())
                    {
                        String fieldName = mapping.get(criteriaName);
                        Object fieldValue = getCacasdingFieldValue(obj, fieldName);
                        if(criteriaName == 'Company')
                        {
                            this.company = (String)fieldValue;
                        }
                        else if(criteriaName == 'Country')
                        {
                            this.country = (String)fieldValue;
                        }
                        else if(criteriaName == 'ZipCode')
                        {
                            this.zipCode = (String)fieldValue;
                        }
                        else if(criteriaName == 'State')
                        {
                            this.state = (String)fieldValue;
                        }
                        else if(criteriaName == 'Industry')
                        {
                            this.industry = (String)fieldValue;
                        }
                        else if(criteriaName == 'EmailDomain')
                        {
                            this.emailDomain = getEmailDomain((String)fieldValue);
                        }
                        else if(criteriaName == 'Custom1')
                        {
                            this.custom1 = (String)fieldValue;
                        }
                        else if(criteriaName == 'Custom2')
                        {
                            this.custom2 = (String)fieldValue;
                        }
                        else if(criteriaName == 'Custom3')
                        {
                            this.custom3 = (String)fieldValue;
                        }
                        else if(criteriaName == 'Custom4')
                        {
                            this.custom4 = (String)fieldValue;
                        }
                        else if(criteriaName == 'Custom5')
                        {
                            this.custom5 = (String)fieldValue;
                        }
                        else if(criteriaName == 'Custom6')
                        {
                            this.custom6 = (String)fieldValue;
                        }
                    }
                    system.debug('this '+this);
                    this.locked = (Boolean)obj.get('PatchLocked__c');
                }
                else
                {
                    //throw new PatchException('Setup is not complete. Object[' + objName + '] is not configured');
                }
            }
        }

        global String company { get; set; }
        global String emailDomain { get; set; }
        global String country { get; set; }
        global String zipCode { get; set; }
        global String state { get; set; }
        global String industry { get; set; }
        global String custom1 { get; set; }
        global String custom2 { get; set; }
        global String custom3 { get; set; }
        global String custom4 { get; set; }
        global String custom5 { get; set; }
        global String custom6 { get; set; }
        global Boolean locked { get; set; }

        public List<String> getTargetValues()
        {
            Set<String> values = new Set<String>();
            if(company != null)
            {
                values.add(company.trim());
            }
            if(emailDomain != null)
            {
                values.add(emailDomain.trim());
            }
            if(country != null)
            {
                values.add(country.trim());
            }
            if(zipCode != null)
            {
                values.add(zipCode.trim());
            }
            if(state != null)
            {
                values.add(state.trim());
            }
            if(industry != null)
            {
                values.add(industry.trim());
            }
            if(custom1 != null)
            {
                values.add(custom1.trim());
            }
            if(custom2 != null)
            {
                values.add(custom2.trim());
            }
            if(custom3 != null)
            {
                values.add(custom3.trim());
            }
            if(custom4 != null)
            {
                values.add(custom4.trim());
            }
            if(custom5 != null)
            {
                values.add(custom5.trim());
            }
            if(custom6 != null)
            {
                values.add(custom6.trim());
            }
            values.remove('');
            return new List<String>(values);
        }

        public Boolean isSameTarget(MatchTarget t)
        {
            return this.company == t.company && this.emailDomain == t.emailDomain && this.country == t.country && this.zipCode == t.zipCode && this.state == t.state && this.industry == t.industry && this.custom1 == t.custom1 && this.custom2 == t.custom2 && this.custom3 == t.custom3 && this.custom4 == t.custom4 && this.custom5 == t.custom5 && this.custom6 == t.custom6;
        }

        private String getEmailDomain(String email)
        {
            email = (email == null) ? '' : email;
            return (email.indexOf('@') >= 0) ? email.substring(email.indexOf('@') + 1) : email;
        }

        private Object getCacasdingFieldValue(SObject obj, String field)
        {
            if(String.isBlank(field) || obj == null)
            {
                return null;
            }
            String[] fieldParts = field.split('\\.');
            for(Integer i = 0; i < fieldParts.size() - 1; i++)
            {
                obj = obj.getSObject(fieldParts[i]);
                if(obj == null)
                {
                    return null;
                }
            }
            return obj.get(fieldParts[fieldParts.size() - 1]);
        }
    }

    public class PatchConfig
    {
        public PatchConfig()
        {
            this.allFields = new Map<String, List<String>>();
            this.criteriaFields = new Map<String, Map<String, String>>();
            this.roles = new Map<String, List<TeamMemberRoleConfig>>();
        }

        public Map<String, List<String>> allFields { get; set; }
        public Map<String, Map<String, String>> criteriaFields { get; set; }
        public Map<String, List<TeamMemberRoleConfig>> roles { get; set; }
    }

    public class TeamMemberRoleConfig
    {
        public TeamMemberRoleConfig(String role, String field, String accountAccess, String opportunityAccess, String caseAccess, String contactAccess, Boolean assignOwner)
        {
            this.role = role;
            this.fieldName = field;
            this.accountAccess = accountAccess;
            this.opportunityAccess = opportunityAccess;
            this.caseAccess = caseAccess;
            this.contactAccess = contactAccess;
            this.assignOwnership = (assignOwner == true);
        }

        public String role { get; set; }
        public String fieldName { get; set; }
        public String accountAccess { get; set; }
        public String opportunityAccess { get; set; }
        public String caseAccess { get; set; }
        public String contactAccess { get; set; }
        public Boolean assignOwnership { get; set; }
    }
}