global class RollupEnrolledUsersBatch implements Database.Batchable<sObject>,Database.Stateful {

    global List<String> fieldnameList;
    Map< Id, Decimal> LMap = new Map< Id, Decimal>();
    Map< Id, Integer> countMap = new Map< Id, Integer>();
   
    global RollupEnrolledUsersBatch (List<String> fieldnameList) {
        this.fieldnameList = fieldnameList;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'Select Enrolled_Users__c, Zscaler_Cloud_ID__c FROM  ' +
            'Cloud_Usage__c Where Cloud_Usage_Type__c = \'ZPA\' AND ' +
            fieldnameList.get(0) + ' = true ORDER BY Zscaler_Cloud_ID__c'
        );
    }
    global void execute(Database.BatchableContext bc, List<Cloud_Usage__c> records){
        
        for (Cloud_Usage__c ar : records)  {
           
            LMap.put( ar.Zscaler_Cloud_Id__c , LMap.containsKey(ar.Zscaler_Cloud_Id__c) ? LMap.get(ar.Zscaler_Cloud_Id__c)  + ar.Enrolled_Users__c: ar.Enrolled_Users__c );
            if(countMap.containskey( ar.Zscaler_Cloud_Id__c))
                countMap.put( ar.Zscaler_Cloud_Id__c, countMap.get( ar.Zscaler_Cloud_Id__c) + 1);
            else
                countMap.put( ar.Zscaler_Cloud_Id__c,  1);
        }

    }    

    global void finish(Database.BatchableContext bc){

        List<Zscaler_Cloud_ID__c> clouds = new List<Zscaler_Cloud_ID__c>();
        String fieldname = 'ZPA_Enrolled_Users_L90D_Rollup__c';
        if(fieldnameList.get(0) == 'Last_31_Days__c')
            fieldname = 'ZPA_Enrolled_Users_L31D_Rollup__c';
        else if( fieldnameList.get(0) == 'Last_6_Months__c')
            fieldname = 'ZPA_Enrolled_Users_L6M_Rollup__c';
        else if( fieldnameList.get(0) == 'Last_90_Days__c')
            fieldname = 'ZPA_Enrolled_Users_L90D_Rollup__c';


        for (Id ar : LMap.keyset())  {
            Zscaler_Cloud_ID__c cloudIdRecord = new Zscaler_Cloud_ID__c(
                                                    Id = ar
                                                );
            cloudIdRecord.put( fieldname, LMap.get(ar) /countMap.get(ar));
            clouds.add( cloudIdRecord );
        }

        if(!clouds.isEmpty()) {
            update clouds;
        }

        LMap = new Map< Id, Decimal>();
        countMap = new Map< Id, Integer>();

        if(!fieldnameList.isEmpty()){
            fieldnameList.remove(0);

            if(!fieldnameList.isEmpty()) {
                RollupEnrolledUsersBatch b = new RollupEnrolledUsersBatch(fieldnameList);
                database.executebatch(b);
            } else {
                AccountRollUpEnrolledUserBatch b = new AccountRollUpEnrolledUserBatch();
                database.executebatch(b,50);
            }
        }
    }  
}