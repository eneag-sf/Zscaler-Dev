trigger RHX_Equipment_Request on Equipment_Request__c
    (after delete, after insert, after undelete, after update, before delete) {
  	 Type rollClass = System.Type.forName('rh2', 'ParentUtil');
	 if(rollClass != null) {
		rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
		if (trigger.isAfter) {
			pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Equipment_Request__c'}, null);
    	}
    }
    
    if(trigger.isInsert && trigger.isBefore){
        for(Equipment_Request__c epRec : trigger.new){
            epRec.ER_Owner__c = userinfo.getUserId();
        }
    }
}