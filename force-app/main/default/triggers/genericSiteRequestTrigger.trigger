trigger genericSiteRequestTrigger on Site_Request__c (after delete) {
    Set<Id> setEquipmentRequestIds = new Set<Id>();
    for (String key : Trigger.OldMap.keySet()) {
        setEquipmentRequestIds.add(Trigger.oldMap.get(key).ME_Equipment_Request__c);
    }

    List<Equipment_Request__c> lstERsToUpdate = new List<Equipment_Request__c>();
    for (Id equipRequest : setEquipmentRequestIds) {
        lstERsToUpdate.add(new Equipment_Request__c(Id = equipRequest, Is_Site_Request_Approval_Sent__c = False));
    }

    update lstERsToUpdate;
}