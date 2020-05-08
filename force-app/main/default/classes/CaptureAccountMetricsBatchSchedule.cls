/*****************************************************************************************
Name: CaptureAccountMetricsBatchSchedule
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Scheduler for CaptureAccountMetricsBatch Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Oct-2015    Initial Development
******************************************************************************************/ 

global class CaptureAccountMetricsBatchSchedule implements Schedulable{
    global void execute(SchedulableContext ctx){
        string batchSize = ZscalerSetting__c.getValues('AccountMetricsBatchSize').Value__c;
        CaptureAccountMetricsBatch currentBatchJob = new CaptureAccountMetricsBatch();
        Database.executeBatch(currentBatchJob, integer.valueOf(batchSize));
    }
}