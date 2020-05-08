public class oppTeamQuoteAndProdConfigShareBatch implements Database.Batchable<SObject>,Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext context) {
        String  shareStatus = 'Ready To Share';
        return Database.getQueryLocator('Select Id, Opportunity_Id__c, Status__c from Opportunity_Share__c Where Status__c =: shareStatus');
    }
    
    public void execute(Database.BatchableContext context, Opportunity_Share__c[] oppShareRecords) {
        //quoteAndProposalShareUtil.runSharingForQuoteAndProposal(oppTeamRecords);
        /**List<Opportunity_Share__c> oppShareRecords = [Select Id,
                                                                        Opportunity_Id__c,
                                                                        Status__c
                                                                        from
                                                                        Opportunity_Share__c
                                                                        Where ID IN: recordIds];**/
                                                                        
        quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(oppShareRecords);
    }
    
    public void finish(Database.BatchableContext context) {
        List<Opportunity_Share__c> openSharings = [Select Id from Opportunity_Share__c where Status__c = 'Ready To Share' LIMIT 1];
        if(!openSharings.isEmpty()){
            Database.executeBatch(new oppTeamQuoteAndProdConfigShareBatch(), 10);
        }
    }
}