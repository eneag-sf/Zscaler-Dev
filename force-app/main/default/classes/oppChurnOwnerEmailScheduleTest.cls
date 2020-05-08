@isTest
private class oppChurnOwnerEmailScheduleTest {
    public static String CRON_EXP = '0 0 22 ? * 6L';
    static testmethod void testScheduledJob() {
        String jobId = System.schedule('oppChurnOwnerEmailScheduleTest', CRON_EXP, new oppChurnOwnerEmailSchedule());         
    }
}