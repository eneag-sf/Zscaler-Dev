/***********************************************
Changes by              Date           Description
Gurjinder Singh Mann    13-May-2019    Changes done to execute the Events on the basis of IsRecurrence. 
************************************************/
global class UpdateTerritoryonEvents_Schedulable implements Schedulable
{
    global Date sd;
    global Date ed;
    
    global UpdateTerritoryonEvents_Schedulable(Date startdate, Date enddate)
    {
        sd = startdate;
        ed = enddate;
    }
    
    global void execute(SchedulableContext SC)
    {
        UpdateTerritoryonEvents batch;
        if(sd == null){
            sd = Date.Today().addDays(-6);
        }
        if(ed == null){
            ed = Date.Today();
        }
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        
        //Execute the batch for Non Recurring task with a batch size of 200 
        String NonRecurringEventBatchQuery='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from event where IsRecurrence=False and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\')';
        
        Integer NonRecurringEventBatchSize = integer.valueof(ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize')!=null && ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('NonRecurringEventBatchSize').Value__c:'200');
        
        batch = new UpdateTerritoryonEvents(startdate,enddate,NonRecurringEventBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,NonRecurringEventBatchSize);
        }
        
        //Execute the batch for Recurring task with a batch size of 1   
        String RecurringEventBatchQuery='Select Id,WhoId,WhatId,AccountId,Sales_Territory__c,Territory_Area__c,Territory_Geo__c,Territory_Type__c,IsRecurrence from event where IsRecurrence=True and LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate and Sales_Territory__c=null and Territory_Area__c=null and Territory_Geo__c=null and Territory_Type__c=null and (accountId != null or Who.Type = \'Lead\')';
        
        Integer RecurringEventBatchSize = integer.valueof(ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize')!=null && ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize').Value__c!=null ? ZscalerCustomSetting__c.getInstance('RecurringEventBatchSize').Value__c:'1');
        
        batch = new UpdateTerritoryonEvents(startdate,enddate,RecurringEventBatchQuery);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,RecurringEventBatchSize);
        }
     }
 }