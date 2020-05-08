/*****************************************************************************************
Name: DealRegistrationServiceTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to unit test the DealRegistrationService class code
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     02-Sept-2016    Initial Development
******************************************************************************************/
@isTest
public class DealRegistrationServiceTest {
	
    /**
     * Method to test the deal registration creation
     */
	@isTest static void testRegisterNewDeal() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        //Create a new model
        DealRegistrationModel model = new DealRegistrationModel();
        model.customerCompanyName = 'TestCust1';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact1';
        model.customerContactEmail = 'customercontact1@testcust1.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner1';
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner1@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('10');
        model.dealDescription = 'Test deal1';
        model.estimatedAmount = Decimal.valueOf('100000.5');
        model.expectedCloseDate = Date.today();

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        DealRegistrationService.registerNewDeal();
        Test.stopTest();

        String response = res.responseBody.toString();
        DealRegistrationService.DealRegistrationResponseModel responseModel = (DealRegistrationService.DealRegistrationResponseModel)JSON.deserialize(response, DealRegistrationService.DealRegistrationResponseModel.class);
        System.assert(responseModel.dealRegId != null);
        System.assert(responseModel.status_code != '-1');
	}

    /**
     * Method to test the retrieval of a single deal registration
     */
    @isTest static void testGetRegisteredDeal() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        //Create a new model
        DealRegistrationModel model = new DealRegistrationModel();
        model.customerCompanyName = 'TestCust1';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact1';
        model.customerContactEmail = 'customercontact1@testcust1.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner1';
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner1@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('10');
        model.dealDescription = 'Test deal1';
        model.estimatedAmount = Decimal.valueOf('100000.5');
        model.expectedCloseDate = Date.today();

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        DealRegistrationService.registerNewDeal();
        String response = res.responseBody.toString();
        DealRegistrationService.DealRegistrationResponseModel responseModel = (DealRegistrationService.DealRegistrationResponseModel)JSON.deserialize(response, DealRegistrationService.DealRegistrationResponseModel.class);

        Test.startTest();
        req.requestURI = '/DealRegistrationService';
        req.httpMethod = 'GET';
        req.requestBody = null;

        req.addParameter('partnerEmail', model.partnerContactEmail);
        req.addParameter('dealRegId', responseModel.dealRegId);

        DealRegistrationService.getRegisteredDeals();
        String getResponseText = res.responseBody.toString();
        Test.stopTest();

        //Assertions
        System.assert(getResponseText.contains(responseModel.dealRegId));
    }

    /**
     * Method to test the negative cases of deal registration creation
     */
    @isTest static void testGetRegisteredDealNegativeCases() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String bothInvalidResponse, emailInvalidResponse, dealRegIdInvalidResponse, noRecordFoundResponse;
        Integer bothInvalidResponseCode, emailInvalidResponseCode, dealRegIdInvalidResponseCode, noRecordFoundResponseCode;

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        req.requestURI = '/DealRegistrationService';
        req.httpMethod = 'GET';
        req.requestBody = null;

        //Invalid input parameters
        req.addParameter('partnerEmail', null);
        req.addParameter('dealRegId', null);

        DealRegistrationService.getRegisteredDeals();
        bothInvalidResponse = res.responseBody.toString();
        bothInvalidResponseCode = res.statusCode;

        //Invalid partnerEmail
        req.params.clear();
        req.addParameter('partnerEmail', null);
        req.addParameter('dealRegId', 'ZDR-00012');

        DealRegistrationService.getRegisteredDeals();
        emailInvalidResponse = res.responseBody.toString();
        emailInvalidResponseCode = res.statusCode;

        //Invalid dealRegId
        req.params.clear();
        req.addParameter('partnerEmail', 'partner1@testpartner1.com');
        req.addParameter('dealRegId', null);

        DealRegistrationService.getRegisteredDeals();
        dealRegIdInvalidResponse = res.responseBody.toString();
        dealRegIdInvalidResponseCode = res.statusCode;

        //Record not found case
        req.params.clear();
        req.addParameter('partnerEmail', 'partner1@testpartner1.com');
        req.addParameter('dealRegId', 'ZDR-00101');

        DealRegistrationService.getRegisteredDeals();
        noRecordFoundResponse = res.responseBody.toString();
        noRecordFoundResponseCode = res.statusCode;
        
        Test.stopTest();

        //Assertions
        System.assertEquals(DealRegistrationService.INVALID_SINGLE_REQUEST_INPUT, bothInvalidResponse);
        System.assertEquals(400, bothInvalidResponseCode);
        System.assertEquals(DealRegistrationService.INVALID_DEAL_REG_ID, dealRegIdInvalidResponse);
        System.assertEquals(400, dealRegIdInvalidResponseCode);
        System.assertEquals(DealRegistrationService.INVALID_PARTNER_EMAIL, emailInvalidResponse);
        System.assertEquals(400, emailInvalidResponseCode);
        System.assertEquals(DealRegistrationService.NO_DATA_FOUND, noRecordFoundResponse);
        System.assertEquals(404, noRecordFoundResponseCode);
    }

    /**
     * Method to test the retrieval of multiple deal registrations (in bulk)
     */
    @isTest static void testGetRegisteredDealBulk() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        String response, dealRegIdOne, dealRegIdTwo;
        DealRegistrationService.DealRegistrationResponseModel responseModel;

        String responseByPartnerEmail, responseByPartnerName, noRecordsFoundResponse, invalidInputParametersResponse;
        Integer noRecordsFoundResponseCode;

        //Create a new model
        DealRegistrationModel model = new DealRegistrationModel();
        model.customerCompanyName = 'TestCust1';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact1';
        model.customerContactEmail = 'customercontact1@testcust1.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner1';
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner1@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('10');
        model.dealDescription = 'Test deal1';
        model.estimatedAmount = Decimal.valueOf('100000.5');
        model.expectedCloseDate = Date.today();

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        DealRegistrationService.registerNewDeal();
        response = res.responseBody.toString();
        responseModel = (DealRegistrationService.DealRegistrationResponseModel)JSON.deserialize(response, DealRegistrationService.DealRegistrationResponseModel.class);
        dealRegIdOne = responseModel.dealRegId;

        //Create another new model
        DealRegistrationModel model2 = new DealRegistrationModel();
        model.customerCompanyName = 'TestCust3';
        model.customerContactFirstName = 'Customer';
        model.customerContactLastName = 'Contact4';
        model.customerContactEmail = 'customercontact4@testcust2.com';
        model.customerContactCountry = 'India';
        model.customerContactState = 'Karnataka';
        model.customerContactPhone = '987634567';
        model.partnerCompanyName = 'TestPartner2';
        model.partnerContactFirstName = 'partner1';
        model.partnerContactLastName = 'test';
        model.partnerContactEmail = 'partner2@testpartner1.com';
        model.partnerPhone = '3456987654';
        model.numberOfSeats = Integer.valueOf('20');
        model.dealDescription = 'Test deal3';
        model.estimatedAmount = Decimal.valueOf('10000.5');
        model.expectedCloseDate = Date.today();

        req.requestBody = Blob.valueOf(JSON.serialize(model));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        DealRegistrationService.registerNewDeal();
        response = res.responseBody.toString();
        responseModel = (DealRegistrationService.DealRegistrationResponseModel)JSON.deserialize(response, DealRegistrationService.DealRegistrationResponseModel.class);
        dealRegIdTwo = responseModel.dealRegId;

        Test.startTest();
        req.requestURI = '/DealRegistrationService/bulk';
        req.httpMethod = 'GET';
        req.requestBody = null;

        req.addParameter('partnerEmail', model.partnerContactEmail);

        DealRegistrationService.getRegisteredDeals();
        responseByPartnerEmail = res.responseBody.toString();

        req.params.clear();
        req.addParameter('partnerDomain', 'testpartner1.com');

        DealRegistrationService.getRegisteredDeals();
        responseByPartnerName = res.responseBody.toString();

        req.params.clear();
        req.addParameter('partnerEmail', 'test@norecords.com');

        DealRegistrationService.getRegisteredDeals();
        noRecordsFoundResponse = res.responseBody.toString();
        noRecordsFoundResponseCode = res.statusCode;

        req.params.clear();
        DealRegistrationService.getRegisteredDeals();
        invalidInputParametersResponse = res.responseBody.toString();

        Test.stopTest();

        //Assertions
        System.assertEquals(responseByPartnerEmail, responseByPartnerName);
        System.assertEquals(noRecordsFoundResponse, DealRegistrationService.NO_DATA_FOUND);
        System.assertEquals(noRecordsFoundResponseCode, 404);
        System.assertEquals(invalidInputParametersResponse, DealRegistrationService.INVALID_BULK_REQUEST_INPUT);
    }
}