trigger SetCurrentStageOnPR on POC_Phase__c (after update,after insert,after delete){
    If ( Trigger.Isupdate || Trigger.Isinsert ){
          POCTriggerClass myTriggerClass = new POCTriggerClass();
          myTriggerClass.setCurrentStageOnPR(Trigger.new);
          
    }  
    If ( Trigger.IsDelete ){     
          POCTriggerClass myTriggerClass = new POCTriggerClass();
          myTriggerClass.setCurrentStageOnPR(trigger.old);
          
    } 
}