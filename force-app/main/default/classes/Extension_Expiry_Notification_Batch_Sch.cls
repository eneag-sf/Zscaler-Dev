global class Extension_Expiry_Notification_Batch_Sch implements Schedulable
{
    global Extension_Expiry_Notification_Batch_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Extension_Expiry_Notification_Batch batch;
        batch = new Extension_Expiry_Notification_Batch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }