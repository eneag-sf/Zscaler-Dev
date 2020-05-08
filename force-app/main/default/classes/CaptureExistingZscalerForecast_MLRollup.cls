/*****************************************************************************************
Name: CaptureExistingZscalerForecast_MLRollup
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to capture user specific Zscaler Forecast records

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           08-June-2018      Initial Development
******************************************************************************************/

global class CaptureExistingZscalerForecast_MLRollup implements Database.Batchable<sObject>, Database.Stateful{
    global List<String> errorlst = new List<String>();
    global List<String> successlst = new List<String>();
    global final Integer level;
    global final String qtr;
    global final String week;
    global final Date nextweekstartdate;
    global final Date enddate;
    global final Date startdate;
    
    global CaptureExistingZscalerForecast_MLRollup(Integer l, String q, String w, Date nwsd, Date quarterstartdate, Date quarterenddate)
    {
        level = l;
        qtr = q;
        week = w;
        nextweekstartdate = nwsd;
        enddate = quarterenddate;
        startdate = quarterstartdate;
    }

    global Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from User Where  isActive = true and ForecastEnabled__c=true ';
        if(level != null)
        {
            query += ' and ForecastLevel__c=\'Level '+level+'\'';
        }
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext context, List<User> scope){
        try{
            Set<Id> upselplaceholderusers = new Set<Id>();
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalMostLikely = new List<OpportunitySplit>();
            List<Zscaler_Forecast__c> existingForecasts = [select Id, Archived__c, Archived_Date__c, Forecast_Amount__c, Forecast_Family__c, Forecast_Type__c, FYFQ__c, Locked__c, Month__c, Unique_Key__c, User__c, YYWW__c, Comments__c from Zscaler_Forecast__c where Forecast_Family__c = 'ZIA' and User__c in :scope and YYWW__c != null and Archived__c = false];
            Id userId = scope[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            system.debug('Unlocked Forecasts ::'+existingForecasts);
            
            String query = '';
            String forecastSummaryField = 'Forecast_Category_New__c';
            if (scope[0].Level__c != 'Rep') {
                if (scope[0].Level__c == 'Manager') {
                    forecastSummaryField = 'DM_Forecast_Category__c';
                } else if (scope[0].Level__c == 'Director') {
                    forecastSummaryField = 'AD_Forecast_Category__c';
                } else if (scope[0].Level__c == 'RVP') {
                    forecastSummaryField = 'RVP_Forecast_Category__c';
                } else if (scope[0].Level__c == 'VP') {
                    forecastSummaryField = 'VP_Forecast_Category__c';
                } else if (scope[0].Level__c == 'Exec') {
                    forecastSummaryField = 'CRO_Forecast_Category__c';
                }
            } else {
                forecastSummaryField = 'Forecast_Category_New__c';
            }
            query += 'Select Id, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, '+forecastSummaryField + ' from OpportunitySplit where ';
                
                
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
            
            for(Zscaler_Forecast__c Futurerec : existingForecasts)
            {
                if(!Futurerec.Locked__c){
                    if(Futurerec.Forecast_Type__c == 'New'){
                        Futurerec.Forecast_Amount__c = revenue_new;
                    }else if(Futurerec.Forecast_Type__c == 'Upsell'){
                        Futurerec.Forecast_Amount__c = revenue_upsell;
                    }else{
                        Futurerec.Forecast_Amount__c = revenue_renewal;
                    }
                }
            }
            
            Database.SaveResult[] srList = database.update(existingForecasts, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorlst.add(sr.getId() + ' - ' + err.getMessage());
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
                mail1.setSubject('Zscaler forecast batch Failure result');
                mail1.setPlainTextBody('Below are the details of records that have failed:' + errorlst);
                messageList.add(mail1);
            }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {Label.BSYS_INFO});
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setSubject('Zscaler forecast batch success result ');
                mail.setPlainTextBody('Zscaler forecast batch has been executed Successfully and processed '+ successlst.size() + ' records');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}