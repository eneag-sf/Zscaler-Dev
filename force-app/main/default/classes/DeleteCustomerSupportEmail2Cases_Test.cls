@isTest
public class DeleteCustomerSupportEmail2Cases_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support_EmailToCase').getRecordTypeId();
        Test.startTest();
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        DeleteCustomerSupportEmail2Cases batch;
        batch = new DeleteCustomerSupportEmail2Cases();
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
    }
}