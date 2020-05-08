/*****************************************************************************************
Name: Potential_ZPA_Notification
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify users on Potential_ZPA_Notification

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           5-Mar-2019      Initial Development
******************************************************************************************/

public class Potential_ZPA_Notification implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id from User where Id in (Select OwnerId from Account where type = \'Customer\' and Do_not_tag_as_Propensity_to_Buy_ZPA__c = false) ';
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<User> uslst){
        Id userId = uslst[0].Id;
        Boolean proceed = false;
        String Stage1 = label.Stage_7_Closed_Lost;
        String Stage2 = label.Stage_6_Closed_Won;
        
        List<String> StageList = new List<String>(); 
        StageList.add(Stage1);
        StageList.add(Stage2);
        //Map<Id, Account> accmap = new Map<Id, Account>([Select Id, Name,No_of_Platform_Seats__c, CSM_Name_New__r.Name, Sales_Territory__r.Field_Marketing__r.email from Account where (Users_ZPA_Platform__c = 0 or Users_ZPA_Platform__c = null) and Id not in (Select AccountId from Opportunity where Recordtype.Name in ('Renewal Opportunity','Upsell Opportunity') and Stagename not in ('11 - Closed Lost', '12 - Closed With No Decision', '13 - Closed & Approved By Finance', '14 - Closed: Delete Duplicate') and Total_ZPA_ACV__c > 0 and Account.OwnerId = :userId) and ownerId = :userId and type = 'Customer' and Do_not_tag_as_Propensity_to_Buy_ZPA__c = false]);
        Map<Id, Account> accmap = new Map<Id, Account>([Select Id, Name,No_of_Platform_Seats__c, CSM_Name_New__r.Name, Sales_Territory__r.Field_Marketing__r.email from Account where (Users_ZPA_Platform__c = 0 or Users_ZPA_Platform__c = null) and Id not in (Select AccountId from Opportunity where Recordtype.Name in ('Renewal Opportunity','Upsell Opportunity') and Stagename not IN:StageList and Total_ZPA_ACV__c > 0 and Account.OwnerId = :userId) and ownerId = :userId and type = 'Customer' and Do_not_tag_as_Propensity_to_Buy_ZPA__c = false]);
        
        
        Set<Id> accIdsforoldermonth = new Set<Id>();
        if(!accmap.isEmpty()){
            accIdsforoldermonth.addAll(accmap.keyset());
        }
        Map<Id, Decimal> mapacctoTotalDevices = new Map<Id, Decimal>();
        Date startdate = date.today().addmonths(-1).toStartOfMonth();
        Date enddate = date.today().toStartOfMonth().adddays(-1);
        List<string> emailIdList = new List<string>();
        
        for(AggregateResult aggr : [select Cloud_ID__r.Account__c accId, sum(Total_registered_Devices__c) a from BWC_Data__c where Z_App_ZIA_Enabled__c = 'Enabled' and Cloud_ID__r.Account__r.OwnerId = :userId and Monthly_Usage__c >= :startdate and Monthly_Usage__c <= :enddate and Cloud_ID__r.Account__c in :accIdsforoldermonth group by Cloud_ID__r.Account__c]){
            if((Decimal)aggr.get('a') != null && (Decimal)aggr.get('a') != 0){
                accIdsforoldermonth.remove((Id)aggr.get('accId'));
                mapacctoTotalDevices.put((Id)aggr.get('accId'), (Decimal)aggr.get('a'));
            }
        }
        system.debug(accIdsforoldermonth);
        startdate = date.today().addmonths(-2).toStartOfMonth();
        enddate = date.today().addmonths(-1).toStartOfMonth().adddays(-1);
        
        for(AggregateResult aggr : [select Cloud_ID__r.Account__c accId, sum(Total_registered_Devices__c) a from BWC_Data__c where Z_App_ZIA_Enabled__c = 'Enabled' and Cloud_ID__r.Account__c = :accIdsforoldermonth and Monthly_Usage__c >= :startdate and Monthly_Usage__c <= :enddate group by Cloud_ID__r.Account__c]){
            if((Decimal)aggr.get('a') != null && (Decimal)aggr.get('a') != 0){
                mapacctoTotalDevices.put((Id)aggr.get('accId'), (Decimal)aggr.get('a'));
            }
        }
        system.debug(mapacctoTotalDevices);
        if(!mapacctoTotalDevices.isEmpty()){
            for(Id accId: mapacctoTotalDevices.keyset()){
                if(mapacctoTotalDevices.get(accId) != null && accmap.get(accId) != null && accmap.get(accId).No_of_Platform_Seats__c != null && accmap.get(accId).No_of_Platform_Seats__c != 0 && (((mapacctoTotalDevices.get(accId) / 2) / accmap.get(accId).No_of_Platform_Seats__c) * 100 > 10)){
                    proceed = true;
                    if(accmap!= null && accmap.containsKey(accId) && accmap.get(accId) != null && accmap.get(accId).Sales_Territory__r.Field_Marketing__r.email != null){
                        if(!emailIdList.contains(accmap.get(accId).Sales_Territory__r.Field_Marketing__r.email)){
                            emailIdList.add(accmap.get(accId).Sales_Territory__r.Field_Marketing__r.email);
                        }
                    }
                }
            }
        }
        
        if(proceed || test.isrunningtest()){
            
            EmailTemplate et = [Select Id,Name from EmailTemplate where Name = 'Potential ZPA Notification Template'];
            list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, userId, null);
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            for(String s: Potential_ZPA_Notification_CC_List__c.getAll().keyset()){
                emailIdList.add(s);
            }
            mail.setCcAddresses(emailIdList);
            mail.setsaveAsActivity(false);
            emailList.add(mail);
            try{
                Messaging.sendEmail(emailList);
                successlst.add(userId);
            }catch(Exception e){
                errorlst.add('Exception for user:' + userId + '. Exception is ' + e);
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
            mail1.setSubject('Potential ZPA Notification Batch Failure result');
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
            mail.setSubject('Potential ZPA Notification Batch Success result ');
            mail.setPlainTextBody('Potential ZPA Notification Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}