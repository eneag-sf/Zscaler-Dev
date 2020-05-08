/*****************************************************************************************
Name: Exec_Briefing_Notification
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify Internal Attendees of EB session

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           25-Oct-2019      Initial Development
******************************************************************************************/

public class Exec_Briefing_Notification implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Name, Opportunity__r.Name, OwnerId, Customer__r.name, Business_Strategies__c, Champion__c, Competitive_Overview__c, Critical_Capabilities__c, Current_Quarter_Opportunity__c, Customer__c, Date_of_Meeting__c, Decision_Criteria__c, Decision_Process__c, Desired_Meeting_Outcome__c, Economic_Buyer__c, Event_Type__c, Identified_Pain__c, Internal_Attendees__c, Metrics__c, Opportunity__c, Opportunity_Quarter__c, Opportunity_Type__c, Products__c, Purpose_of_Meeting_and_Agenda__c, RSM_Name__c, Sales_Stage__c, SD_WAN_O365_and_AWS_Azure_Usage__c, Strategic_Initiatives__c, TCV__c, Why_Anything__c, Why_Now__c, Why_Zscaler__c from Executive_Briefing_Request__c where Date_of_Meeting__c = TOMORROW and Approval_Status__c = \'Approved\'';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<Executive_Briefing_Request__c> eblst){
        Executive_Briefing_Request__c eb = eblst[0];
        Set<Id> accIds= new Set<Id>();
        Set<Id> activeusers = new Set<Id>();
        
        String emailtempname = '';
        emailtempname = 'Executive Briefing Remainder';
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        List<string> emailIdList = new List<string>();
        List<string> ccList = new List<string>();
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        if(runningInASandbox()){
            emailIdList.clear();
            for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                emailIdList.add(s);
            }
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, eb.OwnerId, eb.Id);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
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
            
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, eb.OwnerId, eb.Id);
            list<Executive_Briefing_Internal_Attendees__c> ebialst = [Select Id, User__r.Email from Executive_Briefing_Internal_Attendees__c where Executive_Briefing_Request__c = :eb.Id];
            for(Executive_Briefing_Internal_Attendees__c ebia : ebialst){
                if(ebia.User__r.Email != null){
                    emailIdList.add(ebia.User__r.Email);
                }       
            }
            for(String s: Exec_Briefing_Notification_CC_List__c.getAll().keyset()){
                ccList.add(s);
            }
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            if(!emailIdList.isEmpty()){
                mail.setToAddresses(emailIdList);
            }
            
            if(!ccList.isEmpty()){
                mail.setCcAddresses(ccList);
            }
            mail.setsaveAsActivity(false);
            emailList.add(mail);
            
        }
        String sentemailsto = '';
        Integer countofmails = 0;
        try{
            
            for(String s: emailIdList){
                sentemailsto += s + ';';
            }
            for(String s: ccList){
                sentemailsto += s + ';';
            }
            
            countofmails += ccList.size();
            countofmails += emailIdList.size();
            
            if(canSendEmail(countofmails)){
                Messaging.sendEmail(emailList);
                
                Task actHistory = new Task(Subject='Executive Briefing Session Reminder Email sent on ' + Date.Today(), WhatId=eb.Id, Status='Completed', ActivityDate=Date.today(), Description='Executive Briefing Session Reminder Email sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = eb.OwnerId ,Priority='Normal', type='Other');
                actHistory.WhoId = null;
                insert actHistory;
                
                successlst.add(eb.Id);
            }
        }catch(Exception e){
            errorlst.add('Exception on Exec Briefing:' + eb.Id + '. Exception is ' + e);
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
            mail1.setSubject('Executive Briefing Session Reminder Batch Failure result');
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
            mail.setSubject('Executive Briefing Session Reminder Batch Success result ');
            mail.setPlainTextBody('Executive Briefing Session Reminder Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
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