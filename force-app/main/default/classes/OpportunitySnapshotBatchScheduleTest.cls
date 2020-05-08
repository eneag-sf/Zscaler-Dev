@isTest(SeeAllData=true)
private class OpportunitySnapshotBatchScheduleTest {
    static testmethod void test() {   
       test.starttest();     
       String CRON_EXP = '0 0 0 15 3 ? 2022';
       String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new OpportunitySnapshotBatchSchedule());
       test.stopTest();
    }
}