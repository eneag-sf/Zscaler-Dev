/*****************************************************************************************
Name: PartnerAccountInfoServiceTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to test the PartnerAccountInfoService code
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Vijay Prakash P J     07-Sept-2016    Initial Development
******************************************************************************************/
@isTest
private class PartnerAccountInfoServiceTest {

    /**
     * Method to test the retrieval of matching partner account
     */
	@isTest static void testFetchPartnerAccount() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Map<String, String> mapMatchingResponse = new Map<String, String>();
        String notMatchingResponse;
        Integer notMatchingResponseCode;

        //Create a test account
        Account testPartnerAccount = new Account(
                                                    Name = 'Test Partner Account 1',
                                                    Domain__c = 'testpartneraccount1.com',
                                                    Partner_Type__c = 'Partner-SP',
                                                    Type = 'Partner'
                                                );
        insert testPartnerAccount;

        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;

        //Scenario 1: Return matching partner account
        //Set the input parameter
        req.addParameter('domain', 'testpartneraccount1.com');
        PartnerAccountInfoService.fetchPartnerAccount();
        mapMatchingResponse = (Map<String, String>)JSON.deserialize(res.responseBody.toString(), Type.forName('Map<String, String>'));

        //Scenario 2: Return 404 as no matching account is found
        //Set the input parameter
        req.addParameter('domain', 'zscaler.com');
        PartnerAccountInfoService.fetchPartnerAccount();
        notMatchingResponse = res.responseBody.toString();
        notMatchingResponseCode = res.statusCode;
        Test.stopTest();

        //Assertions
        System.assert((mapMatchingResponse.get('id') == testPartnerAccount.Id ? true : false));
        System.assertEquals(PartnerAccountInfoService.NO_DATA_FOUND, notMatchingResponse);
        System.assertEquals(404, notMatchingResponseCode);
	}

    /**
     * Method to test the negative case
     */
	@isTest static void testWithNegativeCase() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;

        PartnerAccountInfoService.fetchPartnerAccount();
        Test.stopTest();

        //Assertions
        System.assertEquals(PartnerAccountInfoService.INVALID_INPUT, res.responseBody.toString());
        System.assertEquals(400, res.statusCode);
	}

}