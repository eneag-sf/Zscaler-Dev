/*****************************************************************************************
Name: genericTaskTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Generic trigger to manage all the business logic.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Sep-2015    Initial Development
******************************************************************************************/ 


trigger genericTaskTrigger on Task (after insert, after update, before insert, before update) {
    if(trigger.isInsert && trigger.isAfter){
        if(!TriggerUtility.isCampMemActivityExecuted())
           captureActivityOnLead.getActivityDetail(trigger.newMap);
           
        /*if(!TriggerUtility.isActivityleadterritoryinsertExecuted()){
            captureActivityOnLead.assignleadterritory(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }*/
    }
    /*if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.isActivityleadterritoryupdateExecuted()){
            captureActivityOnLead.assignleadterritory(trigger.new, trigger.Oldmap, trigger.isInsert, trigger.isUpdate);
        }
    }*/
}