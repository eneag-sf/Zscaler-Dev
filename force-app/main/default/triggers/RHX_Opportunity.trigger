trigger RHX_Opportunity on Opportunity(after delete, after insert, after undelete, after update, before delete) {
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Opportunity_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    if(!skipTrigger){
        Type rollClass = System.Type.forName('rh2', 'ParentUtil');
        //Added check as part of RBAC
        if(!TriggerUtility.isPatchRealigning()) {    
            if(rollClass != null) {
                rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
                if (trigger.isAfter) {
                    pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Opportunity'}, null);
                }
            }
        }
    }
}