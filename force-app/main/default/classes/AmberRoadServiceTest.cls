/*****************************************************************************************
Name: AmberRoadServiceTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Unit test class to test AmberRoadService and AmberRoadRequestService
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     17-Oct-2016    Initial Development
******************************************************************************************/
@isTest
public class AmberRoadServiceTest {

    @isTest static void testTransactionalAccountScreening() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        AmberRoadAccountModel returnModel = new AmberRoadAccountModel();

        Account testAccountToBeScreened = new Account(
                                            Name = 'Test Account',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288'
                                        );
        insert testAccountToBeScreened;
        
        API_Country_Mapping__c countryMapping = new API_Country_Mapping__c(
                                                    Name = 'united states',
                                                    Amber_Road_Country_Name__c = 'UNITED STATES OF AMERICA',
                                                    Amber_Road_Country_Code__c = 'US'
                                                );
        insert countryMapping;

        API_States_Mapping__c stateMapping = new API_States_Mapping__c(
                                                    Name = 'california',
                                                    Amber_Road_State_Code__c = 'CA'
                                                );
        insert stateMapping;
        
        Test.startTest();
        returnModel = AmberRoadService.screenAccount(testAccountToBeScreened);
        Test.stopTest();

        System.debug(returnModel);
    }

    @isTest static void testActiveAccountScreeningFuture() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        Account testAccountToBeScreened = new Account(
                                            Name = 'Test Account',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288'
                                        );
        insert testAccountToBeScreened;

        Test.startTest();
        AmberRoadService.screenAccountFuture(JSON.serialize(testAccountToBeScreened), true, false);
        Test.stopTest();
    }

    @isTest static void testActiveAccountScreening() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(200, 'Success', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        AmberRoadAccountModel returnModel = new AmberRoadAccountModel();

        Account testAccountToBeScreened = new Account(
                                            Name = 'Test Account',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288'
                                        );
        insert testAccountToBeScreened;

        Test.startTest();
        returnModel = AmberRoadService.screenAccount(testAccountToBeScreened, true);
        Test.stopTest();

        System.debug(returnModel);
    }

    @isTest static void testAccountScreeningIntegrationErrorCase() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(200, 'Integration Error', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        AmberRoadAccountModel returnModel = new AmberRoadAccountModel();

        Account testAccountToBeScreened = new Account(
                                            Name = 'Test Account',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288'
                                        );
        Test.startTest();
        try {
            returnModel = AmberRoadService.screenAccount(testAccountToBeScreened);
        } catch (Exception ex) {
            if (ex instanceof AmberRoadService.AmberRoadServiceException) {
                System.debug('Verified!');
            }
        }
        Test.stopTest();

        System.debug(returnModel);
    }

    @isTest static void testTransactionalScreeningNegativeCase() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(400, 'Bad Request', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        AmberRoadAccountModel returnModel = new AmberRoadAccountModel();

        Account testAccountToBeScreened = new Account(
                                            Name = 'Test Account',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288'
                                        );

        Test.startTest();
        try {
            returnModel = AmberRoadService.screenAccount(testAccountToBeScreened);
        } catch (Exception ex) {
            if (ex instanceof AmberRoadService.AmberRoadServiceException) {
                System.debug('Verified!');
            }
        }
        Test.stopTest();

        System.debug(returnModel);
    }

    @isTest static void testEmptyRequestBodyCase() {
        AmberRoadHTTPCalloutMock httpMock = new AmberRoadHTTPCalloutMock(400, 'Bad Request', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, httpMock);
        Test.startTest();
        try {
            AmberRoadRequestService.screenAccount(null);
        } catch(Exception ex) {
            System.assert(ex instanceof AmberRoadRequestService.AmberRoadRequestServiceException);
        }
        Test.stopTest();
    }
}