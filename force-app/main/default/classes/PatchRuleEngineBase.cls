public virtual class PatchRuleEngineBase 
{
    public List<Id> overlayingPatchIds = new List<Id>();
    protected Map<String, Set<Id>> prematches = new Map<String, Set<Id>>();

    @testvisible
    protected Map<String, Set<Id>> prematchList(PatchDataModel.MatchTarget t)
    {
        system.debug('inside prematchList method of PatchRuleEngineBase '+t);
        system.debug('inside prematchList method of PatchRuleEngineBase '+t.getTargetValues());
        Map<String, Set<Id>> result = new Map<String, Set<Id>>{ 'Company Name' => new Set<Id>(), 'Country' => new Set<Id>(), 'Zip Code' => new Set<Id>(), 'State' => new Set<Id>(), 'Industry' => new Set<Id>(),'Email Domain' => new Set<Id>(),'Custom1' => new Set<Id>(), 'Custom2' => new Set<Id>(), 'Custom3' => new Set<Id>(), 'Custom4' => new Set<Id>(), 'Custom5' => new Set<Id>(), 'Custom6' => new Set<Id>() };
        for(PatchMatchList__c prematch : [select Name, PatchCriteriaRule__c from PatchMatchList__c where Name in :t.getTargetValues()])
        {
            system.debug('prematch  '+prematch);
            if(prematch.Name == t.company)  result.get('Company Name').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.country)  result.get('Country').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.zipCode)  result.get('Zip Code').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.state)    result.get('State').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.industry) result.get('Industry').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.emailDomain)  result.get('Email Domain').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom1)  result.get('Custom1').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom2)  result.get('Custom2').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom3)  result.get('Custom3').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom4)  result.get('Custom4').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom5)  result.get('Custom5').add(prematch.PatchCriteriaRule__c);
            if(prematch.Name == t.custom6)  result.get('Custom6').add(prematch.PatchCriteriaRule__c);
        }
        system.debug('result '+result);
        return result;
    }

    @testvisible
    protected Boolean opIn(String value, Set<String> targetSet) 
    {
        value = (value == null) ? null : value.toLowerCase();
        return targetSet.contains(value);
    }

    @testvisible
    protected Boolean opInRange(String value, String targetLow, String targetHigh)
    {
        value = (value == null) ? '' : value.toLowerCase();
        targetLow = (targetLow == null) ? '' : targetLow.toLowerCase();
        targetHigh = (targetHigh == null) ? '' : targetHigh.toLowerCase();
        if(value.length() < targetLow.length() || value.length() < targetHigh.length())
        {
            return false;
        }
        else
        {
            return value.substring(0, targetLow.length()) >= targetLow && value.substring(0, targetHigh.length()) <= targetHigh;
        }
    }

    @testvisible
    protected Boolean opEqual(String value, String target)
    {
        return value == target || (String.IsBlank(target) && String.isBlank(value));
    }

    @testvisible
    protected Boolean opStart(String value, Set<String> targetSet)
    {
        value = (value == null) ? '' : value.toLowerCase();
        for(String t : targetSet)
        {
            if(value.startsWith(t))
            {
                return true;
            }
        }
        return false;
    }

    @testvisible
    protected Boolean opEnd(String value, Set<String> targetSet)
    {
        value = (value == null) ? '' : value.toLowerCase();
        for(String t : targetSet)
        {
            if(value.endsWith(t))
            {
                return true;
            }
        }
        return false;
    }

    @testvisible
    protected Boolean opContain(String value, String target)
    {
        value = (value == null) ? '' : value.toLowerCase();
        target = (target == null) ? '' : target.toLowerCase();
        return value.contains(target);
    }

    @testvisible
    public static Boolean opZipcode(String zipcode, String target)
    {
        zipcode = (zipcode == null) ? '' : zipcode.replaceAll('\\s', '');
        target = (target == null) ? '' : target.replaceAll('\\s', '');
        for(String segment : target.split(','))
        {
            if(!segment.contains('~'))
            {
                if(zipcode.startsWith(segment))
                {
                    return true;
                }
            }
            else
            {
                String[] range = segment.split('~');
                if(zipcode >= range[0] && zipcode <= range[1])
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    @testvisible
    protected PatchDataModel.PatchInfo processResult(Id patchId)
    {
        system.debug('inside processResult method ');
        system.debug('inside processResult method overlayingPatchIds '+overlayingPatchIds);
        PatchDataModel.PatchInfo result = patchId != null ? PatchRuleHelper.getPatch(patchId) : new PatchDataModel.PatchInfo();
        List<PatchDataModel.PatchInfo> overlayingPatches = (overlayingPatchIds.size() > 0) ? PatchRuleHelper.getPatches(overlayingPatchIds) : new List<PatchDataModel.PatchInfo>();
        System.debug('overlayingPatchIds: ' + overlayingPatchIds);
        System.debug('overlayingPatches: ' + overlayingPatches);
        for(PatchDataModel.PatchInfo overlay : overlayingPatches)
        {
            system.debug('overlayingPatches  '+overlayingPatches);
            for(PatchDataModel.TeamMemberInfo overlayingMember : overlay.members)
            {
                system.debug('overlayingMember '+overlayingMember);
                Boolean exist = false;
                for(PatchDataModel.TeamMemberInfo member : result.members)
                {
                    system.debug('member '+member);
                    if(member.userId == overlayingMember.userId)
                    {
                        system.debug('member already exists');
                        exist = true;
                        break;
                    }
                }
                if(!exist)
                {
                    system.debug('member does not exists');
                    result.members.add(overlayingMember);
                }
            }
        }
        return result;
    }
}