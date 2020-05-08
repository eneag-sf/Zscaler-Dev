public class APTS_SetBilltoAccountHelper {
    public static boolean beforeflag=true;
    public static void before(List<Apttus_Config2__ProductConfiguration__c> configlist){
        if(beforeflag = true){
            
            Map<id, List<Apttus_Config2__ProductConfiguration__c>> configMap = new  Map<id, List<Apttus_Config2__ProductConfiguration__c>> ();
            List<Apttus_Config2__ProductConfiguration__c> configlistNew;
            for(Apttus_Config2__ProductConfiguration__c  config : configlist) {
                if(config.Apttus_QPConfig__Proposald__c != null){
                    configlistNew = new List<Apttus_Config2__ProductConfiguration__c> ();
                    if(configMap.get(config.Apttus_QPConfig__Proposald__c) != null) {
                        configlistNew = configMap.get(config.Apttus_QPConfig__Proposald__c);
                    }
                    configlistNew.add(config);
                    configMap.put(config.Apttus_QPConfig__Proposald__c,configlistNew);
                }
            }
            if(configMap.size () > 0) {
                List<Apttus_Proposal__Proposal__c> proposalList = [select id,Apttus_QPConfig__BillToAccountId__c, Apttus_Proposal__ExpectedStartDate__c, Apttus_Proposal__ExpectedEndDate__c from 
                                                                   Apttus_Proposal__Proposal__c where id IN:configMap.keyset()];
                for(Apttus_Proposal__Proposal__c prop :proposalList) {
                    for(Apttus_Config2__ProductConfiguration__c  config : configMap.get(prop.id)) {
                        config.Apttus_Config2__BillToAccountId__c = prop.Apttus_QPConfig__BillToAccountId__c;
                        config.Apttus_Config2__ExpectedStartDate__c = prop.Apttus_Proposal__ExpectedStartDate__c;
                        config.Apttus_Config2__ExpectedEndDate__c = prop.Apttus_Proposal__ExpectedEndDate__c;
                    }
                }                                                        
            }
            beforeflag=false;
        }
    }
    
    //Method added as a part of RBAC
    public static void afterInsert(List<Apttus_Config2__ProductConfiguration__c> configlist){
        shareProposalProdConfigRecordsToOppUsers(configlist);
    }
    
    //Method added as a part of RBAC
    public static void shareProposalProdConfigRecordsToOppUsers(List<Apttus_Config2__ProductConfiguration__c> configlist){
        Set<Id> proposalIds = new Set<Id>();
        for(Apttus_Config2__ProductConfiguration__c proposalProdConfigRec : configlist){
            proposalIds.add(proposalProdConfigRec.Apttus_QPConfig__Proposald__c);
        }
        
        List<Apttus_Proposal__Proposal__c> prodConfigProposals = [Select Id, Apttus_Proposal__Opportunity__c From Apttus_Proposal__Proposal__c Where Id IN: proposalIds];
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Id> proposalOppMap = new Map<Id, Id>();
        for(Apttus_Proposal__Proposal__c proposalRec : prodConfigProposals){
            oppIds.add(proposalRec.Apttus_Proposal__Opportunity__c);
            proposalOppMap.put(proposalRec.Id, proposalRec.Apttus_Proposal__Opportunity__c);
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
        List<Apttus_Config2__ProductConfiguration__Share> prodConfigShareRecordsLst = new List<Apttus_Config2__ProductConfiguration__Share>();
        for(Apttus_Config2__ProductConfiguration__c configRec : configlist){
            if(proposalOppMap.get(configRec.Apttus_QPConfig__Proposald__c) != null){
                if(oppTeamMembersMap.get(proposalOppMap.get(configRec.Apttus_QPConfig__Proposald__c)) != null){
                    for(OpportunityTeamMember teamMemberRec : oppTeamMembersMap.get(proposalOppMap.get(configRec.Apttus_QPConfig__Proposald__c))){
                        Apttus_Config2__ProductConfiguration__Share prodConfigShareRec = new Apttus_Config2__ProductConfiguration__Share();
                        prodConfigShareRec.ParentId = configRec.id;
                        prodConfigShareRec.AccessLevel = 'EDIT';
                        prodConfigShareRec.UserOrGroupId = teamMemberRec.UserId;
                        prodConfigShareRecordsLst.add(prodConfigShareRec);
                    }
                }
            }  
        }
        if(!prodConfigShareRecordsLst.isEmpty()){
            Database.insert(prodConfigShareRecordsLst, false);
        }
    }
}