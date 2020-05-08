@isTest
public class ZForecastingService_Test{
    @isTest
    static void testZForecastingService()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        ZForecastingService.GetDirectSubordinateUsers(userId, 'ZIA');
        ZForecastingService.GetAllSubordinateUsers(userId);
        ZForecastingService.GetDirectSubordinateUserIds(userId);
        ZForecastingService.GetAllSubordinateUserIds(userId);
        ZForecastingService.GetUser(userId);

        update new User(Id=userId, ForecastEnabled__c=true);
        test.starttest();
        ZForecastingService.initForecast(userId, 'Exec', 'New','ZIA','en-US','en-US');
        List<Zscaler_Forecast__c> newForecasts = [select Id from Zscaler_Forecast__c where User__c=:userId AND Forecast_Family__c = 'ZIA'];
        System.assertEquals(1, newForecasts.size());
        Zscaler_Forecast__c fc = newForecasts[0];
        Zscaler_Forecast__c fc2 = fc.clone(false, false, false, false);
        Zscaler_Forecast__c fc3 = fc.clone(false, false, false, false);
        fc.Locked__c = true;
        newForecasts.add(fc2);
        newForecasts.add(fc3);
        upsert newForecasts;
        test.stoptest();
        }
    }

    @isTest
    static void testZPAZForecastingService()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId =usr.Id;
        Id userRoleId = usr.UserRoleId;
        system.runas(new User(Id=Userinfo.getUserId())){
        ZForecastingService.GetDirectSubordinateUsers(userId, 'ZPA');
        ZForecastingService.GetAllSubordinateUsers(userId, 'ZPA');
        ZForecastingService.GetDirectSubordinateUserIds(userId);
        ZForecastingService.GetUser(userId);

        update new User(Id=userId, ZPAForecastEnabled__c=true);
        ZForecastingService.initForecast(userId, 'Exec', 'New', 'ZPA','en-US','en-US');
        test.starttest();
        ZForecastingService.GetDirectSubordinateUsersV2(userId, 'ZPA');
        ZForecastingService.getUsersByRoleV2(userRoleId, true, 'ZPA');
        List<Zscaler_Forecast__c > newForecasts = [select Id from Zscaler_Forecast__c where User__c=:userId AND Forecast_Family__c = 'ZPA'];
        System.assertEquals(1, newForecasts.size());
        Zscaler_Forecast__c fc = newForecasts[0];
        Zscaler_Forecast__c fc2 = fc.clone(false, false, false, false);
        Zscaler_Forecast__c fc3 = fc.clone(false, false, false, false);
        fc.Locked__c = true;
        newForecasts.add(fc2);
        newForecasts.add(fc3);
        upsert newForecasts;
        test.stoptest();
        }
    }
    @isTest
    static void testZForecastingService2()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId =usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        ZForecastingService.getNextForecastWeek();
        ZForecastingService.getLatestForecastWeek(qtr, 'ZIA');
        ZForecastingService.getLatestForecastWeek(qtr, 'ZIA', 'en_US','en_US');
        ZForecastingService.getLastForecastWeek(qtr, 'ZIA', 'en_US','en_US');
        ZForecastingService.getForecasts(userId,qtr, week, 'ZIA');
	ZForecastingService.booster();
        }
    }
}