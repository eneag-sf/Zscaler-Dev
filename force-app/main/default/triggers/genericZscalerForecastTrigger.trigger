trigger genericZscalerForecastTrigger on Zscaler_Forecast__c (before insert, before update) {
    for (Zscaler_Forecast__c entry : Trigger.new) {
        entry.Unique_Key__c = entry.User__c + ':' + entry.FYFQ__c + ':' + entry.YYWW__c + ':' + entry.Month__c + ':' + entry.Forecast_Type__c;
    }
}