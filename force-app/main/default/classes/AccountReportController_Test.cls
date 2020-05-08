@isTest
public class AccountReportController_Test{
    testmethod static void testmethod1(){
        Account acc =new Account(name = 'Test Account');
        insert acc;
        AccountReportController ctrl = new AccountReportController();
        ApexPages.currentPage().getParameters().put('id',acc.Id);
        AccountReportController ctrl1 = new AccountReportController();
    }
}