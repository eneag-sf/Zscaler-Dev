/*
 * Sets unique key = FYFQ + YYWW + ForecastType + UserID
 * Sets Unique Key V2 = FYFQ + YYWW + ForecastType + UserID + ForecastFamily
 */
trigger PopulateUniqueKey on CustomForecast__c (before insert, before update)
{
    for(CustomForecast__c f : Trigger.new)
    {
        f.UniqueKey__c = f.FYFQ__c + ':' + f.YYWW__c + ':' + f.ForecastType__c + ':' + f.User__c;
        f.UniqueKeyV2__c = f.FYFQ__c + ':' + f.YYWW__c + ':' + f.ForecastType__c + ':' + f.User__c + ':' + f.Forecast_Family__c;
    }
}