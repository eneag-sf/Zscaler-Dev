global class BatchSendSignedLegalQuestionnaireEmails implements Database.Batchable<sObject>  {
    
    public string accountIdToProcess = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        if(!test.isRunningTest()){
            query = 'SELECT Id,Signed_Legal_Questionaire_Date__c,Type,BillingCountry,PartnerContractReviewer__c FROM Account WHERE Signed_Legal_Questionaire_Date__c = THIS_YEAR and Type = \'Partner\' and PartnerContractReviewer__c != null';
        }
        else{
            query = 'SELECT Id,Signed_Legal_Questionaire_Date__c,Type,BillingCountry,PartnerContractReviewer__c FROM Account WHERE Signed_Legal_Questionaire_Date__c != null and Type = \'Partner\' and PartnerContractReviewer__c != null';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> scope){
        List<Account> AccountList = (list<Account>) scope;
        List<Account> AccountsTobeUpdated = new list<Account>();
        Set<Integer> remainderDays = new Set<Integer>{0, 37, 48};
        Set<Integer> statusChangeDate = new Set<Integer>{51};
        try{
            for(Account Acc : AccountList){
                
                String templateName = '';
                boolean isEMACountry = false;
                if(Acc.BillingCountry != null){
                    List<String> emaCountries = Label.EMEA_Countries.split(','); 
                    if(emaCountries.contains(Acc.BillingCountry)){
                        isEMACountry = true;
                    }
                }
                
                Integer noofDays = Acc.Signed_Legal_Questionaire_Date__c.daysBetween(System.today());
                
                if(!isEMACountry){
                    if(noofDays == 0){
                        templateName = 'Anti_Corruption_Questionnaire_Template_Non_EMEA';
                    }
                    else if(noofDays == 37){
                        templateName = 'X1st_Reminder_Anti_Bribery_Questionnaire_Non_EMEA';
                    }
                    else if(noofDays == 48){
                        templateName = 'Final_Reminder_Anti_Corruption_Compliance_Questionnaire_Non_EMEA';
                    }
                }
                else{
                    if(noofDays == 0){
                        templateName = 'Anti_Bribery_Questionnaire_Template';
                    }
                    else if(noofDays == 37){
                        templateName = 'X1st_Reminder_Anti_Bribery_Questionnaire_EMEA';
                    }
                    else if(noofDays == 48){
                        templateName = 'Final_Reminder_Anti_Corruption_Compliance_Questionnaire_EMEA';
                    }
                }
                
                
                if(remainderDays.contains(noofDays)){
                    //Write the code
                    List<String> sendTo = new List<String>();
                    if(runningInASandbox()){
                        sendTo.add('snag@zscaler.com');
                        sendTo.add('uraju@zscaler.com');
                        sendTo.add('smittal@zscaler.com');
                    }
                    Contact cnt = [select id, Email from Contact where Id = :Acc.PartnerContractReviewer__c limit 1];
                    List<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    EmailTemplate emailTemplate = [select Id, HTMLValue, DeveloperName, Subject from EmailTemplate where DeveloperName =: templateName];
                    msg.setTemplateId(emailTemplate.Id);
                    msg.setWhatId(Acc.Id);
                    msg.setTargetObjectId(cnt.id);
                    msg.setToAddresses(sendTo);
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'z-legal-noreply@zscaler.com'];
                    //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    if(noofDays == 37 || noofDays == 48){
                        String[] ccAddresses = new String[] {Acc.OwnerId};
                        msg.setCcAddresses(ccAddresses);
                    }
                    
                    if (owea.size() > 0 ) {
                        msg.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    if(runningInASandbox()){
                        msg.setReplyTo('z-legal-noreply@zscaler.com.sandbox');
                    }
                    else{
                        msg.setReplyTo('z-legal-noreply@zscaler.com');
                    }
                    msgList.add(msg);
                    // Send the emails in a transaction, then roll it back
                    //Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(msgList);
                    /*Database.rollback(sp); // Email will not send as it is rolled Back
                    // Send Actual email
                    List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : msgList) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSubject(email.getSubject());
                        msgListToBeSend.add(emailToSend);
                    }
                    Messaging.sendEmail(msgListToBeSend);*/
                    
                    //Task ta = new Task();
                    //ta.Subject = noofDays + ' Days Legal Questionaire Date Email Remainder Sent on ' + System.today().month() + '/' + System.today().day() + '/' + System.today().year();
                    //ta.Status = 'Completed';
                    //ta.Priority = 'Normal';
                    //ta.Description = 'Email Sent Successfully';
                    //ta.whatId = Acc.Id;
                    //insert ta;
                    
                }else if(statusChangeDate.contains(noofDays)){
                    Acc.Type = 'Ex - Partner';
                    AccountsTobeUpdated.Add(Acc);
                }
            }
            
            if(AccountsTobeUpdated.size()>0){
                try{
                    update AccountsTobeUpdated;
                    Task ta = new Task();
                    ta.Subject = 'Updated to Ex - Partner on ' + System.today().month() + '/' + System.today().day() + '/' + System.today().year();
                    ta.Status = 'Completed';
                    ta.Priority = 'Normal';
                    ta.whatId = AccountsTobeUpdated[0].Id;
                    ta.Description = 'Updated to Ex - Partner';
                    insert ta;
                }
                catch(Exception exp){
                    Task ta = new Task();
                    ta.Subject = 'Failed to Update as Ex - Partner. Please take the necessary action';
                    ta.Status = 'In Progress';
                    ta.Priority = 'High';
                    ta.whatId = AccountsTobeUpdated[0].Id;
                    ta.Description = exp.getMessage();
                    insert ta;
                }
            }
            
        }catch(Exception exp){
            System.debug('The following exception has occurred: ' + exp.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc){
    
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

}