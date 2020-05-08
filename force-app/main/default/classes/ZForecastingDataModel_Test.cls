@isTest
private class ZForecastingDataModel_Test
{
    @isTest
    static void testZForecastingDataModel()
    {
        User currentUser = [SELECT Id, Name, LocaleSidKey, View_Notra__c, View_Billings__c, View_Export_to_Excel__c, View_Net_New_ACV_Summary__c, Department, UserRoleId, UserRole.Name, ForecastEnabled__c, ViewForecastAs__c, ViewForecastAs__r.Name, Show_As_Manager_In_ZPA_Forecasting__c, DefaultForecastFamily__c, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, Forecast_Inline_Editing__c, Level__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ZForecastingDataModel.UserInfo usr = new ZForecastingDataModel.UserInfo(currentUser);
        System.debug(usr.ViewForecastAs);
        System.debug(usr.ViewZPAForecastAs);

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo();
        qtr = new ZForecastingDataModel.FiscalQuarterInfo(Date.Today());
        qtr = new ZForecastingDataModel.FiscalQuarterInfo('2015Q1');
        System.assertEquals('2015Q1', qtr.FormattedString);
        System.assertEquals('2015Q2', qtr.Next.FormattedString);
        System.assertEquals('2014Q4', qtr.Previous.FormattedString);
        System.assertNotEquals(null, qtr.JsonWeeks);
        System.debug(qtr.getWeek(Date.today()));

        ZForecastingDataModel.WeekInfo week = new ZForecastingDataModel.WeekInfo();
        Date d = Date.newInstance(2015, 1, 1);
        week = new ZForecastingDataModel.WeekInfo(d);
        System.assertEquals('201452', week.FormattedString);

        ZForecastingDataModel.FiscalYearInfo year = new ZForecastingDataModel.FiscalYearInfo(2017);
        year.StartDate = Date.newInstance(2017, 01, 01);
        year.EndDate = Date.newInstance(2017, 12, 31);
        System.assertEquals(2018, year.Next.Year);
        System.assertEquals(2016, year.Previous.Year);
        System.debug(qtr.Month1);
        System.debug(qtr.Month3);
        
        Date d1 = Date.newInstance(2016, 1, 1);
        Date d2 = Date.newInstance(2015, 1, 1);
        week = new ZForecastingDataModel.WeekInfo(d1,d2);
    }
}