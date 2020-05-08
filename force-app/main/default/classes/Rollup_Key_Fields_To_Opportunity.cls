/*****************************************************************************************
Name: SCI Rollup info onto Opportunity
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. SCI Rollup info onto Opportunity

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           07-June-2019      Initial Development
******************************************************************************************/

public class Rollup_Key_Fields_To_Opportunity implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public string query = '';
    public Rollup_Key_Fields_To_Opportunity(String q){
        query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, F2F_SCI_s_in_the_last_12_Months__c, F2F_SCI_s_in_the_last_6_Months__c,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity where Id in (Select Opportunity_Name__c from Significant_Customer_Interaction__c where Recordtype.name not in (\'CAB\')) ';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<Opportunity> opplst){
        Set<Id> oppIdSet = new set<Id>();
        map<Id, decimal> scislast6months = new map<Id, Decimal>();
        map<Id, decimal> scislast12months = new map<Id, Decimal>();
        map<Id, decimal> allscis = new map<Id, Decimal>();
        map<Id, decimal> f2flast6months = new map<Id, Decimal>();
        map<Id, decimal> f2flast12months = new map<Id, Decimal>();
        map<Id, decimal> allf2fs = new map<Id, Decimal>();
        list<Opportunity> oppUpdateList = new list<Opportunity>();
        for(sObject opp : opplst ){
            oppIdSet.add((Id)opp.get('Id'));
        }
        
        for(Significant_Customer_Interaction__c sci: [Select Id,CreatedDate, Method_of_Interaction__c, Account_Name__c, Account_Name__r.Id, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name, RecordType.DeveloperName from Significant_Customer_Interaction__c where (Opportunity_Name__c IN: oppIdSet) and Recordtype.name not in ('CAB')]){
            if(sci.Opportunity_Name__c != null && allscis.containsKey(sci.Opportunity_Name__c)){
                allscis.put(sci.Opportunity_Name__c, allscis.get(sci.Opportunity_Name__c) + 1);
            }else{
                allscis.put(sci.Opportunity_Name__c, 1);
            }
            if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-6)){
                if(sci.Opportunity_Name__c != null && scislast6months.containsKey(sci.Opportunity_Name__c)){
                    scislast6months.put(sci.Opportunity_Name__c, scislast6months.get(sci.Opportunity_Name__c) + 1);
                }else{
                    scislast6months.put(sci.Opportunity_Name__c, 1);
                }
            }
            if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-12)){
                if(sci.Opportunity_Name__c != null && scislast12months.containsKey(sci.Opportunity_Name__c)){
                    scislast12months.put(sci.Opportunity_Name__c, scislast12months.get(sci.Opportunity_Name__c) + 1);
                }else{
                    scislast12months.put(sci.Opportunity_Name__c, 1);
                }
            }
            
            if(sci.Method_of_Interaction__c == 'F2F' && sci.Recordtype.name != 'Marketing/CXO Event'){
                if(sci.Opportunity_Name__c != null && allf2fs.containsKey(sci.Opportunity_Name__c)){
                    allf2fs.put(sci.Opportunity_Name__c, allf2fs.get(sci.Opportunity_Name__c) + 1);
                }else{
                    allf2fs.put(sci.Opportunity_Name__c, 1);
                }
                if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-6)){
                    if(sci.Opportunity_Name__c != null && f2flast6months.containsKey(sci.Opportunity_Name__c)){
                        f2flast6months.put(sci.Opportunity_Name__c, f2flast6months.get(sci.Opportunity_Name__c) + 1);
                    }else{
                        f2flast6months.put(sci.Opportunity_Name__c, 1);
                    }
                }
                if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-12)){
                    if(sci.Opportunity_Name__c != null && f2flast12months.containsKey(sci.Opportunity_Name__c)){
                        f2flast12months.put(sci.Opportunity_Name__c, f2flast12months.get(sci.Opportunity_Name__c) + 1);
                    }else{
                        f2flast12months.put(sci.Opportunity_Name__c, 1);
                    }
                }
            }
            
        }
        
        for(id oppId: oppIdSet){
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            
            if(scislast6months.containsKey(oppId)){
                opp.SCI_s_in_the_last_6_Months__c = scislast6months.get(oppId);
            }
            if(scislast12months.containsKey(oppId)){
                opp.SCI_s_in_the_last_12_Months__c  = scislast12months.get(oppId);
            }
            if(allscis.containsKey(oppId)){
                opp.All_time_of_SCI__c = allscis.get(oppId);
            }
            if(f2flast6months.containsKey(oppId)){
                opp.F2F_SCI_s_in_the_last_6_Months__c = f2flast6months.get(oppId);
            }
            if(f2flast12months.containsKey(oppId)){
                opp.F2F_SCI_s_in_the_last_12_Months__c = f2flast12months.get(oppId);
            }
            if(allf2fs.containsKey(oppId)){
                opp.All_time_F2F_of_SCI__c = allf2fs.get(oppId);
            }
            oppUpdateList.add(opp);
        }
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        TriggerUtility.OpptyTriggerFCexecuted();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.oppPRProductionStatusUpdateExecuted();
        TriggerUtility.opportunityAccountsScreeningExecuted();
        TriggerUtility.OpportunityPartnerAdditionExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.updateOppNextStepHistoryExecuted();
        TriggerUtility.updateTechValHistoryExecuted();
        TriggerUtility.architectureHistoryExecuted();
        TriggerUtility.ERNotificationExecuted();
        TriggerUtility.updateSEManagerEmailExecuted();
        TriggerUtility.updateAccountForApprovedPZENExecuted();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.overrideACVValuesResetExecuted();
        TriggerUtility.SkipAccTriggerExecuted();
        
        Database.SaveResult[] srList = database.update(oppUpdateList, false);
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
            mail1.setSubject('Opportunity SCI fields Rollup Failure result');
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
            mail.setSubject('Opportunity SCI fields Rollup Success result ');
            mail.setPlainTextBody('Opportunity SCI fields Rollup has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}