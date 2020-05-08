global class CaptureUserZscalerForecastSchedule implements Schedulable
{
    global Integer level;
    
    global CaptureUserZscalerForecastSchedule()
    {
      this(null);
    }
    
    global CaptureUserZscalerForecastSchedule(Integer l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        CaptureUserZscalerForecast batch = new CaptureUserZscalerForecast(level, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
    }
}