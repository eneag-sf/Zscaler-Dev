@istest
public class EntitlementInactivetoActive_Batch_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Test.startTest();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        Entitlement ent = new Entitlement();
        ent.Name = 'test';
        ent.AccountId = acct.id;
        insert ent;

        EntitlementInactivetoActive_Batch batch = new EntitlementInactivetoActive_Batch('Select Id, SlaProcess.Name from Entitlement');
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch,200);
        Test.stopTest();
    }
}