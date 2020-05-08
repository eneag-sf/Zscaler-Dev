public class ContentDocumentLinkTriggerUtility {
    public static void afterInsert(List<ContentDocumentLink> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_EmailMessageCDL_to_CaseCDL') && tsmap.get('Execute_EmailMessageCDL_to_CaseCDL') != null && tsmap.get('Execute_EmailMessageCDL_to_CaseCDL').Execute__c && !TriggerUtility.isEmailCDLtoCaseEDLExecuted()){
            createCaseCDLfromEmailCDL(newList);
        }
        //TriggerUtility.CDLAfterInsertExecuted();
    }
    public static void createCaseCDLfromEmailCDL(List<ContentDocumentLink> newList){
        List<ContentDocumentLink> cdllst = new List<ContentDocumentLink>();
        Map<Id, id> linkedEntitytoCaseIdMap = new Map<Id,Id>();
        Set<Id> linkedEntityIds = new Set<Id>();
        for(ContentDocumentLink cdl : newList){
            if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType){
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
        }
        if(!linkedEntityIds.isEmpty()){
            for(EmailMessage em: [Select Id, ParentId from EmailMessage where Id in :linkedEntityIds and Incoming = true and ParentId != null]){
                linkedEntitytoCaseIdMap.put(em.Id, em.ParentId);
            }
        }
        if(!linkedEntitytoCaseIdMap.isEmpty()){
            for(ContentDocumentLink cdl : newList){
                if(cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSobjectType() == Schema.EmailMessage.SObjectType){
                    ContentDocumentLink newcdl = new ContentDocumentLink();
                    newcdl.Visibility = 'AllUsers';
                    newcdl.ShareType = 'I';
                    newcdl.LinkedEntityId = linkedEntitytoCaseIdMap.containsKey(cdl.LinkedEntityId) && linkedEntitytoCaseIdMap.get(cdl.LinkedEntityId) != null ? linkedEntitytoCaseIdMap.get(cdl.LinkedEntityId) : null;
                    newcdl.ContentDocumentId = cdl.ContentDocumentId;
                    cdllst.add(newcdl);
                }
            }
            insert cdllst;
        }
        
        //TriggerUtility.EmailCDLtoCaseEDLExecuted();
    }
}