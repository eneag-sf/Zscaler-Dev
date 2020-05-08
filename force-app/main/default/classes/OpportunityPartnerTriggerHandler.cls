/**
	Updated BY : Sateesh U 
	This class is used To update 'Has_Technology_Partner__c' on opportunity when there is Technology partners exists
**/
public class OpportunityPartnerTriggerHandler {
    
    public static void onBeforeInsert(list<Opportunity_Partner__c> newOppPartnerList){
        
        List<string> OppIds = new List<string>();
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true && Partner.Partner_Type__c == 'Tech Partner'){
                OppIds.Add(Partner.Opportunity__c);
            }
        }
        
        list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id IN:OppIds And Has_Technology_Partner__c = false];
        for(opportunity rec:opportunityList){
            rec.Has_Technology_Partner__c = true;
        }
        update opportunityList;
        
        /**List<string> OppIds = new List<string>();
        List<string> Types = new List<string>();
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true){
                OppIds.Add(Partner.Opportunity__c);
                Types.Add(Partner.Partner_Type__c);
            }
        }
        
        if(OppIds.size()>0){
            OppPartnersList = [select Id,Name,
                                      Opportunity__c,
                                      Partner_Type__c 
                                      from 
                                      Opportunity_Partner__c 
                                      where 
                                      Opportunity__c IN:OppIds 
                                      And 
                                      Partner_Type__c IN:Types 
                                      And 
                                      Is_Primary__c = true];
                                      
            for(Opportunity_Partner__c OppPartner:OppPartnersList){
                OppPartner.Is_Primary__c = false;
            }
            
            update OppPartnersList;
        }**/
    }
    
    public static void onBeforeUpdate(list<Opportunity_Partner__c> newOppPartnerList,Map<ID, Opportunity_Partner__c> oldOppPartnerMap){
        
        List<string> OppIds = new List<string>();
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true && Partner.Is_Primary__c != oldOppPartnerMap.get(Partner.Id).Is_Primary__c  && Partner.Partner_Type__c == 'Tech Partner'){
                OppIds.Add(Partner.Opportunity__c);
            }
        }
        
        list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id IN:OppIds And Has_Technology_Partner__c = false];
        for(opportunity rec:opportunityList){
            rec.Has_Technology_Partner__c = true;
        }
        update opportunityList;
        
        /**List<string> OppIds = new List<string>();
        List<string> Types = new List<string>();
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Opportunity__c != null && Partner.Is_Primary__c == true && Partner.Is_Primary__c != oldOppPartnerMap.get(Partner.Id).Is_Primary__c){
                OppIds.Add(Partner.Opportunity__c);
                Types.Add(Partner.Partner_Type__c);
            }
        }
        
        if(OppIds.size()>0){
            OppPartnersList = [select Id,Name,
                                      Opportunity__c,
                                      Partner_Type__c 
                                      from 
                                      Opportunity_Partner__c 
                                      where 
                                      Opportunity__c IN:OppIds 
                                      And 
                                      Partner_Type__c IN:Types 
                                      And 
                                      Is_Primary__c = true];
                                      
            for(Opportunity_Partner__c OppPartner:OppPartnersList){
                OppPartner.Is_Primary__c = false;
            }
            
            update OppPartnersList;
        }**/
    }
    
    /*public static void onBeforeDelete(list<Opportunity_Partner__c> newOppPartnerList){
        
        List<string> OppIds = new List<string>();
        Map<string,string> IdVsRecMap = new Map<string,string>();
        List<Opportunity_Partner__c> OppPartnersList = new List<Opportunity_Partner__c>();
        
        for(Opportunity_Partner__c Partner:newOppPartnerList){
            OppIds.Add(Partner.Opportunity__c);
        }
        
        if(OppIds.size()>0){
            OppPartnersList = [select Id,Name,
                                      Opportunity__c,
                                      Partner_Type__c 
                                      from 
                                      Opportunity_Partner__c 
                                      where 
                                      Opportunity__c IN:OppIds 
                                      And 
                                      Partner_Type__c = 'Tech Partner'
                                      And 
                                      Is_Primary__c = true];
                                      
            for(Opportunity_Partner__c Partner:OppPartnersList){
                IdVsRecMap.put(Partner.Opportunity__c,Partner.Opportunity__c);
            }
                                      
            list<opportunity> opportunityList = [Select Id, Has_Technology_Partner__c From opportunity where id IN:OppIds And Has_Technology_Partner__c = true];
            for(opportunity rec:opportunityList){
                if(IdVsRecMap.get(rec.Id) == null){
                    rec.Has_Technology_Partner__c = false;
                }
            }
            update opportunityList;
            
        } 
        
        /**for(Opportunity_Partner__c Partner:newOppPartnerList){
            if(Partner.Is_Primary__c == true){
                Partner.addError('You Cannot Delete Primary Partner Record');
            }
        }**
    }**/
}