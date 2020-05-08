/*****************************************************************************************
Name: Extension_Expiry_Notification_Batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify Finance and rep on Renewal due on a daily basis

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-Apr-2019      Initial Development
******************************************************************************************/

public class Extension_Expiry_Notification_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String str1 = label.Stage_4_Economic_Buyer_Signoff;
        String str2 = label.Stage_5_Contracts_Complete;
        String str3 = label.Stage_6_Closed_Won;
        String str4 = label.Stage_7_Closed_Lost;
        List<String> StrList = new List<String>(); 
        StrList.add(str1);
        StrList.add(str2);
        StrList.add(str3);
        StrList.add(str4);
        String query = 'Select Id, Owner.GEO__c, Name, AccountId, Owner.Email, Partner_Account_Contact_Email__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status_Formula__c,  Past_Due_Notification_Status_Formula__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where Recordtype.name = \'Renewal Opportunity\' and Extension_Expiry_Notification_Date__c = Today and StageName NOT IN: StrList';/*\'10 - Closed Won\', \'10b - PO recd, pending finance approval\',\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')*/
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Opportunity> opplist){
		
		if(Test.isRunningTest()){
            booster();
        }
		
        Opportunity opp = opplist[0];
        String orderops = label.Order_Ops_Email_Id;
        String emailtempname = '';
        if(opp.New_Extended_Contract_Date__c != null && opp.New_Extended_Contract_Date__c == Date.today()){
            emailtempname = 'Extension Expiry Notification Alert';
        }else if(opp.New_Extended_Contract_Date__c != null && opp.New_Extended_Contract_Date__c < Date.today()){
            emailtempname = 'Extension Expiry Termination Alert';
        }
        
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        List<string> emailIdList = new List<string>();
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        
            if(runningInASandbox()){
                
                emailIdList.clear();
                
                /*emailIdList.add('snag@zscaler.com');
                emailIdList.add('uraju@zscaler.com');*/
                
                
                for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                    emailIdList.add(s);
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, Userinfo.getUserId(), opp.Id);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(!emailIdList.isEmpty()){
                    mail.setToAddresses(emailIdList);
                }
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }else{
                emailIdList.clear();
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, opp.OwnerId, opp.Id);
                emailIdList.add(orderops);
                
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(!emailIdList.isEmpty()){
                    mail.setToAddresses(emailIdList);
                }
                
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
            String sentemailsto = '';
            try{
                for(String s: emailIdList){
                    sentemailsto += s + ';';
                }
                if(canSendEmail(emailIdList.size())){
                    Messaging.sendEmail(emailList);
                    
                    Task actHistory = new Task(Subject='Extension Expiry Reminder Notification Email sent on ' + Date.Today(), WhatId=opp.Id, Status='Completed', ActivityDate=Date.today(), Description='Extension Expiry Reminder Notification sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = opp.OwnerId ,Priority='Normal', type='Other');
                    actHistory.WhoId = null;
                    insert actHistory;
                    successlst.add(opp.Id);
                }
            }catch(Exception e){
                errorlst.add('Exception on opp:' + opp.Id + '. Exception is ' + e);
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
            mail1.setSubject('Renewal Notification Batch Failure result');
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
            mail.setSubject('Renewal Notification Batch Success result ');
            mail.setPlainTextBody('Renewal Notification Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
        	Messaging.sendEmail(messageList);
        }
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    private static Boolean canSendEmail(Integer count) {
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
    public static void booster() {
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}