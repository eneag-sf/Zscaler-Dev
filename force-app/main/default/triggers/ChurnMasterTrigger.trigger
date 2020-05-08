/*
 *  @purpose: Covers all trigger events in Churn object.
 * 			  Please extend this same trigger for additional functionality
 * 
 *  @author : Pranjal Singh
 */
trigger ChurnMasterTrigger on Churn__c (before insert,before update,before delete) {
    if(Trigger.isBefore){
        if(Trigger.isinsert){
            Util_ChurnReasonMethods.checkChurnPresentFlag_onOpp(Trigger.new);
        }
        if(Trigger.isDelete){
            Util_ChurnReasonMethods.checkChurnPresentFlag_onOpp(Trigger.old);    	
        }
    }
}