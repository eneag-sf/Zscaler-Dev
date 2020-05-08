/***********************************************
Created by              Date           Description
Gurjinder Singh Mann    06-Nov-2019    TO Create or Update SCI from Events. 
************************************************/
global class Event2SCIAutocreationBatchSchedulable implements Schedulable
{
      
    global void execute(SchedulableContext SC)
    {
        Event2SCIAutocreationBatch batch;
        
        batch = new Event2SCIAutocreationBatch();
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,10);
        }
        
    }
 }