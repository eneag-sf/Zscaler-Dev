trigger RHX_Zscaler_Cloud_ID on Zscaler_Cloud_ID__c
    (after delete, after insert, after undelete, after update, before delete) {
     Type rollClass = System.Type.forName('rh2', 'ParentUtil');
    if(rollClass != null) {
        rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
        if (trigger.isAfter) {
            pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Zscaler_Cloud_ID__c'}, null);
        }
    }
    //Changes done for Autocreation of Zscaler Cloud ID Contact:Gurjinder:Start
    if((trigger.isAfter && trigger.isInsert)){  
        AutocreateZscalerCloudIDContact.CreateZscalerCloudIDContacts(trigger.new);  
    }
    if(trigger.isbefore && trigger.isdelete){
        AutocreateZscalerCloudIDContact.DeleteZscalerCloudIDContacts(trigger.oldMap);
    }
    //Changes done for Autocreation of Zscaler Cloud ID Contact:Gurjinder:End
}