@isTest
public class CaptureWeeklyForecastBatch_Test{
    static testmethod void test() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureWeeklyForecastBatch batch;
        
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
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            insert opp;
            
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Commit' );
            insert oppSplit;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(23, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            Database.executeBatch(batch,1);
        }
        test.stopTest();
    }
    
    static testmethod void test1() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureWeeklyForecastBatch batch;
        
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
            
            Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Commit');
            insert sfm;
            
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            insert opp;
            
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, VP_Forecast_Category__c = 'Commit' );
            insert oppSplit;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(23, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            Database.executeBatch(batch,1);
        }
        test.stopTest();
    }
    
    static testmethod void test2() {
        ZForecastingDataModel.FiscalQuarterInfo currentQuarter;
        ZForecastingDataModel.WeekInfo nextWeek;
        Date nextWeekStartDay;
        CaptureWeeklyForecastBatch batch;
        
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
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
            insert opp;
            
            OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, AD_Forecast_Category__c = 'Commit' );
            insert oppSplit;
            
            nextWeekStartDay = Date.today();
            currentQuarter = new ZForecastingDataModel.FiscalQuarterInfo(nextWeekStartDay);
            nextWeek = new ZForecastingDataModel.WeekInfo(nextWeekStartDay);
            batch = new CaptureWeeklyForecastBatch(23, nextWeek.StartDate, nextWeek.EndDate, currentQuarter.StartDate, currentQuarter.EndDate, currentQuarter, nextWeek);
            Database.executeBatch(batch,1);
        }
        test.stopTest();
    }
}