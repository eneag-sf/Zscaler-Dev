global class CleanupAppliedRuleInfoBatch implements Database.Batchable<sObject>{

    Boolean isPrimaryData = true;
    Boolean isClosed = true;
    global CleanupAppliedRuleInfoBatch(Boolean isPrimary, Boolean isClosed)
    {
        isPrimary = isPrimary;
        isClosed = isClosed;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String str = 'SELECT Id FROM Apttus_Config2__ProductConfiguration__c '+
                                        'where Apttus_QPConfig__Proposald__r.Apttus_Proposal__Primary__c <> '+isPrimaryData+
                                        ' and Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.isClosed='+isClosed;
        return Database.getQueryLocator(str);
        //and Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.isWon=false
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        Database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}