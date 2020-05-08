/**
* Single trigger on Project object.
* Uses ProjectTriggerHandler for all business logic
* 
* @Date: xx.xx.xxxx
* @Author: Pankaj
* 
* @Notes: Calls after update, after insert, before insert, before delete, after undelete
*         Inpire Project record replication using trigger 
*/
trigger ProjectTrigger on inspire1__Project__c (after update, after insert, before insert, before delete, after undelete) {
    projectTriggerHandler handler = new projectTriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.afterInsert(Trigger.newMap);
        }
        if(Trigger.isUpdate){
           handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if (Trigger.isUnDelete) {
            //handler.afterUnDelete(Trigger.newMap);
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //Need Trigger.new for insert.
           // handler.beforeInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            //handler.beforedelete(Trigger.oldMap);
        }   
    }
}