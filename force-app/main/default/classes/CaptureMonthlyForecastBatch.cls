/*****************************************************************************************
Name: CaptureMonthlyForecastBatch
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



public class CaptureMonthlyForecastBatch implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String q = '';
    Date monthstartdate = null;
    Date monthenddate = null;
    Date qtrstartdate = null;
    Date qtrenddate = null;
    ZForecastingDataModel.FiscalQuarterInfo qtr;
    ZForecastingDataModel.WeekInfo week;
    Integer level;
    public CaptureMonthlyForecastBatch(Integer l, Date mstdate, Date meddate, Date qstdate, Date qeddate, ZForecastingDataModel.FiscalQuarterInfo fq, ZForecastingDataModel.WeekInfo fw){
        level = l;
        monthstartdate = mstdate;
        monthenddate = meddate;
        qtrstartdate = qstdate;
        qtrenddate = qeddate;
        qtr = fq;
        week = fw;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from User Where  isActive = true and ForecastEnabled__c=true ';
        if(level != null)
        {
            query += ' and ForecastLevel__c=\'Level '+level+'\'';
        }
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<User> users){
        try{
            Id weeklyrtid = Schema.SObjectType.Linearity_Snapshot__c.getRecordTypeInfosByName().get('Monthly Forecast').getRecordTypeId();
            List<Id> allUserIds = new List<Id>();
            List<OpportunitySplit> totalAmount = new List<OpportunitySplit>();
            List<Linearity_Snapshot__c> fslst = new List<Linearity_Snapshot__c>();
            Set<String> types = new Set<String>{'New','Upsell', 'Renewal'};
            Id userId = users[0].Id;
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            Date msd = monthstartdate;
            Date med = monthenddate;
            
            Set<Id> upselplaceholderusers = new Set<Id>();
            upselplaceholderusers.addAll(ZForecastingService.getAllPlaceholderUsers());
            
            Set<string> lstypes = new Set<String>();
            List<Linearity_Snapshot__c> lslst = [Select Id, Forecast_Family__c, Forecast_Type__c from Linearity_Snapshot__c where  User__c = :userId and FYFQ__c = :qtr.FormattedString and Recordtype.Name = 'Monthly Forecast'];
            for (Linearity_Snapshot__c ls: lslst){
                lstypes.add(ls.Forecast_Family__c);
            }
            //List<Linearity_Snapshot__c> lslst = [Select Id from Linearity_Snapshot__c where Month__c = :date.today().month() and User__c = :userId and FYFQ__c = :qtr.FormattedString];
            
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
            
            if(msd.daysbetween(date.today().adddays(1)) >= 4 && !lstypes.contains('ZIA')){
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :med AND Opportunity.CloseDate >= :msd AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                   
                System.debug(totalAmount);                 
                Double revenue_new = 0.0;
                Double revenue_upsell = 0.0;
                Double revenue_renewal = 0.0;
                for(OpportunitySplit os: totalAmount){
                    if(os.Forecast_Type__c == 'New' && os.SplitAmount != null){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell' && os.SplitAmount != null){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal' && os.SplitAmount != null){
                        revenue_renewal += os.SplitAmount;
                    }
                    
                }
                for(String s: types){
                    Linearity_Snapshot__c fsrec = new Linearity_Snapshot__c();
                    fsrec.RecordTypeId = weeklyrtid;
                    fsrec.OwnerId = userId;
                    fsrec.User__c = userId;
                    fsrec.Forecast_Type__c = s;
                    fsrec.Forecast_Family__c = 'ZIA';
                    fsrec.Month__c = msd.month();
                    fsrec.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec.Amount__c = revenue_new;
                    }else if(s == 'Upsell'){
                        fsrec.Amount__c = revenue_upsell;
                    }else{
                        fsrec.Amount__c = revenue_renewal;
                    }
                    fslst.add(fsrec);
                    
                   
                }
                System.debug(fslst); 
                //msd = msd.addmonths(1);
                med = msd.addmonths(2).adddays(-1);
                System.debug(msd);
                System.debug(med);
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :med AND Opportunity.CloseDate >= :msd AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                    
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                for(OpportunitySplit os: totalAmount){
                    if(os.Forecast_Type__c == 'New' && os.SplitAmount != null){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell' && os.SplitAmount != null){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal' && os.SplitAmount != null){
                        revenue_renewal += os.SplitAmount;
                    }
                    
                }
                for(String s: types){
                    Linearity_Snapshot__c fsrec = new Linearity_Snapshot__c();
                    fsrec.RecordTypeId = weeklyrtid;
                    fsrec.OwnerId = userId;
                    fsrec.User__c = userId;
                    fsrec.Forecast_Type__c = s;
                    fsrec.Forecast_Family__c = 'ZIA';
                    fsrec.Month__c = med.month();
                    fsrec.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec.Amount__c = revenue_new;
                    }else if(s == 'Upsell'){
                        fsrec.Amount__c = revenue_upsell;
                    }else{
                        fsrec.Amount__c = revenue_renewal;
                    }
                    fslst.add(fsrec);
                    
                }
                System.debug(fslst); 
                //msd = msd.addmonths(1);
                med = msd.addmonths(3).adddays(-1);
                List<Zscaler_Forecast__c> lstzfl = [Select Id, Forecast_Amount__c, Forecast_Family__c, Forecast_Type__c, FYFQ__c, Month__c, User__c, YYWW__c from Zscaler_Forecast__c where User__c = :userId and FYFQ__c = :qtr.FormattedString and YYWW__c = :week.FormattedString];
                //totalAmount = Database.query(query + ' Opportunity.CloseDate <= :qtrenddate AND Opportunity.CloseDate >= :qtrstartdate AND SplitOwnerId IN :allUserIds AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                    
                revenue_new = 0.0;
                revenue_upsell = 0.0;
                revenue_renewal = 0.0;
                /*for(OpportunitySplit os: totalAmount){
                    if(os.Forecast_Type__c == 'New'){
                        revenue_new += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Upsell'){
                        revenue_upsell += os.SplitAmount;
                    }else if(os.Forecast_Type__c == 'Renewal'){
                        revenue_renewal += os.SplitAmount;
                    }
                }*/
                for(Zscaler_Forecast__c os: lstzfl){
                    if(os.Forecast_Family__c == 'ZIA'){
                        if(os.Forecast_Type__c == 'New' && os.Forecast_Amount__c != null){
                            revenue_new += os.Forecast_Amount__c;
                        }else if(os.Forecast_Type__c == 'Upsell' && os.Forecast_Amount__c != null){
                            revenue_upsell += os.Forecast_Amount__c;
                        }else if(os.Forecast_Type__c == 'Renewal' && os.Forecast_Amount__c != null){
                            revenue_renewal += os.Forecast_Amount__c;
                        }
                    }
                    
                }
                for(String s: types){
                    Linearity_Snapshot__c fsrec = new Linearity_Snapshot__c();
                    fsrec.RecordTypeId = weeklyrtid;
                    fsrec.OwnerId = userId;
                    fsrec.User__c = userId;
                    fsrec.Forecast_Type__c = s;
                    fsrec.Forecast_Family__c = 'ZIA';
                    fsrec.Month__c = med.month();
                    fsrec.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec.Amount__c = revenue_new;
                    }else if(s == 'Upsell'){
                        fsrec.Amount__c = revenue_upsell;
                    }else{
                        fsrec.Amount__c = revenue_renewal;
                    }
                    fslst.add(fsrec);
                    
                    
                }
                System.debug(fslst); 
                
            }
            
            msd = monthstartdate;
            med = monthenddate;
            
            if(msd.daysbetween(date.today().adddays(1)) >= 4 && !lstypes.contains('ZPA')){
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :med AND Opportunity.CloseDate >= :msd AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                   
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
                    Linearity_Snapshot__c fsrec1 = new Linearity_Snapshot__c();
                    fsrec1.RecordTypeId = weeklyrtid;
                    fsrec1.OwnerId = userId;
                    fsrec1.User__c = userId;
                    fsrec1.Forecast_Type__c = s;
                    fsrec1.Forecast_Family__c = 'ZPA';
                    fsrec1.Month__c = msd.month();
                    fsrec1.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec1.Amount__c = zpa_new;
                    }else if(s == 'Upsell'){
                        fsrec1.Amount__c = zpa_upsell;
                    }else{
                        fsrec1.Amount__c = zpa_renewal;
                    }
                    fslst.add(fsrec1);
                }
                System.debug(fslst); 
                //msd = msd.addmonths(1);
                med = msd.addmonths(2).adddays(-1);
                System.debug(msd);
                System.debug(med);
                totalAmount = Database.query(query + ' Opportunity.CloseDate <= :med AND Opportunity.CloseDate >= :msd AND (SplitOwnerId IN :allUserIds OR (SplitOwnerId IN :upselplaceholderusers AND Opportunity.OwnerId IN :allUserIds)) AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                    
                zpa_new = 0.0;
                zpa_upsell = 0.0;
                zpa_renewal = 0.0;
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
                    Linearity_Snapshot__c fsrec1 = new Linearity_Snapshot__c();
                    fsrec1.RecordTypeId = weeklyrtid;
                    fsrec1.OwnerId = userId;
                    fsrec1.User__c = userId;
                    fsrec1.Forecast_Type__c = s;
                    fsrec1.Forecast_Family__c = 'ZPA';
                    fsrec1.Month__c = med.month();
                    fsrec1.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec1.Amount__c = zpa_new;
                    }else if(s == 'Upsell'){
                        fsrec1.Amount__c = zpa_upsell;
                    }else{
                        fsrec1.Amount__c = zpa_renewal;
                    }
                    fslst.add(fsrec1);
                }
                System.debug(fslst); 
                //msd = msd.addmonths(1);
                med = msd.addmonths(3).adddays(-1);
                List<Zscaler_Forecast__c> lstzfl = [Select Id, Forecast_Amount__c, Forecast_Family__c, Forecast_Type__c, FYFQ__c, Month__c, User__c, YYWW__c from Zscaler_Forecast__c where User__c = :userId and FYFQ__c = :qtr.FormattedString and YYWW__c = :week.FormattedString];
                //totalAmount = Database.query(query + ' Opportunity.CloseDate <= :qtrenddate AND Opportunity.CloseDate >= :qtrstartdate AND SplitOwnerId IN :allUserIds AND ' + forecastSummaryField + ' IN (\'Most Likely\', \'Commit\')');
                    
                zpa_new = 0.0;
                zpa_upsell = 0.0;
                zpa_renewal = 0.0;
                for(Zscaler_Forecast__c os: lstzfl){
                    
                    if(os.Forecast_Family__c == 'ZPA'){
                        if(os.Forecast_Type__c == 'New' && os.Forecast_Amount__c != null){
                            zpa_new += os.Forecast_Amount__c;
                        }else if(os.Forecast_Type__c == 'Upsell' && os.Forecast_Amount__c != null){
                            zpa_upsell += os.Forecast_Amount__c;
                        }else if(os.Forecast_Type__c == 'Renewal' && os.Forecast_Amount__c != null){
                            zpa_renewal += os.Forecast_Amount__c;
                        }
                    }
                }
                for(String s: types){
                    
                    Linearity_Snapshot__c fsrec1 = new Linearity_Snapshot__c();
                    fsrec1.RecordTypeId = weeklyrtid;
                    fsrec1.OwnerId = userId;
                    fsrec1.User__c = userId;
                    fsrec1.Forecast_Type__c = s;
                    fsrec1.Forecast_Family__c = 'ZPA';
                    fsrec1.Month__c = med.month();
                    fsrec1.FYFQ__c = qtr.FormattedString;
                    if(s == 'New'){
                        fsrec1.Amount__c = zpa_new;
                    }else if(s == 'Upsell'){
                        fsrec1.Amount__c = zpa_upsell;
                    }else{
                        fsrec1.Amount__c = zpa_renewal;
                    }
                    fslst.add(fsrec1);
                }
                System.debug(fslst); 
                
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
                mail1.setSubject('Monthly Forecast Batch Failure result');
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
                mail.setSubject('Monthly Forecast Batch Success result ');
                mail.setPlainTextBody('Monthly Forecast batch has been executed Successfully and processed '+ successlst.size() + ' records');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}