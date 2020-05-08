/*
 * This Schedule job is used to schedule ZPA Cloud Usage which are in last 6 months
 * 
 */
public class ZPACloudUsageBatchSchedule implements Schedulable
{

    public void execute(SchedulableContext SC)
    {
        ZPACloudUsageSetToTrueBatch zpaBatch = new ZPACloudUsageSetToTrueBatch();
        Database.executeBatch(zpaBatch, 200);
    }
    
}