@istest
public class EmailMessageTrigger_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id from User where Service_Level__c != null and isActive=true limit 1];
        Test.startTest();
        System.runAs(ur){
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            TriggerUtility.isSkipCaseTriggerExecuted();
            insert cs;
            Id caseId = cs.Id;

            EmailMessage em = new EmailMessage(parentId = caseId, incoming=true);
            em.HTMLBody = 'abcd';
            insert em;
        }
        Test.stopTest();
        
    }
}