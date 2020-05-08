/*****************************************************************************************
Name: UpdateTerritoryonTasks
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to update Territory information on Tasks weekly

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           16-November-2018      Initial Development
2.0            Gurjinder Singh Mann 13-May-2019          Split the logic to execute the Tasks on the basis of IsRecurrence
******************************************************************************************/

public class UpdateTerritoryonTasks implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String q = '';
    DateTime startDate;
    DateTime endDate;
    String query='';
    public UpdateTerritoryonTasks(String stdt, String eddt,String taskquery){
        startDate = Datetime.valueOf(stdt);
        endDate = Datetime.valueOf(eddt);
        query=taskquery;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, WhoId, WhatId, AccountId, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Task where LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate';
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Task> tasklst){
        set<id> leadIdSet = new set<id>();
        set<id> accountIdSet = new set<id>();
        Map<Id, Lead> ldmap = new Map<Id, Lead>();
        Map<Id, Account> accmap = new Map<Id, Account>();
        for(task t : tasklst){
            if(t.WhoId != null){
                Schema.SObjectType token = t.WhoId.getSObjectType();
                String objName  = token.getDescribe().getName();
                if(objName == 'Lead'){
                    leadIdSet.add(t.WhoId);
                } 
            }       
            if(t.AccountId != null){
                accountIdSet.add(t.AccountId);
            }
        }
        
        if(!leadIdSet.isEmpty()){
            ldmap = new Map<Id, Lead>([Select Id, Territory_Type__c, Territory_Name__c, Territory__r.Area__c, Territory__r.Theater__c from Lead where Id in :leadIdSet]);
        }
        if(!accountIdSet.isEmpty()){
            accmap = new Map<Id, Account>([Select Id, Territory_Type__c, Sales_Territory__r.Name, Sales_Territory__r.Area__c,  Sales_Territory__r.Theater__c from Account where Id in :accountIdSet]);
        }
        for(task t : tasklst){
            if(t.AccountId != null && accmap.containsKey(t.AccountId) && accmap.get(t.AccountId) != null){
                t.Sales_Territory__c =  accmap.get(t.AccountId).Sales_Territory__r.Name;
                t.Territory_Area__c =  accmap.get(t.AccountId).Sales_Territory__r.Area__c;
                t.Territory_Geo__c =  accmap.get(t.AccountId).Sales_Territory__r.Theater__c;
                t.Territory_Type__c =  accmap.get(t.AccountId).Territory_Type__c;
            }else if(t.WhoId != null && ldmap.containsKey(t.WhoId) && ldmap.get(t.WhoId) != null){
                t.Sales_Territory__c =  ldmap.get(t.WhoId).Territory_Name__c;
                t.Territory_Area__c =  ldmap.get(t.WhoId).Territory__r.Area__c;
                t.Territory_Geo__c =  ldmap.get(t.WhoId).Territory__r.Theater__c;
                t.Territory_Type__c =  ldmap.get(t.WhoId).Territory_Type__c;
            }
        }
        Database.SaveResult[] srList = database.update(tasklst, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successlst.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(sr.getId() + ' - ' + err.getMessage());
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
            mail1.setSubject('Weekly Territory Update Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Weekly Territory Update Batch Success result ');
            mail.setPlainTextBody('Weekly Territory Update Batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}