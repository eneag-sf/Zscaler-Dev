@istest
public class CaptureExistingZscalerForecast_MLRlTest{

    static testmethod void test(){
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        
        Date currentweekstartdate = Date.today().toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter1 = new ForecastingDataModel.FiscalQuarterInfo(currentweekstartdate);
        ForecastingDataModel.WeekInfo currentweek = new ForecastingDataModel.WeekInfo(currentweekstartdate);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'Exec');
        insert usr;
        
        system.runas(new User(Id=Userinfo.getUserId())){
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        
        
        
        List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
        Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
        zf1.User__c = usr.Id;
        zf1.YYWW__c = currentweek.FormattedString;
        zf1.Archived__c = false;
        zf1.Forecast_Type__c = 'New';
        zforlst.add(zf1);
        
        Zscaler_Forecast__c zf3 = new Zscaler_Forecast__c ();
        zf3.User__c = usr.Id;
        zf3.FYFQ__c = currentQuarter.FormattedString;
        zf3.YYWW__c = null;
        zf3.Forecast_Type__c = 'Upsell';
        zf3.Archived__c = false;
        zforlst.add(zf3);
        
        insert zforlst;
        }
        test.starttest();
        CaptureExistingZscalerForecast_MLRollup batch = new CaptureExistingZscalerForecast_MLRollup(23, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        Database.executeBatch(batch,2000);
        test.stoptest();
    }
    
    static testmethod void test1(){
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        
        Date currentweekstartdate = Date.today().toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter1 = new ForecastingDataModel.FiscalQuarterInfo(currentweekstartdate);
        ForecastingDataModel.WeekInfo currentweek = new ForecastingDataModel.WeekInfo(currentweekstartdate);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'VP');
        insert usr;
        
        system.runas(new User(Id=Userinfo.getUserId())){
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        
        List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
        Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
        zf1.User__c = usr.Id;
        zf1.YYWW__c = currentweek.FormattedString;
        zf1.Archived__c = false;
        zf1.Forecast_Type__c = 'New';
        zforlst.add(zf1);
        
        Zscaler_Forecast__c zf2 = new Zscaler_Forecast__c ();
        zf2.User__c = usr.Id;
        zf2.FYFQ__c  = currentQuarter.FormattedString;
        zf2.YYWW__c = null;
        zf2.Forecast_Type__c = 'New';
        zf2.Archived__c = false;
        zforlst.add(zf2);
        
        insert zforlst;
        }
        test.starttest();
        CaptureExistingZscalerForecast_MLRollup batch = new CaptureExistingZscalerForecast_MLRollup(23, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        Database.executeBatch(batch,2000);
        test.stoptest();
        
    }
    
    static testmethod void test2(){
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        
        Date currentweekstartdate = Date.today().toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter1 = new ForecastingDataModel.FiscalQuarterInfo(currentweekstartdate);
        ForecastingDataModel.WeekInfo currentweek = new ForecastingDataModel.WeekInfo(currentweekstartdate);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = false, Level__c = 'Director');
        insert usr;
        
        system.runas(new User(Id=Userinfo.getUserId())){
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        
        List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
        Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
        zf1.User__c = usr.Id;
        zf1.YYWW__c = currentweek.FormattedString;
        zf1.Archived__c = false;
        zf1.Forecast_Type__c = 'New';
        zforlst.add(zf1);
        
        Zscaler_Forecast__c zf2 = new Zscaler_Forecast__c ();
        zf2.User__c = usr.Id;
        zf2.FYFQ__c  = currentQuarter.FormattedString;
        zf2.YYWW__c = null;
        zf2.Forecast_Type__c = 'New';
        zf2.Archived__c = false;
        zforlst.add(zf2);
        
        insert zforlst;
        }
        test.starttest();
        CaptureExistingZscalerForecast_MLRollup batch = new CaptureExistingZscalerForecast_MLRollup(23, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        Database.executeBatch(batch,2000);
        test.stoptest();
        
    }
    static testmethod void test3(){
        Date nextWeekStartDay = Date.today().addDays(7).toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter = new ForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
        ForecastingDataModel.WeekInfo nextWeek = new ForecastingDataModel.WeekInfo(nextWeekStartDay);
        
        Date currentweekstartdate = Date.today().toStartOfWeek();
        ForecastingDataModel.FiscalQuarterInfo currentQuarter1 = new ForecastingDataModel.FiscalQuarterInfo(currentweekstartdate);
        ForecastingDataModel.WeekInfo currentweek = new ForecastingDataModel.WeekInfo(currentweekstartdate);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = false, Level__c = 'Manager');
        insert usr;
        
        system.runas(new User(Id=Userinfo.getUserId())){
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        
        List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
        Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
        zf1.User__c = usr.Id;
        zf1.YYWW__c = currentweek.FormattedString;
        zf1.Archived__c = false;
        zf1.Forecast_Type__c = 'New';
        zforlst.add(zf1);
        
        Zscaler_Forecast__c zf2 = new Zscaler_Forecast__c ();
        zf2.User__c = usr.Id;
        zf2.FYFQ__c  = currentQuarter.FormattedString;
        zf2.YYWW__c = null;
        zf2.Forecast_Type__c = 'New';
        zf2.Archived__c = false;
        zforlst.add(zf2);
        
        insert zforlst;
        }
        test.starttest();
        CaptureExistingZscalerForecast_MLRollup batch = new CaptureExistingZscalerForecast_MLRollup(23, currentQuarter.FormattedString, nextWeek.FormattedString, nextWeekStartDay, currentQuarter.startdate, currentQuarter.enddate);
        batch.errorlst.add('ABC');
        Database.executeBatch(batch,2000);
        test.stoptest();
        
    }
}