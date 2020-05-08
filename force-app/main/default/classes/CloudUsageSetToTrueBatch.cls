/*****************************************************************************************
Name: CloudUsageSetToTrueBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to update cloud Usage to true if it is within 6 months.

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            16-Nov-2016    Initial Development
******************************************************************************************/


global class CloudUsageSetToTrueBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([Select Id, Last_6_Months__c, Usage_Pull_Date__c, Last_31_Days__c, Last_90_Days__c from Cloud_Usage__c WHERE Usage_Pull_Date__c != null AND Usage_Pull_Date__c = LAST_N_DAYS:180 AND Last_31_Days__c = false] );
    }
    global void execute (Database.BatchableContext context, List<sObject> cloudUsageList){
        list<Cloud_Usage__c> cloudUsageUpdateList = new list<Cloud_Usage__c>();
        for(Cloud_Usage__c cloudUsage : (list<Cloud_Usage__c>)cloudUsageList){
            Cloud_Usage__c tempCloudUsage = new Cloud_Usage__c();
            tempCloudUsage = cloudUsage;
            tempCloudUsage.Last_6_Months__c = true;
            if(tempCloudUsage.Usage_Pull_Date__c.addDays(30) >= system.today()){
                tempCloudUsage.Last_31_Days__c = true;
            }
            if(tempCloudUsage.Usage_Pull_Date__c.addDays(90) >= system.today()){
                tempCloudUsage.Last_90_Days__c = true;
            }
            cloudUsageUpdateList.add(tempCloudUsage);

        }
        database.update(cloudUsageUpdateList, false);
    }
    global void finish(Database.BatchableContext context){
        database.executeBatch(new CloudUsageSetToFalseBatch(), 200);
    }

}