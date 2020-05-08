public class OpportunityLineItemController{
    Public String opptyrecId{get; set;}
    Public String accrecordId{get; set;}
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    Public Opportunity opptyrec{get {
        if(opptyrecId != null){
        opptyrec = [Select Id, Name,Type,Primary_Partner__c, Product_Type__c, Proposed_Number_of_Users__c, Amount, Total_ZPA_ACV__c, DAS_Package_New__c, Opportunity_ZPA_Manager__c, Opportunity_ZPA_SE__c, SE_Name__c, Owner.Name, /*Primary_Project_Contact_Name__c, Primary_Project_Contact_Email__c, Primary_Project_Contact_Phone__c,*/ Validation_Plan__c, Validation_Report__c, Architecture_Document__c, Summarize_the_Value_to_the_Customer__c, Opportunity_ZPA_Manager__r.Name, Opportunity_ZPA_SE__r.Name, SE_Name__r.Name, DAS_Transition_Comments__c from Opportunity where Id = :opptyrecId];
        }
        return opptyrec;
    } set;}
    Public Account accrecord{get {
        if(accrecordId != null) {
        accrecord = [Select Id, Name, Region__c,Architecture_Workshop_Link__c, Territory_Type__c,CSM_Name_New__c,CSM_Name_New__r.Name, NumberOfEmployees, CSM_CSS_Name_del__c, TAM_Name__c from Account where Id = :accrecordId];
        }
        return accrecord;
    } set;}
    Public List<OpportunityLineItem> olilst{get {
        if(opptyrecId != null){
            olilst = [Select Id,Product2.Name, ProductCode from OpportunityLineItem where OpportunityId = :opptyrecId];
        }
        return olilst;
    }  set;}
    
}