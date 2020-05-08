@RestResource(urlMapping='/OPPTYSYNC/*')
global with sharing class OPPTYSYNCTOFED{
    global static Boolean avoidtriggers = false;
    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        Map<String,String> parmap = new Map<String, String>();
        System.debug(req.params);
        System.debug(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8'));
        system.debug(Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')));
        if(req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_leads'){
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                List<Opportunity> opplst = new List<Opportunity>();
                for(Opportunity opp: [Select Id, Stagename, OwnerId, CloseDate, AD_Forecast_Category__c, CRO_Forecast_Category__c, DM_Forecast_Category__c, Forecast_Category__c, VP_Forecast_Category__c, Amount, Proposed_Number_of_Users__c, Expected_Term_Months__c , Product_Type__c, (Select SplitOwnerId, SplitPercentage, AD_Forecast_Category__c, AD_Forecast_Category_Lock__c, Area__c, Channel_Rep__c, CRO_Forecast_Category__c, CRO_Forecast_Category_Lock__c, DM_Forecast_Category__c, DM_Forecast_Category_Lock__c, Forecast_Type__c, Geo__c, Opportunity_Split_Account_Manager__c, Opportunity_Split_Area_Director__c, Opportunity_Split_Channel_Manager__c, Opportunity_Split_Renewal_Director__c, Opportunity_Split_Renewal_Manager__c, Opportunity_Split_Sales_Engineer__c, Opportunity_Split_Territory_Type__c, OTB_Account_Manager__c, OTB_Account_Manager_Override__c, OTB_Channel_Manager_Override__c, OTB_Renewal_Manager_Override__c, OTB_Sales_Engineer_Override__c, Owner_Sales_Terr_Geo__c, Owner_Sales_Territory__c, Customer_Advocate__c, Forecast_Category_New__c, Sales_Territory__c, SE__c, Sales_Terr_SE__c, Split_Type__c, VP_Forecast_Category__c, VP_Forecast_Category_Lock__c, ZPA_Amount__c, ZPA_Split_Percentage__c, Owner_s_Sales_Territory_Name__c, Sales_Territory_Name__c from OpportunitySplits where LastModifiedDate >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and LastModifiedDate <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))) from Opportunity where LastModifiedDate >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and LastModifiedDate <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Is_Federal_Opportunity_Sync__c = true]){
                    opplst.add(opp);
                }
                system.debug(opplst);
                if(!opplst.isEmpty()){
                    result.put('oppresults', JSON.serialize(opplst));
                }
            }
        }
        return result;
    }
    
}