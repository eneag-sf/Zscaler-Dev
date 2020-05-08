/**
 * Batch job to create next week's CustomForecast.
 */
global class ForecastSubmissionBatch implements Database.Batchable<sObject>
{
    global final Integer level;
    global final String qtr;
    global final String week;

    global ForecastSubmissionBatch(Integer l, String q, String w)
    {
        level = l;
        qtr = q;
        week = w;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select Id from User where IsActive=true and ( ForecastEnabled__c=true or ZPAForecastEnabled__c =true)';
        if(level != null)
        {
            query += ' and ForecastLevel__c=\'Level '+level+'\'';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        List<CustomForecast__c> existingForecasts = [select Id, User__c, User__r.IsActive, User__r.ForecastEnabled__c,User__r.ZPAForecastEnabled__c, ForecastType__c,Forecast_Family__c , QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, YYWW__c, FYFQ__c from CustomForecast__c where User__c in :scope and YYWW__c != null and Locked__c = false];
        List<CustomForecast__c> existingFutureForecasts = [select Id, User__c, User__r.IsActive, User__r.ForecastEnabled__c,User__r.ZPAForecastEnabled__c, ForecastType__c,Forecast_Family__c, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, YYWW__c, FYFQ__c from CustomForecast__c where User__c in :scope and FYFQ__c = :qtr and YYWW__c = null and Locked__c = false];
        List<CustomForecast__c> newForecasts = new List<CustomForecast__c>();
        system.debug('Unlocked Forecasts ::'+existingForecasts);
        system.debug('Existing Future Forecasts ::'+existingFutureForecasts);
        for(CustomForecast__c existingFuture : existingFutureForecasts)
        {
            existingFuture.YYWW__c = week;
            newForecasts.add(existingFuture);
        }

        for(CustomForecast__c existing : existingForecasts)
        {
            if(existing.FYFQ__c == qtr && existing.YYWW__c == week)
            {
                continue;
            }
            existing.SubmittedOn__c = DateTime.now();
            existing.Locked__c = true;
            system.debug('Existing Record ::'+existing);
            if(existing.User__r.IsActive && existing.User__r.ForecastEnabled__c && existing.Forecast_Family__c =='ZIA')
            {
                System.debug('Inside ZIA Block');
                Boolean foundFuture = false;
                for(CustomForecast__c existingFuture : existingFutureForecasts)
                {
                    if(existingFuture.User__c == existing.User__c && existingFuture.ForecastType__c == existing.ForecastType__c && existingFuture.Forecast_Family__c == existing.Forecast_Family__c)
                    {
                        foundFuture = true;
                        System.debug('Found Future ZIA');
                        continue;
                    }
                }
                if(!foundFuture)
                {
                    CustomForecast__c newFc = existing.clone(false, false, false, false);
                    newFc.Locked__c = false;
                    newFc.FYFQ__c = qtr;
                    newFc.YYWW__c = week;
                    newFc.SubmittedOn__c = null;
                    newFc.Forecast_Family__c ='ZIA';
                    newFc.LastEdited__c = DateTime.now();
                    System.debug('Creating ZIA ::'+newFc);
                    newForecasts.add(newFc);
                }
            }
            if(existing.User__r.IsActive && existing.User__r.ZPAForecastEnabled__c && existing.Forecast_Family__c =='ZPA')
            {
                Boolean foundFuture = false;
                System.debug('Inside ZPA Block');
                for(CustomForecast__c existingFuture : existingFutureForecasts)
                {
                    if(existingFuture.User__c == existing.User__c && existingFuture.ForecastType__c == existing.ForecastType__c && existingFuture.Forecast_Family__c == existing.Forecast_Family__c)
                    {
                        foundFuture = true;
                        System.debug('Found Future ZPA');
                        continue;
                    }
                }
                if(!foundFuture)
                {
                    CustomForecast__c newFc = existing.clone(false, false, false, false);
                    newFc.Locked__c = false;
                    newFc.FYFQ__c = qtr;
                    newFc.YYWW__c = week;
                    newFc.SubmittedOn__c = null;
                    newFc.Forecast_Family__c ='ZPA';
                    newFc.LastEdited__c = DateTime.now();
                    System.debug('Creating ZPA ::'+newFc);
                    newForecasts.add(newFc);
                }
            }
        }
        try
        {
            update existingForecasts;
            upsert newForecasts;
        }
        catch(DMLException ex)
        {
            throw new ForecastingException('Failed to submit forecast. ' + ex.getMessage());
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        submitInactiveUsers();
    }

    private void submitInactiveUsers()
    {
        List<CustomForecast__c> fs = new List<CustomForecast__c>();
        for(CustomForecast__c f : [select Id from CustomForecast__c where (User__r.IsActive=false or User__r.ForecastEnabled__c=false) and Forecast_Family__c = 'ZIA' and Locked__c=false])
        {
            f.Locked__c = true;
            fs.add(f);
        }

        for(CustomForecast__c f : [select Id from CustomForecast__c where (User__r.IsActive=false or User__r.ZPAForecastEnabled__c=false) and Forecast_Family__c = 'ZPA' and Locked__c=false])
        {
            f.Locked__c = true;
            fs.add(f);
        }
        update fs;
    }
}