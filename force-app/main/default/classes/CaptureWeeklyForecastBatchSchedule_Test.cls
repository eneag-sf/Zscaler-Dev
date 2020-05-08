@isTest
public class CaptureWeeklyForecastBatchSchedule_Test{

    static testmethod void test1(){
        CaptureWeeklyForecastBatchSchedule ctrl = new CaptureWeeklyForecastBatchSchedule(1, true, true, true);
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Merge Job 1', sch, ctrl);
    }
}