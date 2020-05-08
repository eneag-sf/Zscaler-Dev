@isTest
private class CleanupOpportunitySnapshotBatchTest {

    @isTest static void testBatch() {
        Opportunity_Snapshot__c testRecord = new Opportunity_Snapshot__c();
        insert testRecord;

        Test.startTest();
        ForecastingDataModel.FiscalQuarterInfo fq = new ForecastingDataModel.FiscalQuarterInfo();
        CleanupOpportunitySnapshotBatch b = new CleanupOpportunitySnapshotBatch('2015Q1');
        Database.executeBatch(b);
        Test.stopTest();
    }

    @isTest static void testBatchError() {
        Opportunity_Snapshot__c testRecord = new Opportunity_Snapshot__c();
        insert testRecord;

        Test.startTest();
        try {
            ForecastingDataModel.FiscalQuarterInfo fq = new ForecastingDataModel.FiscalQuarterInfo();
            CleanupOpportunitySnapshotBatch b = new CleanupOpportunitySnapshotBatch(fq.FormattedString);
            Database.executeBatch(b);

            CleanupOpportunitySnapshotBatch b1 = new CleanupOpportunitySnapshotBatch(null);
            Database.executeBatch(b1);
        } catch(Exception ex) {}
        Test.stopTest();
    }
}