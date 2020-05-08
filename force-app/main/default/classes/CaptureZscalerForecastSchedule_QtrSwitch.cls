global class CaptureZscalerForecastSchedule_QtrSwitch implements Schedulable
{
    global Integer level;
    
    global CaptureZscalerForecastSchedule_QtrSwitch()
    {
      this(null);
    }
    
    global CaptureZscalerForecastSchedule_QtrSwitch(Integer l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        Date nextWeekStartDay = Date.today().addDays(1);
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        CaptureUserZscalerForecast batch = new CaptureUserZscalerForecast(level, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
    }
}