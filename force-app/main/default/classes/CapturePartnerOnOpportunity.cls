Public Class CapturePartnerOnOpportunity{
    public static void insertPartner( list<Opportunity> newOppList, map<id, Opportunity> oldOppMap){
        list<Partner> partnerInsertList = new list<Partner>();
        
            for(Opportunity opp: newOppList){
                if(oldOppMap == null){
                    if(opp.Partner_Account_Name__c != null){
                        partnerInsertList.add(createOppPartner(opp));
                    }else{
                        
                    }
                }else{
                    if(oldOppMap.get(opp.Id).Partner_Account_Name__c == null && oldOppMap.get(opp.Id).Partner_Account_Name__c != opp.Partner_Account_Name__c){
                        partnerInsertList.add(createOppPartner(opp));
                    }
                }
                
            }
        
        
        if(!partnerInsertList.isEmpty())
            database.insert(partnerInsertList,false);
       
    }
    
    public static partner createOppPartner(Opportunity opp){
        Partner p = new Partner();
        p.Role = 'VAR/Reseller';
        p.OpportunityId = opp.Id;
        p.AccountToId = opp.Partner_Account_Name__c;
        p.IsPrimary = true;
        return p;
    }
    
      @future (callout=true)
      public static void updateOpportunityPartner(set<id> oppIdSet) {
        map<id, id> OppAccIdMap = new map<id,id>();
        
        list<Opportunity> oppUpdateList = new list<Opportunity>();
        for(OpportunityContactRole  oppCon  : [select contactId, contact.Partner_Deal_Reg_Account_Name__c, Role, OpportunityId, IsPrimary from OpportunityContactRole where OpportunityId IN: oppIdSet AND IsPrimary =: true AND contact.Partner_Deal_Reg_Account_Name__c != null]){
            OppAccIdMap.put(oppCon.OpportunityId, oppCon.contact.Partner_Deal_Reg_Account_Name__c);
        }
        list<Partner> partnerInsertList = new list<Partner>();
        
        for(id oppId : OppAccIdMap.keySet()){
            partnerInsertList.add(createOppPartner(new opportunity(id = oppId, Partner_Account_Name__c = OppAccIdMap.get(oppId))));
            oppUpdateList.add(new opportunity(id= oppid, Partner_Role__c = 'Sourced'));
        }
        
        if(!partnerInsertList.isEmpty())
            database.Insert(partnerInsertList, false);
        if(!oppUpdateList.isEmpty())
            database.update(oppUpdateList, false);    
      }
    

}