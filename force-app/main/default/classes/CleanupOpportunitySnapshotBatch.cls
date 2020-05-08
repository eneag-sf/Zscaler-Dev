global class CleanupOpportunitySnapshotBatch implements Database.Batchable<sObject>, Database.Stateful {

    String query;
    Boolean isValid;

    global CleanupOpportunitySnapshotBatch(String FiscalQuarterString) {
        ForecastingDataModel.FiscalQuarterInfo fq, currentFq;
        isValid = false;

        // Determine the created date
        if (FiscalQuarterString != null) {
            fq = new ForecastingDataModel.FiscalQuarterInfo(FiscalQuarterString);
            currentFq = new ForecastingDataModel.FiscalQuarterInfo();
            System.debug('>>>> fq.startDate: ' + fq.startDate);
            System.debug('>>>> currentFq.startDate: ' + currentFq.startDate);
            System.debug('>>>> fq.startDate.daysBetween(currentFq.startDate): ' + fq.startDate.daysBetween(currentFq.startDate));
            if (fq.startDate.daysBetween(currentFq.startDate) < 544) {
                throw new CleanupOpportunitySnapshotBatchException('Cannot delete data less than 6 quarters old.');
            }

            Datetime createdDate = Datetime.newInstance(fq.startDate.year(), fq.startDate.month(), fq.startDate.day(), 0, 0, 0);

            query = 'SELECT Id, CreatedDate FROM Opportunity_Snapshot__c WHERE CreatedDate < ' + createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            isValid = true;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (isValid) {
            return Database.getQueryLocator(query);
        } else {
            return null;
        }
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            System.debug(JSON.serialize(scope));
            Database.delete(scope, false);
        } catch (Exception ex) {
            System.debug('>>>> Deletion of Opportunity Snapshots failed. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('>>>> Deletion of Opportunity Snapshots complete.');
    }

    public class CleanupOpportunitySnapshotBatchException extends Exception { }
}