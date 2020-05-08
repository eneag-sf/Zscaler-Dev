/**
 * @File Name          : UpdateAccountMarketSegment.trigger
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 20/5/2019, 12:31:05 PM
 * @Modification Log   : 
 *==============================================================================
 *  Date                     Author                    Modification
 *==============================================================================
 *  3June,2019        Gurjinder Singh     Added logic to update Customer Success Stage on Account
**/

trigger UpdateAccountMarketSegment on Account (before insert, before update, after update)
{
    //changes added as a part of RBAC:Start
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Account_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    if((!skipTrigger) && (!TriggerUtility.isSkipAccTriggerExecuted())){
    
        if(trigger.isbefore){
            
        
            for(Account accRec : trigger.new){
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
            }
        //changes added as a part of RBAC:End
        //for(Account accRec : trigger.new){
        //}
        //if(!TriggerUtility.isPatchRealigning()){
            // Query the list of country names and codes for EMEA region. Should not skip this code
			if(trigger.isInsert || !TriggerUtility.UpdatingMarketsegmentforEMEAExecuted()){
							
				ZscalerSetting__c setting = ZscalerSetting__c.getInstance('EMEACountriesPatchRuleName');
				List<String> lstPatchCriteriaRuleNames = new List<String>();
				if (setting != null && setting.Value__c != null) {
					lstPatchCriteriaRuleNames.addAll(setting.Value__c.split(','));
				}
				System.debug('*** lstPatchCriteriaRuleNames: ' + lstPatchCriteriaRuleNames);
				Set<String> setEMEACountries = new Set<String>();
				for (PatchMatchList__c countryName : [SELECT Name FROM PatchMatchList__c WHERE PatchCriteriaRule__r.Name = :lstPatchCriteriaRuleNames]) {
					setEMEACountries.add(countryName.Name.toLowerCase());
				}
				if(trigger.isInsert)
				{
					for(Account newAccount : Trigger.new)
					{
						if(!newAccount.Override_Market_Segment__c)
						{
							newAccount.Market_Segment__c = TriggerUtility.GetMarketSegment(newAccount.No_of_Employees_Users__c, newAccount.NumberOfEmployees, (newAccount.BillingCountry != null && setEMEACountries.contains(newAccount.BillingCountry.toLowerCase())));
						}
					}
				}
				else if(trigger.isUpdate)
				{
					Account oldAccount;
					for(Account newAccount : Trigger.new)
					{
						oldAccount = Trigger.oldMap.get(newAccount.Id);
						if(!newAccount.Override_Market_Segment__c && (newAccount.TriggerPatchAssignment__c || newAccount.NumberOfEmployees != oldAccount.NumberOfEmployees || newAccount.No_of_Employees_Users__c != oldAccount.No_of_Employees_Users__c || newAccount.BillingCountry != oldAccount.BillingCountry))
						{
							newAccount.Market_Segment__c = TriggerUtility.GetMarketSegment(newAccount.No_of_Employees_Users__c, newAccount.NumberOfEmployees, (newAccount.BillingCountry != null && setEMEACountries.contains(newAccount.BillingCountry.toLowerCase())));
						}
					}
					TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
				}
			}
			
            if(!TriggerUtility.isAccTerritoryPatchexecuted()){
                AccountSalesTerritoryAndContactPatch.setAccountSalesTerritory(trigger.new);
            }
            
            if(!TriggerUtility.isAccSalesTeamExecuted()){
                AccountTriggerHelper.getAccSalesTeam(trigger.new, trigger.oldMap);
            }
            
            //if(!TriggerUtility.isPatchRealigning()){
            //Added to update Customer Success Stage on Account: Gurjinder :Start
        List <ByPassTriggerForSpecifiedUser__c> bypasstrigger = ByPassTriggerForSpecifiedUser__c.getAll().values();
        Map<String, ByPassTriggerForSpecifiedUser__c> triggersMap= new Map<String, ByPassTriggerForSpecifiedUser__c>();
        boolean bypassflag=false;
        if(!bypasstrigger.isempty() && bypasstrigger.size()>0){
            for(ByPassTriggerForSpecifiedUser__c objbypass: bypasstrigger) {
                triggersMap.put(objbypass.User_Name__c ,objbypass);
            }
        }
            
        if(triggersMap!= null && triggersMap.containsKey(UserInfo.getUserName()) && triggersMap.get(UserInfo.getUserName()).bypass_component__c==TRUE){        
            ByPassTriggerForSpecifiedUser__c objbypass = triggersMap.get(UserInfo.getUserName());
            if(objbypass.User_Name__c==UserInfo.getUserName() && objbypass.bypass_component__c==TRUE)      
            {             
                system.debug('bypass the logic ');
                bypassflag=true;
            }else{
                system.debug('execute the logic ');
            }
        }
            if(!bypassflag &&  trigger.isbefore && (trigger.isInsert || trigger.isUpdate) && !TriggerUtility.CustomerSuccessUpdatemethodexecuted() && !TriggerUtility.isPatchRealigning()){
                system.debug('passed condition 1');
                if(OnOffSwitch__c.getInstance('updateCSMfieldonAccount')!=null && OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateCSMfieldonAccount').Deactivate_Component__c==False){
                     system.debug('passed condition 2');
                    AccountTriggerHelper.UpdateCustomerSuccessStage(trigger.new,trigger.oldMap);
                }
            }
            
            //}
            //Added to update Customer Success Stage on Account: Gurjinder :End
            
            //if(!TriggerUtility.isPatchRealigning()){
            //BEFORE INSERT & UPDATE - Account->ProspectType updates on related SCI and Opp stages
            if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        AccountTriggerHelper obj = new AccountTriggerHelper();
         obj.updateCustomerSupportStage(trigger.new);
                if(!TriggerUtility.isProspectUpdateExecuted()){
                    obj.updateProspectTypeOnAccount(trigger.new);
                }
            }
        //}
        }
        /**if(trigger.isAfter && Trigger.isUpdate){
            system.debug('in After update event');
            system.debug('TriggerUtility.UpdateAccountExtensionmethodExecuted()' + TriggerUtility.UpdateAccountExtensionmethodExecuted());
            if(!TriggerUtility.UpdateAccountExtensionmethodExecuted()){
                 AccountTriggerHelper.UpdateAccountExtensionmethod(trigger.new,trigger.oldMap);
            }
        }**/
        if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore){
        //system.debug('TriggerUtility.UpdateAccountExtensionmethodExecuted()' + TriggerUtility.AccountWorkflowOptimizationmethodExecuted());
            //if(!TriggerUtility.AccountWorkflowOptimizationmethodExecuted()){
                 AccountTriggerHelper.AccountWorkflowOptimizationmethod(trigger.new,trigger.oldMap,Trigger.isInsert , Trigger.isUpdate);
           // }
        }
    }
}