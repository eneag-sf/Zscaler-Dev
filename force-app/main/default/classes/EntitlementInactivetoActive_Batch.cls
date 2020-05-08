/*****************************************************************************************
Name: EntitlementInactivetoActive_Batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Change Entitlement on Account entitlement

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           12-Dec-2019      Initial Development
******************************************************************************************/

public class EntitlementInactivetoActive_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public String que = '';
    public EntitlementInactivetoActive_Batch(string q){
        que = q;
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, SlaProcess.Name from Entitlement where SlaProcess.IsActive = false and Status = \'Active\' and AccountId != null';
        return Database.getQueryLocator(que);
    }

    public void execute(Database.BatchableContext context, List<Entitlement> entlst){
        try{
            Map<String, Id>  spmap = new Map<String, Id>();
            for(SlaProcess sp: [Select Id, Name from SlaProcess where IsActive =true]){
                spmap.put(sp.Name, sp.Id);
            }
            List<Entitlement> entlsttoinsert = new List<Entitlement>();
            for(Entitlement ent: entlst){
                Entitlement temp = new Entitlement(Id = ent.Id);
                temp.SlaProcessId = ent.SlaProcess.Name != null && spmap.containsKey(ent.SlaProcess.Name) ? spmap.get(ent.SlaProcess.Name) : spmap.containsKey('Standard') ? spmap.get('Standard') : null;
                entlsttoinsert.add(temp);
            }
            TriggerUtility.SkipAccTriggerExecuted();
            Database.SaveResult[] srList = database.update(entlsttoinsert, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    String s = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorlst.add(sr.getId() + ' - ' + err.getMessage());
                    }
                }
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
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
            mail1.setSubject('Entitlement Inactive to Active Entitlement Version change Batch Failure result');
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
            mail.setSubject('Entitlement Inactive to Active Entitlement Version change Success result ');
            mail.setPlainTextBody('Entitlement Inactive to Active Entitlement Version change Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}