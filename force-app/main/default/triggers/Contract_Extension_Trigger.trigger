trigger Contract_Extension_Trigger on Contract_Extension_Request__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(Trigger.isBefore && Trigger.isUpdate){
        Contract_Extension_TriggerHelper.beforeupdate(Trigger.new, Trigger.OldMap);
    }
}