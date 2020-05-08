trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (after insert, after delete) {
    OpportunityTeamMemberHandler handler = new OpportunityTeamMemberHandler();
    if(trigger.isInsert && trigger.isAfter){  
        handler.afterInsert(Trigger.new);
    }
    
    if(trigger.isDelete && trigger.isAfter){ 
        system.debug('the Opp Team deleted records are' + Trigger.old);
        handler.afterDelete(Trigger.old);
    }
}