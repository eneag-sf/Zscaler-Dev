/*****************************************************************************************
Name: POC_Notification_Batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify partners and customers on Provisioning Request POC alerts on a daily basis

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           10-June-2019      Initial Development
******************************************************************************************/

public class POC_Notification_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, OwnerId, Days_Left_After_Reminder_Initiation__c, Primary_Eval_Contact__r.Name, Tentative_Deprovision_Date__c, Account__r.Name, Email_Sent__c, Send_Reminder_Emails__c, SE__r.Id, Account__r.OwnerId, Account__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.OwnerId, Primary_Eval_Contact__c, POC_Alert_Recipient_1__c, POC_Alert_Recipient_1__r.Email, POC_Alert_Recipient_2__c, POC_Alert_Recipient_2__r.Email, POC_Alert_Recipient_3__c, POC_Alert_Recipient_3__r.Email, Account_Manager__r.Email, SE_Manager_Email__c, SE__r.Email, SE__c from Provisioning_Request__c where Next_Notification_Date__c = Today and Send_Reminder_Emails__c = true and Email_Sent__c != null ';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<Provisioning_Request__c> prlist){
        Provisioning_Request__c pr = prlist[0];
        Set<Id> accIds= new Set<Id>();
        Set<Id> activeusers = new Set<Id>();
        if(pr.SE__c != null){
            activeusers.add(pr.SE__c);
        }
        if(pr.POC_Alert_Recipient_1__c != null){
            activeusers.add(pr.POC_Alert_Recipient_1__c );
        }
        if(pr.POC_Alert_Recipient_2__c != null){
            activeusers.add(pr.POC_Alert_Recipient_2__c );
        }
        if(pr.POC_Alert_Recipient_3__c != null){
            activeusers.add(pr.POC_Alert_Recipient_3__c);
        }
        if(!activeusers.isEmpty()){
            for(User u: [Select Id from User where Id in :activeusers and isActive = false]){
                activeusers.remove(u.Id);
            }    
        }
        String emailtempname = '';
        emailtempname = 'Email Reminders on POC To Customer';
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        List<string> emailIdList = new List<string>();
        List<string> ccList = new List<string>();
        List<string> bccList = new List<string>();
        Set<string> partneremails = new Set<string>();
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        if(runningInASandbox()){
            emailIdList.clear();
            for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                emailIdList.add(s);
            }
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, pr.Primary_Eval_Contact__c, pr.Id);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pocdecommissionalert@zscaler.com'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setToAddresses(emailIdList);
            mail.setsaveAsActivity(false);
            emailList.add(mail);
        }else{
            emailIdList.clear();
            
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, pr.Primary_Eval_Contact__c, pr.Id);
            if(pr.Account__r.OwnerId != null){
                ccList.add(pr.Account__r.Owner.Email);
            }                
            if(pr.Opportunity__r.OwnerId != null){
                ccList.add(pr.Opportunity__r.Owner.Email);
            }              
            if(pr.SE__c != null && activeusers.contains(pr.SE__c)){
                ccList.add(pr.SE__r.Email);
            }  
            
            if(pr.POC_Alert_Recipient_1__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_1__c)){
                bccList.add(pr.POC_Alert_Recipient_1__r.Email);
            }
            if(pr.POC_Alert_Recipient_2__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_2__c)){
                bccList.add(pr.POC_Alert_Recipient_2__r.Email);
            }
            if(pr.POC_Alert_Recipient_3__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_3__c)){
                bccList.add(pr.POC_Alert_Recipient_3__r.Email);
            }
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pocdecommissionalert@zscaler.com'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            if(!ccList.isEmpty()){
                mail.setCcAddresses(ccList);
            }
            if(!bccList.isEmpty()){
                mail.setBccAddresses(bccList);
            }
            mail.setsaveAsActivity(false);
            emailList.add(mail);
        }
        String sentemailsto = '';
        Integer countofmails = 0;
        try{
            for(String s: ccList){
                sentemailsto += s + ';';
            }
            for(String s: bccList){
                sentemailsto += s + ';';
            }
            
            countofmails += ccList.size();
            countofmails += bccList.size();
            
            if(canSendEmail(countofmails)){
                Messaging.sendEmail(emailList);
                
                Task actHistory = new Task(Subject='POC Decommision Alerts Email sent on ' + Date.Today(), WhatId=pr.Id, Status='Completed', ActivityDate=Date.today(), Description='POC Decommision Alerts Email sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = pr.OwnerId ,Priority='Normal', type='Other');
                actHistory.WhoId = null;
                insert actHistory;
                
                successlst.add(pr.Id);
            }
        }catch(Exception e){
            errorlst.add('Exception on opp:' + pr.Id + '. Exception is ' + e);
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
            mail1.setSubject('POC PR Notification Batch Failure result');
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
            mail.setSubject('POC PR Notification Batch Success result ');
            mail.setPlainTextBody('POC PR Notification Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
         if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
         }
    }
    
    public static Boolean runningInASandbox() {
        //return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return false;
    }
    
    public static Boolean canSendEmail(Integer count) {
        Boolean canSend;
        
        try {
            Messaging.reserveSingleEmailCapacity(count);
            canSend = true;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            canSend = false;
        }
        
        return canSend;
    }
    
}