/*****************************************************************************************
Name: CaptureUserForecastSnapshot
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to capture user specific list of opportunity splits for forecasting

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           28-May-2018      Initial Development
******************************************************************************************/



global class CaptureUserForecastSnapshot implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String q = '';
    global CaptureUserForecastSnapshot(String qry){
        q = qry;
    }
    global Database.QueryLocator start(Database.BatchableContext context){
        
        return Database.getQueryLocator(q);
    }

    global void execute (Database.BatchableContext context, List<User> users){
        try{
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalMostLikely = new List<OpportunitySplit>();
            List<OpportunitySplit> totalBestCase = new List<OpportunitySplit>();
            List<OpportunitySplit> totalWorstCase = new List<OpportunitySplit>();
            List<OpportunitySplit> totalQTDCommit = new List<OpportunitySplit>();
            Map<String,Deal_Support_Summary_Snapshot__c> fslst = new Map<String,Deal_Support_Summary_Snapshot__c>();
            Set<String> types = new Set<String>{'New','Upsell', 'Renewal'};
            Id userId = users[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            
            Set<Id> upselplaceholderusers = new Set<Id>();
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            
            String query = '';
            
            String forecastSummaryField = 'Forecast_Category_New__c';
            if (users[0].Level__c != 'Rep') {
                if (users[0].Level__c == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (users[0].Level__c == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (users[0].Level__c == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (users[0].Level__c == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                } else if (users[0].Level__c == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }
            query += 'Select Id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, '+forecastSummaryField + ' from OpportunitySplit where ';
            
            
            
            //The below logic is for week's start date
            ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(date.today().toStartOfWeek());
            ForecastingDataModel.WeekInfo week = new ForecastingDataModel.WeekInfo(date.today().toStartOfWeek());
            Date startdate = qtr.startdate;
            Date enddate = qtr.enddate;
            
            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            
            Double revenue_new = 0.0;
            Double revenue_upsell = 0.0;
            Double revenue_renewal = 0.0;
            for(OpportunitySplit os: totalMostLikely){
                if(os.Forecast_Type__c == 'New'){
                    revenue_new += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Upsell'){
                    revenue_upsell += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Renewal'){
                    revenue_renewal += os.SplitAmount;
                }
            }
            for(String s: types){
                Deal_Support_Summary_Snapshot__c fsrec = new Deal_Support_Summary_Snapshot__c();
                fsrec.OwnerId = userId;
                fsrec.User__c = userId;
                fsrec.Forecasting_Type__c = s;
                fsrec.Month__c = date.today().toStartOfWeek().month();
                fsrec.Quarter__c = qtr.FormattedString;
                fsrec.Week__c = week.FormattedString; 
                if(s == 'New'){
                    fsrec.Most_Likely__c = revenue_new;
                }else if(s == 'Upsell'){
                    fsrec.Most_Likely__c = revenue_upsell;
                }else{
                    fsrec.Most_Likely__c = revenue_renewal;
                }
                fslst.put(s,fsrec);
            }
            totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
            
            revenue_new = 0.0;
            revenue_upsell = 0.0;
            revenue_renewal = 0.0;
            for(OpportunitySplit os: totalBestCase){
                if(os.Forecast_Type__c == 'New'){
                    revenue_new += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Upsell'){
                    revenue_upsell += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Renewal'){
                    revenue_renewal += os.SplitAmount;
                }
            }
            for(String s: types){
                if(s == 'New' && fslst.containskey(s)){
                    fslst.get(s).Best_Case__c = revenue_new;
                }else if(s == 'Upsell' && fslst.containskey(s)){
                    fslst.get(s).Best_Case__c = revenue_upsell;
                }else if(fslst.containskey(s)){
                    fslst.get(s).Best_Case__c = revenue_renewal;
                }
            }
            
            totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Closed\', \'Commit\')');
    
            revenue_new = 0.0;
            revenue_upsell = 0.0;
            revenue_renewal = 0.0;
            for(OpportunitySplit os: totalWorstCase){
                if(os.Forecast_Type__c == 'New'){
                    revenue_new += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Upsell'){
                    revenue_upsell += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Renewal'){
                    revenue_renewal += os.SplitAmount;
                }
            }
            for(String s: types){
                if(s == 'New' && fslst.containskey(s)){
                    fslst.get(s).Worst_Case__c = revenue_new;
                }else if(s == 'Upsell' && fslst.containskey(s)){
                    fslst.get(s).Worst_Case__c = revenue_upsell;
                }else if(fslst.containskey(s)){
                    fslst.get(s).Worst_Case__c = revenue_renewal;
                }
            }
            
            totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' = \'Closed\' AND Opportunity.IsWon = True');
            
            revenue_new = 0.0;
            revenue_upsell = 0.0;
            revenue_renewal = 0.0;
            for(OpportunitySplit os: totalQTDCommit){
                if(os.Forecast_Type__c == 'New'){
                    revenue_new += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Upsell'){
                    revenue_upsell += os.SplitAmount;
                }else if(os.Forecast_Type__c == 'Renewal'){
                    revenue_renewal += os.SplitAmount;
                }
            }
            for(String s: types){
                if(s == 'New' && fslst.containskey(s)){
                    fslst.get(s).QTD__c = revenue_new;
                }else if(s == 'Upsell' && fslst.containskey(s)){
                    fslst.get(s).QTD__c = revenue_upsell;
                }else if(fslst.containskey(s)){
                    fslst.get(s).QTD__c = revenue_renewal;
                }
            }
            
            Database.SaveResult[] srList = database.insert(fslst.values(), false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    String s = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if(srList.indexOf(sr) != -1 && !fslst.values().isEmpty() && fslst.values().size() > srList.indexOf(sr) && fslst.values()[srList.indexOf(sr)] != null){
                            s = fslst.values()[srList.indexOf(sr)].User__c;
                        }
                        if(s!= ''){
                            errorlst.add(sr.getId() + ' - ' + err.getMessage() +' for the user ' + s);
                        }else{
                            errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
            
            
            
            //The below logic if for date.today() and if the quarter varies in this week
            ForecastingDataModel.FiscalQuarterInfo qtr1 = new ForecastingDataModel.FiscalQuarterInfo(date.today());
            ForecastingDataModel.WeekInfo week1 = new ForecastingDataModel.WeekInfo(date.today());
            
            if(qtr.FormattedString != qtr1.FormattedString || Test.isRunningTest()){
                fslst = new Map<String,Deal_Support_Summary_Snapshot__c>();
                startdate = qtr1.startdate;
                enddate = qtr1.enddate;
                totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
                
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                for(OpportunitySplit os: totalMostLikely){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                }
                for(String s: types){
                    Deal_Support_Summary_Snapshot__c fsrec = new Deal_Support_Summary_Snapshot__c();
                    fsrec.OwnerId = userId;
                    fsrec.User__c = userId;
                    fsrec.Forecasting_Type__c = s;
                    fsrec.Month__c = date.today().month();
                    fsrec.Quarter__c = qtr1.FormattedString;
                    fsrec.Week__c = week1.FormattedString; 
                    if(s == 'New'){
                        fsrec.Most_Likely__c = revenue_new;
                    }else if(s == 'Upsell'){
                        fsrec.Most_Likely__c = revenue_upsell;
                    }else{
                        fsrec.Most_Likely__c = revenue_renewal;
                    }
                    fslst.put(s,fsrec);
                }
                totalBestCase = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\', \'Best Case\')');
                
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                for(OpportunitySplit os: totalBestCase){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                }
                for(String s: types){
                    if(s == 'New' && fslst.containskey(s)){
                        fslst.get(s).Best_Case__c = revenue_new;
                    }else if(s == 'Upsell' && fslst.containskey(s)){
                        fslst.get(s).Best_Case__c = revenue_upsell;
                    }else if(fslst.containskey(s)){
                        fslst.get(s).Best_Case__c = revenue_renewal;
                    }
                }
                
                totalWorstCase = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Closed\', \'Commit\')');
        
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                for(OpportunitySplit os: totalWorstCase){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                }
                for(String s: types){
                    if(s == 'New' && fslst.containskey(s)){
                        fslst.get(s).Worst_Case__c = revenue_new;
                    }else if(s == 'Upsell' && fslst.containskey(s)){
                        fslst.get(s).Worst_Case__c = revenue_upsell;
                    }else if(fslst.containskey(s)){
                        fslst.get(s).Worst_Case__c = revenue_renewal;
                    }
                }
                
                totalQTDCommit = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' = \'Closed\' AND Opportunity.IsWon = True');
                
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                for(OpportunitySplit os: totalQTDCommit){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                }
                for(String s: types){
                    if(s == 'New' && fslst.containskey(s)){
                        fslst.get(s).QTD__c = revenue_new;
                    }else if(s == 'Upsell' && fslst.containskey(s)){
                        fslst.get(s).QTD__c = revenue_upsell;
                    }else if(fslst.containskey(s)){
                        fslst.get(s).QTD__c = revenue_renewal;
                    }
                }
                
                srList = database.insert(fslst.values(), false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        successlst.add(sr.getId());
                    }
                    else {
                        String s = '';
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            if(srList.indexOf(sr) != -1 && !fslst.values().isEmpty() && fslst.values().size() > srList.indexOf(sr) && fslst.values()[srList.indexOf(sr)] != null){
                                s = fslst.values()[srList.indexOf(sr)].User__c;
                            }
                            if(s!= ''){
                                errorlst.add(sr.getId() + ' - ' + err.getMessage() +' for the user ' + s);
                            }else{
                                errorlst.add(sr.getId() + ' - ' + err.getMessage());
                            }
                        }
                    }
                }
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
        
    }

    global void finish(Database.BatchableContext context){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            
            
            if(!errorlst.isEmpty()){
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
                if ( owea.size() > 0 ) {
                    mail1.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail1.setsenderDisplayName('Sales Ops System Admin');
                }
                mail1.setSubject('User Forecasting Snapshot Failure result');
                mail1.setPlainTextBody('Below are the Ids of records that have failed:' + errorlst);
                messageList.add(mail1);
            }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {Label.BSYS_INFO});
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setSubject('User Forecasting Snapshot success result ');
                mail.setPlainTextBody('Forecasting Snapshot batch has been executed Successfully and processed '+ successlst.size() + ' records');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}