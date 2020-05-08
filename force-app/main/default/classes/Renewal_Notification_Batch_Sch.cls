global class Renewal_Notification_Batch_Sch implements Schedulable
{
    global Renewal_Notification_Batch_Sch ()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Renewal_Notification_Batch batch;
        batch = new Renewal_Notification_Batch ();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }