/*
 * Builds the PatchRuleEngine according to existing Patch and PatchCriteriaRule records
 */
public class PatchRuleEngineBuilder
{
    private String headerComment;
    private String classHeader;
    private List<String> methods;
    private List<String> subclasses;
    private List<String> variables;
    private static final Integer NumberOfPatchesInEachMethod = 35;
    //private Map<Id, Set<String>> matchlistRepo;

    private String engineIndex;
    private List<Patch__c> patchesForBuild;

    public PatchRuleEngineBuilder(String engineIndex, List<Patch__c> patches)
    {
        headerComment = '/*\r\n' +
                        ' * This class is generated dynamically from Patch Rules.\r\n' +
                        ' */\r\n';
        classHeader = 'global class PatchRuleEngine' + engineIndex + ' extends ' + PatchRuleHelper.NamespaceClassPrefix + ' PatchRuleEngineBase implements '+ PatchRuleHelper.NamespaceClassPrefix +'IPatchRuleEngine\r\n';
        methods = new List<String>();
        subclasses = new List<String>();
        variables = new List<String>();
        //matchlistRepo = new Map<Id, Set<String>>();
        /*for(PatchMatchList__c pml : [select Id, Name, PatchCriteriaRule__c from PatchMatchList__c])
        {
            if(matchlistRepo.containsKey(pml.PatchCriteriaRule__c))
            {
                matchlistRepo.get(pml.PatchCriteriaRule__c).add(pml.Name);
            }
            else
            {
                matchlistRepo.put(pml.PatchCriteriaRule__c, new Set<String> {pml.Name});
            }
        }*/

        this.engineIndex = engineIndex;
        this.patchesForBuild = patches;
    }
    
    public String build()
    {
        registerMainMethod();
        //registerOpMethods(); //methods in function is inherited from PatchRuleEngineBase class.
        registerSubClasses();
        //registerVariables(); //methods in function is inherited from PatchRuleEngineBase class.
        String result = headerComment + 
                        classHeader + 
                        '{\r\n';
        for(String variableBody : variables)
        {
            result += variableBody;
        }
        for(String methodBody : methods)
        {
            result += methodBody;
        }
        for(String subclassBody : subclasses)
        {
            result += subclassBody;
        }
        result += '}';
        return result;
    }

    public String buildTestCoverage()
    {
        return '@isTest\r\n' + 
                'public class PatchRuleEngineTest' + engineIndex + '\r\n' +
                '{\r\n' +
                '    @isTest static void testMatch()\r\n' +
                '    {\r\n' +
                '        '+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.MatchTarget t = new '+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.MatchTarget(null);\r\n' +
                '        PatchRuleEngine' + engineIndex + ' engine = new PatchRuleEngine' + engineIndex + '();\r\n' +
                '        engine.match(t);\r\n' +
                '    }\r\n\r\n' +    
                '    @isTest static void testOp()\r\n' +
                '    {\r\n' +
                '        ' + PatchRuleHelper.NamespacePrefix + 'Patch__c patch = new ' + PatchRuleHelper.NamespacePrefix + 'Patch__c(' + PatchRuleHelper.NamespacePrefix + 'PatchName__c=\'acme\', ' + PatchRuleHelper.NamespacePrefix + 'Active__c=true);\r\n' +
                '        insert patch;\r\n' +
                '        PatchRuleEngine' + engineIndex + ' engine = new PatchRuleEngine' + engineIndex + '();\r\n' +
                '        engine.processResult(patch.Id);\r\n' +
                '        System.assert(engine.opIn(\'a\', new Set<String> {\'a\', \'b\'}));\r\n' +
                '        System.assert(engine.opInRange(\'11111\', \'00000\', \'22222\'));\r\n' +
                '        System.assert(engine.opInRange(\'90145\', \'00000\', \'90200\'));\r\n' +
                '        System.assert(engine.opEqual(\'a\', \'A\'));\r\n' +
                '        System.assert(engine.opStart(\'abcd\', new Set<String> {\'a\'}));\r\n' +
                '        System.assert(engine.opEnd(\'dcba\', new Set<String> {\'a\'}));\r\n' +
                '        System.assert(engine.opContain(\'abcd\', \'A\')); \r\n' +
                '    }\r\n' +
                '}';
    }
    
    private void registerMainMethod()
    {
        String methodHeader = '  //returns the matched patch\r\n' +
                              '  global '+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo match('+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.MatchTarget t)\r\n' +
                              '  {\r\n';
        String methodBody = '    Id result = null;\r\n';
        methodBody += '    prematches = prematchList(t);\r\n';

        List<Id> patchIds = new List<Id>();
        Map<Id, PatchDataModel.PatchInfo> patchId2PatchInfo = new Map<Id, PatchDataModel.PatchInfo>();
        for(Patch__c p : patchesForBuild)
        {
            patchIds.add(p.Id);
        }
        List<PatchDataModel.PatchInfo> allPatchInfos = PatchRuleHelper.getPatches(patchIds);
        for(PatchDataModel.PatchInfo info : allPatchInfos)
        {
            patchId2PatchInfo.put(info.patchId, info);
        }
                
        List<PatchDataModel.PatchInfo> patchInfos = new List<PatchDataModel.PatchInfo>();
        Integer groupIndex = 0;
        for(Patch__c p : patchesForBuild)
        {
            patchInfos.add(patchId2PatchInfo.get(p.Id));
            
            if(patchInfos.size() >= NumberOfPatchesInEachMethod)
            {
                methodBody += buildPatchGroup(patchInfos, ++groupIndex);
                patchInfos.clear();
            }
        }
        if(patchInfos.size() >= 0)
        {
            methodBody += buildPatchGroup(patchInfos, ++groupIndex);
            patchInfos.clear();
        }
        String methodFooter = '    return null;\r\n  }\r\n';
        methods.add(methodHeader + methodBody + methodFooter);
    }
    
    private void registerGroupMatchMethod(List<PatchDataModel.PatchInfo> patches, Integer groupNumber)
    {
        String body = '  private Id matchGroup' + groupNumber + '('+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.MatchTarget t)\r\n' +
                      '  {\r\n';
        Integer i = 0;
        for(PatchDataModel.PatchInfo patch : patches)
        {
            body += buildPatch(patch, i++);
        }
        body += '    return null;\r\n  }\r\n';
        methods.add(body);
    }
    
    private String buildPatchGroup(List<PatchDataModel.PatchInfo> patches, Integer groupNumber)
    {
        String methodBody = '    result = matchGroup' + groupNumber + '(t);\r\n' +
                            '    if(result != null) return processResult(result);\r\n';
        registerGroupMatchMethod(patches, groupNumber);
        return methodBody;
    }
    
    private String buildPatch(PatchDataModel.PatchInfo patch, Integer patchNumber)
    {
        String body = '';
        Map<Integer, String> rules = new Map<Integer, String>();
        for(Integer j = 0; j < patch.rules.size(); j++)
        {
            PatchDataModel.RuleInfo rule = patch.rules[j];
            if(rule.sequence == null)
            {
                throw new PatchException('One of the rule has empty processing sequence. Patch[' + patch.patchId+ ']');
            }
            if(isListOperation(rule.operation))
            {
                //body += '    ' + buildRuleList(rule) + '\r\n';
            }
            rules.put(rule.sequence, buildRule(patch, rule));
        }
        body += buildCriteria(patch, rules, patchNumber);
        return body;
    }
    
