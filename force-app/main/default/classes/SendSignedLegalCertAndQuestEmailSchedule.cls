global class SendSignedLegalCertAndQuestEmailSchedule implements Schedulable {
    
    global SendSignedLegalCertAndQuestEmailSchedule(){ 
        
    }
    global void execute(SchedulableContext ctx) {
        //Database.executeBatch(new BatchSendSignedLegalCertificationEmails(), 1);
        Database.executeBatch(new BatchSendSignedLegalQuestionnaireEmails(), 1);
    }
}