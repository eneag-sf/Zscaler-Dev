public class PerformanceOpportunityReportController {
    public string FiscalQtr {get;set;}
    public string currentUserId {get;set;}
    public string type {get;set;}
    public string stage {get;set;}
    public string startDate {get; set;}
    public string endDate {get; set;}
    public string source {get; set;}
    public string forecastType {get; set;}
    
    public PerformanceOpportunityReportController(){
        FiscalQtr = '';
        currentUserId = '';
        stage = '';
        startDate = '';
        endDate = '';
        source = '';
        type = '';
        FiscalQtr =  ApexPages.currentPage().getParameters().get('FiscalQtr');
        currentUserId = ApexPages.currentPage().getParameters().get('UsrId');
        type = ApexPages.currentPage().getParameters().get('ForecastType');
        stage = ApexPages.currentPage().getParameters().get('Category'); 
        startDate = ApexPages.currentPage().getParameters().get('StartDate');
        endDate = ApexPages.currentPage().getParameters().get('EndDate');       
        Source = ApexPages.currentPage().getParameters().get('Source');
    }

}