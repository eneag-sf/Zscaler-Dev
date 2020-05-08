@isTest
private class InlineSCIParticipantsNotifCtrlrTest {
    
    @isTest static void testShowBanner() {
        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        accInsertList.add(acc);

        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_2_Qualified_Budgeted /*'2 - Technical Validation'*/, CloseDate = system.Today()+30);
        insert opp;

        contact con = new contact();
        con.FirstName = 'Test';
        con.lastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        contact con1 = new contact();
        con1.FirstName = 'Test';
        con1.lastName = 'Contact';
        con1.AccountId = acc.Id;
        insert con1;

        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci.Date__c = system.today();
        sci.Interaction_With__c = 'Test Data';
        sci.I_am_the__c = 'Organizer';
        sci.Next_Steps__c = 'F2F Meeting';
        sci.Meeting_Notes__c = 'Important conv';
        sci.Account_Name__c = acc.Id;
        insert sci;

        Test.startTest();
        ApexPages.StandardController stdCntrlr = new ApexPages.StandardController(sci);
        InlineSCIParticipantsNotificationCtrlr extension = new InlineSCIParticipantsNotificationCtrlr(stdCntrlr);
        Boolean showBanner = extension.getHasToAddParticipants();

        InlineSCIParticipantsNotificationCtrlr constructorTest = new InlineSCIParticipantsNotificationCtrlr();
        Test.stopTest();
    }
    
}