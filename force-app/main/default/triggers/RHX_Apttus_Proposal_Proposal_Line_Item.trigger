trigger RHX_Apttus_Proposal_Proposal_Line_Item on Apttus_Proposal__Proposal_Line_Item__c
    (after delete, after insert, after undelete, after update, before delete) {
  	 Type rollClass = System.Type.forName('rh2', 'ParentUtil');
	 if(rollClass != null) {
		rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
		if (trigger.isAfter) {
			pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Apttus_Proposal__Proposal_Line_Item__c'}, null);
    	}
    }
}