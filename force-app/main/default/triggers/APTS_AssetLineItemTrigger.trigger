trigger APTS_AssetLineItemTrigger on Apttus_Config2__AssetLineItem__c (after insert, after update) {
     APTS_AssetLineItemTriggerHandler handler = new APTS_AssetLineItemTriggerHandler();
     
    if(Trigger.isInsert && Trigger.isAfter)
    {  
      handler.handleAfterInsertEvents(Trigger.new);        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {  
      handler.handleAfterInsertEvents(Trigger.new);        
    }

}