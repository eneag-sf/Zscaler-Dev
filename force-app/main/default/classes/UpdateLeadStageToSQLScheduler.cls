global class UpdateLeadStageToSQLScheduler implements Schedulable {
    global UpdateLeadStageToSQLScheduler() {}

    global void execute(SchedulableContext sc) {
        Datetime endDate = Datetime.now();
        Datetime startDate = endDate.addDays(-1);

        UpdateLeadStageToSQLBatch b = new UpdateLeadStageToSQLBatch(startDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''), endDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        Database.executebatch(b, 200);
    }
}