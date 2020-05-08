@isTest
    private class PerformanceDashboardTest{
        @isTest
        static void testPerformanceDataModel(){
            user  us = [Select ViewForecastAs__c, Id, name, UserRoleId, UserRole.Name, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            system.runAs(us){
            PerformanceDataModel.UserInfo usr = new PerformanceDataModel.UserInfo(us);
            }
        }
        
        @isTest
        static void testPerformanceDashboardController(){
            user  us = [Select id, name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            system.runAs(us){
            
            test.startTest();
            PageReference pageRef = new PageReference('/apex/PerformanceDashboard');
            Test.setCurrentPage(pageRef);
            PerformanceController controller = new PerformanceController();
            List<PerformanceDataModel.UserInfo> userInfoList = new List<PerformanceDataModel.UserInfo>();
            userInfoList = PerformanceController.GetDirectSubordinateUsers(controller.CurrentViewingUser.UserId);
            userInfoList = PerformanceController.GetAllSubordinateUsers(controller.CurrentViewingUser.UserId);
            String userId = UserInfo.getUserId();
            pageRef = new PageReference('/apex/PerformanceDashboard?path=/'+userId);
            Test.setCurrentPage(pageRef);
            PerformanceController controller1 = new PerformanceController();
            list<id> subOrdIdList = PerformanceService.GetAllSubordinateUserIds(controller.CurrentViewingUser.UserId);
            test.stopTest();
            }
        }
        
        @isTest
        static void testPerformanceStatService(){
            user  us = [Select ViewForecastAs__c, id, name, UserRoleId, UserRole.Name, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            test.startTest();
            system.runAs(us){
                PerformanceStatService.ForecastSummary foreSumm = new PerformanceStatService.ForecastSummary();
                String qtr = '2016Q2';
                foreSumm = PerformanceStatService.GetForecastSummary(us.ViewForecastAs__c, qtr, 'all');
                set<string> strSet = PerformanceStatService.getForecastTypes('all');
                ZscalerSetting__c zs = new ZscalerSetting__c();
                zs.Name = 'StartingDayOfWeek';
                zs.Value__c = 'Friday';
                insert zs;
                PerformanceStatService.LoadSourceFunnelData('all', us.ViewForecastAs__c);
                PerformanceStatService.LoadSourceFunnelData('new', us.ViewForecastAs__c);
                PerformanceStatService.LoadFunnelWOWChange('all', us.ViewForecastAs__c);
                PerformanceStatService.LoadFunnelWOWChange('new', us.ViewForecastAs__c);
                foreSumm = PerformanceStatService.GetFunnelAchievement(us.ViewForecastAs__c, qtr, 'new');
                foreSumm = PerformanceStatService.GetFunnelAchievement(us.ViewForecastAs__c, qtr, 'all');
                PerformanceStatService.getFourQtrSourceWOW('renewal',us.ViewForecastAs__c);
                PerformanceStatService.getFourQtrSourceWOW('all',us.ViewForecastAs__c);
                PerformanceStatService.GetSourceSummary(us.ViewForecastAs__c,'new');
                PerformanceStatService.getAddDaysMap('Saturday');
                PerformanceStatService.getAddDaysMap('Sunday');
                PerformanceStatService.getAddDaysMap('Monday');
                PerformanceStatService.getAddDaysMap('Tuesday');
                PerformanceStatService.getAddDaysMap('Wednesday');
                PerformanceStatService.getAddDaysMap('Thrusday');
                
            test.stopTest();
            
            
            }
        }
        
        @isTest
        static void testPerformanceStatService1(){
            user  us = [Select ViewForecastAs__c, id, name, UserRoleId, UserRole.Name, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            test.startTest();
            system.runAs(us){
                ZscalerSetting__c zs = new ZscalerSetting__c();
                zs.Name = 'StartingDayOfWeek';
                zs.Value__c = 'Friday';
                insert zs;
                PerformanceStatService.loadWOWFunnelDistribution('new', us.ViewForecastAs__c, '2016Q2');
                PerformanceStatService.loadWOWFunnelDistribution('all', us.ViewForecastAs__c,'2016Q2');
            }   
            test.stopTest();
        }
        
    }