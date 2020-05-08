@istest
public class CaptureZscalerForecast_MLSchedule_Test{
    static testmethod void test1(){
        CaptureZscalerForecast_MLSchedule m = new CaptureZscalerForecast_MLSchedule ();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('Pull Leads Job 0', sch, m);
        
        CaptureZscalerForecast_MLSchedule m1 = new CaptureZscalerForecast_MLSchedule(1);
        String sch1 = '0 36 1 * * ?';
        jobID = system.schedule('Pull Leads Job 1', sch1, m1);
    }
}