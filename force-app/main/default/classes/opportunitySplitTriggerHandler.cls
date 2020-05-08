public class opportunitySplitTriggerHandler {
    
    public static void afterInsert(List<OpportunitySplit> newOpportunitySplit){
        List<OpportunityTeamMember> oppTeamLst = new List<OpportunityTeamMember>();
        List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
        Set<Id> oppIds = new Set<Id>();
        //Set<Id> accountIds = new Set<Id>();
        //Map<Id, List<OpportunitySplit>> opportunitySplitMemberMap = new Map<Id, List<OpportunitySplit>>();
        
        for(OpportunitySplit splitRec : newOpportunitySplit){
            OpportunityTeamMember oppTeamRec = new OpportunityTeamMember();
            oppTeamRec.OpportunityId = splitRec.OpportunityId;
            oppTeamRec.UserId = splitRec.SplitOwnerId;
            oppTeamRec.TeamMemberRole = 'Opportunity Split';
            oppTeamRec.OpportunityAccessLevel = 'Edit';
            oppTeamLst.add(oppTeamRec);
            oppIds.add(splitRec.OpportunityId);
            /**if(opportunitySplitMemberMap.get(splitRec.OpportunityId) == null){
                List<OpportunitySplit> tempSet = new List<OpportunitySplit>();
                tempSet.add(splitRec);
                opportunitySplitMemberMap.put(splitRec.OpportunityId, tempSet);
            }
            else{
                List<OpportunitySplit> tempSet = opportunitySplitMemberMap.get(splitRec.OpportunityId);
                tempSet.add(splitRec);
                opportunitySplitMemberMap.put(splitRec.OpportunityId, tempSet);
            }**/
        }
        if(!oppTeamLst.isEmpty()){
            insert oppTeamLst;
        }
        
        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, AccountId from Opportunity where id IN: oppIds]);
        Map<String, String> accountTeamMap = new Map<String, String>();
        Set<Id> accountIdSet = new Set<Id>();
        for(OpportunitySplit splitRec : newOpportunitySplit){
            accountIdSet.add(OppMap.get(splitRec.OpportunityId).AccountId);
            if(accountTeamMap.get(OppMap.get(splitRec.OpportunityId).AccountId + '' + splitRec.SplitOwnerId) == null){
                AccountTeamMember accTeamRec = new AccountTeamMember();
                accTeamRec.AccountId = OppMap.get(splitRec.OpportunityId).AccountId;
                accTeamRec.UserId = splitRec.SplitOwnerId;
                accTeamRec.TeamMemberRole = 'Opportunity Split';
                accTeamRec.AccountAccessLevel = 'Edit';
                accTeamRec.OpportunityAccessLevel = 'Edit';
                accTeamLst.add(accTeamRec);
            }
        }   
        
        /**List<Opportunity> opportunityLst = [Select Id from Opportunity Where AccountId IN: accountIdSet];
        
        List<Apttus_Proposal__Proposal__c> opportunityProposals = [Select Id, Apttus_Proposal__Opportunity__c
                                                                            from 
                                                                            Apttus_Proposal__Proposal__c 
                                                                            Where 
                                                                            Apttus_Proposal__Opportunity__c IN: opportunityLst];
        
        Set<Id> proposalSet = new Set<Id>();
                                                                            
        Map<Id, List<Apttus_Proposal__Proposal__c>> opportunityProposalMap = new Map<Id, List<Apttus_Proposal__Proposal__c>>();
        for(Apttus_Proposal__Proposal__c proposalRec : opportunityProposals){
            proposalSet.add(proposalRec.Id);
            if(opportunityProposalMap.get(proposalRec.Apttus_Proposal__Opportunity__c) == null){
                List<Apttus_Proposal__Proposal__c> tempList = new List<Apttus_Proposal__Proposal__c>();
                tempList.add(proposalRec);
                opportunityProposalMap.put(proposalRec.Apttus_Proposal__Opportunity__c, tempList);
            }
            else{
                List<Apttus_Proposal__Proposal__c> tempList = opportunityProposalMap.get(proposalRec.Apttus_Proposal__Opportunity__c);
                tempList.add(proposalRec);
                opportunityProposalMap.put(proposalRec.Apttus_Proposal__Opportunity__c, tempList);
            }
        }
        
        Map<Id, List<Apttus_Config2__ProductConfiguration__c>> proposalProdConfigMap = new Map<Id, List<Apttus_Config2__ProductConfiguration__c>>();
        List<Apttus_Config2__ProductConfiguration__c> proposalProdConfigs = [Select Id,
                                                                                    Apttus_QPConfig__Proposald__c
                                                                                    from
                                                                                    Apttus_Config2__ProductConfiguration__c	
                                                                                    Where
                                                                                    Apttus_QPConfig__Proposald__c IN: proposalSet];
        
        for(Apttus_Config2__ProductConfiguration__c prodConfigRec : proposalProdConfigs){
            if(proposalProdConfigMap.get(prodConfigRec.Apttus_QPConfig__Proposald__c) == null){
                List<Apttus_Config2__ProductConfiguration__c> tempList = new List<Apttus_Config2__ProductConfiguration__c>();
                tempList.add(prodConfigRec);
                proposalProdConfigMap.put(prodConfigRec.Apttus_QPConfig__Proposald__c, tempList);
            }
            else{
                List<Apttus_Config2__ProductConfiguration__c> tempList = proposalProdConfigMap.get(prodConfigRec.Apttus_QPConfig__Proposald__c);
                tempList.add(prodConfigRec);
                proposalProdConfigMap.put(prodConfigRec.Apttus_QPConfig__Proposald__c, tempList);
            }
        }
        
        List<Apttus_Proposal__Proposal__Share> proposalSharesToInsert = new List<Apttus_Proposal__Proposal__Share>();
        List<Apttus_Config2__ProductConfiguration__Share> prodConfigSharesToInsert = new List<Apttus_Config2__ProductConfiguration__Share>();
        
        for(Opportunity oppRec : opportunityLst){
            
            for(Id oppId : opportunitySplitMemberMap.keySet()){
                for(OpportunitySplit splitMember : opportunitySplitMemberMap.get(oppId)){
                    if(opportunityProposalMap.get(oppRec.Id) != null){
                        for(Apttus_Proposal__Proposal__c proposalRec : opportunityProposalMap.get(oppRec.Id)){
                            Apttus_Proposal__Proposal__Share proposalShareRec = new Apttus_Proposal__Proposal__Share();
                            proposalShareRec.ParentId = proposalRec.id;
                            proposalShareRec.AccessLevel = 'EDIT';
                            proposalShareRec.UserOrGroupId = splitMember.SplitOwnerId;
                            proposalShareRec.RowCause = Schema.Apttus_Proposal__Proposal__Share.RowCause.Opportunity_Split__c;
                            proposalSharesToInsert.add(proposalShareRec);
                            if(proposalProdConfigMap.get(proposalRec.Id) != null){
                                for(Apttus_Config2__ProductConfiguration__c prodConfigRec : proposalProdConfigMap.get(proposalRec.Id)){
                                    Apttus_Config2__ProductConfiguration__Share prodConfigShareRec = new Apttus_Config2__ProductConfiguration__Share();
                                    prodConfigShareRec.ParentId = prodConfigRec.id;
                                    prodConfigShareRec.AccessLevel = 'EDIT';
                                    prodConfigShareRec.UserOrGroupId = splitMember.SplitOwnerId;
                                    prodConfigShareRec.RowCause = Schema.Apttus_Config2__ProductConfiguration__Share.RowCause.Opportunity_Split__c;
                                    prodConfigSharesToInsert.add(prodConfigShareRec);
                                }    
                            }
                        }
                    }
                }
            }
        }**/
        
        if(!accTeamLst.isEmpty()){
            Database.insert(accTeamLst, false);
        }
        List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdSet];
        if(!accountList.isEmpty()){
            for(Account accountRec : accountList){
                accountRec.TriggerPatchAssignment__c = true;   
            }
            update accountList;
        }
        
        /**if(!proposalSharesToInsert.isEmpty()){
            Database.insert(proposalSharesToInsert, false);
        }
        
        if(!prodConfigSharesToInsert.isEmpty()){
            Database.insert(prodConfigSharesToInsert, false);
        }**/
    }
    
    public static void afterDelete(List<OpportunitySplit> newOpportunitySplit){
        Set<Id> oppIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(OpportunitySplit splitRec : newOpportunitySplit){
            oppIds.add(splitRec.OpportunityId);
            userIds.add(splitRec.SplitOwnerId);
        }
        
        /**List<OpportunityTeamMember> oppTeamToDelete = [Select Id 
                                                            from 
                                                            OpportunityTeamMember
                                                            Where    
                                                            OpportunityId IN: oppIds
                                                            AND
                                                            UserId IN: userIds
                                                            AND
                                                            TeamMemberRole = 'Opportunity Split'];
        if(!oppTeamToDelete.isEmpty()){
            delete oppTeamToDelete;
        }**/
        //Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, AccountId from Opportunity where id IN: oppIds]);
        List<Opportunity> opportunities = [Select Id, AccountId from Opportunity where id IN: oppIds];
        if(!opportunities.isEmpty()){
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity oppRec : opportunities){
                accountIds.add(oppRec.AccountId);
            }
            List<Opportunity> existingOpp = [Select Id from Opportunity Where AccountId IN: accountIds];
            List<OpportunitySplit> existingOpportunitySplitMembers = [Select Id, SplitOwnerId from OpportunitySplit Where OpportunityId IN: existingOpp AND SplitOwnerId IN: userIds ];
            if(existingOpportunitySplitMembers.isEmpty()){
                               
                List<AccountTeamMember> accTeamMembersToDelete = [Select Id, AccountId from AccountTeamMember Where AccountId IN: accountIds AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split'];
                Set<Id> accountIdsToTriggerPatch = new Set<Id>();
                for(AccountTeamMember accountTeamMemberRec : accTeamMembersToDelete){
                    accountIdsToTriggerPatch.add(accountTeamMemberRec.AccountId);   
                }
                Database.delete(accTeamMembersToDelete, false);
                
                List<OpportunityTeamMember> oppTeamToDelete = [Select Id from OpportunityTeamMember Where OpportunityId IN: existingOpp AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split'];
                if(!oppTeamToDelete.isEmpty()){
                    delete oppTeamToDelete;
                }
                
                List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdsToTriggerPatch];
                if(!accountList.isEmpty()){
                    for(Account accountRec : accountList){
                        accountRec.TriggerPatchAssignment__c = true;   
                    }
                    update accountList;
                }
            }
            else{
                Map<String, boolean> userSplitOppTeam = new Map<String, Boolean>();
                for(OpportunitySplit teamMemberRec : existingOpportunitySplitMembers){
                    userSplitOppTeam.put(teamMemberRec.SplitOwnerId, true);
                }
                List<AccountTeamMember> accTeamMembersToDelete = new List<AccountTeamMember>();
                List<AccountTeamMember> accTeamMembers = [Select Id, UserId, AccountId from AccountTeamMember Where AccountId IN: accountIds AND UserId IN: userIds AND TeamMemberRole = 'Opportunity Split'];
                Set<Id> accountIdsToTriggerPatch = new Set<Id>();
                for(AccountTeamMember accTeamRec : accTeamMembers){
                    if(userSplitOppTeam.get(accTeamRec.UserId) == null){
                        accTeamMembersToDelete.add(accTeamRec);
                        accountIdsToTriggerPatch.add(accTeamRec.AccountId); 
                    }
                }
                Database.delete(accTeamMembersToDelete, false);

                List<Account> accountList = [Select Id, TriggerPatchAssignment__c from Account Where Id IN: accountIdsToTriggerPatch];
                if(!accountList.isEmpty()){
                    for(Account accountRec : accountList){
                        accountRec.TriggerPatchAssignment__c = true;   
                    }
                    update accountList;
                }
            }
        }
    }
}