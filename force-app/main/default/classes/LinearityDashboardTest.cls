/*****************************************************************************************
Name: LinearityDashboardTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for LinearityDashboardController & LinearityDashboardService
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            28-Aug-2015    Initial Development
******************************************************************************************/ 



@isTest(SeeAllData=true)

    private class LinearityDashboardTest{
        
        @isTest(SeeAllData=true)

        static void testLinearityDashboardController(){
            user  us = [Select id, name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            system.runAs(us){
            
            test.startTest();
            PageReference pageRef = new PageReference('/apex/LinearityDashboard');
            Test.setCurrentPage(pageRef);
            LinearityDashboardController controller = new LinearityDashboardController();
            List<PerformanceDataModel.UserInfo> userInfoList = new List<PerformanceDataModel.UserInfo>();
            userInfoList = LinearityDashboardController.GetDirectSubordinateUsers(controller.CurrentViewingUser.UserId);
            userInfoList = LinearityDashboardController.GetAllSubordinateUsers(controller.CurrentViewingUser.UserId, 'VP');
            String userId = UserInfo.getUserId();
            pageRef = new PageReference('/apex/LinearityDashboard?path=/'+userId);
            Test.setCurrentPage(pageRef);
            LinearityDashboardController controller1 = new LinearityDashboardController();
            test.stopTest();
            }
        }
        
         @isTest(SeeAllData=true)

        static void testLinearityDashboardService(){
            user  us = [Select ViewForecastAs__c, id, name, UserRoleId, UserRole.Name, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            
            system.runAs(us){
                test.startTest();
                string year = ''+(system.today().Year()-1);
                LinearityDashboardService.getTeamForecast(us.ViewForecastAs__c,year,'all');
                LinearityDashboardService.getMonthlyContriLinearity(us.ViewForecastAs__c,year+'Q4', 'all' );
                LinearityDashboardService.getTeamForecast(us.ViewForecastAs__c,year,'upsell');
                LinearityDashboardService.getMonthlyContriLinearity(us.ViewForecastAs__c,year+'Q4', 'upsell');
                
                LinearityDashboardService.getLinearityMetric(us.ViewForecastAs__c,year+'Q4', 'all');
                LinearityDashboardService.getLinearityMetric(us.ViewForecastAs__c,year+'Q4', 'upsell');
                
                
                LinearityDashboardService.LinearityStackFilter filter = new LinearityDashboardService.LinearityStackFilter();
                filter.userId = us.ViewForecastAs__c;
                filter.currentFiscalQtr = year+'Q4';
                filter.forecastType = 'all';
                filter.month = 'Month 1';
                LinearityDashboardService.getLinearityStack(filter);
                
                filter.currentFiscalQtr = year+'Q3';
                filter.forecastType = 'upsell';
                filter.month = 'Month 2';
                LinearityDashboardService.getLinearityStack(filter);
                filter.currentFiscalQtr = year+'Q2';
                filter.forecastType = 'all';
                filter.month = 'Month 3';
                LinearityDashboardService.getLinearityStack(filter);
                LinearityDashboardService.getQuarterlyLinearityMetric(us.ViewForecastAs__c, 'all', year+'Q1',year+'Q2',year+'Q3',year+'Q4');
                LinearityDashboardService.getQuarterlyLinearityMetric(us.ViewForecastAs__c, 'upsell', year+'Q1',year+'Q2',year+'Q3',year+'Q4');
                
                test.stopTest();
            
            
            }
        }
    }