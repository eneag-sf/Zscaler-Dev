/*****************************************************************************************
Name: Ramped Users Batch on Account
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

public class Account_Ramped_Users_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Number_of_Ramped_Users__c from Account where Type = \'Customer\' ';
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Account> acclst){
        Account acc = acclst[0];
        Set<String> setSKUCodes = new Set<String> {
                                        APTS_CONSTANTS.PROD_SKU_SIP,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                                    };
        
        /*,APTS_CONSTANTS.PROD_SKU_ZPROSUITE,APTS_CONSTANTS.PROD_SKU_ZBUSINESSSUITE,
         APTS_CONSTANTS.PROD_SKU_ZENTSUITE*/
        try{
            Date today = date.today();
            List<AggregateResult> totalusers = [SELECT SUM(Quantity__c) a FROM Contract_Detail__c WHERE (Contract_Detail_Status__c = 'Active' OR Contract_Detail_Status__c = 'Renewed') and Start_Date__c <= :today and End_Date__c >= :today and Product_SKU__c in :setSKUCodes and Account_Name__c = :acc.Id];
            acc.Number_of_Ramped_Users__c = totalusers[0].get('a') == null ? 0 : (Decimal)totalusers[0].get('a');
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();
            update acc;
            successlst.add(acc.Id);
        }catch(Exception e){
            errorlst.add('Exception on acc:' + acc.Id + '. Exception is ' + e);
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
            mail1.setSubject('Ramped Users Batch Failure result');
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
            mail.setSubject('Ramped Users Batch Success result ');
            mail.setPlainTextBody('Ramped Users Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}