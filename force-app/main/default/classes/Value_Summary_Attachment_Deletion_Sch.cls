global class Value_Summary_Attachment_Deletion_Sch implements Schedulable
{
    global Value_Summary_Attachment_Deletion_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Value_Summary_Attachment_Deletion batch;
        batch = new Value_Summary_Attachment_Deletion();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,200);
        }
     }
 }