@istest
public class CaseLWCControllerTest {
    public Static testMethod void CaseLWCTest(){
        Account acc= new Account();
        acc.Name = 'test';
        insert acc;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        c.AccountId = acc.Id;
	c.Account_of_Support_Case__c = acc.Id;
	c.Legacy_Account__c = 'test';
        c.RecordTypeId = caseSupportRT;
        insert c;
        
        Case c1 = new Case();
        c1.Status = 'Closed';
        c1.Subject = 'test';
        c1.Description = 'test dessc';
        c1.AccountId = acc.Id;
	c.Account_of_Support_Case__c = acc.Id;
	c.Legacy_Account__c = 'test';
        c.RecordTypeId = caseSupportRT;
        insert c1;
        
        Case c2 = new Case();
        c2.Status = 'New';
        c2.Subject = 'test';
        c2.Description = 'test dessc';
        c2.AccountId = acc.Id;
	c.Account_of_Support_Case__c = acc.Id;
	c.Legacy_Account__c = 'test';
        c.RecordTypeId = caseSupportRT;
        insert c2;
        
        
        
        test.startTest();
        CaseLWCController.fetchCases(true, acc.Id);
        test.stopTest();
    }
}