global class oppChurnOwnerEmailSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new OpportunitywithoutchurnRecBatch(), 1);
    }
}