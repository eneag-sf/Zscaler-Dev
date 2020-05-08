@istest
public class CaptureUserZscalerForecastSchedule_Test{
    static testmethod void test1(){
        CaptureUserZscalerForecastSchedule m = new CaptureUserZscalerForecastSchedule();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('Pull Leads Job 0', sch, m);
        
        CaptureUserZscalerForecastSchedule m1 = new CaptureUserZscalerForecastSchedule(1);
        String sch1 = '0 36 1 * * ?';
        jobID = system.schedule('Pull Leads Job 1', sch1, m1);
    }
}