trigger genericSCIExternalAttendeeTrigger on SCI_External_Attendee__c (before insert, before update, after insert, after update, after delete, before delete) {
	if(trigger.isAfter && trigger.isDelete){
		if(!TriggerUtility.isudpateSCIforEngagement())
			SCIExternalAttendeeTriggerHelper.udpateSCIforEngagement(trigger.old);

        if(!TriggerUtility.isupdatePartnerAccountForSCIExecuted())
            SCIExternalAttendeeTriggerHelper.updatePartnerAccountForSCI(trigger.Old);
	}

    // After insert or update
    if (Trigger.isAfter
        && (Trigger.isInsert || Trigger.isUpdate)) {
        // if(!TriggerUtility.isupdatePartnerAccountForSCIExecuted())
            SCIExternalAttendeeTriggerHelper.updatePartnerAccountForSCI(trigger.new);
    }
}