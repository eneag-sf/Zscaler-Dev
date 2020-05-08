@isTest
public class CaptureUserForecastSnapshot_Test{
    static testmethod void test() {
        test.startTest();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        user usr = [select id from user where IsActive = true AND Level__c = 'Exec' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        Database.executeBatch(new CaptureUserForecastSnapshot('select id from user where IsActive = true AND Level__c = \'Exec\' limit 1'), 1); 
        test.stopTest();
    }
    static testmethod void test1() {
        test.startTest();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Closed');
        insert sfm;
        user usr = [select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = 'VP' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'Existing');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, VP_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        Database.executeBatch(new CaptureUserForecastSnapshot('select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = \'VP\' limit 1'), 1); 
        test.stopTest();
    }
    static testmethod void test2() {
        test.startTest();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Closed');
        insert sfm;
        user usr = [select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = 'Director' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'Existing Customer (Add On)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, AD_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        Database.executeBatch(new CaptureUserForecastSnapshot('select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = \'Director\' limit 1'), 1); 
        test.stopTest();
    }
    static testmethod void test3() {
        test.startTest();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Closed');
        insert sfm;
        user usr = [select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = 'Manager' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'New Business');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, DM_Forecast_Category__c= 'Closed' );
        insert oppSplit;
        Database.executeBatch(new CaptureUserForecastSnapshot('select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = \'Manager\' limit 1'), 1); 
        test.stopTest();
    }
    static testmethod void test4() {
        test.startTest();
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'OpportunityForecastCategoryAutomation', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'OppSplitForecastCategoryAutomation', Execute__c = true);
        trlst.add(tr1);
        trlst.add(tr2);
        insert trlst;
        
        Stage_ForecastCategory_Mapping__c sfm = new Stage_ForecastCategory_Mapping__c(name='Stg1', StageName__c = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, Forecast_Category__c = 'Closed');
        insert sfm;
        
        user usr = [select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = 'Exec' limit 1];
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_4_Economic_Buyer_Signoff /*10 - Closed Won*/, CloseDate = Date.Today(), Type = 'Existing Customer (Renewal)');
        insert opp;
        
        OpportunitySplit  oppSplit = new OpportunitySplit(OpportunityId = opp.Id, SplitPercentage = 10, SplitOwnerId = usr.id, CRO_Forecast_Category__c = 'Closed' );
        insert oppSplit;
        Database.executeBatch(new CaptureUserForecastSnapshot('select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name, Level__c from user where IsActive = true AND Level__c = \'Exec\' limit 1'), 1); 
        test.stopTest();
    }
}