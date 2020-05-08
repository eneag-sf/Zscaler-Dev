global class CaptureMonthlyForecastBatchSchedule implements Schedulable
{
    global Integer level;
    
    global CaptureMonthlyForecastBatchSchedule(Integer l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureMonthlyForecastBatch batch;
        currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(Date.today());
        nextWeek = new ZForecastingDataModel.WeekInfo(Date.today());
        batch = new CaptureMonthlyForecastBatch(level, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
        if(!Test.isRunningTest() && Date.today().tostartofmonth().daysbetween(date.today().adddays(1)) >= 4 && Date.today().tostartofmonth().daysbetween(date.today().adddays(1)) <= 14){
            Database.executeBatch(batch,1);
        }
        
    }
}