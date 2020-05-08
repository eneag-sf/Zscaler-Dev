/*****************************************************************************************
Name: CaptureWeeklyForecastBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to capture user specific list of opportunity splits for forecasting for next to next week

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-June-2018      Initial Development
******************************************************************************************/



public class CaptureWeeklyForecastBatch implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String q = '';
    Date weekstartdate = null;
    Date weekenddate = null;
    Date qtrstartdate = null;
    Date qtrenddate = null;
    ZForecastingDataModel.WeekInfo week;
    ZForecastingDataModel.FiscalQuarterInfo qtr;
    Integer level;
    public CaptureWeeklyForecastBatch(Integer l, Date wstdate, Date weddate, Date qstdate, Date qeddate, ZForecastingDataModel.FiscalQuarterInfo fq, ZForecastingDataModel.WeekInfo fw){
        level = l;
        weekstartdate = wstdate;
        weekenddate = weddate;
        qtrstartdate = qstdate;
        qtrenddate = qeddate;
        qtr = fq;
        week = fw;
        
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c, LocaleSidKey from User Where  isActive = true and ForecastEnabled__c=true ';
        if(level != null)
        {
            query += ' and ForecastLevel__c=\'Level '+level+'\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<User> users){
        try{
            String yyww = week.FormattedString;
            Integer weekplusone = Integer.valueOf(week.FormattedString) + 1;
            if(UserInfo.getLocale() == 'en_US' && !users.isEmpty() && users[0].LocaleSidKey != 'en_US' && weekstartdate != null && math.mod(weekstartdate.adddays(1).dayOfYear(), 7) == 0){
                yyww = week.FormattedString != null && week.FormattedString != '' ? String.valueOf(weekplusone): week.FormattedString;
                
            }
            
            Id weeklyrtid = Schema.SObjectType.Linearity_Snapshot__c.getRecordTypeInfosByName().get('Weekly Forecast').getRecordTypeId();
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalAmount = new List<OpportunitySplit>();
            Map<String,Linearity_Snapshot__c> fslst = new Map<String,Linearity_Snapshot__c>();
            Set<String> types = new Set<String>{'New','Upsell', 'Renewal'};
            Id userId = users[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            
            Set<Id> upselplaceholderusers = new Set<Id>();
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            
            String query = '';
            Boolean execute = false;
            
            String forecastSummaryField = 'Forecast_Category_New__c';
            if (users[0].Level__c != 'Rep') {
                if (users[0].Level__c == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (users[0].Level__c == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (users[0].Level__c == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                } else if (users[0].Level__c == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (users[0].Level__c == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }
            query += 'Select Id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, Opportunity.CloseDate, '+forecastSummaryField + ' from OpportunitySplit where ';
            
            if(weekstartdate >= qtrstartdate && weekstartdate <= qtrenddate && weekenddate <= qtrenddate){
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :weekenddate AND Opportunity.CloseDate >= :weekstartdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Best Case\', \'Commit\')');
                execute = true;
            }else if(weekstartdate >= qtrstartdate && weekstartdate <= qtrenddate && weekenddate > qtrenddate){
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :qtrenddate AND Opportunity.CloseDate >= :weekstartdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Best Case\', \'Commit\')');
                execute = true;
            }else if(weekstartdate < qtrstartdate && weekenddate <= qtrenddate){
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :weekenddate AND Opportunity.CloseDate >= :qtrstartdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Best Case\', \'Commit\')');
                execute = true;
            }
            if(execute){
                Double revenue_new = 0.0;
                Double revenue_upsell = 0.0;
                Double revenue_renewal = 0.0;
                Integer monthoftheweek = 0;
                for(OpportunitySplit os: totalAmount){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                    monthoftheweek = os.Opportunity.CloseDate.month();
                }
                for(String s: types){
                    Linearity_Snapshot__c fsrec = new Linearity_Snapshot__c();
                    fsrec.RecordTypeId = weeklyrtid;
                    fsrec.OwnerId = userId;
                    fsrec.User__c = userId;
                    fsrec.Forecast_Type__c = s;
                    fsrec.Month__c = monthoftheweek;
                    fsrec.FYFQ__c = qtr.FormattedString;
                    fsrec.YYWW__c = yyww;
                    fsrec.Forecast_Family__c = 'ZIA'; 
                    if(s == 'New'){
                        fsrec.Amount__c = revenue_new;
                    }else if(s == 'Upsell'){
                        fsrec.Amount__c = revenue_upsell;
                    }else{
                        fsrec.Amount__c = revenue_renewal;
                    }
                    fslst.put(s,fsrec);
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
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
        
    }

    public void finish(Database.BatchableContext context){
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
                mail1.setSubject('Weekly Forecast Batch Failure result');
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
                mail.setSubject('Weekly Forecast Batch Success result ');
                mail.setPlainTextBody('Weekly Forecast batch has been executed Successfully and processed '+ successlst.size() + ' records');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}