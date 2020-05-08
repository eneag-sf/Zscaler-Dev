global class UpdateRollupDetailsonCampaigns_Sch implements Schedulable
{
    global UpdateRollupDetailsonCampaigns_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        UpdateRollupDetailsonCampaigns batch;
        batch = new UpdateRollupDetailsonCampaigns();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }