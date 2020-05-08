trigger genericFeedCommentTrigger on FeedComment(before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger && !TriggerUtility.isSkipFeedCommentTriggerExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_FeedComment_Trigger') && tsmap.get('Execute_FeedComment_Trigger') != null && tsmap.get('Execute_FeedComment_Trigger').Execute__c){
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isFeedCommentAfterTriggerExecuted()){
            FeedCommentTriggerUtility.afterInsert(Trigger.new);
        }
    }
}