public class PerformanceOpportunityReportServiceExt {

    public PerformanceOpportunityReportServiceExt(PerformanceOpportunityReportController controller) {}
    
    @RemoteAction @ReadOnly
    public static OpportunityListResponse GetOpportunityListing(OpportunityListRequest request){
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(request.userId);
        allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(request.userId));

        string strtDateStr = '';
        string endDateStr = '';
        set<string> forecastTypeSet = new set<string>();
        
        set<string> forecasteTypeSet = new set<string>();
        
        if(request.forecastType == 'all'){
            forecasteTypeSet.add('new');
            forecasteTypeSet.add('upsell');
            forecasteTypeSet.add('renewal');
        }else{
            forecasteTypeSet.add(request.forecastType);
        }
        
        set<string> oppForecastSet = new set<string>();
        if(request.Stage == 'All'){
            oppForecastSet.add('Upside');
            oppForecastSet.add('Commit');
            oppForecastSet.add('Pipeline');
            oppForecastSet.add('Closed');
        }
        if(request.Stage == 'Pipeline'){
            oppForecastSet.add('Pipeline');
        }
        
        
        if(request.startDate != null && request.startDate != ''){
            strtDateStr = ' AND closeDate>=' + Datetime.newInstance(integer.valueOf(request.startDate.split('/')[2]), integer.valueOf(request.startDate.split('/')[0]), integer.valueOf(request.startDate.split('/')[1])).format('yyyy-MM-dd');
            
            
        }
        if(request.endDate != null && request.endDate != ''){
            endDateStr = ' AND closeDate<= ' + DateTime.newInstance(integer.valueOf(request.endDate.split('/')[2]), integer.valueOf(request.endDate.split('/')[0]), integer.valueOf(request.endDate.split('/')[1])).format('yyyy-MM-dd');
        }
            
        Integer pageSize = 25;
        String stage = '';
        string ClosedStage = label.Stage_6_Closed_Won;
        string ClosedLostStage = label.Stage_7_Closed_Lost;
        string SubStageClosedWithNoDes = Label.SubStage_Closed_With_No_Decision;
        String SubStringClosedLost = Label.SubStage_Closed_Lost;
        
        if(request.Stage == 'Closed Won'){
            stage = 'AND StageName = :ClosedStage AND  StageName != \'0 - Initial Prospecting\' ';
        }else if(request.Stage == 'Commit'){
            stage = 'AND ForecastCategoryName =\'Commit\'  AND  StageName != \'0 - Initial Prospecting\' ';
        }else if(request.Stage == 'Upside'){
            stage = 'AND ForecastCategoryName =\'Upside\'  AND  StageName != \'0 - Initial Prospecting\' ';
        }else if(request.Stage == 'Lost'){
            stage = 'AND ( StageName = :ClosedLostStage AND (Sub_Stage__c = :SubStageClosedWithNoDes OR Sub_Stage__c = :SubStringClosedLost)) ';
        }else if(request.Stage == 'Pipeline' || request.Stage == 'All'){
            stage = 'AND ForecastCategoryName IN: oppForecastSet AND  StageName != \'0 - Initial Prospecting\' ';
        }
        
        string oppSource ='';
        if(String.isNotBlank(request.source)){
            if(request.source == 'None'){
                oppSource = ' AND Source__c =\'\' ';
            }else{
                oppSource = ' AND Source__c = \''+request.source+'\' ';
            }
        }
        
        String forecastType = '';
        if(String.isNotBlank(request.forecastType) ){
            forecastType = 'AND Forecast_Type__c IN: forecasteTypeSet';
        }
        
        string FiscalQtrStr = '';
        set<string> fiscalQtrSet = new set<string>();
        if(String.isNotBlank(request.FiscalQtr)){
            for(string fiscalQtrs : request.FiscalQtr.split(';')){
                fiscalQtrSet.add(''+fiscalQtrs.substring(0,4)+'-'+fiscalQtrs.substring(4,6));
            }
           // fiscalQtrSet.add(''+request.FiscalQtr.substring(0,4)+'-'+request.FiscalQtr.substring(4,6));
            FiscalQtrStr = ' And Fiscal_Period__c IN: fiscalQtrSet';
        }
        
        
        String sortBy = ' ORDER BY ' + (String.isBlank(request.SortField) ? 'CloseDate' : request.SortField) + ' ';
        String order = request.IsAscendingOrder == true ? 'ASC' : 'DESC NULLS LAST';

        String query = 'SELECT Name, VMO_Play__c, IsWon, StageName, Source__c, LeadSource, Type, OwnerId, Owner.Name, Probability, ForecastCategory, ForecastCategoryName, ExpectedRevenue, CloseDate, Amount, NextStep, Deal_Path__c, (select AccountToId, AccountTo.Name from OpportunityPartnersFrom where IsPrimary=true), (select Current_POC_Phase__c, Type_of_Interaction__c from Executive_Advocacy_Programs__r where Type_of_Interaction__c=\'POC Inline\' order by CreatedDate desc) FROM Opportunity ';
        query += ' WHERE OwnerId IN :allUserIds ';
        query += stage;
        query += forecastType;
        query += FiscalQtrStr;
        query += oppSource;
        query += strtDateStr;
        query += endDateStr;
        query += sortBy;
        query += order;
        system.debug('# query : '+query);
        ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
        oppController.setPageSize(pageSize);

