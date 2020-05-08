trigger Forecastcategoryupdates on Opportunity (before insert, before update, after insert, after update) {
    //PatchRealigning Check is added as a part of RBAC
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Account_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    if(!skipTrigger){
        if(!TriggerUtility.isPatchRealigning()) {
            if(Trigger.isinsert && Trigger.isBefore){
                OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
                OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                OppotunityTriggerHelper.clearNSfieldsonCreation(Trigger.New);
            }
            if(Trigger.isUpdate && Trigger.isBefore && !TriggerUtility.isOpptyTriggerFCexecuted()){
                OppotunityTriggerHelper.handleallcategoryfieldandlockchanges(Trigger.newmap, Trigger.Oldmap);
                OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                OppotunityTriggerHelper.validateClosedLostwithOpenPRs(trigger.newMap, trigger.oldmap);
            }
            //Changes Added as a part of RBAC :Start
            if(Trigger.isinsert && trigger.isAfter){
                OppotunityTriggerHelper.afterInsert(trigger.new);
            }
            
            if(Trigger.isUpdate && trigger.isBefore){
                OppotunityTriggerHelper.afterUpdate(trigger.new, trigger.oldmap);
            }
        }
        else{
            if(Trigger.isinsert && Trigger.isBefore){ OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
                //OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                //OppotunityTriggerHelper.clearNSfieldsonCreation(Trigger.New);
            }
        }
    }
     //Changes Added as a part of RBAC :End
}