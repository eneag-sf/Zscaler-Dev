global class RollupEnrolledUsersBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        RollupEnrolledUsersBatch b = new RollupEnrolledUsersBatch(new List<String>{ 'Last_31_Days__c', 'Last_6_Months__c', 'Last_90_Days__c'});
        database.executebatch(b);
    }
}