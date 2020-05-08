@isTest
public class CaseEscalationController_LWC_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Test.startTest();
        CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'handoff', '4', true);
        CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'other', '4', true);
        CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'other', '', true);
        CaseEscalationController_LWC.reOpenCs(cs.Id, 'reason');
        CaseEscalationController_LWC.caseHandoff(cs.Id, 'reason');
        CaseEscalationController_LWC.initcaseHandoff(cs.Id);
        CaseEscalationController_LWC.closeCs(cs.Id, 'reason');
        CaseEscalationController_LWC.checkCaseEscalation(cs.Id);
        Test.stopTest();
        
    }
    @IsTest
    static void test2(){
        
        User ur = [Select Id from User where ContactId != null and isactive = true limit 1];
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Test.startTest();
        System.runAs(ur){
            CaseEscalationController_LWC.checkCaseEscalation(cs.Id);
        }
        Test.stopTest();
        
    }
}