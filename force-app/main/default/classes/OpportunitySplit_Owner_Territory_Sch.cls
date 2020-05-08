global class OpportunitySplit_Owner_Territory_Sch implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        OpportunitySplit_Owner_Territory_Update batch;
        List<string> Stages = new List<string>();
        Stages.add(label.Stage_6_Closed_Won);
        Stages.add(label.Stage_7_Closed_Lost);
        //batch = new OpportunitySplit_Owner_Territory_Update('Select Id, SplitOwnerId, Owner_Sales_Territory__c from OpportunitySplit where Owner_Sales_Territory__c = null and Opportunity.CloseDate >= TODAY and Opportunity.StageName NOT IN (\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')');
        //batch = new OpportunitySplit_Owner_Territory_Update('Select Id, SplitOwnerId, Owner_Sales_Territory__c from OpportunitySplit where Owner_Sales_Territory__c = null and Opportunity.CloseDate >= TODAY and Opportunity.StageName NOT IN :Stages');
        batch = new OpportunitySplit_Owner_Territory_Update('Select Id, SplitOwnerId, Owner_Sales_Territory__c from OpportunitySplit where Owner_Sales_Territory__c = null and Opportunity.CloseDate >= TODAY and Opportunity.StageName NOT IN (\'' + label.Stage_6_Closed_Won + '\', \'' + label.Stage_7_Closed_Lost + '\')');
        Integer batchsize= integer.valueof(ZscalerCustomSetting__c.getInstance('OppSplit_Owner_territory_Update')!=null && ZscalerCustomSetting__c.getInstance('OppSplit_Owner_territory_Update').Value__c!=null ? ZscalerCustomSetting__c.getInstance('OppSplit_Owner_territory_Update').Value__c:'1');

        if(!Test.isRunningTest()){
            Database.executeBatch(batch,batchsize);
        }
     }
 }