public class PatchConfigurationController 
{
    public PatchConfigurationController()
    {
        textFieldItems = new Map<String, List<SelectOption>>();
        textFieldItems.put('Lead', getFieldsList(new List<Schema.SObjectType> {Schema.Lead.SObjectType}, true));
        textFieldItems.put('Account', getFieldsList(new List<Schema.SObjectType> {Schema.Account.SObjectType}, true));
        textFieldItems.put('Opportunity', getFieldsList(new List<Schema.SObjectType> {Schema.Account.SObjectType, Schema.Opportunity.SObjectType}, true));
        
        userLookupFieldItems = new Map<String, List<SelectOption>>();
        userLookupFieldItems.put('Lead', getFieldsList(new List<Schema.SObjectType> {Schema.Lead.SObjectType}, false));
        
        PatchDataModel.PatchConfig config = PatchRuleHelper.getConfig();
        mappings = new Map<String, List<MappingInfo>>();
        Map<String, String> leadMapping = new Map<String, String>();
        if(config.criteriaFields.containsKey('Lead'))
        {
            leadMapping = config.criteriaFields.get('Lead');
        }
        if(hasAccountTeamEnabled)
        {
            accountTeamRoleItems = getAllAccountRoles();
        }
        if(hasOpportunityTeamEnabled)
        {
            oppTeamRoleItems = getAllOpportunityRoles();
        }
        mappings.put('Lead', new List<MappingInfo> {
                                    new MappingInfo('Company', leadMapping.get('Company')),
                                    new MappingInfo('Country', leadMapping.get('Country')),
                                    new MappingInfo('State', leadMapping.get('State')),
                                    new MappingInfo('ZipCode', leadMapping.get('ZipCode')),
                                    new MappingInfo('EmailDomain', leadMapping.get('EmailDomain')),
                                    new MappingInfo('Industry', leadMapping.get('Industry')),
                                    new MappingInfo('Custom1', leadMapping.get('Custom1')),
                                    new MappingInfo('Custom2', leadMapping.get('Custom2')),
                                    new MappingInfo('Custom3', leadMapping.get('Custom3')),
                                    new MappingInfo('Custom4', leadMapping.get('Custom4')),
                                    new MappingInfo('Custom5', leadMapping.get('Custom5')),
                                    new MappingInfo('Custom6', leadMapping.get('Custom6'))
        });
        Map<String, String> accMapping = new Map<String, String>();
        if(config.criteriaFields.containsKey('Account'))
        {
            accMapping = config.criteriaFields.get('Account');
        }
        mappings.put('Account', new List<MappingInfo> {
                                    new MappingInfo('Company', accMapping.get('Company')),
                                    new MappingInfo('Country', accMapping.get('Country')),
                                    new MappingInfo('State', accMapping.get('State')),
                                    new MappingInfo('ZipCode', accMapping.get('ZipCode')),
                                    new MappingInfo('EmailDomain', accMapping.get('EmailDomain')),
                                    new MappingInfo('Industry', accMapping.get('Industry')),
                                    new MappingInfo('Custom1', accMapping.get('Custom1')),
                                    new MappingInfo('Custom2', accMapping.get('Custom2')),
                                    new MappingInfo('Custom3', accMapping.get('Custom3')),
                                    new MappingInfo('Custom4', accMapping.get('Custom4')),
                                    new MappingInfo('Custom5', accMapping.get('Custom5')),
                                    new MappingInfo('Custom6', accMapping.get('Custom6'))
        });
        Map<String, String> oppMapping = new Map<String, String>();
        if(config.criteriaFields.containsKey('Opportunity'))
        {
            oppMapping = config.criteriaFields.get('Opportunity');
        }
        mappings.put('Opportunity', new List<MappingInfo> {
                                    new MappingInfo('Company', oppMapping.get('Company')),
                                    new MappingInfo('Country', oppMapping.get('Country')),
                                    new MappingInfo('State', oppMapping.get('State')),
                                    new MappingInfo('ZipCode', oppMapping.get('ZipCode')),
                                    new MappingInfo('EmailDomain', oppMapping.get('EmailDomain')),
                                    new MappingInfo('Industry', oppMapping.get('Industry')),
                                    new MappingInfo('Custom1', oppMapping.get('Custom1')),
                                    new MappingInfo('Custom2', oppMapping.get('Custom2')),
                                    new MappingInfo('Custom3', oppMapping.get('Custom3')),
                                    new MappingInfo('Custom4', oppMapping.get('Custom4')),
                                    new MappingInfo('Custom5', oppMapping.get('Custom5')),
                                    new MappingInfo('Custom6', oppMapping.get('Custom6'))
        });
        
        roles = new Map<String, List<MappingInfo>> { 'Lead' => new List<MappingInfo>(), 'Account' => new List<MappingInfo>(), 'Opportunity' => new List<MappingInfo>()};
        List<PatchDataModel.TeamMemberRoleConfig> roleConfigs = new List<PatchDataModel.TeamMemberRoleConfig>();
        if(config.roles.containsKey('Lead'))
        {
            roleConfigs = config.roles.get('Lead');
        }
        for(String role : getAllRoles())
        {
            Boolean added = false;
            for(PatchDataModel.TeamMemberRoleConfig roleConfig : roleConfigs)
            {
                if(roleConfig.role == role)
                {
                    roles.get('Lead').add(new MappingInfo(role, roleConfig.fieldName, roleConfig.accountAccess, roleConfig.opportunityAccess, roleConfig.caseAccess, roleConfig.contactAccess, roleConfig.assignOwnership));
                    added = true;
                    break;
                }
            }
            if(!added)
            {
                roles.get('Lead').add(new MappingInfo(role, '', '', '', '', '', false));
            }
        }
        roleConfigs = new List<PatchDataModel.TeamMemberRoleConfig>();
        if(config.roles.containsKey('Account'))
        {
            roleConfigs = config.roles.get('Account');
        }
        for(String role : getAllRoles())
        {
            Boolean added = false;
            for(PatchDataModel.TeamMemberRoleConfig roleConfig : roleConfigs)
            {
                if(roleConfig.role == role)
                {
                    roles.get('Account').add(new MappingInfo(role, roleConfig.fieldName, roleConfig.accountAccess, roleConfig.opportunityAccess, roleConfig.caseAccess, roleConfig.contactAccess, roleConfig.assignOwnership));
                    added = true;
                    break;
                }
            }
            if(!added)
            {
                roles.get('Account').add(new MappingInfo(role, '', '', '', '', '', false));
            }
        }
        roleConfigs = new List<PatchDataModel.TeamMemberRoleConfig>();
        if(config.roles.containsKey('Opportunity'))
        {
            roleConfigs = config.roles.get('Opportunity');
        }
        for(String role : getAllRoles())
        {
            Boolean added = false;
            for(PatchDataModel.TeamMemberRoleConfig roleConfig : roleConfigs)
            {
                if(roleConfig.role == role)
                {
                    roles.get('Opportunity').add(new MappingInfo(role, roleConfig.fieldName, roleConfig.accountAccess, roleConfig.opportunityAccess, roleConfig.caseAccess, roleConfig.contactAccess, roleConfig.assignOwnership));
                    added = true;
                    break;
                }
            }
            if(!added)
            {
                roles.get('Opportunity').add(new MappingInfo(role, '', '', '', '', '', false));
            }
        }
    }
    
