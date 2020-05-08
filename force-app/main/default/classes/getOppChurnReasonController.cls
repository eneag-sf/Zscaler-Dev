/**
* @File Name          : getOppChurnReasonController.cls
* @Description        : 
* @Author             : pranjalsingh
* @Group              : 
* @Last Modified By   : pranjalsingh
* @Last Modified On   : 20/7/2019, 1:20:13 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    20/7/2019, 1:20:08 PM   pranjalsingh@zscaler.com     Initial Version
**/
global class getOppChurnReasonController {
    
    public Boolean isZIAproduct{ set; get; }
    public static Churn__c churnObj{ set; get; }
    public static Opportunity oppObj{ set; get; }
    //public String searchTerm {get; set;}
    public string SCINumber {get; set;}
    
    
    
    //Constructor Method
    global getOppChurnReasonController(ApexPages.StandardController controller){
        Opportunity oppObj = (Opportunity)controller.getRecord();
        oppObj.Id = ApexPages.currentPage().getParameters().get('oppId');
        isZIAproduct = Util_ChurnReasonMethods.isZIApresent(oppObj.Id);
        Map<String, String> m = ApexPages.currentPage().getParameters();
        system.debug('----------'+ApexPages.currentPage().getParameters().get('cid'));
        if(ApexPages.currentPage().getParameters().get('cid') != null){
            List<Churn__c> churnLst = [Select Id, SCINumber__c from Churn__c Where Id =: ApexPages.currentPage().getParameters().get('cid')];
            if(!churnLst.isEmpty()){
                if(churnLst[0].SCINumber__c != null){
                    SCINumber = churnLst[0].SCINumber__c;
                }
                else{
                    SCINumber = 'No SCI';
                }
            }
        }
    }
    
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
    
    
    //Used by Submit Churn Form button to redirect to our Churn Reason Form.
    /**public PageReference init(){
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('churnId') != null)
            return new PageReference('/apex/OppChurnReasonForm?oppId='+ApexPages.currentPage().getParameters().get('id') + '&cid=' + ApexPages.currentPage().getParameters().get('churnId'));
        else if(ApexPages.currentPage().getParameters().get('id') != null)
            return new PageReference('/apex/OppChurnReasonForm?oppId='+ApexPages.currentPage().getParameters().get('id'));
        else
            return null;
    }**/
    /*
    @RemoteAction
    global static List<Product2> getProducts(String searchString){
        Map<string,string> mapProds = new Map<string,string>();
        String query = 'SELECT Id FROM Product2 WHERE Name LIKE \'%'+searchString+'%\'';
        List<Product2> prodList = Database.query(query);
        if(!prodList.isEmpty() && prodList != null)
            return prodList;
        else
            return null;
        
    }*/
    
    //Used by Submit Churn Form button to redirect to our Churn Reason Form.
    public PageReference init(){
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('churnId') != null)
            return new PageReference('/apex/OppChurnReasonFormPage?oppId='+ApexPages.currentPage().getParameters().get('id') + '&cid=' + ApexPages.currentPage().getParameters().get('churnId'));
        else if(ApexPages.currentPage().getParameters().get('id') != null)
            return new PageReference('/apex/OppChurnReasonFormPage?oppId='+ApexPages.currentPage().getParameters().get('id'));
        else
            return null;
    }

    @RemoteAction
    global static Churn__c getChurn(String cId){
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
                  			,SCINumber__r.Name
                  			,DonotrenewSupportProducts__c
                  			,DonotrenewZIAProducts__c
                  			,DonotrenewZPAProducts__c
                  			,DowngradingFrom__c
                  			,Type_of_Churn__c
                  			,LossAnalysisCall__c
                  			,DowngradingTo__c,Others__c From Churn__c Where id =: cId];
        if(!churnLst.isEmpty()){
            return churnLst[0];
        }
        else{
            return new Churn__c();
        }
    }

    
    @RemoteAction
    global static String saveForm(String oppId,
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
                                  String primaryComp,
                                  String secondaryComp,
                                  String additionalNotes,
                                  String sciNumber,
                                  String downgradingFrom,
                                  String downgradingTo,
                                  String doNotRenewZIAproduct,
                                  String doNotRenewZPAproduct,
                                  String doNotRenewSupportproduct,
                                  boolean reductionOfSeats,
                                  boolean downgradingBundle,
                                  boolean notRenewedAdvFeaturesCheck,
                                  boolean others,
                                  string othersInput,
                                  boolean isLossCallConducted,
                                  boolean isActivePRpresent){
                                    Churn__c churnObj = new Churn__c();
                try{
                    churnObj.Type__c = 'Churn';
                    Opportunity opp = [SELECT Id,Name,Stagename FROM Opportunity WHERE Id =: oppId LIMIT 1];
                    if(oppId != null){
                        churnObj.Opportunity__c = oppId;
                        /**if(opp.Name.length() > 70){
                            churnObj.Name = opp.Name.substring(0, 70) +'_Churn';
                        }
                        else{
                            churnObj.Name = opp.Name +'_Churn';
                        }**/
                        churnObj.Name__c = opp.Name +'_Churn';
                        if(isActivePRpresent != null){
                            opp.Confirm_Opportunity_Closure__c = isActivePRpresent;
                        }
                    }
                    if(primaryResn != null && primaryResn != 'Please select'){
                        churnObj.TransformationPrimaryReason__c = primaryResn;
                    }
                    if(secondaryResn != null && secondaryResn != 'Please select'){
                        churnObj.TransformationSecondaryReason__c = secondaryResn;
                    }
                    else if(secondaryResn == 'Please select'){
                        churnObj.TransformationSecondaryReason__c = null;
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
                    if(ZPAPrimaryResn != null && ZPAPrimaryResn != 'Please select'){
                        churnObj.ExperienceFeaturesZPAPrimaryReason__c = ZPAPrimaryResn;
                    }
                    if(ZPASecondaryResn != null && ZPASecondaryResn != 'Please select'){
                        churnObj.ExperienceFeaturesZPASecondaryReason__c = ZPASecondaryResn;
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
                    if(ExperienceMissingfunctionality != null){
                        churnObj.ExperienceMissingfunctionality__c = ExperienceMissingfunctionality;
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
                    if(additionalNotes != null){
                        churnObj.AdditionalNotes__c = additionalNotes;
                    }
                    if(sciNumber != null && sciNumber != 'Please select' && sciNumber != ''){
                        churnObj.SCINumber__c = sciNumber;
                    }
                    else{
                        churnObj.SCINumber__c = null;
                    }
                    if(downgradingFrom != null && downgradingFrom != 'Please select'){
                        churnObj.DowngradingFrom__c = downgradingFrom;
                    }
                    else if(downgradingFrom == 'Please select'){
                        churnObj.DowngradingFrom__c = null;
                    }
                    if(downgradingTo != null && downgradingTo != 'Please select'){
                        churnObj.DowngradingTo__c = downgradingTo;
                    }
                    else if(downgradingTo == 'Please select'){
                        churnObj.DowngradingTo__c = null;
                    }
                    if(doNotRenewZIAproduct != null && doNotRenewZIAproduct != 'Please select'){
                        churnObj.DonotrenewZIAProducts__c = doNotRenewZIAproduct;
                    }
                    else{
                        churnObj.DonotrenewZIAProducts__c = null;
                    }
                    if(doNotRenewZPAproduct != null && doNotRenewZPAproduct != 'Please select'){
                        churnObj.DonotrenewZPAProducts__c = doNotRenewZPAproduct;
                    }
                    else{
                        churnObj.DonotrenewZPAProducts__c = null;
                    }
                    if(doNotRenewSupportproduct != null && doNotRenewSupportproduct != 'Please select'){
                        churnObj.DonotrenewSupportProducts__c = doNotRenewSupportproduct;
                    }
                    else{
                        churnObj.DonotrenewSupportProducts__c = null;
                    }
                    if(churnId != null && churnId != ''){
                        churnObj.Id = churnId;
                    }
                    
                    
                    
                    //boolean reductionOfSeats,
                    //boolean downgradingBundle,
                    //boolean notRenewedAdvFeaturesCheck,
                    //boolean others
                    
                    Set<String> churnTypes = new Set<String>();
                    if(reductionOfSeats){
                        churnTypes.add('Reduction in Seats');
                    }
                    if(downgradingBundle){
                        churnTypes.add('Downgrading to a Lower Bundle');
                    }
                    if(notRenewedAdvFeaturesCheck){
                        churnTypes.add('Did not Renew Advanced features');
                    }
                    if(others){
                        churnTypes.add('Other (If other, state reason)');
                    }
                    if(othersInput != null && othersInput != ''){
                       churnObj.Others__c =  othersInput;
                    }
                    
                    churnObj.Type_of_Churn__c = '';
                    for(string churnType : churnTypes){
                        if(churnObj.Type_of_Churn__c != ''){
                            churnObj.Type_of_Churn__c = churnObj.Type_of_Churn__c + ';' + churnType;
                        }
                        else{
                            churnObj.Type_of_Churn__c = churnType;
                        }
                    }
                    Id RecordTypeIdChurn = Schema.SObjectType.Churn__c.getRecordTypeInfosByName().get('Renewals').getRecordTypeId();
                    churnObj.RecordTypeId = RecordTypeIdChurn;
                    if(isLossCallConducted){
                        churnObj.LossAnalysisCall__c = true;
                    } 
                    else{
                        churnObj.LossAnalysisCall__c = false;
                    }
                    update opp;
                    upsert churnObj;
                    if(churnId != null && churnId != ''){
                        return churnId;
                    }
                    else{
                        return opp.Id;
                    }
                }
                catch(Exception e){
                    ApexPages.addMessages(e);
                    return e.getMessage();
                }
                                      
    }
}