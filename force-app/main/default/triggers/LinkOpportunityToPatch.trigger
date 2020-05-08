/*
 * Links opportunity to a matching patch on new opp insert or certain fields update.
 */
trigger LinkOpportunityToPatch on Opportunity (after insert, before update, after update/*, before insert*/){
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Opportunity_Triggers__c = true){
            skipTrigger = true;
        }
    }
    if(!skipTrigger){
    //if(System.Label.Skip_Opportunity_Triggers != 'Yes'){
    
        List<Id> oppNeedsPatchAssign = new List<Id>();
        
        List<Opportunity> opportunityToCreateSalesTeam = new List<Opportunity>();
        Set<Id> opportunitySalesTerritoryIds = new Set<Id>();
        
        if(Trigger.isInsert && !TriggerUtility.isOppPatchManagerAfterInsertExecuted()){
            for(Opportunity opp : Trigger.new){
                oppNeedsPatchAssign.add(opp.Id);
            }
        }
        else if(Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isOppPatchManagerAfterUpdateExecuted()){
            for(Opportunity opp : Trigger.new){
                if(!PatchRuleEngineStarter.isInPipeline(opp.Id)/* && system.isBatch()*/) {
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if(opp.TriggerPatchAssignment__c || opp.AccountId != oldOpp.AccountId){
                        oppNeedsPatchAssign.add(opp.Id);
                    }
                }
            }
        }
        if(oppNeedsPatchAssign.size() > 0){
             //below two lines commented as a part of RBAC
            // PatchRuleEngineStarter starter = new PatchRuleEngineStarter(oppNeedsPatchAssign);
            // starter.start();
            PatchRuleHelper.assignSalesTeamMembers(oppNeedsPatchAssign, 'Opportunity');  // added as apart of RBAC
            if (Trigger.isInsert) {
                TriggerUtility.oppPatchManagerAfterInsertExecuted();
            } else if (Trigger.isUpdate) {
                TriggerUtility.oppPatchManagerAfterUpdateExecuted();
            }
        }
        
        If(Trigger.isBefore){
            if(Trigger.isInsert){
                OpportunityFieldUpdateTriggerHandler.BeforeInsert(trigger.New);
            }
            if(Trigger.isUpdate){
                OpportunityFieldUpdateTriggerHandler.BeforeUpdate(trigger.New,Trigger.OldMap);
                UpdateIncumbentPartners.BeforeUpdate(trigger.New,Trigger.OldMap);
            } 
        }
        
        if(trigger.isInsert && trigger.IsAfter){
            CaseCreationForAccountAndOpportunity.opportunityCaseCreation(trigger.new);
        }
    
        if(trigger.isInsert && trigger.IsAfter){
            //CapturePartnerOnOpportunity.insertPartner(trigger.new, null);
            set<id> oppIdSet = new set<Id>();
            List<Id> accountIdsToScreen = new List<Id>(); // added for Amber Road Enhancement:Gurjinder
            for(Opportunity opp : trigger.New){
                if(opp.Partner_Account_Name__c == null){
                    oppIdSet.add(opp.Id);
                }
                //Changes Added for Amber Road Enhancement:Gurjinder:Start
                if(opp.AccountId!=null) {
                     accountIdsToScreen.add(opp.AccountId);
                }
                //Changes Added for Amber Road Enhancement:Gurjinder:End
            }
            if(!oppIdSet.isEmpty())
                //CapturePartnerOnOpportunity.updateOpportunityPartner(oppIdSet);
    
            if (!TriggerUtility.isupdateSEManagerEmailExecuted()) {
                OppotunityTriggerHelper.updateOpportunityFields(Trigger.oldMap, Trigger.new);
            }
            //Changes added for Amber Road Enhancement:Gurjinder:Start
            if (!accountIdsToScreen.isEmpty() && !TriggerUtility.isOpportunityAccountsScreeningExecuted()) {
                    for (Account accountToBeScreened : [SELECT Id, Amber_Road_Status__c, BillingPostalCode, BillingState,
                                                               BillingCity, BillingCountry, BillingStreet, Fax, Name, Phone,Type 
                                                          FROM Account
                                                         WHERE Id IN :accountIdsToScreen and Type='Customer']) {
                        if (!Test.isRunningTest()) {
                            AmberRoadService.screenAccountFuture(JSON.serialize(accountToBeScreened), false, true);
                        }
                    }
                    TriggerUtility.opportunityAccountsScreeningExecuted();
                }
            //Changes added for Amber Road Enhancement:Gurjinder:End
        }
        
        //Changes added as apart of RBAC
        if(trigger.isUpdate && trigger.IsBefore){
            List<Opportunity> oppToCreateTeam = new List<Opportunity>();
            for(Opportunity opp : trigger.New){
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if(oldOpp.OwnerId != opp.OwnerId){
                    oppToCreateTeam.add(opp);
                }
            }
            if(!oppToCreateTeam.isEmpty()){
                OppotunityTriggerHelper.createOpportunityTeam(oppToCreateTeam);
            }
        }
        
        
        //Check added as apart of RBAc
        
        system.debug('the patch realignment' + TriggerUtility.isPatchRealigning());
        
        if(!TriggerUtility.isPatchRealigning()) {
            if(trigger.isUpdate && trigger.IsAfter ){
                system.debug('in the after update log');
                list<Opportunity> oppList = new list<Opportunity>();
                List<Id> accountIdsToScreen = new List<Id>();
                for(Opportunity opp : trigger.new){
                    //if(opp.StageName == '13 - Closed & Approved By Finance' && opp.StageName != trigger.oldMap.get(opp.Id).StageName){
                    if(opp.StageName == label.Stage_6_Closed_Won && opp.StageName != trigger.oldMap.get(opp.Id).StageName){
                        oppList.add(opp);
                    }
        
                    //if ((opp.StageName == '8 - Expecting Order' || opp.StageName == '10b - PO recd, pending finance approval' || opp.StageName == '13 - Closed & Approved By Finance')&& opp.StageName != trigger.oldMap.get(opp.Id).StageName) {
                    if ((opp.StageName == label.Stage_4_Economic_Buyer_Signoff || opp.StageName == label.Stage_5_Contracts_Complete || opp.StageName == label.Stage_6_Closed_Won) && opp.StageName != trigger.oldMap.get(opp.Id).StageName) {
                        accountIdsToScreen.add(opp.AccountId);
                    }
                }
                if(!oppList.isEmpty() && !TriggerUtility.isOppCaseCreationExecuted()){
                    CaseCreationForAccountAndOpportunity.opportunityCaseCreation(trigger.new);
                    TriggerUtility.oppCaseCreationExecuted();
                }
        
                if (!oppList.isEmpty() && !TriggerUtility.isOppPRProductionStatusUpdateExecuted()) {
                    OppotunityTriggerHelper.updatePRStatusToProduction(oppList);
                    TriggerUtility.oppPRProductionStatusUpdateExecuted();
                }
        
                if (!System.isFuture()
                    && !accountIdsToScreen.isEmpty()
                    && !TriggerUtility.isOpportunityAccountsScreeningExecuted()) {
                    for (Account accountToBeScreened : [SELECT Id, Amber_Road_Status__c, BillingPostalCode, BillingState,
                                                               BillingCity, BillingCountry, BillingStreet, Fax, Name, Phone,Type
                                                          FROM Account
                                                         WHERE Id IN :accountIdsToScreen]) {
                        if (!Test.isRunningTest()) {
                            AmberRoadService.screenAccountFuture(JSON.serialize(accountToBeScreened), false, true);
                        }
                    }
                    TriggerUtility.opportunityAccountsScreeningExecuted();
                }
        
                if(!TriggerUtility.isOpportunityPartnerAddition())
                //CapturePartnerOnOpportunity.insertPartner(trigger.new, trigger.OldMap);
        
                if(!TriggerUtility.isRequestDecommissionPrExecuted())
                    oppotunityTriggerHelper.decommissionProvRequests(trigger.new, trigger.oldMap);
        
                 if(!TriggerUtility.isOppSpliSalesTeamExecuted())
                    oppotunityTriggerHelper.updateSalesTeamInfoOnOppSplit(trigger.oldMap, trigger.new);
        
                if (!TriggerUtility.isupdateOppNextStepHistoryExecuted()) {
                    OppotunityTriggerHelper.updateOpportunityNextStepsHistory(Trigger.oldMap, Trigger.new);
                    TriggerUtility.updateOppNextStepHistoryExecuted();
                }
        
                //Start of the change - Raghu
                system.debug('Testing Tech Value History');
                if (!TriggerUtility.isupdateTechValHistoryExecuted()) {
                    OppotunityTriggerHelper.updateTechValHistory(Trigger.oldMap, Trigger.new);
                    TriggerUtility.updateTechValHistoryExecuted();
                }
        
                if (!TriggerUtility.isarchitectureHistoryExecuted()) {
                    OppotunityTriggerHelper.updateArchitectureNextStepsHistory(Trigger.oldMap, Trigger.new);
                    TriggerUtility.architectureHistoryExecuted();
                }
                //End of the change -- Raghu
        
                if(!TriggerUtility.isERNotificationExecuted())
                    oppotunityTriggerHelper.EREmailNotification(trigger.new, trigger.oldMap);
        
                if (!TriggerUtility.isupdateSEManagerEmailExecuted()) {
                    OppotunityTriggerHelper.updateOpportunityFields(Trigger.oldMap, Trigger.new);
                }
                if (!TriggerUtility.isUpdateAccountForApprovedPZEN()) {
                    system.debug('here Account Approved PZEN');
                    OppotunityTriggerHelper.updateAccountForApprovedPZEN(Trigger.oldMap, Trigger.new);
                }
                if(!TriggerUtility.isUpdateForecastCategoryExecuted()){
                    OppotunityTriggerHelper.updateSplitForecastCategory(Trigger.newMap, Trigger.oldMap);
                }
                if(!TriggerUtility.isOverrideACVValuesResetExecuted()){
                    OppotunityTriggerHelper.resetOverrideACVFieldsInProposal(Trigger.oldMap, Trigger.new);
                }
                /**if(!TriggerUtility.isrevokePendingQuoteApprovalExecuted()){
                    OppotunityTriggerHelper.revokeopenPendingQuotes(Trigger.new, trigger.oldMap);
                }**/
            }
        
            // Commenting the below block as logic to change opportunity owner from ZPA rep to zia account owner is out of scope
            // if (Trigger.isAfter) {
            //     // Skip execution of ownership change code
            //     TriggerUtility.opportunityOwnershipChangeExecuted();
            //     if (!TriggerUtility.isOpportunityOwnershipChangeExecuted()) {
            //         OppotunityTriggerHelper.updateOwnersForOpportunity(Trigger.newMap, Trigger.oldMap);
            //     }
            // }
        }
      
        //if(Trigger.isBefore && Trigger.isUpdate && !TriggerUtility.isTechpartnerupdateExecuted()){
            //set<string> objectSet = new set<string>();
            //if(Label.Skip_Tech_Partner_Validations != null){
          //objectSet.addall(Label.Skip_Tech_Partner_Validations.split(','));
        //}
            //If(objectSet.contains('Opportunity')){
            //oppTechPartnerValidationHelper.validateOpportunityStages(Trigger.new, Trigger.oldMap);
            //}
        //}
        
        //OpportunityFieldUpdateTriggerHandler TriggerHandler = new OpportunityFieldUpdateTriggerHandler();
        /**If(Trigger.isAfter){
            if(Trigger.isInsert){
                OpportunityFieldUpdateTriggerHandler.AfterInsert(trigger.New);
            }
            if(Trigger.isUpdate){
                OpportunityFieldUpdateTriggerHandler.AfterUpdate(trigger.New,Trigger.OldMap);
            } 
        }**/
    }
}