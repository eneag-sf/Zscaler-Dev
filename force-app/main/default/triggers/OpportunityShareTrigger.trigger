trigger OpportunityShareTrigger on Opportunity_Share__c (after insert, after update) {
    
    List<Id> oppShareIds = new List<Id>();
    
    if(trigger.isAfter){
        for(Opportunity_Share__c oppShareRec : trigger.new){
            if(oppShareRec.Status__c == 'Ready To Share'){
                oppShareIds.add(oppShareRec.Id);
            }
        }
    }
    
    if(!oppShareIds.isEmpty()){
        OpportunityShareTriggerHandler.shareQuoteAndProdConfigToOppTeamMembers(oppShareIds);
    }

}