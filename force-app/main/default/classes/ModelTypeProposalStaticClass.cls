/**
 * @File Name          : ModelTypeProposalStaticClass.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/3/2020, 3:00:48 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/3/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public with sharing class ModelTypeProposalStaticClass {

    public string errorMessage;
    public boolean hasError;
    public string selectedModelType;
    public Opportunity oppRecord;
    public ModelTypeProposalStaticClass() {

    }

    public PageReference checkOpportunityReseller(string errorMessage,boolean hasError,string selectedModelType,Opportunity oppRecord){

        if(oppRecord.recordtype.Name == 'Renewal Opportunity'){
            return new PageReference('/apex/ApttusCreateNewQuotePage?id='+ oppRecord.Id);
        }

        List<Opportunity_Partner__c> oppPartnerList = [SELECT Id, 
                                                            Name, 
                                                            Is_Primary__c,
                                                            Opportunity__r.Type,
                                                            Opportunity__r.recordtype.Name , 
                                                            Opportunity__c, 
                                                            Partner_Type__c,
                                                            Account__r.Model_Type_Partner__c 
                                                        FROM Opportunity_Partner__c 
                                                        WHERE Opportunity__c=: oppRecord.Id 
                                                        AND Partner_Type__c = 'Reseller' 
                                                        AND Is_Primary__c = true LIMIT 1];
        
        if(oppPartnerList.isEmpty()){
            hasError = true;
            errorMessage = 'Primary Reseller Partner is required to create Proposal';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage ));
        } else if( oppPartnerList.get(0).Account__r.Model_Type_Partner__c == 'Partner Summit' ) {
            selectedModelType = 'Partner Summit';
            return new PageReference( GeneratePageURL() ); 
        } else if( oppPartnerList.get(0).Account__r.Model_Type_Partner__c == 'Legacy' ) {
            selectedModelType = 'Legacy';
            return new PageReference( GeneratePageURL() ); 
        }

        return null;
    }

        /*
        Check Opportunity Reseller From opportunity Partner
    */
    
    public PageReference createNewQuote(string errorMessage,boolean hasError,string selectedModelType,Opportunity oppRecord) {
       
        if(selectedModelType != null && selectedModelType != '' ) {
           return new PageReference( GeneratePageURL() ); 
        } else {
            errorMessage = 'Please select Model type.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
        return null;
    }

    public String GeneratePageURL() {
        if(oppRecord.Type == 'New Business' || oppRecord.Type == 'Existing Customer (Add On)'){
            return  '/apex/ApttusCreateNewQuotePage?id=' + oppRecord.Id + '&modelType=' + selectedModelType;
        } 

        return  '/apex/ApttusCreateNewQuotePage?id=' + oppRecord.id +'&pricelistid=ZScaler FY2020 Price List&modelType=' + selectedModelType;
       
    }
    
    /**
     * Performs the cancel action
     * @return the next page reference 
     */
    public PageReference doCancel() {
        // navigate to the opportunity 
        return new PageReference('/' + oppRecord.Id);
    }
    
    /*
        Model Type For Proposal
    */
    public List<SelectOption> getModelTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--- Select ---')); 

        Schema.SObjectType s = Schema.getGlobalDescribe().get('Opportunity_Partner__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('Model_Type_Partner__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue() !='Both'){
                options.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel())); 
            }            
        }
        
        return options;
    }
}