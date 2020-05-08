trigger UpdateContactonZSCloudContactdeletion on Zscaler_Cloud_ID_Contact__c (before delete,after insert) {
    if(trigger.isbefore && trigger.isdelete && !TriggerUtility.ZCloudIDcontactDeletetriggerExecuted()){
        AutocreateZscalerCloudIDContact.UpdateContactonZSCloudContactdelete(trigger.oldmap);        
    }
    
    if(trigger.isAfter && trigger.isInsert && !TriggerUtility.ZCloudIDcontactAfterInserttriggerExecuted()){
        AutocreateZscalerCloudIDContact.UpdateContactonZSCloudContactInsert(trigger.new);       
    }
    
}