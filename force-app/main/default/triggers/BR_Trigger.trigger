trigger BR_Trigger on Event_Expenditure_Request__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(Trigger.isBefore && Trigger.isupdate){
        BR_Trigger_Handler.onbeforeupdate(trigger.new, trigger.oldMap);
    }
}