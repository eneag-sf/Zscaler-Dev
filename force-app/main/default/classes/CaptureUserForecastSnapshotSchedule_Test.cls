@istest
public class CaptureUserForecastSnapshotSchedule_Test{
    static testmethod void test1(){
        CaptureUserForecastSnapshotSchedule m = new CaptureUserForecastSnapshotSchedule();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('Pull Leads Job 0', sch, m);
        
    }
}