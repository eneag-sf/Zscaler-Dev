public class APTSCU_CreateOpportunitySplitUtil {
    
    public set<string> oppIdSet;
    
    public APTSCU_CreateOpportunitySplitUtil () {
        oppIdSet= new set<string> ();
    }
    
    public void init(Map<id,OpportunityLineItem> oppLineItemMap) {
        String ownerId;
        for(OpportunityLineItem opl :oppLineItemMap.values()) {
            oppIdSet.add(opl.OpportunityId);
            
        }
         
        
        List<opportunity> oppList = new List<opportunity> ();
        opplist = [select id,Cross_Sell_Up_Sell__c,Renewal_Amount__c,ownerId,Account.Account_Manager__c,Account.Account_Manager__r.isactive from  opportunity where id IN:oppIdSet AND Type='Existing Customer (Renewal)'];
        
        oppIdSet = new Set<string> ();
        for(opportunity opp :oppList) {
            
            oppIdset.add(opp.Id);
        }
        if(opplist.size() > 0) {
            Map<string,string> oppMap = new Map<string,string>();
            Map<string,string> oppMapManager = new Map<string,string>();
            
            
            List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember> ();
            oppTeamMemberList = [select id,OpportunityId,UserId from OpportunityTeamMember where OpportunityId IN:oppIdSet];
            
            Set<string> oppTeamMemberSet = new Set<string> ();
            for(OpportunityTeamMember opTM: oppTeamMemberList) {
                oppTeamMemberSet.add(String.valueof(opTM.UserId).substring(0,15)+'$'+String.valueof(opTM.OpportunityId).substring(0,15));
            }
            
            List<OpportunityTeamMember> oppTeamMemberListToInsert = new List<OpportunityTeamMember> ();
            
            List<User> userList = new List<User> ();
            userList = [select id,ManagerId from user where ManagerId != null AND isactive = true];
            
            OpportunityTeamMember opTM;
            
            for(Opportunity opp :opplist) {
                opTM = new OpportunityTeamMember();
                oppMap.put(string.valueof(opp.Id).substring(0,15),opp.ownerId);
                if(opp.Account.Account_Manager__c != null && opp.Account.Account_Manager__r.isActive == true) {
                    oppMapManager.put(string.valueof(opp.id).substring(0,15),opp.Account.Account_Manager__c);
                    if(!oppTeamMemberSet.contains(String.valueof(opp.Account.Account_Manager__c).substring(0,15)+'$'+String.valueof(opp.id).substring(0,15))) {
                        opTM.OpportunityId = opp.Id;
                        opTM.UserId = opp.Account.Account_Manager__c;
                        opTM.TeamMemberRole = 'Account Manager';
                        oppTeamMemberListToInsert.add(opTM);
                    }
                } else {
                    oppMapManager.put(string.valueof(opp.id).substring(0,15),userList[0].Id);
                    if(!oppTeamMemberSet.contains(String.valueof(userList[0].Id).substring(0,15)+'$'+String.valueof(opp.id).substring(0,15))) {
                        opTM.OpportunityId = opp.Id;
                        opTM.UserId = userList[0].Id;
                        opTM.TeamMemberRole = 'Account Manager';
                        oppTeamMemberListToInsert.add(opTM);
                    }
                } 
                
                
            }
            
            if(oppTeamMemberListToInsert.size() >0) {
                insert oppTeamMemberListToInsert;
            }
             
            List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c> ();
            proposalList  = [select id,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Primary__c from Apttus_Proposal__Proposal__c 
                                where Apttus_Proposal__Primary__c= true AND Apttus_Proposal__Opportunity__c IN:oppIdSet];
            Set<string> proposalIdSet = new Set<string> ();
            
            for(Apttus_Proposal__Proposal__c prop:proposalList) {
                proposalIdSet.add(prop.id);
            }
            
            
            Map<string,Decimal> oldACVMap = new Map<string, Decimal>();
            Map<string,Decimal> newACVMap = new Map<string, Decimal>();
            
            
            Map<string,Decimal> oldACVMapOLI = new Map<string, Decimal>();
            Map<string,Decimal> newACVMapOLI = new Map<string, Decimal>();
            
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c> ();
            proposalLineItemList = [select id,APTS_ACV__c,APTS_Upsell_Corp_ACV__c,Apttus_QPConfig__AssetLineItemId__c,Apttus_Proposal__Product__c,Apttus_QPConfig__AssetLineItemId__r.APTS_ACV__c,APTS_Renewal_Corp_ACV__c,Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c,Apttus_Proposal__Proposal__r.APTSCU_Original_Quote_ACV__c 
                                        from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c IN:proposalIdSet];
            Boolean isupsell = false;
            Set<string> upsellOppIdSet = new set<string> ();
            
            for(Apttus_Proposal__Proposal_Line_Item__c prli :proposalLineItemList) {
                Decimal oldACV = 0;
                Decimal newACV = 0;
                Decimal oldACVOLI = 0;
                Decimal newACVOLI = 0;
                
                if(prli.Apttus_QPConfig__AssetLineItemId__c == null) {
                    isupsell = true;
                    upsellOppIdSet.add(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15));
                }
                
                
                if(oldACVMap.get(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15)) != null) {
                    oldACV = oldACVMap.get(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15));
                }
                if(newACVMap.get(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15)) != null) {
                    newACV = newACVMap.get(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15));
                }
                
                
                if(oldACVMapOLI.get(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15)) != null) {
                    oldACVOLI = oldACVMapOLI.get(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15));
                }
                if(newACVMapOLI.get(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15)) != null) {
                    newACVOLI = newACVMapOLI.get(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15));
                }
                
                if(prli.APTS_Renewal_Corp_ACV__c != null)  {
                   newACV = newACV + prli.APTS_Renewal_Corp_ACV__c;
                   newACVOLI = newACVOLI +prli.APTS_Renewal_Corp_ACV__c;
                }
                if(prli.APTS_Upsell_Corp_ACV__c != null) {
                    oldACV = oldACV + prli.APTS_Upsell_Corp_ACV__c; 
                }
                
                if(prli.Apttus_QPConfig__AssetLineItemId__c != null && prli.Apttus_QPConfig__AssetLineItemId__r.APTS_ACV__c != null) {
                   // oldACV = oldACV + prli.Apttus_QPConfig__AssetLineItemId__r.APTS_ACV__c;
                    oldACVOLI = oldACV + prli.Apttus_QPConfig__AssetLineItemId__r.APTS_ACV__c;
                }
                
                oldACVMap.put(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15),oldACV);
                newACVMap.put(string.valueof(prli.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c).substring(0,15),newACV);
                
                
                oldACVMapOLI.put(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15),oldACVOLI);
                newACVMapOLI.put(string.valueof(prli.Apttus_Proposal__Product__c).substring(0,15),newACVOLI);
                
            }
            
            List<OpportunityLineItem> oppLineItemToUpdate = new List<OpportunityLineItem>();
            
            OpportunityLineItem opLI;
            
            for(OpportunityLineItem opl :oppLineItemMap.values()) {
                Boolean isupdate = false;
                opLI = new OpportunityLineItem(id=opl.Id);
                if(oldACVMapOLI.get(string.valueof(opl.product2Id).substring(0,15)) != null) {
                    opLI .APTSCU_Old_ACV__c = oldACVMapOLI.get(string.valueof(opl.product2Id).substring(0,15));
                }
                if(newACVMapOLI.get(string.valueof(opl.product2Id).substring(0,15)) != null) {
                    opLI .APTSCU_New_ACV__c = newACVMapOLI.get(string.valueof(opl.product2Id).substring(0,15));
                }
                if(isupdate) {
                    oppLineItemToUpdate.add(opLI );
                }
                
            }
            
            if(oppLineItemToUpdate.size() > 0) {
              //  update oppLineItemToUpdate;
            }
            
            List<OpportunitySplit> oppSplitList = new List<OpportunitySplit>();
            oppSplitList = [select id,opportunityID,APTSCU_Amount__c,Split_Type__c,SplitPercentage,SplitOwnerID  from OpportunitySplit where opportunityID IN:oppIdSet];
            
            Map<string,List<OpportunitySplit>> oppSplitMap = new Map<string,List<OpportunitySplit>>();
            
            List<OpportunitySplit> opSplitList;
            for(OpportunitySplit ops : oppSplitList) {
                  opSplitList = new List<OpportunitySplit>();
                  if(oppSplitMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                      opSplitList = oppSplitMap.get(string.valueof(ops.opportunityID).substring(0,15));
                  }
                  opSplitList.add(ops);
                  oppSplitMap.put(string.valueof(ops.opportunityID).substring(0,15),opSplitList);
                   /*
                    if(oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                        ops.APTSCU_Total_Renewal_ACV__c = oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                    }
                    if(newACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                        if(oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                            ops.APTSCU_TOTAL_UPSELL_ACV__c = newACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) - oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                        } else {
                            ops.APTSCU_TOTAL_UPSELL_ACV__c = newACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                        }
                    }
                    */
                  
            }
            
            OpportunitySplit os;
            
            for(string oppId : oppIdSet) {
                if(oppSplitMap.get(oppId.substring(0,15)) == null) {
                    os = new OpportunitySplit();
                    os.opportunityID = oppId;
                    os.SplitPercentage = 100;
                    os.SplitOwnerID = oppMap.get(oppId.substring(0,15));
                    os.Split_Type__c = 'Renewal';
                    oppSplitList.add(os);
                    
                    OpportunitySplit os1 = new OpportunitySplit();
                    os1.opportunityID = oppId;
                    os1.SplitPercentage = 0;
                    os1.SplitOwnerID = oppMapManager.get(oppId.substring(0,15));
                    os1.Split_Type__c = 'Upsell';
                    oppSplitList.add(os1);
                    system.debug('@@@@==='+oppSplitList);
                }
                
                if(oppSplitMap.get(oppId.substring(0,15)).size() == 1) {
                    oppSplitMap.get(oppId.substring(0,15))[0].Split_Type__c = 'Renewal';
                    os = new OpportunitySplit();
                    os.opportunityID = oppId;
                    os.SplitPercentage = 0;
                    os.SplitOwnerID = oppMapManager.get(oppId.substring(0,15));
                    os.Split_Type__c = 'Upsell';
                    oppSplitList.add(os);
                    system.debug('1@@@@==='+oppSplitList);
                }
            }
            
            if(oppSplitList.size() > 0) {
                system.debug('222'+oppSplitList);
                upsert oppSplitList;
            }
            
            
            List<OpportunitySplit> oppSplitListNew = new List<OpportunitySplit>();
            oppSplitListNew = [select id,opportunityID,APTSCU_Amount__c,Split_Type__c,SplitPercentage from OpportunitySplit where opportunityID IN:oppIdSet];
            
            Map<string,List<OpportunitySplit>> oppSplitMapNew = new Map<string,List<OpportunitySplit>>();
            
            List<OpportunitySplit> opSplitListNew;
            for(OpportunitySplit ops : oppSplitListNew) {
                  opSplitListNew = new List<OpportunitySplit>();
                  if(oppSplitMapNew.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                      opSplitListNew = oppSplitMapNew.get(string.valueof(ops.opportunityID).substring(0,15));
                  }
                  opSplitListNew.add(ops);
                  oppSplitMapNew.put(string.valueof(ops.opportunityID).substring(0,15),opSplitListNew);
                    
            }
            
            
            List<OpportunitySplit> oppSplitListToUpsert = new List<OpportunitySplit>();
            system.debug('###oldACVMap'+oldACVMap);
            system.debug('$$$newACVMap'+newACVMap);
            for (String oppId : oppSplitMapNew.keySet()){
                for(OpportunitySplit ops :oppSplitMapNew.get(oppId)) {
                    Decimal upsellAmount = 0;
                    Decimal renewlAmount = 0;
                    Decimal totalAmount = 0;
                    Decimal splitPercentage ;
                    if(ops.Split_Type__c == 'Upsell') {
                         
                         if(!upsellOppIdSet.contains(oppId)) {
                             delete ops;
                         } else {
                             if(oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                            
                                ops.APTSCU_Amount__c = oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                                
                                upsellAmount = ops.APTSCU_Amount__c;
                            }
                            if(newACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                                renewlAmount = newACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                            }
                            
                            if(upsellAmount > 0) {
                                totalAmount =  upsellAmount + renewlAmount;
                            
                                ops.SplitPercentage =  (upsellAmount/totalAmount) * 100;
                                oppSplitListToUpsert.add(ops);
                            } else {
                                delete ops;
                            }
                       }
                        
                    } else {
                        if(oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                              upsellAmount = oldACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                        }
                        if(newACVMap.get(string.valueof(ops.opportunityID).substring(0,15)) != null) {
                            ops.APTSCU_Amount__c = newACVMap.get(string.valueof(ops.opportunityID).substring(0,15));
                        }
                        renewlAmount = ops.APTSCU_Amount__c;
                        if(upsellAmount > 0) {
                            totalAmount =  upsellAmount + renewlAmount;
                             if(!upsellOppIdSet.contains(oppId)) {
                                 ops.SplitPercentage = 100;
                             } else {
                                ops.SplitPercentage =  (renewlAmount/totalAmount) * 100;
                            }
                            oppSplitListToUpsert.add(ops);
                        }
                       
                    }
                    
                    
                }
            }
            if(oppSplitListToUpsert.size() > 0) {
                system.debug(oppSplitListToUpsert);
                upsert oppSplitListToUpsert;
            }
           for(opportunity opp :oppList) {
                if(oldACVMap.get(string.valueof(opp.id).substring(0,15)) != null) {
                    opp.Renewal_Amount__c = oldACVMap.get(string.valueof(opp.id).substring(0,15));
                }
                
                if(newACVMap.get(string.valueof(opp.id).substring(0,15)) != null){
                     opp.Cross_Sell_Up_Sell__c = newACVMap.get(string.valueof(opp.id).substring(0,15));
                }
               
                
            }
            update oppList;
    
        } 
        
        
      
        
    }
}