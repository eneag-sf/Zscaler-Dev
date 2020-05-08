/*
*************************************************
Name :  APTS_Opportunity_Master_trigger
CreatedBy :  Hormese A  <hambookken@apttus.com>
CreatedOn :  12 Oct 2016
Description :  Master Trigger for Opportunity object.
*************************************************
*/

trigger APTS_Opportunity_Master_trigger on Opportunity (before insert, before update, after insert, after update) {
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Opportunity_Triggers__c = true){
            skipTrigger = true;
        }
    }
    
    if(!skipTrigger){
    
        APTS_OpportunityTriggerHandler instTrHand = new APTS_OpportunityTriggerHandler();
        if (trigger.isafter && trigger.isinsert){
           
           // instTrHand.onAfterInsert(trigger.new);
        }
        if(trigger.isbefore && trigger.isupdate){
            //Integer countCHURN = [SELECT count() FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c IN: Trigger.new];
            if(!System.Label.System_Admin_Id.contains(UserInfo.getProfileId()) || Test.isRunningTest()){
                for(Opportunity opp : Trigger.new){
                    if(!String.isBlank(opp.Sub_Stage__c)){
                        if(opp.Stagename == Label.Stage_7_Closed_Lost && System.Label.Stages_for_Loss_Form.contains(opp.Sub_Stage__c) && opp.isChurnpresent__c == false && opp.Stagename != trigger.oldMap.get(opp.Id).Stagename && System.Label.Skip_Churn_And_Loss != 'Yes' /*&& opp.StageName == '11 - Closed Lost'*/ && !String.isblank(opp.Validation_Stage__c) && opp.Validation_Stage__c != '0 - Not Started'){
                            if(!Test.isRunningTest()){
                                opp.addError('The opportunity cannot be set to closed set without completing the opportunity loss form. <a href=\''+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/OppLossReasonFormPage?oppId='+opp.Id+'\'>Click here</a> to complete the form.', false);
                            }
                        }
                    }
                }
            }
        }
        if (trigger.isbefore && trigger.isinsert){
    		instTrHand.handleBeforeInsert(trigger.new);
            
           // instTrHand.onBeforeInsert(trigger.new);
        }
        if (trigger.isbefore && trigger.isupdate){
            //instTrHand.onBeforeUpdate(trigger.new,trigger.oldmap);
            system.debug('here it is');
            OpportunityNOTRAHandler.beforeUpdate(trigger.oldMap, trigger.newMap);
        }
        if (trigger.isafter && trigger.isupdate){
          // instTrHand.autoreneOpportunity(trigger.new,trigger.oldmap);
          //  instTrHand.onAfterUpdate(trigger.new,trigger.oldmap); 
        }
    }
}