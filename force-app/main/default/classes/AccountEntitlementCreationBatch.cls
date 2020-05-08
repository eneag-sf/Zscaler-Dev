/*****************************************************************************************
Name: AccountEntitlementCreationBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Populate Entitlement on Account based on type and support level

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           03-Dec-2019      Initial Development
******************************************************************************************/

public class AccountEntitlementCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public String que = '';

    public AccountEntitlementCreationBatch(string q){
        que = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, Type, Support_Type__c from Account where (type = \'Prospect\' or type = \'Customer\') and Id not in (Select AccountId from Entitlement) ';
        return Database.getQueryLocator(que);
    }

    public void execute(Database.BatchableContext context, List<Account> acclst){
        try{
            Map<String, Id>  spmap = new Map<String, Id>();
            for(SlaProcess sp: [Select Id, Name from SlaProcess where IsActive =true]){
                spmap.put(sp.Name, sp.Id);
            }
            List<Entitlement> entlst = new List<Entitlement>();
            for(Account acc: acclst){
                Entitlement ent = new Entitlement(AccountId = acc.Id, StartDate=date.today());
                if(acc.type == 'Prospect'){
                    ent.Name = 'Premium Plus';
                }else{
                    if(acc.Support_Type__c == 'Premium Support'){
                        ent.Name = 'Premium';
                    }else if(acc.Support_Type__c == 'Premium Plus Support'){
                        ent.Name = 'Premium Plus';
                    }else{
                        ent.Name = 'Standard';
                    }
                }
                ent.SlaProcessId = !spmap.isEmpty() && ent.Name != null && spmap.containsKey(ent.Name) ? spmap.get(ent.Name) : spmap.containsKey('Standard') ? spmap.get('Standard') : null;
                entlst.add(ent);
            }
            TriggerUtility.SkipAccTriggerExecuted();
            Database.SaveResult[] srList = database.insert(entlst, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    String s = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if(srList.indexOf(sr) != -1 && !entlst.isEmpty() && entlst.size() > srList.indexOf(sr) && entlst[srList.indexOf(sr)] != null){
                            s = entlst[srList.indexOf(sr)].AccountId;
                        }
                        if(s!= ''){
                            errorlst.add(sr.getId() + ' - ' + err.getMessage() +' for the account ' + s);
                        }else{
                            errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        }
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
            mail1.setSubject('Entitlement Creation Batch Failure result');
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
            mail.setSubject('Entitlement Creation Batch Success result ');
            mail.setPlainTextBody('Entitlement Creation Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}