global class opportunityShareEngineStarter{
    
    private static Set<Id> globalPipeline = new Set<Id>();
    private List<Id> currentPipeline = new List<Id>();
    
    global opportunityShareEngineStarter(List<Id> RecordIds){
        Set<Id> newdedup = new Set<Id>(RecordIds);
        currentPipeline.addAll(newdedup);
    }
    
    global void start(){
        globalPipeline.addAll(currentPipeline);
        if(currentPipeline.size() <= 2){
            assignPatch(currentPipeline);
        }
        else{
            InnerJob job = new InnerJob(currentPipeline);
            System.enqueueJob(job);
        }
    }
    
    private void assignPatch(List<Id> recordIds){
        if(recordIds == null || recordIds.size() == 0){
            return;
        }
        
        List<Opportunity_Share__c> oppShareRecords = [Select Id,
                                                                        Opportunity_Id__c,
                                                                        Status__c
                                                                        from
                                                                        Opportunity_Share__c
                                                                        Where ID IN: recordIds];
                                                                        
        quoteAndProposalShareUtil.shareQuoteAndProdConfigWithOppTeamMembers(oppShareRecords);
    }
    
    public class InnerJob implements Queueable{
        private List<Id> currentBatch;
        private List<Id> pipeline;
        
        public InnerJob(List<Id> records){
            if(records != null){
                if(records.size() <= 2){
                    currentBatch = new List<Id>(records);
                    pipeline = null;
                }
                else{
                    currentBatch = new List<Id>();
                    pipeline = new List<Id>();
                    for(Integer i = 0; i < records.size(); i++){
                        if(i < 2){
                            currentBatch.add(records[i]);
                        }
                        else{
                            pipeline.add(records[i]);
                        }
                    }
                }
            }
        }
        
        public void execute(QueueableContext context) {
            if(currentBatch != null){
                opportunityShareEngineStarter starter = new opportunityShareEngineStarter(currentBatch);
                starter.assignPatch(currentBatch);
            }
            if(pipeline != null && !Test.isRunningtest()){
                System.enqueueJob(new InnerJob(pipeline)); 
            }
        }
    }
}