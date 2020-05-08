@isTest
public class ZendeskTicketsListControllerTest{
    public static Account acctTest;

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
                                                Zendesk__Organization__c = acctTest.Id, Sub_Area__c = 'zmca'
                                            );
        insert ticket;
    }

    static testMethod void testZendeskTicketsListController() {
        ZendeskTicketsListController controller = new ZendeskTicketsListController();
        controller.accountId = acctTest.Id;
        controller.getTickets();
        controller.showMore();
    }
}