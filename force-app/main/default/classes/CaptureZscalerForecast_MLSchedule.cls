global class CaptureZscalerForecast_MLSchedule implements Schedulable
{
    global Integer level;
    
    global CaptureZscalerForecast_MLSchedule ()
    {
      this(null);
    }
    
    global CaptureZscalerForecast_MLSchedule (Integer l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        Date nextWeekStartDay = Date.today().toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        CaptureExistingZscalerForecast_MLRollup batch = new CaptureExistingZscalerForecast_MLRollup(level, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
    }
}