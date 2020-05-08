global class Exec_Briefing_Notification_Sch implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        Exec_Briefing_Notification batch;
        batch = new Exec_Briefing_Notification();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }