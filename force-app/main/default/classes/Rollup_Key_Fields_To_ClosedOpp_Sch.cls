global class Rollup_Key_Fields_To_ClosedOpp_Sch implements Schedulable
{
    global Rollup_Key_Fields_To_ClosedOpp_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Rollup_Key_Fields_To_Opportunity batch;
        String Stage1 = label.Stage_7_Closed_Lost;
        String Stage2 = label.Stage_6_Closed_Won;
        List<String> StageList = new List<String>(); 
        StageList.add(Stage1);
        StageList.add(Stage2);
        
        String oppId = '0060g00000vlEWm';
        //batch = new Rollup_Key_Fields_To_Opportunity('Select Id from Opportunity where (StageName IN (\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\') and Id in (select OpportunityId from OpportunityFieldHistory where field = \'Stagename\' and Createddate = YESTERDAY))');
        
        batch = new Rollup_Key_Fields_To_Opportunity('Select Id from Opportunity where (StageName IN (\'' + label.Stage_7_Closed_Lost +'\', \'' + label.Stage_6_Closed_Won + '\') and Id in (select OpportunityId from OpportunityFieldHistory where field = \'Stagename\' and Createddate = YESTERDAY))');
        
        //batch = new Rollup_Key_Fields_To_Opportunity('Select Id from Opportunity where StageName IN (\'' + label.Stage_7_Closed_Lost +'\', \'' + label.Stage_6_Closed_Won + '\') and Id = \'0060g00000vlEWm\'');
        
        Integer batchsize= integer.valueof(ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size')!=null && ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size').Value__c:'1');

        if(!Test.isRunningTest()){
            Database.executeBatch(batch,batchsize);
        }
     }
 }