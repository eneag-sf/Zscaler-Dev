public Class POCTriggerClass{
        public void setCurrentStageOnPR(list<POC_Phase__c> newOldPocPhaseList){
                set<Id> sciIdSet = new set<Id>();
                map<Id, decimal> sciPhaseRankMap = new Map<Id, decimal>();
                map<string, POC_Phase__c> sciRankPocMap = new map<string, POC_Phase__c>();
                for(POC_Phase__c pocPhase : newOldPocPhaseList){
                    if(pocPhase.Significant_Customer_Interaction__c != null){
                        sciIdSet.add(pocPhase.Significant_Customer_Interaction__c);
                    }
                }
                try{
                    for(POC_Phase__c pocPhase : [Select Id, Phase_Rank__c,Significant_Customer_Interaction__c,POC_Phase__c from POC_Phase__c where Significant_Customer_Interaction__c IN:sciIdSet ]){
                        if(pocPhase.Significant_Customer_Interaction__c != null){
                            sciRankPocMap.put(''+pocPhase.Significant_Customer_Interaction__c + pocPhase.Phase_Rank__c, pocPhase);
                            if(sciPhaseRankMap.containsKey(pocPhase.Significant_Customer_Interaction__c)){
                                if(sciPhaseRankMap.get(pocPhase.Significant_Customer_Interaction__c) < pocPhase.Phase_Rank__c)
                                    sciPhaseRankMap.put(pocPhase.Significant_Customer_Interaction__c, pocPhase.Phase_Rank__c);
                            }else{
                                sciPhaseRankMap.put(pocPhase.Significant_Customer_Interaction__c, pocPhase.Phase_Rank__c);
                            }
                        }   
                    }   
                        
                    list<Significant_Customer_Interaction__c>   sciUpdateList = new list<Significant_Customer_Interaction__c>();
                    for(id sciId : sciIdSet){
                        if(sciPhaseRankMap.containsKey(sciId)){
                            sciUpdateList.add(new Significant_Customer_Interaction__c( id = sciId, Current_POC_Phase__c = sciRankPocMap.get(''+sciId+sciPhaseRankMap.get(sciId)).POC_Phase__c));
                        }else{
                            sciUpdateList.add(new Significant_Customer_Interaction__c( id = sciId, Current_POC_Phase__c = null));
                        }
                    }
                    
                    if(!sciUpdateList.isEmpty())
                        database.Update (sciUpdateList,false);
                }catch(exception e){}

        }
    }