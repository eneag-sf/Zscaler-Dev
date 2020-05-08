@istest
public  class MilestoneUtilsTest {
    @IsTest
    static void test1(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        MilestoneUtils.booster();
        MilestoneUtils.completeMilestone(new Set<Id>{cs.Id}, 'First Response', date.today());
    }
}