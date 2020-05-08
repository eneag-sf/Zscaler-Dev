global class OpportunitySnapshotBatchSchedule implements Schedulable{
    global void execute(SchedulableContext ctx){
        OpportunitySnapshotBatch currentBatchJob = new OpportunitySnapshotBatch();
        Database.executeBatch(currentBatchJob, 200);
    }
}