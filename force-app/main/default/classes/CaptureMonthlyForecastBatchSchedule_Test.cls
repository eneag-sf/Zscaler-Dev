@isTest
public class CaptureMonthlyForecastBatchSchedule_Test{

    static testmethod void test1(){
        CaptureMonthlyForecastBatchSchedule ctrl = new CaptureMonthlyForecastBatchSchedule(1);
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Merge Job 1', sch, ctrl);
    }
}