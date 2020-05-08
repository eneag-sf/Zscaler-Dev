@isTest
public class ZForecastingController_Test{
    @isTest
    static void  testZForecastingController()
    {
        PageReference pageRef = new PageReference('/apex/zforecasting');
        Test.setCurrentPage(pageRef);
        ZForecastingController controller = new ZForecastingController();

        String userId = UserInfo.getUserId();
        update new User(Id=userId, ForecastEnabled__c=true);
        pageRef = new PageReference('/apex/zforecasting?quarter=2015Q1&path=/'+userId);
        Test.setCurrentPage(pageRef);
        controller = new ZForecastingController();

        String path = controller.UserPath;
        System.assertEquals('2015Q1', controller.CurrentFiscalQuarter.FormattedString);
        System.assertNotEquals(null, controller.CurrentViewingUser);
        System.assertNotEquals(null, ZForecastingController.GetDirectSubordinateUsers(UserInfo.getUserId(), 'ZIA'));
        System.assertNotEquals(null, ZForecastingController.GetAllSubordinateUsers(UserInfo.getUserId(), 'ZIA'));

        controller.init();
        system.debug(controller.CurrentUserLevel);
        system.debug(controller.MyUserLevel);
        system.debug(controller.showMyRollupSection );
        system.debug(controller.showMyForecastSection );
        system.debug(controller.forecastEnabledForLoggedInUser  );
        ZForecastingController.GetDirectSubordinateUsersV2(UserInfo.getUserId(),'ZIA');
        ZForecastingController.GetUser(UserInfo.getUserId());
    }
    @isTest 
    static void testZForecastingControllerAttributes()
    {
        
        Date td = Date.today();
        ForecastingDataModel.FiscalQuarterInfo currQtr = new ForecastingDataModel.FiscalQuarterInfo(td);
        
        PageReference pageRef = new PageReference('/apex/zforecasting');
        pageRef.getParameters().put('quarter', currQtr.FormattedString);
        pageRef.getParameters().put('userId', UserInfo.getUserId());
        pageRef.getParameters().put('impersonate', 'true');
        
        Test.setCurrentPage(pageRef);
        ZForecastingController controller = new ZForecastingController();
        
        
        Boolean showForecastFamilySwitch = controller.showForecastFamilySwitch;
        Boolean canImpersonate = controller.canImpersonate;
        String InlineEditingState = controller.InlineEditingState;
        String opportunityPicklistFieldsValues = controller.getOpportunityPicklistFieldsValues();
        
    }
     @isTest
    static void  testZPAZForecastingController()
    {
        PageReference pageRef = new PageReference('/apex/zforecasting');
        Test.setCurrentPage(pageRef);
        ZForecastingController controller = new ZForecastingController();

        String userId = UserInfo.getUserId();
        update new User(Id=userId, ZPAForecastEnabled__c=true);
        pageRef = new PageReference('/apex/zforecasting?quarter=2015Q1&forecastFamily=ZPA&path=/'+userId);
        Test.setCurrentPage(pageRef);
        controller = new ZForecastingController();

        String path = controller.UserPath;
        System.assertEquals('2015Q1', controller.CurrentFiscalQuarter.FormattedString);
        System.assertNotEquals(null, controller.CurrentViewingUser);
        System.assertNotEquals(null, ZForecastingController.GetDirectSubordinateUsers(UserInfo.getUserId(), 'ZPA'));
        System.assertNotEquals(null, ZForecastingController.GetAllSubordinateUsers(UserInfo.getUserId(), 'ZPA'));

        controller.init();
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
        ZForecastingController controller = new ZForecastingController();
        Boolean isAdminTest = controller.IsAdmin;
        Boolean isViewingHistoryTest = controller.IsViewingHistory;
        Boolean canEditPlanTest = controller.canEditPlan;
        ZForecastingController.GetUserNavPath('/'+UserInfo.getUserId());
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

        
        System.runAs(me) {
            PageReference forecastingVFPage = Page.Forecasting;
            Test.setCurrentPage(forecastingVFPage);
            ZForecastingController controller = new ZForecastingController();
            //Set impersonation to True
            controller.toggleImpersonation();
            Test.startTest();
            //Set impersonation to False
            controller.toggleImpersonation();
            Test.stopTest();
        }
        
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
            ZForecastingController zpacontroller = new ZForecastingController();

            //Set impersonation to true
            zpacontroller.toggleImpersonation();

            //Set impersonation to true
            zpacontroller.toggleImpersonation();
        }
        Test.stopTest();
    }
}