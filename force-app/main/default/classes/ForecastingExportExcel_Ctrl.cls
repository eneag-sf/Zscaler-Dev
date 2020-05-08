public class ForecastingExportExcel_Ctrl {
    public List<ZForecastingStatsService.OpportunityEntry> OpplstforExcel{get; set;}
    public String LevelminusoneTitle{get; set;}
    public String viewNotra{get; set;}
    public String daterange{get; set;}
    public Boolean isrepUserLevel {get; set;}
    public Boolean isExecUserLevel {get; set;}
    public Boolean isVPUserLevel {get; set;}
    public Boolean isrenewal{get; set;}
    public Boolean isnewupsell{get; set;}
    public ZForecastingStatsService.ForecastingOppListRequest request{get;set;}
    public ForecastingExportExcel_Ctrl(){
        
        if(ApexPages.currentpage().getparameters().get('payload') != ''){
            request = (ZForecastingStatsService.ForecastingOppListRequest)JSON.deserialize(ApexPages.currentpage().getparameters().get('payload'), ZForecastingStatsService.ForecastingOppListRequest.class);
            isrepUserLevel = request.UserLevel == 'Rep';
            isExecUserLevel = request.UserLevel == 'Exec';
            isVPUserLevel = request.UserLevel == 'VP';
            isrenewal = request.ForecastType == 'Renewal';
            isnewupsell = request.ForecastType == 'new-upsell';
        }
        if(ApexPages.currentpage().getparameters().get('levelminusonetitle') != '' && ApexPages.currentpage().getparameters().get('levelminusonetitle') != null){
            LevelminusoneTitle = ApexPages.currentpage().getparameters().get('levelminusonetitle') + '\'s FC';
        }
        if(ApexPages.currentpage().getparameters().get('viewNotra') != '' && ApexPages.currentpage().getparameters().get('viewNotra') != null){
            viewNotra= ApexPages.currentpage().getparameters().get('viewNotra');
        }
        if(ApexPages.currentpage().getparameters().get('daterange') != '' && ApexPages.currentpage().getparameters().get('daterange') != null){
            daterange= ApexPages.currentpage().getparameters().get('daterange');
        }
        ZForecastingStatsService.ForecastingOppListResponse response = ZForecastingStatsService.GetOpportunityListing(request);
        OpplstforExcel = response.Opportunities;
        
    }
}