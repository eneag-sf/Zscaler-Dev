/* APTS_LineItem_Master_Trigger 
 * Trigger for line item(Apttus_Config2__LineItem__c) Object.
 *
 * Developer: Sagar Jogi, APTTUS - 12/29/2016
 */
trigger APTS_LineItem_Master_Trigger on Apttus_Config2__LineItem__c (before insert, before update, after insert, after update) {
    APTS_LineItem_Master_TriggerHandler handler = new APTS_LineItem_Master_TriggerHandler(true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new,Trigger.old, Trigger.oldMap);
    }
    /* Before Delete */
//    else if(Trigger.isDelete && Trigger.isBefore){
//        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
//    }
    /* After Delete */
//    else if(Trigger.isDelete && Trigger.isAfter){
//        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
//    }

    /* After Undelete */
//    else if(Trigger.isUnDelete){
//        handler.OnUndelete(Trigger.new);
//    }
}