@isTest
public class ForecastingExportExcel_Ctrl_Test{
    static testmethod void test1(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
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
        
        ApexPages.currentPage().getParameters().put('payload',JSON.serialize(req));
        ApexPages.currentPage().getParameters().put('levelminusonetitle','VP');
        ForecastingExportExcel_Ctrl ctrl = new ForecastingExportExcel_Ctrl();

    }

}