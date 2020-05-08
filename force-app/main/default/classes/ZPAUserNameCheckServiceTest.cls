@isTest
private class ZPAUserNameCheckServiceTest {

    @testSetup static void setup(){
        Account Acc = new Account(Name = 'Test');
        TriggerUtility.SkipAccTriggerExecuted();
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        Insert Acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = Acc.id;
        con.email = 'test@test.com';
        con.ZIA_User_Name__c = 'Testing';
        insert con;
        
        Zscaler_Cloud_ID__c ZscalerCloudId = new Zscaler_Cloud_ID__c();
        ZscalerCloudId.Name = 'Testing';
        ZscalerCloudId.Account__c = Acc.Id;
        ZscalerCloudId.Zscaler_Cloud_Domain__c = 'Test';
        Insert ZscalerCloudId;
    }
    
    private static testMethod void test() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        req.requestURI = '/checkZPAUserName/';
        req.httpMethod = 'GET';
        req.requestBody = null;
        
        RestContext.request = new RestRequest();
        RestContext.request.params.put('zpaOrgId', 'Testing');
        RestContext.request.params.put('zpaUserName', 'Testing');
        
        ZPAUserNameCheckService.checkZPAUser();
        test.stopTest();
    }
    
    private static testMethod void test1() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        req.requestURI = '/createZPAcontactandUser/';
        req.httpMethod = 'GET';
        req.requestBody = null;
        
        RestContext.request = new RestRequest();
        List<Account> acclst = [Select Id from Account limit 1];
        RestContext.request.params.put('accountId', acclst[0].Id);
        RestContext.request.params.put('zpaUserName', 'Testing');
        RestContext.request.params.put('zpaEmail', 'oktest@oktest.com');
        RestContext.request.params.put('firstName', 'Testing');
        RestContext.request.params.put('lastName', 'Testingjdff');
        
        ZPAContactandUserCreation.createZPAcontactandUser();
        test.stopTest();
    }
    
    private static testMethod void test2() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        Test.startTest();
        req.requestURI = '/createZPAcontactandUser/';
        req.httpMethod = 'GET';
        req.requestBody = null;
        
        RestContext.request = new RestRequest();
        List<Account> acclst = [Select Id from Account limit 1];
        RestContext.request.params.put('accountId', acclst[0].Id);
        RestContext.request.params.put('zpaUserName', 'Testing');
        RestContext.request.params.put('zpaEmail', 'test@test.com');
        RestContext.request.params.put('firstName', 'Testing');
        RestContext.request.params.put('lastName', 'Testingjdff');
        
        ZPAContactandUserCreation.createZPAcontactandUser();
        test.stopTest();
    }


}