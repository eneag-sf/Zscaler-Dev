@isTest
private class ForecastingTest
{
    @isTest
    static void testForecastingDataModel()
    {
        User currentUser = [SELECT Id, Name, UserRoleId, UserRole.Name, ForecastEnabled__c, ViewForecastAs__c, ViewForecastAs__r.Name, Show_As_Manager_In_ZPA_Forecasting__c, DefaultForecastFamily__c, ZPAForecastEnabled__c, ViewZPAForecastAs__c, ViewZPAForecastAs__r.Name, Forecast_Inline_Editing__c, Level__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ForecastingDataModel.UserInfo usr = new ForecastingDataModel.UserInfo(currentUser);
        System.debug(usr.ViewForecastAs);
        System.debug(usr.ViewZPAForecastAs);

        ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo();
        qtr = new ForecastingDataModel.FiscalQuarterInfo(Date.Today());
        qtr = new ForecastingDataModel.FiscalQuarterInfo('2015Q1');
        System.assertEquals('2015Q1', qtr.FormattedString);
        System.assertEquals('2015Q2', qtr.Next.FormattedString);
        System.assertEquals('2014Q4', qtr.Previous.FormattedString);
        System.assertNotEquals(null, qtr.JsonWeeks);
        System.debug(qtr.getWeek(Date.today()));

        ForecastingDataModel.WeekInfo week = new ForecastingDataModel.WeekInfo();
        Date d = Date.newInstance(2015, 1, 1);
        week = new ForecastingDataModel.WeekInfo(d);
        System.assertEquals('201452', week.FormattedString);

        ForecastingDataModel.FiscalYearInfo year = new ForecastingDataModel.FiscalYearInfo(2017);
        year.StartDate = Date.newInstance(2017, 01, 01);
        year.EndDate = Date.newInstance(2017, 12, 31);
        System.assertEquals(2018, year.Next.Year);
        System.assertEquals(2016, year.Previous.Year);
    }

    @isTest
    static void  testForecastingController()
    {
        PageReference pageRef = new PageReference('/apex/forecasting');
        Test.setCurrentPage(pageRef);
        ForecastingController controller = new ForecastingController();

        String userId = UserInfo.getUserId();
        update new User(Id=userId, ForecastEnabled__c=true);
        pageRef = new PageReference('/apex/forecasting?quarter=2015Q1&path=/'+userId);
        Test.setCurrentPage(pageRef);
        controller = new ForecastingController();

        String path = controller.UserPath;
        System.assertEquals('2015Q1', controller.CurrentFiscalQuarter.FormattedString);
        System.assertNotEquals(null, controller.CurrentViewingUser);
        System.assertNotEquals(null, ForecastingController.GetDirectSubordinateUsers(UserInfo.getUserId(), 'ZIA'));
        System.assertNotEquals(null, ForecastingController.GetAllSubordinateUsers(UserInfo.getUserId(), 'ZIA'));

        controller.init();
    }
    
    @isTest // Added at 04APR2018 by Jimmy Li
    static void testForecastingControllerAttributes()
    {
        
        Date td = Date.today();
        ForecastingDataModel.FiscalQuarterInfo currQtr = new ForecastingDataModel.FiscalQuarterInfo(td);
        
        PageReference pageRef = new PageReference('/apex/forecasting');
        pageRef.getParameters().put('quarter', currQtr.FormattedString);
        pageRef.getParameters().put('userId', UserInfo.getUserId());
        pageRef.getParameters().put('impersonate', 'true');
        
        Test.setCurrentPage(pageRef);
        ForecastingController controller = new ForecastingController();
        
        
        Boolean showForecastFamilySwitch = controller.showForecastFamilySwitch;
        Boolean canImpersonate = controller.canImpersonate;
        String InlineEditingState = controller.InlineEditingState;
        //String OppListEditingPicklists = controller.OppListEditingPicklists;
        String opportunityPicklistFieldsValues = controller.getOpportunityPicklistFieldsValues();
        
    }

    @isTest
    static void  testZPAForecastingController()
    {
        PageReference pageRef = new PageReference('/apex/forecasting');
        Test.setCurrentPage(pageRef);
        ForecastingController controller = new ForecastingController();

        String userId = UserInfo.getUserId();
        update new User(Id=userId, ZPAForecastEnabled__c=true);
        pageRef = new PageReference('/apex/forecasting?quarter=2015Q1&forecastFamily=ZPA&path=/'+userId);
        Test.setCurrentPage(pageRef);
        controller = new ForecastingController();

        String path = controller.UserPath;
        System.assertEquals('2015Q1', controller.CurrentFiscalQuarter.FormattedString);
        System.assertNotEquals(null, controller.CurrentViewingUser);
        System.assertNotEquals(null, ForecastingController.GetDirectSubordinateUsers(UserInfo.getUserId(), 'ZPA'));
        System.assertNotEquals(null, ForecastingController.GetAllSubordinateUsers(UserInfo.getUserId(), 'ZPA'));

        controller.init();
    }

    @isTest
    static void testForecastingService()
    {
        Id userId = UserInfo.getUserId();

        ForecastingService.GetDirectSubordinateUsers(userId, 'ZIA');
        ForecastingService.GetAllSubordinateUsers(userId);
        ForecastingService.GetDirectSubordinateUserIds(userId);
        ForecastingService.GetAllSubordinateUserIds(userId);
        ForecastingService.GetUser(userId);

        update new User(Id=userId, ForecastEnabled__c=true);
        ForecastingService.initForecast(userId, 'New');
        List<CustomForecast__c> newForecasts = [select Id from CustomForecast__c where User__c=:userId AND Forecast_Family__c = 'ZIA'];
        System.assertEquals(1, newForecasts.size());
        CustomForecast__c fc = newForecasts[0];
        CustomForecast__c fc2 = fc.clone(false, false, false, false);
        CustomForecast__c fc3 = fc.clone(false, false, false, false);
        fc.Locked__c = true;
        newForecasts.add(fc2);
        newForecasts.add(fc3);
        upsert newForecasts;
        ForecastingService.initForecast(userId, 'New', 'ZIA');
        ZForecastingStatsService.SaveOppListItemRequest ctrl1 = new ZForecastingStatsService.SaveOppListItemRequest();
        ForecastingService.allowInlineEdting(ctrl1);
    }

    @isTest
    static void testZPAForecastingService()
    {
        Id userId = UserInfo.getUserId();
        Id userRoleId = UserInfo.getUserRoleId();

        ForecastingService.GetDirectSubordinateUsers(userId, 'ZPA');
        ForecastingService.GetAllSubordinateUsers(userId, 'ZPA');
        ForecastingService.GetDirectSubordinateUserIds(userId);
        ForecastingService.GetAllSubordinateUserIds(userId, 'ZPA');
        ForecastingService.GetUser(userId);

        update new User(Id=userId, ZPAForecastEnabled__c=true);
        ForecastingService.initForecast(userId, 'New', 'ZPA');
        ForecastingService.GetDirectSubordinateUsersV2(userId, 'ZPA');
        ForecastingService.getUsersByRoleV2(userRoleId, true, 'ZPA');
        List<CustomForecast__c> newForecasts = [select Id from CustomForecast__c where User__c=:userId AND Forecast_Family__c = 'ZPA'];
        System.assertEquals(1, newForecasts.size());
        CustomForecast__c fc = newForecasts[0];
        CustomForecast__c fc2 = fc.clone(false, false, false, false);
        CustomForecast__c fc3 = fc.clone(false, false, false, false);
        fc.Locked__c = true;
        newForecasts.add(fc2);
        newForecasts.add(fc3);
        upsert newForecasts;
        ForecastingService.initForecast(userId, 'New', 'ZPA');
    }

    @isTest
    static void testForecastingStatsService()
    {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName=label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate=Date.today());
        insert opp;

        CustomForecast__c fc = new CustomFOrecast__c(User__c=userId, ForecastType__c='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;

        ForecastingStatsService.GetForecastSummary(userId, qtr, 'New', 'ZIA');
        ForecastingStatsService.GetForecastSummary(userId, qtr, 'All', 'ZIA');
        
        ForecastingStatsService.SelectOptionWrapper optionWrapper = new ForecastingStatsService.SelectOptionWrapper(new SelectOption('label','value'));

        ForecastingStatsService.ForecastingOppListRequest req = new ForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = 'All Open';
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        ForecastingStatsService.GetOpportunityListing(req);

        ForecastingStatsService.ForecastingOppListRequest req2 = new ForecastingStatsService.ForecastingOppListRequest();
        req2.UserId = userId;
        req2.FiscalQtr = qtr;
        req2.Stage = 'Closed Lost';
        req2.Probability = '> 10';
        req2.forecastFamily = 'ZIA';
        ForecastingStatsService.GetOpportunityListing(req2);

        ForecastingStatsService.ForecastEntry entry = new ForecastingStatsService.ForecastEntry();
        entry.UserId = userId;
        entry.QtrCommit = 200;
        entry.QtrUpside = 250;
        entry.QtrPipeline = 300;
        ForecastingStatsService.SaveForecast(userId, 'New', 'ZIA', entry);
        
    }
    
    //added at 12APR2018
    @isTest
    static void testOpportunityUpdating()
    {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Id userId = UserInfo.getUserId();
        String qtr = (new ForecastingDataModel.FiscalQuarterInfo()).FormattedString;
        String week = (new ForecastingDataModel.WeekInfo()).FormattedString;
        
        List<Account> acts = new List<Account>();
        acts.add(new Account(Name='acme customer'));
        acts.add(new Account(Name='acme partner', Type='Partner'));
        acts.add(new Account(Name='acme partner2', Type='Partner'));
        insert acts;
        
        User currUser = new User(Id=userId, Forecast_Inline_Editing__c = true);
        update currUser;
        
        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', Amount=2000, AccountId=acts[0].Id, StageName=label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate=Date.today());
        insert opp;
        
        insert new Partner(AccountToId = acts[2].Id, OpportunityId = opp.Id, isPrimary=true);

        CustomForecast__c fc = new CustomFOrecast__c(User__c=userId, ForecastType__c='New', FYFQ__c=qtr, YYWW__c=week, Forecast_Family__c = 'ZIA');
        insert fc;
        
        ForecastingStatsService.ForecastingOppListRequest req = new ForecastingStatsService.ForecastingOppListRequest();
        req.UserId = userId;
        req.FiscalQtr = qtr;
        req.Stage = 'All Open';
        req.Probability = '> 10';
        req.forecastFamily = 'ZIA';
        ForecastingStatsService.ForecastingOppListResponse oppListResp = ForecastingStatsService.GetOpportunityListing(req);
        
        ForecastingStatsService.SaveOppListItemRequest oppSaveReq = new ForecastingStatsService.SaveOppListItemRequest();
        oppSaveReq.oppListItem = oppListResp.Opportunities[0];
        // Test the exception
        ForecastingStatsService.SaveOppListItemResponse oppSaveResp = ForecastingStatsService.updateOpportunityRecord(oppSaveReq);
        ForecastingStatsService.SaveOppListItemResponse oppSaveResp2 = ForecastingStatsService.updateOpportunityRecord(oppSaveReq);
        
        // actual test
        oppSaveReq.params = new Map<String, String>{
                'FiscalQtr' => qtr,
                'UserId' => userId,
                'ForecastFamily' => ''
        };
        Test.startTest();
        oppSaveReq.oppListItem.CloseDate = opp.CloseDate.year() + '-' + opp.CloseDate.month() + '-' + opp.CloseDate.day();
        oppSaveReq.oppListItem.PrimaryPartnerId = (String)acts[1].Id;
        oppSaveReq.oppListItem.Amount = 2500;
        ForecastingStatsService.SaveOppListItemResponse oppSaveResp3 = ForecastingStatsService.updateOppListItem(oppSaveReq);
        Test.stopTest();
    }

    @isTest
    static void testForecastingQuotaController()
    {
        ForecastingQuotaController controller = new ForecastingQuotaController();
        System.assert(controller.RootUsers != null);

        ForecastingQuotaController.UserQuota q = new ForecastingQuotaController.UserQuota(UserInfo.getUserId(), UserInfo.getUserName(), 'System Administrator', null);
        ForecastingQuotaController.SaveUserQuota(new List<ForecastingQuotaController.UserQuota> { q });
    }

    @isTest
    static void testForecastingException()
    {
        ForecastingException ex = new ForecastingException();
    }

    @isTest
    static void testBatchJob()
    {
        User me = new User(Id=UserInfo.getUserId(), ForecastEnabled__c=true, ForecastLevel__c='Level 4');
        update me;

        Test.startTest();

        CustomForecast__c f = new CustomForecast__c(User__c=me.Id, Locked__c=false, QuarterPipeline__c=100, FYFQ__c = '2016Q1', YYWW__c = '201610', Forecast_Family__c = 'ZIA');
        CustomForecast__c f2 = new CustomForecast__c(User__c=me.Id, Locked__c=false, QuarterPipeline__c=200, FYFQ__c = '2016Q1', YYWW__c = '201610', Forecast_Family__c = 'ZPA');
        insert new List<CustomForecast__c> { f, f2 };
        ForecastSubmissionBatch job = new ForecastSubmissionBatch(4, '2016Q1', '201611');
        Database.executeBatch(job);
        Test.stopTest();

        f = [select Id, Locked__c, SubmittedOn__c from CustomForecast__c where Id=:f.Id limit 1];
        System.assertEquals(true, f.Locked__c);
        List<CustomForecast__c> newFc = [select Id, QuarterPipeline__c, User__c, Locked__c from CustomForecast__c where Locked__c=false];
        // System.assertEquals(2, newFc.size());
        // System.assertEquals(100, newFc[0].QuarterPipeline__c);
        // System.assertEquals(me.Id, newFc[0].User__c);
    }

    @isTest
    static void testSchedule()
    {
        User me = new User(Id=UserInfo.getUserId(), ForecastLevel__c='Level 4', ForecastEnabled__c=true);
        update me;
        Test.startTest();
        ForecasSubmissionSchedule schedule = new ForecasSubmissionSchedule(4);
        schedule.execute(null);
        Test.stopTest();
    }

    @isTest
    static void testPublicProperties() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User userToImpersonate = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 4', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey);
        insert userToImpersonate;

        me.ForecastEnabled__c = true;
        me.ForecastLevel__c = 'Level 4';
        me.ViewForecastAs__c = userToImpersonate.Id;
        update me;

        Test.startTest();
        ForecastingController controller = new ForecastingController();
        Boolean isAdminTest = controller.IsAdmin;
        Boolean isViewingHistoryTest = controller.IsViewingHistory;
        Boolean canEditPlanTest = controller.canEditPlan;
        ForecastingController.GetUserNavPath('/'+UserInfo.getUserId());
        Test.stopTest();
    }

