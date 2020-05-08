@isTest
private class ZIAUserNameCheckServiceTest {
    
    @testSetup static void setup(){
        Account Acc = new Account(Name = 'Test');
	    Insert Acc;
	    
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = Acc.id;
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
        req.requestURI = '/checkZIAUserName/';
        req.httpMethod = 'GET';
        req.requestBody = null;
        
        RestContext.request = new RestRequest();
        RestContext.request.params.put('ziaOrgId', 'Testing');
        RestContext.request.params.put('ziaUserName', 'Testing');
        
        ZIAUserNameCheckService.checkziaUser();
        test.stopTest();
	}

}