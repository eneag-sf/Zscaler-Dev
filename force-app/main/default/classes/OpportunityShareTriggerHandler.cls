public class OpportunityShareTriggerHandler {
    
    public static void shareQuoteAndProdConfigToOppTeamMembers(List<Id> oppShareIds){
        if(!system.isBatch() && !system.isFuture()){
            if(oppShareIds.size() > 0){
                opportunityShareEngineStarter starter = new opportunityShareEngineStarter(oppShareIds);
                starter.start();
            }
        }
    }

}