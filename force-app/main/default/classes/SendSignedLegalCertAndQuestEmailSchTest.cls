@isTest
public class SendSignedLegalCertAndQuestEmailSchTest {

    public static String CRON_EXP = '0 0 22 ? * 6L';
    static testmethod void testScheduledJob() {
        Test.StartTest();
        SendSignedLegalCertAndQuestEmailSchedule schedule = new SendSignedLegalCertAndQuestEmailSchedule();
        String sch = '0 0 23 * * ?'; 
        system.schedule('SendSignedLegalCertAndQuestEmailSchTest', sch, schedule);
        Test.stopTest(); 
    }
}