@isTest
public class MonthlyPolicyConfigsTest{
    public static Account acctTest;
    public static Focus_Accounts__c focusAccount;

    static {
        //Account
        acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        insert acctTest;

        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c(Account__c = acctTest.Id, Org_Name__c = 'Test', Status__c = 'Production');
        insert cloudId;

        Monthly_Policy_Configurations__c config = new Monthly_Policy_Configurations__c(
                                                    O365_One_Click__c = 'Enabled',
                                                    Number_of_GRE_Tunnels__c = 50,
                                                    Number_of_IP__c = 10,
                                                    Max__c = 9000,
                                                    IPs_without_Location__c = 100,
                                                    Authentication_Frequency__c = 'Only Once',
                                                    Account__c = acctTest.Id,
                                                    Zscaler_Cloud_ID__c = cloudId.Id
                                                );
        insert config;

        focusAccount = new Focus_Accounts__c(Account_Name__c = acctTest.Id);
        insert focusAccount;
    }

    static testMethod void testMonthlyPolicyConfigsController() {
        Test.setCurrentPage(Page.MonthlyPolicyConfigsForFocusAccounts);
        ApexPages.currentPage().getParameters().put('id', focusAccount.Id);
        ApexPages.StandardController stdCtrlr = new ApexPages.StandardController(focusAccount);
        MonthlyPolicyConfigsListController controller = new MonthlyPolicyConfigsListController(stdCtrlr);
        controller.accountId = acctTest.Id;
        controller.getConfigs();
        controller.showMore();
    }
}