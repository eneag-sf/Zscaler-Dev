public with sharing class ZForecastingStatsService {
    Public static String LoggedInUserLocale
    {
        get
        {
            ZForecastingDataModel.UserInfo LoggedInUserInfo = ZForecastingService.GetUser(UserInfo.getUserId());
            return LoggedInUserInfo.UserLocale;
            
        }
    }
    
    public ZForecastingStatsService(ZForecastingController controller) {
    }

    @RemoteAction @ReadOnly
    public static ZForecastSummary getForecastSummary(String userId, String currentUserLevel, String myUserLevel, String fiscalQuarter, String forecastType, Boolean includeSubordinates, String forecastFamily) {
        ZForecastSummary forecastSummary = new ZForecastSummary();
        User user;
        List<User> users = [SELECT Id, Name, UserRoleId, Level__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0) {
            ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            ZForecastingDataModel.WeekInfo week = new ZForecastingDataModel.WeekInfo();
            forecastSummary.UserName = users[0].Name;
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserLevel = currentUserLevel;
            forecastSummary.MyUserLevel = myUserLevel;

            // Query all subordinate users
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

            getDealSupportSummary(forecastSummary, userId, qtr, forecastType, includeSubordinates, allUserIds);
            getMyForecast(forecastSummary, userId, qtr.FormattedString, forecastType, allUserIds, forecastFamily);
            getPreviousWeekSummary(forecastSummary, userId, qtr, forecastType);
            getMyTopLevelDealSupportSummary(forecastSummary, userId, qtr, forecastType, allUserIds);
            if (forecastSummary.UserLevel != 'Rep') {
                getRSMDealSupportSummary(forecastSummary, userId, qtr, forecastType, allUserIds);
            }
            if (forecastSummary.MyUserLevel != 'Rep' && forecastSummary.MyUserLevel != 'Manager') {
                getLevelMinusOneDealSupportSummary(forecastSummary, userId, qtr, forecastType, allUserIds);
            }
            getSummaryNumbers(forecastSummary, userId, qtr, forecastType, includeSubordinates, 'ZIA', allUserIds);
        }

        return forecastSummary;
    }

    @RemoteAction @ReadOnly
    public static void getSummaryNumbers(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, Boolean includeSubordinates, String forecastFamily, List<Id> lstUserIds) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;
            System.debug('>>>> qtrStartDate: ' + qtrStartDate + ', qtrEndDate: ' + qtrEndDate);

            List<Id> allUserIds = new List<Id>();
            if (includeSubordinates == true) {
                allUserIds.addAll(lstUserIds);
            } else {
                allUserIds.add(userId);
            }

            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }
            System.debug('>>>> includeSubordinates: ' + includeSubordinates + ' allUserIds: ' + JSON.serialize(allUserIds));

            List<AggregateResult> totalPipeline, totalUpside, totalCommit, totalWon, myCommitResult, myUpsideResult, myPipeResult, myWonResult, totalBestCase, totalMostLikely, totalWorstCase;

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' Forecast_Type__c =: forecastType AND ';
            }else if(forecastType != null && forecastType == 'new-upsell'){
                query += ' Forecast_Type__c in :forcasttypeset AND ';
            } else {
                query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
            }

            String forecastSummaryField = 'Forecast_Category_New__c';
            if (forecastSummary.UserLevel != 'Rep') {
                if (forecastSummary.UserLevel == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                }  else if (forecastSummary.UserLevel == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }

            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Closed\', \'Commit\')');

            totalPipeline = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and ' +forecastSummaryField + ' =\'Pipeline\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\'');

            totalUpside = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and ' +forecastSummaryField + ' =\'Upside\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\'');

            totalCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and  ' +forecastSummaryField + ' =\'Commit\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\'');


            totalWon = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsWon = true and  ' +forecastSummaryField + ' =\'Closed\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Opportunity.IsWon = true and Forecast_Category__c=\'Closed\'');

            // bestCaseResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Deal_Path__c = \'Bridge to BC\'');
            //
            // mostLikelyResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND Deal_Path__c = \'Bridge to ML\'');

            myWonResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId =:userId OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId =:userId)) AND Opportunity.IsWon = true and  ' +forecastSummaryField + ' =\'Closed\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsWon = true and Forecast_Category__c=\'Closed\'');

            myCommitResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId =:userId OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId =:userId)) AND Opportunity.IsClosed = false and  ' +forecastSummaryField + ' =\'Commit\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Commit\'');

            myUpsideResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId =:userId OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId =:userId)) AND Opportunity.IsClosed = false and  ' +forecastSummaryField + ' =\'Upside\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Upside\'');

            myPipeResult = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId =:userId OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId =:userId)) AND Opportunity.IsClosed = false and  ' +forecastSummaryField + ' =\'Pipeline\'');//Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND SplitOwnerId=:userId AND Opportunity.IsClosed = false and Forecast_Category__c=\'Pipeline\'');
            //}
            forecastSummary.TotalPipeline = totalPipeline[0].get('a') == null ? 0 : (Decimal)totalPipeline[0].get('a');
            forecastSummary.TotalUpside = totalUpside[0].get('a') == null ? 0 : (Decimal)totalUpside[0].get('a');
            forecastSummary.TotalCommit = totalCommit[0].get('a') == null ? 0 : (Decimal)totalCommit[0].get('a');
            forecastSummary.TotalQTDBooking = totalWon[0].get('a') == null ? 0 : (Decimal)totalWon[0].get('a');
            forecastSummary.MyTotalCommit = (Decimal)myCommitResult[0].get('a');
            forecastSummary.MyTotalUpside = (Decimal)myUpsideResult[0].get('a');
            forecastSummary.MyTotalPipeline = (Decimal)myPipeResult[0].get('a');
            forecastSummary.MyQTDBooking = (Decimal)myWonResult[0].get('a');
            forecastSummary.TotalMostLikely = (Decimal)totalMostLikely[0].get('a');
            forecastSummary.TotalBestCase = (Decimal)totalBestCase[0].get('a');

            if(String.isNotBlank(forecastType) && forecastType != 'all' && forecastType != 'new-upsell')
            {
                List<SalesQuota__c> quota = [select QuotaAmount__c from SalesQuota__c where User__c=:userId and ForecastType__c=:forecastType AND FYFQ__c=:fiscalQtr AND Forecast_Family__c = 'ZIA' limit 1];
                if(quota.size() > 0)
                {
                    forecastSummary.QTRQuota = quota[0].QuotaAmount__c;
                }
            }
            else if(String.isNotBlank(forecastType) && forecastType == 'all')
            {
                List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND FYFQ__c=:fiscalQtr AND Forecast_Family__c = 'ZIA' AND ForecastType__c IN ('New', 'Upsell', 'Renewal')];
                if(quota.size() > 0)
                {
                    forecastSummary.QTRQuota = (Decimal)quota[0].get('q');
                }
            }else{
                List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND FYFQ__c=:fiscalQtr and ForecastType__c in :forcasttypeset AND Forecast_Family__c = 'ZIA'];
                if(quota.size() > 0)
                {
                    forecastSummary.QTRQuota = (Decimal)quota[0].get('q');
                }
            }
        }
    }

    @RemoteAction @ReadOnly
    public static void getMyForecast(ZForecastSummary forecastSummary, String userId, String fiscalQuarter, String forecastType, List<Id> lstUserIds, String forecastFamily) {

        Set<Id> upselplaceholderusers = new Set<Id>();
        if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }

        if (forecastType != null && !forecastType.equalsIgnoreCase('all') && !forecastType.equalsIgnoreCase('new-upsell')) {
            List<Zscaler_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, YYWW__c, Archived__c, Locked__c, Month__c, User__c, Comments__c, Weekly_Forecast_Comment__c
                                                FROM Zscaler_Forecast__c
                                               WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                 AND Forecast_Type__c = :forecastType
                                                 AND FYFQ__c = :fiscalQuarter ORDER BY YYWW__c DESC LIMIT 1];
            System.debug('*** JSON.serialize(entries): ' + JSON.serialize(entries));
            if (entries != null && entries.size() > 0) {
                forecastSummary.MyForecast = entries[0].Forecast_Amount__c;
                forecastSummary.MyForecastSFID = entries[0].Id;
                forecastSummary.Locked = entries[0].Locked__c;
                forecastSummary.Comments = entries[0].Comments__c;
            } else {
                forecastSummary.MyForecast = null;
                forecastSummary.MyForecastSFID = null;
                forecastSummary.Locked = false;
                forecastSummary.Comments = null;
            }

            if (forecastSummary.Locked != true) {
                forecastSummary.MyForecast = forecastSummary.MySummary.MostLikelyTotal;
            }
        } else if(forecastType != null && forecastType.equalsIgnoreCase('all')) {
            List<Zscaler_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, YYWW__c, Forecast_Type__c, Archived__c, Locked__c, Month__c, User__c, Comments__c, Weekly_Forecast_Comment__c 
                                                FROM Zscaler_Forecast__c
                                               WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                 AND FYFQ__c = :fiscalQuarter ORDER BY YYWW__c DESC LIMIT 3];

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';

            ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;

            String forecastSummaryField = 'Forecast_Category_New__c';
            if (forecastSummary.UserLevel != 'Rep') {
                if (forecastSummary.UserLevel == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                }  else if (forecastSummary.UserLevel == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }

            System.debug(JSON.serialize(lstUserIds));
            System.debug(qtrStartDate + ' | ' + qtrEndDate);
            query = query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :lstUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :lstUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')';

            if (entries.size() > 0) {
                forecastSummary.MyForecast = 0;
                Set<String> forecastTypes = new Set<String> { 'new', 'upsell', 'renewal' };
                for (Zscaler_Forecast__c entry : entries) {
                    if (entry.Locked__c == true) {
                        forecastSummary.MyForecast += entry.Forecast_Amount__c != null ? entry.Forecast_Amount__c : 0;
                    } else {
                        List<AggregateResult> summary;
                        summary = Database.query(query + ' AND Forecast_Type__c = \'' + entry.Forecast_Type__c + '\'');
                        System.debug(summary);
                        forecastSummary.MyForecast += ((Decimal)summary[0].get('a') != null ? (Decimal)summary[0].get('a') : 0);
                    }
                    forecastSummary.MyForecastSFID = null;
                    forecastSummary.Locked = false;
                    forecastSummary.Comments = null;

                    forecastTypes.remove(entry.Forecast_Type__c.toLowerCase());
                }

                if (forecastTypes.size() > 0) {
                    for (String type : forecastTypes) {
                        List<AggregateResult> summary;
                        summary = Database.query(query + ' AND Forecast_Type__c = \'' + type + '\'');
                        forecastSummary.MyForecast += ((Decimal)summary[0].get('a') != null ? (Decimal)summary[0].get('a') : 0);
                    }
                }
            } else {
                List<AggregateResult> totalNew, totalUpsell, totalRenewal;
                totalNew = Database.query(query + ' AND Forecast_Type__c = \'new\'');
                totalUpsell = Database.query(query + ' AND Forecast_Type__c = \'upsell\'');
                totalRenewal = Database.query(query + ' AND Forecast_Type__c = \'renewal\'');
                Decimal totalForecast = 0;
                if (totalNew != null && totalNew.size() > 0 && (Decimal)totalNew[0].get('a') != null) {
                    totalForecast += (Decimal)totalNew[0].get('a');
                }
                if (totalUpsell != null && totalUpsell.size() > 0 && (Decimal)totalUpsell[0].get('a') != null) {
                    totalForecast += (Decimal)totalUpsell[0].get('a');
                }
                if (totalRenewal != null && totalRenewal.size() > 0 && (Decimal)totalRenewal[0].get('a') != null) {
                    totalForecast += (Decimal)totalRenewal[0].get('a');
                }
                forecastSummary.MyForecast = totalForecast;
                forecastSummary.MyForecastSFID = null;
                forecastSummary.Locked = false;
                forecastSummary.Comments = null;
            }
        }else{
            Set<String> forcasttypeset = new Set<String>();
            if(forecastType != null && forecastType.contains('-')){
                forcasttypeset.addAll(forecastType.split('-'));
            }
            List<Zscaler_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, YYWW__c, Forecast_Type__c, Archived__c, Locked__c, Month__c, User__c, Comments__c, Weekly_Forecast_Comment__c
                                                FROM Zscaler_Forecast__c
                                               WHERE User__c = :userId and Forecast_Family__c = :forecastFamily and Forecast_Type__c in :forcasttypeset
                                                 AND FYFQ__c = :fiscalQuarter ORDER BY YYWW__c DESC LIMIT 2];

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';

            ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;

            String forecastSummaryField = 'Forecast_Category_New__c';
            if (forecastSummary.UserLevel != 'Rep') {
                if (forecastSummary.UserLevel == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                }  else if (forecastSummary.UserLevel == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }

            System.debug(JSON.serialize(lstUserIds));
            System.debug(qtrStartDate + ' | ' + qtrEndDate);
            query = query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :lstUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :lstUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')';

            if (entries.size() > 0) {
                forecastSummary.MyForecast = 0;
                Set<String> forecastTypes = new Set<String> { 'new', 'upsell' };
                for (Zscaler_Forecast__c entry : entries) {
                    if (entry.Locked__c == true) {
                        forecastSummary.MyForecast += entry.Forecast_Amount__c != null ? entry.Forecast_Amount__c : 0;
                    } else {
                        List<AggregateResult> summary;
                        summary = Database.query(query + ' AND Forecast_Type__c = \'' + entry.Forecast_Type__c + '\'');
                        System.debug(summary);
                        forecastSummary.MyForecast += ((Decimal)summary[0].get('a') != null ? (Decimal)summary[0].get('a') : 0);
                    }
                    forecastSummary.MyForecastSFID = null;
                    forecastSummary.Locked = false;
                    forecastSummary.Comments = null;
                    if(entry.Forecast_Type__c == 'New'){
                        forecastSummary.WeeklyComments = entry.Weekly_Forecast_Comment__c;
                    }

                    forecastTypes.remove(entry.Forecast_Type__c.toLowerCase());
                }

                if (forecastTypes.size() > 0) {
                    for (String type : forecastTypes) {
                        List<AggregateResult> summary;
                        summary = Database.query(query + ' AND Forecast_Type__c = \'' + type + '\'');
                        forecastSummary.MyForecast += ((Decimal)summary[0].get('a') != null ? (Decimal)summary[0].get('a') : 0);
                    }
               }
            } else {
                List<AggregateResult> totalNew, totalUpsell;
                totalNew = Database.query(query + ' AND Forecast_Type__c = \'new\'');
                totalUpsell = Database.query(query + ' AND Forecast_Type__c = \'upsell\'');
                Decimal totalForecast = 0;
                if (totalNew != null && totalNew.size() > 0 && (Decimal)totalNew[0].get('a') != null) {
                    totalForecast += (Decimal)totalNew[0].get('a');
                }
                if (totalUpsell != null && totalUpsell.size() > 0 && (Decimal)totalUpsell[0].get('a') != null) {
                    totalForecast += (Decimal)totalUpsell[0].get('a');
                }

                forecastSummary.MyForecast = totalForecast;
                forecastSummary.MyForecastSFID = null;
                forecastSummary.Locked = false;
                forecastSummary.Comments = null;
            }
        }
        List<User> userlst = [Select Id, LocaleSidKey from User where Id = :userId];
        String userlocale = '';
        if(!userlst.isEmpty()){
            userlocale = userlst[0].LocaleSidKey;
        }
        
        // Logic to pull M1 W1 and M3 W1 numbers
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
        ZForecastingDataModel.WeekInfo M1W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate);
        
        Date m1date = qtr.startDate;
        if((qtr.startdate.daysbetween(M1W1Info.enddate.adddays(1)) < 4 && userlocale == 'en-US') || (qtr.startdate.daysbetween(M1W1Info.enddate.adddays(1)) < 5 && userlocale != 'en-US')){
            M1W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate.adddays(7).toStartOfWeek());
            m1date = qtr.startDate.adddays(7);
        }
        ZForecastingDataModel.WeekInfo M3W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate.addMonths(2));
        Date m3date = qtr.startDate.addMonths(2);
        String m1w1 = M1W1Info.FormattedString;
        String m3w1 = M3W1Info.FormattedString;
        
        if(LoggedInUserLocale != userlocale && (LoggedInUserLocale == 'en_US' || userlocale == 'en_US')){
            if(LoggedInUserLocale == 'en_US'){
                ZForecastingDataModel.WeekInfo weekM1 = new ZForecastingDataModel.WeekInfo(m1date);
                ZForecastingDataModel.WeekInfo weekM3 = new ZForecastingDataModel.WeekInfo(m3date);
                Integer weekplusonem1w1 = Integer.valueOf(M1W1Info.FormattedString) + 1;
                Integer weekplusonem3w1 = Integer.valueOf(M3W1Info.FormattedString) + 1;
                if(weekM1 != null && weekM1.StartDate != null && math.mod(weekM1.StartDate.adddays(1).dayOfYear(), 7) == 0){
                    m1w1 = weekplusonem1w1 != null ? String.valueOf(weekplusonem1w1): M1W1Info.FormattedString;
                }
                if(weekM3 != null && weekM3.StartDate != null && math.mod(weekM3.StartDate.adddays(1).dayOfYear(), 7) == 0){
                    m3w1 = weekplusonem3w1 != null ? String.valueOf(weekplusonem3w1): M3W1Info.FormattedString;
                }
            }else if(LoggedInUserLocale != 'en_US'){
                ZForecastingDataModel.WeekInfo weekM1 = new ZForecastingDataModel.WeekInfo(m1date);
                ZForecastingDataModel.WeekInfo weekM3 = new ZForecastingDataModel.WeekInfo(m3date);
                Integer weekplusonem1w1 = Integer.valueOf(M1W1Info.FormattedString) - 1;
                Integer weekplusonem3w1 = Integer.valueOf(M3W1Info.FormattedString) - 1;
                if(weekM1 != null && weekM1.StartDate != null && math.mod(weekM1.StartDate.dayOfYear(), 7) == 0){
                    m1w1 = weekplusonem1w1 != null ? String.valueOf(weekplusonem1w1): M1W1Info.FormattedString;
                }
                if(weekM3 != null && weekM3.StartDate != null && math.mod(weekM3.StartDate.dayOfYear(), 7) == 0){
                    m3w1 = weekplusonem3w1 != null ? String.valueOf(weekplusonem3w1): M3W1Info.FormattedString;
                }
            }
        }
        
        String lastForecastWeek = ZForecastingService.getLastForecastWeek(fiscalQuarter, 'ZIA', LoggedInUserLocale, userlocale);

        forecastSummary.MyM1W1Forecast = forecastSummary.MyM3W1Forecast = forecastSummary.MyLastWeekForecast = 0;

        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            List<Zscaler_Forecast__c> monthEntries = [SELECT FYFQ__c, YYWW__c, Forecast_Amount__c, Forecast_Type__c
                                                        FROM Zscaler_Forecast__c
                                                       WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                         AND Forecast_Type__c = :forecastType
                                                         AND FYFQ__c = :fiscalQuarter
                                                         AND YYWW__c IN (:m1w1, :m3w1, :lastForecastWeek)
                                                       ORDER BY LastModifiedDate DESC];

             Set<String> setWeekFCTypes = new Set<String>();
             for (Zscaler_Forecast__c entry : monthEntries) {
                //if (setWeekFCTypes.add(entry.YYWW__c + '|' + entry.Forecast_Type__c)) {
                if (entry.YYWW__c == m1w1 && !setWeekFCTypes.contains('M1W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM1W1Forecast = entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M1W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == m3w1 && !setWeekFCTypes.contains('M3W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM3W1Forecast = entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M3W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == lastForecastWeek && !setWeekFCTypes.contains('LW|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyLastWeekForecast = entry.Forecast_Amount__c;
                    setWeekFCTypes.add('LW|' + entry.Forecast_Type__c);
                }
                //}
             }
         } else if(forecastType != null && forecastType == 'all') {
             List<Zscaler_Forecast__c> monthEntries = [SELECT FYFQ__c, YYWW__c, Forecast_Amount__c, Forecast_Type__c
                                                         FROM Zscaler_Forecast__c
                                                        WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                          AND FYFQ__c = :fiscalQuarter
                                                          AND YYWW__c IN (:m1w1, :m3w1, :lastForecastWeek)
                                                          AND Forecast_Type__c IN ('New', 'Upsell', 'Renewal')
                                                        ORDER BY LastModifiedDate DESC];
            Set<String> setWeekFCTypes = new Set<String>();
            for (Zscaler_Forecast__c entry : monthEntries) {
                //if (setWeekFCTypes.add(entry.YYWW__c + '|' + entry.Forecast_Type__c)) {
                entry.Forecast_Amount__c = (entry.Forecast_Amount__c != null ? entry.Forecast_Amount__c : 0);
                if (entry.YYWW__c == m1w1 && !setWeekFCTypes.contains('M1W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM1W1Forecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M1W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == m3w1 && !setWeekFCTypes.contains('M3W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM3W1Forecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M3W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == lastForecastWeek && !setWeekFCTypes.contains('LW|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyLastWeekForecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('LW|' + entry.Forecast_Type__c);
                }
                //}
            }
        }else{
            Set<String> forcasttypeset = new Set<String>();
            if(forecastType != null && forecastType.contains('-')){
                forcasttypeset.addAll(forecastType.split('-'));
            }
            List<Zscaler_Forecast__c> monthEntries = [SELECT FYFQ__c, YYWW__c, Forecast_Amount__c, Forecast_Type__c
                                                         FROM Zscaler_Forecast__c
                                                        WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                         AND Forecast_Type__c in :forcasttypeset
                                                          AND FYFQ__c = :fiscalQuarter
                                                          AND YYWW__c IN (:m1w1, :m3w1, :lastForecastWeek)
                                                        ORDER BY LastModifiedDate DESC];
            Set<String> setWeekFCTypes = new Set<String>();
            for (Zscaler_Forecast__c entry : monthEntries) {
                //if (setWeekFCTypes.add(entry.YYWW__c + '|' + entry.Forecast_Type__c)) {
                entry.Forecast_Amount__c = (entry.Forecast_Amount__c != null ? entry.Forecast_Amount__c : 0);
                if (entry.YYWW__c == m1w1 && !setWeekFCTypes.contains('M1W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM1W1Forecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M1W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == m3w1 && !setWeekFCTypes.contains('M3W1|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyM3W1Forecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('M3W1|' + entry.Forecast_Type__c);
                }
                if (entry.YYWW__c == lastForecastWeek && !setWeekFCTypes.contains('LW|' + entry.Forecast_Type__c)) {
                    forecastSummary.MyLastWeekForecast += entry.Forecast_Amount__c;
                    setWeekFCTypes.add('LW|' + entry.Forecast_Type__c);
                }
                //}
            }
        }
    }


    @RemoteAction
    public static void SaveForecast(String UserId, String fyfq, String forecastType, String ForecastFamily, Decimal MyForecast, Boolean Locked, String Comments, Id MyForecastSFID) {
        if(String.isBlank(forecastType) || forecastType == 'all' || forecastType == 'new-upsell')
        {
            throw new ForecastingException('Please specify the type of your forecast.');
        }
        
        List<User> userlst = [Select Id, LocaleSidKey from User where Id = :userId];
        String userlocale = '';
        if(!userlst.isEmpty()){
            userlocale = userlst[0].LocaleSidKey;
        }

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo currentQtr = new ZForecastingDataModel.FiscalQuarterInfo();
        ZForecastingDataModel.WeekInfo week = qtr.getWeekByNumber(ZForecastingService.getLatestForecastWeek(fyfq, ForecastFamily, LoggedInUserLocale, userlocale));
        if (week == null) {
            week = new ZForecastingDataModel.WeekInfo();
        }

        if (fyfq == currentQtr.FormattedString) {
            if (MyForecastSFID != null) {
                Zscaler_Forecast__c forecast = [SELECT Id, Forecast_Amount__c, Locked__c, User__c, Forecast_Type__c, Comments__c FROM Zscaler_Forecast__c WHERE Id = :MyForecastSFID LIMIT 1];
                if (forecast != null) {
                    forecast.Forecast_Amount__c = MyForecast;
                    forecast.Locked__c = Locked;
                    forecast.Month__c = String.valueOf(week.StartDate.month());
                    forecast.Comments__c = Comments;

                    update forecast;
                }
            } else {
      //added ownerid=userid as a part of RBAC
                Zscaler_Forecast__c newforecast = new Zscaler_Forecast__c(OwnerId = UserId, Forecast_Family__c = ForecastFamily,Forecast_Amount__c = MyForecast, Locked__c = Locked, User__c = UserId, Forecast_Type__c = forecastType, FYFQ__c = qtr.FormattedString, YYWW__c = week.FormattedString, Month__c = String.valueOf(week.StartDate.month()), Comments__c = Comments);
                insert newforecast;
            }
        } else if (fyfq > currentQtr.FormattedString) {
            List<Zscaler_Forecast__c> forecast = [SELECT Id, Forecast_Amount__c, Locked__c, User__c, Forecast_Type__c, Comments__c FROM Zscaler_Forecast__c WHERE FYFQ__c = :fyfq AND User__c = :UserId AND Forecast_Type__c = :forecastType LIMIT 1];
            if (forecast != null && forecast.size() > 0) {
                forecast[0].Forecast_Amount__c = MyForecast;
                forecast[0].Locked__c = Locked;
                forecast[0].Comments__c = Comments;

                update forecast;
            } else {
      //added ownerid=userid as a part of RBAC
                Zscaler_Forecast__c newforecast = new Zscaler_Forecast__c(OwnerId=UserId, Forecast_Family__c = ForecastFamily, FYFQ__c = fyfq, YYWW__c = null, Month__c = null, Forecast_Type__c = forecastType, Forecast_Amount__c = MyForecast, Locked__c = Locked, User__c = UserId, Comments__c = Comments);
                insert newforecast;
            }
        }
    }

    @RemoteAction
    public static void SaveForecastWeeklyComments(String UserId, String fyfq, String forecastType, String ForecastFamily, String Commentsweeklyforecast, Id MyForecastSFID) {

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo currentQtr = new ZForecastingDataModel.FiscalQuarterInfo();
        List<Zscaler_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, YYWW__c, Archived__c, Locked__c, Month__c, User__c, Comments__c, Weekly_Forecast_Comment__c
                                                FROM Zscaler_Forecast__c
                                               WHERE User__c = :UserId and Forecast_Family__c = :forecastFamily 
                                                 AND Forecast_Type__c = 'New'
                                                 AND FYFQ__c = :fyfq ORDER BY YYWW__c DESC LIMIT 1];

        if (fyfq == currentQtr.FormattedString) {
            if (MyForecastSFID != null) {
                Zscaler_Forecast__c forecast = new Zscaler_Forecast__c(Id=MyForecastSFID);
                forecast.Weekly_Forecast_Comment__c = Commentsweeklyforecast;
                update forecast;
            }else if(!entries.isEmpty()){
                Zscaler_Forecast__c forecast = new Zscaler_Forecast__c(Id=entries[0].Id);
                forecast.Weekly_Forecast_Comment__c = Commentsweeklyforecast;
                update forecast;
            }
        } else if (fyfq > currentQtr.FormattedString) {
           throw new ForecastingException('Weekly Forecast Comment can only be entered for current quarter');
        }
    }

    @RemoteAction
    public static void SaveYonYGrowth(String UserId, String fyfq, String forecastType, String ForecastFamily, Decimal PriorYrClosedYTD) {

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo currentQtr = new ZForecastingDataModel.FiscalQuarterInfo();
        List<Prior_Year_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, User__c 
                                                FROM Prior_Year_Forecast__c
                                               WHERE User__c = :UserId
                                                 AND FYFQ__c = :fyfq LIMIT 1];

        if (!entries.isEmpty()) {
            Prior_Year_Forecast__c pyf = new Prior_Year_Forecast__c(Id = entries[0].Id);
            pyf.Forecast_Amount__c = PriorYrClosedYTD;
            update pyf;
        }else{
            Prior_Year_Forecast__c pyf = new Prior_Year_Forecast__c();
            pyf.Forecast_Amount__c = PriorYrClosedYTD;
            pyf.FYFQ__c = fyfq;
            pyf.User__c = UserId;
            insert pyf;
        }
    }

    @RemoteAction @ReadOnly
    public static void getMyTopLevelDealSupportSummary(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, List<Id> lstUserIds) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;

            List<Id> allUserIds = new List<Id>();
            allUserIds.addAll(lstUserIds);
            System.debug(JSON.serialize(allUserIds));

            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }

            List<AggregateResult> totalMostLikely, totalBestCase, totalWorstCase, totalQTDCommit;

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';
            String forecastCategoryField = 'Forecast_Category_New__c';
            if (forecastSummary.MyUserLevel != 'Rep') {
                if (forecastSummary.MyUserLevel == 'Manager') {
                    forecastCategoryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.MyUserLevel == 'Director') {
                    forecastCategoryField = 'AD_Forecast_Category__c';
                } else if (forecastSummary.MyUserLevel == 'RVP') {
                    forecastCategoryField = 'RVP_Forecast_Category__c';
                }  else if (forecastSummary.MyUserLevel == 'VP') {
                    forecastCategoryField = 'VP_Forecast_Category__c';
                } else if (forecastSummary.MyUserLevel == 'Exec') {
                    forecastCategoryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastCategoryField = 'Forecast_Category_New__c';
            }

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' Forecast_Type__c =: forecastType AND ';
            }else if(forecastType != null && forecastType == 'new-upsell') {
                query += ' Forecast_Type__c in :forcasttypeset AND ';
            } else {
                query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
            }

            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Closed\', \'Commit\')');
            totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' = \'Closed\' AND Opportunity.IsWon = True');

            forecastSummary.MyTopLevelSummary = new DealSupportSummary();
            forecastSummary.MyTopLevelSummary.MostLikelyTotal = (Decimal)totalMostLikely[0].get('a');
            forecastSummary.MyTopLevelSummary.BestCaseTotal = (Decimal)totalBestCase[0].get('a');
            forecastSummary.MyTopLevelSummary.WorstCaseTotal = (Decimal)totalWorstCase[0].get('a');
            forecastSummary.MyTopLevelSummary.QTDClosedTotal = (Decimal)totalQTDCommit[0].get('a');
        }
    }

    @RemoteAction @ReadOnly
    public static void getRSMDealSupportSummary(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, List<Id> lstUserIds) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;

            List<Id> allUserIds = new List<Id>();
            allUserIds.addAll(lstUserIds);
            System.debug(JSON.serialize(allUserIds));

            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }

            List<AggregateResult> totalMostLikely, totalBestCase, totalWorstCase, totalQTDCommit;

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';
            String forecastCategoryField = 'Forecast_Category_New__c';

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' Forecast_Type__c =: forecastType AND ';
            }else if(forecastType != null && forecastType == 'new-upsell') {
                query += ' Forecast_Type__c in :forcasttypeset AND ';
            } else {
                query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
            }

            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Closed\', \'Commit\')');
            totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' = \'Closed\' AND Opportunity.IsWon = True');

            forecastSummary.RSMSummary = new DealSupportSummary();
            forecastSummary.RSMSummary.MostLikelyTotal = (Decimal)totalMostLikely[0].get('a');
            forecastSummary.RSMSummary.BestCaseTotal = (Decimal)totalBestCase[0].get('a');
            forecastSummary.RSMSummary.WorstCaseTotal = (Decimal)totalWorstCase[0].get('a');
            forecastSummary.RSMSummary.QTDClosedTotal = (Decimal)totalQTDCommit[0].get('a');
        }
    }

    @RemoteAction @ReadOnly
    public static void getLevelMinusOneDealSupportSummary(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, List<Id> lstUserIds) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;

            List<Id> allUserIds = new List<Id>();
            allUserIds.addAll(lstUserIds);
            System.debug(JSON.serialize(allUserIds));

            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }

            List<AggregateResult> totalMostLikely, totalBestCase, totalWorstCase, totalQTDCommit;

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';

            String forecastCategoryField = 'Forecast_Category_New__c';
            if (forecastSummary.MyUserLevel != 'Rep') {
                if (forecastSummary.MyUserLevel == 'Manager') {
                    forecastCategoryField = 'Forecast_Category_New__c';
                } else if (forecastSummary.MyUserLevel == 'Director') {
                    forecastCategoryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.MyUserLevel == 'RVP') {
                    forecastCategoryField = 'AD_Forecast_Category__c';
                }  else if (forecastSummary.MyUserLevel == 'VP') {
                    forecastCategoryField = 'RVP_Forecast_Category__c';
                } else if (forecastSummary.MyUserLevel == 'Exec') {
                    forecastCategoryField = 'VP_Forecast_Category__c';
                }
            } else {
                forecastCategoryField = 'Forecast_Category_New__c';
            }

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' Forecast_Type__c =: forecastType AND ';
            }else if(forecastType != null && forecastType == 'new-upsell') {
                query += ' Forecast_Type__c in :forcasttypeset AND ';
            } else {
                query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
            }

            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' IN (\'Closed\', \'Commit\')');
            totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastCategoryField + ' = \'Closed\' AND Opportunity.IsWon = True');

            forecastSummary.LevelMinusOneSummary = new DealSupportSummary();
            forecastSummary.LevelMinusOneSummary.MostLikelyTotal = (Decimal)totalMostLikely[0].get('a');
            forecastSummary.LevelMinusOneSummary.BestCaseTotal = (Decimal)totalBestCase[0].get('a');
            forecastSummary.LevelMinusOneSummary.WorstCaseTotal = (Decimal)totalWorstCase[0].get('a');
            forecastSummary.LevelMinusOneSummary.QTDClosedTotal = (Decimal)totalQTDCommit[0].get('a');
        }
    }

    @RemoteAction @ReadOnly
    public static void getDealSupportSummary(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType, Boolean includeSubordinates, List<Id> lstUserIds) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;

            List<Id> allUserIds = new List<Id>();
            if (includeSubordinates == true) {
                allUserIds.addAll(lstUserIds);
            } else {
                allUserIds.add(userId);
            }
            System.debug(JSON.serialize(allUserIds));

            Set<Id> upselplaceholderusers = new Set<Id>();
            if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
                upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            }
            List<AggregateResult> totalMostLikely, totalBestCase, totalWorstCase, totalQTDCommit;

            String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';


            String forecastSummaryField = 'Forecast_Category_New__c';
            if (forecastSummary.UserLevel != 'Rep') {
                if (forecastSummary.UserLevel == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                }  else if (forecastSummary.UserLevel == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (forecastSummary.UserLevel == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' Forecast_Type__c =: forecastType AND ';
            }else if(forecastType == 'new-upsell'){
                query += ' Forecast_Type__c in : forcasttypeset AND ';
            } else {
                query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
            }
            System.debug(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Closed\', \'Commit\')');
            totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' = \'Closed\' AND Opportunity.IsWon = True');

            System.debug(JSON.serialize(totalMostLikely));
            System.debug(JSON.serialize(totalBestCase));
            System.debug(JSON.serialize(totalWorstCase));

            forecastSummary.MySummary = new DealSupportSummary();
            forecastSummary.MySummary.MostLikelyTotal = (Decimal)totalMostLikely[0].get('a');
            forecastSummary.MySummary.BestCaseTotal = (Decimal)totalBestCase[0].get('a');
            forecastSummary.MySummary.WorstCaseTotal = (Decimal)totalWorstCase[0].get('a');
            forecastSummary.MySummary.QTDClosedTotal = (Decimal)totalQTDCommit[0].get('a');
        }
    }

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

    public static void getPreviousWeekSummary(ZForecastSummary forecastSummary, String userId, ZForecastingDataModel.FiscalQuarterInfo qtr, String forecastType) {
        Set<String> forcasttypeset = new Set<String>();
        if(forecastType != null && forecastType.contains('-')){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        if (forecastSummary != null) {
            Date qtrStartDate = qtr.StartDate;
            Date qtrEndDate = qtr.EndDate;
            String fiscalQtr = qtr.FormattedString;
            String recordLimit;

            // List<Id> allUserIds = new List<Id>();
            // allUserIds.add(userId);
            // allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
            // System.debug(JSON.serialize(allUserIds));

            String query = 'SELECT Most_Likely__c, Best_Case__c, QTD__c, Worst_Case__c, User__c FROM Deal_Support_Summary_Snapshot__c WHERE Quarter__c = :fiscalQtr and User__c = :userId ';

            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                query += ' and Forecasting_Type__c = :forecastType ';
                recordLimit = '1';
            } else if(forecastType != null && forecastType == 'all'){
                query += ' AND Forecasting_Type__c IN (\'New\', \'Upsell\', \'Renewal\')';
                recordLimit = '3';
            }else{
                query += ' and Forecasting_Type__c in :forcasttypeset ';
                recordLimit = '2';
            }

            query += ' ORDER BY CreatedDate DESC ';
            query += ' LIMIT ' + recordLimit;

            forecastSummary.MyLastWeekSummary = new DealSupportSummary();
            forecastSummary.MyLastWeekSummary.MostLikelyTotal = 0;
            forecastSummary.MyLastWeekSummary.BestCaseTotal = 0;
            forecastSummary.MyLastWeekSummary.WorstCaseTotal = 0;
            forecastSummary.MyLastWeekSummary.QTDClosedTotal = 0;

            for (Deal_Support_Summary_Snapshot__c snapshot : Database.query(query)) {
                // if (snapshot.Quarter__c == fiscalQtr) {
                    forecastSummary.MyLastWeekSummary.MostLikelyTotal += snapshot.Most_Likely__c;
                    forecastSummary.MyLastWeekSummary.BestCaseTotal += snapshot.Best_Case__c;
                    forecastSummary.MyLastWeekSummary.WorstCaseTotal += snapshot.Worst_Case__c;
                    forecastSummary.MyLastWeekSummary.QTDClosedTotal += snapshot.QTD__c;
                // }
            }
        }
    }

    @RemoteAction @ReadOnly
    public static ForecastingOppListResponse GetOpportunityListing(ForecastingOppListRequest request)
    {
        Set<String> forcasttypeset = new Set<String>();
        if(String.isNotBlank(request.forecastType) && request.forecastType == 'new-upsell'){
            forcasttypeset.addAll(request.forecastType.split('-'));
        }
        Boolean prevandnextweek = false;
        Boolean conprevandnextweek = false;
        Boolean m1andm3 = false;
        Boolean conm1andm3 = false;
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(request.userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(request.userId));
        
        Id userId = request.userId;
        List<User> userlst = [Select Id, LocaleSidKey from User where Id = :userId];
        String userlocale = '';
        if(!userlst.isEmpty()){
            userlocale = userlst[0].LocaleSidKey;
        }

        Set<Id> upselplaceholderusers = new Set<Id>();
        if(request.forecastType == 'upsell' || request.forecastType == 'all' || request.forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(request.FiscalQtr);
        Date qtrStartDate = qtr.StartDate;
        Date qtrEndDate = qtr.EndDate;
        Integer fyear = qtr.Year;

        Integer pageSize = 25;

        String forecastCategoryField = 'Forecast_Category_New__c';
        if (request.UserLevel != 'Rep') {
            if (request.UserLevel == 'Manager') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (request.UserLevel == 'Director') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (request.UserLevel == 'RVP') {
                forecastCategoryField = 'RVP_Forecast_Category__c';
            }  else if (request.UserLevel == 'VP') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            } else if (request.UserLevel == 'Exec') {
                forecastCategoryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category_New__c';
        }

        String levelMinusOneFC = forecastCategoryField;
        if (request.UserLevel == 'Exec') {
            levelMinusOneFC = 'VP_Forecast_Category__c';
        } else if (request.UserLevel == 'VP') {
            levelMinusOneFC = 'RVP_Forecast_Category__c';
        }  else if (request.UserLevel == 'RVP') {
            levelMinusOneFC = 'AD_Forecast_Category__c';
        } else if (request.UserLevel == 'Director') {
            levelMinusOneFC = 'DM_Forecast_Category__c';
        } else if (request.UserLevel == 'Manager') {
            levelMinusOneFC = 'DM_Forecast_Category__c';
        } else {
            levelMinusOneFC = 'Forecast_Category_New__c';
        }

        String stage = '';

        Boolean stagefilter = false;
        if(!request.Stage.isEmpty() && request.Stage.contains('Contracts Complete'))
        {
            stagefilter = true;
            String StageContractsComplete = label.Stage_5_Contracts_Complete;
            stage += 'AND (Opportunity.StageName like :StageContractsComplete '; 
        }
        if(!request.Stage.isEmpty() && request.Stage.contains('Closed Lost'))
        {
            string ClosedLostStage = label.Stage_7_Closed_Lost;
            string SubStageClosedLost = Label.SubStage_Closed_Lost;
            String SubStageClosedLostWithNoDec = Label.SubStage_Closed_With_No_Decision;
            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            //stage += ' ( Opportunity.StageName like \'11 - Closed Lost\' OR Opportunity.StageName like \'12 - Closed With No Decision\') ';
            stage += ' (Opportunity.StageName like:ClosedLostStage and (Opportunity.Sub_Stage__c like:SubStageClosedLost OR Opportunity.Sub_Stage__c like:SubStageClosedLostWithNoDec)) ';
            stagefilter = true;
        }

        if(!request.Stage.isEmpty() && request.Stage.contains('Closed Won'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += ' (Opportunity.IsWon = true and ' + forecastCategoryField + '=\'Closed\') ';
            stagefilter = true;
        }
        if(!request.Stage.isEmpty() && request.Stage.contains('All Open'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += ' (Opportunity.IsClosed = false AND (not Opportunity.StageName like \'0 %\')) ';
            stagefilter = true;
        }

        if(!request.Stage.isEmpty() && request.Stage.contains('Commit'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' = \'Commit\' ';
            stagefilter = true;
        }
        if(!request.Stage.isEmpty() && request.Stage.contains('Upside'))
        {
            stagefilter = true;
            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\') ';
        }
        if(!request.Stage.isEmpty() && request.Stage.contains('Pipeline'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' = \'Pipeline\' ';
            stagefilter = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('Best Case'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' = \'Best Case\'';
            stagefilter = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('Most Likely'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' = \'Most Likely\' ';
            stagefilter = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('BC Forecast'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\') ';
            stagefilter = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('ML Forecast'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\') ';
            stagefilter = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('WC Forecast'))
        {

            if(stagefilter) stage += ' OR ';
            else stage += ' AND ( ';
            stage += forecastCategoryField + ' IN (\'Closed\', \'Commit\') ';
            stagefilter = true;
        }

        if(stagefilter){
            stage += ' ) ';
        }

        Boolean hierarchycheck = false;
        if (!request.Stage.isEmpty() && request.Stage.contains('My Forecast <> RSM'))
        {

            if (request.impersonateViewAsUser == true) {
                stage += ' AND ((Is_View_As_My_FC_Same_As_RSM_FC__c = False ';
            } else {
                stage += 'AND ((Is_My_FC_Same_As_RSM_FC__c = False ';
            }
            stage += ' AND ' + forecastCategoryField + '!=\'Omitted\') ';
            hierarchycheck = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('Level Minus 1 <> RSM'))
        {

            if(hierarchycheck) stage += ' OR ';
            else stage += ' AND ( ';
            if (request.impersonateViewAsUser == true) {
                stage += ' (Is_View_As_Level_1_FC_Same_As_RSM_FC__c = False ';
            } else {
                stage += ' (Is_Level_1_FC_Same_As_RSM_FC__c = False ';
            }
            stage += ' AND ' + forecastCategoryField + '!=\'Omitted\') ';
            hierarchycheck = true;
        }
        if (!request.Stage.isEmpty() && request.Stage.contains('My Forecast <> Level Minus 1')) {

            if(hierarchycheck) stage += ' OR ';
            else stage += ' AND ( ';
            if (request.impersonateViewAsUser == true) {
                stage += ' (Is_View_As_FC_Same_As_Level_Minus_One_FC__c = False ';
            } else {
                stage += ' (Is_My_FC_Same_As_Level_Minus_One_FC__c = False ';
            }
            stage += ' AND ' + forecastCategoryField + '!=\'Omitted\') ';
            hierarchycheck = true;
        }
        if(hierarchycheck) stage += ' ) ';

        Boolean otherfilters = false;
        if(!request.Stage.isEmpty() && request.Stage.contains('Deal Splits')){
            otherfilters = true;
            stage += 'AND ( Opportunity.Split__c=true ';
        }
        if(!request.Stage.isEmpty() && request.Stage.contains('Pushed Deals'))
        {

            if(otherfilters) stage += ' OR ';
            else stage += ' AND ( ';
            stage += ' Opportunity.Pushed_deal__c=true ';
            otherfilters = true;
        }
        if(otherfilters) stage += ' ) ';

        String dealValue = '';
        if (!request.DealValue.isEmpty()) {
            dealValue += ' AND (';
            if (request.DealValue.contains('< $25K')) {
                dealValue += ' (SplitAmount <= 25000) ';
            }
            if (request.DealValue.contains('$25K - $50K')) {
                if(dealValue.contains('SplitAmount')) dealValue += ' OR ';
                dealValue += ' (SplitAmount > 25000 AND SplitAmount <= 50000) ';
            }
            if (request.DealValue.contains('$50K - $100K')) {
                if(dealValue.contains('SplitAmount')) dealValue += ' OR ';
                dealValue += ' (SplitAmount > 50000 AND SplitAmount <= 100000) ';
            }
            if (request.DealValue.contains('$100K - $250K')) {
                if(dealValue.contains('SplitAmount')) dealValue += ' OR ';
                dealValue += ' (SplitAmount > 100000 AND SplitAmount <= 250000) ';
            }
            if (request.DealValue.contains('$250K - $1M')) {
                if(dealValue.contains('SplitAmount')) dealValue += ' OR ';
                dealValue += ' (SplitAmount > 250000 AND SplitAmount <= 1000000) ';
            }
            if (request.DealValue.contains('> $1M')) {
                if(dealValue.contains('SplitAmount')) dealValue += ' OR ';
                dealValue += ' (SplitAmount > 1000000) ';
            }
            dealValue += ') ';
        }

        Date m1startDate;
        Date m1endDate;
        Date m2startDate;
        Date m2endDate;
        Date m3startDate;
        Date m3endDate;
        if (!request.ClosingMonth.isEmpty()) {
            Date startDate = qtrStartDate;
            Date endDate = qtrEndDate;
            if (request.ClosingMonth.contains('M1')) {
                m1startDate = qtrStartDate;
                m1endDate = m1startDate.addMonths(1).addDays(-1);
            }
            if (request.ClosingMonth.contains('M2')) {
                m2startDate = qtrStartDate.addMonths(1);
                m2endDate = m2startDate.addMonths(1).addDays(-1);
            }
            if (request.ClosingMonth.contains('M3')) {
                m3startDate = qtrStartDate.addMonths(2);
                m3endDate = qtrEndDate;
            }

            if(request.ClosingMonth.size() == 3){
                qtrStartDate = startDate;
                qtrEndDate = endDate;
            }else if(request.ClosingMonth.size() == 2){
                if (!request.ClosingMonth.contains('M1')) {
                    qtrStartDate = m2startDate;
                    qtrEndDate = m3endDate;
                }
                if (!request.ClosingMonth.contains('M3')) {
                    qtrStartDate = m1startDate;
                    qtrEndDate = m2endDate;
                }
                if (!request.ClosingMonth.contains('M2')) {
                    qtrStartDate = m1startDate;
                    qtrEndDate = m3endDate;
                    m1andm3 = true;
                }
            }else{
                if (request.ClosingMonth.contains('M1')) {
                    qtrStartDate = m1startDate;
                    qtrEndDate = m1endDate;
                }
                if (request.ClosingMonth.contains('M2')) {
                    qtrStartDate = m2startDate;
                    qtrEndDate = m2endDate;
                }
                if (request.ClosingMonth.contains('M3')) {
                    qtrStartDate = m3startDate;
                    qtrEndDate = m3endDate;
                }
            }
        }

        Date prevstartDate;
        Date prevendDate;
        Date thisstartDate;
        Date thisendDate;
        Date nextstartDate;
        Date nextendDate;
        if (!request.ClosingWeek.isEmpty()) {
            Date startDate = qtrStartDate;
            Date endDate = qtrEndDate;
            
            String[] quarterWeek = ZForecastingService.getLatestForecastWeek(LoggedInUserLocale, userlocale);
            String yyww = quarterWeek[1];
            ZForecastingDataModel.WeekInfo ThisWeekInfo = null;//qtr.getWeekByNumber(yyww);

            if(ThisWeekInfo == null){
                ThisWeekInfo = new ZForecastingDataModel.WeekInfo();
            }

            if (request.ClosingWeek.contains('This')) {
                thisstartDate = ThisWeekInfo.startDate;
                thisendDate = ThisWeekInfo.endDate;
            }
            if (request.ClosingWeek.contains('Next')) {
                ZForecastingDataModel.WeekInfo NextWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(7).toStartOfWeek());
                nextstartDate = NextWeekInfo.startDate;
                nextendDate = NextWeekInfo.endDate;
            }
            if (request.ClosingWeek.contains('Previous')) {
                ZForecastingDataModel.WeekInfo LastWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(-7).toStartOfWeek());
                prevstartDate = LastWeekInfo.startDate;
                prevendDate = LastWeekInfo.endDate;
            }
            if(request.ClosingWeek.size() == 3){
                qtrStartDate = prevstartDate;
                qtrEndDate = nextendDate;
            }else if(request.ClosingWeek.size() == 2){
                if (!request.ClosingWeek.contains('Previous')) {
                    qtrStartDate = thisstartDate;
                    qtrEndDate = nextendDate;
                }
                if (!request.ClosingWeek.contains('Next')) {
                    qtrStartDate = prevstartDate;
                    qtrEndDate = thisendDate;
                }
                if (!request.ClosingWeek.contains('This')) {
                    qtrStartDate = prevstartDate;
                    qtrEndDate = nextendDate;
                    prevandnextweek = true;
                }
            }else{
                if (request.ClosingWeek.contains('Previous')) {
                    qtrStartDate = prevstartDate;
                    qtrEndDate = prevendDate;
                }
                if (request.ClosingWeek.contains('Next')) {
                    qtrStartDate = nextstartDate;
                    qtrEndDate = nextendDate;
                }
                if (request.ClosingWeek.contains('This')) {
                    qtrStartDate = thisstartDate;
                    qtrEndDate = thisendDate;
                }
            }
        }

        /* Contract end date - old logic
        Date conm1startDate;
        Date conm1endDate;
        Date conm2startDate;
        Date conm2endDate;
        Date conm3startDate;
        Date conm3endDate;
        if (!request.ContractEndDateMonth.isEmpty()) {
            Date startDate = qtrStartDate;
            Date endDate = qtrEndDate;
            if (request.ContractEndDateMonth.contains('M1')) {
                conm1endDate = qtrStartDate;
                conm1endDate = conm1endDate.addMonths(1).addDays(-1);
            }
            if (request.ContractEndDateMonth.contains('M2')) {
                conm2startDate = qtrStartDate.addMonths(1);
                conm2endDate = conm2startDate.addMonths(1).addDays(-1);
            }
            if (request.ContractEndDateMonth.contains('M3')) {
                conm3startDate = qtrStartDate.addMonths(2);
                conm3endDate = qtrEndDate;
            }

            if(request.ContractEndDateMonth.size() == 3){
                qtrStartDate = startDate;
                qtrEndDate = endDate;
            }else if(request.ContractEndDateMonth.size() == 2){
                if (!request.ContractEndDateMonth.contains('M1')) {
                    qtrStartDate = conm2startDate;
                    qtrEndDate = conm3endDate;
                }
                if (!request.ContractEndDateMonth.contains('M3')) {
                    qtrStartDate = conm1endDate;
                    qtrEndDate = conm2endDate;
                }
                if (!request.ContractEndDateMonth.contains('M2')) {
                    qtrStartDate = conm1endDate;
                    qtrEndDate = conm3endDate;
                    conm1andm3 = true;
                }
            }else{
                if (request.ContractEndDateMonth.contains('M1')) {
                    qtrStartDate = conm1endDate;
                    qtrEndDate = conm1endDate;
                }
                if (request.ContractEndDateMonth.contains('M2')) {
                    qtrStartDate = conm2startDate;
                    qtrEndDate = conm2endDate;
                }
                if (request.ContractEndDateMonth.contains('M3')) {
                    qtrStartDate = conm3startDate;
                    qtrEndDate = conm3endDate;
                }
            }
        }
        */

       // Contract End Date (Month) logic
       String contractEndDateMonthFilter = '';
       if (!request.ContractEndDateMonth.isEmpty()) {
           contractEndDateMonthFilter += ' AND (';

           for (Integer i=0; i < request.ContractEndDateMonth.size(); i++) {
               if (i > 0) contractEndDateMonthFilter += ' OR ';

               Datetime startDate, endDate;
               Date tempStartDate, tempEndDate;

               if (request.ContractEndDateMonth[i].equalsIgnoreCase('m1')) {
                   startDate = Datetime.newInstanceGMT(qtrStartDate.year(), qtrStartDate.month(), qtrStartDate.day(), 0, 0, 0);
                   tempEndDate = qtrStartDate.addMonths(1);
                   endDate = Datetime.newInstanceGMT(tempEndDate.year(), tempEndDate.month(), tempEndDate.day(), 0, 0, 0);
                   contractEndDateMonthFilter += ' (Opportunity.Contract_End_Date_New__c >= ' + startDate.formatGMT('yyyy-MM-dd')
                                        + ' AND Opportunity.Contract_End_Date_New__c <= ' + endDate.formatGMT('yyyy-MM-dd') + ') ';
               } else if (request.ContractEndDateMonth[i].equalsIgnoreCase('m2')) {
                   tempStartDate = qtrStartDate.addMonths(1);
                   startDate = Datetime.newInstanceGMT(tempStartDate.year(), tempStartDate.month(), tempStartDate.day(), 0, 0, 0);
                   tempEndDate = tempStartDate.addMonths(1);
                   endDate = Datetime.newInstanceGMT(tempEndDate.year(), tempEndDate.month(), tempEndDate.day(), 0, 0, 0);
                   contractEndDateMonthFilter += ' (Opportunity.Contract_End_Date_New__c >= ' + startDate.formatGMT('yyyy-MM-dd')
                                        + ' AND Opportunity.Contract_End_Date_New__c <= ' + endDate.formatGMT('yyyy-MM-dd') + ') ';
               } else if (request.ContractEndDateMonth[i].equalsIgnoreCase('m3')) {
                   tempStartDate = qtrStartDate.addMonths(2);
                   startDate = Datetime.newInstanceGMT(tempStartDate.year(), tempStartDate.month(), tempStartDate.day(), 0, 0, 0);
                   tempEndDate = tempStartDate.addMonths(1);
                   endDate = Datetime.newInstanceGMT(tempEndDate.year(), tempEndDate.month(), tempEndDate.day(), 0, 0, 0);
                   contractEndDateMonthFilter += ' (Opportunity.Contract_End_Date_New__c >= ' + startDate.formatGMT('yyyy-MM-dd')
                                        + ' AND Opportunity.Contract_End_Date_New__c <= ' + endDate.formatGMT('yyyy-MM-dd') + ') ';
               }
           }

           contractEndDateMonthFilter += ') ';
       }

        Date conprevstartDate;
        Date conprevendDate;
        Date conthisstartDate;
        Date conthisendDate;
        Date connextstartDate;
        Date connextendDate;
        

        String geo = '';
        if (!request.Geo.isEmpty()) {
            List<String> geovals = request.Geo;
            geo = ' AND Sales_Territory__r.Theater__c in :geovals ';
        }

        String region = '';
        if (!request.Region.isEmpty()) {
            List<String> regionvals = request.Region;
            region= ' AND Sales_Territory__r.Region__c in :regionvals ';
        }
        String customersuccessstage = '';
        if (!request.CustomerSuccessStage.isEmpty()) {
            List<String> csslist = request.CustomerSuccessStage;
            customersuccessstage = ' AND Opportunity.Account.Success_Stage__c in :csslist ';
        }
        
        String customersentiment = '';
        if (!request.CustomerSentiment.isEmpty()) {
            List<String> cslist = request.CustomerSentiment;
            customersentiment = ' AND Opportunity.Account.Customer_Sentiment__c in :cslist ';
        }

        String notraFilter = '';
        if (!request.NOTRAFilter.isEmpty()) {
            List<String> notraFiltersList = request.NOTRAFilter;
            notraFilter = ' (';
            for (Integer i = 0; i<notraFiltersList.size(); i++) {
                if (i > 0) notraFilter += ' OR ';

                if (notraFiltersList[i].equalsIgnoreCase('on time')) {
                    notraFilter += '((((Opportunity.Contract_End_Date_New__c >= :qtrStartDate AND Opportunity.Contract_End_Date_New__c <= :qtrEndDate) OR Opportunity.Contract_End_Date_New__c = null) AND Opportunity.CloseDate >= :qtrStartDate AND Opportunity.CloseDate <= :qtrEndDate)'
                                + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ';
                } else if (notraFiltersList[i].equalsIgnoreCase('late')) {
                    notraFilter += ' ((Opportunity.Contract_End_Date_New__c < :qtrStartDate AND FISCAL_YEAR(Opportunity.Contract_End_Date_New__c) = :fyear AND Opportunity.CloseDate >= :qtrStartDate AND Opportunity.CloseDate <= :qtrEndDate) '
                                + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ';
                } else if (notraFiltersList[i].equalsIgnoreCase('prior early')) {
                    notraFilter += ' ((Opportunity.Contract_End_Date_New__c >= :qtrStartDate AND Opportunity.Contract_End_Date_New__c <= :qtrEndDate) AND (Opportunity.CloseDate < :qtrStartDate)'
                                + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ';
                } else if (notraFiltersList[i].equalsIgnoreCase('future')) {
                    notraFilter += ' (((Opportunity.Contract_End_Date_New__c > :qtrEndDate) AND Opportunity.CloseDate >= :qtrStartDate AND Opportunity.CloseDate <= :qtrEndDate) '
                                + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ';
                }
            }

            notraFilter += ') ';
        }

        String probability = '';
        if(String.isNotBlank(request.Probability) && request.Probability != 'All')
        {
            probability = 'AND Opportunity.Probability ' + request.Probability + ' ';
        }

        String forecastType = '';
        if(String.isNotBlank(request.forecastType) && request.forecastType != 'all' && request.forecastType != 'new-upsell')
        {
            forecastType = 'AND Forecast_Type__c=\'' + request.forecastType + '\' ';
        }else if(String.isNotBlank(request.forecastType) && request.forecastType == 'new-upsell'){
            forecastType = 'AND Forecast_Type__c in :forcasttypeset ';
        } else {
            forecastType = ' AND Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') ';
        }

        String forecastFamily = '';
        if (request.showzpa) {
            forecastFamily = ' AND (Opportunity.Total_ZPA_ACV__c > 0) ';
        }

        // Determine SortField for Level - 1 FC and My FC
        if (request.SortField == 'LevelMinusOneForecastCategory') {
            request.SortField = levelMinusOneFC;
        } else if (request.SortField == 'MyForecastCategory') {
            request.SortField = forecastCategoryField;
        }

        String sortBy = 'ORDER BY ' + (String.isBlank(request.SortField) ? 'Opportunity.CloseDate' : request.SortField) + ' ';
        String order = request.IsAscendingOrder == true ? 'ASC' : 'DESC NULLS LAST';


        String query = 'SELECT Opportunity.Renewable_ACV__c, Opportunity.Total_ZPA_ACV__c, Amount__c, SplitAmount, ZPA_Amount_For_Sorting__c, ZPA_Amount__c, Opportunity.Product_Type__c, Opportunity.HasOpportunityLineItem, OpportunityId, SplitOwnerId, Forecast_Type__c, CRO_Forecast_Category__c, VP_Forecast_Category__c, RVP_Forecast_Category__c, AD_Forecast_Category__c, DM_Forecast_Category__c, Forecast_Category_New__c, Forecast_Category__c, ZPA_RSM__r.Name, SplitOwner.Name, Opportunity.OwnerId, Opportunity.Owner.Name, Deal_Path__c, DM_Forecast_Category_Lock__c, AD_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c, RVP_Forecast_Category_Lock__c, CRO_Forecast_Category_Lock__c, Owner_s_Sales_Territory_Name__c, Owner_Sales_Territory__r.Name, Owner_Sales_Territory__r.Area__c, Owner_Sales_Terr_Geo__c, SE__r.Name, Sales_Territory__r.Region__c FROM OpportunitySplit ';

        System.debug('>>>> qtrStartDate: ' + qtrStartDate);
        System.debug('>>>> qtrEndDate: ' + qtrEndDate);
        System.debug('>>>> prevandnextweek: ' + prevandnextweek);
        if (notraFilter == '') {
            if(m1andm3){
                query += 'WHERE ((Opportunity.CloseDate <= :m1endDate AND Opportunity.CloseDate >= :m1startDate) OR (Opportunity.CloseDate <= :m3endDate AND Opportunity.CloseDate >= :m3startDate)) ';
            }else if(prevandnextweek){
                query += 'WHERE ((Opportunity.CloseDate <= :prevendDate AND Opportunity.CloseDate >= :prevstartDate) OR (Opportunity.CloseDate <= :nextendDate AND Opportunity.CloseDate >= :nextstartDate)) ';
            }else{
                query += 'WHERE Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate ';
            }
        } else {
            query += 'WHERE ' + notraFilter;
        }

        /* Contract end date month - old logic
        if(!request.ContractEndDateMonth.isEmpty() || !request.ContractEndDateWeek.isEmpty()){
            if(conm1andm3){
                query += ' AND ((Opportunity.Contract_End_Date_New__c <= :conm1endDate AND Opportunity.Contract_End_Date_New__c >= :conm1startDate) OR (Opportunity.Contract_End_Date_New__c <= :conm3endDate AND Opportunity.Contract_End_Date_New__c >= :conm3startDate)) ';
            }else if(conprevandnextweek){
                query += ' AND ((Opportunity.Contract_End_Date_New__c <= :conprevendDate AND Opportunity.Contract_End_Date_New__c >= :conprevstartDate) OR (Opportunity.Contract_End_Date_New__c <= :connextendDate AND Opportunity.Contract_End_Date_New__c >= :connextstartDate)) ';
            }else{
                query += ' AND (Opportunity.Contract_End_Date_New__c <= :qtrEndDate AND Opportunity.Contract_End_Date_New__c >= :qtrStartDate) ';
            }
        }
        */
        System.debug('>>>> qtrStartDate: ' + allUserIds);
        System.debug('>>>> qtrStartDate: ' + upselplaceholderusers);
        //if (request.forecastFamily == 'ZPA') {
          //  query += ' AND ZPA_RSM__c IN :allUserIds ';
        //} else {
            query += ' AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) ';
        //}

        query += stage;
        query += dealValue;
        query += geo;
        query += region;
        query += probability;
        query += forecastType;
        query += forecastFamily;
        query += customersuccessstage;
        query += customersentiment;
        query += contractEndDateMonthFilter;
        query += sortBy;
        query += order;

        System.debug('>>>> opty query String: '+query);
        ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
        if(request.isExporttoExcel == false){
            oppController.setPageSize(pageSize);
        }else{
            oppController.setPageSize(oppController.getResultSize());
        }

        if(request.PageIndex != null && request.PageIndex > 0)
        {
            oppController.setPageNumber(request.PageIndex);
        }
        ForecastingOppListResponse response = new ForecastingOppListResponse();
        response.HasNext = oppController.getHasNext();
        response.HasPrevious = oppController.getHasPrevious();
        response.PageIndex = oppController.getPageNumber();

        response.PageCount = oppController.getResultSize() / pageSize + 1;

        Datetime startDatetime = Datetime.newInstance(qtrStartDate.year(), qtrStartDate.month(), qtrStartDate.day(), 0, 0, 0);
        Datetime endDatetime = Datetime.newInstance(qtrEndDate.year(), qtrEndDate.month(), qtrEndDate.day(), 0, 0, 0);
        response.CloseWeekDateRange = startDatetime.format('MMMM dd') + ' - ' + endDatetime.format('MMMM dd');

        response.totalOppAmount = 0;
        set <Id> opplist = new set<Id>();
        for(OpportunitySplit opp : database.query(query)){
            opplist.add(opp.OpportunityId);
            if(opp.SplitAmount != null){
                if (request.showzpa) {
                    response.totalOppAmount += (opp.ZPA_Amount__c);
                } else {
                    response.totalOppAmount += opp.SplitAmount;
                }
            }

        }

        String oppQuery = 'SELECT Name, AccountId, VMO_Play__c, IsWon, Split_Message__c, Subscription_overdue__c, Contract_End_Date_New__c, Product_Type__c, HasOpportunityLineItem, StageName, Type, OwnerId, Owner.Name, Probability, ForecastCategory, FEVA__c, Inline_POC__c, Validation_Stage__c, ForecastCategoryName, ExpectedRevenue, CloseDate, Amount, NextStep, Deal_Path__c, Account.Last_Architecture_Workshop_Date__c, Account.Last_F2F_Meeting__c, Account.F2F_Meetings_In_Last_60_Days__c, Account.Customer_Sentiment__c, Account.Success_Stage__c, Account.Name, Account.Territory_Type__c, Account.Sales_Territory__r.Name, Account.Area__c, Account.Geo__c,Opportunity_Territory_Type__c, Opportunity_Sales_Territory__r.Name, Area__c, Opportunity_Sales_Territory__r.Theater__c,  Forecast_Type__c, APTS_Primary_Proposal_Lookup__r.APTS_Proposal_Net_Price__c, Proposed_Number_of_Users__c, Expected_Term_Months__c, Total_ZIA_ACV__c, Total_ZPA_ACV__c, Renewable_ACV__c, Netsuite_Sales_Order_No__c, Account.Netsuite_Parent_ID__c, (select AccountToId, AccountTo.Name from OpportunityPartnersFrom where IsPrimary=true), (Select Account__r.Name, Account__c from Opportunity_Partners__r where Is_Primary__c = true and Partner_Type__c = \'Reseller\' LIMIT 1), (select Current_POC_Phase__c, Type_of_Interaction__c from Executive_Advocacy_Programs__r where Type_of_Interaction__c=\'POC Inline\' order by CreatedDate desc) FROM Opportunity ';
        set<id> oppIdSet = new set<Id>();
        Map<Id, Opportunity> opportunityMap = new map<Id, Opportunity>();

        System.debug('*** request.Stage: ' + request.Stage);
        for(sObject opp : oppController.getRecords())
        {
            oppIdSet.add(((OpportunitySplit)Opp).OpportunityId);

        }
        response.RecordCount = opplist.size();
        oppQuery += 'WHERE ID IN :oppIdSet ';

        if (request.showzpa) {
            oppQuery += ' AND (Total_ZPA_ACV__c > 0) ';
        }

        for(Opportunity opp :  database.query(oppQuery)){
            opportunityMap.put(opp.id, opp);
        }
        

        for(sObject opp : oppController.getRecords()){
            Boolean includeSplit = true;
            // if ('My Forecast vs RSM' == request.Stage
            //     && ((OpportunitySplit)opp).get('Forecast_Category_New__c') == ((OpportunitySplit)opp).get(forecastCategoryField)) {
            //     includeSplit = false;
            // } else if ('Level Minus 1 vs RSM' == request.Stage
            //     && ((OpportunitySplit)opp).get('Forecast_Category_New__c') == ((OpportunitySplit)opp).get(levelMinusOneFC)) {
            //     includeSplit = false;
            // }
            if (includeSplit) {
                response.Opportunities.add(new OpportunityEntry(opportunityMap.get(((OpportunitySplit)opp).OpportunityId), (OpportunitySplit)opp, request.ForecastFamily, allUserIds, request.MyUserId, forecastCategoryField, request.showzpa, upselplaceholderusers));
            }
        }
        return response;
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
        String usrlevel = request.params != null && request.params.containsKey('UserLevel')? (String)request.params.get('UserLevel'):'';
        oppToSave = entry.toOpportunity(usrlevel);
        oppSplit = entry.toOpportunitySplit(usrLevel);

        System.debug(oppToSave);
        System.debug(oppSplit);

        List<OpportunitySplit> recalculatedSplits = new List<OpportunitySplit>();
        if(entry.SplitAmountStamp != entry.Amount)
        {
            System.debug('Amount: '+entry.Amount+', splitAmountStamp: '+entry.SplitAmountStamp);
            Decimal alteredSplitAmt = entry.Amount - entry.SplitAmountStamp;
            oppToSave.Amount = entry.OppAmountStamp + alteredSplitAmt;
            System.debug('oppToSave.Amount: '+oppToSave.Amount);
            List<OpportunitySplit> splits = [select Id, SplitAmount, SplitPercentage, Forecast_Type__c, Opportunity_Forecast_Type__c from OpportunitySplit where OpportunityId = :oppToSave.Id];
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
            if (entry.OppType.equalsIgnoreCase('renewal') && entry.OppSplitType.equalsIgnoreCase('upsell')) {
                update oppSplit;
            } else {
                update oppToSave;

                if(recalculatedSplits != null && recalculatedSplits.size() > 0)
                {
                    update recalculatedSplits;
                }
            }

            // Commenting the below to handle Upsell split updates
            // update oppToSave;
            //
            // if(splits != null && splits.size() > 0)
            // {
            //     update splits;
            // }else
            // {
            //     update oppSplit;
            // }

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
                        //alteredSplit.SplitPercentage = split.SplitPercentage;
                        //split = alteredSplit;
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

    @RemoteAction @ReadOnly
    public static MonthlyForecastSummary getMonthlyForecastSummary(Id userId, String fyfq, String forecastType, String level, Boolean isViewingHistory, String forecastfamily) {
        MonthlyForecastSummary summary = new MonthlyForecastSummary(userId, fyfq);
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo thisQtr = new ZForecastingDataModel.FiscalQuarterInfo();
        List<Integer> lstMonthNumbers = new List<Integer>();
        Map<Integer, MonthlyForecastSummaryEntry> summaryEntriesMap = new Map<Integer, MonthlyForecastSummaryEntry>();

        // Return blank for future quarter
        if (qtr.FormattedString > thisQtr.FormattedString) {
            return summary;
        }

        Date currentDate = qtr.startDate;
        Datetime currentDatetime = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);
        Date today = Date.today();
        Integer currentMonth = today.month();
        while (currentDate < qtr.endDate) {
            lstMonthNumbers.add(currentDate.month());
            summaryEntriesMap.put(currentDate.month(), new MonthlyForecastSummaryEntry(currentDatetime.format('MMMM'), 0.0, 0.0, 0.0, currentDate.month() == today.month(), currentDate.month() == qtr.endDate.month()));
            currentDate = currentDate.addMonths(1);
            currentDatetime = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);
        }
        System.debug('*** lstMonthNumbers: ' + lstMonthNumbers);
        System.debug('*** JSON.serialize(summaryEntriesMap): ' + JSON.serialize(summaryEntriesMap));

        Date startDate = qtr.startDate;
        Date endDate = qtr.endDate;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        System.debug('*** JSON.serialize(allUserIds): ' + JSON.serialize(allUserIds));

        Set<Id> upselplaceholderusers = new Set<Id>();
        if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }

        String forecastCategoryField = 'Forecast_Category_New__c';
        if (level != 'Rep') {
            if (level == 'Manager') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (level == 'Director') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (level == 'RVP') {
                forecastCategoryField = 'RVP_Forecast_Category__c';
            }  else if (level == 'VP') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            } else if (level == 'Exec') {
                forecastCategoryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category_New__c';
        }

        Set<String> forcasttypeset = new Set<String>();
        if(String.isNotBlank(forecastType) && forecastType == 'new-upsell'){
            forcasttypeset.addAll(forecastType.split('-'));
        }

        String query = 'SELECT Id, OpportunityId, Split, ZPA_Amount__c, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, Opportunity.IsClosed, Opportunity.IsWon, Opportunity.CloseDate, '+ forecastCategoryField + ' FROM OpportunitySplit WHERE ';
        query += ' Opportunity.CloseDate >= :startDate AND Opportunity.CloseDate <= :endDate';
        query += ' AND (' + forecastCategoryField + ' IN (\'Closed\', \'Commit\', \'Most Likely\') OR (Opportunity.IsClosed = true AND Opportunity.IsWon = true))';

        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            query += ' AND Forecast_Type__c =: forecastType';
        } else if(forecastType != null && forecastType == 'new-upsell'){
            query += ' AND Forecast_Type__c in :forcasttypeset';
        } else {
            query += ' AND Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\')';
        }

        query += ' AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) ';
        System.debug(query);

        // Summarize the total amount based on close dates month
        // Map<Integer, Decimal> mapMonthAndSplitAmounts = new Map<Integer, Decimal>();
        Map<Integer, Map<String, Decimal>> mapMonthAndMyFCSplitAmounts = new Map<Integer, Map<String, Decimal>>();
        for (OpportunitySplit split : Database.query(query)) {
            String myFCValue = '';

            if (level != 'Rep') {
                if (level == 'Manager') {
                    myFCValue = split.DM_Forecast_Category__c;
                } else if (level == 'Director') {
                    myFCValue = split.AD_Forecast_Category__c;
                } else if (level == 'RVP') {
                    myFCValue = split.RVP_Forecast_Category__c;
                }  else if (level == 'VP') {
                    myFCValue = split.VP_Forecast_Category__c;
                } else if (level == 'Exec') {
                    myFCValue = split.CRO_Forecast_Category__c;
                }
            } else {
                myFCValue = split.Forecast_Category_New__c;
            }

            // Mark the opportunities that are closed and won as 'ClosedWon'
            if ((myFCValue == null || myFCValue.equalsIgnoreCase('closed')) && split.Opportunity.IsClosed == true && split.Opportunity.IsWon == true) {
                myFCValue = 'ClosedWon';
            }
            if(forecastfamily == 'ZIA'){
                if (mapMonthAndMyFCSplitAmounts.containsKey(split.Opportunity.CloseDate.month())) {
                    Map<String, Decimal> mapMyFCAndSplitAmounts = mapMonthAndMyFCSplitAmounts.get(split.Opportunity.CloseDate.month());

                    if (mapMyFCAndSplitAmounts.containsKey(myFCValue)) {
                        mapMyFCAndSplitAmounts.put(myFCValue, mapMyFCAndSplitAmounts.get(myFCValue) + split.SplitAmount);
                    } else {
                        mapMyFCAndSplitAmounts.put(myFCValue, split.SplitAmount);
                    }
                } else {
                    mapMonthAndMyFCSplitAmounts.put(split.Opportunity.CloseDate.month(), new Map<String, Decimal> { myFCValue => split.SplitAmount });
                }
            }else if(forecastfamily == 'ZPA'){
                if (mapMonthAndMyFCSplitAmounts.containsKey(split.Opportunity.CloseDate.month())) {
                    Map<String, Decimal> mapMyFCAndSplitAmounts = mapMonthAndMyFCSplitAmounts.get(split.Opportunity.CloseDate.month());

                    if (mapMyFCAndSplitAmounts.containsKey(myFCValue)) {
                        mapMyFCAndSplitAmounts.put(myFCValue, mapMyFCAndSplitAmounts.get(myFCValue) + split.ZPA_Amount__c);
                    } else {
                        mapMyFCAndSplitAmounts.put(myFCValue, split.ZPA_Amount__c);
                    }
                } else {
                    mapMonthAndMyFCSplitAmounts.put(split.Opportunity.CloseDate.month(), new Map<String, Decimal> { myFCValue => split.ZPA_Amount__c });
                }
            }
            
        }
        // Summarize based on close month and assign them to summary entries
        for (Integer summaryMonth : summaryEntriesMap.keySet()) {
            for (Integer month : mapMonthAndMyFCSplitAmounts.keySet()) {
                if (Math.abs(summarymonth - month) <= 2 && month <= summaryMonth ) {
                    if ((Math.abs(summarymonth - currentMonth) <= 2 || isViewingHistory) && summaryMonth < currentMonth) {
                        summaryEntriesMap.get(summaryMonth).forecastRollup += (mapMonthAndMyFCSplitAmounts.get(month).get('ClosedWon') != null ? mapMonthAndMyFCSplitAmounts.get(month).get('ClosedWon') : 0);
                    } else {
                        summaryEntriesMap.get(summaryMonth).forecastRollup += (mapMonthAndMyFCSplitAmounts.get(month).get('Closed') != null ? mapMonthAndMyFCSplitAmounts.get(month).get('Closed') : 0);
                        summaryEntriesMap.get(summaryMonth).forecastRollup += (mapMonthAndMyFCSplitAmounts.get(month).get('ClosedWon') != null ? mapMonthAndMyFCSplitAmounts.get(month).get('ClosedWon') : 0);
                        summaryEntriesMap.get(summaryMonth).forecastRollup += (mapMonthAndMyFCSplitAmounts.get(month).get('Commit') != null ? mapMonthAndMyFCSplitAmounts.get(month).get('Commit') : 0);
                        summaryEntriesMap.get(summaryMonth).forecastRollup += (mapMonthAndMyFCSplitAmounts.get(month).get('Most Likely') != null ? mapMonthAndMyFCSplitAmounts.get(month).get('Most Likely') : 0);
                    }
                }
            }
        }
        final String MONTHLY_LINEARITY_RT_ID = Schema.SObjectType.Linearity_Snapshot__c.getRecordTypeInfosByName().get('Monthly Forecast').getRecordTypeId();
        String linearitySnapshotQuery = 'SELECT Id, FYFQ__c, Month__c, Forecast_Type__c, Amount__c FROM Linearity_Snapshot__c WHERE  Forecast_Family__c = :forecastfamily and RecordTypeId =:MONTHLY_LINEARITY_RT_ID AND User__c =:userId AND Month__c IN :lstMonthNumbers and FYFQ__c=:fyfq';
        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            linearitySnapshotQuery += ' AND Forecast_Type__c =: forecastType';
        }else if(forecastType != null && forecastType == 'new-upsell'){
            linearitySnapshotQuery += ' AND Forecast_Type__c in :forcasttypeset';
        }
        linearitySnapshotQuery += ' ORDER BY CreatedDate ASC';

        System.debug('*** linearitySnapshotQuery: ' + linearitySnapshotQuery);
        for (Linearity_Snapshot__c snapshot : Database.query(linearitySnapshotQuery)) {
            if (summaryEntriesMap.containsKey(Integer.valueOf(snapshot.Month__c))) {
                summaryEntriesMap.get(Integer.valueOf(snapshot.Month__c)).forecastSnapshot += snapshot.Amount__c;
            }
        }

        Decimal QTRQuota = 0.0;
        if(String.isNotBlank(forecastType) && forecastType != 'all' && forecastType != 'new-upsell')
        {
            List<SalesQuota__c> quota = [select QuotaAmount__c from SalesQuota__c where User__c=:userId and ForecastType__c=:forecastType AND FYFQ__c=:qtr.FormattedString AND Forecast_Family__c = :forecastfamily limit 1];
            if(quota.size() > 0)
            {
                QTRQuota = quota[0].QuotaAmount__c;
            }
        }
        else if(String.isNotBlank(forecastType) && forecastType == 'all')
        {
            List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND FYFQ__c=:qtr.FormattedString AND Forecast_Family__c = :forecastfamily AND ForecastType__c IN ('New', 'Upsell', 'Renewal')];
            if(quota.size() > 0)
            {
                QTRQuota = (Decimal)quota[0].get('q');
            }
        }else{
            List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND FYFQ__c=:qtr.FormattedString and ForecastType__c in :forcasttypeset AND Forecast_Family__c = :forecastfamily];
            if(quota.size() > 0)
            {
                QTRQuota = (Decimal)quota[0].get('q');
            }
        }

        List<Decimal> lstPlanTargetPercents = new List<Decimal> { 0.22, 0.55, 1.0 };
        if (QTRQuota != null && QTRQuota != 0.0) {
            for (Integer i = 0; i < lstMonthNumbers.size(); i++) {
                if (summaryEntriesMap.containsKey(lstMonthNumbers[i])) {
                    summaryEntriesMap.get(lstMonthNumbers[i]).planSnapshot = QTRQuota * lstPlanTargetPercents[i];
                }
            }
        }

        summary.entries = new List<MonthlyForecastSummaryEntry>();
        for (Integer month : lstMonthNumbers) {
            summary.entries.add(summaryEntriesMap.get(month));
        }

        return summary;
    }

    @RemoteAction @ReadOnly
    public static WeeklyForecastSummary getWeeklyForecastSummary(Id userId, String fyfq, String forecastType, String level, Boolean isViewingHistory, String forecastfamily) {
        Map<String, ZForecastingDataModel.WeekInfo> mapWeeksToQuery = new Map<String, ZForecastingDataModel.WeekInfo>();
        WeeklyForecastSummary summary = new WeeklyForecastSummary(userId, fyfq);
        summary.entries = new List<WeeklyForecastSummaryEntry>();
        List<String> lstWeeks = new List<String>();
        Map<String, WeeklyForecastSummaryEntry> summaryEntriesMap = new Map<String, WeeklyForecastSummaryEntry>();
        String startDateString, endDateString;
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo thisQtr =  new ZForecastingDataModel.FiscalQuarterInfo();

        ZForecastingDataModel.WeekInfo ThisWeekInfo, LastWeekInfo, LastMinusOneWeekInfo, NextWeekInfo;
        Datetime headerStartDate, headerEndDate;
        if (!isViewingHistory) {
            if (qtr.FormattedString != thisQtr.FormattedString) {
                return summary;
            }
            
            List<User> userlst = [Select Id, LocaleSidKey from User where Id = :userId];
            String userlocale = '';
            if(!userlst.isEmpty()){
                userlocale = userlst[0].LocaleSidKey;
            }

            String[] quarterWeek = ZForecastingService.getLatestForecastWeek(LoggedInUserLocale, userlocale);
            String yyww = quarterWeek[1];

            ZForecastingDataModel.WeekInfo M1W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate);
            ZForecastingDataModel.WeekInfo M1W2Info = new ZForecastingDataModel.WeekInfo(qtr.startDate.addDays(7).toStartOfWeek());
            ZForecastingDataModel.WeekInfo M3LastWeekInfo = new ZForecastingDataModel.WeekInfo(qtr.endDate.toStartOfWeek());

            ThisWeekInfo = null;//qtr.getWeekByNumber(yyww);
            if(ThisWeekInfo == null){
                ThisWeekInfo = new ZForecastingDataModel.WeekInfo();
            }

            if (ThisWeekInfo.FormattedString != M1W1Info.FormattedString && ThisWeekInfo.FormattedString != M1W2Info.FormattedString) {
                LastMinusOneWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(-14).toStartOfWeek());
                LastWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(-7).toStartOfWeek());
                // mapWeeksToQuery.put(LastMinusOneWeekInfo.FormattedString, LastMinusOneWeekInfo);
                // mapWeeksToQuery.put(LastWeekInfo.FormattedString, LastWeekInfo);
                // lstWeeks.add(LastMinusOneWeekInfo.FormattedString);
                // lstWeeks.add(LastWeekInfo.FormattedString);
                //
                // headerStartDate = LastMinusOneWeekInfo.StartDate;
                // headerEndDate = LastMinusOneWeekInfo.EndDate;
                // summaryEntriesMap.put(LastMinusOneWeekInfo.FormattedString, new WeeklyForecastSummaryEntry(LastMinusOneWeekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd')));
                //
                // headerStartDate = LastWeekInfo.StartDate;
                // headerEndDate = LastWeekInfo.EndDate;
                // summaryEntriesMap.put(LastWeekInfo.FormattedString, new WeeklyForecastSummaryEntry(LastWeekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd')));
            } else if (ThisWeekInfo.FormattedString != M1W1Info.FormattedString) {
                LastWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(-7).toStartOfWeek());
                // mapWeeksToQuery.put(LastWeekInfo.FormattedString, LastWeekInfo);
                // lstWeeks.add(LastWeekInfo.FormattedString);
                //
                // headerStartDate = LastWeekInfo.StartDate;
                // headerEndDate = LastWeekInfo.EndDate;
                // summaryEntriesMap.put(LastWeekInfo.FormattedString, new WeeklyForecastSummaryEntry(LastWeekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd')));
            }
            // mapWeeksToQuery.put(ThisWeekInfo.FormattedString, ThisWeekInfo);
            // lstWeeks.add(ThisWeekInfo.FormattedString);
            //
            // headerStartDate = ThisWeekInfo.StartDate;
            // headerEndDate = ThisWeekInfo.EndDate;
            // summaryEntriesMap.put(ThisWeekInfo.FormattedString, new WeeklyForecastSummaryEntry(ThisWeekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd'), true));

            if (ThisWeekInfo.FormattedString != M3LastWeekInfo.FormattedString) {
                NextWeekInfo = new ZForecastingDataModel.WeekInfo(ThisWeekInfo.startDate.addDays(7).toStartOfWeek());
                // mapWeeksToQuery.put(NextWeekInfo.FormattedString, NextWeekInfo);
                // lstWeeks.add(NextWeekInfo.FormattedString);
                //
                // headerStartDate = NextWeekInfo.StartDate;
                // headerEndDate = NextWeekInfo.EndDate;
                // summaryEntriesMap.put(NextWeekInfo.FormattedString, new WeeklyForecastSummaryEntry(NextWeekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd')));
            }

            for (ZForecastingDataModel.WeekInfo weekInfo : qtr.Weeks) {
                if ((NextWeekInfo != null && weekInfo.FormattedString <= NextWeekInfo.FormattedString) || NextWeekInfo == null) {
                    mapWeeksToQuery.put(weekInfo.FormattedString, weekInfo);
                    lstWeeks.add(weekInfo.FormattedString);

                    headerStartDate = weekInfo.StartDate;
                    headerEndDate = weekInfo.EndDate;
                    summaryEntriesMap.put(weekInfo.FormattedString, new WeeklyForecastSummaryEntry(weekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd'), ThisWeekInfo.FormattedString == weekInfo.FormattedString));
                }
            }

            Datetime startDate = mapWeeksToQuery.get(lstWeeks[0]).startDate;
            Datetime endDate = mapWeeksToQuery.get(lstWeeks[lstWeeks.size() - 1]).endDate;
            startDateString = startDate.formatGMT('yyyy-MM-dd'); //String.valueOf(startDate.year()) + '-' + String.valueOf(startDate.month()) + '-' + String.valueOf(startDate.day());
            endDateString = endDate.formatGMT('yyyy-MM-dd'); //String.valueOf(endDate.year()) + '-' + String.valueOf(endDate.month()) + '-' + String.valueOf(endDate.day());
        } else {
            for (ZForecastingDataModel.WeekInfo weekInfo : qtr.Weeks) {
                mapWeeksToQuery.put(weekInfo.FormattedString, weekInfo);
                lstWeeks.add(weekInfo.FormattedString);

                headerStartDate = weekInfo.StartDate;
                headerEndDate = weekInfo.EndDate;
                summaryEntriesMap.put(weekInfo.FormattedString, new WeeklyForecastSummaryEntry(weekInfo.FormattedString, 0, 0, headerStartDate.formatGMT('MMM dd') + ' - ' + headerEndDate.formatGMT('MMM dd')));
            }

            Datetime startDate = qtr.StartDate;
            Datetime endDate = qtr.EndDate;
            startDateString = startDate.formatGMT('yyyy-MM-dd'); //String.valueOf(startDate.year()) + '-' + String.valueOf(startDate.month()) + '-' + String.valueOf(startDate.day());
            endDateString = endDate.formatGMT('yyyy-MM-dd'); //String.valueOf(endDate.year()) + '-' + String.valueOf(endDate.month()) + '-' + String.valueOf(endDate.day());
        }

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        System.debug('*** JSON.serialize(allUserIds): ' + JSON.serialize(allUserIds));

        Set<Id> upselplaceholderusers = new Set<Id>();
        if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }

        String forecastCategoryField = 'Forecast_Category_New__c';
        if (level != 'Rep') {
            if (level == 'Manager') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (level == 'Director') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (level == 'RVP') {
                forecastCategoryField = 'RVP_Forecast_Category__c';
            }  else if (level == 'VP') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            } else if (level == 'Exec') {
                forecastCategoryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category_New__c';
        }

        Set<String> forcasttypeset = new Set<String>();
        if(String.isNotBlank(forecastType) && forecastType == 'new-upsell'){
            forcasttypeset.addAll(forecastType.split('-'));
        }

        String query = 'SELECT Id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, Opportunity.CloseDate, '+ forecastCategoryField + ' FROM OpportunitySplit WHERE ';
        query += ' Opportunity.CloseDate >= ' + startDateString + ' AND Opportunity.CloseDate <= ' + endDateString;
        query += ' AND Opportunity.IsClosed = true AND Opportunity.IsWon = true';

        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            query += ' AND Forecast_Type__c =: forecastType';
        } else if(forecastType != null && forecastType == 'new-upsell'){
            query += ' AND Forecast_Type__c in :forcasttypeset';
        } else {
            query += ' AND Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\')';
        }

        query += ' AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) ';
        System.debug(query);

        Set<String> setWeeksForLinearity = new Set<String>(lstWeeks);
        if (NextWeekInfo != null) {
            setWeeksForLinearity.remove(NextWeekInfo.FormattedString);
        }
        String currentquarterftdstring = qtr.FormattedString;
        final String WEEKLY_LINEARITY_RT_ID = Schema.SObjectType.Linearity_Snapshot__c.getRecordTypeInfosByName().get('Weekly Forecast').getRecordTypeId();
        String linearitySnapshotQuery = 'SELECT Id, FYFQ__c, YYWW__c, Forecast_Type__c, Amount__c FROM Linearity_Snapshot__c WHERE Forecast_Family__c = :forecastfamily and RecordTypeId =:WEEKLY_LINEARITY_RT_ID AND User__c =:userId AND YYWW__c IN :setWeeksForLinearity and FYFQ__c = :currentquarterftdstring';
        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            linearitySnapshotQuery += ' AND Forecast_Type__c =: forecastType';
        }else if(forecastType != null && forecastType == 'new-upsell'){
            linearitySnapshotQuery += ' AND Forecast_Type__c in :forcasttypeset';
        }

        for (Linearity_Snapshot__c snapshot : Database.query(linearitySnapshotQuery)) {
            if (summaryEntriesMap.containsKey(snapshot.YYWW__c)) {
                summaryEntriesMap.get(snapshot.YYWW__c).snapshotAmount += snapshot.Amount__c;
            }
        }

        for (OpportunitySplit split : Database.query(query)) {
            for (String yyww : lstWeeks) {
                if (split.Opportunity.CloseDate >= mapWeeksToQuery.get(yyww).StartDate && split.Opportunity.CloseDate <= mapWeeksToQuery.get(yyww).EndDate) {
                    if (summaryEntriesMap.containsKey(yyww)) {
                        summaryEntriesMap.get(yyww).forecastAmount += split.SplitAmount;
                    }
                }
            }
        }
        System.debug('>>>> summaryEntriesMap before: ' + JSON.serialize(summaryEntriesMap));
        // Add Next Week's data
        if (NextWeekInfo != null) {
            Date nextWeekStartDate = NextWeekInfo.startDate;
            Date nextWeekEndDate = NextWeekInfo.endDate;
            String nextWeekQuery = 'SELECT Id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, Opportunity.CloseDate, '+ forecastCategoryField + ' FROM OpportunitySplit WHERE ';
            nextWeekQuery += ' Opportunity.CloseDate >= :nextWeekStartDate AND Opportunity.CloseDate <= :nextWeekEndDate';
            nextWeekQuery += ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Commit\', \'Best Case\')';
            if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
                nextWeekQuery += ' AND Forecast_Type__c =: forecastType';
            } else if(forecastType != null && forecastType == 'new-upsell'){
                nextWeekQuery += ' AND Forecast_Type__c in :forcasttypeset';
            } else {
                nextWeekQuery += ' AND Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\')';
            }

            nextWeekQuery += ' AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) ';

            for (OpportunitySplit split : Database.query(nextWeekQuery)) {
                if (summaryEntriesMap.containsKey(NextWeekInfo.FormattedString)) {
                    summaryEntriesMap.get(NextWeekInfo.FormattedString).snapshotAmount += split.SplitAmount;
                }
            }
        }

        System.debug('>>>> summaryEntriesMap: ' + JSON.serialize(summaryEntriesMap));

        for (String yyww : lstWeeks) {
            if (summaryEntriesMap.containsKey(yyww)) {
                summary.entries.add(summaryEntriesMap.get(yyww));
            }
        }

        return summary;
    }

    @ReadOnly @RemoteAction
    public static NOTRASummary getNOTRASummary(Id userId, String fyfq, String level) {
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        List<String> fiscalyearlst = fyfq != '' && fyfq != null && fyfq.contains('Q')? fyfq.split('Q') : new List<String>();
        
        NOTRASummary summary = new NOTRASummary();

        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        Date qtrStartDate = qtr.startDate;
        Date qtrEndDate = qtr.endDate;
        
        Integer fiscalyr = !fiscalyearlst.isEmpty() && fiscalyearlst[0] != null && fiscalyearlst[0] != ''? Integer.valueOf(fiscalyearlst[0]) : qtr.Year;

        List<NOTRA_Budget__c> notraBudget = [SELECT Id, User__c, Comments__c, Budget_Amount__c, Renewal_Budget_Amount__c, Renewal_Adjustment__c, FYFQ__c, BD_Renewal__c FROM NOTRA_Budget__c WHERE User__c = :userId AND FYFQ__c = :qtr.FormattedString ORDER BY CreatedDate DESC LIMIT 1];
        if (notraBudget.size() > 0) {
            summary.notraBudgetAmount = notraBudget[0].Budget_Amount__c != null ? notraBudget[0].Budget_Amount__c : 0.0;
            summary.bdrenewal = notraBudget[0].BD_Renewal__c != null ? notraBudget[0].BD_Renewal__c : 0.0;
            summary.renewalBudget = notraBudget[0].Renewal_Budget_Amount__c != null ? notraBudget[0].Renewal_Budget_Amount__c : 0.0;
            List<AggregateResult>  renewaladjustments = [select sum(Renewal_Adjustment__c) q FROM NOTRA_Budget__c WHERE User__c in :allUserIds AND FYFQ__c = :qtr.FormattedString];
            if(renewaladjustments.size() > 0)
            {
                 summary.renewalAdjustment = (Decimal)renewaladjustments[0].get('q') != null ? (Decimal)renewaladjustments[0].get('q') : 0.0;
            }
            summary.comments = notraBudget[0].Comments__c != null ? notraBudget[0].Comments__c : '';
        }

        List<SalesQuota__c> quota = [select QuotaAmount__c from SalesQuota__c where User__c=:userId and ForecastType__c='Renewal' AND FYFQ__c=:fyfq AND Forecast_Family__c = 'ZIA' limit 1];
        if(quota.size() > 0)
        {
            summary.renewalPlan = quota[0].QuotaAmount__c != null ? quota[0].QuotaAmount__c : 0.0;
        }

        summary.fyfq = qtr.FormattedString;
        
        String forecastCategoryField = 'Forecast_Category_New__c';
        if (level != 'Rep') {
            if (level == 'Manager') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (level == 'Director') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (level == 'RVP') {
                forecastCategoryField = 'RVP_Forecast_Category__c';
            }  else if (level == 'VP') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            } else if (level == 'Exec') {
                forecastCategoryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category_New__c';
        }

        String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE ';
        //query += ' FISCAL_YEAR(Opportunity.CloseDate) = :fiscalyr';
        query += ' Forecast_Type__c = \'Renewal\' AND SplitOwnerId IN :allUserIds ';

        List<AggregateResult> totalSummaryOntime = Database.query(query + ' AND ((((Opportunity.Contract_End_Date_New__c >= :qtrStartDate AND Opportunity.Contract_End_Date_New__c <= :qtrEndDate) OR Opportunity.Contract_End_Date_New__c = null) AND Opportunity.CloseDate >= :qtrStartDate AND Opportunity.CloseDate <= :qtrEndDate)'
                    + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ');
        List<AggregateResult> totalSummaryLate = Database.query(query + ' AND ((Opportunity.Contract_End_Date_New__c < :qtrStartDate AND FISCAL_YEAR(Opportunity.Contract_End_Date_New__c) = :fiscalyr AND Opportunity.CloseDate >= :qtrStartDate AND Opportunity.CloseDate <= :qtrEndDate) '
                    + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ');
        List<AggregateResult> totalSummaryPriorEarly = Database.query(query + ' AND ((Opportunity.Contract_End_Date_New__c >= :qtrStartDate AND Opportunity.Contract_End_Date_New__c <= :qtrEndDate) AND (Opportunity.CloseDate < :qtrStartDate)'
                    + ' AND ' + forecastCategoryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')) ');

        if (totalSummaryOntime.size() > 0) {
            summary.renewalOnTime = totalSummaryOntime[0].get('a') != null ? (Decimal)totalSummaryOntime[0].get('a') : 0;
        }

        if (totalSummaryLate.size() > 0) {
            summary.renewalLate = totalSummaryLate[0].get('a') != null ? (Decimal)totalSummaryLate[0].get('a') : 0;
        }

        if (totalSummaryPriorEarly.size() > 0) {
            summary.renewalEarly = totalSummaryPriorEarly[0].get('a') != null ? (Decimal)totalSummaryPriorEarly[0].get('a') : 0;
        }

        // Calculate NOTRA summaries
        summary.renewalOnTimeAndLate = (summary.renewalOnTime != null ? summary.renewalOnTime : 0) + (summary.renewalLate != null ? summary.renewalLate : 0) + (summary.renewalEarly != null ? summary.renewalEarly : 0) + (summary.renewalAdjustment != null ? summary.renewalAdjustment : 0);
        summary.notraActuals = ((summary.renewalOnTime != null ? summary.renewalOnTime : 0) + (summary.renewalLate != null ? summary.renewalLate : 0) + (summary.renewalEarly != null ? summary.renewalEarly : 0) + (summary.renewalAdjustment != null ? summary.renewalAdjustment : 0)) - (summary.renewalBudget != null ? summary.renewalBudget : 0);
        summary.notraBudgetVariance = (summary.notraActuals != null ? summary.notraActuals : 0) - (summary.notraBudgetAmount != null ? summary.notraBudgetAmount : 0);

        return summary;
    }

    @RemoteAction
    public static Boolean saveRenewalAdjustment(Id userId, String fyfq, String level, Decimal adjustment) {
        Boolean success = false;

        NOTRA_Budget__c notraBudgetToUpdate;
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        List<NOTRA_Budget__c> notraBudget = [SELECT Id, User__c, Budget_Amount__c, Renewal_Budget_Amount__c, Renewal_Adjustment__c, FYFQ__c FROM NOTRA_Budget__c WHERE User__c = :userId AND FYFQ__c = :qtr.FormattedString ORDER BY CreatedDate DESC LIMIT 1];

        if (notraBudget.size() > 0) {
            notraBudgetToUpdate = notraBudget[0];
        } else {
            notraBudgetToUpdate = new NOTRA_Budget__c(User__c = userId, FYFQ__c = fyfq);
        }

        notraBudgetToUpdate.Renewal_Adjustment__c = adjustment;

        try {
            upsert notraBudgetToUpdate;
            success = true;
        } catch(Exception ex) {
            System.debug('>>>> Exception occurred while updating NOTRA Renewal Adjustment. ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }

        return success;
    }
    
    @RemoteAction
    public static Boolean saveNotraComments(Id userId, String fyfq, String level, String comments) {
        Boolean success = false;

        NOTRA_Budget__c notraBudgetToUpdate;
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        List<NOTRA_Budget__c> notraBudget = [SELECT Id, User__c, Budget_Amount__c, Renewal_Budget_Amount__c, Renewal_Adjustment__c, FYFQ__c FROM NOTRA_Budget__c WHERE User__c = :userId AND FYFQ__c = :qtr.FormattedString ORDER BY CreatedDate DESC LIMIT 1];

        if (notraBudget.size() > 0) {
            notraBudgetToUpdate = notraBudget[0];
        } else {
            notraBudgetToUpdate = new NOTRA_Budget__c(User__c = userId, FYFQ__c = fyfq);
        }

        notraBudgetToUpdate.Comments__c = comments;

        try {
            upsert notraBudgetToUpdate;
            success = true;
        } catch(Exception ex) {
            System.debug('>>>> Exception occurred while updating NOTRA Comments. ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }

        return success;
    }

    /* Commenting this section as the Deal Churn table has to be hidden from UI
    @ReadOnly @RemoteAction
    public static DealChurnSummary getDealChurnSummary(Id userId, String fyfq, String level) {
        DealChurnSummary dealChurnSummary = new DealChurnSummary();
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        Date startDate = qtr.startDate;
        Date endDate = qtr.endDate;

        dealChurnSummary.fyfq = qtr.FormattedString;

        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        System.debug('*** JSON.serialize(allUserIds): ' + JSON.serialize(allUserIds));

        Set<Id> upselplaceholderusers = new Set<Id>();
        if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }

        String forecastCategoryField = 'Forecast_Category_New__c';
        if (level != 'Rep') {
            if (level == 'Manager') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (level == 'Director') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (level == 'VP') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            } else if (level == 'Exec') {
                forecastCategoryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category_New__c';
        }

        String query = 'SELECT SUM(SplitAmount) a FROM OpportunitySplit WHERE Opportunity.CloseDate >= :startDate AND Opportunity.CloseDate <= :endDate AND Forecast_Type__c = \'Renewal\' AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) ';

        List<AggregateResult> closedLostOppsAmount = Database.query(query + ' AND ( Opportunity.StageName like \'11 - Closed Lost\' OR Opportunity.StageName like \'12 - Closed With No Decision\')');
        List<AggregateResult> csmLostOppsAmount = Database.query(query + ' AND Opportunity.IsClosed != True AND Opportunity.Account.Success_Stage__c = \'7 - Lost\'');
        List<AggregateResult> csmRiskOppsAmount = Database.query(query + ' AND Opportunity.IsClosed != True AND Opportunity.Account.Success_Stage__c = \'6 - At Risk\'');

        if (closedLostOppsAmount.size() > 0) {
            dealChurnSummary.lostDealsSummary = (Decimal)closedLostOppsAmount[0].get('a') != null ? (Decimal)closedLostOppsAmount[0].get('a') : 0.0;
        }

        if (csmLostOppsAmount.size() > 0) {
            dealChurnSummary.csmLostDealsSummary = (Decimal)csmLostOppsAmount[0].get('a') != null ? (Decimal)csmLostOppsAmount[0].get('a') : 0.0;
        }

        if (csmRiskOppsAmount.size() > 0) {
            dealChurnSummary.csmRiskDealsSummary = (Decimal)csmRiskOppsAmount[0].get('a') != null ? (Decimal)csmRiskOppsAmount[0].get('a') : 0.0;
        }

        dealChurnSummary.csmTotalDealsSummary = dealChurnSummary.csmLostDealsSummary + dealChurnSummary.csmRiskDealsSummary;

        return dealChurnSummary;
    }
    */

    @RemoteAction
   public static NetNewACVSummary getNetNewACVSummary(String userId, String currentUserLevel, String myUserLevel, String fiscalQuarter, String forecastType, Boolean includeSubordinates, String forecastFamily, Boolean isViewingHistory) {
       NetNewACVSummary summary = new NetNewACVSummary();

       List<Id> allUserIds = new List<Id>();
       allUserIds.add(userId);
       allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

        ZForecastSummary forecastSummary = new ZForecastSummary();
        List<User> users = [SELECT Id, Name, UserRoleId, Level__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0) {
            ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            forecastSummary.UserName = users[0].Name;
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserLevel = currentUserLevel;
            forecastSummary.MyUserLevel = myUserLevel;

            getMyForecast(forecastSummary, userId, qtr.FormattedString, forecastType, allUserIds, forecastFamily);
            getDealSupportSummary(forecastSummary, userId,  qtr, forecastType, includeSubordinates, allUserIds);
            getSummaryNumbers(forecastSummary, userId, qtr, forecastType, includeSubordinates, 'ZIA', allUserIds);
        }

        NOTRASummary notradata = getNOTRASummary(userId, fiscalQuarter, currentUserLevel);

        summary.newACVPlan = forecastSummary.QTRQuota;
        if(!isViewingHistory){
            summary.newACVForecast = forecastSummary.MyForecast;
        }else{
            summary.newACVForecast = forecastSummary.MySummary.QTDClosedTotal;
        }
        summary.notraACVPlan = notradata.notraBudgetAmount;
        summary.notraACVForecast = notradata.notraActuals;

       return summary;
   }

    @RemoteAction
    public static ACVForecastBillings getACVForecastBillings(String userId, String currentUserLevel, String myUserLevel, String fiscalQuarter, String forecastType, Boolean includeSubordinates, String forecastFamily) {
        ACVForecastBillings acvforecast = new ACVForecastBillings();

        ZForecastSummary forecastSummary = new ZForecastSummary();
        ZForecastSummary previousFYForecastSummary = new ZForecastSummary();
        List<User> users = [SELECT Id, Name, UserRoleId, Level__c FROM User WHERE Id = :userId LIMIT 1];
        if(users.size() > 0) {
            ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
            forecastSummary.UserName = users[0].Name;
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserLevel = currentUserLevel;
            forecastSummary.MyUserLevel = myUserLevel;

             // Query all subordinate users
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));

            getDealSupportSummary(forecastSummary, userId, qtr, forecastType, includeSubordinates, allUserIds);
            getMyForecast(forecastSummary, userId, qtr.FormattedString, forecastType, allUserIds, forecastFamily);
            getSummaryNumbers(forecastSummary, userId, qtr, forecastType, includeSubordinates, 'ZIA', allUserIds);

            Date previousFYQuarterStartDate = qtr.StartDate.addYears(-1);
            ZForecastingDataModel.FiscalQuarterInfo previousFYQuarter = new ZForecastingDataModel.FiscalQuarterInfo(previousFYQuarterStartDate);
            previousFYForecastSummary.UserName = users[0].Name;
            previousFYForecastSummary.UserId = users[0].Id;
            previousFYForecastSummary.UserLevel = currentUserLevel;
            previousFYForecastSummary.MyUserLevel = myUserLevel;
            getMyForecast(previousFYForecastSummary, userId, previousFYQuarter.FormattedString, forecastType, allUserIds, forecastFamily);
            getDealSupportSummary(previousFYForecastSummary, userId, previousFYQuarter, forecastType, includeSubordinates, allUserIds);
            getSummaryNumbers(previousFYForecastSummary, userId, previousFYQuarter, forecastType, includeSubordinates, 'ZIA', allUserIds);
        }

        acvforecast.closedQTD = forecastSummary.MySummary.QTDClosedTotal;
        acvforecast.forecast = forecastSummary.MyForecast;
        List<Prior_Year_Forecast__c> entries = [SELECT Id, Forecast_Amount__c, FYFQ__c, User__c 
                                                FROM Prior_Year_Forecast__c
                                               WHERE User__c = :UserId
                                                 AND FYFQ__c = :fiscalQuarter LIMIT 1];

        if (!entries.isEmpty()) {
            acvforecast.PriorYrClosedYTD = entries[0].Forecast_Amount__c;
        }
        
        
        if (acvforecast.forecast != null && acvforecast.PriorYrClosedYTD != null && acvforecast.PriorYrClosedYTD != 0) {
            acvforecast.YonYGrowth = ((acvforecast.forecast / acvforecast.PriorYrClosedYTD) - 1) * 100;
        }
        acvforecast.planacv = forecastSummary.QTRQuota;
        acvforecast.acvtogo = acvforecast.closedQTD != null && acvforecast.forecast  != null ? acvforecast.forecast - acvforecast.closedQTD : 0.0;

        return acvforecast;

    }
    
    @RemoteAction
    public static ForecastingSummaryZPA getForecastSummaryZPA(String userId, String currentUserLevel, String myUserLevel, String fiscalQuarter, String forecastType, String forecastFamily) {
        ForecastingSummaryZPA forecastSummaryZPA = new ForecastingSummaryZPA();
        
        List<User> userlst = [Select Id, LocaleSidKey from User where Id = :userId];
        String userlocale = '';
        if(!userlst.isEmpty()){
            userlocale = userlst[0].LocaleSidKey;
        }
        
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(userId));
        
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
        Date qtrStartDate = qtr.StartDate;
        Date qtrEndDate = qtr.EndDate;
        String fiscalQtr = qtr.FormattedString;
        
        Set<Id> upselplaceholderusers = new Set<Id>();
        if(forecastType == 'upsell' || forecastType == 'all' || forecastType == 'new-upsell'){
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
        }
        
        Set<String> forcasttypeset = new Set<String>();
        if(String.isNotBlank(forecastType) && forecastType == 'new-upsell'){
            forcasttypeset.addAll(forecastType.split('-'));
        }
        
        List<AggregateResult>  quota = [select sum(QuotaAmount__c) q from SalesQuota__c where User__c=:userId AND FYFQ__c=:fiscalQtr and ForecastType__c in :forcasttypeset AND Forecast_Family__c = :forecastFamily];
        if(quota.size() > 0)
        {
            forecastSummaryZPA.QTRQuota = (Decimal)quota[0].get('q');
        }
        
        String query = 'SELECT SUM(ZPA_Amount__c) a FROM OpportunitySplit WHERE ';
        
        String forecastSummaryField = 'Forecast_Category_New__c';
        if (currentUserLevel != 'Rep') {
            if (currentUserLevel == 'Manager') {
                forecastSummaryField = 'DM_Forecast_Category__c';
            } else if (currentUserLevel == 'Director') {
                forecastSummaryField = 'AD_Forecast_Category__c';
            } else if (currentUserLevel == 'RVP') {
                forecastSummaryField = 'RVP_Forecast_Category__c';
            }  else if (currentUserLevel == 'VP') {
                forecastSummaryField = 'VP_Forecast_Category__c';
            } else if (currentUserLevel == 'Exec') {
                forecastSummaryField = 'CRO_Forecast_Category__c';
            }
        } else {
            forecastSummaryField = 'Forecast_Category_New__c';
        }

        System.debug(JSON.serialize(allUserIds));
        System.debug(qtrStartDate + ' | ' + qtrEndDate);
        query = query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\') AND (Opportunity.Total_ZPA_ACV__c > 0)';

        List<AggregateResult> totalNew, totalUpsell;
        totalNew = Database.query(query + ' AND Forecast_Type__c = \'new\'');
        totalUpsell = Database.query(query + ' AND Forecast_Type__c = \'upsell\'');
        Decimal totalForecast = 0;
        if (totalNew != null && totalNew.size() > 0 && (Decimal)totalNew[0].get('a') != null) {
            totalForecast += (Decimal)totalNew[0].get('a');
        }
        if (totalUpsell != null && totalUpsell.size() > 0 && (Decimal)totalUpsell[0].get('a') != null) {
            totalForecast += (Decimal)totalUpsell[0].get('a');
        }

        forecastSummaryZPA.ZPAMLRollup = totalForecast;
        
        

        List<AggregateResult> totalQTDCommit;

        query = 'SELECT SUM(ZPA_Amount__c) a FROM OpportunitySplit WHERE ';

        if (forecastType != null && forecastType != 'all' && forecastType != 'new-upsell') {
            query += ' Forecast_Type__c =: forecastType AND ';
        }else if(forecastType != null && forecastType == 'new-upsell') {
            query += ' Forecast_Type__c in :forcasttypeset AND ';
        } else {
            query += ' Forecast_Type__c IN (\'New\', \'Upsell\', \'Renewal\') AND ';
        }

        totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :qtrEndDate AND Opportunity.CloseDate >= :qtrStartDate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' = \'Closed\' AND Opportunity.IsWon = True');

        forecastSummaryZPA.ZPAClosedQTD = (Decimal)totalQTDCommit[0].get('a');
        
        ZForecastingDataModel.WeekInfo M1W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate);
        Date m1date = qtr.startDate;
        if((qtr.startdate.daysbetween(M1W1Info.enddate.adddays(1)) < 4 && userlocale == 'en-US') || (qtr.startdate.daysbetween(M1W1Info.enddate.adddays(1)) < 5 && userlocale != 'en-US')){
            M1W1Info = new ZForecastingDataModel.WeekInfo(qtr.startDate.adddays(7).toStartOfWeek());
            m1date = qtr.startDate.adddays(7);
        }
        
        String m1w1 = M1W1Info.FormattedString;
        
        if(LoggedInUserLocale != userlocale && (LoggedInUserLocale == 'en_US' || userlocale == 'en_US')){
            if(LoggedInUserLocale == 'en_US'){
                ZForecastingDataModel.WeekInfo weekM1 = new ZForecastingDataModel.WeekInfo(m1date);
                Integer weekplusonem1w1 = Integer.valueOf(M1W1Info.FormattedString) + 1;
                if(weekM1 != null && weekM1.StartDate != null && math.mod(weekM1.StartDate.adddays(1).dayOfYear(), 7) == 0){
                    m1w1 = weekplusonem1w1 != null ? String.valueOf(weekplusonem1w1): M1W1Info.FormattedString;
                }
            }else if(LoggedInUserLocale != 'en_US'){
                ZForecastingDataModel.WeekInfo weekM1 = new ZForecastingDataModel.WeekInfo(m1date);
                Integer weekplusonem1w1 = Integer.valueOf(M1W1Info.FormattedString) - 1;
                if(weekM1 != null && weekM1.StartDate != null && math.mod(weekM1.StartDate.dayOfYear(), 7) == 0){
                    m1w1 = weekplusonem1w1 != null ? String.valueOf(weekplusonem1w1): M1W1Info.FormattedString;
                }
            }
        }
        
        List<Zscaler_Forecast__c> monthEntries = [SELECT FYFQ__c, YYWW__c, Forecast_Amount__c, Forecast_Type__c
                                                     FROM Zscaler_Forecast__c
                                                    WHERE User__c = :userId and Forecast_Family__c = :forecastFamily 
                                                     AND Forecast_Type__c in :forcasttypeset
                                                      AND FYFQ__c = :fiscalQuarter
                                                      AND YYWW__c IN (:m1w1)
                                                    ORDER BY LastModifiedDate DESC];
        Set<String> setWeekFCTypes = new Set<String>();
        for (Zscaler_Forecast__c entry : monthEntries) {
            entry.Forecast_Amount__c = (entry.Forecast_Amount__c != null ? entry.Forecast_Amount__c : 0);
            if (entry.YYWW__c == m1w1 && !setWeekFCTypes.contains('M1W1|' + entry.Forecast_Type__c)) {
                forecastSummaryZPA.FirstMLRollup += entry.Forecast_Amount__c;
                setWeekFCTypes.add('M1W1|' + entry.Forecast_Type__c);
            }
        }
        
        return forecastSummaryZPA;
    }

    @RemoteAction @ReadOnly
    public static BillingsSummary getBillingsSummary(String fyfq) {
        BillingsSummary billingsSummary = new BillingsSummary();

        for (Zscaler_Billings_Summary__c summary : [SELECT Id, FYFQ__c, Bill_To_Go_Summary__c, First_Forecast_Summary__c, Type__c,
                                                            Netsuite_Summary__c, Plan_Billings_Summary__c, Prior_Year_Billings_Summary__c,
                                                            Total_Billings_Summary__c, Y_Y_Growth__c, Comments__c 
                                                      FROM Zscaler_Billings_Summary__c
                                                     WHERE FYFQ__c = :fyfq ORDER BY CreatedDate DESC LIMIT 3]) {
            if (summary.Type__c.equalsIgnoreCase('greater than 1 year')) {
                billingsSummary.greaterThanOneYear.id = summary.id;
                billingsSummary.greaterThanOneYear.billToGoSummary = summary.Bill_To_Go_Summary__c;
                billingsSummary.greaterThanOneYear.firstForecastSummary = summary.First_Forecast_Summary__c;
                billingsSummary.greaterThanOneYear.type = summary.Type__c;
                billingsSummary.greaterThanOneYear.netsuiteSummary = summary.Netsuite_Summary__c;
                billingsSummary.greaterThanOneYear.planBillingsSummary = summary.Plan_Billings_Summary__c;
                billingsSummary.greaterThanOneYear.priorYearBillingsSummary = summary.Prior_Year_Billings_Summary__c;
                billingsSummary.greaterThanOneYear.totalBillingsSummary = summary.Total_Billings_Summary__c;
                billingsSummary.greaterThanOneYear.yOnYGrowth = summary.Y_Y_Growth__c;
                
            } else if (summary.Type__c.equalsIgnoreCase('annual')) {
                billingsSummary.annual.id = summary.id;
                billingsSummary.annual.billToGoSummary = summary.Bill_To_Go_Summary__c;
                billingsSummary.annual.firstForecastSummary = summary.First_Forecast_Summary__c;
                billingsSummary.annual.type = summary.Type__c;
                billingsSummary.annual.netsuiteSummary = summary.Netsuite_Summary__c;
                billingsSummary.annual.planBillingsSummary = summary.Plan_Billings_Summary__c;
                billingsSummary.annual.priorYearBillingsSummary = summary.Prior_Year_Billings_Summary__c;
                billingsSummary.annual.totalBillingsSummary = summary.Total_Billings_Summary__c;
                billingsSummary.annual.yOnYGrowth = summary.Y_Y_Growth__c;
            } else if (summary.Type__c.equalsIgnoreCase('less than 1 year')) {
                billingsSummary.lessThanOneYear.id = summary.id;
                billingsSummary.lessThanOneYear.billToGoSummary = summary.Bill_To_Go_Summary__c;
                billingsSummary.lessThanOneYear.firstForecastSummary = summary.First_Forecast_Summary__c;
                billingsSummary.lessThanOneYear.type = summary.Type__c;
                billingsSummary.lessThanOneYear.netsuiteSummary = summary.Netsuite_Summary__c;
                billingsSummary.lessThanOneYear.planBillingsSummary = summary.Plan_Billings_Summary__c;
                billingsSummary.lessThanOneYear.priorYearBillingsSummary = summary.Prior_Year_Billings_Summary__c;
                billingsSummary.lessThanOneYear.totalBillingsSummary = summary.Total_Billings_Summary__c;
                billingsSummary.lessThanOneYear.yOnYGrowth = summary.Y_Y_Growth__c;
            }
            billingsSummary.comments = summary.Comments__c;
        }
        billingsSummary.greaterThanOneYear.type = 'Greater than 1 Year';
        billingsSummary.annual.type = 'Annual';
        billingsSummary.lessThanOneYear.type = 'Less than 1 Year';
        billingsSummary.total.billToGoSummary = billingsSummary.greaterThanOneYear.billToGoSummary + billingsSummary.annual.billToGoSummary + billingsSummary.lessThanOneYear.billToGoSummary;
        billingsSummary.total.firstForecastSummary = billingsSummary.greaterThanOneYear.firstForecastSummary + billingsSummary.annual.firstForecastSummary + billingsSummary.lessThanOneYear.firstForecastSummary;
        billingsSummary.total.netsuiteSummary = billingsSummary.greaterThanOneYear.netsuiteSummary + billingsSummary.annual.netsuiteSummary + billingsSummary.lessThanOneYear.netsuiteSummary;
        billingsSummary.total.planBillingsSummary = billingsSummary.greaterThanOneYear.planBillingsSummary + billingsSummary.annual.planBillingsSummary + billingsSummary.lessThanOneYear.planBillingsSummary;
        billingsSummary.total.priorYearBillingsSummary = billingsSummary.greaterThanOneYear.priorYearBillingsSummary + billingsSummary.annual.priorYearBillingsSummary + billingsSummary.lessThanOneYear.priorYearBillingsSummary;
        billingsSummary.total.totalBillingsSummary = billingsSummary.greaterThanOneYear.totalBillingsSummary + billingsSummary.annual.totalBillingsSummary + billingsSummary.lessThanOneYear.totalBillingsSummary;
        billingsSummary.total.type = 'Current Forecast-ML';

        billingsSummary.total.yOnYGrowth = billingsSummary.total.priorYearBillingsSummary != null && billingsSummary.total.priorYearBillingsSummary != 0.0 ? ((billingsSummary.total.totalBillingsSummary / billingsSummary.total.priorYearBillingsSummary) - 1) * 100 : 0.0;
        billingsSummary.growthNotGreaterThanOneYear = billingsSummary.annual.priorYearBillingsSummary != null && billingsSummary.lessThanOneYear.priorYearBillingsSummary != null && ((billingsSummary.annual.priorYearBillingsSummary + billingsSummary.lessThanOneYear.priorYearBillingsSummary) != 0.0) ? (((billingsSummary.annual.totalBillingsSummary + billingsSummary.lessThanOneYear.totalBillingsSummary) / (billingsSummary.annual.priorYearBillingsSummary + billingsSummary.lessThanOneYear.priorYearBillingsSummary)) - 1) * 100 : 0.0;

        return billingsSummary;
    }

    @RemoteAction
    public static void SaveBillingsSummary(String fyfq, BillingsSummary billingsSummary) {
        List<Zscaler_Billings_Summary__c> billsummarytosave = new List<Zscaler_Billings_Summary__c>();
        ZForecastingDataModel.FiscalQuarterInfo qtr = new ZForecastingDataModel.FiscalQuarterInfo(fyfq);
        ZForecastingDataModel.FiscalQuarterInfo currentQtr = new ZForecastingDataModel.FiscalQuarterInfo();

        Zscaler_Billings_Summary__c gtoneyr = new Zscaler_Billings_Summary__c();
        gtoneyr.id = billingsSummary.greaterThanOneYear.id ;
        gtoneyr.Bill_To_Go_Summary__c = billingsSummary.greaterThanOneYear.billToGoSummary;
        gtoneyr.First_Forecast_Summary__c = billingsSummary.greaterThanOneYear.firstForecastSummary;
        gtoneyr.Type__c = billingsSummary.greaterThanOneYear.type;
        gtoneyr.FYFQ__c = fyfq;
        gtoneyr.Netsuite_Summary__c = billingsSummary.greaterThanOneYear.netsuiteSummary;
        gtoneyr.Plan_Billings_Summary__c = billingsSummary.greaterThanOneYear.planBillingsSummary;
        gtoneyr.Prior_Year_Billings_Summary__c = billingsSummary.greaterThanOneYear.priorYearBillingsSummary;
        gtoneyr.Comments__c = billingsSummary.comments;
        billsummarytosave.add(gtoneyr);

        Zscaler_Billings_Summary__c annual = new Zscaler_Billings_Summary__c();
        annual.id = billingsSummary.annual.id ;
        annual.Bill_To_Go_Summary__c = billingsSummary.annual.billToGoSummary;
        annual.First_Forecast_Summary__c = billingsSummary.annual.firstForecastSummary;
        annual.Type__c = billingsSummary.annual.type;
        annual.FYFQ__c = fyfq;
        annual.Netsuite_Summary__c = billingsSummary.annual.netsuiteSummary;
        annual.Plan_Billings_Summary__c = billingsSummary.annual.planBillingsSummary;
        annual.Prior_Year_Billings_Summary__c = billingsSummary.annual.priorYearBillingsSummary;
        annual.Comments__c = billingsSummary.comments;
        billsummarytosave.add(annual);

        Zscaler_Billings_Summary__c ltoneyr = new Zscaler_Billings_Summary__c();
        ltoneyr.id = billingsSummary.lessThanOneYear.id ;
        ltoneyr.Bill_To_Go_Summary__c = billingsSummary.lessThanOneYear.billToGoSummary;
        ltoneyr.First_Forecast_Summary__c = billingsSummary.lessThanOneYear.firstForecastSummary;
        ltoneyr.Type__c = billingsSummary.lessThanOneYear.type;
        ltoneyr.FYFQ__c = fyfq;
        ltoneyr.Netsuite_Summary__c = billingsSummary.lessThanOneYear.netsuiteSummary;
        ltoneyr.Plan_Billings_Summary__c = billingsSummary.lessThanOneYear.planBillingsSummary;
        ltoneyr.Prior_Year_Billings_Summary__c = billingsSummary.lessThanOneYear.priorYearBillingsSummary;
        ltoneyr.Comments__c = billingsSummary.comments;
        billsummarytosave.add(ltoneyr);

        upsert billsummarytosave;

    }

    public class ZForecastSummary {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public String UserLevel { get; set; }
        public String MyUserLevel { get; set; }
        public String LevelMinusOneUserLevel { get; set; }
        public Decimal MyForecast { get; set; }
        public Decimal MyLastWeekForecast { get; set; }
        public Decimal MyM1W1Forecast { get; set; }
        public Decimal MyM3W1Forecast { get; set; }
        public Id MyForecastSFID { get; set; }
        public Boolean Locked { get; set; }
        public String FYFQ { get; set; }
        public String YYWW { get; set; }
        public String Comments { get; set; }
        public String WeeklyComments { get; set; }
        public Decimal YonYGrowth { get; set; }
        public Decimal PriorYrClosedYTD { get; set; }

        public DealSupportSummary MySummary { get; set; }
        public DealSupportSummary RSMSummary { get; set; }
        public DealSupportSummary LevelMinusOneSummary { get; set; }
        public DealSupportSummary MyLastWeekSummary { get; set; }
        public DealSupportSummary MyTopLevelSummary { get; set; }

        public Decimal TotalPipeline { get; set; }
        public Decimal TotalUpside { get; set; }
        public Decimal TotalCommit { get; set; }
        public Decimal TotalQTDBooking { get; set; }
        public Decimal TotalMostLikely { get; set; }
        public Decimal TotalBestCase { get; set; }
        public Decimal TotalWorstCase { get; set; }
        public Decimal MyTotalCommit { get; set; }
        public Decimal MyTotalUpside { get; set; }
        public Decimal MyTotalPipeline { get; set; }
        public Decimal MyQTDBooking { get; set; }
        public Decimal QTRQuota { get; set; }
    }

    public class DealSupportSummary {
        public String UserId { get; set; }
        public String UserName { get; set; }
        public List<DealSupportSummaryEntry> MostLikelySummaryEntries { get; set; }
        public List<DealSupportSummaryEntry> BestCaseSummaryEntries { get; set; }
        public List<DealSupportSummaryEntry> WorstCaseSummaryEntries { get; set; }
        public List<DealSupportSummaryEntry> QTDClosedSummaryEntries { get; set; }

        public Decimal MostLikelyTotal { get; set; }
        public Decimal BestCaseTotal { get; set; }
        public Decimal WorstCaseTotal { get; set; }
        public Decimal QTDClosedTotal { get; set; }
    }

    public class DealSupportSummaryEntry {
        public Decimal Amount { get; set; }
        public String FYFQ { get; set; }
        public String YYWW { get; set; }
    }

    public class ForecastingOppListRequest
    {
        public String UserId { get; set; }
        public String UserLevel { get; set; }
        public String MyUserId { get; set; } // Used to set opporunity editable flag
        public String FiscalQtr { get; set; }
        public List<String> Stage { get; set; }
        public List<String> ContractEndDateMonth { get; set; }
        public List<String> ContractEndDateWeek { get; set; }
        public List<String> CustomerSuccessStage { get; set; }
        public List<String> CustomerSentiment { get; set; }
        public List<String> NOTRAFilter { get; set; }
        public List<String> DealValue { get; set; }
        public List<String> ClosingMonth { get; set; }
        public List<String> ClosingWeek { get; set; }
        public List<String> Geo { get; set; }
        public List<String> Region { get; set; }
        public String Probability { get; set; }
        public String SortField { get; set; }
        public Boolean IsAscendingOrder { get; set; }
        public Integer PageIndex { get; set; }
        public String ForecastType { get; set; }
        public String ForecastFamily { get; set; }
        public Boolean impersonateViewAsUser { get; set; }
        public Boolean showzpa { get; set; }
        public Boolean isExporttoExcel { get; set; }
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
        public String CloseWeekDateRange { get; set; }
    }

    public class OpportunityEntry
    {
        public OpportunityEntry() { }

        public OpportunityEntry(Opportunity opp,OpportunitySplit oppSplit, String ForecastFamily, String forecastCategoryField, Boolean showzpa, Set<Id> upselplaceholderusers)
        {
            this.OppId = opp.Id;
            this.SplitId = oppSplit.Id;
            this.OppName = opp.Name;
            this.OppType = opp.Forecast_Type__c;
            this.OppOwner = opp.Owner.Name;
            this.oppTerType = opp.Opportunity_Territory_Type__c;
            if(opp.Opportunity_Sales_Territory__c != null){
                this.oppTerritory = opp.Opportunity_Sales_Territory__r.Name;
                this.oppGEO = opp.Opportunity_Sales_Territory__r.Theater__c;
            }
            this.oppArea = opp.Area__c;
            if(opp.APTS_Primary_Proposal_Lookup__c != null){
                this.TCV = opp.APTS_Primary_Proposal_Lookup__r.APTS_Proposal_Net_Price__c;
            }
            this.numofUsers = opp.Proposed_Number_of_Users__c;
            this.contractTerm = opp.Expected_Term_Months__c;
            this.totalZIAACV = opp.Total_ZIA_ACV__c;
            this.totalZPAACV = opp.Total_ZPA_ACV__c;
            this.totalZIAACV = opp.Total_ZIA_ACV__c;
            
            this.OppSplitType = oppSplit.Forecast_Type__c;
            this.splitownerTerType = oppSplit.Owner_s_Sales_Territory_Name__c;
            if(oppSplit.Owner_Sales_Territory__c != null){
                this.splitownerTerritory = oppSplit.Owner_Sales_Territory__r.Name;
                this.splitOwnerArea = oppSplit.Owner_Sales_Territory__r.Area__c;
            }
            this.splitOwnerGeo = oppSplit.Owner_Sales_Terr_Geo__c;
            this.territoryRegion = oppSplit.Sales_Territory__r.Region__c;
            this.forecastType = oppSplit.Forecast_Type__c;
            if(oppSplit.SE__c != null){
                this.SEName = oppSplit.SE__r.Name;
            }
            this.OppAmountStamp = opp.Amount;
            this.Amount = (showzpa ? (oppSplit.ZPA_Amount__c) : oppSplit.SplitAmount);
            
            
            this.SplitAmountStamp = this.Amount;
            this.Stage = opp.StageName;
            this.RenewalACV = opp.Renewable_ACV__c;
            this.NetsuiteParentID = opp.Account.Netsuite_Parent_ID__c;
            this.SOnumber = opp.Netsuite_Sales_Order_No__c;
            this.RecordEditable = String.isBlank(opp.StageName)?false:(opp.StageName.contains('5 - Contracts Complete') || opp.StageName.contains('Closed Won') || opp.isWon == true)?false:true;
            this.Probability = opp.Probability;
            this.CloseDate = (opp.CloseDate == null) ? '' : formatDate(opp.CloseDate);
            this.CloseDateExcel = (opp.CloseDate == null) ? '' : formatDateExcel(opp.CloseDate);
            this.ContractEndDate = opp.Contract_End_Date_New__c == null ? '' : formatDate(opp.Contract_End_Date_New__c);
            this.ContractEndDateExcel = opp.Contract_End_Date_New__c == null ? '' : formatDateExcel(opp.Contract_End_Date_New__c);
            this.LastF2FMeetingDate = (opp.Account.Last_F2F_Meeting__c == null) ? 'No F2F' : formatDate(opp.Account.Last_F2F_Meeting__c);
            this.LastF2FMeetingDateCSS = (opp.Account.Last_F2F_Meeting__c == null || opp.Account.Last_F2F_Meeting__c < Date.today().adddays(-60)) ? true : false;
            this.LastF2FMeetingDateExcel = (opp.Account.Last_F2F_Meeting__c == null) ? '' : formatDateExcel(opp.Account.Last_F2F_Meeting__c);
            this.LastArchWorkshopDate = (opp.Account.Last_Architecture_Workshop_Date__c == null) ? 'No AW' : formatDate(opp.Account.Last_Architecture_Workshop_Date__c);
            this.LastArchWorkshopDateCSS = (opp.Account.Last_Architecture_Workshop_Date__c == null || opp.Account.Last_Architecture_Workshop_Date__c < Date.today().addmonths(-6)) ? true : false;
            this.LastArchWorkshopDateExcel = (opp.Account.Last_Architecture_Workshop_Date__c == null) ? '' : formatDateExcel(opp.Account.Last_Architecture_Workshop_Date__c);
            this.F2FMeetingsInLast60Days = (opp.Account.F2F_Meetings_In_Last_60_Days__c == null) ? 0 : opp.Account.F2F_Meetings_In_Last_60_Days__c;
            this.ForecastCategory = oppSplit.Forecast_Category_New__c;// opp.ForecastCategoryName;// original is: oppSplit.Forecast_Category__c

            if (forecastCategoryField == 'Forecast_Category_New__c') {
                this.MyForecastCategory = oppSplit.Forecast_Category_New__c;
            } else if (forecastCategoryField == 'DM_Forecast_Category__c') {
                this.MyForecastCategory = oppSplit.DM_Forecast_Category__c;
            } else if (forecastCategoryField == 'AD_Forecast_Category__c') {
                this.MyForecastCategory = oppSplit.AD_Forecast_Category__c;
            } else if (forecastCategoryField == 'RVP_Forecast_Category__c') {
                this.MyForecastCategory = oppSplit.RVP_Forecast_Category__c;
            } else if (forecastCategoryField == 'VP_Forecast_Category__c') {
                this.MyForecastCategory = oppSplit.VP_Forecast_Category__c;
            } else if (forecastCategoryField == 'CRO_Forecast_Category__c') {
                this.MyForecastCategory = oppSplit.CRO_Forecast_Category__c;
            }

            if (forecastCategoryField == 'DM_Forecast_Category__c') {
                this.MyFCLock = oppSplit.DM_Forecast_Category_Lock__c;
            } else if (forecastCategoryField == 'AD_Forecast_Category__c') {
                this.MyFCLock = oppSplit.AD_Forecast_Category_Lock__c;
            } else if (forecastCategoryField == 'RVP_Forecast_Category__c') {
                this.MyFCLock = oppSplit.RVP_Forecast_Category_Lock__c;
            } else if (forecastCategoryField == 'VP_Forecast_Category__c') {
                this.MyFCLock = oppSplit.VP_Forecast_Category_Lock__c;
            } else if (forecastCategoryField == 'CRO_Forecast_Category__c') {
                this.MyFCLock = oppSplit.CRO_Forecast_Category_Lock__c;
            }
            if (forecastCategoryField == 'DM_Forecast_Category__c') {
                this.LevelMinusOneForecastCategory = oppSplit.Forecast_Category_New__c;
            } else if (forecastCategoryField == 'AD_Forecast_Category__c') {
                this.LevelMinusOneForecastCategory = oppSplit.DM_Forecast_Category__c;
            } else if (forecastCategoryField == 'RVP_Forecast_Category__c') {
                this.LevelMinusOneForecastCategory = oppSplit.AD_Forecast_Category__c;
            }else if (forecastCategoryField == 'VP_Forecast_Category__c') {
                this.LevelMinusOneForecastCategory = oppSplit.RVP_Forecast_Category__c;
            } else if (forecastCategoryField == 'CRO_Forecast_Category__c') {
                this.LevelMinusOneForecastCategory = oppSplit.VP_Forecast_Category__c;
            }

            this.Type = opp.Type;
            this.NextStep = opp.NextStep;
            if(upselplaceholderusers.contains(oppSplit.SplitOwnerId)){
                this.OwnerId = oppSplit.Opportunity.OwnerId;
                this.OwnerName = (oppSplit.Opportunity.Owner.Name);
            }else{
                this.OwnerId = oppSplit.SplitOwnerId;
                this.OwnerName = (oppSplit.SplitOwner.Name);
            }

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
            this.CustomerSuccessStage = opp.Account.Success_Stage__c;
            this.CustomerSentiment = opp.Account.Customer_Sentiment__c;
            //Updated at 09APR2018 by Jimmy Li - to seperate the stage value for Inline Editing Values Inlitial Mapping
            /*if(opp.Inline_POC__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatusPreffix = 'Inline POC ';
            }else if (opp.FEVA__c && (opp.Validation_Stage__c != null && opp.Validation_Stage__c != '')){
                this.PocStatusPreffix = 'FEVA ';
            }else if(opp.Validation_Stage__c != null && opp.Validation_Stage__c != ''){
                this.PocStatusPreffix = '';
            }*/
            this.PocStatusPreffix = '';
            if(String.isNotBlank(opp.AccountId))
            {
                this.AccountId = opp.AccountId;
                this.AccountName = opp.Account.Name;
                this.AccountTerType = opp.Account.Territory_Type__c;
                this.AccountArea = opp.Account.Area__c;
                this.AccountGeo = opp.Account.Geo__c;
                if(String.isNotBlank(opp.Account.Sales_Territory__c)){
                    this.AccountTerName = opp.Account.Sales_Territory__r.Name;
                }
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
        public OpportunityEntry(Opportunity opp,OpportunitySplit oppSplit, String ForecastFamily, List<Id> teamUserIds, String viewingUserId, String forecastCategoryField, Boolean showzpa, Set<Id> upselplaceholderusers)
        {
            this(opp, oppSplit, ForecastFamily, forecastCategoryField, showzpa, upselplaceholderusers);
            this.RecordEditable = ( this.RecordEditable && (teamUserIds.contains(opp.OwnerId) || teamUserIds.contains(oppSplit.SplitOwnerId)));
            this.OwnedByViewingUser = (viewingUserId == opp.OwnerId)?true:false;
            //System.debug(viewingUserId +' - '+ opp.OwnerId);
        }

        public String OppId { get; set; }
        public String OppName { get; set; }
        public String OppType { get; set; }
        public String OppSplitType { get; set; }
        public String OppOwner { get; set; }
        public String Stage { get; set; }
        public String CloseDate { get; set; }
        public String CloseDateExcel { get; set; }
        public String ContractEndDate { get; set; }
        public String ContractEndDateExcel { get; set; }
        public String LastArchWorkshopDate { get; set; }
        public Boolean LastArchWorkshopDateCSS { get; set; }
        public String LastArchWorkshopDateExcel { get; set; }
        public String LastF2FMeetingDate { get; set; }
        public Boolean LastF2FMeetingDateCSS { get; set; }
        public String LastF2FMeetingDateExcel { get; set; }
        public Decimal F2FMeetingsInLast60Days { get; set; }
        public String ForecastCategory { get; set; }
        public String LevelMinusOneForecastCategory { get; set; }
        public String MyForecastCategory { get; set; }
        public String Type { get; set; }
        public String NextStep { get; set; }
        public String OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String PrimaryPartnerId { get; set; }
        public String PrimaryPartnerName { get; set; }
        public String PocStatus { get; set; }
        public String CustomerSuccessStage { get; set; }
        public String CustomerSentiment { get; set; }
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
        public Boolean MyFCLock { get; set; } //Added at 14 JUN 2018
        public Decimal Amount { get; set; }
        public Decimal Probability { get; set; }
        public Decimal SplitAmountStamp { get; set; } //Added at 02/04/2018
        public Decimal OppAmountStamp { get; set; } //Added at 02/04/2018
        public String AccountName { get; set; }
        public String AccountTerType{ get; set; }
        public String AccountArea{ get; set; }
        public String AccountTerName{ get; set; }
        public String AccountGeo{ get; set; }
        public String oppTerType{ get; set; }
        public String oppTerritory{ get; set; }
        public String oppArea{ get; set; }
        public String oppGEO{ get; set; }
        public String splitownerTerType{ get; set; }
        public String splitownerTerritory{ get; set; }
        public String splitOwnerArea{ get; set; }
        public String splitOwnerGeo{ get; set; }
        public decimal TCV{ get; set; }
        public decimal numofUsers{ get; set; }
        public decimal contractTerm{ get; set; }
        public decimal totalZIAACV{ get; set; }
        public decimal totalZPAACV{ get; set; }
        public String forecastType{ get; set; }
        public String SEName{ get; set; }
        public Decimal RenewalACV {get; set;}
        public String SOnumber{get; set;}
        public String NetsuiteParentID {get; Set;}
        public String territoryRegion{get; set;}

        private String formatDate(Date d)
        {
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '/' + day + '/' + d.year();
        }
        
        public String formatDateExcel(Date d)
        {
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '-' + day + '-' + d.year();
        }

        //Converts to SObjects for saving
        /*public Opportunity toOpportunity()
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
        }*/

        public Opportunity toOpportunity(String Userlevel)
        {
            Opportunity opp = new Opportunity();
            opp.Id = String.isNotBlank(this.OppId)?(Id)this.OppId:null;
            opp.AccountId = String.isNotBlank(this.AccountId)?(Id)this.AccountId:null;
            opp.Name = this.OppName;
            opp.StageName = this.Stage;
            system.debug('++++'+this.oppType + this.OppSplitType);
            if(this.RecordEditable == true && !(this.oppType == 'Renewal' && this.OppSplitType == 'Upsell'))
            {
                if(Userlevel == 'VP'){
                    opp.VP_Forecast_Category__c = this.MyForecastCategory;
                    opp.VP_Forecast_Category_Lock__c = this.MyFCLock;
                }else if(Userlevel == 'RVP'){
                    opp.RVP_Forecast_Category__c = this.MyForecastCategory;
                    opp.RVP_Forecast_Category_Lock__c = this.MyFCLock;
                }else if(Userlevel == 'Exec'){
                    opp.CRO_Forecast_Category__c = this.MyForecastCategory;
                    opp.CRO_Forecast_Category_Lock__c = this.MyFCLock;
                }else if(Userlevel == 'Director'){
                    opp.AD_Forecast_Category__c = this.MyForecastCategory;
                    opp.AD_Forecast_Category_Lock__c = this.MyFCLock;
                }else if(Userlevel == 'Manager'){
                    opp.DM_Forecast_Category__c = this.MyForecastCategory;
                    opp.DM_Forecast_Category_Lock__c = this.MyFCLock;
                }else{
                    opp.Forecast_Category__c = this.MyForecastCategory;
                }
            }
            if( 'Upside'.equalsIgnoreCase(this.ForecastCategory) ){
                opp.Deal_Path__c = this.DealPath;
            }
            opp.CloseDate = Date.valueOf(this.CloseDate);
            opp.NextStep = this.NextStep;
            return opp;
        }

        public OpportunitySplit toOpportunitySplit(String UserLevel)
        {
            OpportunitySplit split = new OpportunitySplit();
            split.Id = String.isNotBlank(this.SplitId)?(Id)this.SplitId:null;
            //split.Deal_Path__c = this.DealPath;
            if(Userlevel == 'VP'){
                split.VP_Forecast_Category__c = this.MyForecastCategory;
                split.VP_Forecast_Category_Lock__c = this.MyFCLock;
            }else if(Userlevel == 'RVP'){
                split.RVP_Forecast_Category__c = this.MyForecastCategory;
                split.RVP_Forecast_Category_Lock__c = this.MyFCLock;
            }else if(Userlevel == 'Exec'){
                split.CRO_Forecast_Category__c = this.MyForecastCategory;
                split.CRO_Forecast_Category_Lock__c = this.MyFCLock;
            }else if(Userlevel == 'Director'){
                split.AD_Forecast_Category__c = this.MyForecastCategory;
                split.AD_Forecast_Category_Lock__c = this.MyFCLock;
            }else if(Userlevel == 'Manager'){
                split.DM_Forecast_Category__c = this.MyForecastCategory;
                split.DM_Forecast_Category_Lock__c = this.MyFCLock;
            }else{
                split.Forecast_Category_New__c = this.MyForecastCategory;
            }
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

    public class MonthlyForecastSummary {
        public Id userId { get; set; }
        public String fyfq { get; set; }
        List<MonthlyForecastSummaryEntry> entries { get; set; }

        public MonthlyForecastSummary(Id userId, String fyfq) {
            this.userId = userId;
            this.fyfq = fyfq;
            this.entries = new List<MonthlyForecastSummaryEntry>();
        }
    }

    public class MonthlyForecastSummaryEntry {
        public String month { get; set; }
        public Decimal forecastSnapshot { get; set; }
        public Decimal forecastRollup { get; set; }
        public Decimal planSnapshot { get; set; }
        public Boolean highlight { get; set; }
        public Boolean islastmonth { get; set; }

        public MonthlyForecastSummaryEntry(String month, Decimal forecastSnapshot, Decimal forecastRollup, Decimal planSnapshot, Boolean highlight, Boolean islastmonth) {
            this.month = month;
            this.forecastSnapshot = forecastSnapshot;
            this.forecastRollup = forecastRollup;
            this.planSnapshot = planSnapshot;
            this.highlight = highlight;
            this.islastmonth = islastmonth;
        }
    }

    public class WeeklyForecastSummary {
        public Id userId { get; set; }
        public String fyfq { get; set; }
        public List<WeeklyForecastSummaryEntry> entries { get; set; }

        public WeeklyForecastSummary(Id userId, String fyfq) {
            this.userId = userId;
            this.fyfq = fyfq;
            this.entries = new List<WeeklyForecastSummaryEntry>();
        }
    }

    public class WeeklyForecastSummaryEntry {
        public String yyww { get; set; }
        public Decimal snapshotAmount { get; set; }
        public Decimal forecastAmount { get; set; }
        public String headerDate { get; set; }
        public Boolean highlightColumn { get; set; }

        public WeeklyForecastSummaryEntry(String yyww, Decimal snapshotAmount, Decimal forecastAmount, String headerDate) {
            this.yyww = yyww;
            this.snapshotAmount = snapshotAmount;
            this.forecastAmount = forecastAmount;
            this.headerDate = headerDate;
        }

        public WeeklyForecastSummaryEntry(String yyww, Decimal snapshotAmount, Decimal forecastAmount, String headerDate, Boolean highlightColumn) {
            this(yyww, snapshotAmount, forecastAmount, headerDate);
            this.highlightColumn = highlightColumn;
        }
    }

    public class NOTRASummary {
        public String fyfq { get; set; }
        public Decimal renewalPlan { get; set; }
        public Decimal renewalBudget { get; set; }
        public Decimal renewalOnTime { get; set; }
        public Decimal renewalLate { get; set; }
        public Decimal renewalEarly { get; set; }
        public Decimal renewalOnTimeAndLate { get; set; }
        public Decimal renewalAdjustment { get; set; }
        public Decimal notraActuals { get; set; }
        public Decimal notraBudgetAmount { get; set; }
        public Decimal notraBudgetVariance { get; set; }
        public Decimal bdrenewal { get; set; }
        public String comments { get; set; }

        public NOTRASummary() {
            this.renewalPlan = 0.0;
            this.renewalBudget = 0.0;
            this.renewalOnTime = 0.0;
            this.renewalLate = 0.0;
            this.renewalEarly = 0.0;
            this.renewalOnTimeAndLate = 0.0;
            this.renewalAdjustment = 0.0;
            this.notraActuals = 0.0;
            this.notraBudgetAmount = 0.0;
            this.notraBudgetVariance = 0.0;
            this.bdrenewal = 0.0;
            this.comments = '';
        }
    }

    /* Commenting this section as the Deal Churn table has to be hidden from UI
    public class DealChurnSummary {
        public String fyfq { get; set; }
        public Decimal lostDealsSummary { get; set; }
        public Decimal csmLostDealsSummary { get; set; }
        public Decimal csmRiskDealsSummary { get; set; }
        public Decimal csmTotalDealsSummary { get; set; }

        public DealChurnSummary() {
            this.lostDealsSummary = 0.0;
            this.csmLostDealsSummary = 0.0;
            this.csmRiskDealsSummary = 0.0;
            this.csmTotalDealsSummary = 0.0;
        }
    }
    */

    public class NetNewACVSummary {
        public Decimal newACVPlan { get; set; }
        public Decimal newACVForecast { get; set; }
        public Decimal notraACVPlan { get; set; }
        public Decimal notraACVForecast { get; set; }

        public NetNewACVSummary() {
            this.newACVPlan = 0.0;
            this.newACVForecast = 0.0;
            this.notraACVPlan = 0.0;
            this.notraACVForecast = 0.0;
        }
    }
    
    public class ForecastingSummaryZPA {
        public Decimal QTRQuota { get; set; }
        public Decimal ZPAMLRollup { get; set; }
        public Decimal ZPAClosedQTD { get; set; }
        public Decimal FirstMLRollup { get; set; }

        public ForecastingSummaryZPA() {
            this.QTRQuota = 0.0;
            this.ZPAMLRollup = 0.0;
            this.ZPAClosedQTD = 0.0;
            this.FirstMLRollup = 0.0;
        }
    }

    public class ACVForecastBillings{
        public Decimal closedQTD { get; set; }
        public Decimal acvtogo { get; set; }
        public Decimal forecast { get; set; }
        public Decimal YonYGrowth { get; set; }
        public Decimal PriorYrClosedYTD { get; set; }
        public Decimal planacv { get; set; }

        public ACVForecastBillings() {
            this.closedQTD = 0.0;
            this.acvtogo = 0.0;
            this.forecast = 0.0;
            this.YonYGrowth = 0.0;
            this.PriorYrClosedYTD = 0.0;
            this.planacv = 0.0;
        }
    }

    public class BillingsSummary {
        public String fyfq { get; set; }
        public BillingsSummaryEntry greaterThanOneYear { get; set; }
        public BillingsSummaryEntry annual { get; set; }
        public BillingsSummaryEntry lessThanOneYear { get; set; }
        public BillingsSummaryEntry total { get; set; }
        public Decimal growthNotGreaterThanOneYear { get; set; }
        public String comments { get; set; }

        public BillingsSummary() {
            this.fyfq = '';
            this.greaterThanOneYear = new BillingsSummaryEntry();
            this.annual = new BillingsSummaryEntry();
            this.lessThanOneYear = new BillingsSummaryEntry();
            this.total = new BillingsSummaryEntry();
            this.growthNotGreaterThanOneYear = 0.0;
            this.comments = '';
        }
    }

    public class BillingsSummaryEntry {
        public Id id { get; set; }
        public Decimal billToGoSummary { get; set; }
        public Decimal firstForecastSummary { get; set; }
        public String type { get; set; }
        public Decimal netsuiteSummary { get; set; }
        public Decimal planBillingsSummary { get; set; }
        public Decimal priorYearBillingsSummary { get; set; }
        public Decimal totalBillingsSummary { get; set; }
        public Decimal yOnYGrowth { get; set; }
        public Decimal billingsMixForecast { get; set; }
        public Decimal billingsMixPlan { get; set; }
        public Decimal billingsMixPriorYear { get; set; }

        public BillingsSummaryEntry() {
            this.id = null;
            this.billToGoSummary = 0.0;
            this.firstForecastSummary = 0.0;
            this.type = '';
            this.netsuiteSummary = 0.0;
            this.planBillingsSummary = 0.0;
            this.priorYearBillingsSummary = 0.0;
            this.totalBillingsSummary = 0.0;
            this.yOnYGrowth = 0.0;
            this.billingsMixForecast = 0.0;
            this.billingsMixPlan = 0.0;
            this.billingsMixPriorYear = 0.0;
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