    private String buildCriteria(PatchDataModel.PatchInfo patch, Map<Integer, String> rules, Integer patchNumber)
    {
        String body = '';
        if(rules.keyset().size() > 0)
        {
            body += '    if(';
            if(String.isBlank(patch.ruleLogic))
            {
                for(String ruleName : rules.values())
                {
                    body += ruleName + ' && ';
                }
                body = body.substring(0, body.length() - 4);
            }
            else
            {
                Map<String, String> operatorConversions = new Map<String, String> {
                    'AND' => ' && ',
                    'OR' => ' || ',
                    'NOT' => ' !'
                };
                String ruleLogic = '';
                for(String logicSegment : patch.ruleLogic.toUpperCase().splitByCharacterType())
                {
                    if(logicSegment.isNumeric())
                    {
                        Integer ruleNumber = -1;
                        try
                        {
                            ruleNumber = Integer.valueOf(logicSegment);
                        }
                        catch(Exception ex)
                        {
                            throw new PatchException('Unrecognizable Processing Sequence: ' + logicSegment + ' in patch [' + patch.patchId + ']');
                        }
                        if(rules.containsKey(ruleNumber))
                        {
                            ruleLogic += rules.get(ruleNumber);
                        }
                        else
                        {
                            throw new PatchException('Processing Sequence does not exist: ' + logicSegment + ' in patch [' + patch.patchId + ']');
                        }
                    }
                    else if(String.isNotBlank(logicSegment))
                    {
                        if(operatorConversions.containsKey(logicSegment))
                        {
                            ruleLogic += operatorConversions.get(logicSegment);
                        }
                        else
                        {
                            ruleLogic += logicSegment;
                        }
                    }
                }
                body += ruleLogic;
            }
            body += ')';
            body += (patch.assignTeamOnly)? '      overlayingPatchIds.add(\'' + patch.patchId + '\');\r\n' : '      return \'' + patch.patchId + '\'; //Patch ' + patch.name + '\r\n';
        }
        else
        {
            if(patch.Catchall)
            {
                body += '    return \'' + patch.PatchId + '\'; //Patch ' + patch.name + '\r\n';
            }
            else
            {
                body += '    //Empty rule criteria. Patch ' + patch.name + '\r\n';
            }
        }
        return body;
    }
    
    private String buildValueList(PatchDataModel.RuleInfo rule)
    {
        String result = 'new Set<String> { ';
        String notNullValue = (rule.value == null) ? '' : rule.value;
        Set<String> addedValues = new Set<String>();
        for(String value : PatchRuleHelper.splitCsv(notNullValue))
        {
            value = value.replaceAll('’', '\'');
            value = String.escapeSingleQuotes(value).toLowerCase();
            if(!addedValues.contains(value))
            {
                addedValues.add(value);
                result += '\'' + value + '\', ';
            }
        }
        if(result.endsWith(', '))
        {
            result = result.substring(0, result.length() - 2);
        }
        result += ' }';
        return result;
    }
    
    /*private String buildMatchList(PatchDataModel.RuleInfo rule)
    {
        String result = 'new Set<String> { ';
        Set<String> addedValues = new Set<String>();
        if(matchlistRepo.containsKey(rule.ruleId))
        {
            for(String matchItem : matchlistRepo.get(rule.ruleId))
            {
                String value = String.isBlank(matchItem) ? '' : matchItem;
                value = value.replaceAll('’', '\'');
                value = String.escapeSingleQuotes(matchItem).toLowerCase();
                if(!addedValues.contains(value))
                {
                    addedValues.add(value);
                    result += '\'' + value + '\', ';
                }
            }
            if(result.endsWith(', '))
            {
                result = result.substring(0, result.length() - 2);
            }
        }
        result += ' }';
        return result;
    }*/
    
