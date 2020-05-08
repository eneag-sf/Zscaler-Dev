@isTest
public class CleanupAppliedRuleInfoBatchTest {

    static testMethod void testInfo()
    {
        Test.startTest();
        CleanupAppliedRuleInfoBatch info = new CleanupAppliedRuleInfoBatch(true,true);
        Database.executeBatch(info);
        Test.stopTest();
    }
}