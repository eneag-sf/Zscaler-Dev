public class OpportunitySplit_Owner_Territory_Update implements Database.Batchable<sObject>, Database.Stateful {
    public String query = '';
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public OpportunitySplit_Owner_Territory_Update(String q){
        query = q;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, F2F_SCI_s_in_the_last_12_Months__c, F2F_SCI_s_in_the_last_6_Months__c,  All_time_F2F_of_SCI__c, All_time_of_SCI__c from Opportunity where Id in (Select Opportunity_Name__c from Significant_Customer_Interaction__c where Recordtype.name not in (\'CAB\')) ';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<OpportunitySplit> newSplits){
        List<OpportunitySplit> opSpliList = new List<OpportunitySplit>();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
        TriggerUtility.revisitOpportunitySplitsSalesTerritoryExecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
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

        Set<Id> userIds = new Set<Id>();
        Map<Id,Id> userIdTerritoryIdMap = new Map<Id,Id>();
        for(OpportunitySplit os: newSplits){
            userIds.add(os.SplitOwnerId);
        }
        for(PatchTeamMember__c salesTeam : [Select Id, PatchTeam__c , User__c from PatchTeamMember__c where User__c IN: userIds AND PatchTeam__r.Sales_Territory_Year__c = 'Current']){
            if (!userIdTerritoryIdMap.containsKey(salesTeam.User__c)) {
                userIdTerritoryIdMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
            }
        }
        for(OpportunitySplit os: newSplits){
            if(userIdTerritoryIdMap.containsKey(os.SplitOwnerId) && os.Owner_Sales_Territory__c != userIdTerritoryIdMap.get(os.SplitOwnerId)){
                os.Owner_Sales_Territory__c = userIdTerritoryIdMap.get(os.SplitOwnerId);
                opSpliList.add(os);
            }
        }
        Database.SaveResult[] srList = database.update(opSpliList, false);
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
            mail1.setSubject('Opportunity Split Owner Territory Fields Update Batch Failure result');
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
            mail.setSubject('Opportunity Split Owner Territory Fields Update Batch Success result ');
            mail.setPlainTextBody('Opportunity Split Owner Territory Fields Update Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
}