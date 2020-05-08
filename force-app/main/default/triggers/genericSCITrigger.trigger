trigger genericSCITrigger on Significant_Customer_Interaction__c (before Insert, After Insert, Before Update, After Update, Before delete, After delete) {
    system.debug('TriggerUtility.bypassSCITrigger inside genericSCITrigger  '+TriggerUtility.bypassSCITrigger);
    if(!TriggerUtility.bypassSCITrigger){
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<Id> sciAccountIds = new Set<Id>();
        Map<Id, String> accountTamEmailMap = new Map<Id, String>();
        for (Significant_Customer_Interaction__c sci : (List<Significant_Customer_Interaction__c>)Trigger.new) {
            sciAccountIds.add(sci.Account_Name__c);
        }

        for (Account account : [SELECT Id, TAM_Email__c FROM Account WHERE TAM_Email__c <> NULL AND Id IN :sciAccountIds]) {
            accountTamEmailMap.put(account.Id, account.TAM_Email__c);
        }

        for (Significant_Customer_Interaction__c sci : (List<Significant_Customer_Interaction__c>)Trigger.new) {
            if (accountTamEmailMap.containsKey(sci.Account_Name__c)) {
                sci.TAM_Email__c = accountTamEmailMap.get(sci.Account_Name__c);
            }
        }
    }

    if(trigger.isAfter){
        if(!TriggerUtility.isSCIOppUpdateExecuted()){
            if(trigger.isInsert )
                SCITriggerHelper.updateLatestSCIonOpp(trigger.new, null);
            if(trigger.isUpdate)
                SCITriggerHelper.updateLatestSCIonOpp(trigger.new, trigger.oldmap);
        }
    }

    if(trigger.isDelete && trigger.isAfter)
      if(!TriggerUtility.isSCIOppUpdateExecuted())
        SCITriggerHelper.updateLatestSCIonOpp(null, trigger.oldmap);

    if(trigger.isAfter && trigger.isInsert ){
        if(!TriggerUtility.ismanageZscalerAttendeeExecuted())
            manageZscalerAttendee.addZscalerAttendee(trigger.newMap, null);

         SCITriggerHelper.afterInsert(trigger.newMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        if(!TriggerUtility.ismanageZscalerAttendeeExecuted())
            manageZscalerAttendee.addZscalerAttendee(trigger.newMap, trigger.oldmap);

        SCITriggerHelper.afterUpdate(trigger.newMap);
    }


 }
}