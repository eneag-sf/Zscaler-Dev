/*****************************************************************************************
Name: Value_Summary_Attachment_Deletion
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Delete all attachments in Value  Summary Dummmy Quote

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           17-April-2019      Initial Development
******************************************************************************************/

public class Value_Summary_Attachment_Deletion implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String quoteId = Label.DummyQuote_ValueSummary;
        String query = 'Select Id from Attachment where ParentId =:quoteId ';
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Attachment> attlst){
        if(!attlst.isEmpty()){
            Database.DeleteResult[] drList = Database.delete(attlst, false);

            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(''+dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        errorlst.add(dr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext context){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Value Summary Attachment Deletion Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Value Summary Attachment Deletion Batch Success result ');
            mail.setPlainTextBody('Value Summary Attachment Deletion Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}