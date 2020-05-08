@isTest
    private class PerformanceOppRptControllerTest{
        
        @isTest
        static void testPerformanceOpportunityReportController(){
            user  us = [Select id, name, UserRoleId, UserRole.Name, ViewForecastAs__c, ForecastEnabled__c from User Where ViewForecastAs__c != null AND Profile.Name =: 'System Administrator' AND isActive =: true limit 1];
            system.runAs(us){
            
            test.startTest();
            string path = '/apex/PerformanceOpportunityReport?FiscalQtr=2016Q3&UsrId='+UserInfo.getUserId()+'&ForecastType=new&Category=Upside&StartDate=2/5/2016&EndDate=2/11/2016&&Source=';
            PageReference pageRef = new PageReference(path);
            
            Test.setCurrentPage(pageRef);
            PerformanceOpportunityReportController controller = new PerformanceOpportunityReportController();
            List<PerformanceDataModel.UserInfo> userInfoList = new List<PerformanceDataModel.UserInfo>();
            //userInfoList = PerformanceController.GetDirectSubordinateUsers(controller.CurrentViewingUser.UserId);
            //userInfoList = PerformanceController.GetAllSubordinateUsers(controller.CurrentViewingUser.UserId);
            String userId = UserInfo.getUserId();
           // pageRef = new PageReference('/apex/PerformanceDashboard?path=/'+userId);
            Test.setCurrentPage(pageRef);
            PerformanceOpportunityReportController controller1 = new PerformanceOpportunityReportController();
            //list<id> subOrdIdList = PerformanceService.GetAllSubordinateUserIds(controller.CurrentViewingUser.UserId);
            test.stopTest();
            }
        }
       
    }