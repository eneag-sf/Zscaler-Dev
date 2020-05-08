public with sharing class ForecastingStatsService
{

    public ForecastingStatsService(ForecastingController controller) { }
    public ForecastingStatsService(ZForecastingController controller) { }

    @RemoteAction @ReadOnly
    public static ForecastSummary GetForecastSummary(String userId, String fiscalQuarter, String forecastType, String forecastFamily)
    {
        User user;
        List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0)
        {
            ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            ForecastSummary forecastSummary = new ForecastSummary();
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserName = users[0].Name;
            loadRecentForecasts(forecastSummary, userId, qtr, forecastType, forecastFamily);
            loadSummaryNumbers(forecastSummary, userId, qtr, forecastType, forecastFamily);
            return forecastSummary;
        }
        else
        {
            return null;
        }
    }

    @RemoteAction @ReadOnly
    public static ForecastingOppListResponse GetOpportunityListing(ForecastingOppListRequest request)
    {
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(request.userId);
        allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(request.userId, request.forecastFamily));

        ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(request.FiscalQtr);
        Date qtrStartDate = qtr.StartDate;
        Date qtrEndDate = qtr.EndDate;

        Integer pageSize = 25;

        String stage = '';
        if(request.Stage == 'All Open')
        {
            stage = 'AND Opportunity.IsClosed = false AND (not Opportunity.StageName like \'0 %\') ';
        }
        else if(request.Stage == 'Closed Won')
        {
            stage = 'AND Opportunity.IsWon = true and Forecast_Category__c != \'Omitted\' ';
        }
        else if(request.Stage == 'Contracts Complete')
        {
            stage = 'AND Opportunity.StageName = \'5 - Contracts Complete\' ';
        }
        else if(request.Stage == 'Commit')
        {
            stage = 'AND Forecast_Category__c = \'Commit\' ';
        }
        else if(request.Stage == 'Upside')
        {
            stage = 'AND Forecast_Category__c = \'Upside\' ';
        }
        else if(request.Stage == 'Pipeline')
        {
            stage = 'AND Forecast_Category__c = \'Pipeline\' ';
        }
        /*
        else if(request.Stage == 'Bridge Ops')
        {
            stage = 'AND Bridge__c=true ';
        }
        */
        else if(request.Stage == 'Deal Splits'){
            stage = 'AND Opportunity.Split__c=true ';
        }
        else if(request.Stage == 'Pushed Deals')
        {
            stage = 'AND Opportunity.Pushed_deal__c=true ';
        }
        else if(request.Stage == 'Bridge to ML')
        {
            stage = 'AND Deal_Path__c = \'Bridge to ML\' ';
        }

        else if(request.Stage == 'Bridge to BC')
        {
            stage = 'AND Deal_Path__c = \'Bridge to BC\' ';
        }

        else if(request.Stage == 'Closed Lost')
        {
            string ClosedStage = label.Stage_7_Closed_Lost;
            String SubStageClosedLost = label.SubStage_Closed_Lost;
            string SubStageClosedWithNoDes = label.SubStage_Closed_With_No_Decision;
            //stage = 'AND ( Opportunity.StageName like \'11 - Closed Lost\' OR Opportunity.StageName like \'12 - Closed With No Decision\') ';
            stage = 'AND ( Opportunity.StageName like:ClosedStage) AND ( Opportunity.Sub_Stage__c like:SubStageClosedWithNoDes OR Opportunity.Sub_Stage__c like: SubStageClosedLost) ';
        }

        String probability = '';
        if(String.isNotBlank(request.Probability) && request.Probability != 'All')
        {
            probability = 'AND Opportunity.Probability ' + request.Probability + ' ';
        }

        String forecastType = '';
        if(String.isNotBlank(request.forecastType) && request.forecastType != 'all')
        {
            forecastType = 'AND Forecast_Type__c=\'' + request.forecastType + '\' ';
        }

        String forecastFamily = '';
        if (String.isNotBlank(request.forecastFamily) && request.forecastFamily == 'ZPA') {
            forecastFamily = ' AND ((Opportunity.Product_Type__c = \'ZPA\' AND Opportunity.HasOpportunityLineItem = False) OR (Opportunity.Total_ZPA_ACV__c > 0)) ';
        }

        String sortBy = 'ORDER BY ' + (String.isBlank(request.SortField) ? 'Opportunity.CloseDate' : request.SortField) + ' ';
        String order = request.IsAscendingOrder == true ? 'ASC' : 'DESC NULLS LAST';


        String query = 'SELECT Opportunity.Total_ZPA_ACV__c, Amount__c, SplitAmount, ZPA_Amount_For_Sorting__c, ZPA_Amount__c, Opportunity.Product_Type__c, Opportunity.HasOpportunityLineItem, OpportunityId, SplitOwnerId, Forecast_Type__c, Forecast_Category__c, ZPA_RSM__r.Name, SplitOwner.Name, Deal_Path__c FROM OpportunitySplit ';

        System.debug('>>>> qtrStartDate: ' + qtrStartDate);
        System.debug('>>>> qtrEndDate: ' + qtrEndDate);
        System.debug('*** allUserIds: ' + JSON.serialize(allUserIds));
        query += 'WHERE Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate ';

        if (request.forecastFamily == 'ZPA') {
            query += ' AND ZPA_RSM__c IN :allUserIds ';
        } else {
            query += ' AND SplitOwnerId IN :allUserIds ';
        }

        query += stage;
        query += probability;
        query += forecastType;
        query += forecastFamily;
        query += sortBy;
        query += order;

        System.debug('>>>> opty query String: '+query);
        System.debug('>>>> opty query: ' + JSON.serialize(Database.query(query)));
        ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
        oppController.setPageSize(pageSize);

        if(request.PageIndex != null && request.PageIndex > 0)
        {
            oppController.setPageNumber(request.PageIndex);
        }
        ForecastingOppListResponse response = new ForecastingOppListResponse();
        response.HasNext = oppController.getHasNext();
        response.HasPrevious = oppController.getHasPrevious();
        response.PageIndex = oppController.getPageNumber();
        response.RecordCount = oppController.getResultSize();
        response.PageCount = response.RecordCount / pageSize + 1;

        response.totalOppAmount = 0;

        for(OpportunitySplit opp : database.query(query)){
            if(opp.SplitAmount != null){
                if (request.forecastFamily == 'ZPA') {
                    response.totalOppAmount += (opp.Opportunity.Product_Type__c == 'ZPA' && opp.Opportunity.HasOpportunityLineItem != true ? opp.SplitAmount : opp.ZPA_Amount__c);
                } else {
                    response.totalOppAmount += opp.SplitAmount;
                }
            }

        }

        String oppQuery = 'SELECT Name, AccountId, VMO_Play__c, IsWon, Split_Message__c, Subscription_overdue__c, Product_Type__c, HasOpportunityLineItem, StageName, Type, OwnerId, Owner.Name, Probability, ForecastCategory,Sub_Stage__c, FEVA__c, Inline_POC__c, Validation_Stage__c, ForecastCategoryName, ExpectedRevenue, CloseDate, Amount, NextStep, Deal_Path__c, (select AccountToId, AccountTo.Name from OpportunityPartnersFrom where IsPrimary=true), (Select Account__r.Name, Account__c from Opportunity_Partners__r where Is_Primary__c = true and Partner_Type__c = \'Reseller\' LIMIT 1), (select Current_POC_Phase__c, Type_of_Interaction__c from Executive_Advocacy_Programs__r where Type_of_Interaction__c=\'POC Inline\' order by CreatedDate desc) FROM Opportunity ';
        set<id> oppIdSet = new set<Id>();
        Map<Id, Opportunity> opportunityMap = new map<Id, Opportunity>();

        for(sObject opp : oppController.getRecords())
        {
            oppIdSet.add(((OpportunitySplit)Opp).OpportunityId);
            //response.Opportunities.add(new OpportunityEntry((Opportunity)opp));

        }
        oppQuery += 'WHERE ID IN :oppIdSet ';

        if (forecastFamily == 'ZPA') {
            oppQuery += ' AND ((Product_Type__c = \'ZPA\' AND HasOpportunityLineItem = False) OR (Total_ZPA_ACV__c > 0)) ';
        }

        for(Opportunity opp :  database.query(oppQuery)){
            opportunityMap.put(opp.id, opp);
        }

        for(sObject opp : oppController.getRecords()){
            response.Opportunities.add(new OpportunityEntry(opportunityMap.get(((OpportunitySplit)opp).OpportunityId), (OpportunitySplit)opp, request.ForecastFamily, allUserIds, request.userId));
        }
        return response;
    }

    @RemoteAction
    public static void SaveForecast(Id userId, String forecastType, String forecastFamily, ForecastEntry entryValue)
    {
        if(String.isBlank(forecastType) || forecastType == 'all')
        {
            throw new ForecastingException('Please specify the type of your forecast.');
        }

        String week = '';
        String fiscalQtr = entryValue.FYFQ;
        String currentFiscalQtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        if(String.isBlank(fiscalQtr))
        {
            fiscalQtr = currentFiscalQtr;
        }
        CustomForecast__c targetForecast;
        if(fiscalQtr == currentFiscalQtr)
        {
            week = ForecastingService.getLatestForecastWeek(fiscalQtr, forecastFamily);
            if(String.isBlank(week))
            {
                week = (new ForecastingDataModel.WeekInfo()).FormattedString;
            }
            List<CustomForecast__c> existings = [SELECT Id, YYWW__c, Locked__c FROM CustomForecast__c WHERE User__c=:userId and ForecastType__c=:forecastType AND Forecast_Family__c = :forecastFamily and FYFQ__c = :fiscalQtr and YYWW__c!=null ORDER BY YYWW__c DESC LIMIT 1];
            if(existings.size() > 0)
            {
                /*if(existings[0].Locked__c == true)
                {
                    throw new ForecastingException('Forecast is locked. Please switch to next quarter.');
                }*/
                targetForecast = existings[0];
            }
            else
            {
                targetForecast = new CustomForecast__c(User__c = userId, FYFQ__c = fiscalQtr, YYWW__c = week, ForecastType__c = forecastType, Forecast_Family__c = forecastFamily);
            }
        }
        else if(fiscalQtr < currentFiscalQtr)
        {
            //throw new ForecastingException('You can\'t update forecast in the past.');
            List<CustomForecast__c> existings = [SELECT Id, YYWW__c, Locked__c FROM CustomForecast__c WHERE User__c=:userId and ForecastType__c=:forecastType AND Forecast_Family__c = :forecastFamily and FYFQ__c = :fiscalQtr ORDER BY YYWW__c DESC LIMIT 1];
            targetForecast = (existings.size() > 0) ? existings[0] : new CustomForecast__c(User__c = userId, FYFQ__c = fiscalQtr, YYWW__c = week, ForecastType__c = forecastType, Forecast_Family__c = forecastFamily);
        }
        else if(fiscalQtr > currentFiscalQtr)
        {
            List<CustomForecast__c> existings = [SELECT Id, YYWW__c, Locked__c FROM CustomForecast__c WHERE User__c=:userId and ForecastType__c=:forecastType AND Forecast_Family__c = :forecastFamily and FYFQ__c = :fiscalQtr ORDER BY YYWW__c DESC LIMIT 1];
            targetForecast = (existings.size() > 0) ? existings[0] : new CustomForecast__c(User__c = userId, FYFQ__c = fiscalQtr, YYWW__c = week, ForecastType__c = forecastType, Forecast_Family__c = forecastFamily);
        }

        targetForecast.QuarterCommit__c = entryValue.QtrCommit;
        targetForecast.QuarterPipeline__c = entryValue.QtrPipeline;
        targetForecast.QuarterUpside__c = entryValue.QtrUpside;
        targetForecast.Forecast_Family__c = forecastFamily;
        targetForecast.LastEdited__c = DateTime.now();
        try
        {
            upsert targetForecast;
        }
        catch (Exception e)
        {
            throw new ForecastingException('Failed to save forecast. Error message is: ' + e.getMessage());
        }
    }

    /**
     * @description: This exposed method to update opportunity record.
     * @author: SNAP BI
     * @log:
     * 29MAR2018 - Jimmy Li - Added.
     **/
    @RemoteAction
    public static SaveOppListItemResponse updateOpportunityRecord(SaveOppListItemRequest request)
    {
        if( ForecastingService.allowInlineEdting(request) == 'ALLOWED')//ForecastingConfigurationService.getIsAllowOppListInlinEditing())
        {
            return updateOppListItem(request);
        }else
        {
            return new SaveOppListItemResponse(request).setContents(false, new String[] { 'You are not allowed to use the Opportunity Inline Editting, please contact your administrator.' });
        }
    }

    private static void loadRecentForecasts(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr, String forecastType) {
        loadRecentForecasts(forecastSummary, userId, qtr, forecastType, 'ZIA');
    }

    private static void loadRecentForecasts(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, String forecastFamily)
    {
        if(forecastSummary != null)
        {
            forecastSummary.RecentForecasts = new List<ForecastEntry>();
            if(String.isNotBlank(forecastType) && forecastType != 'all')
            {
                for(CustomForecast__c forecast : [SELECT Id, User__c, User__r.Name, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, ForecastType__c, Forecast_Family__c, YYWW__c, FYFQ__c, Locked__c FROM CustomForecast__c WHERE FYFQ__c = :qtr.FormattedString AND User__c = :userId AND ForecastType__c=:forecastType AND Forecast_Family__c =:forecastFamily ORDER BY YYWW__c DESC LIMIT 3])
                {
                    Boolean found = false;
                    for(ForecastEntry entry : forecastSummary.RecentForecasts)
                    {
                        if(entry.YYWW == forecast.YYWW__c)
                        {
                            entry.QtrCommit = forecast.QuarterCommit__c == null ? 0 : forecast.QuarterCommit__c;
                            entry.QtrUpside = forecast.QuarterUpside__c == null ? 0 : forecast.QuarterUpside__c;
                            entry.QtrPipeline = forecast.QuarterPipeline__c == null ? 0 : forecast.QuarterPipeline__c;
                            found = true;
                        }
                    }
                    if(!found)
                    {
                        forecastSummary.RecentForecasts.add(new ForecastEntry(forecast));
                    }
                }
            }
            else
            {
                for(CustomForecast__c forecast : [SELECT Id, User__c, User__r.Name, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, ForecastType__c, Forecast_Family__c, YYWW__c, FYFQ__c, Locked__c FROM CustomForecast__c WHERE FYFQ__c = :qtr.FormattedString AND User__c = :userId AND ForecastType__c!=null AND Forecast_Family__c =:forecastFamily ORDER BY YYWW__c DESC LIMIT 9])
                {
                    Boolean found = false;
                    for(ForecastEntry entry : forecastSummary.RecentForecasts)
                    {
                        if(entry.YYWW == forecast.YYWW__c)
                        {
                            entry.QtrCommit = entry.QtrCommit == null ? 0 : entry.QtrCommit;
                            entry.QtrCommit += forecast.QuarterCommit__c == null ? 0 : forecast.QuarterCommit__c;
                            entry.QtrUpside = entry.QtrUpside == null ? 0 : entry.QtrUpside;
                            entry.QtrUpside += forecast.QuarterUpside__c == null ? 0 : forecast.QuarterUpside__c;
                            entry.QtrPipeline = entry.QtrPipeline == null ? 0 : entry.QtrPipeline;
                            entry.QtrPipeline += forecast.QuarterPipeline__c == null ? 0 : forecast.QuarterPipeline__c;
                            entry.Locked = false;
                            found = true;
                        }
                    }
                    if(!found && forecastSummary.RecentForecasts.size() < 3)
                    {
                        forecastSummary.RecentForecasts.add(new ForecastEntry(forecast));
                    }
                }
            }
            if(forecastSummary.RecentForecasts.size() <= 3)
            {
                for(Integer i = forecastSummary.RecentForecasts.size(); i < 3; i++)
                {
                    forecastSummary.RecentForecasts.add(new ForecastEntry());
                }
            }
        }
    }

    private static void loadSummaryNumbers(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr, String forecastType) {
        loadSummaryNumbers(forecastSummary, userId, qtr, forecastType, 'ZIA');
    }

    private static void loadSummaryNumbers(ForecastSummary forecastSummary, String userId, ForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, String forecastFamily)
    {
        if(forecastSummary != null)
        {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;
            System.debug('>>>> qtrStartDate: ' + qtrStartDate + ', qtrEndDate: ' + qtrEndDate);

            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId, forecastFamily));
            System.debug('>>>> allUserIds: ' + JSON.serialize(allUserIds));

            List<AggregateResult> totalPipeline, totalUpside, totalCommit, totalWon, myCommitResult, myUpsideResult, myPipeResult, myWonResult, mostLikelyResult, bestCaseResult;


            String oppSplitQuery = 'SELECT SplitAmount, ZPA_Amount__c, SplitOwnerId, ZPA_RSM__c, Opportunity.IsClosed, Opportunity.CloseDate, Opportunity.IsWon, Forecast_Category__c, Deal_Path__c, Opportunity.Product_Type__c, Opportunity.HasOpportunityLineItem, Opportunity.Total_ZPA_ACV__c ';
            oppSplitQuery += ' FROM OpportunitySplit ';

            if (forecastFamily == 'ZPA') {
                oppSplitQuery += ' WHERE Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND ZPA_RSM__c IN :allUserIds AND ((Opportunity.Product_Type__c = \'ZPA\' AND Opportunity.HasOpportunityLineItem = False) OR (Opportunity.Total_ZPA_ACV__c > 0)) ';
            } else {
                oppSplitQuery += ' WHERE Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds ';
            }

            if (String.isNotBlank(forecastType) && forecastType != 'all') {
                oppSplitQuery += ' AND Forecast_Type__c = :forecastType';
                System.debug('>>>> forecastType: ' + forecastType);
            }

            forecastSummary.TotalPipeline = 0;
            forecastSummary.TotalUpside = 0;
            forecastSummary.TotalCommit = 0;
            forecastSummary.QTDBooking = 0;
            forecastSummary.MyTotalCommit = 0;
            forecastSummary.MyTotalUpside = 0;
            forecastSummary.MyTotalPipeline = 0;
            forecastSummary.MyQTDBooking = 0;
            System.debug('>>>> oppSplitQuery: ' + oppSplitQuery);
            Decimal bestCaseResultValue = 0.0, mostLikelyResultValue = 0.0;
            for (OpportunitySplit split : Database.query(oppSplitQuery)) {
                if (forecastFamily == 'ZIA'
                    || (forecastFamily == 'ZPA' && split.Opportunity.Product_Type__c == 'ZPA' && split.Opportunity.HasOpportunityLineItem != true)) {
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Pipeline') {
                        forecastSummary.TotalPipeline = (forecastSummary.TotalPipeline != null ? forecastSummary.TotalPipeline + split.SplitAmount : split.SplitAmount);
                    }
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Upside') {
                        forecastSummary.TotalUpside = (forecastSummary.TotalUpside != null ? forecastSummary.TotalUpside + split.SplitAmount : split.SplitAmount);
                    }
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Commit') {
                        forecastSummary.TotalCommit = (forecastSummary.TotalCommit != null ? forecastSummary.TotalCommit + split.SplitAmount : split.SplitAmount);
                    }
                    if (split.Opportunity.IsWon == true && split.Forecast_Category__c == 'Closed') {
                        forecastSummary.QTDBooking = (forecastSummary.QTDBooking != null ? forecastSummary.QTDBooking + split.SplitAmount : split.SplitAmount);
                    }
                    if (split.Deal_Path__c == 'Bridge to BC') {
                        bestCaseResultValue = (bestCaseResultValue != null ? bestCaseResultValue + split.SplitAmount : split.SplitAmount);
                    }
                    if (split.Deal_Path__c == 'Bridge to ML') {
                        mostLikelyResultValue = (mostLikelyResultValue != null ? mostLikelyResultValue + split.SplitAmount : split.SplitAmount);
                    }
                    if (((forecastFamily == 'ZIA' && split.SplitOwnerId == userId) || (forecastFamily == 'ZPA' && split.ZPA_RSM__c == userId))
                        && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Commit') {
                        forecastSummary.MyTotalCommit = (forecastSummary.MyTotalCommit != null ? forecastSummary.MyTotalCommit + split.SplitAmount : split.SplitAmount);
                    }
                    if (((forecastFamily == 'ZIA' && split.SplitOwnerId == userId) || (forecastFamily == 'ZPA' && split.ZPA_RSM__c == userId))
                        && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Upside') {
                        forecastSummary.MyTotalUpside = (forecastSummary.MyTotalUpside != null ? forecastSummary.MyTotalUpside + split.SplitAmount : split.SplitAmount);
                    }
                    if (((forecastFamily == 'ZIA' && split.SplitOwnerId == userId) || (forecastFamily == 'ZPA' && split.ZPA_RSM__c == userId))
                        && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Pipeline') {
                        forecastSummary.MyTotalPipeline = (forecastSummary.MyTotalPipeline != null ? forecastSummary.MyTotalPipeline + split.SplitAmount : split.SplitAmount);
                    }
                    if (((forecastFamily == 'ZIA' && split.SplitOwnerId == userId) || (forecastFamily == 'ZPA' && split.ZPA_RSM__c == userId))
                        && split.Opportunity.IsWon == true && split.Forecast_Category__c == 'Closed') {
                        forecastSummary.MyQTDBooking = (forecastSummary.MyQTDBooking != null ? forecastSummary.MyQTDBooking + split.SplitAmount : split.SplitAmount);
                    }
                } else if (forecastFamily == 'ZPA' && split.Opportunity.Total_ZPA_ACV__c > 0) {
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Pipeline') {
                        forecastSummary.TotalPipeline = (forecastSummary.TotalPipeline != null ? forecastSummary.TotalPipeline + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Upside') {
                        forecastSummary.TotalUpside = (forecastSummary.TotalUpside != null ? forecastSummary.TotalUpside + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Commit') {
                        forecastSummary.TotalCommit = (forecastSummary.TotalCommit != null ? forecastSummary.TotalCommit + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.Opportunity.IsWon == true && split.Forecast_Category__c == 'Closed') {
                        forecastSummary.QTDBooking = (forecastSummary.QTDBooking != null ? forecastSummary.QTDBooking + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.Deal_Path__c == 'Bridge to BC') {
                        bestCaseResultValue = (bestCaseResultValue != null ? bestCaseResultValue + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.Deal_Path__c == 'Bridge to ML') {
                        mostLikelyResultValue = (mostLikelyResultValue != null ? mostLikelyResultValue + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.ZPA_RSM__c == userId && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Commit') {
                        forecastSummary.MyTotalCommit = (forecastSummary.MyTotalCommit != null ? forecastSummary.MyTotalCommit + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.ZPA_RSM__c == userId && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Upside') {
                        System.debug('>>>> ulle po: ' + userId + ' ' + split.ZPA_Amount__c);
                        forecastSummary.MyTotalUpside += split.ZPA_Amount__c; //(forecastSummary.MyTotalUpside != null ? forecastSummary.MyTotalUpside + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.ZPA_RSM__c == userId && split.Opportunity.IsClosed == false && split.Forecast_Category__c == 'Pipeline') {
                        forecastSummary.MyTotalPipeline = (forecastSummary.MyTotalPipeline != null ? forecastSummary.MyTotalPipeline + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                    if (split.ZPA_RSM__c == userId && split.Opportunity.IsWon == true && split.Forecast_Category__c == 'Closed') {
                        forecastSummary.MyQTDBooking = (forecastSummary.MyQTDBooking != null ? forecastSummary.MyQTDBooking + split.ZPA_Amount__c : split.ZPA_Amount__c);
                    }
                }
            }
            System.debug('>>>> forecastSummary: ' + JSON.serialize(forecastSummary));

            // String query = 'SELECT '; //SplitAmount, ZPA_Amount__c, Opportunity.IsClosed, Opportunity.CloseDate, Opportunity.IsWon, ';
            // if (forecastFamily == 'ZPA') {
            //     query += 'SUM(ZPA_Amount__c) a';
            // } else {
            //     query += 'SUM(SplitAmount) a';
            // }
            //
            // query += ' FROM OpportunitySplit ';
            //
            // if (forecastFamily == 'ZPA') {
            //     query += ' WHERE ((Opportunity.Product_Type__c = \'ZPA\' AND Opportunity.HasOpportunityLineItem = False) OR (Opportunity.Total_ZPA_ACV__c > 0)) AND ';
            // } else {
            //     query += ' WHERE ';
            // }
            //
            // if(String.isNotBlank(forecastType) && forecastType != 'all')
            // {
            //     totalPipeline = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\' and Forecast_Type__c =: forecastType'); //[SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c='Pipeline' and Forecast_Type__c =: forecastType ];
            //
            //     totalUpside = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\' and Forecast_Type__c =: forecastType');
            //
            //     totalCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\' and Forecast_Type__c = : forecastType');
            //
            //
            //     totalWon = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsWon = true and Forecast_Type__c =: forecastType  and Forecast_Category__c=\'Closed\'');
            //
            //     bestCaseResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Forecast_Type__c =: forecastType AND Deal_Path__c = \'Bridge to BC\'');
            //
            //     mostLikelyResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Forecast_Type__c =: forecastType AND Deal_Path__c = \'Bridge to ML\'');
            //
            //     myWonResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsWon = true and Forecast_Type__c =: forecastType and Forecast_Category__c=\'Closed\'');
            //
            //     myCommitResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\' and Forecast_Type__c =: forecastType');
            //
            //     myUpsideResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\' and Forecast_Type__c =: forecastType');
            //
            //     myPipeResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\' and Forecast_Type__c =: forecastType');
            //
            //     /*
            //     totalPipeline = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Pipeline' and Forecast_Type__c=:forecastType];
            //     totalUpside = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Upside' and Forecast_Type__c=:forecastType];
            //     totalCommit = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Commit' and Forecast_Type__c=:forecastType];
            //     totalWon = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsWon = true and Forecast_Type__c=:forecastType and ForecastCategoryName='Closed'];
            //     bestCaseResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND Forecast_Type__c=:forecastType  AND Deal_Path__c = 'Bridge to BC'];
            //     mostLikelyResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND Forecast_Type__c=:forecastType  AND Deal_Path__c = 'Bridge to ML'];
            //
            //     myWonResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsWon = true and Forecast_Type__c=:forecastType and ForecastCategoryName='Closed'];
            //     myCommitResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Commit' and Forecast_Type__c=:forecastType];
            //     myUpsideResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Upside' and Forecast_Type__c=:forecastType];
            //     myPipeResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Pipeline' and Forecast_Type__c=:forecastType];
            //     */
            // }
            // else
            // {
            //     totalPipeline = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\'');
            //
            //     totalUpside = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\'');
            //
            //     totalCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\'');
            //
            //
            //     totalWon = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Opportunity.IsWon = true and Forecast_Category__c=\'Closed\'');
            //
            //     bestCaseResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Deal_Path__c = \'Bridge to BC\'');
            //
            //     mostLikelyResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId IN :allUserIds AND Deal_Path__c = \'Bridge to ML\'');
            //
            //     myWonResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsWon = true and Forecast_Category__c=\'Closed\'');
            //
            //     myCommitResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\'');
            //
            //     myUpsideResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\'');
            //
            //     myPipeResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\'');
            //
            //     /*
            //     totalPipeline = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Pipeline'];
            //     totalUpside = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Upside'];
            //     totalCommit = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsClosed = false and ForecastCategoryName='Commit'];
            //     totalWon = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds AND IsWon = true and ForecastCategoryName='Closed'];
            //     bestCaseResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds  AND Deal_Path__c = 'Bridge to BC'];
            //     mostLikelyResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId IN :allUserIds  AND Deal_Path__c = 'Bridge to ML'];
            //
            //
            //
            //     myWonResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsWon = true and ForecastCategoryName='Closed'];
            //     myCommitResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Commit'];
            //     myUpsideResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Upside'];
            //     myPipeResult = [SELECT SUM(Amount) a FROM Opportunity WHERE CloseDate <= :qtrEndDate AND CloseDate >= :qtrStartDate AND OwnerId=:userId AND IsClosed = false and ForecastCategoryName='Pipeline'];
            //     */
            // }
            // // forecastSummary.TotalPipeline = totalPipeline[0].get('a') == null ? 0 : (Decimal)totalPipeline[0].get('a');
            // // forecastSummary.TotalUpside = totalUpside[0].get('a') == null ? 0 : (Decimal)totalUpside[0].get('a');
            // // forecastSummary.TotalCommit = totalCommit[0].get('a') == null ? 0 : (Decimal)totalCommit[0].get('a');
            // // forecastSummary.QTDBooking = totalWon[0].get('a') == null ? 0 : (Decimal)totalWon[0].get('a');
            // // forecastSummary.MyTotalCommit = (Decimal)myCommitResult[0].get('a');
            // // forecastSummary.MyTotalUpside = (Decimal)myUpsideResult[0].get('a');
            // // forecastSummary.MyTotalPipeline = (Decimal)myPipeResult[0].get('a');
            // // forecastSummary.MyQTDBooking = (Decimal)myWonResult[0].get('a');


            decimal mostLikely = 0;
            decimal bestCase = 0;
            for(ForecastEntry entry : forecastSummary.RecentForecasts){
                if(entry.QtrCommit != null){
                    mostLikely = entry.QtrCommit;
                    break;
                }
            }
            for(ForecastEntry entry : forecastSummary.RecentForecasts){
                if(entry.QtrUpside != null){
                    bestCase = entry.QtrUpside;
                    break;
                }
            }

            // forecastSummary.MostLikelyGap = forecastSummary.QTDBooking + forecastSummary.TotalCommit + (mostLikelyResult[0].get('a') == null ? 0 : (Decimal)mostLikelyResult[0].get('a')) - mostLikely;
            forecastSummary.MostLikelyGap = forecastSummary.QTDBooking + forecastSummary.TotalCommit + (mostLikelyResultValue == null ? 0 : mostLikelyResultValue) - mostLikely;

            // forecastSummary.BestCaseGap  = forecastSummary.QTDBooking + forecastSummary.TotalCommit + (mostLikelyResult[0].get('a') == null ? 0 : (Decimal)mostLikelyResult[0].get('a')) +(bestCaseResult[0].get('a') == null ? 0 : (Decimal)bestCaseResult[0].get('a')) - bestCase;
            forecastSummary.BestCaseGap  = forecastSummary.QTDBooking + forecastSummary.TotalCommit + (mostLikelyResultValue == null ? 0 : mostLikelyResultValue) +(bestCaseResultValue == null ? 0 : bestCaseResultValue) - bestCase;

            if(String.isNotBlank(forecastType) && forecastType != 'all')
            {
                List<SalesQuota__c> quota = [select QuotaAmount__c from SalesQuota__c where User__c=:userId and ForecastType__c=:forecastType AND Forecast_Family__c =:forecastFamily AND Forecast_Family__c =: forecastFamily and FYFQ__c=:fiscalQtr limit 1];
                if(quota.size() > 0)
                {
                    forecastSummary.QTRQuota = quota[0].QuotaAmount__c;
                }
            }
            else
            {
                List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND Forecast_Family__c =:forecastFamily AND Forecast_Family__c =: forecastFamily and FYFQ__c=:fiscalQtr];
                if(quota.size() > 0)
                {
                    forecastSummary.QTRQuota = (Decimal)quota[0].get('q');
                }
            }
        }
    }

    /**
     * @description: updates method to update opportunity from request
     * @author: SNAP BI
     * @log:
     * 29MAR2018 - Jimmy Li - Added.
     **/
    @testVisible
    private static SaveOppListItemResponse updateOppListItem(SaveOppListItemRequest request)
    {
        SaveOppListItemResponse oppSaveResponse = new SaveOppListItemResponse(request);

        Opportunity oppToSave = new Opportunity();
        OpportunitySplit oppSplit = new OpportunitySplit();
        Map<String, Schema.SObjectField> fieldDescribes = Schema.SObjectType.Opportunity.fields.getMap();
        System.debug('-- into opportunity save --');
        System.debug(request);
        OpportunityEntry entry = request.oppListItem;

        oppToSave = entry.toOpportunity();
        oppSplit = entry.toOpportunitySplit();

        System.debug(oppToSave);
        System.debug(oppSplit);

        List<OpportunitySplit> recalculatedSplits;
        if(entry.SplitAmountStamp != entry.Amount)
        {
            System.debug('Amount: '+entry.Amount+', splitAmountStamp: '+entry.SplitAmountStamp);
            Decimal alteredSplitAmt = entry.Amount - entry.SplitAmountStamp;
            oppToSave.Amount = entry.OppAmountStamp + alteredSplitAmt;
            System.debug('oppToSave.Amount: '+oppToSave.Amount);
            List<OpportunitySplit> splits = [select SplitAmount, SplitPercentage from OpportunitySplit where OpportunityId = :oppToSave.Id];
            recalculatedSplits = recalculateAcmounts(splits, entry.Amount, oppToSave.Amount, oppSplit);
        }

        //Integer partnerExistsCount = [select count() from Partner where OpportunityId = :oppToSave.Id and AccountToId = :entry.PrimaryPartnerId];
        OpportunityPartnerHelper partnerHelper = new OpportunityPartnerHelper();
        
        entry.PrimaryPartnerId = String.isBlank(entry.PrimaryPartnerId)?null:entry.PrimaryPartnerId;
        
        List<Partner> relatedPartners = partnerHelper.getRelatedPartners(oppToSave.Id, oppToSave.AccountId, entry.PrimaryPartnerId);

        /*for(Partner p : [select Id, OpportunityId, AccountToId from Partner where OpportunityId = :oppToSave.Id and AccountToId != :oppToSave.AccountId])
        {
            p.Id = null;
            p.isPrimary = false;

            if(p.AccountToId == entry.PrimaryPartnerId){
                containsInPrimary = true;
                p.isPrimary = true;
            }
            relatedPartners.add(p);
        }*/

        if(partnerHelper.containsInPrimary == false && String.isNotBlank(entry.PrimaryPartnerId) )
        {
            //return oppSaveResponse.setContents(false, new List<String>{ 'Selected partner account is not a exitis opportunity partner' });
            //If not exitis as a partner, add to the list & mark as primary
            relatedPartners.add(new Partner(AccountToId = entry.PrimaryPartnerId, OpportunityId = oppToSave.Id, isPrimary=true));
            partnerHelper.containsInPrimary = true;
        }

        SavePoint sp = Database.setSavepoint();

        try
        {
            update oppToSave;

            if(recalculatedSplits != null && recalculatedSplits.size() > 0)
            {
                update recalculatedSplits;
            }else
            {
                update oppSplit;
            }

            /*if(partnerHelper.containsInPrimary)
            {
                delete [select Id from Partner where OpportunityId = :oppToSave.Id];
                insert relatedPartners;
            }*/
            
            partnerHelper.insertPartners(oppToSave.Id, relatedPartners);

            return oppSaveResponse.setContents(true, new List<String>());
        }catch(Exception e)
        {
            System.debug(e.getLineNumber());
            Database.rollback(sp);
            return oppSaveResponse.setContents(false, new List<String>{ e.getMessage(), e.getStackTraceString() });
        }
    }

    public static List<OpportunitySplit> recalculateAcmounts(List<OpportunitySplit> splits, Decimal alteredSplitAmt, Decimal alteredOppAmt, OpportunitySplit alteredSplit)
    {
        if(splits != null && splits.size() > 0)
        {
            Map<Id, OpportunitySplit> splitsMap = new Map<Id, OpportunitySplit>();
            if(alteredOppAmt != 0)
            {
                Decimal totalPercent = 0;
                for(OpportunitySplit split : splits)
                {

                    if(alteredSplit.Id == split.Id)
                    {
                        split.SplitPercentage = alteredSplitAmt / alteredOppAmt;
                        alteredSplit.SplitPercentage = split.SplitPercentage;
                        split = alteredSplit;
                    }else{
                        split.SplitPercentage = split.SplitAmount / alteredOppAmt;
                    }
                    split.SplitPercentage = (split.SplitPercentage * 100).setScale(2, RoundingMode.HALF_DOWN);
                    totalPercent += split.SplitPercentage;
                    splitsMap.put(split.Id, split);
                    System.debug('Percent: '+split.SplitPercentage);
                }
                if(totalPercent != 100){
                    splitsMap.get(alteredSplit.Id).SplitPercentage += (100 - totalPercent);
                }
            }
            return splitsMap.values();
        }else
        {
            return null;
        }
    }

    public class ForecastSummary
    {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public List<ForecastEntry> RecentForecasts { get; set; }
        public Decimal QTDBooking { get; set; }
        public Decimal TotalCommit { get; set; }
        public Decimal TotalUpside { get; set; }
        public Decimal TotalPipeline { get; set; }
        public Decimal QTRQuota { get; set; }

        public Decimal MyTotalCommit { get; set; }
        public Decimal MyTotalUpside { get; set; }
        public Decimal MyTotalPipeline { get; set; }
        public Decimal MyQTDBooking { get; set; }

        public Decimal MostLikelyGap { get; set; }
        public Decimal BestCaseGap { get; set; }


        public ForecastSummary()
        {
            RecentForecasts = new List<ForecastEntry>();
        }
    }

    public class ForecastEntry
    {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public Decimal QtrCommit { get; set; }
        public Decimal QtrUpside { get; set; }
        public Decimal QtrPipeline { get; set; }
        public String FYFQ { get; set; }
        public String YYWW { get; set; }
        public Boolean Locked { get; set; }
        public String ForecastFamily { get; set; }

        public ForecastEntry()
        {
            Locked = false;
        }

        public ForecastEntry(CustomForecast__c forecast)
        {
            UserId = forecast.User__c;
            UserName = forecast.User__r.Name;
            QtrCommit = forecast.QuarterCommit__c;
            QtrUpside= forecast.QuarterUpside__c;
            QtrPipeline = forecast.QuarterPipeline__c;
            FYFQ = forecast.FYFQ__c;
            YYWW = forecast.YYWW__c;
            Locked = forecast.Locked__c;
            ForecastFamily = forecast.Forecast_Family__c;
        }
    }

    public class ForecastingOppListRequest
    {
        public String UserId { get; set; }
        public String FiscalQtr { get; set; }
        public String Stage { get; set; }
        public String Probability { get; set; }
        public String SortField { get; set; }
        public Boolean IsAscendingOrder { get; set; }
        public Integer PageIndex { get; set; }
        public String ForecastType { get; set; }
        public String ForecastFamily { get; set; }
    }

    public class ForecastingOppListResponse
    {
        public ForecastingOppListResponse()
        {
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

    public class OpportunityEntry
    {
        public OpportunityEntry() { }

        public OpportunityEntry(Opportunity opp,OpportunitySplit oppSplit, String ForecastFamily)
        {
            this.OppId = opp.Id;
            this.SplitId = oppSplit.Id;
            this.OppName = opp.Name;
            this.OppAmountStamp = opp.Amount;
            this.Amount = (ForecastFamily == 'ZPA' ? (opp.Product_Type__c == 'ZPA' && opp.HasOpportunityLineItem != true ? oppSplit.SplitAmount : oppSplit.ZPA_Amount__c) : oppSplit.SplitAmount);
            this.SplitAmountStamp = this.Amount;
            this.Stage = opp.StageName;
            this.RecordEditable = String.isBlank(opp.StageName)?false:(opp.StageName.contains('Contracts Complete') || opp.StageName.contains('Closed Won') || opp.isWon == true)?false:true;
            this.Probability = opp.Probability;
            this.CloseDate = (opp.CloseDate == null) ? '' : formatDate(opp.CloseDate);
            this.ForecastCategory = oppSplit.Forecast_Category__c;// opp.ForecastCategoryName;// original is: oppSplit.Forecast_Category__c
            this.Type = opp.Type;
            this.NextStep = opp.NextStep;
            this.OwnerId = oppSplit.SplitOwnerId;
            this.OwnerName = (ForecastFamily == 'ZPA' ? oppSplit.ZPA_RSM__r.Name : oppSplit.SplitOwner.Name);
            this.DealPath = oppSplit.Deal_Path__c;
            this.VMOPlay = opp.VMO_Play__c;
            this.SplitMessage = opp.Split_Message__c;
            //if(opp.OpportunityPartnersFrom.size() > 0)
            //{
                //this.PrimaryPartnerId = opp.OpportunityPartnersFrom[0].AccountToId;
                //this.PrimaryPartnerName = opp.OpportunityPartnersFrom[0].AccountTo.Name;
            //}
            //Changed to Custom Object
            if(opp.Opportunity_Partners__r.size() > 0)
            {
                this.PrimaryPartnerId = opp.Opportunity_Partners__r[0].Account__c;
                this.PrimaryPartnerName = opp.Opportunity_Partners__r[0].Account__r.Name;
            }
            this.PocStatus = opp.Validation_Stage__c;
            //Updated at 09APR2018 by Jimmy Li - to seperate the stage value for Inline Editing Values Inlitial Mapping
            if(opp.Inline_POC__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatusPreffix = 'Inline POC ';
            }else if (opp.FEVA__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatusPreffix = 'FEVA ';
            }else if(opp.Validation_Stage__c != null && opp.Validation_Stage__c != ''){
                this.PocStatusPreffix = '';
            }
            if(String.isNotBlank(opp.AccountId))
            {
                this.AccountId = opp.AccountId;
            }
            this.AmountEditable = !opp.HasOpportunityLineItem;
            /*

            if(opp.Inline_POC__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatus = 'Inline POC ' + opp.Validation_Stage__c;
            }else if (opp.FEVA__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatus = 'FEVA ' + opp.Validation_Stage__c;
            }else{

                if(opp.Executive_Advocacy_Programs__r.size() == 1){
                    this.PocStatus = opp.Executive_Advocacy_Programs__r[0].Current_POC_Phase__c;
                }else if(opp.Executive_Advocacy_Programs__r.size() > 1){
                    for(Significant_Customer_Interaction__c sci : opp.Executive_Advocacy_Programs__r)
                    {
                        if(sci.Current_POC_Phase__c != '8-Delivering POC Findings Report To Prospect' && String.isNotBlank(sci.Current_POC_Phase__c))
                        {
                            this.PocStatus = sci.Current_POC_Phase__c;
                        }
                        if(String.isBlank(this.PocStatus) && sci.Current_POC_Phase__c == '8-Delivering POC Findings Report To Prospect')
                        {
                            this.PocStatus = sci.Current_POC_Phase__c;
                        }
                    }
                }

            }
            */

            this.Highlight = !opp.IsWon && ((Amount == 0 || Amount == null || ForecastCategory == 'Omitted' || (opp.CloseDate != null && opp.CloseDate.daysBetween(Date.today())>0)) || opp.Subscription_overdue__c);
        }
        
        // Added at 09MAR2018 Jimmy Li - To indicate that if this opportunity owned by a memeber of the team
        public OpportunityEntry(Opportunity opp,OpportunitySplit oppSplit, String ForecastFamily, List<Id> teamUserIds, String viewingUserId)
        {
            this(opp, oppSplit, ForecastFamily);
            this.RecordEditable = ( this.RecordEditable && teamUserIds.contains(opp.OwnerId));
            this.OwnedByViewingUser = (viewingUserId == opp.OwnerId)?true:false;
            //System.debug(viewingUserId +' - '+ opp.OwnerId);
        }

        public String OppId { get; set; }
        public String OppName { get; set; }
        public String Stage { get; set; }
        public String CloseDate { get; set; }
        public String ForecastCategory { get; set; }
        public String Type { get; set; }
        public String NextStep { get; set; }
        public String OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String PrimaryPartnerId { get; set; }
        public String PrimaryPartnerName { get; set; }
        public String PocStatus { get; set; }
        public String PocStatusPreffix { get; set; }
        public String DealPath { get; set; }
        public string VMOPlay {get; set;}
        public string SplitMessage {get; set;}
        public String SplitId { get; set; } // Added at 30MAR2018
        public String AccountId { get; set; } // Added at 30MAR2018
        public Boolean Highlight { get; set; }
        public Boolean RecordEditable { get; set; } //Added at 30MAR2018
        public Boolean AmountEditable { get; set; } //Added at 30MAR2018
        public Boolean OwnedByViewingUser { get; set; } //Added at 10APR2018
        public Decimal Amount { get; set; }
        public Decimal Probability { get; set; }
        public Decimal SplitAmountStamp { get; set; } //Added at 02/04/2018
        public Decimal OppAmountStamp { get; set; } //Added at 02/04/2018

        private String formatDate(Date d)
        {
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '/' + day + '/' + d.year();
        }

        //Converts to SObjects for saving
        public Opportunity toOpportunity()
        {
            Opportunity opp = new Opportunity();
            opp.Id = String.isNotBlank(this.OppId)?(Id)this.OppId:null;
            opp.AccountId = String.isNotBlank(this.AccountId)?(Id)this.AccountId:null;
            opp.Name = this.OppName;
            opp.StageName = this.Stage;
            if(this.RecordEditable == true && this.OwnedByViewingUser == true)
            {
                opp.ForecastCategoryName = this.ForecastCategory;
            }
            if( 'Upside'.equalsIgnoreCase(this.ForecastCategory) ){
                opp.Deal_Path__c = this.DealPath;
            }
            opp.CloseDate = Date.valueOf(this.CloseDate);
            opp.NextStep = this.NextStep;
            return opp;
        }

        public OpportunitySplit toOpportunitySplit()
        {
            OpportunitySplit split = new OpportunitySplit();
            split.Id = String.isNotBlank(this.SplitId)?(Id)this.SplitId:null;
            split.Deal_Path__c = this.DealPath;
            return split;
        }
    }

    /**
    * @description: Requests Wrapper Class of Opportunity Item for Opportunity Inline Editting Feature
    * @author: SNAP BI
    * @log:
    * 29MAR2018 - Jimmy Li - Added.
    **/
    public class SaveOppListItemRequest
    {
        public OpportunityEntry oppListItem { get; set; }
        public Map<String, Object> params { get; set; }
    }
    /**
    * @description: Response Wrapper Class of Opportunity Item for Opportunity Inline Editting Feature
    * @author: SNAP BI
    * @log:
    * 29MAR2018 - Jimmy Li - Added.
    **/
    public class SaveOppListItemResponse
    {
        public OpportunityEntry oppListItem { get; set; }
        public Boolean status { get; set; }
        public String[] messages { get; set; }

        public SaveOppListItemResponse()
        {
            this.oppListItem = new OpportunityEntry();
            this.status = false;
            this.messages = new String[]{};
        }

        public SaveOppListItemResponse(SaveOppListItemRequest request)
        {
            this();
            this.oppListItem = request.oppListItem;
        }

        public SaveOppListItemResponse setContents(Boolean flag, String[] msgs)
        {
            this.status = flag;
            this.messages = msgs;
            return this;
        }
    }

    public class SelectOptionWrapper
    {
        public String label { get; set; }
        public String value { get; set; }
        public Boolean isDefault { get; set; }

        public SelectOptionWrapper()
        {
            this.label = '';
            this.value = '';
            this.isDefault = false;
        }

        public SelectOptionWrapper(SelectOption option)
        {
            this();
            this.label = option.getLabel();
            this.value = option.getValue();
        }

        public SelectOptionWrapper(Schema.PicklistEntry entry)
        {
            this();
            this.label = entry.getLabel();
            this.value = entry.getValue();
            this.isDefault = entry.isDefaultValue();
        }
    }
    
    public without sharing class OpportunityPartnerHelper
    {
        public OpportunityPartnerHelper()
        {
            this.containsInPrimary = false;
        }
        
        public Boolean containsInPrimary { get; set; }
        
        public List<Partner> getRelatedPartners(Id oppId, Id oppActId, Id primaryActId)
        {
            List<Partner> relatedPartners = new List<Partner>();
            
            for(Partner p : [select Id, OpportunityId, AccountToId from Partner where OpportunityId = :oppId and AccountToId != :oppActId])
            {
                p.Id = null;
                p.isPrimary = false;
                
                if(p.AccountToId == primaryActId){
                    this.containsInPrimary = true;
                    p.isPrimary = true;
                }
                relatedPartners.add(p);
            }
            
            return relatedPartners;
        }
        
        public void insertPartners(Id oppId, List<Partner> partners)
        {
            if(this.containsInPrimary)
            {
                delete [select Id from Partner where OpportunityId = :oppId];
                insert partners;
            }
        }
    }
}