/*****************************************************************************************
Name: CreateZPARecordsforAllUsers
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to capture user specific list of opportunity splits for forecasting for current month

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-June-2018      Initial Development
******************************************************************************************/



public class CreateZPARecordsforAllUsers implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String q = '';
    Date monthstartdate = null;
    Date monthenddate = null;
    Date qtrstartdate = null;
    Date qtrenddate = null;
    Date weekstartdate = null;
    ZForecastingDataModel.FiscalQuarterInfo qtr;
    ZForecastingDataModel.WeekInfo week;
    Integer level;
    public CreateZPARecordsforAllUsers(Integer l, Date mstdate, Date meddate, Date qstdate, Date qeddate, ZForecastingDataModel.FiscalQuarterInfo fq, ZForecastingDataModel.WeekInfo fw){
        level = l;
        monthstartdate = mstdate;
        monthenddate = meddate;
        qtrstartdate = qstdate;
        qtrenddate = qeddate;
        qtr = fq;
        week = fw;
        ZForecastingDataModel.WeekInfo nextWeek = new ZForecastingDataModel.WeekInfo(date.today());
        weekstartdate = nextWeek.StartDate;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Department, LocaleSidKey, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from User Where  isActive = true and ForecastEnabled__c=true ';
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
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalAmount = new List<OpportunitySplit>();
            List<Zscaler_Forecast__c> fslst = new List<Zscaler_Forecast__c>();
            Set<String> types = new Set<String>{'New','Upsell', 'Renewal'};
            Id userId = users[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            Date msd = monthstartdate;
            Date med = monthenddate;
            
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
            query += 'Select Id, OpportunityId, Split, ZPA_Amount__c, SplitAmount, SplitNote, SplitOwnerId, SplitPercentage, SplitTypeId, Forecast_Category__c, Forecast_Type__c, Opportunity.CloseDate, '+forecastSummaryField + ' from OpportunitySplit where ';
            
            totalAmount = Database.query(query + ' Opportunity.CloseDate <= :qtrenddate AND Opportunity.CloseDate >= :qtrstartdate AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\',\'Closed\')  AND (Opportunity.Total_ZPA_ACV__c > 0)');
                   
            System.debug(totalAmount);                 
           
            Double zpa_new = 0.0;
            Double zpa_upsell = 0.0;
            Double zpa_renewal = 0.0;
            for(OpportunitySplit os: totalAmount){
                
                if(os.Forecast_Type__c == 'New' && os.ZPA_Amount__c != null){
                    zpa_new += os.ZPA_Amount__c;
                }else if(os.Forecast_Type__c == 'Upsell' && os.ZPA_Amount__c != null){
                    zpa_upsell += os.ZPA_Amount__c;
                }else if(os.Forecast_Type__c == 'Renewal' && os.ZPA_Amount__c != null){
                    zpa_renewal += os.ZPA_Amount__c;
                }
            }
            for(String s: types){
                
                Zscaler_Forecast__c fsrec1 = new Zscaler_Forecast__c();
                fsrec1.OwnerId = userId;
                fsrec1.User__c = userId;
                fsrec1.Forecast_Type__c = s;
                fsrec1.Forecast_Family__c = 'ZPA';
                fsrec1.Month__c = String.valueOf(msd.month());
                fsrec1.FYFQ__c = qtr.FormattedString;
                fsrec1.YYWW__c = yyww;
                if(s == 'New'){
                    fsrec1.Forecast_Amount__c = zpa_new;
                }else if(s == 'Upsell'){
                    fsrec1.Forecast_Amount__c = zpa_upsell;
                }else{
                    fsrec1.Forecast_Amount__c = zpa_renewal;
                }
                fslst.add(fsrec1);
            }
            Database.SaveResult[] srList = database.insert(fslst, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    String s = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        if(srList.indexOf(sr) != -1 && !fslst.isEmpty() && fslst.size() > srList.indexOf(sr) && fslst[srList.indexOf(sr)] != null){
                            s = fslst[srList.indexOf(sr)].User__c;
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
                mail1.setSubject('ZPA Forecast records Batch Failure result');
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
                mail.setSubject('ZPA Forecast records Batch Success result ');
                mail.setPlainTextBody('ZPA Forecast records batch has been executed Successfully and processed '+ successlst.size() + ' records');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}