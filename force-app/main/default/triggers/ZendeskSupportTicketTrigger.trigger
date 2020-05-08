/**
 *  Zendesk Support Ticket Trigger
 *    Author			Version 	Description
 *    Raghu Manchiraju    v1.0 		Initial Trigger
 * 
 */

trigger ZendeskSupportTicketTrigger on Zendesk__Zendesk_Ticket__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    //This is mechanism to skip the trigger code part. 
    if(!(ZendeskSupportTicketTriggerHelper.skipTrigger))
    {
        
         ZendeskSupportTicketTriggerHelper handler = new ZendeskSupportTicketTriggerHelper();
         if(Trigger.isInsert && Trigger.isBefore)
         {
             handler.OnBeforeInsert(Trigger.new);
         }
        
         if(Trigger.isInsert && Trigger.isAfter)
         {
             handler.OnAfterInsert(Trigger.new);
         }
        
         if(Trigger.isUpdate && Trigger.isBefore)
         {
             handler.OnBeforeUpdate(Trigger.oldMap, Trigger.newMap);
         }
        
         if(Trigger.isUpdate && Trigger.isAfter)
         {
             handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
         }
         
         if(Trigger.isDelete && Trigger.isBefore)
         {
             handler.onBeforeDelete(Trigger.oldMap);
         }
        
         if(Trigger.isDelete && Trigger.isAfter)
         {
             handler.onAfterDelete(Trigger.oldMap);
         }
        
        //no oldMap available for undelete and no beforeUnDelete operation exists as well
         if(Trigger.isUndelete && Trigger.isAfter)
         {
             handler.onAfterUndelete(Trigger.newMap);
         }
    }
    
}