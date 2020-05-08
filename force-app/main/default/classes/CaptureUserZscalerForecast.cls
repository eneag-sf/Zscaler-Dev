/*****************************************************************************************
Name: CaptureUserZscalerForecast
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
1.0            Abhishek V           01-June-2018      Initial Development
******************************************************************************************/

global class CaptureUserZscalerForecast implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    global final Integer level;
    global final String qtr;
    global final String week;
    global final Date nextweekstartdate;
    global final Date enddate;
    global final Date startdate;
    
    global CaptureUserZscalerForecast(Integer l, String q, String w, Date nwsd, Date quarterstartdate, Date quarterenddate)
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
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalMostLikely = new List<OpportunitySplit>(), totalAmount = new List<OpportunitySplit>();
            List<Zscaler_Forecast__c> existingForecasts = [select Id, Archived__c, Archived_Date__c, Forecast_Amount__c, Forecast_Family__c, Forecast_Type__c, FYFQ__c, Locked__c, Month__c, Unique_Key__c, User__c, YYWW__c, Comments__c from Zscaler_Forecast__c where User__c in :scope and YYWW__c != null and Archived__c = false];
            List<Zscaler_Forecast__c> existingFutureForecasts = [select Id, Archived__c, Archived_Date__c, Forecast_Amount__c, Forecast_Family__c, Forecast_Type__c, FYFQ__c, Locked__c, Month__c, Unique_Key__c, User__c, YYWW__c, Comments__c from Zscaler_Forecast__c where User__c in :scope and FYFQ__c = :qtr and YYWW__c = null and Archived__c = false];
            List<Zscaler_Forecast__c> newForecasts = new List<Zscaler_Forecast__c>();
            String level = scope[0].Level__c;
            Id userId = scope[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            
            Set<Id> upselplaceholderusers = new Set<Id>();
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            
            system.debug('Unlocked Forecasts ::'+existingForecasts);
            system.debug('Existing Future Forecasts ::'+existingFutureForecasts);
            for(Zscaler_Forecast__c existingFuture : existingFutureForecasts)
            {
               
                existingFuture.YYWW__c = week;
                newForecasts.add(existingFuture);
            }
    
            for(Zscaler_Forecast__c existing : existingForecasts)
            {
                if(existing.FYFQ__c == qtr && existing.YYWW__c >= week)
                {
                    continue;
                }
                existing.Archived_Date__c = DateTime.now();
                existing.Archived__c = true;
                system.debug('Existing Record ::'+existing);
                
                Boolean foundFuture = false;
                for(Zscaler_Forecast__c existingFuture : existingFutureForecasts)
                {
                    if(existingFuture.User__c == existing.User__c && existingFuture.Forecast_Type__c == existing.Forecast_Type__c  && existingFuture.Forecast_Family__c == existing.Forecast_Family__c)
                    {
                        foundFuture = true;
                        System.debug('Found Future ZIA');
                        continue;
                    }
                }
                if(!foundFuture)
                {
                    Zscaler_Forecast__c newFc = existing.clone(false, false, false, false);
                    newFc.Archived__c = false;
                    newFc.FYFQ__c = qtr;
                    newFc.YYWW__c = week;
                    newFc.Archived_Date__c = null;
                    newFc.Month__c = String.valueOf(nextweekstartdate.month());
                    newFc.OwnerId = existing.User__c; //added as a part of RBAC
                    System.debug('Creating FC::'+newFc);
                    newForecasts.add(newFc);
                }
                
            }
            
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
            query += 'Select Id, ZPA_Amount__c, OpportunityId, Split, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, Opportunity.Total_ZPA_ACV__c, SplitTypeId, Forecast_Category__c, Forecast_Type__c, '+forecastSummaryField + ' from OpportunitySplit where ';
                
                
            totalMostLikely = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds))  AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Closed\', \'Commit\')');
            
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
            
            totalAmount = Database.query(query + ' Opportunity.CloseDate <= :enddate AND Opportunity.CloseDate >= :startdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\',\'Closed\')  AND (Opportunity.Total_ZPA_ACV__c > 0)');
            
            Double revenue_new_zpa = 0.0;
            Double revenue_upsell_zpa = 0.0;
            Double revenue_renewal_zpa = 0.0;
            for(OpportunitySplit os: totalAmount){
                
                if(os.Forecast_Type__c == 'New' && os.ZPA_Amount__c != null){
                    revenue_new_zpa += os.ZPA_Amount__c;
                }else if(os.Forecast_Type__c == 'Upsell' && os.ZPA_Amount__c != null){
                    revenue_upsell_zpa += os.ZPA_Amount__c;
                }else if(os.Forecast_Type__c == 'Renewal' && os.ZPA_Amount__c != null){
                    revenue_renewal_zpa += os.ZPA_Amount__c;
                }
            }
            
            for(Zscaler_Forecast__c Futurerec : newForecasts)
            {
                if(Futurerec.Locked__c && level == 'Rep'){
                    Futurerec.Locked__c = false;
                }
                
                if(!Futurerec.Locked__c && Futurerec.Forecast_Family__c == 'ZIA'){
                    if(Futurerec.Forecast_Type__c == 'New'){
                        Futurerec.Forecast_Amount__c = revenue_new;
                    }else if(Futurerec.Forecast_Type__c == 'Upsell'){
                        Futurerec.Forecast_Amount__c = revenue_upsell;
                    }else{
                        Futurerec.Forecast_Amount__c = revenue_renewal;
                    }
                }else if(!Futurerec.Locked__c && Futurerec.Forecast_Family__c == 'ZPA'){
                    if(Futurerec.Forecast_Type__c == 'New'){
                        Futurerec.Forecast_Amount__c = revenue_new_zpa;
                    }else if(Futurerec.Forecast_Type__c == 'Upsell'){
                        Futurerec.Forecast_Amount__c = revenue_upsell_zpa;
                    }else{
                        Futurerec.Forecast_Amount__c = revenue_renewal_zpa;
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
            
            Database.UpsertResult[] srList1 = database.upsert(newForecasts,Zscaler_Forecast__c.fields.Id, false);
            for (Database.UpsertResult sr : srList1) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    String s = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if(srList1.indexOf(sr) != -1 && !newForecasts.isEmpty() && newForecasts.size() > srList1.indexOf(sr) && newForecasts[srList1.indexOf(sr)] != null){
                            s = newForecasts[srList1.indexOf(sr)].User__c;
                        }
                        if(s!= ''){
                            errorlst.add(sr.getId() + ' - ' + err.getMessage() +' for the user ' + s);
                        }else{
                            errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
        
    }

    global void finish(Database.BatchableContext context){
            List<Zscaler_Forecast__c> inactiveuserszforlst = [Select Id, Archived__c, Archived_Date__c from Zscaler_Forecast__c where User__c in (Select Id from User where isActive = false or ForecastEnabled__c=false) and Archived__c = false limit 50000];
            
            for(Zscaler_Forecast__c zfore: inactiveuserszforlst){
                zfore.Archived__c = true;
                zfore.Archived_Date__c = date.today();
            }
            
            Database.SaveResult[] srList = database.update(inactiveuserszforlst, false);
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
        if(!Test.isRunningTest()){ 
		Messaging.sendEmail(messageList);
        }
    }
}