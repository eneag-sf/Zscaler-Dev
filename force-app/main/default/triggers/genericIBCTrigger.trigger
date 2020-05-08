trigger genericIBCTrigger on ecosystems_svcs__IBC__c (After Insert, After Update, Before Insert, Before Update, Before delete, After delete){
   
    if(trigger.isAfter && trigger.isInsert){
        if(!TriggerUtility.isupdateLatestIBConOppExecuted())
            IBCTriggerHelper.updateLatestIBConOpp(trigger.new, null);
    }
    if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.isupdateLatestIBConOppExecuted())
            IBCTriggerHelper.updateLatestIBConOpp(trigger.new, trigger.oldMap);
    }

    if(trigger.isAfter && trigger.isDelete){
        if(!TriggerUtility.isupdateLatestIBConOppExecuted())
            IBCTriggerHelper.updateLatestIBConOpp(null, trigger.oldMap);
    }
}