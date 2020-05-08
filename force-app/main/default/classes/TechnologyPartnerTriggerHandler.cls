public class TechnologyPartnerTriggerHandler{
    
    public static void onBeforeInsert(list<Technology_Partner__c> newTechlist){
        set<id> oppid= new Set<Id>();
        for(Technology_Partner__c techpartner : newTechlist){
            if(techpartner.Opportunity__c != null && techpartner.IsPrimary__c == true){
                oppid.add(techpartner.Opportunity__c);
            }
        }
        List<Technology_Partner__c> techpartnerlist = [Select id, Name, Account__c, Opportunity__c, 
                                                                Opportunity__r.id, 
                                                                IsPrimary__c 
                                                                FROM 
                                                                Technology_Partner__c 
                                                                where 
                                                                IsPrimary__c = true 
                                                                AND 
                                                                Opportunity__c in: oppid];
        
        
        for(Technology_Partner__c partnerRec : techpartnerlist){
            partnerRec.IsPrimary__c = false;
        }
        update techpartnerlist;
    }
    
    
    public static void onbeforeupdate(Map<Id, Technology_Partner__c> newTechPartnerMap, Map<Id, Technology_Partner__c> oldTechPartnerMap){
        
        Set<id> oppid = new Set<Id>();
        for(Technology_Partner__c techPartnerRec : newTechPartnerMap.values()){
            if(techPartnerRec.Opportunity__c != null && techPartnerRec.IsPrimary__c == true && techPartnerRec.IsPrimary__c != oldTechPartnerMap.get(techPartnerRec.Id).IsPrimary__c){
               oppid.add(techPartnerRec.Opportunity__c); 
            }
        }
        
        
        List<Technology_Partner__c> techpartnersToUpdate = [Select Id, Name, Account__c, Opportunity__c, Opportunity__r.id,
                                                                    IsPrimary__c 
                                                                    FROM 
                                                                    Technology_Partner__c 
                                                                    WHERE 
                                                                    IsPrimary__c = true 
                                                                    and 
                                                                    Opportunity__c IN: oppid
                                                                    AND 
                                                                    ID NOT IN: newTechPartnerMap.values()];
        for(Technology_Partner__c techRec : techpartnersToUpdate){
            techRec.IsPrimary__c = false;
        }
        update techpartnersToUpdate;
        
        list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id In:oppid And Has_Technology_Partner__c = false];
        for(opportunity rec:opportunityList){
            rec.Has_Technology_Partner__c = true;
        }
        update opportunityList;
    }
    
    public static void onAfterInsert(list<Technology_Partner__c> newTechlist){
        set<id> oppid= new Set<Id>();
        for(Technology_Partner__c techpartner : newTechlist){
            if(techpartner.Opportunity__c != null && techpartner.IsPrimary__c == true){
                oppid.add(techpartner.Opportunity__c);
            }
        }
        list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id In:oppid And Has_Technology_Partner__c = false];
        for(opportunity rec:opportunityList){
            rec.Has_Technology_Partner__c = true;
        }
        update opportunityList;
    }
    
}