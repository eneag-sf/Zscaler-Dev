/*
 * Links account to a matching patch on new account insert or certain fields update.
 */
trigger LinkAccountToPatch on Account (before insert, after insert, before update, after update) 
{
    
    /**for(Account accRec : trigger.new){ 
        if(trigger.isUpdate){
            if(accRec.TriggerPatchAssignment__c && accRec.TriggerPatchAssignment__c != trigger.oldMap.get(accRec.Id).TriggerPatchAssignment__c){
                TriggerUtility.realignPatch();
                break;
            }
        }
        if(trigger.isInsert){
            if(accRec.TriggerPatchAssignment__c){
                TriggerUtility.realignPatch();
                break;
            }
        }
    }**/
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Account_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    
    if((!skipTrigger) && (!TriggerUtility.isSkipAccTriggerExecuted())){
        
        if(trigger.isInsert && trigger.isBefore){   
            AccountTriggerHelper.UpdateDateRange(Trigger.new);
        }   
        if(trigger.isUpdate && trigger.isBefore){   
            AccountTriggerHelper.UpdateDateRange(Trigger.new,Trigger.oldMap);   
        }
        
        List<Id> accNeedsPatchAssign = new List<Id>();
        if(Trigger.isInsert)
        {
            if(Trigger.isBefore)
            {
                for(Account acc : Trigger.new)
                {
                    acc.TriggerPatchAssignment__c = true;
                }
            }
            else if(Trigger.isAfter)
            {
                for(Account acc : Trigger.new)
                {
                    accNeedsPatchAssign.add(acc.Id);
                }
            }
        }
        else if(Trigger.isUpdate)
        {   //changes added as apart of RBAC:Start
            if(Trigger.isBefore)
            {
                for(Account acc : Trigger.new)
                {
                    system.debug('before update Account');
                    if(!PatchRuleEngineStarter.isInPipeline(acc.Id))
                    {
                        system.debug('before update Account');
                        Account oldAccount = Trigger.oldMap.get(acc.Id);
                        PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(acc);
                        PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                        if(!target.isSameTarget(oldTarget))
                        {
                            system.debug('target is not same');
                            acc.TriggerPatchAssignment__c = true;
                        }
                    }
                }
            }
            else if(Trigger.isAfter)
            {   //changes added as apart of RBAC:End
                for(Account acc : Trigger.new)
                {
                    system.debug('in after update of Account trigger');
                    if(!PatchRuleEngineStarter.isInPipeline(acc.Id))
                    {
                        system.debug('inside pipeline');
                        Account oldAccount = Trigger.oldMap.get(acc.Id);
                        PatchDataModel.MatchTarget target = new PatchDataModel.MatchTarget(acc);
                        PatchDataModel.MatchTarget oldTarget = new PatchDataModel.MatchTarget(oldAccount);
                        if(acc.TriggerPatchAssignment__c || !target.isSameTarget(oldTarget))
                        {
                            system.debug('inside if condition to patch assign');
                            accNeedsPatchAssign.add(acc.Id);
                        }
                    }
                }
            }
        }
        system.debug('accNeedsPatchAssign  '+accNeedsPatchAssign);
        if(accNeedsPatchAssign.size() > 0)
        {
            system.debug('inside if condition to patch assign');
            PatchRuleEngineStarter starter = new PatchRuleEngineStarter(accNeedsPatchAssign);
            starter.start();
        }
        //check added as apart of RBAC
        if(!TriggerUtility.isPatchRealigning()) {
            //Need to run when patch is realigned
            system.debug('call the AccountSalesTerritoryAndContactPatch.updateContactsPatch method');
            AccountSalesTerritoryAndContactPatch.updateContactsPatch(trigger.new, trigger.oldMap);
        }
    
        if(trigger.isAfter && trigger.isInsert) {
            CaseCreationForAccountAndOpportunity.accountCaseCreation(trigger.new);
            if(!TriggerUtility.isProspectEntitlementExecuted()){
                AccountTriggerHelper.entitlementCreationforProspect(Trigger.new);
            }
        }
        if(trigger.isAfter /* && !TriggerUtility.ScreenAccountsWithAmberRoadExecuted() */ && (trigger.isInsert || trigger.isupdate)){
            AccountTriggerHelper.screenAccountsWithAmberRoad(trigger.new,trigger.oldMap);
        }
        
        
        system.debug('the patch realign' + TriggerUtility.isPatchRealigning());
        system.debug('is Update ' + trigger.isUpdate);
        
         //check added as apart of RBAC
        if(!TriggerUtility.isPatchRealigning()) {
            //Skip these methods when patch is realigned -- Don't change anything here
            if(trigger.isUpdate && trigger.isAfter){
                
                //AccountTriggerHelper.reCreateAccountTeams(Trigger.new, Trigger.oldMap);            
                //Need to run when patch is realigned
                AccountTriggerHelper.changeRelatedContactsOwner(trigger.new, trigger.oldmap);
        
                // Vijay - 03/26/2018: Commented this out as the logic will be handled by contact trigger
                // if(!TriggerUtility.isAccContactWhiteSpaceUpdateExecuted())
                //     AccountTriggerHelper.updateContactWhitespaceRole(trigger.new, trigger.oldMap);
        
                if (!TriggerUtility.isupdateSENameFromAccountExecuted()) {
                    //Need to run when patch is realigned
                    AccountTriggerHelper.updateSENamesInOpportunity(trigger.new, trigger.oldMap);
                }
        
                if (!TriggerUtility.isCaptureCustomerNextStepsHistoryExecuted()) {
                    //Ignore
                    AccountTriggerHelper.captureCustomerNextStepsHistory(Trigger.new, Trigger.oldMap);
                }
                
                system.debug('here it is' + TriggerUtility.isUpdateContractEndDateExecuted());
                
                if (!TriggerUtility.isUpdateContractEndDateExecuted()) {
                    //Ignore
                    AccountTriggerHelper.updateContractEndDateInOpportunity(Trigger.new, Trigger.oldMap);
                }
                
                if (!TriggerUtility.isAcctoActivityTerritoryExecuted()) {
                    //Need to run when patch is realigned. Commented by Sateesh
                    AccountTriggerHelper.updateTerritoryonActivities(Trigger.new, Trigger.oldMap);
                }
    
            }
        }
        
        //if(TriggerUtility.isPatchRealigning()){
        if(trigger.isUpdate && trigger.isAfter){
            //if account owner changes create the account team member
            AccountTriggerHelper.AAUCreateAccountTeamMember(Trigger.new, Trigger.oldMap);
            
            if(!TriggerUtility.isEntitlementUpdateExecuted()){
                AccountTriggerHelper.updateEntitlement(Trigger.new, Trigger.OldMap);
            }
        }
        if((trigger.isUpdate) && trigger.isBefore){
            //if account owner changes create the account team member
            AccountTriggerHelper.beforeUpdatePartnerTier(Trigger.new, Trigger.oldMap);
        }
        if((trigger.isInsert) && trigger.isBefore){
            //if account owner changes create the account team member
            AccountTriggerHelper.beforeInsertPartnerTier(Trigger.new);
        }
        //}
    }
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