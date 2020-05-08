@istest
public class CaptureZscalerForecastSch_QtrSwitch_Test{
    static testmethod void test1(){
        CaptureZscalerForecastSchedule_QtrSwitch m = new CaptureZscalerForecastSchedule_QtrSwitch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('CZF', sch, m);
        
        CaptureZscalerForecastSchedule_QtrSwitch m1 = new CaptureZscalerForecastSchedule_QtrSwitch(1);
        String sch1 = '0 36 1 * * ?';
        jobID = system.schedule('CZF 1', sch1, m1);
    }
}