    private String buildZipcodeList(PatchDataModel.RuleInfo rule)
    {
        Set<String> values = new Set<String>();
        String entry = rule.value;
        entry = (entry == null) ? '' : entry;
        values.addAll(entry.split('\\s*,\\s*'));

        List<String> altValues = new List<String>(values);
        altValues.sort();
        String result = '';
        String low = '', high = '';
        for(String value : altValues)
        {
            if(!value.isNumeric())
            {
                result += value + ',';
                continue;
            }
            if(String.isBlank(low))
            {
                low = value;
                high = value;
            }
            else if(Integer.valueOf(high) + 1 == Integer.valueOf(value))
            {
                high = value;
            }
            else
            {
                result += (low == high) ? low + ',' : low + '~' + high + ',';
                low = high = value;
            }
        }
        result += (low == high) ? low + ',' : low + '~' + high + ',';
        result = result.removeEnd(',');
        return result;
    }
    
    private String buildRule(PatchDataModel.PatchInfo patch, PatchDataModel.RuleInfo rule)
    {
        Map<String, String> opMap = new Map<String, String> {
                                                                'equals' => 'opEqual', 'not equal to' => '!opEqual',
                                                                'in' => 'opIn', 'not in' => '!opIn',
                                                                'starts with' => 'opStart', 'not starts with' => '!opStart',
                                                                'ends with' => 'opEnd', 'not ends with' => '!opEnd',
                                                                'contains' => 'opContain', 'not contains' => '!opContain',
                                                                'in range' => 'opInRange',
                                                                'in match list' => 'opIn'
                                                            };
        Map<String, String> fieldMap = new Map<String, String> {
                                                                    'Company Name' => 't.company',
                                                                    'Email Domain' => 't.emailDomain',
                                                                    'Country' => 't.country',
                                                                    'Zip Code' => 't.zipCode',
                                                                    'State' => 't.state',
                                                                    'Industry' => 't.industry',
                                                                    'Custom1' => 't.custom1',
                                                                    'Custom2' => 't.custom2',
                                                                    'Custom3' => 't.custom3',
                                                                    'Custom4' => 't.custom4',
                                                                    'Custom5' => 't.custom5',
                                                                    'Custom6' => 't.custom6'
                                                                };
        if(!opMap.containsKey(rule.operation))
        {
            throw new PatchException('Operation cannot be recognized: ' + rule.operation + '. Patch[' + patch.name + ']');
        }
        if(!fieldMap.containsKey(rule.field))
        {
            throw new PatchException('Rule Criteria cannot be recognized: ' + rule.field + '. Patch[' + patch.name + ']');
        }
        
        String field = fieldMap.get(rule.field);
        String methodName = opMap.get(rule.operation);
        if(rule.field == 'Zip Code' && (rule.operation == 'in' || rule.operation == 'not in'))
        {
            methodName = (rule.operation == 'not in') ? '!opZipcode' : 'opZipcode';
            return methodName + '(' + field + ', \'' + buildZipcodeList(rule) + '\')';
        }
        else if(rule.operation == 'in range')
        {
            String valueLow = (rule.rangeLow == null) ? 'null' : String.escapeSingleQuotes(rule.rangeLow);
            String valueHigh = (rule.rangeHigh == null) ? 'null' : String.escapeSingleQuotes(rule.rangeHigh);
            return methodName + '(' + field + ', \'' + valueLow + '\', \'' + valueHigh + '\')';
        }
        else if(rule.operation == 'in match list')
        {
            //return methodName + '(' + field + ', ' + buildMatchList(rule) + ')';
            return 'prematches.get(\'' + rule.field + '\').contains(\'' + rule.ruleId + '\')';
        }
        else if(isListOperation(rule.operation))
        {
            return methodName + '(' + field + ', ' + buildValueList(rule) + ')';
        }
        else //equals, contains
        {
            String value = (rule.value == null) ? '' : String.escapeSingleQuotes(rule.value);
            return methodName + '(' + field + ', \'' + value + '\')';
        }
    }
    
    private void registerSubClasses()
    {
    }
    
