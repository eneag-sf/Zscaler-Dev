public class Contract_Extension_TriggerHelper{
    public static void beforeupdate(List<Contract_Extension_Request__c> newlist, Map<Id, Contract_Extension_Request__c > oldmap){
        Map<ID, Contract_Extension_Request__c> opptyIdtoCR = new Map<ID, Contract_Extension_Request__c>();
        
        for(Contract_Extension_Request__c cr: newlist){
            if((cr.Approval_Status__c == 'Approved' || cr.Approval_Status__c =='Rejected' || cr.Approval_Status__c == 'Recalled') && oldmap.containskey(cr.Id) && oldmap.get(cr.Id).Approval_Status__c != cr.Approval_Status__c  && cr.Extension_Request_No__c == cr.Opportunity_Extension_Number__c){                
                opptyIdtoCR.put(cr.Opportunity__c, cr);
            }
        }
        
        setOpptyCRStatusandExtensionDate(opptyIdtoCR);
    }
    
    public static void setOpptyCRStatusandExtensionDate(Map<ID, Contract_Extension_Request__c> opptyIdtoCR){
        List<Opportunity> opptoupdate = new List<Opportunity>();
        for(Id oppId: opptyIdtoCR.keyset()){
            opptoupdate.add(new Opportunity(Id = oppId, Extension_Approval_Status__c = opptyIdtoCR.get(oppId).Approval_Status__c , New_Extended_Contract_Date__c = opptyIdtoCR.get(oppId).Approval_Status__c == 'Approved' ? opptyIdtoCR.get(oppId).Contract_Extension_Date__c : null));
        }
        update opptoupdate;
    }
}