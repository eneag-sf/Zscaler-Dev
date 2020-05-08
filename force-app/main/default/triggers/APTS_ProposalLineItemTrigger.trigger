/* APTS_ProposalLineItemTrigger
 * Trigger for proposal line item(Apttus_Proposal__Proposal_Line_Item__c) Object.
 *
 * Developer: Harish Emmadi, APTTUS - 11/08/2016
 * Business Owner:
 *
 * Scenario:
 *
 *
 *
 * History:
 */
trigger APTS_ProposalLineItemTrigger on Apttus_Proposal__Proposal_Line_Item__c (before insert, before update, after insert, after update,after delete) {
    APTS_ProposalLineItemTriggerHandler handler = new APTS_ProposalLineItemTriggerHandler(true);

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.afterInsert(Trigger.new);
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    /* After Update*/
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.afterUpdate(Trigger.new);
    }

    //Below part commented by Anay Bhande
    //Unused code
    /* After Insert */
//    else if(Trigger.isInsert && Trigger.isAfter){
//        handler.OnAfterInsert(Trigger.new);
//    }
    /* After Update */
//    else if(Trigger.isUpdate && Trigger.isAfter){
//        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
//    }
    /* Before Delete */
 //  else if(Trigger.isDelete && Trigger.isBefore){
 //      handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
//   }
    /* After Delete */
   else if(Trigger.isDelete && Trigger.isAfter){
       handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }

    /* After Undelete */
//    else if(Trigger.isUnDelete){
//        handler.OnUndelete(Trigger.new);
//    }
}