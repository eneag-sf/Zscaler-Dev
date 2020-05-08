@isTest
private class ScheduledBatchSendInternalHandoffTest {
    static testMethod void testmethod1(){
        Test.StartTest();
        ScheduledBatchSendInternalHandoffEmail Schedule = new ScheduledBatchSendInternalHandoffEmail();
        String sch = '0 0 23 * * ?';
        system.schedule('Test', sch, Schedule);
        Test.stopTest();
    }
}