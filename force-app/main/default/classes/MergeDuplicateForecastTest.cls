@isTest
public class MergeDuplicateForecastTest
{
    @isTest
    static void test()
    {
        CustomForecast__c f1 = new CustomForecast__c(User__c=UserInfo.getUserId(), FYFQ__c='2016Q1', YYWW__c='201601', ForecastType__c='New', QuarterCommit__c=1000);
        insert f1;
        
        CustomForecast__c f2 = new CustomForecast__c(User__c=UserInfo.getUserId(), FYFQ__c='2016Q1', YYWW__c='201601', ForecastType__c='New', QuarterCommit__c=2000);
        insert f2;
        
        f1 = [select Id, QuarterCommit__c from CustomForecast__c where Id=:f1.Id limit 1];
        System.assertEquals(2000, f1.QuarterCommit__c);
        
        
    }
}