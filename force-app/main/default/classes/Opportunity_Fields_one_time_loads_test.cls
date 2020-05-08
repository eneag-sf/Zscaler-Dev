@isTest
public class Opportunity_Fields_one_time_loads_test{

    static testmethod void test1(){
        
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'Exec');
        insert usr;*/
        
        test.starttest();
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acct.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        // OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = UserInfo.getUserId(), CRO_Forecast_Category__c = 'Closed' );
        // insert oppSplit;
        
        test.stoptest();
        
        Opportunity_Fields_one_time_loads batch;
        batch = new Opportunity_Fields_one_time_loads('Select Id, RVP_Forecast_Category__c, AD_Forecast_Category__c, Account.Sales_territory__r.Regional_VP__c, RVP_Forecast_Category_Lock__c , AD_Forecast_Category_Lock__c from Opportunity', 'FY20 Pricelist','true', true,'Test Batch');
        batch.errorlst.add('abc');
        Database.executeBatch(batch,200);
    
    }
    
    static testmethod void test2(){
        /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, Level__c = 'Exec');
        insert usr;*/
        
        test.starttest();
        //insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        //insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acct.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        // OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = UserInfo.getUserId(), CRO_Forecast_Category__c = 'Closed' );
        // insert oppSplit;
        
        test.stoptest();
        
        OpportunitySplit_Fields_one_time_loads batch;
        batch = new OpportunitySplit_Fields_one_time_loads('Select Id, RVP_Forecast_Category__c, AD_Forecast_Category__c, Opportunity.Account.Sales_territory__r.Regional_VP__c, RVP_Forecast_Category_Lock__c , AD_Forecast_Category_Lock__c from OpportunitySplit',true,'Test Batch');
        batch.errorlst.add('abc');
        Database.executeBatch(batch,200);
    
    }
}