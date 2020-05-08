public class quoteAndProposalShareUtil {
    
    public static void shareQuoteAndProdConfigWithOppTeamMembers(List<Opportunity_Share__c> oppToShare){
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity_Share__c oppShareRec : oppToShare){
            oppIds.add(oppShareRec.Opportunity_Id__c);
        }
        
        List<OpportunityTeamMember> oppTeamMembers = [Select Id, UserId, OpportunityId from OpportunityTeamMember Where OpportunityId IN: oppIds];
        Map<Id, List<OpportunityTeamMember>> oppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
        for(OpportunityTeamMember teamMemberRec : oppTeamMembers){
            if(oppTeamMembersMap.get(teamMemberRec.OpportunityId) == null){
                List<OpportunityTeamMember> tempList = new List<OpportunityTeamMember>();
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
            else{
                List<OpportunityTeamMember> tempList = oppTeamMembersMap.get(teamMemberRec.OpportunityId);
                tempList.add(teamMemberRec);
                oppTeamMembersMap.put(teamMemberRec.OpportunityId, tempList);
            }
        }
        
        Map<Id, List<Apttus_Proposal__Proposal__c>> oppProposalMap = new Map<Id, List<Apttus_Proposal__Proposal__c>>();
        List<Apttus_Proposal__Proposal__c> oppProposals = [Select Id, Apttus_Proposal__Opportunity__c 
                                                                    from 
                                                                    Apttus_Proposal__Proposal__c 
                                                                    Where 
                                                                    Apttus_Proposal__Opportunity__c IN: oppIds];
                                                                    
        for(Apttus_Proposal__Proposal__c proposalRec : oppProposals){
            if(oppProposalMap.get(proposalRec.Apttus_Proposal__Opportunity__c) == null){
                List<Apttus_Proposal__Proposal__c> tempList = new List<Apttus_Proposal__Proposal__c>();
                tempList.add(proposalRec);
                oppProposalMap.put(proposalRec.Apttus_Proposal__Opportunity__c, tempList);
            }
            else{
                List<Apttus_Proposal__Proposal__c> tempList = oppProposalMap.get(proposalRec.Apttus_Proposal__Opportunity__c);
                tempList.add(proposalRec);
                oppProposalMap.put(proposalRec.Apttus_Proposal__Opportunity__c, tempList);
            }
        }
                                                                    
        Map<Id, List<Apttus_Config2__ProductConfiguration__c>> proposalProdConfigMap = new Map<Id, List<Apttus_Config2__ProductConfiguration__c>>();
        List<Apttus_Config2__ProductConfiguration__c> proposalProdConfigs = [Select Id, Apttus_QPConfig__Proposald__c 
                                                                                    from 
                                                                                    Apttus_Config2__ProductConfiguration__c
                                                                                    Where
                                                                                    Apttus_QPConfig__Proposald__c IN: oppProposals
                                                                                    //AND
                                                                                    /*Apttus_Config2__Status__c = 'Finalized'*/];
        
        for(Apttus_Config2__ProductConfiguration__c prodConfigRec : proposalProdConfigs){
            if(proposalProdConfigMap.get(prodConfigRec.Apttus_QPConfig__Proposald__c) == null){
                List<Apttus_Config2__ProductConfiguration__c> tempList = New List<Apttus_Config2__ProductConfiguration__c>();
                tempList.add(prodConfigRec);
                proposalProdConfigMap.put(prodConfigRec.Apttus_QPConfig__Proposald__c, tempList);
            }
            else{
                List<Apttus_Config2__ProductConfiguration__c> tempList = proposalProdConfigMap.get(prodConfigRec.Apttus_QPConfig__Proposald__c);
                tempList.add(prodConfigRec);
                proposalProdConfigMap.put(prodConfigRec.Apttus_QPConfig__Proposald__c, tempList);
            }
        }
        
        
        Map<String, Apttus_Proposal__Proposal__Share> existingProposalSharesMap = new Map<String, Apttus_Proposal__Proposal__Share>();
        Map<String, Apttus_Config2__ProductConfiguration__Share> existingProposalProdConfigSharesMap = new Map<String, Apttus_Config2__ProductConfiguration__Share>();
        
        if(!oppProposals.isEmpty()){
            List<Apttus_Proposal__Proposal__Share> existingProposalShares = [Select Id, 
                                                                                    ParentId,
                                                                                    UserOrGroupId
                                                                                    from
                                                                                    Apttus_Proposal__Proposal__Share
                                                                                    Where
                                                                                    ParentId IN: oppProposals
                                                                                    AND
                                                                                    RowCause = 'Opportunity_Team__c'];
            /**if(!proposalShareToDelete.isEmpty()){
                Database.delete(proposalShareToDelete, false);
            }**/
            for(Apttus_Proposal__Proposal__Share proposalShareRec : existingProposalShares){
                existingProposalSharesMap.put(proposalShareRec.ParentId + '' + proposalShareRec.UserOrGroupId, proposalShareRec);
            }
            
        }
            
        if(!proposalProdConfigs.isEmpty()){
            List<Apttus_Config2__ProductConfiguration__Share> existingProposalProdConfigShares = [Select Id,
                                                                                                    ParentId,
                                                                                                    UserOrGroupId
                                                                                                    from
                                                                                                    Apttus_Config2__ProductConfiguration__Share
                                                                                                    Where
                                                                                                    ParentId IN: proposalProdConfigs
                                                                                                    AND
                                                                                                    RowCause = 'Opportunity_Team__c'];
            
            /**if(!existingProposalProdConfigShares.isEmpty()){
                Database.delete(existingProposalProdConfigShares, false);
            }**/
            for(Apttus_Config2__ProductConfiguration__Share proposalProdConfigShareRec : existingProposalProdConfigShares){
                existingProposalProdConfigSharesMap.put(proposalProdConfigShareRec.ParentId + '' + proposalProdConfigShareRec.UserOrGroupId, proposalProdConfigShareRec);
            }
        }
        
        List<Apttus_Proposal__Proposal__Share> proposalSharesToInsert = new List<Apttus_Proposal__Proposal__Share>();
        List<Apttus_Config2__ProductConfiguration__Share> prodConfigSharesToInsert = new List<Apttus_Config2__ProductConfiguration__Share>();
        
        for(Opportunity_Share__c oppShareRec : oppToShare){
            if(oppTeamMembersMap.get(oppShareRec.Opportunity_Id__c) != null){
                for(OpportunityTeamMember oppTeamRec : oppTeamMembersMap.get(oppShareRec.Opportunity_Id__c)){
                    if(oppProposalMap.get(oppShareRec.Opportunity_Id__c) != null){
                        for(Apttus_Proposal__Proposal__c proposalRec : oppProposalMap.get(oppShareRec.Opportunity_Id__c)){
                            Apttus_Proposal__Proposal__Share proposalShareRec = new Apttus_Proposal__Proposal__Share();
                            proposalShareRec.ParentId = proposalRec.id;
                            proposalShareRec.AccessLevel = 'EDIT';
                            proposalShareRec.UserOrGroupId = oppTeamRec.UserId;
                            proposalShareRec.RowCause = Schema.Apttus_Proposal__Proposal__Share.RowCause.Opportunity_Team__c;
                            proposalSharesToInsert.add(proposalShareRec);
                            
                            if(proposalProdConfigMap.get(proposalRec.Id) != null){
                                for(Apttus_Config2__ProductConfiguration__c prodConfigRec : proposalProdConfigMap.get(proposalRec.Id)){
                                    Apttus_Config2__ProductConfiguration__Share prodConfigShareRec = new Apttus_Config2__ProductConfiguration__Share();
                                    prodConfigShareRec.ParentId = prodConfigRec.id;
                                    prodConfigShareRec.AccessLevel = 'EDIT';
                                    prodConfigShareRec.UserOrGroupId = oppTeamRec.UserId;
                                    prodConfigShareRec.RowCause = Schema.Apttus_Config2__ProductConfiguration__Share.RowCause.Opportunity_Team__c;
                                    prodConfigSharesToInsert.add(prodConfigShareRec);
                                }
                            }
                        }
                    }
                }
            }
            oppShareRec.Status__c = 'Sharing Completed';
        }
        
        /**if(!proposalSharesToInsert.isEmpty()){
            //insert proposalSharesToInsert;
            Database.insert(proposalSharesToInsert, false);
        }
        
        if(!prodConfigSharesToInsert.isEmpty()){
            //insert prodConfigSharesToInsert;
            Database.insert(prodConfigSharesToInsert, false);
        }**/
        
        List<Apttus_Proposal__Proposal__Share> proposalShareToDelete = new List<Apttus_Proposal__Proposal__Share>();
        List<Apttus_Proposal__Proposal__Share> proposalShareToInsert = new List<Apttus_Proposal__Proposal__Share>();
        List<Apttus_Proposal__Proposal__Share> proposalShareToUpdate = new List<Apttus_Proposal__Proposal__Share>();
        
        
        if(!proposalSharesToInsert.isEmpty()){
            for(Apttus_Proposal__Proposal__Share proposalShareRec : proposalSharesToInsert){
                if(existingProposalSharesMap.get(proposalShareRec.ParentId + '' + proposalShareRec.UserOrGroupId) != null){
                    proposalShareToUpdate.add(proposalShareRec);
                    existingProposalSharesMap.remove(proposalShareRec.ParentId + '' + proposalShareRec.UserOrGroupId);
                }
                else{
                    proposalShareToInsert.add(proposalShareRec);
                }
            }  
           
        }
        
        List<Apttus_Config2__ProductConfiguration__Share> proposalProdConfigShareToDelete = new List<Apttus_Config2__ProductConfiguration__Share>();
        List<Apttus_Config2__ProductConfiguration__Share> proposalProdConfigShareToInsert = new List<Apttus_Config2__ProductConfiguration__Share>();
        List<Apttus_Config2__ProductConfiguration__Share> proposalProdConfigShareToUpdate = new List<Apttus_Config2__ProductConfiguration__Share>();
        
        if(!proposalSharesToInsert.isEmpty()){
            for(Apttus_Config2__ProductConfiguration__Share proposalProdConfigShareRec : prodConfigSharesToInsert){
                if(existingProposalProdConfigSharesMap.get(proposalProdConfigShareRec.ParentId + '' + proposalProdConfigShareRec.UserOrGroupId) != null){
                    proposalProdConfigShareToUpdate.add(proposalProdConfigShareRec);
                    existingProposalProdConfigSharesMap.remove(proposalProdConfigShareRec.ParentId + '' + proposalProdConfigShareRec.UserOrGroupId);
                }
                else{
                    proposalProdConfigShareToInsert.add(proposalProdConfigShareRec);
                }
            }  
        }
        
        if(!proposalShareToUpdate.isEmpty()){
            Database.insert(proposalShareToInsert, false);
        }
        if(!existingProposalSharesMap.values().isEmpty()){
            proposalShareToDelete.addAll(existingProposalSharesMap.values());
            Database.delete(proposalShareToDelete, false);
        }
        
        
        if(!proposalProdConfigShareToInsert.isEmpty()){
            Database.insert(proposalProdConfigShareToInsert, false);
        }
        if(!existingProposalProdConfigSharesMap.values().isEmpty()){
            proposalProdConfigShareToDelete.addAll(existingProposalProdConfigSharesMap.values());
            Database.delete(proposalProdConfigShareToDelete, false);
        }
        
        if(!oppToShare.isEmpty()){
            Database.update(oppToShare, false);
        }
    }
}