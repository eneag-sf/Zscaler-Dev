global class Rollup_Key_Fields_To_Account_Sch implements Schedulable
{
    global Rollup_Key_Fields_To_Account_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Rollup_Key_Fields_To_Account batch;
        batch = new Rollup_Key_Fields_To_Account();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }