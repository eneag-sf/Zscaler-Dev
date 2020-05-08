@isTest
private class ZendeskTicketsListForTDCtrlrTest {
    public static Account acctTest;
    public static Tam_Details__c tamDetail;

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

        tamDetail = new Tam_Details__c(Account_Name__c = acctTest.Id);
        insert tamDetail;
    }

    @isTest static void testZendeskTicketsListForTDCtrlr() {
        Test.setCurrentPage(Page.ZendeskTicketsListForTamDetails);
        ApexPages.currentPage().getParameters().put('id', tamDetail.Id);
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(tamDetail);
        ZendeskTicketsListForTDController ctrlr = new ZendeskTicketsListForTDController(stdCtrlr);
    }
}