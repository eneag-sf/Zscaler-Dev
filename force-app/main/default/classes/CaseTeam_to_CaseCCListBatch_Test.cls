@istest
public class CaseTeam_to_CaseCCListBatch_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        
        Test.startTest();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        CaseTeam_to_CaseCCListBatch batch;
        batch = new CaseTeam_to_CaseCCListBatch('Select Id, Case_CC_List__c from Case limit 1', false);
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch,200);
        Test.stopTest();
        
    }
}