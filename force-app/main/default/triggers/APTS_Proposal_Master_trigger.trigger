/*
*************************************************
Name :  APTS_Proposal_Master_trigger
CreatedBy :  Sanjay Nair  <sanjaynair@apttus.com>
CreatedOn :  12 Nov 2016
Description :  Master Trigger for Quote/Proposal object.
*************************************************
*/

trigger APTS_Proposal_Master_trigger on Apttus_Proposal__Proposal__c (before insert, before update, after insert, after update) {
  //  Zscaler_Admin_Settings__c settings = Zscaler_Admin_Settings__c.getInstance(UserInfo.getUserId());

//    if (settings != null && settings.Is_Data_Migration_User__c != true) {
        APTS_Proposal_Trigger_Handler instTrHand = new APTS_Proposal_Trigger_Handler();
        if (trigger.isafter && trigger.isinsert){
            //Written by Pranjal Mittal for New Approval Changes
            //instTrHand.updateFieldOnCart(trigger.oldmap, trigger.newmap);
            instTrHand.onAfterInsert(trigger.new);
        }
        if (trigger.isbefore && trigger.isinsert){
            instTrHand.onBeforeInsert(trigger.new);
        }
        if (trigger.isbefore && trigger.isupdate){
            instTrHand.onBeforeUpdate(trigger.new,trigger.oldmap);
        }
        if (trigger.isafter && trigger.isupdate){
            //Written by Pranjal Mittal for New Approval Changes
            //instTrHand.updateFieldOnCart(trigger.oldmap, trigger.newmap);
            instTrHand.onAfterUpdate(trigger.new,trigger.oldmap); 
        }
  //  }
}