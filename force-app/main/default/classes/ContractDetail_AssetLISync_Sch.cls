global class ContractDetail_AssetLISync_Sch implements Schedulable
{
    global Date sd;
    global Date ed;
    
    global ContractDetail_AssetLISync_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        ContractDetail_AssetLISync_batch batch;
        sd = Date.Today().addDays(-1);
        ed = Date.Today().addDays(-1);
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new ContractDetail_AssetLISync_batch(startdate,enddate);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }