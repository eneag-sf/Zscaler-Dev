trigger OwnerCopy on Opportunity (before Insert,before Update) {
    //if(!TriggerUtility.isPatchRealigning()) {
        /* for(Opportunity x:Trigger.New){
            x.Owner_Details__c=x.OwnerID;
        } */
      
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Opportunity_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    if(!skipTrigger){
        if(trigger.isInsert && trigger.isBefore){
            Set<id> CampaignIdSet= new Set<id>();
            Set<String> UntaggingCampaignTypeSet= new Set<String>();
            String UntaggingCampaignType= ZscalerCustomSetting__c.getInstance('UntaggingCampaignType')!=null && ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('UntaggingCampaignType').Value__c:'Operational,Non-Marketing Programs';
            UntaggingCampaignTypeSet.addall(UntaggingCampaignType.split(','));      
            for(Opportunity opp : trigger.new){
               if((opp.Type == 'Existing Customer (Add On)' || opp.Type == 'New Business' ) && opp.Lead_Source_Map__c != null && opp.Lead_Source_Map__c != '' ){
                    opp.LeadSource = opp.Lead_Source_Map__c;
                }
                if(opp.CampaignId!=null){
                    CampaignIdSet.add(opp.CampaignId);              
                }
            }
            
            Map<Id,Campaign> CampaignMap = new Map<Id,Campaign>([Select Id,name,type,Campaign_Type__c from Campaign where Id =:CampaignIdSet]);
            
            for(Opportunity opp : trigger.new){
                if(opp.CampaignId!=null && CampaignMap.get(opp.CampaignId)!=null && UntaggingCampaignTypeSet.contains(CampaignMap.get(opp.CampaignId).Campaign_Type__c)){
                    opp.CampaignId=null;
                }
            }
            
        }
    }
         
    //}
}