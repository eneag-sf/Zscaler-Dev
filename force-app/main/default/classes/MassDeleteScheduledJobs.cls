Global class MassDeleteScheduledJobs implements Database.Batchable<sObject> {
// query all the scheduled jobs from the system
String query = 'select Id from CronTrigger';
global Database.QueryLocator start(Database.BatchableContext BC){
    /** Return all the scheduled jobs for processing  **/
    return Database.getQueryLocator(query);
}
global void execute(Database.BatchableContext BC, List<CronTrigger> scope){
    If (scope.size() > 0){
    For (Integer i = 0; i < scope.size(); i++){ 
            System.abortJob(scope[i].Id); 
            }
        }
}
global void finish(Database.BatchableContext BC){

}
}