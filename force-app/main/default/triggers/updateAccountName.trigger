trigger updateAccountName on Apttus_Approval__Approval_Request__c (before insert, before update) {
    
    Map<Id, List<Apttus_Approval__Approval_Request__c>> proposalMap = new Map<Id, List<Apttus_Approval__Approval_Request__c>>();

    Map<Id, string> proposalAccountNames = new Map<Id, string>();
    
    if(Trigger.isInsert)
    {
        for(Apttus_Approval__Approval_Request__c appr : Trigger.New)
        {
            if(appr.Apttus_QPApprov__ProposalId__c != null)
            {
                if(proposalMap.containsKey(appr.Apttus_QPApprov__ProposalId__c))
                {
                    proposalMap.get(appr.Apttus_QPApprov__ProposalId__c).add(appr);
                }
                else
                {
                    proposalMap.put(appr.Apttus_QPApprov__ProposalId__c, new List<Apttus_Approval__Approval_Request__c>{appr});
                }
            }    
        }
    }    
    
    if(Trigger.isUpdate)
    {
        for(Apttus_Approval__Approval_Request__c appr : Trigger.New)
        {
            if(appr.Apttus_QPApprov__ProposalId__c != null && appr.APTS_Account_Name__c == null)
            {
                if(proposalMap.containsKey(appr.Apttus_QPApprov__ProposalId__c))
                {
                    proposalMap.get(appr.Apttus_QPApprov__ProposalId__c).add(appr);
                }
                else
                {
                    proposalMap.put(appr.Apttus_QPApprov__ProposalId__c, new List<Apttus_Approval__Approval_Request__c>{appr});
                }
            }    
        }
    }    
    
    
    if(proposalMap.size() > 0)
    {
        for(Apttus_Proposal__Proposal__c prop : [select Id, Apttus_Proposal__Account__c, Apttus_Proposal__Account__r.Name from Apttus_Proposal__Proposal__c where Id in: proposalMap.keyset()])
        {
            proposalAccountNames.put(prop.Id, prop.Apttus_Proposal__Account__r.Name);
        }
    }    
    
    if(proposalAccountNames.size() > 0)
    {
        for(Apttus_Approval__Approval_Request__c appr : Trigger.New)
        {
            if(appr.Apttus_QPApprov__ProposalId__c != null)
            {
                appr.APTS_Account_Name__c = proposalAccountNames.get(appr.Apttus_QPApprov__ProposalId__c);
            }
        }
    }    
}