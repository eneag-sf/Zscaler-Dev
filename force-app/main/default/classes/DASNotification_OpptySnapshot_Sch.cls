global class DASNotification_OpptySnapshot_Sch implements Schedulable
{
    global Date sd;
    global Date ed;
    
    global DASNotification_OpptySnapshot_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        DASNotification_OpptySnapshotBatch batch;
        sd = Date.Today().addDays(-1);
        ed = Date.Today().addDays(-1);
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new DASNotification_OpptySnapshotBatch(startdate,enddate);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }