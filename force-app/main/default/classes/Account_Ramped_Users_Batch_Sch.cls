global class Account_Ramped_Users_Batch_Sch implements Schedulable
{
    global Account_Ramped_Users_Batch_Sch ()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Account_Ramped_Users_Batch batch;
        batch = new Account_Ramped_Users_Batch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }