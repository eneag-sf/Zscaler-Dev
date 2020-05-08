public class EmailMessageTriggerUtility {
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    public static Id caseSupportE2CRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_EmailToCase').getRecordTypeId();
    public static Id salesopsRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
    public static void afterInsert(List<EmailMessage> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_EmailMessage_CaseComment') && tsmap.get('Execute_EmailMessage_CaseComment') != null && tsmap.get('Execute_EmailMessage_CaseComment').Execute__c && !TriggerUtility.isEmailMessagetoCaseCommentExecuted()){
            createCaseComment(newList);
        }
        if(tsmap.containsKey('Close_Case_FRT') && tsmap.get('Close_Case_FRT') != null && tsmap.get('Close_Case_FRT').Execute__c && !TriggerUtility.isEmailMessageFRTExecuted()){
            closeCaseFRT(newList);
        }
        TriggerUtility.EmailMessageAfterInsertExecuted();
    }
    public static void createCaseComment(List<EmailMessage> newList){
        List<Case> clst = new List<Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        for (EmailMessage em : newList){
            if(em.Incoming && em.parentId != null){
                caseIds.add(em.parentId);
            }
        }
        if(!caseIds.isEmpty()){
            for(case cs: [Select Id, RecordTypeId from Case where Id in :caseIds]){
                caseMap.put(cs.Id, cs);
            }
        }
        for (EmailMessage em : newList){
            if(em.Incoming && em.parentId != null && caseMap.containsKey(em.parentId) && caseMap.get(em.parentId) != null && (caseMap.get(em.parentId).RecordTypeId == caseSupportE2CRT || caseMap.get(em.parentId).RecordTypeId == caseSupportRT || caseMap.get(em.parentId).RecordTypeId == salesopsRT)){
                Case cs = new Case(Id = em.parentId, Status='Customer Note Added');
                clst.add(cs);
            }
            
        }
        if(!clst.isEmpty()){
            update clst;
        }
        TriggerUtility.EmailMessagetoCaseCommentExecuted();
    }
    public static void closeCaseFRT(List<EmailMessage> newList){
        Set<Id> CaseIds = new Set<Id>();
        Set<Id> usrIds = new Set<Id>();
        Set<Id> caseIdstoupdate = new Set<Id>();
        List<Case> casetoudpate = new List<case>();
        for(EmailMessage cc: newList){
            if(cc.ParentId != null && !cc.Incoming){
                CaseIds.add(cc.ParentId);
                usrIds.add(cc.CreatedById);
            }
        }
        Map<Id, case> csmap = new Map<Id, Case>([select id, status, First_Response_Timestamp__c from Case where Id in :CaseIds and Recordtype.Developername = 'Support']);
        Map<Id, User> usrinf = new Map<Id, USer>([Select Id, profile.name, service_Level__c, ContactId from User where Id = :usrIds]);
        for(EmailMessage cc: newList){
            if(usrinf != null && !usrinf.isEmpty() && usrinf.containsKey(cc.CreatedById) && usrinf.get(cc.CreatedById).Service_Level__c != null && !csmap.isEmpty() && csmap.containsKey(cc.ParentId) && csmap.get(cc.ParentId).First_Response_Timestamp__c == null){
                caseIdstoupdate.add(cc.ParentId);
            }
        }
        
        if(!caseIdstoupdate.isEmpty()){
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            MilestoneUtils.completeMilestone(caseIdstoupdate, 'First Response', System.now());
        }
        TriggerUtility.EmailMessageFRTExecuted();
    }
}