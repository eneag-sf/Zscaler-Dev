@isTest
private class ZendeskTicketsListForFACtrlrTest {
    public static Account acctTest;
    public static Focus_Accounts__c focusAccount;

    static {
        //Account
        acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        insert acctTest;

        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c(
                                                Zendesk__Subject__c = 'Test ticket',
                                                Zendesk__Type__c = 'Task',
                                                Zendesk__Priority__c = 'Normal',
                                                Zendesk__Status__c = 'Open',
                                                Management_Notes__c = 'Test ticket',
                                                Zendesk__Organization__c = acctTest.Id
                                            );
        insert ticket;

        focusAccount = new Focus_Accounts__c(Account_Name__c = acctTest.Id);
        insert focusAccount;
    }

    @isTest static void testZendeskTicketsListForTDCtrlr() {
        Test.setCurrentPage(Page.ZendeskTicketsListForFocusAccounts);
        ApexPages.currentPage().getParameters().put('id', focusAccount.Id);
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(focusAccount);
        ZendeskTicketsListForFAController ctrlr = new ZendeskTicketsListForFAController(stdCtrlr);
    }
}