/**
 * @File Name          : getOppLossReasonController.cls
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 20/7/2019, 1:20:51 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    20/7/2019, 1:20:47 PM   pranjalsingh@zscaler.com     Initial Version
**/

global class getOppLossReasonController {
    public static Churn__c churnObj{ set; get; }
    public Boolean isZIAproduct{ set; get; }
    public Boolean isZPAproduct{ set; get; }
    public string SCINumber {get; set;}
    public string opportunityRecordType{ set; get; }
    public static Opportunity oppObj { get; set; }
    public String Accountname {get; set;}
    public static Significant_Customer_Interaction__c sciObj { get; set; }
    public string oppName = null;
    
    global getOppLossReasonController(ApexPages.StandardController controller){
        Churn__c churnObj = (Churn__c)controller.getRecord();
        Map<String, String> m = ApexPages.currentPage().getParameters();
        churnObj.Opportunity__c = (Id) m.get('oppId');
        isZIAproduct = Util_ChurnReasonMethods.isZIApresent(churnObj.Opportunity__c);
        isZPAproduct = Util_ChurnReasonMethods.isZPApresent(churnObj.Opportunity__c);
        opportunityRecordType = Util_ChurnReasonMethods.getOpportunityRecordType(churnObj.Opportunity__c);
        if(m.get('Id') != null){
            List<Churn__c> churnLst = [Select Id, SCINumber__c from Churn__c Where Id =: (Id) m.get('Id')];
            if(!churnLst.isEmpty()){
                if(churnLst[0].SCINumber__c != null){
                    SCINumber = churnLst[0].SCINumber__c;
                }
                else{
                    SCINumber = 'No SCI';
                }
            }
        }
        List<Opportunity> opplst = [Select Id, Account.name from Opportunity where Id = :(Id) m.get('oppId')];
        if(!opplst.isEmpty()){
            accountName = opplst[0].Account.Name;
        }
        
    }
    /**
     * Common util function to fetch picklist dynamically by taking Object and field name
     * as reference points and returns to page JS vars.
     */
    @RemoteAction    
    global static list<SelectOption> getPicklistValues(String str, String fld){
       
      sObject obj = Schema.getGlobalDescribe().get(str).newSObject();
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
    }
    
    @RemoteAction
    global static Churn__c getChuran(String cId){
        List<Churn__c> churnLst = new List<Churn__c>();
        churnLst = [Select id,Name
                            ,Type__c
                            ,Opportunity__c
                            ,Opportunity__r.StageName
                            ,TransformationPrimaryReason__c
                            ,TransformationSecondaryReason__c
                            ,ExperienceFeaturesZPAPrimaryReason__c
                            ,ExperienceFeaturesZPASecondaryReason__c
                            ,ExperienceFeaturesZIAPrimaryReason__c
                            ,ExperienceFeaturesZIASecondaryReason__c
                            ,Engagement_Primary_Reason__c
                            ,Engagement_Secondary_Reason__c
                            ,Other_Primary_Reason__c
                            ,Other_Secondary_Reason__c
                            ,Lifetime_Value_Primary_Reason__c
                            ,Lifetime_Value_Secondary_Reason__c
                            ,ExperienceMissingfunctionality__c
                            ,PrimaryCompetitor__c
                            ,Secondary_Competitors__c
                            ,AdditionalNotes__c
                            ,Renewalquestion__c
                            ,SCINumber__c
                            ,LossAnalysisCall__c
                            ,SCINumber__r.Name From Churn__c Where id=:cId];
        if(!churnLst.isEmpty()){
            return churnLst[0];
        }
        else{
            return new Churn__c();        
        }
    }

    @RemoteAction
    public static saveResponse saveForm(String oppId,
                                  String churnId,
                                  String primaryResn,
                                  String secondaryResn,
                                  String ZIAPrimaryResn,
                                  String ZIASecondaryResn,
                                  String ZPAPrimaryResn,
                                  String ZPASecondaryResn,
                                  String primaryEngagementResn,
                                  String secondaryEngagementResn,
                                  String primaryotherResn,
                                  String secondaryotherResn,
                                  String primarylifetimeResn,
                                  String secondarylifetimeResn,
                                  String ExperienceMissingfunctionality,
                                  String RenewalQuestionVal,
                                  String primaryComp,
                                  String secondaryComp,
                                  //String isProductSelectedInput,
                                  String additionalNotes,
                                  String sciNumber,
                                  String closedLost,
                                  boolean isLossCallConducted,
                                  boolean isActivePRpresent){
        
        saveResponse responseValue = new saveResponse();
        
        Churn__c churnObj = new Churn__c();
        try{
            system.debug('#LOG:');
            //Map<String, String> m = ApexPages.currentPage().getParameters();
            Opportunity opp = [SELECT Id,Name,Stagename,recordType.Name, Confirm_Opportunity_Closure__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
            
            if(oppId != null){
                if(opp.recordType.Name == 'Renewal Opportunity'){
                    churnObj.Type__c = 'Churn';
                }
                else{
                    churnObj.Type__c = 'Loss';
                }
                churnObj.Opportunity__c = oppId;
                //churnObj.Name = opp.Name+'_'+churnObj.Type__c;
                churnObj.Name__c = opp.Name+'_'+churnObj.Type__c;
                if(closedLost != null){
                    opp.StageName = closedLost;
                }
                if(isActivePRpresent != null){
                    opp.Confirm_Opportunity_Closure__c = isActivePRpresent;
                }
            }
            
            if(primaryResn != null && primaryResn != 'Please select' ){
                churnObj.TransformationPrimaryReason__c = primaryResn;
            }
            
            if(secondaryResn != null && secondaryResn != 'Please select' ){
                churnObj.TransformationSecondaryReason__c = secondaryResn;
            }
            else if(secondaryResn == 'Please select'){
                churnObj.TransformationSecondaryReason__c = null;
            }
            
            if(ZPAPrimaryResn != null && ZPAPrimaryResn != 'Please select'){
                churnObj.ExperienceFeaturesZPAPrimaryReason__c = ZPAPrimaryResn;
            }
            if(ZPASecondaryResn != null && ZPASecondaryResn != 'Please select'){
                churnObj.ExperienceFeaturesZPASecondaryReason__c = ZPASecondaryResn;
            }
            else if(ZPASecondaryResn == 'Please select'){
                churnObj.ExperienceFeaturesZPASecondaryReason__c = null;
            }
            
            if(ZIAPrimaryResn != null && ZIAPrimaryResn != 'Please select'){
                churnObj.ExperienceFeaturesZIAPrimaryReason__c = ZIAPrimaryResn;
            }
            if(ZIASecondaryResn != null && ZIASecondaryResn != 'Please select'){
                churnObj.ExperienceFeaturesZIASecondaryReason__c = ZIASecondaryResn;
            }
            else if(ZIASecondaryResn == 'Please select'){
                churnObj.ExperienceFeaturesZIASecondaryReason__c = null;
            }
            if(primaryEngagementResn != null && primaryEngagementResn != 'Please select'){
                    churnObj.Engagement_Primary_Reason__c = primaryEngagementResn;
                }
                if(secondaryEngagementResn != null && secondaryEngagementResn != 'Please select'){
                    churnObj.Engagement_Secondary_Reason__c = secondaryEngagementResn;
                }
                else if(secondaryEngagementResn == 'Please select'){
                    churnObj.Engagement_Secondary_Reason__c = null;
                }
                
                if(primaryotherResn != null && primaryotherResn != 'Please select'){
                    churnObj.Other_Primary_Reason__c = primaryotherResn;
                }
                else if(primaryotherResn == 'Please select'){
                    churnObj.Other_Primary_Reason__c = null;
                }
                if(secondaryotherResn != null && secondaryotherResn != 'Please select'){
                    churnObj.Other_Secondary_Reason__c = secondaryotherResn;
                }
                else if(secondaryotherResn == 'Please select'){
                    churnObj.Other_Secondary_Reason__c = null;
                }
                if(primarylifetimeResn != null && primarylifetimeResn != 'Please select'){
                    churnObj.Lifetime_Value_Primary_Reason__c = primarylifetimeResn;
                }
                if(secondarylifetimeResn != null && secondarylifetimeResn != 'Please select'){
                    churnObj.Lifetime_Value_Secondary_Reason__c = secondarylifetimeResn;
                }
                else if(secondarylifetimeResn == 'Please select'){
                    churnObj.Lifetime_Value_Secondary_Reason__c = null;
                }
            /**if(opp.recordType.Name == 'New Business' || opp.recordType.Name == 'New Business Close'){
                
                
                
                
                
                
                
                
                
                
                
            }
            if(opp.recordType.Name == 'Upsell Opportunity' || opp.recordType.Name == 'Renewal Opportunity'){
                
                /**if(ZIAPrimaryResn != null && ZIAPrimaryResn != 'Please select'){
                    churnObj.ExperienceFeaturesZIAPrimaryReason__c = ZIAPrimaryResn;
                }
                if(ZIASecondaryResn != null && ZIASecondaryResn != 'Please select'){
                    churnObj.ExperienceFeaturesZIASecondaryReason__c = ZIASecondaryResn;
                }
                else if(ZIASecondaryResn == 'Please select'){
                    churnObj.ExperienceFeaturesZIASecondaryReason__c = null;
                }
                
                if(ZIAPrimaryResn != null && ZIAPrimaryResn != 'Please select'){
                    churnObj.ExperienceFeaturesZIAPrimaryReason__c = ZIAPrimaryResn;
                }
                if(ZIASecondaryResn != null && ZIASecondaryResn != 'Please select'){
                    churnObj.ExperienceFeaturesZIASecondaryReason__c = ZIASecondaryResn;
                }
                else if(ZPASecondaryResn == 'Please select'){
                    churnObj.ExperienceFeaturesZPASecondaryReason__c = null;
                }
                
                if(primaryEngagementResn != null && primaryEngagementResn != 'Please select'){
                    churnObj.Engagement_Primary_Reason__c = primaryEngagementResn;
                }
                if(secondaryEngagementResn != null && secondaryEngagementResn != 'Please select'){
                    churnObj.Engagement_Secondary_Reason__c = secondaryEngagementResn;
                }
                else if(secondaryEngagementResn == 'Please select'){
                    churnObj.Engagement_Secondary_Reason__c = null;
                }
                
                
                if(primaryotherResn != null && primaryotherResn != 'Please select'){
                    churnObj.Other_Primary_Reason__c = primaryotherResn;
                }
                else if(primaryotherResn == 'Please select'){
                    churnObj.Other_Primary_Reason__c = null;
                }
                if(secondaryotherResn != null && secondaryotherResn != 'Please select'){
                    churnObj.Other_Secondary_Reason__c = secondaryotherResn;
                }
                else if(secondaryotherResn == 'Please select'){
                    churnObj.Other_Secondary_Reason__c = null;
                }**/
                
                /**if(primarylifetimeResn != null && primarylifetimeResn != 'Please select'){
                    churnObj.Lifetime_Value_Primary_Reason__c = primarylifetimeResn;
                }
                if(secondarylifetimeResn != null && secondarylifetimeResn != 'Please select'){
                    churnObj.Lifetime_Value_Secondary_Reason__c = secondarylifetimeResn;
                }
                else if(secondarylifetimeResn == 'Please select'){
                    churnObj.Lifetime_Value_Secondary_Reason__c = null;
                }
                
            }**/
            
            if(ExperienceMissingfunctionality != null){
                churnObj.ExperienceMissingfunctionality__c = ExperienceMissingfunctionality;
            }
            
            if(RenewalQuestionVal != null && RenewalQuestionVal != 'Please select'){
                churnObj.Renewalquestion__c = RenewalQuestionVal;
            }
            
            if(primaryComp != null && primaryComp != 'Please select'){
                churnObj.PrimaryCompetitor__c = primaryComp;
            }
            if(secondaryComp != null && secondaryComp != 'Please select'){
                churnObj.Secondary_Competitors__c = secondaryComp;
            }
            else if(secondaryComp == 'Please select'){
                churnObj.Secondary_Competitors__c = null;
            }
            
            /*if(isProductSelectedInput != null){
                churnObj.PrimaryCompetitorProduct__c = isProductSelectedInput;
            }
            if(isProductSelectedInput != null && primaryComp != ''){
                churnObj.Primary_Product__c = isProductSelectedInput;
            }
            */
            
            if(churnId != null && churnId != ''){
                churnObj.Id = churnId;
            }
            
            if(additionalNotes != null){
                churnObj.AdditionalNotes__c = additionalNotes;
            }
            if(sciNumber != null && sciNumber != 'Please select' && sciNumber != ''){
                churnObj.SCINumber__c = sciNumber;
            }
            else{
                churnObj.SCINumber__c = null;
            }
            Id RecordTypeIdChurn = Schema.SObjectType.Churn__c.getRecordTypeInfosByName().get('NewBusiness_Upsell').getRecordTypeId();
            churnObj.RecordTypeId = RecordTypeIdChurn;
            if(isLossCallConducted){
                churnObj.LossAnalysisCall__c = true;
            } 
            else{
                churnObj.LossAnalysisCall__c = false;
            }
            update opp;
            upsert churnObj;
            system.debug('#LOG:'+churnObj.Id);
            
            if(churnId != null && churnId != ''){
                //return churnObj.Id;
                responseValue.result = churnObj.Id;
                responseValue.status = true;
            }
            else{
                //return opp.Id;
                responseValue.result = opp.Id;
                responseValue.status = true;
            }
        }catch(Exception e){
            //ApexPages.addMessages(e);system.debug('here Form error: '+ e);
            //return e.getMessage();
            responseValue.exceptionMsg = e.getMessage();
            responseValue.status = false;
        }
        return responseValue;
    }
    
    public class saveResponse{
        public boolean status;
        public string exceptionMsg;
        public string result;
    }
}