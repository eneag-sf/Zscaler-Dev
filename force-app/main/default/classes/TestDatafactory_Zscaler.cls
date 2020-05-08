public class TestDatafactory_Zscaler{
    public static List<Triggers_Switch__c> gettriggerswitchrecords(Boolean execute){
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        trlst.add(new Triggers_Switch__c(name = 'CloseMilestonesonCaseClose', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Close_Case_FRT', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Account_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CaseComment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Description_to_Comment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Entitlement_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Escalation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_SkillAssignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Status_History', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Case_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Contact_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_ContentDocumentLink_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_CustomerNoteAdded', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessageCDL_to_CaseCDL', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_CaseComment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_EmailMessage_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Escalation_History_Creation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Escalation_Notes_Creation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedComment_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedItem_Internal', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FeedItem_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_FRT_CustomerNoteAdded', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Get_Feedback', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_Manual_SLA', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_User_Skill_Assignment', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Execute_User_Trigger', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'UpdateDetailsonMasterCase', Execute__c = execute));
        trlst.add(new Triggers_Switch__c(name = 'Update_GAM_NAM', Execute__c = execute));
        return trlst;
    }
    public static List<Stage_ForecastCategory_Mapping__c> getstageforecastcategorymap(){
        List<Stage_ForecastCategory_Mapping__c > sfmlst = new List<Stage_ForecastCategory_Mapping__c >();
        /*Stage_ForecastCategory_Mapping__c sfm0 = new Stage_ForecastCategory_Mapping__c(name='Stg0', StageName__c = '0 - Initial Prospecting', Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm0);*/
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm);
        Stage_ForecastCategory_Mapping__c sfm1 = new Stage_ForecastCategory_Mapping__c(name='Stg2', StageName__c = label.Stage_2_Qualified_Budgeted /*'2 - Technical Validation'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm1);
        Stage_ForecastCategory_Mapping__c sfm2 = new Stage_ForecastCategory_Mapping__c(name='Stg3', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'7 - Negotiation & Review'*/, Forecast_Category__c = 'Pipeline');
        sfmlst.add(sfm2);
        //Stage_ForecastCategory_Mapping__c sfm3 = new Stage_ForecastCategory_Mapping__c(name='Stg4', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'8 - Expecting Order'*/, Forecast_Category__c = 'Commit');
        //sfmlst.add(sfm3);
        //Stage_ForecastCategory_Mapping__c sfm4 = new Stage_ForecastCategory_Mapping__c(name='Stg5', StageName__c = '10 - Closed Won', Forecast_Category__c = 'Closed');
        //sfmlst.add(sfm4);
        Stage_ForecastCategory_Mapping__c sfm5 = new Stage_ForecastCategory_Mapping__c(name='Stg6', StageName__c = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/, Forecast_Category__c = 'Closed');
        sfmlst.add(sfm5);
        Stage_ForecastCategory_Mapping__c sfm6 = new Stage_ForecastCategory_Mapping__c(name='Stg7', StageName__c = label.Stage_7_Closed_Lost /*'11 - Closed Lost'*/, Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm6);
        /*Stage_ForecastCategory_Mapping__c sfm7= new Stage_ForecastCategory_Mapping__c(name='Stg8', StageName__c = '12 - Closed With No Decision', Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm7);
        Stage_ForecastCategory_Mapping__c sfm8= new Stage_ForecastCategory_Mapping__c(name='Stg9', StageName__c = '14 - Closed: Delete Duplicate', Forecast_Category__c = 'Omitted');
        sfmlst.add(sfm8);*/
        Stage_ForecastCategory_Mapping__c sfm9 = new Stage_ForecastCategory_Mapping__c(name='Stg10', StageName__c = label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/, Forecast_Category__c = 'Closed');
        sfmlst.add(sfm9);
        return sfmlst;
    }
    
    public static List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skusNSInteg(){
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> trlst = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'Credit_SKUs', SKU_Codes__c = 'Z-Credit;ZCR-Buyback');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'One_Time_SKUs', SKU_Codes__c = 'Z-DAS-0;Z-DAS-1');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'DAS_SKUs', SKU_Codes__c = 'Z-DAS-0;Z-DAS-1');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c tr4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name = 'One_Time_SKU', SKU_Codes__c = 'Z-DAS-0;Z-DAS-1');
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);
        trlst.add(tr4);
        return trlst;
    }
    public static List<Like_to_Like_Asset_Mapping_for_ZSUITE__c> liketolike(){
        List<Like_to_Like_Asset_Mapping_for_ZSUITE__c> trlst = new List<Like_to_Like_Asset_Mapping_for_ZSUITE__c>();
        Like_to_Like_Asset_Mapping_for_ZSUITE__c tr1 = new Like_to_Like_Asset_Mapping_for_ZSUITE__c(name = '1', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS;Z-LOGFEED;ZMAN-WEB-BAND',Asset_SKU_Qty_codes__c = 'ZSUITE-WEBBUS',Proposal_Line_Item_Quantity_SKU_Codes__c='ZIA-BUS-BUNDLE',Proposal_Line_Item_SKU_Codes__c='ZIA-BUS-BUNDLE');
        Like_to_Like_Asset_Mapping_for_ZSUITE__c tr2 = new Like_to_Like_Asset_Mapping_for_ZSUITE__c(name = '2', Asset_SKU_Codes__c = 'ZSC-SIP;ZSUITE-WEBBUS',Asset_SKU_Qty_codes__c = 'ZSUITE-WEBBUS',Proposal_Line_Item_Quantity_SKU_Codes__c='ZIA-BUS-BUNDLE',Proposal_Line_Item_SKU_Codes__c='ZIA-BUS-BUNDLE');
        trlst.add(tr1);
        trlst.add(tr2);
        return trlst;
    }
    public static List<Service_Team_to_Skill_Map__c> getserviceteamtoskill(){
        List<Service_Team_to_Skill_Map__c> trlst = new List<Service_Team_to_Skill_Map__c>();
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'Centracomm', Skill__c = 'Cetercomm'));
        trlst.add(new Service_Team_to_Skill_Map__c(name = 'L2', Skill__c = 'L2;L2Escalated;L2AEscalated;L3Escalated;L2_Placeholder'));
        return trlst;
    }
    public static List<Primary_Secondary_Escalation_Support_Map__c> getprimsecescmap(){
        List<Primary_Secondary_Escalation_Support_Map__c> trlst = new List<Primary_Secondary_Escalation_Support_Map__c>();
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'Centracomm', Escalation_Support__c = '', Primary_Support__c='Centracomm', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'CS', Escalation_Support__c = '', Primary_Support__c='CS', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L1', Escalation_Support__c = '', Primary_Support__c='L1', Secondary_Support__c=''));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L1Escalation', Escalation_Support__c = 'L3Escalated', Primary_Support__c='L2Escalated', Secondary_Support__c='L2AEscalated'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2', Escalation_Support__c = '', Primary_Support__c='L2', Secondary_Support__c='L2-Placeholder'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2A', Escalation_Support__c = '', Primary_Support__c='L2A', Secondary_Support__c='L2'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2AEscalation', Escalation_Support__c = '', Primary_Support__c='L3Escalated', Secondary_Support__c='L3'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L2Escalation', Escalation_Support__c = 'L3Escalated', Primary_Support__c='L2AEscalated', Secondary_Support__c='L2A'));
        trlst.add(new Primary_Secondary_Escalation_Support_Map__c(name = 'L3', Escalation_Support__c = '', Primary_Support__c='L3', Secondary_Support__c='L2A'));
        return trlst;
    }
    public static List<Case_Priority_Score__c> getpriorityscore(){
        List<Case_Priority_Score__c> trlst = new List<Case_Priority_Score__c>();
        trlst.add(new Case_Priority_Score__c(name = 'High (P2)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Low (P4)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Medium (P3)', Score__c = 25));
        trlst.add(new Case_Priority_Score__c(name = 'Urgent (P1)', Score__c = 25));
        return trlst;
    }
    public static List<DEFCON_Case_Score__c> getdefconcasescore(){
        List<DEFCON_Case_Score__c> trlst = new List<DEFCON_Case_Score__c>();
        trlst.add(new DEFCON_Case_Score__c(name = '1', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '2', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '3', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '4', Score__c = 25));
        trlst.add(new DEFCON_Case_Score__c(name = '5', Score__c = 25));
        return trlst;
    }
    public static List<DefaultData__c> getDefaultData(){
        List<DefaultData__c> trlst = new List<DefaultData__c>();
        trlst.add(new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = '0017000000RYGPtAAP', Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning'));
        trlst.add(new DefaultData__c(name = 'SurveyCaseDefaults', Account_Id__c = '0017000000RYGPtAAP', Category__c='DSAT',Priority__c='Medium (P3)',Product__c='', Stage_Status__c='New',Type__c=''));
        return trlst;
    }
}