@isTest
public class AccountTriggerHelperTest 
{
  @isTest static void testMethod1()
    {
        AccountTriggerHelper acc = new AccountTriggerHelper();
        acc.dummyCounter(1);
    }
    
    @isTest static void testMethod2()
    {
        AccountTriggerHelper acc = new AccountTriggerHelper();
        acc.dummyCounter2(1);
    }
}