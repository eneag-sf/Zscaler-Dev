global class OpportunitySnapshotBatch implements Database.Batchable<sObject>{
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<OpportunitySnapshotMapping__c> oppSnapMapList = OpportunitySnapshotMapping__c.getall().values();
        string queryString = 'Select CreatedDate ';
        for(OpportunitySnapshotMapping__c fieldApi : oppSnapMapList){
            queryString += ',' +  fieldApi.Opportunity_Field_API__c;
        }
        queryString += ' from Opportunity ';
        if(test.isRunningTest())
        queryString += ' limit 5';     
        return Database.getQueryLocator(queryString);
    }
      
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> oppList){
        // Field Mapping Values for Opportunity and Opportunity Snapshot
        list<OpportunitySnapshotMapping__c> oppSnapMapList = OpportunitySnapshotMapping__c.getall().values();
        list<Opportunity_Snapshot__c> oppSnapshotInsertList = new list<Opportunity_Snapshot__c>();
        
        for(Opportunity opp : (list<Opportunity>) oppList){
            Opportunity_Snapshot__c oppSnap = new Opportunity_Snapshot__c();
            oppSnap.put('Snapshot_Date__c', system.today());
            for(OpportunitySnapshotMapping__c fieldApi : oppSnapMapList){
                oppSnap.put(fieldApi.Sanpshot_Field_API__c, opp.get(fieldApi.Opportunity_Field_API__c));
            }
            if(oppSnap != null)
                oppSnapshotInsertList.add(oppSnap);
        }
        if(!oppSnapshotInsertList.isEmpty()){
            Database.insert(oppSnapshotInsertList,false);
        }
    }
     
    global void finish(Database.BatchableContext BC){
         //if(!Test.isRunningTest())
           // database.executeBatch(new CaptureUserOpportunityListBatch(), 1);
    }
}