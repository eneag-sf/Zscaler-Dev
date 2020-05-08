global class CaptureWeeklyForecastBatchSchedule implements Schedulable
{
    global Integer level;
    global boolean execute1;
    global boolean execute7;
    global boolean execute14;
    
    global CaptureWeeklyForecastBatchSchedule(Integer l, Boolean e1, Boolean e7, Boolean e14)
    {
        this.level = l;
        execute1 = e1;
        execute7 = e7;
        execute14 = e14;
    }
    
    global void execute(SchedulableContext SC)
    {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureWeeklyForecastBatch batch;
        if(execute1){
            nextWeekStartDay = Date.today().adddays(1);
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(Date.today().adddays(1));
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(level, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            if(!Test.isRunningTest()){
                Database.executeBatch(batch,1);
            }
        }
        if(execute7){
            nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(Date.today());
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(level, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            if(!Test.isRunningTest()){
                Database.executeBatch(batch,1);
            }
        }
        if(execute14){
            nextWeekStartDay = Date.today().addDays(14).toStartOfWeek();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(Date.today());
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(level, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            if(!Test.isRunningTest()){
                Database.executeBatch(batch,1);
            }
        }
    }
}