        if(request.PageIndex != null && request.PageIndex > 0)
        {
            oppController.setPageNumber(request.PageIndex);
        }
        OpportunityListResponse response = new OpportunityListResponse();
        response.HasNext = oppController.getHasNext();
        response.HasPrevious = oppController.getHasPrevious();
        response.PageIndex = oppController.getPageNumber();
        response.RecordCount = oppController.getResultSize();
        response.PageCount = response.RecordCount / pageSize + 1;
        
        response.totalOppAmount = 0;
        
        for(Opportunity opp : database.query(query)){
            if(opp.Amount != null){
                response.totalOppAmount += opp.Amount;
            }
            
        }
        
        for(sObject opp : oppController.getRecords()){
            response.Opportunities.add(new OpportunityEntry((Opportunity)opp));
            
        }
        return response;
    }   

    
    public class OpportunityListRequest{
        
        public String UserId { get; set; }
        public String FiscalQtr { get; set; }
        public String Stage { get; set; }
        public String source { get; set; }
        public String startDate { get; set; }
        public String endDate { get; set; }
        
        public String SortField { get; set; }
        public Boolean IsAscendingOrder { get; set; }
        public Integer PageIndex { get; set; }
        public String ForecastType { get; set; }
    }

    public class OpportunityListResponse{
        public OpportunityListResponse(){
            Opportunities = new List<OpportunityEntry>();
        }
        public List<OpportunityEntry> Opportunities { get; set; }
        public Boolean HasNext { get; set; }
        public Boolean HasPrevious { get; set; }
        public Integer PageIndex { get; set; }
        public Integer PageCount { get; set; }
        public Integer RecordCount { get; set; }
        public decimal totalOppAmount {get; set;}
    }

    public class OpportunityEntry{
        public OpportunityEntry(Opportunity opp){
            this.OppId = opp.Id;
            this.OppName = opp.Name;
            this.Amount = opp.Amount;
            this.Stage = opp.StageName;
            this.Probability = opp.Probability;
            this.CloseDate = (opp.CloseDate == null) ? '' : formatDate(opp.CloseDate);
            this.ForecastCategory = opp.ForecastCategoryName;
            this.Type = opp.Type;
            this.NextStep = opp.NextStep;
            this.OwnerId = opp.OwnerId;
            this.OwnerName = opp.Owner.Name;
            this.DealPath = opp.Deal_Path__c;
            this.VMOPlay = opp.VMO_Play__c;
            this.Source = opp.Source__c;
            this.LeadSource = opp.LeadSource;
            if(opp.OpportunityPartnersFrom.size() > 0){
                this.PrimaryPartnerId = opp.OpportunityPartnersFrom[0].AccountToId;
                this.PrimaryPartnerName = opp.OpportunityPartnersFrom[0].AccountTo.Name;
            }
            if(opp.Executive_Advocacy_Programs__r.size() == 1){
                this.PocStatus = opp.Executive_Advocacy_Programs__r[0].Current_POC_Phase__c;
            }else if(opp.Executive_Advocacy_Programs__r.size() > 1){
                for(Significant_Customer_Interaction__c sci : opp.Executive_Advocacy_Programs__r){
                    if(sci.Current_POC_Phase__c != '8-Delivering POC Findings Report To Prospect' && String.isNotBlank(sci.Current_POC_Phase__c)){
                        this.PocStatus = sci.Current_POC_Phase__c;
                    }
                    if(String.isBlank(this.PocStatus) && sci.Current_POC_Phase__c == '8-Delivering POC Findings Report To Prospect'){
                        this.PocStatus = sci.Current_POC_Phase__c;
                    }
                }
            }
            this.Highlight = !opp.IsWon && (Amount == 0 || Amount == null || ForecastCategory == 'Omitted' || (opp.CloseDate != null && opp.CloseDate.daysBetween(Date.today())>0));
        }

        public String OppId { get; set; }
        public String OppName { get; set; }
        public Decimal Amount { get; set; }
        public String Stage { get; set; }
        public Decimal Probability { get; set; }
        public String CloseDate { get; set; }
        public String ForecastCategory { get; set; }
        public String Type { get; set; }
        public String NextStep { get; set; }
        public String OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String PrimaryPartnerId { get; set; }
        public String PrimaryPartnerName { get; set; }
        public String PocStatus { get; set; }
        public String DealPath { get; set; }
        public string VMOPlay {get; set;}
        public string Source {get; set;}
        public string LeadSource {get; set;}
        public Boolean Highlight { get; set; }
        private String formatDate(Date d){
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '/' + day + '/' + d.year();
        }
    }

    
}