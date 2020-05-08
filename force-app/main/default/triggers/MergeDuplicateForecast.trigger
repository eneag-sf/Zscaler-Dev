/*
 * If forecast with same unique key existed, merge them and delete the new.
 */
trigger MergeDuplicateForecast on CustomForecast__c (after insert, after update)
{
    Zscaler_Admin_Settings__c settings = Zscaler_Admin_Settings__c.getInstance(UserInfo.getUserId());

    if (settings != null && settings.Is_Data_Migration_User__c != true) {
        Map<String, CustomForecast__c> newFCs = new Map<String, CustomForecast__c>();
        Map<String, CustomForecast__c> existingFCs = new Map<String, CustomForecast__c>();

        List<CustomForecast__c> toLose = new List<CustomForecast__c>();
        List<CustomForecast__c> toMerge = new List<CustomForecast__c>();

        for(CustomForecast__c f : Trigger.new)
        {
            if(newFCs.containsKey(f.UniqueKeyV2__c))
            {
                toLose.add(new CustomForecast__c(Id=f.Id));
            }
            else
            {
                newFCs.put(f.UniqueKeyV2__c, f);
            }
        }

        for(CustomForecast__c f : [select Id, UniqueKeyV2__c from CustomForecast__c where UniqueKeyV2__c in :newFCs.keyset() and Id not in :Trigger.new])
        {
            existingFCs.put(f.UniqueKeyV2__c, f);
        }

        for(CustomForecast__c f : Trigger.new)
        {
            if(existingFCs.containsKey(f.UniqueKeyV2__c))
            {
                toLose.add(new CustomForecast__c(Id=f.Id));
                CustomForecast__c existing = existingFCs.get(f.UniqueKeyV2__c);
                mergeForecast(f, existing);
                toMerge.add(existing);
            }
        }


        if(toLose.size() > 0)
        {
            delete toLose;
        }
        if(toMerge.size() > 0)
        {
            update toMerge;
        }
    }

    private void mergeForecast(CustomForecast__c source, CustomForecast__c dest)
    {
        dest.MonthCommit__c = source.MonthCommit__c;
        dest.QuarterCommit__c = source.QuarterCommit__c;
        dest.QuarterPipeline__c = source.QuarterPipeline__c;
        dest.QuarterUpside__c = source.QuarterUpside__c;
        dest.WeekCommit__c = source.WeekCommit__c;
        dest.LastEdited__c = DateTime.now();
        dest.Locked__c = source.Locked__c;
        dest.SubmittedOn__c = source.SubmittedOn__c;
        dest.Forecast_Family__c = source.Forecast_Family__c;
    }

}