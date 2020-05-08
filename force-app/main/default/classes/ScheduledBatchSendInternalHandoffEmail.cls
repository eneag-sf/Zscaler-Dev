global class ScheduledBatchSendInternalHandoffEmail implements Schedulable {

   global void execute(SchedulableContext ctx) {
      BatchSendInternalHandoffEmail batchCls = new BatchSendInternalHandoffEmail();
        database.executeBatch(batchCls,10);
   }   
}