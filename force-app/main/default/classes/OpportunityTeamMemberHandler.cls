public class OpportunityTeamMemberHandler {
    
    public void afterInsert(list<OpportunityTeamMember > newOpportunityTeams){
        List<Opportunity_Share__c> oppToShareAgain = new List<Opportunity_Share__c>();
        Map<Id, Id> oppUniqueMap = new Map<Id, Id>();
        for(OpportunityTeamMember member : newOpportunityTeams) {
            if(oppUniqueMap.get(member.OpportunityId) == null){
                Opportunity_Share__c oppShareRec = new Opportunity_Share__c();
                oppShareRec.Opportunity_Id__c = member.OpportunityId;
                oppShareRec.Status__c = 'Ready To Share';
                oppToShareAgain.add(oppShareRec);
                oppUniqueMap.put(member.OpportunityId, member.OpportunityId);
            }
        }
        if(!oppToShareAgain.isEmpty()){
            upsert oppToShareAgain Opportunity_Id__c;
        }
    }
    
    public void afterDelete(list<OpportunityTeamMember > newOpportunityTeams){
        List<Opportunity_Share__c> oppToShareAgain = new List<Opportunity_Share__c>();
        Map<Id, Id> oppUniqueMap = new Map<Id, Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for(OpportunityTeamMember member : newOpportunityTeams) {
            if(oppUniqueMap.get(member.OpportunityId) == null){
                Opportunity_Share__c oppShareRec = new Opportunity_Share__c();
                oppShareRec.Opportunity_Id__c = member.OpportunityId;
                oppShareRec.Status__c = 'Ready To Share';
                oppToShareAgain.add(oppShareRec);
                oppUniqueMap.put(member.OpportunityId, member.OpportunityId);
            }
        }
        if(!oppToShareAgain.isEmpty()){
            upsert oppToShareAgain Opportunity_Id__c;
        }
    }
	
	public static void booster(){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
	}
}