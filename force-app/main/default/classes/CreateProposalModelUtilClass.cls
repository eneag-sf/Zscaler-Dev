/**
 * @File Name          : CreateProposalModelUtilClass.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/3/2020, 7:12:51 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    9/3/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class CreateProposalModelUtilClass {

    public static String checkOpportunityReseller(string selectedModelType,Opportunity oppRecord){
        String returnMessage;
        if(oppRecord.recordtype.Name == 'Renewal Opportunity'){
            system.debug('==recordtype.Name == Renewal Opportunity');
            returnMessage = '/apex/ApttusCreateNewQuotePage?id='+ oppRecord.Id;
            return returnMessage;
        }else{

            List<Opportunity_Partner__c> oppPartnerList = [SELECT Id, 
                                                                Name, 
                                                                Is_Primary__c,
                                                                Opportunity__r.Type,
                                                                Opportunity__r.recordtype.Name , 
                                                                Opportunity__c, 
                                                                Partner_Type__c,
                                                                Partner_Program__c 
                                                            FROM Opportunity_Partner__c 
                                                            WHERE Opportunity__c=: oppRecord.Id 
                                                            AND Partner_Type__c = 'Reseller' 
                                                            AND Is_Primary__c = true LIMIT 1];
            
            if(oppPartnerList.isEmpty()){
                returnMessage = 'error';
                system.debug('==returnMessage = error');
                return returnMessage;
            } else if( oppPartnerList.get(0).Partner_Program__c == 'Partner Summit' || oppPartnerList.get(0).Partner_Program__c == 'Legacy') {
                returnMessage = GeneratePageURL(oppRecord, oppPartnerList.get(0).Partner_Program__c);
                system.debug('==Partner_Program__c=='+oppPartnerList.get(0).Partner_Program__c);
                return returnMessage; 
            }
            else if(oppPartnerList.get(0).Partner_Program__c == 'Both' || oppPartnerList.get(0).Partner_Program__c == null || oppPartnerList.get(0).Partner_Program__c == ''){
                returnMessage = GeneratePageURL(oppRecord, oppPartnerList.get(0).Partner_Program__c);
                //returnMessage = 'Show Model';
                system.debug('==both/null=='+oppPartnerList.get(0).Partner_Program__c);
                return returnMessage;
            } 
        }
        system.debug('==oppPartnerListisEmpty'); 
        return returnMessage;
    }

    public static String createNewQuote(string selectedModelType,Opportunity oppRecord) {
        system.debug('=== in createNewQuote selectedModelType');
        if(selectedModelType != null && selectedModelType != '' ) {
            system.debug('===createNewQuote selectedModelType not null'+selectedModelType);
            return GeneratePageURL(oppRecord,selectedModelType); 
        } /*else {
            errorMessage = 'Please select Model type.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }*/
        system.debug('===createNewQuote selectedModelType null=');
        return null; 
    }

    public static String GeneratePageURL(Opportunity opp,String selectedModelType) {
        if(opp.Type == 'New Business' || opp.Type == 'Existing Customer (Add On)'){
            return  '/apex/ApttusCreateNewQuotePage?id=' + opp.Id + '&modelType=' + selectedModelType;
        } 

        return  '/apex/ApttusCreateNewQuotePage?id=' + opp.id +'&pricelistid=ZScaler FY2020 Price List&modelType=' + selectedModelType;
       
    }

    /*
        Model Type For Proposal
    */
    public static List<SelectOption> getModelTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '', '--- Select ---')); 

        Schema.SObjectType s = Schema.getGlobalDescribe().get('Opportunity_Partner__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('Partner_Program__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue() !='Both'){
                options.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel())); 
            }            
        }
        
        return options;
    }
}