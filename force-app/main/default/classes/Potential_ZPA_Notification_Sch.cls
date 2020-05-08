global class Potential_ZPA_Notification_Sch implements Schedulable
{
    global Potential_ZPA_Notification_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Potential_ZPA_Notification batch;
        batch = new Potential_ZPA_Notification();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }