public class UpdateIncumbentPartners {
    
    /**
        Updated BY : Sateesh U 
        This method is used To create Incumbent partners for the opportunity when Opportunity stage equals to '6 - Closed Won'
    **/
    public static void BeforeUpdate(list<Opportunity> newOppList,Map<ID, Opportunity> oldOppMap){
        List<string> OppIds = new List<string>();
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        List<Incumbent_Partner__c> IncumbentPartList = new List<Incumbent_Partner__c>();
        Map<string,string> OppVsAccountIdMap = new Map<string,string>();
        List<Incumbent_Partner__c> IncumbentPartsForOpp = new List<Incumbent_Partner__c>();
        Map<string,Incumbent_Partner__c> OppIdVsIncumPart = new Map<string,Incumbent_Partner__c>();
        
        for(Opportunity Opp:newOppList){
            if(Opp.StageName != oldOppMap.get(Opp.Id).StageName && Opp.StageName == '6 - Closed Won'){
                OppVsAccountIdMap.put(Opp.Id,Opp.AccountId);
                OppIds.Add(Opp.Id);
            }
        }
        
        if(OppIds.size()>0){
             OppPartnersList = [Select Id,Name,Account__c,Account__r.Name,Opportunity__c,Opportunity__r.Name,Partner_Type__c from Opportunity_Partner__c where Opportunity__c IN:OppIds And Is_Primary__c = true];
             IncumbentPartsForOpp = [select Id,
                                            Name,
                                            Account__c,
                                            Opportunity__c,
                                            Partner_Type__c,
                                            Incumbent_Partner_Account__c
                                            From
                                            Incumbent_Partner__c
                                            Where
                                            Opportunity__c IN:OppIds];
                                            
            for(Incumbent_Partner__c IncumbentPart:IncumbentPartsForOpp){
                OppIdVsIncumPart.put(IncumbentPart.Opportunity__c+'-'+IncumbentPart.Incumbent_Partner_Account__c+'-'+IncumbentPart.Partner_Type__c,IncumbentPart);
            }
             
            for(Opportunity_Partner__c OppPartner:OppPartnersList){
                if(OppIdVsIncumPart.get(OppPartner.Opportunity__c+'-'+OppPartner.Account__c+'-'+OppPartner.Partner_Type__c) == null){
                    Incumbent_Partner__c IncumbentPartner = new Incumbent_Partner__c();
                    IncumbentPartner.Incumbent_Partner_Account__c = OppPartner.Account__c;
                    if(OppVsAccountIdMap.get(OppPartner.Opportunity__c) != null){
                        IncumbentPartner.Account__c = OppVsAccountIdMap.get(OppPartner.Opportunity__c);
                    }
                    IncumbentPartner.Opportunity__c = OppPartner.Opportunity__c; 
                    //IncumbentPartner.Is_Primary__c = OppPartner.Is_Primary__c;
                    IncumbentPartner.Partner_Type__c = OppPartner.Partner_Type__c;
                    IncumbentPartList.Add(IncumbentPartner);
                }
            }
        }
        if(IncumbentPartList.size()>0){
            insert IncumbentPartList;
        }
        
    }
}