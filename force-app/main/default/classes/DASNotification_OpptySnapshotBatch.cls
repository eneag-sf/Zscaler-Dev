/*****************************************************************************************
Name: DASNotification_OpporutunitySnapshotBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to send out DAS notification of Opportunities modified on a daily basis

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           26-November-2018     Initial Development
******************************************************************************************/

public class DASNotification_OpptySnapshotBatch implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    DateTime startDate;
    DateTime endDate;
    String OpportunityChanges;
    string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
    
    public static final string emailStart = '<html><body>';
    public static final string emailEnd = '</body></html>';
    public static final string tableStart = '<table  width=\"100%\" style=\"border: 1px solid black;border-collapse: collapse;\" >';
    public static final string SummTableHeaderForOpp = '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Opportunity Name</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Current Stage</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: center;\"><b>Current DAS</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Comments</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Stage 6 Date</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Link to Opportunity</b></td></tr>';
    public static final string tableEnd = '</table>';
    
    public DASNotification_OpptySnapshotBatch(String stdt, String eddt){
        startDate = Datetime.valueOf(stdt);
        endDate = Datetime.valueOf(eddt);
        OpportunityChanges = '';
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        //String oppId = '0060g00000xrfX9AAI';
        String query = 'Select Id, Name, DAS_Notification_Sent__c, APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c, Primary_Proposal_DAS_Snapshot__c, Stagename, APTS_Primary_Proposal_Lookup__r.APTS_ACV__c, (select OpportunityId, Oldvalue, newvalue, field, Createddate from Histories where field = \'Stagename\' and Createddate >= :startDate and Createddate <= :endDate order by createddate asc) from Opportunity where LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate';
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Opportunity> opplist){
        Opportunity opp = opplist[0];
        Integer i = 0;
        
        Boolean sendnotification = false;
        String Comments = '';
        String stage6date = '';
        string url = sBaseURL + '/' +opp.Id;
        
        if(opp.DAS_Notification_Sent__c && opp.Primary_Proposal_DAS_Snapshot__c != opp.APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c  && opp.APTS_Primary_Proposal_Lookup__r.APTS_ACV__c >= 50000){
            Comments += (Comments != '' ? '<br/>' : '') + ++i + '. DAS changed from '+ (opp.Primary_Proposal_DAS_Snapshot__c != null ? opp.Primary_Proposal_DAS_Snapshot__c : ' blank ') + ' to ' + (opp.APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c != null ? opp.APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c : ' blank ') + '.';
            sendnotification = true;
        }
        if(!opp.Histories.isEmpty()){
            Boolean showhistory = false;
            for(OpportunityFieldHistory opphis : opp.Histories){
                system.debug('++++'+ opphis.oldvalue + '++++' + opphis.newvalue);
                if(opphis.OldValue == Label.Stage_5_Contracts_Complete){
                    showhistory = true;
                }
                if(opp.DAS_Notification_Sent__c && showhistory && opp.APTS_Primary_Proposal_Lookup__r.APTS_ACV__c >= 50000){
                    Comments += (Comments != '' ? '<br/>' : '') + ++i + '. Stage got changed from '+ (opphis.OldValue != null ? opphis.OldValue : ' blank ') + ' to ' + (opphis.NewValue != null ? opphis.NewValue : ' blank ') + '.';
                    if(opphis.NewValue == Label.Stage_6_Closed_Won){
                        stage6date = opphis.Createddate.format('MM/dd/YYYY');
                    }
                    sendnotification = true;
                }
            }
        }
        
        if(sendnotification){
            OpportunityChanges += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\">'+opp.Name+'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\">'+opp.Stagename+'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\">'+opp.APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c+'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\">'+Comments+'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\">'+stage6date+'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;text-align: left;\"><a href=\''+ url + '\''  + '>'+opp.Name+'</a></td></tr>';
            
            opp.Primary_Proposal_DAS_Snapshot__c = opp.APTS_Primary_Proposal_Lookup__r.Included_DAS_Package__c;
            TriggerUtility.updateContractEndDateExecuted();
            TriggerUtility.OpptyTriggerFCexecuted();
            TriggerUtility.updateSEManagerEmailExecuted();
            TriggerUtility.oppPRProductionStatusUpdateExecuted();
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
            Database.SaveResult sr = database.update(opp, false);
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successlst.add(sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(opp.Id + ' - ' + err.getMessage());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        system.debug('++++'+OpportunityChanges);
        List<String> dasteamemails = new List<String>();
        if(Label.DAS_Notification_team != '' && Label.DAS_Notification_team != null){
            dasteamemails.addAll(Label.DAS_Notification_team.split(','));
        }
        /*dasteamemails.add('uraju@zscaler.com');
        dasteamemails.add('vjambunathan@zscaler.com');
        dasteamemails.add('snag@zscaler.com');
        dasteamemails.add('rmanchiraju@zscaler.com');*/
        if(OpportunityChanges != ''){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list<string> ccEmailIdList = new list<string>();
            String emailBody = emailStart + tableStart + SummTableHeaderForOpp + OpportunityChanges + tableEnd + emailEnd;
            mail.setSubject('Summary of Opportunity Changes');
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setToAddresses(dasteamemails);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(emailBody);
            messageList.add(mail);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list<string> ccEmailIdList = new list<string>();
            String emailBody = 'There are no Opportunities that got changed yesterday.';
            mail.setSubject('Summary of Opportunity Changes');
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setToAddresses(dasteamemails);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setPlainTextBody(emailBody);
            messageList.add(mail);
        }
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Opportunity DAS Snapshot Update Failure result');
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
            mail.setSubject('Opportunity DAS Snapshot Update Success result ');
            mail.setPlainTextBody('Opportunity DAS Snapshot Update has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}