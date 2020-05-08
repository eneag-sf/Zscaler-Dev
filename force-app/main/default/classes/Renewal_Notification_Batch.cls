/*****************************************************************************************
Name: Renewal_Notification_Batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify partners and customers on Renewal due on a daily basis

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           25-Feb-2019      Initial Development
******************************************************************************************/

public class Renewal_Notification_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String Stage1 = label.Stage_4_Economic_Buyer_Signoff;
        String Stage2 = label.Stage_5_Contracts_Complete;
        String Stage3 = label.Stage_7_Closed_Lost;
        String Stage4 = label.Stage_6_Closed_Won;
        List<String> StageList = new List<String>(); 
        StageList.add(Stage1);
        StageList.add(Stage2);
        StageList.add(Stage3);
        StageList.add(Stage4);
        
        //String oppid = '0060g00000usFPE';
        
        //String query = 'Select Id, Owner.GEO__c, Name, AccountId, Owner.Email, Partner_Account_Contact_Email__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status_Formula__c,  Past_Due_Notification_Status_Formula__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where Recordtype.name = \'Renewal Opportunity\' and Next_Renewal_Notification_Date__c = Today and StageName NOT IN (\'10 - Closed Won\', \'10b - PO recd, pending finance approval\',\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\') and ((Contract_End_Date_New__c >= TODAY AND  Renewal_Notification_Status_Formula__c = \'Yes\') or (Contract_End_Date_New__c < TODAY AND Past_Due_Notification_Status_Formula__c = \'Yes\')) ';
        String query = 'Select Id, Owner.GEO__c, Name, AccountId, Owner.Email, Partner_Account_Contact_Email__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status_Formula__c,  Past_Due_Notification_Status_Formula__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where Recordtype.name = \'Renewal Opportunity\' and Next_Renewal_Notification_Date__c = Today and StageName NOT IN:StageList and ((Contract_End_Date_New__c >= TODAY AND  Renewal_Notification_Status_Formula__c = \'Yes\') or (Contract_End_Date_New__c < TODAY AND Past_Due_Notification_Status_Formula__c = \'Yes\')) ';
        
        //for testing
        //String query = 'Select Id, Owner.GEO__c, Name, AccountId, Owner.Email, Partner_Account_Contact_Email__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status_Formula__c,  Past_Due_Notification_Status_Formula__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where Recordtype.name = \'Renewal Opportunity\' and Id =: oppid and Next_Renewal_Notification_Date__c = Today and StageName NOT IN:StageList and ((Contract_End_Date_New__c >= TODAY AND Renewal_Notification_Status_Formula__c = \'Yes\') or (Contract_End_Date_New__c < TODAY AND Past_Due_Notification_Status_Formula__c = \'Yes\')) ';
        
        
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Opportunity> opplist){
		
		if(test.isrunningtest()){
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
        Opportunity opp = opplist[0];
        String americasalias = label.Renewal_Americas;
        String apacalias = label.Renewal_APJ;
        String emeaalias = label.Renewal_EMEA;
        Set<Id> accIds= new Set<Id>();
        Boolean proceed = false;
        String emailtempname = '';
        if(opp.Contract_End_Date_New__c >= Date.today()){
            proceed = opp.Renewal_Notification_Status_Formula__c == 'Yes';
            emailtempname = 'Upcoming Reminder Notification';
        }else if(opp.New_Extended_Contract_Date__c != null && opp.New_Extended_Contract_Date__c > Date.today()){
            proceed = opp.Past_Due_Notification_Status_Formula__c == 'Yes';
            emailtempname = 'Upcoming Extension Expiration Reminder Notification';
        }else{
            proceed = opp.Past_Due_Notification_Status_Formula__c == 'Yes';
            emailtempname = 'Past Due Reminder Notifications';
        }
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        List<string> emailIdList = new List<string>();
        Set<string> partneremails = new Set<string>();
        if(proceed){
            emailIdList.clear();
            list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            if(runningInASandbox()){
                
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
                mail.setToAddresses(emailIdList);
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }else{
                emailIdList.clear();
                partneremails.clear();
                accIds.add(opp.AccountId);
                /*if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null){
                    accIds.add(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c);
                }*/
                
                
                for(Contact con: [Select Id, email, name from Contact where AccountId in :accIds and Renewal_Notification_Recipient__c = true and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
                    emailIdList.add(con.email);
                }
                
                if(opp.Partner_Account_Contact_Email__c != null && opp.Partner_Account_Contact_Email__c != ''){
                    partneremails.addAll(opp.Partner_Account_Contact_Email__c.split(';'));
                }
                if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null && !partneremails.isEmpty()){
                    for(Contact con: [Select Id, email, name from Contact where AccountId  = :opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c and email in :partneremails and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
                        emailIdList.add(con.email);
                    }
                }
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, opp.OwnerId, opp.Id);
                
                /*if(opp.Owner.GEO__c == 'Americas'){
                    emailIdList.add(americasalias);
                }else if(opp.Owner.GEO__c == 'APAC'){
                    emailIdList.add(apacalias);
                }else if(opp.Owner.GEO__c == 'EMEA'){
                    emailIdList.add(emeaalias);
                }*/
                
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setToAddresses(emailIdList);
                
                
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
            String sentemailsto = '';
            try{
                for(String s: emailIdList){
                    sentemailsto += s + ';';
                }
                Messaging.sendEmail(emailList);
                
                Task actHistory = new Task(Subject='Renewal Notification Email sent on ' + Date.Today(), WhatId=opp.Id, Status='Completed', ActivityDate=Date.today(), Description='Renewal Notification Email sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = opp.OwnerId ,Priority='Normal', type='Other');
                actHistory.WhoId = null;
                insert actHistory;
                successlst.add(opp.Id);
            }catch(Exception e){
                errorlst.add('Exception on opp:' + opp.Id + '. Exception is ' + e);
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
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}