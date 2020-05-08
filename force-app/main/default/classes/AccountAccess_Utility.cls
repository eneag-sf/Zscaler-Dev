public without sharing class AccountAccess_Utility {
    public static void insertAccountShare(list<AccountShare> accountShareList){
        Database.insert(accountShareList, false);
    }
    
    public static void deleteAccountVacationCoverage(Set<Id> AccountIds, Set<Id> coveringUsers){
        List<AccountTeamMember> vacationCoverageAccountTeam = [Select Id 
                                                                        from 
                                                                        AccountTeamMember
                                                                        Where 
                                                                        AccountId IN: AccountIds
                                                                        AND
                                                                        UserId IN: coveringUsers
                                                                        AND
                                                                        TeamMemberRole = 'Vacation Coverage'];
        if(!vacationCoverageAccountTeam.isEmpty()){
            Database.delete(vacationCoverageAccountTeam, false);
        }
    }
    
    public static void deleteOpportunityVacationCoverage(Set<Id> AccountIds, Set<Id> coveringUsers){
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> OppList = [select Id,
                                            Name,
                                            AccountId
                                            from 
                                            Opportunity 
                                            Where 
                                            AccountId IN:AccountIds];
        for(Opportunity Opp:OppList){
            opportunityIds.add(Opp.Id);
        }
        system.debug('---coveringUsers--'+coveringUsers);
        List<OpportunityTeamMember> vacationCoverageOppTeam = [Select Id 
                                                                        from 
                                                                        OpportunityTeamMember
                                                                        Where 
                                                                        OpportunityId IN: opportunityIds
                                                                        AND
                                                                        UserId IN: coveringUsers
                                                                        AND
                                                                        TeamMemberRole = 'Vacation Coverage'];
        
        /*for(OpportunityTeamMember oppTeamMemberRec : vacationCoverageOppTeam){
            opportunityIds.add(oppTeamMemberRec.Id);
        }*/
        
        if(!vacationCoverageOppTeam.isEmpty()){
            Database.delete(vacationCoverageOppTeam, false);
            deleteProposalVacationCoverage(opportunityIds, coveringUsers);
        }
    }
    
    public static void deleteProposalVacationCoverage(Set<Id> oppIds, Set<Id> coveringUsers){
        Set<Id> ProposalIds = new Set<Id>();
        List<Apttus_Proposal__Proposal__c> PropList = [Select Id, Name, Apttus_Proposal__Opportunity__c 
                                                                from 
                                                                Apttus_Proposal__Proposal__c
                                                                Where 
                                                                Apttus_Proposal__Opportunity__c IN:OppIds];
        
        for(Apttus_Proposal__Proposal__c Prop:PropList){
            ProposalIds.Add(Prop.Id);
        }
        List<Apttus_Proposal__Proposal__share> PropShareToDelete = [Select Id
                                                                            From
                                                                            Apttus_Proposal__Proposal__share
                                                                            Where 
                                                                            ParentId IN: ProposalIds
                                                                            AND
                                                                            UserOrGroupId IN: coveringUsers
                                                                            AND
                                                                            RowCause = 'Opportunity_Team__c'];
        if(!PropShareToDelete.isEmpty()){
            Database.delete(PropShareToDelete, false);
            deleteProdConfigVacationCoverage(ProposalIds, coveringUsers);
        }
    }
    
    public static void deleteProdConfigVacationCoverage(Set<Id> proposalIds, Set<Id> coveringUsers){
        Set<Id> ProposalProdConfigIds = new Set<Id>();
        List<Apttus_Config2__ProductConfiguration__c> ProposalProdConfigs = [select Id, Name 
                                                                                            from 
                                                                                            Apttus_Config2__ProductConfiguration__c 
                                                                                            Where 
                                                                                            Apttus_QPConfig__Proposald__c IN:proposalIds];
        for(Apttus_Config2__ProductConfiguration__c PropProdConfig : ProposalProdConfigs){
            ProposalProdConfigIds.Add(PropProdConfig.Id);
        }
        
        List<Apttus_Config2__ProductConfiguration__share> PropProdConfiShareToDelete = [Select Id
                                                                                            From
                                                                                            Apttus_Config2__ProductConfiguration__share
                                                                                            Where 
                                                                                            ParentId IN: ProposalProdConfigIds
                                                                                            AND
                                                                                            UserOrGroupId IN: coveringUsers
                                                                                            AND
                                                                                            RowCause = 'Opportunity_Team__c'];
        if(!PropProdConfiShareToDelete.isEmpty()){
            Database.delete(PropProdConfiShareToDelete, false);
        }
    }
    
    public static void insertAccountTeam(Set<Id> AccountIds, string selectedManager){
        List<AccountTeamMember> AccountTeamInsertList = new List<AccountTeamMember>();
        for(Id accoutId : AccountIds){
            AccountTeamMember accTeamRec = new AccountTeamMember();
            accTeamRec.AccountId = accoutId;
            accTeamRec.UserId = selectedManager;
            accTeamRec.TeamMemberRole = 'Vacation Coverage';
            accTeamRec.AccountAccessLevel = 'Edit';
            accTeamRec.OpportunityAccessLevel = 'Edit';
            AccountTeamInsertList.add(accTeamRec);
        }
        if(!AccountTeamInsertList.isEmpty()){
            Database.insert(AccountTeamInsertList, false);
        }
    }
    
    public static void InsertOpportunityTeam(set<Id> AccountIds, string selectedManager){ 
        Set<Id> OppIds = new Set<Id>();
        Id selectedCoveringManager = selectedManager;
        Map<String, Boolean> OppotunityMap = new Map<String, Boolean>();
        List<OpportunityTeamMember> OpportunityTeamList = new List<OpportunityTeamMember>();
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        if(AccountIds.size()>0){
            OpportunityList = [Select Id, Name, AccountId from Opportunity where AccountId IN:AccountIds];
            
            for(Opportunity Opp:OpportunityList){
                OppIds.Add(Opp.Id);
            }
            List<OpportunityTeamMember> OppTeamMemberList = new List<OpportunityTeamMember>();
            OppTeamMemberList = [select Id, OpportunityId, UserId from 
                                            OpportunityTeamMember 
                                            Where 
                                            OpportunityId IN: OppIds 
                                            And 
                                            UserId != null];
            for(OpportunityTeamMember OTM:OppTeamMemberList){
                OppotunityMap.put(OTM.OpportunityId+'-'+OTM.UserId,true);
            }
            
            for(Opportunity Opp:OpportunityList){
                system.debug('--------Opp map----'+OppotunityMap.get(Opp.Id+'-'+selectedCoveringManager));
                if(OppotunityMap.get(Opp.Id+'-'+selectedCoveringManager) == null){
                    //OppIds.Add(Opp.Id);
                    OpportunityTeamMember OppTeam = new OpportunityTeamMember();
                    OppTeam.OpportunityAccessLevel = 'Edit';
                    OppTeam.OpportunityId = Opp.Id;
                    OppTeam.TeamMemberRole = 'Vacation Coverage';
                    OppTeam.UserId = selectedCoveringManager;
                    OpportunityTeamList.Add(OppTeam);
                    //OppotunityMap.put(Opp.Id, true);
                }
            }
            if(OpportunityTeamList.size()>0){
                Database.insert(OpportunityTeamList, false);
                if(OppIds.size()>0){
                    AccountAccess_Utility.InsertProposalShare(OppIds,selectedCoveringManager);
                }
            }
        }
    }
    
    public static void InsertProposalShare(set<Id> OppIds, string selectedCoveringManager){
        Set<Id> ProposalIds = new Set<Id>();
        List<Apttus_Proposal__Proposal__share> ProposalShareList = new List<Apttus_Proposal__Proposal__share>();
        List<Apttus_Proposal__Proposal__c> PropList = new List<Apttus_Proposal__Proposal__c>();
        
        if(OppIds.size()>0){
            Map<String, Boolean> PropMap = new Map<String, Boolean>();
            PropList = [select Id,Name,Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c Where Apttus_Proposal__Opportunity__c IN:OppIds];
            for(Apttus_Proposal__Proposal__c Prop:PropList){
                ProposalIds.Add(Prop.Id);
            }
            
            List<Apttus_Proposal__Proposal__share> PropShareList = new List<Apttus_Proposal__Proposal__share>();
            PropShareList = [select Id,ParentId,UserOrGroupId from Apttus_Proposal__Proposal__share where ParentId IN:ProposalIds And UserOrGroupId != null];
            for(Apttus_Proposal__Proposal__share PropShare:PropShareList){
                PropMap.put(PropShare.ParentId+'-'+PropShare.UserOrGroupId,true);
            }
            
            for(Apttus_Proposal__Proposal__c Prop:PropList){
                if(PropMap.get(Prop.Id+'-'+selectedCoveringManager) == null){
                    //ProposalIds.Add(Prop.Id);
                    Apttus_Proposal__Proposal__share PropShare = new Apttus_Proposal__Proposal__share();
                    PropShare.ParentId = Prop.Id;
                    PropShare.UserOrGroupId = selectedCoveringManager;
                    PropShare.AccessLevel = 'Edit';
                    PropShare.RowCause = 'Opportunity_Team__c';
                    ProposalShareList.Add(PropShare);
                    //PropMap.put(Prop.Id, true);
                }
            }
            
            if(ProposalShareList.size()>0){
                Database.insert(ProposalShareList, false);
                if(ProposalIds.size()>0){
                    AccountAccess_Utility.InsertPropConfigurationShare(ProposalIds, selectedCoveringManager);
                }
            }
        }
    }
    
    public static void InsertPropConfigurationShare(set<Id> PropIds,string selectedCoveringManager){
        List<Apttus_Config2__ProductConfiguration__share> ProposalConfigShareList = new List<Apttus_Config2__ProductConfiguration__share>();
        Set<Id> ProposalConfigIds = new Set<Id>();
        Map<String, Boolean> PropConfigMap = new Map<String, Boolean>();
        
        if(PropIds.size()>0){
            List<Apttus_Config2__ProductConfiguration__c> PropConfigList = new List<Apttus_Config2__ProductConfiguration__c>();
            PropConfigList = [select Id,Name from Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c IN:PropIds];
            for(Apttus_Config2__ProductConfiguration__c PropConfig:PropConfigList){
                ProposalConfigIds.Add(PropConfig.Id);
            }
            
            List<Apttus_Config2__ProductConfiguration__share> PropConfigShareList = new List<Apttus_Config2__ProductConfiguration__share>();
            PropConfigShareList = [select Id,ParentId,UserOrGroupId from Apttus_Config2__ProductConfiguration__share where ParentId IN:ProposalConfigIds And UserOrGroupId != null];
            for(Apttus_Config2__ProductConfiguration__share PopConfigShare:PropConfigShareList){
                system.debug('---UserOrGroupId--put-'+PopConfigShare.UserOrGroupId);
                PropConfigMap.put(PopConfigShare.ParentId+'-'+PopConfigShare.UserOrGroupId,true);
            }
            
            
            for(Apttus_Config2__ProductConfiguration__c PropConfig:PropConfigList){
                if(PropConfigMap.get(PropConfig.Id+'-'+selectedCoveringManager) == null){
                    system.debug(PropConfigMap.get(PropConfig.Id+'-'+selectedCoveringManager)+'----Map------UserOrGroupId--get--'+selectedCoveringManager);
                    Apttus_Config2__ProductConfiguration__share  PropConfigShare = new Apttus_Config2__ProductConfiguration__share ();
                    PropConfigShare.ParentId = PropConfig.Id;
                    PropConfigShare.UserOrGroupId = selectedCoveringManager;
                    PropConfigShare.AccessLevel = 'Edit';
                    PropConfigShare.RowCause = 'Opportunity_Team__c';
                    ProposalConfigShareList.Add(PropConfigShare);
                    //PropConfigMap.put(PropConfig.Id, true);
                }
            }
            
            system.debug('---list---'+ProposalConfigShareList.size());
            if(ProposalConfigShareList.size()>0){
                Database.insert(ProposalConfigShareList, false);
            }
        }
    }
    
}