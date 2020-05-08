@istest
public class ZForecastingStatsService_Test{
    @isTest
    static void testZForecastingStatsService()
    {
        
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        //ZForecastingStatsService.GetForecastSummary(userId, 'VP', 'Exec', qtr, 'All', false, 'ZIA');

        /*ZForecastingStatsService.SelectOptionWrapper optionWrapper = new ZForecastingStatsService.SelectOptionWrapper(new SelectOption('label','value'));*/
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.showzpa = false;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'All Open'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
        
    }
    @isTest
    static void testZForecastingStatsService_Test1()
    {   
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'Commit'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.showzpa = false;
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);

        Test.stopTest();
    }
    
    @isTest
    static void testZForecastingStatsService_Test2()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'Pipeline'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.showzpa = false;
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);

        Test.stopTest();
    }
    
    @isTest
    static void testZForecastingStatsService_Test3()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'Best Case'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.showzpa = false;
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
    }
    
    @isTest
    static void testZForecastingStatsService_Test4()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'Most Likely'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.showzpa = false;
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
    }
    
    @isTest
    static void testZForecastingStatsService_Test5()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'BC Forecast'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        req.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
    }
    
    @isTest
    static void testZForecastingStatsService_Test6()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'ML Forecast'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        req.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testZForecastingStatsService_Test7()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'WC Forecast'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'$100K - $250K'};
        req.ClosingMonth = new List<String>{'M2'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'This'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        req.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req);
        
        Test.stopTest();
    }
    @isTest
    static void testZForecastingStatsService_Test8()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ZForecastingStatsService.GetForecastSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        ZForecastingStatsService.getForecastSummaryZPA(userId, 'Exec', 'VP' , qtr, 'New', 'ZIA');
        
        test.starttest();
        
        ZForecastingStatsService.ForecastingOppListRequest req2 = new ZForecastingStatsService.ForecastingOppListRequest();
        req2.UserId = userId;
        req2.FiscalQtr = qtr;
        req2.Stage = new List<String>{'Closed Lost'};
        req2.Probability = '> 10';
        req2.forecastFamily = 'ZIA';
        req2.DealValue = new List<String>();
        req2.ClosingMonth = new List<String>();
        req2.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req2.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req2.ClosingWeek = new List<String>();
        req2.Geo = new List<String>();
        req2.Region = new List<String>();
        req2.customersuccessstage  = new List<String>();
        req2.CustomerSentiment  = new List<String>();
        req2.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req2);

        test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService1()
    {
        test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        //ZForecastingStatsService.GetForecastSummary(userId, 'Director', 'VP', qtr, 'All', false, 'ZIA');

        /*ZForecastingStatsService.SelectOptionWrapper optionWrapper = new ZForecastingStatsService.SelectOptionWrapper(new SelectOption('label','value'));*/

        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'All Open'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>();
        req.ClosingMonth = new List<String>();
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>();
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        req.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req);

        ZForecastingStatsService.ForecastingOppListRequest req2 = new ZForecastingStatsService.ForecastingOppListRequest();
        req2.UserId = userId;
        req2.FiscalQtr = qtr;
        req2.Stage = new List<String>{'Closed Lost'};
        req2.Probability = '> 10';
        req2.forecastFamily = 'ZIA';
        req2.DealValue = new List<String>();
        req2.ClosingMonth = new List<String>();
        req2.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req2.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req2.ClosingWeek = new List<String>();
        req2.Geo = new List<String>();
        req2.Region = new List<String>();
        req2.customersuccessstage  = new List<String>();
        req2.CustomerSentiment  = new List<String>();
        req2.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req2);


        test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService2()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        test.starttest();
        ZForecastingStatsService.GetForecastSummary(userId, 'Manager','Director', qtr, 'New', false, 'ZIA');

        /*ZForecastingStatsService.SelectOptionWrapper optionWrapper = new ZForecastingStatsService.SelectOptionWrapper(new SelectOption('label','value'));*/

        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'All Open'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>();
        req.ClosingMonth = new List<String>();
        req.ClosingWeek = new List<String>();
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        req.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req);

        ZForecastingStatsService.ForecastingOppListRequest req2 = new ZForecastingStatsService.ForecastingOppListRequest();
        req2.UserId = userId;
        req2.FiscalQtr = qtr;
        req2.Stage = new List<String>{'Closed Lost'};
        req2.Probability = '> 10';
        req2.forecastFamily = 'ZIA';
        req2.DealValue = new List<String>();
        req2.ClosingMonth = new List<String>();
        req2.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req2.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req2.ClosingWeek = new List<String>();
        req2.Geo = new List<String>();
        req2.Region = new List<String>();
        req2.customersuccessstage  = new List<String>();
        req2.CustomerSentiment  = new List<String>();
        req2.showzpa = false;
        ZForecastingStatsService.GetOpportunityListing(req2);


        test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService3()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        test.starttest();
        ZForecastingStatsService.GetForecastSummary(userId, 'Rep','Manager', qtr, 'New', false, 'ZIA');

        /*ZForecastingStatsService.SelectOptionWrapper optionWrapper = new ZForecastingStatsService.SelectOptionWrapper(new SelectOption('label','value'));*/

        ZForecastingStatsService.ForecastingOppListRequest req = new ZForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = new List<String>{'All Open'};
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        req.DealValue = new List<String>{'> $1M'};
        req.ClosingMonth = new List<String>{'M3'};
        req.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req.ClosingWeek = new List<String>{'Previous'};
        req.Geo = new List<String>();
        req.Region = new List<String>();
        req.showzpa = false;
        req.customersuccessstage  = new List<String>();
        req.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req);

        ZForecastingStatsService.ForecastingOppListRequest req2 = new ZForecastingStatsService.ForecastingOppListRequest();
        req2.UserId = userId;
        req2.FiscalQtr = qtr;
        req2.Stage = new List<String>{'Closed Lost'};
        req2.Probability = '> 10';
        req2.forecastFamily = 'ZIA';
        req2.DealValue = new List<String>();
        req2.ClosingMonth = new List<String>();
        req2.ContractEndDateMonth = new List<String>{'M1','M2','M3'};
        req2.NOTRAFilter = new List<String>{'on time','late','prior early','future'};
        req2.ClosingWeek = new List<String>();
        req2.Geo = new List<String>();
        req2.Region = new List<String>();
        req2.showzpa = false;
        req2.customersuccessstage  = new List<String>();
        req2.CustomerSentiment  = new List<String>();
        ZForecastingStatsService.GetOpportunityListing(req2);


        test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService5()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;


        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;
        test.starttest();
        ZForecastingStatsService.SaveForecast(userId, qtr, 'New', 'ZIA', 492.2829, false, 'abcsdfned', fc.Id);
        ZForecastingStatsService.SaveForecastWeeklyComments(userId, qtr, 'New', 'ZIA', 'abcsdfned', fc.Id);
        ZForecastingStatsService.SaveYonYGrowth(userId, qtr, 'New', 'ZIA',0.0);
        try{
        ZForecastingStatsService.SaveForecast(userId, qtr, 'new-upsell', 'ZIA', 492.2829, false, 'abcsdfned', fc.Id);
        }catch(Exception ex){
        }
        test.stoptest();
    }

    @isTest
    static void testZForecastingStatsService6()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;
        OpportunitySplit oppsplit = [Select Id, SplitAmount,Forecast_Category_New__c, DM_Forecast_Category__c, AD_Forecast_Category__c, VP_Forecast_Category__c,CRO_Forecast_Category__c, SplitOwnerId, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c, Forecast_Type__c, CRO_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c,AD_Forecast_Category_Lock__c, DM_Forecast_Category_Lock__c, Owner_s_Sales_Territory_Name__c, Owner_Sales_Territory__r.Name, Owner_Sales_Territory__r.Area__c, Owner_Sales_Terr_Geo__c, SE__r.Name, Sales_Territory__r.Region__c from OpportunitySplit limit 1];

        ZForecastingStatsService.ZForecastSummary forecastSummary = new ZForecastingStatsService.ZForecastSummary();
        forecastSummary.UserName = Userinfo.getusername();
        forecastSummary.UserId = Userinfo.getuserId();
        forecastSummary.UserLevel = 'Exec';
        forecastSummary.MyUserLevel = 'VP';


        try{
        ZForecastingStatsService.getMyForecast(forecastSummary, userId, qtr, 'all', allUserIds,'ZIA');
        }catch(Exception ex){

        }
        Set<Id> upselplaceholderusers = new Set<Id>();
        upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        Date nextWeekStartDay = Date.today();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ZForecastingStatsService.OpportunityEntry oectrl =  new ZForecastingStatsService.OpportunityEntry(opp, oppsplit, 'ZIA', 'CRO_Forecast_Category__c', false, upselplaceholderusers );
        oectrl.CloseDate = oectrl.CloseDate.split('/')[2] + '-' + oectrl.CloseDate.split('/')[0] + '-' + oectrl.CloseDate.split('/')[1] + ' ' + '00:00:00';
        oectrl.Amount = 27992.289;
        oectrl.SplitAmountStamp = 7992.289;
        oectrl.OppAmountStamp  = 2992.289;
        oectrl.RecordEditable  = true;
        oectrl.oppType  = 'New';
        ZForecastingStatsService.SaveOppListItemRequest ctrlsr = new ZForecastingStatsService.SaveOppListItemRequest();
        ctrlsr.oppListItem = oectrl;
        ctrlsr.params = new Map<String, Object>();
        ctrlsr.params.put('ForecastFamily', 'ZIA');
        ctrlsr.params.put('UserId', userId);
        ctrlsr.params.put('FiscalQtr', currentQuarter.FormattedString);
        test.starttest();
        ZForecastingStatsService.updateOpportunityRecord(ctrlsr);
        ZForecastingStatsService.DealSupportSummary ctrl1 = new ZForecastingStatsService.DealSupportSummary ();
        ZForecastingStatsService.DealSupportSummaryEntry ctrl2 = new ZForecastingStatsService.DealSupportSummaryEntry  ();
        system.debug(ctrl1.UserId);
        system.debug(ctrl1.UserName );
        system.debug(ctrl1.MostLikelySummaryEntries );
        system.debug(ctrl1.BestCaseSummaryEntries );
        system.debug(ctrl1.WorstCaseSummaryEntries );
        system.debug(ctrl1.QTDClosedSummaryEntries  );
        system.debug(ctrl2.Amount   );
        system.debug(ctrl2.FYFQ   );

        system.debug(ctrl2.YYWW   );
        try{
        ZForecastingStatsService.SelectOptionWrapper ctrl100 = new ZForecastingStatsService.SelectOptionWrapper((SelectOption)null);
        }catch(Exception ex){

        }
        test.stoptest();


        }
    }
    @isTest
    static void testZForecastingStatsService7()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;
        OpportunitySplit oppsplit = [Select Id, SplitAmount,Forecast_Category_New__c, DM_Forecast_Category__c, AD_Forecast_Category__c, VP_Forecast_Category__c,CRO_Forecast_Category__c, SplitOwnerId, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c, Forecast_Type__c, CRO_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c,AD_Forecast_Category_Lock__c, DM_Forecast_Category_Lock__c, Owner_s_Sales_Territory_Name__c, Owner_Sales_Territory__r.Name, Owner_Sales_Territory__r.Area__c, Owner_Sales_Terr_Geo__c, SE__r.Name, Sales_Territory__r.Region__c from OpportunitySplit limit 1];
        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;
        ZForecastingStatsService.ZForecastSummary forecastSummary = new ZForecastingStatsService.ZForecastSummary();
        forecastSummary.UserName = Userinfo.getusername();
        forecastSummary.UserId = Userinfo.getuserId();
        forecastSummary.UserLevel = 'Exec';
        forecastSummary.MyUserLevel = 'VP';


        try{
        ZForecastingStatsService.getMyForecast(forecastSummary, userId, qtr, 'all', allUserIds,'ZIA');
        }catch(Exception ex){

        }

        try{
        ZForecastingStatsService.getNOTRASummary(userId, qtr, 'Exec');
        //ZForecastingStatsService.getDealChurnSummary(userId, qtr, 'Exec');
        }catch(Exception ex){

        }
        Set<Id> upselplaceholderusers = new Set<Id>();
        upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        Date nextWeekStartDay = Date.today();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ZForecastingStatsService.OpportunityEntry oectrl =  new ZForecastingStatsService.OpportunityEntry(opp, oppsplit, 'ZIA', 'CRO_Forecast_Category__c', false, upselplaceholderusers);
        oectrl.CloseDate = oectrl.CloseDate.split('/')[2] + '-' + oectrl.CloseDate.split('/')[0] + '-' + oectrl.CloseDate.split('/')[1] + ' ' + '00:00:00';
        oectrl.Amount = 27992.289;
        oectrl.SplitAmountStamp = 7992.289;
        oectrl.OppAmountStamp  = 2992.289;
        oectrl.RecordEditable  = true;
        oectrl.oppType  = 'New';
        ZForecastingStatsService.SaveOppListItemRequest ctrlsr = new ZForecastingStatsService.SaveOppListItemRequest();
        ctrlsr.oppListItem = oectrl;
        ctrlsr.params = new Map<String, Object>();
        ctrlsr.params.put('ForecastFamily', 'ZIA');
        ctrlsr.params.put('UserId', userId);
        ctrlsr.params.put('FiscalQtr', currentQuarter.FormattedString);
        test.starttest();
        ZForecastingStatsService.updateOpportunityRecord(ctrlsr);
        ZForecastingStatsService.DealSupportSummary ctrl1 = new ZForecastingStatsService.DealSupportSummary ();
        ZForecastingStatsService.DealSupportSummaryEntry ctrl2 = new ZForecastingStatsService.DealSupportSummaryEntry  ();
        system.debug(ctrl1.UserId);
        system.debug(ctrl1.UserName );
        system.debug(ctrl1.MostLikelySummaryEntries );
        system.debug(ctrl1.BestCaseSummaryEntries );
        system.debug(ctrl1.WorstCaseSummaryEntries );
        system.debug(ctrl1.QTDClosedSummaryEntries  );
        system.debug(ctrl2.Amount   );
        system.debug(ctrl2.FYFQ   );

        system.debug(ctrl2.YYWW   );
        try{
        ZForecastingStatsService.SelectOptionWrapper ctrl100 = new ZForecastingStatsService.SelectOptionWrapper((SelectOption)null);
        }catch(Exception ex){

        }
        test.stoptest();


        }
    }

    @isTest
    static void testZForecastingStatsService8()
    {
         test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;
        OpportunitySplit oppsplit = [Select Id, SplitAmount,Forecast_Category_New__c, DM_Forecast_Category__c, AD_Forecast_Category__c, VP_Forecast_Category__c,CRO_Forecast_Category__c, SplitOwnerId, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c, Forecast_Type__c, CRO_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c,AD_Forecast_Category_Lock__c, DM_Forecast_Category_Lock__c from OpportunitySplit limit 1];

        ZForecastingStatsService.ZForecastSummary forecastSummary = new ZForecastingStatsService.ZForecastSummary();
        forecastSummary.UserName = Userinfo.getusername();
        forecastSummary.UserId = Userinfo.getuserId();
        forecastSummary.UserLevel = 'Exec';
        forecastSummary.MyUserLevel = 'VP';


        try{
        ZForecastingStatsService.getMyForecast(forecastSummary, userId, qtr, 'new-upsell', allUserIds,'ZIA');
        }catch(Exception ex){

        }

        }
         test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService9()
    {   
        test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;
        OpportunitySplit oppsplit = [Select Id, SplitAmount,Forecast_Category_New__c, DM_Forecast_Category__c, AD_Forecast_Category__c, VP_Forecast_Category__c,CRO_Forecast_Category__c, SplitOwnerId, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c, Forecast_Type__c, CRO_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c,AD_Forecast_Category_Lock__c, DM_Forecast_Category_Lock__c from OpportunitySplit limit 1];
        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;
        ZForecastingStatsService.ZForecastSummary forecastSummary = new ZForecastingStatsService.ZForecastSummary();
        forecastSummary.UserName = Userinfo.getusername();
        forecastSummary.UserId = Userinfo.getuserId();
        forecastSummary.UserLevel = 'Exec';
        forecastSummary.MyUserLevel = 'VP';


        try{
        ZForecastingStatsService.getMyForecast(forecastSummary, userId, qtr, 'new-upsell', allUserIds,'ZIA');
        }catch(Exception ex){

        }
    
    }
     test.stoptest();
    }
    @isTest
    static void testZForecastingStatsService10()
    {   
        test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'Exec');
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
   
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        List<Opportunity> Opplst = new List<Opportunity>();
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today()));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today()));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().adddays(-10)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().adddays(-12)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().adddays(7)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().adddays(7)));
        insert Opplst;
        Linearity_Snapshot__c fc = new Linearity_Snapshot__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Amount__c = 3423);
        insert fc;

        try{
            ZForecastingStatsService.getWeeklyForecastSummary(userId, qtr, 'New', 'Exec', false,'ZIA');
            ZForecastingStatsService.getWeeklyForecastSummary(userId, qtr, 'new-upsell', 'VP', false,'ZIA');
            ZForecastingStatsService.getWeeklyForecastSummary(userId, qtr, 'New', 'Director', true,'ZIA');
            ZForecastingStatsService.getWeeklyForecastSummary(userId, qtr, 'New', 'Manager', true,'ZIA');
        }catch(Exception ex){

        }
    test.stoptest();

    }
    }

    @isTest
    static void testZForecastingStatsServicemonforecast()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'Exec');
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        List<Opportunity> Opplst = new List<Opportunity>();
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today()));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today()));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().addmonths(-3)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().addmonths(-4)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().addmonths(2)));
        Opplst.add(new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, Type = 'New Business', CloseDate=Date.today().addmonths(1)));
        insert Opplst;
        Linearity_Snapshot__c fc = new Linearity_Snapshot__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Amount__c = 3423);
        insert fc;

        try{
            ZForecastingStatsService.getMonthlyForecastSummary(userId, qtr, 'New', 'Exec', false,'ZIA');
            ZForecastingStatsService.getMonthlyForecastSummary(userId, qtr, 'new-upsell', 'VP', false,'ZIA');
            ZForecastingStatsService.getMonthlyForecastSummary(userId, qtr, 'All', 'Director', true,'ZIA');
            ZForecastingStatsService.getMonthlyForecastSummary(userId, qtr, 'New', 'Manager', true,'ZIA');
        }catch(Exception ex){

        }

    }
    }

    @isTest
    static void testGetNotraSummary()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
            insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
            insert TestDatafactory_Zscaler.getstageforecastcategorymap();

            String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
            String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
            ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
            insert newSetting;

            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

            Id renewalRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
            Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today(), RecordTypeId=renewalRTId, Type='Existing Customer (Renewal)', Contract_End_Date_New__c=Date.today(), Forecast_Category__c = 'Closed');
            insert opp;
            Opportunity opp1 = new Opportunity(Name='acme1', StageName=label.Stage_4_Economic_Buyer_Signoff /* 8- Expecting Order */, CloseDate=Date.today(), RecordTypeId=renewalRTId, Type='Existing Customer (Renewal)', Contract_End_Date_New__c=Date.today() - 95, Forecast_Category__c = 'Commit');
            insert opp1;
            Opportunity opp2 = new Opportunity(Name='acme2', StageName=label.Stage_4_Economic_Buyer_Signoff /* 8- Expecting Order */, CloseDate=Date.today(), RecordTypeId=renewalRTId, Type='Existing Customer (Renewal)', Contract_End_Date_New__c=Date.today() + 95, Forecast_Category__c = 'Commit');
            insert opp2;
            OpportunitySplit oppsplit = [Select Id, SplitAmount,Forecast_Category_New__c, DM_Forecast_Category__c, AD_Forecast_Category__c, VP_Forecast_Category__c,CRO_Forecast_Category__c, SplitOwnerId, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c, Forecast_Type__c, CRO_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c,AD_Forecast_Category_Lock__c, DM_Forecast_Category_Lock__c from OpportunitySplit limit 1];

            ZForecastingStatsService.ZForecastSummary forecastSummary = new ZForecastingStatsService.ZForecastSummary();
            forecastSummary.UserName = Userinfo.getusername();
            forecastSummary.UserId = Userinfo.getuserId();
            forecastSummary.UserLevel = 'Exec';
            forecastSummary.MyUserLevel = 'VP';


            try{
            ZForecastingStatsService.getMyForecast(forecastSummary, userId, qtr, 'all', allUserIds,'ZIA');
            }catch(Exception ex){

            }
        }
    }
    
    @isTest
    static void testBillings()
    {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;

        Id userId = usr.Id;

        system.runas(new User(Id = UserInfo.getUserId())){
            insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
            insert TestDatafactory_Zscaler.getstageforecastcategorymap();

            String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
            String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
            ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
            insert newSetting;

            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

            Zscaler_Billings_Summary__c rec1 = new Zscaler_Billings_Summary__c(Type__c = 'greater than 1 year', FYFQ__c = qtr);
            Zscaler_Billings_Summary__c rec2 = new Zscaler_Billings_Summary__c(Type__c = 'less than 1 year', FYFQ__c = qtr);
            Zscaler_Billings_Summary__c rec3 = new Zscaler_Billings_Summary__c(Type__c = 'annual', FYFQ__c = qtr);
            Zscaler_Billings_Summary__c[] listbs = new List<Zscaler_Billings_Summary__c>();
            listbs.add(rec1);
            listbs.add(rec2);
            listbs.add(rec3);
            insert listbs;

            ZForecastingStatsService.BillingsSummary  forecastSummary = new ZForecastingStatsService.BillingsSummary ();
            forecastSummary.fyfq = qtr;


            try{
                ZForecastingStatsService.getBillingsSummary(qtr);
            }catch(Exception ex){

            }
            try{
                ZForecastingStatsService.SaveBillingsSummary(qtr,forecastSummary);
            }catch(Exception ex){

            }
            try{
                ZForecastingStatsService.saveNotraComments(userId, qtr,'VP','abc');
            }catch(Exception ex){

            }
            try{
                
                ZForecastingStatsService.saveRenewalAdjustment(userId, qtr,'VP',20);
            }catch(Exception ex){

            }
        }
    }
    
    @isTest
    static void testZForecastingStatsService_savenotra()
    {
        test.starttest();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff, CloseDate=Date.today());
        insert opp;

        Zscaler_Forecast__c fc = new Zscaler_Forecast__c(User__c=userId, Forecast_Type__c ='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;
        try{
        ZForecastingStatsService.getACVForecastBillings(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA');
        }catch(Exception ex){
            
        }
        try{
        ZForecastingStatsService.getNetNewACVSummary(userId, 'Exec', 'VP' , qtr, 'New', true, 'ZIA', true);
        }catch(Exception ex){
            
        }
        

        test.stoptest();
    }
}