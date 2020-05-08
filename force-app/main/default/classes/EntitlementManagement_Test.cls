@istest
public class EntitlementManagement_Test {
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
        Map<Id, String> accmap = new Map<Id, String>{acct.Id => 'premplus'};
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        Entitlement ent = new Entitlement();
        ent.Name = 'test';
        ent.AccountId = acct.id;
        ent.Startdate = date.today();
        insert ent;

        EntitlementManagement.createEntitleMent(accmap);
        EntitlementManagement.updateExistingEntitlement(accmap);
        Test.stopTest();
    }
}