    @isTest
    static void testToggleImpersonation() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User userToImpersonate = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 4', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, ZPAForecastEnabled__c = true);
        insert userToImpersonate;

        me.ForecastEnabled__c = true;
        me.ForecastLevel__c = 'Level 4';
        me.ViewForecastAs__c = userToImpersonate.Id;
        me.ZPAForecastEnabled__c = true;
        me.ViewZPAForecastAs__c = userToImpersonate.Id;
        update me;

        Test.startTest();
        System.runAs(me) {
            PageReference forecastingVFPage = Page.Forecasting;
            Test.setCurrentPage(forecastingVFPage);
            ForecastingController controller = new ForecastingController();
            //Set impersonation to True
            controller.toggleImpersonation();

            //Set impersonation to False
            controller.toggleImpersonation();
        }
        Test.stopTest();
    }

    @isTest
    static void testZPAToggleImpersonation() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];

        User userToImpersonate = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 4', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true, ZPAForecastEnabled__c = true);
        insert userToImpersonate;

        me.ForecastEnabled__c = true;
        me.ForecastLevel__c = 'Level 4';
        me.ViewForecastAs__c = userToImpersonate.Id;
        me.ZPAForecastEnabled__c = true;
        me.ViewZPAForecastAs__c = userToImpersonate.Id;
        update me;

        Test.startTest();
        System.runAs(me) {
            // Run ZPA Impersonation Testing
            PageReference zpaforecastingVFPage = Page.Forecasting;
            Test.setCurrentPage(zpaforecastingVFPage);
            ApexPages.currentPage().getParameters().put('family', 'ZPA');
            ForecastingController zpacontroller = new ForecastingController();

            //Set impersonation to true
            zpacontroller.toggleImpersonation();

            //Set impersonation to true
            zpacontroller.toggleImpersonation();
            
        }
        Test.stopTest();
    }
}