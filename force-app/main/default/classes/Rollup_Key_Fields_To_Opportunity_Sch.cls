global class Rollup_Key_Fields_To_Opportunity_Sch implements Schedulable
{
    global Rollup_Key_Fields_To_Opportunity_Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        //String Stage1 = label.Stage_7_Closed_Lost;
        //String Stage2 = label.Stage_6_Closed_Won;
        //List<String> StageList = new List<String>(); 
        //StageList.add(Stage1);
        //StageList.add(Stage2);
        
        
        Rollup_Key_Fields_To_Opportunity batch;
        //batch = new Rollup_Key_Fields_To_Opportunity('Select Id, F2F_SCI_s_in_the_last_12_Months__c, F2F_SCI_s_in_the_last_6_Months__c,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity where Id in (Select Opportunity_Name__c from Significant_Customer_Interaction__c where Recordtype.name not in (\'CAB\'))  and StageName NOT IN (\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')');
        //batch = new Rollup_Key_Fields_To_Opportunity('Select Id, F2F_SCI_s_in_the_last_12_Months__c, F2F_SCI_s_in_the_last_6_Months__c,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity where Id in (Select Opportunity_Name__c from Significant_Customer_Interaction__c where Recordtype.name not in (\'CAB\'))  and StageName NOT IN (\'' + label.Stage_7_Closed_Lost + '\', \'' + label.Stage_6_Closed_Won + '\')');
        
        batch = new Rollup_Key_Fields_To_Opportunity('Select Id, F2F_SCI_s_in_the_last_12_Months__c, F2F_SCI_s_in_the_last_6_Months__c,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity where Id in (Select Opportunity_Name__c from Significant_Customer_Interaction__c where Recordtype.name not in (\'CAB\'))  and StageName NOT IN (\'' + label.Stage_7_Closed_Lost + '\', \'' + label.Stage_6_Closed_Won + '\')');
        
        Integer batchsize= integer.valueof(ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size')!=null && ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SCI_Rollup_Opp_Batch_Size').Value__c:'1');

        if(!Test.isRunningTest()){
            Database.executeBatch(batch,batchsize);
        }
     }
 }