    //Obsolete. Replaced by PatchRuleEngineBase class
    /*
    private void registerOpMethods()
    {
        methods.add(
               '  @testvisible\r\n' +
               '  private Map<String, Set<Id>> prematchList(' + PatchRuleHelper.NamespaceClassPrefix + 'PatchDataModel.MatchTarget t)\r\n' +
               '  {\r\n' +
               '    Map<String, Set<Id>> result = new Map<String, Set<Id>>{ \'Company Name\' => new Set<Id>(), \'Country\' => new Set<Id>(), \'Zip Code\' => new Set<Id>(), \'State\' => new Set<Id>(), \'Industry\' => new Set<Id>(),\'Email Domain\' => new Set<Id>(),\'Custom1\' => new Set<Id>(), \'Custom2\' => new Set<Id>(), \'Custom3\' => new Set<Id>(), \'Custom4\' => new Set<Id>(), \'Custom5\' => new Set<Id>(), \'Custom6\' => new Set<Id>() };\r\n' +
               '    for(PatchMatchList__c prematch : [select Name, PatchCriteriaRule__c from PatchMatchList__c where Name in :t.getTargetValues()])\r\n' +
               '    {\r\n' +
               '      if(prematch.Name == t.company)\r\n' +
               '      {\r\n' +
               '        result.get(\'Company Name\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.country)\r\n' +
               '      {\r\n' +
               '        result.get(\'Country\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.zipCode)\r\n' +
               '      {\r\n' +
               '        result.get(\'Zip Code\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.state)\r\n' +
               '      {\r\n' +
               '        result.get(\'State\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.industry)\r\n' +
               '      {\r\n' +
               '        result.get(\'Industry\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.emailDomain)\r\n' +
               '      {\r\n' +
               '        result.get(\'Email Domain\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom1)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom1\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom2)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom2\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom3)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom3\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom4)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom4\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom5)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom5\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '      if(prematch.Name == t.custom6)\r\n' +
               '      {\r\n' +
               '        result.get(\'Custom6\').add(prematch.PatchCriteriaRule__c);\r\n' +
               '      }\r\n' +
               '    }\r\n' +
               '    return result;\r\n' +
               '  }\r\n');
        methods.add( 
               '  @testvisible\r\n' +
               '  private Boolean opIn(String value, Set<String> targetSet) \r\n' +
               '  {\r\n' +
               '    value = (value == null) ? null : value.toLowerCase();\r\n' +
               '    return targetSet.contains(value);\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private Boolean opInRange(String value, String targetLow, String targetHigh)\r\n' +
               '  {\r\n' +
               '    value = (value == null) ? \'\' : value.toLowerCase();\r\n' +
               '    targetLow = (targetLow == null) ? \'\' : targetLow.toLowerCase();\r\n' +
               '    targetHigh = (targetHigh == null) ? \'\' : targetHigh.toLowerCase();\r\n' +
               '    if(value.length() < targetLow.length() || value.length() < targetHigh.length())\r\n' +
               '    {\r\n' +
               '      return false;\r\n' +
               '    }\r\n' +
               '    else\r\n' +
               '    {\r\n' +
               '      return value.substring(0, targetLow.length()) >= targetLow && value.substring(0, targetHigh.length()) <= targetHigh;\r\n' +
               '    }\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private Boolean opEqual(String value, String target)\r\n' +
               '  {\r\n' +
               '    return value == target || (String.IsBlank(target) && String.isBlank(value));\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private Boolean opStart(String value, Set<String> targetSet)\r\n' +
               '  {\r\n' +
               '    value = (value == null) ? \'\' : value.toLowerCase();\r\n' +
               '    for(String t : targetSet)\r\n' +
               '    {\r\n' +
               '      if(value.startsWith(t))\r\n' +
               '      {\r\n' +
               '         return true;\r\n' +
               '      }\r\n' +
               '    }\r\n' +
               '    return false;\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private Boolean opEnd(String value, Set<String> targetSet)\r\n' +
               '  {\r\n' +
               '    value = (value == null) ? \'\' : value.toLowerCase();\r\n' +
               '    for(String t : targetSet)\r\n' +
               '    {\r\n' +
               '      if(value.endsWith(t))\r\n' +
               '      {\r\n' +
               '         return true;\r\n' +
               '      }\r\n' +
               '    }\r\n' +
               '    return false;\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private Boolean opContain(String value, String target)\r\n' +
               '  {\r\n' +
               '    value = (value == null) ? \'\' : value.toLowerCase();\r\n' +
               '    target = (target == null) ? \'\' : target.toLowerCase();\r\n' +
               '    return value.contains(target);\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  public static Boolean opZipcode(String zipcode, String target)\r\n' +
               '  {\r\n' +
               '    zipcode = (zipcode == null) ? \'\' : zipcode.replaceAll(\'\\\\s\', \'\');\r\n' +
               '    target = (target == null) ? \'\' : target.replaceAll(\'\\\\s\', \'\');\r\n' +
               '    for(String segment : target.split(\',\'))\r\n' +
               '    {\r\n' +
               '      if(!segment.contains(\'~\'))\r\n' +
               '      {\r\n' +
               '        if(zipcode.startsWith(segment))\r\n' +
               '        {\r\n' +
               '          return true;\r\n' +
               '        }\r\n' +
               '      }\r\n' +
               '      else\r\n' +
               '      {\r\n' +
               '        String[] range = segment.split(\'~\');\r\n' +
               '        if(zipcode >= range[0] && zipcode <= range[1])\r\n' +
               '        {\r\n' +
               '          return true;\r\n' +
               '        }\r\n' +
               '      }\r\n' +
               '    }\r\n' +
               '    return false;\r\n' +
               '  }\r\n');
        methods.add(
               '  @testvisible\r\n' +
               '  private '+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo processResult(Id patchId)\r\n' +
               '  {\r\n' +
               '    '+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo result = '+ PatchRuleHelper.NamespaceClassPrefix +'PatchRuleHelper.getPatch(patchId);\r\n' +
               '    List<'+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo> overlayingPatches = (overlayingPatchIds.size() > 0) ? '+ PatchRuleHelper.NamespaceClassPrefix +'PatchRuleHelper.getPatches(overlayingPatchIds) : new List<'+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo>();\r\n' +
               '    for('+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.PatchInfo overlay : overlayingPatches)\r\n' +
               '    {\r\n' +
               '      for('+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.TeamMemberInfo overlayingMember : overlay.members)\r\n' +
               '      {\r\n' +
               '        Boolean exist = false;\r\n' +
               '        for('+ PatchRuleHelper.NamespaceClassPrefix +'PatchDataModel.TeamMemberInfo member : result.members)\r\n' +
               '        {\r\n' +
               '          if(member.userId == overlayingMember.userId)\r\n' +
               '          {\r\n' +
               '            exist = true;\r\n' +
               '            break;\r\n' +
               '          }\r\n' +
               '        }\r\n' +
               '        if(!exist)\r\n' +
               '        {\r\n' +
               '          result.members.add(overlayingMember);\r\n' +
               '        }\r\n' +
               '      }\r\n' +
               '    }\r\n' +
               '    return result;\r\n' +
               '  }\r\n');
    }
    */
    
    //Obsolete. Replaced by PatchRuleEngineBase class
    /*
    private void registerVariables()
    {
        variables.add('  private List<Id> overlayingPatchIds = new List<Id>();\r\n');
        variables.add('  private Map<String, Set<Id>> prematches = new Map<String, Set<Id>>();\r\n');
    }
    */
    
    private String wrapId(Id value)
    {
        return (value == null) ? 'null' : '\'' + value + '\'';
    }
    
    private Boolean isListOperation(String op)
    {
        return op == 'in' || op == 'not in' || op == 'starts with' || op == 'not starts with' || op == 'ends with' || op == 'not ends with';
    }
}