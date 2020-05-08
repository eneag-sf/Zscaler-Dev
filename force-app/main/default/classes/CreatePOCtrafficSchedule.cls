global class CreatePOCtrafficSchedule implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        CreatePOCtrafficBatch currentBatchJob = new CreatePOCtrafficBatch();
        Database.executeBatch(currentBatchJob, 1);
    }
}