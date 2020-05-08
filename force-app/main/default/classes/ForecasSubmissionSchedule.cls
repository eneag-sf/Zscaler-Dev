/**
 * This scheduled is supposed to execute at a given date every week to snapshot forecast for users with specified forecast level.
 */
global class ForecasSubmissionSchedule implements Schedulable
{
    global Integer level;
    
    global ForecasSubmissionSchedule()
    {
    	this(null);
    }
    
    global ForecasSubmissionSchedule(Integer l)
    {
        this.level = l;
    }
    
    global void execute(SchedulableContext SC)
    {
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        ForecastSubmissionBatch batch = new ForecastSubmissionBatch(level, currentQuarter.FormattedString, nextWeek.FormattedString);
        Database.executeBatch(batch);
    }
}