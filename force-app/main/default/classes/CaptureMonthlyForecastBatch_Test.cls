@isTest
public class CaptureMonthlyForecastBatch_Test{
    static testmethod void test() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureMonthlyForecastBatch batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'Exec',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            
            List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
            Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
            zf1.User__c = usr.Id;
            zf1.FYFQ__c = currentQuarter.FormattedString;
            zf1.YYWW__c = nextWeek.FormattedString;
            zf1.Archived__c = false;
            zf1.Forecast_Type__c = 'New';
            zforlst.add(zf1);
            
            Zscaler_Forecast__c zf3 = new Zscaler_Forecast__c ();
            zf3.User__c = usr.Id;
            zf3.FYFQ__c = currentQuarter.FormattedString;
            zf3.YYWW__c = nextWeek.FormattedString;
            zf3.Forecast_Type__c = 'Upsell';
            zf3.Archived__c = false;
            zforlst.add(zf3);
            insert zforlst;
            
            batch = new CaptureMonthlyForecastBatch(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek );
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
    
    static testmethod void test1() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureMonthlyForecastBatch  batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'VP',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureMonthlyForecastBatch(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek );
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
    
    static testmethod void test2() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureMonthlyForecastBatch  batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'Director',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureMonthlyForecastBatch(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
    static testmethod void test_1() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CreateZPARecordsforAllUsers batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'Exec',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            
            List<Zscaler_Forecast__c> zforlst = new List<Zscaler_Forecast__c >();
            Zscaler_Forecast__c zf1 = new Zscaler_Forecast__c ();
            zf1.User__c = usr.Id;
            zf1.FYFQ__c = currentQuarter.FormattedString;
            zf1.YYWW__c = nextWeek.FormattedString;
            zf1.Archived__c = false;
            zf1.Forecast_Type__c = 'New';
            zforlst.add(zf1);
            
            Zscaler_Forecast__c zf3 = new Zscaler_Forecast__c ();
            zf3.User__c = usr.Id;
            zf3.FYFQ__c = currentQuarter.FormattedString;
            zf3.YYWW__c = nextWeek.FormattedString;
            zf3.Forecast_Type__c = 'Upsell';
            zf3.Archived__c = false;
            zforlst.add(zf3);
            insert zforlst;
            
            batch = new CreateZPARecordsforAllUsers(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek );
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
    
    static testmethod void test1_1() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CreateZPARecordsforAllUsers batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'VP',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CreateZPARecordsforAllUsers(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek );
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
    
    static testmethod void test2_1() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CreateZPARecordsforAllUsers batch;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id, Level__c = 'Director',
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        
        test.startTest();
        system.runas(new User(Id=Userinfo.getUserId())){
            List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
            Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
            Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
            trlst.add(tr1);
            trlst.add(tr2);
            insert trlst;
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            List<Opportunity> opplst = new List<opportunity>();
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            opplst.add(opp);
            opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(1), Type = 'Existing Customer (Renewal)');
            opplst.add(opp1);
            opportunity opp2 = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today().addmonths(2), Type = 'Existing Customer (Renewal)');
            opplst.add(opp2);
            insert opplst;
            
            List<OpportunitySplit> oppspllst = new List<OpportunitySplit>();
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opplst[0].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit);
            OpportunitySplit  oppSplit2 = new OpportunitySplit(OpportunityId = opplst[1].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit2);
            OpportunitySplit  oppSplit3 = new OpportunitySplit(OpportunityId = opplst[2].Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            oppspllst.add(oppSplit3);
            insert oppspllst;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CreateZPARecordsforAllUsers(23, Date.today().tostartofmonth(), Date.today().tostartofmonth().addmonths(1).adddays(-1), currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            try{
                Database.executeBatch(batch,1);
            }catch(Exception ex){}
        }
        test.stopTest();
    }
}