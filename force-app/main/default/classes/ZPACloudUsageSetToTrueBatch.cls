global class ZPACloudUsageSetToTrueBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([Select Id, Last_6_Months__c, ZPA_End_Date__c, Last_31_Days__c, Last_90_Days__c from Cloud_Usage__c WHERE Cloud_Usage_Type__c = 'ZPA' AND ZPA_End_Date__c != null AND ZPA_End_Date__c = LAST_N_DAYS:180 AND Last_31_Days__c = false] );
    }
    global void execute (Database.BatchableContext context, List<sObject> cloudUsageList){
        list<Cloud_Usage__c> cloudUsageUpdateList = new list<Cloud_Usage__c>();
        for(Cloud_Usage__c cloudUsage : (list<Cloud_Usage__c>)cloudUsageList){
            Cloud_Usage__c tempCloudUsage = new Cloud_Usage__c();
            tempCloudUsage = cloudUsage;
            tempCloudUsage.Last_6_Months__c = true;
            if(tempCloudUsage.ZPA_End_Date__c.addDays(30) >= system.today()){
                tempCloudUsage.Last_31_Days__c = true;
            }
            if(tempCloudUsage.ZPA_End_Date__c.addDays(90) >= system.today()){
                tempCloudUsage.Last_90_Days__c = true;
            }
            cloudUsageUpdateList.add(tempCloudUsage);

        }
        database.update(cloudUsageUpdateList, false);
    }
    global void finish(Database.BatchableContext context){
        database.executeBatch(new ZPACloudUsageSetToFalseBatch(), 200);
    }

}