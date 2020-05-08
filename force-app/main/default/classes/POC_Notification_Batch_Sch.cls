global class POC_Notification_Batch_Sch implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        POC_Notification_Batch batch;
        batch = new POC_Notification_Batch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }