/*
 * Controller of page PatchRules
 */
public with sharing class PatchRulesController 
{
    private Long deployDateInternal;
    
    public PatchRulesController()
    {
        deployDateInternal = 0;
    }

    public String PatchToDisplay
    {
        get
        {
            List<PatchDataModel.PatchInfo> result = PatchRuleHelper.getPatches();
            return JSON.serialize(result);
        }
    }
    
    public Boolean IsAdmin
    {
        get
        {
            return PatchRuleHelper.IsAdmin;
        }
    }
    
    public Long LastDeploymentDate
    {
        get
        {
            if(deployDateInternal == 0)
            {
                deployDateInternal = PatchRuleHelper.LastDeploymentDate;
            }
            return deployDateInternal;
        }
    }
}