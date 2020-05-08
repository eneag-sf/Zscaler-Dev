global class CaptureUserForecastSnapshotSchedule implements Schedulable
{
    
    global void execute(SchedulableContext SC)
    {
        CaptureUserForecastSnapshot batch = new CaptureUserForecastSnapshot('Select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from User Where isActive = true and ForecastEnabled__c=true');
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
    }
}