    public Map<String, List<SelectOption>> textFieldItems { get; set; }
    public Map<String, List<SelectOption>> userLookupFieldItems { get; set; }
    public List<SelectOption> accountTeamRoleItems { get; set; }
    public List<SelectOption> oppTeamRoleItems { get; set; }
    public Map<String, List<MappingInfo>> mappings { get; set; }
    public Map<String, List<MappingInfo>> roles { get; set; }
    public MappingInfo templeMapping  { get; set; }
    
    public Boolean hasLeadShareEnabled 
    {
        get
        {
            Schema.SObjectType leadShareType = PatchRuleHelper.getSObjectType('LeadShare');
            return leadShareType != null && leadShareType.getDescribe().isCreateable();
        }
    }
    
    public Boolean hasAccountTeamEnabled
    {
        get
        {
            return PatchRuleHelper.getSObjectType('AccountTeamMember') != null;
        }
    }
    
    public Boolean hasOpportunityTeamEnabled 
    {
        get
        {
            return PatchRuleHelper.getSObjectType('OpportunityTeamMember') != null;
        }
    }
    
    public PageReference save()
    {
        PatchDataModel.PatchConfig config = new PatchDataModel.PatchConfig();
        config.criteriaFields.put('Lead', new Map<String, String>());
        for(MappingInfo mapping : mappings.get('Lead'))
        {
            config.criteriaFields.get('Lead').put(mapping.key, mapping.value);
        }
        config.criteriaFields.put('Account', new Map<String, String>());
        for(MappingInfo mapping : mappings.get('Account'))
        {
            config.criteriaFields.get('Account').put(mapping.key, mapping.value);
        }
        config.criteriaFields.put('Opportunity', new Map<String, String>());
        for(MappingInfo mapping : mappings.get('Opportunity'))
        {
            config.criteriaFields.get('Opportunity').put(mapping.key, mapping.value);
        }
        config.criteriaFields.get('Opportunity').put('', 'Account.PatchLocked__c');
        
        config.roles.put('Lead', new List<PatchDataModel.TeamMemberRoleConfig>());
        for(MappingInfo mapping : roles.get('Lead'))
        {
            config.roles.get('Lead').add(new PatchDataModel.TeamMemberRoleConfig(mapping.key, mapping.value, mapping.accountAccess, mapping.opportunityAccess, mapping.caseAccess, mapping.contactAccess, mapping.addBool));
        }
        config.roles.put('Account', new List<PatchDataModel.TeamMemberRoleConfig>());
        for(MappingInfo mapping : roles.get('Account'))
        {
            config.roles.get('Account').add(new PatchDataModel.TeamMemberRoleConfig(mapping.key, mapping.value, mapping.accountAccess, mapping.opportunityAccess, mapping.caseAccess, mapping.contactAccess, mapping.addBool));
        }
        config.roles.put('Opportunity', new List<PatchDataModel.TeamMemberRoleConfig>());
        for(MappingInfo mapping : roles.get('Opportunity'))
        {
            config.roles.get('Opportunity').add(new PatchDataModel.TeamMemberRoleConfig(mapping.key, mapping.value, mapping.accountAccess, mapping.opportunityAccess, mapping.caseAccess, mapping.contactAccess, mapping.addBool));
        }
        try
        {
            PatchRuleHelper.saveConfig(config);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Configuraiton saved.'));
        }
        catch(PatchException ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }

    public List<SelectOption> getAllAccessLevels()
    {
        List<SelectOption> result = new List<SelectOption> { new SelectOption('', '- none -') };
        result.add(new SelectOption('Read Only', 'Read Only'));
        result.add(new SelectOption('Read / Write', 'Read / Write'));
        return result;
    }

    public void retrieveTeamMemberPermissions()
    {
        String obj = Apexpages.currentPage().getParameters().get('obj');
        String value = Apexpages.currentPage().getParameters().get('value');
        for(MappingInfo m : roles.get(obj))
        {
            if(m.key == value)
            {
                templeMapping = new Mappinginfo(m.key, m.value);
                templeMapping.accountAccess = m.accountAccess;
                templeMapping.opportunityAccess = m.opportunityAccess;
                templeMapping.caseAccess = m.caseAccess;
                templeMapping.contactAccess = m.contactAccess;
                templeMapping.obj = obj;
            }
        }
    }

    public void saveTeamMemberPermissions()
    {
        String obj =templeMapping.obj;
        String key = templeMapping.key;
        for(MappingInfo m : roles.get(obj))
        {
            if(m.key == key)
            {
                m.accountAccess = templeMapping.accountAccess;
                m.opportunityAccess = templeMapping.opportunityAccess;
                m.caseAccess = templeMapping.caseAccess;
                m.contactAccess = templeMapping.contactAccess;
            }
        }
    }
    
    private List<String> getAllRoles()
    {
        List<String> result = new List<String>();
        Schema.DescribeFieldResult describe = Schema.SObjectType.PatchTeamMember__c.fields.Role__c;
        for(Schema.PicklistEntry entry : describe.getPicklistValues())
        {
            result.add(entry.getValue());
        }
        return result;
    }

    private List<SelectOption> getAllOpportunityRoles()
    {
        List<SelectOption> result = new List<SelectOption> { new SelectOption('', '- select a role -') };
        Schema.DescribeFieldResult field = PatchRuleHelper.getSObjectField('OpportunityTeamMember', 'TeamMemberRole').getDescribe();
        for(Schema.PicklistEntry entry : field.getPicklistValues())
        {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return result;
    }
    
    private List<SelectOption> getAllAccountRoles()
    {
        List<SelectOption> result = new List<SelectOption> { new SelectOption('', '- select a role -') };
        Schema.DescribeFieldResult field = PatchRuleHelper.getSObjectField('AccountTeamMember', 'TeamMemberRole').getDescribe();
        for(Schema.PicklistEntry entry : field.getPicklistValues())
        {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return result;
    }
    
    private List<SelectOption> getFieldsList(List<Schema.SObjectType> objTypes, Boolean text)
    {
        List<SelectOption> fields = (text) ? getAllTextFields(objTypes) : getAllUserLookupFields(objTypes);
        for(Integer i = 0; i < fields.size(); i++)
        {
            for(Integer j = i + 1; j < fields.size(); j++)
            {
                if(fields[i].getLabel() > fields[j].getLabel())
                {
                    SelectOption t = fields[j];
                    fields[j] = fields[i];
                    fields[i] = t;
                }
            }
        }
        fields.add(0, new SelectOption('', '-- None --'));
        return fields;
    }
    
    private List<SelectOption> getAllTextFields(List<Schema.SObjectType> objTypes)
    {
        List<SelectOption> result = new List<SelectOption>();
        for(Schema.SObjectType objType : objTypes)
        {
            Schema.DescribeSObjectResult describe = objType.getDescribe();
            Map<String, Schema.SObjectField> fields = describe.fields.getMap();
            for(String fieldName : fields.keyset())
            {
                Schema.DescribeFieldResult field = fields.get(fieldName).getDescribe();
                Schema.DisplayType fieldType = field.getType();
                if(fieldType == Schema.DisplayType.Email || fieldType == Schema.DisplayType.Picklist || fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea)
                {
                    if(objTypes.size() > 1)
                    {
                        result.add(new SelectOption(describe.getName() + '.' + field.getName(), describe.getName() + '.' + field.getLabel()));
                    }
                    else
                    {
                        result.add(new SelectOption(field.getName(), field.getLabel()));
                    }
                }
            }
        }
        return result;
    }
    
    private List<SelectOption> getAllUserLookupFields(List<Schema.SObjectType> objTypes)
    {
        List<SelectOption> result = new List<SelectOption>();
        for(Schema.SObjectType objType : objTypes)
        {
            Schema.DescribeSObjectResult describe = objType.getDescribe();
            Map<String, Schema.SObjectField> fields = describe.fields.getMap();
            for(String fieldName : fields.keyset())
            {
                Schema.DescribeFieldResult field = fields.get(fieldName).getDescribe();
                if(field.getReferenceTo().size() == 1 && field.getReferenceTo()[0] == Schema.User.SObjectType && field.isUpdateable())
                {
                    if(objTypes.size() > 1)
                    {
                        result.add(new SelectOption(describe.getName() + '.' + field.getName(), describe.getName() + '.' + field.getLabel()));
                    }
                    else
                    {
                        result.add(new SelectOption(field.getName(), field.getLabel()));
                    }
                }
            }
        }
        return result;
    }
    
    public class MappingInfo
    {
        public MappingInfo(String key, String value)
        {
            this.key = key;
            this.value = value;
        }
        public MappingInfo(String key, String value, String accountAccess, String opportunityAccess, String caseAccess, String contactAccess, Boolean addBool)
        {
            this(key, value);
            this.accountAccess = accountAccess;
            this.opportunityAccess = opportunityAccess;
            this.caseAccess = caseAccess;
            this.contactAccess = contactAccess;
            this.addBool = addBool;
        }
        
        public String obj { get; set; }
        public String key { get; set; }
        public String value { get; set; }
        public String accountAccess { get; set; }
        public String opportunityAccess { get; set; }
        public String caseAccess { get; set; }
        public String contactAccess { get; set; }
        public Boolean addBool { get; set; }
    }
    
    
}