/*****************************************************************************************
Name: RequestHelpForLeadControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for RequestHelpForLeadController.
    
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            27-Sept-2017    Initial Development
******************************************************************************************/ 
@isTest(seeAllData=false)
private class RequestHelpForLeadControllerTest {
    @isTest static void testRequestHelpForLeadController() {
        Test.startTest();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        insert le;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'SalesOperationQueueId';
        zs.Value__c = userInfo.getUserId();
        insert zs;
        Test.setCurrentPage(Page.RequestHelpForLead);
        ApexPages.currentPage().getParameters().put('id', le.Id);
        RequestHelpForLeadController controller = new RequestHelpForLeadController();
        controller.newCase.Subject = 'test';
        controller.newCase.Description = 'test';
        controller.save();
        controller.cancel();
        Test.stopTest();
    }
}