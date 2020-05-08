/*****************************************************************************************
Name: DealRegistrationService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to create and query Deal Registrations from APEX
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     30-Aug-2016    Initial Development
******************************************************************************************/

@RestResource(urlMapping='/DealRegistrationService/*')
global class DealRegistrationService {

    global static final String SUCCESS_MESSAGE = 'Thank you for registering the following deal. We will review your request and contact you shortly.\\n\\nPlease note your deal registration request number - [DealRegNumber]\\n\\nYou can check the status of your deal by clicking the \\"Check Deal Status\\" button';
    global static final String FAILURE_MESSAGE = 'Thank you for registering the following deal. We will review your request and contact you shortly.';
    global static final String INVALID_BULK_REQUEST_INPUT = 'Invalid request. At most one parameter (Partner Domain or Partner Email) is required';
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Deal Reg Id and Partner Email are mandatory';
    global static final String INVALID_DEAL_REG_ID = 'Invalid request. Deal Reg Id is not valid';
    global static final String INVALID_PARTNER_EMAIL = 'Invalid request. Partner Email is not valid';
    global static final String NO_DATA_FOUND = 'No matching deal registrations found';

    /**
     * Implementation for HTTP GET that queries the matching deal registrations and returns them
     * Deal registrations can be queried one by one or in bulk
     * Examples:
     * Single Request: /DealRegistrationService?dealRegId=ZDR-00018&partnerEmail=partner1@testpartner1.com
     *     Returns an array containing one matching record. Otherwise, returns a HTTP 404.
     *     Both dealRegId and partnerEmail are mandatory.
     *
     * Bulk Request: /DealRegistrationService/bulk?partnerEmail=partner1@testpartner1.com
     *                                     Or
     *               /DealRegistrationService/bulk?partnerDomain=testpartner1
     *     Returns an array of matching records. Otherwise, returns a HTTP 404.
     *     At most one parameter (partnerEmail or partnerDomain) is mandatory.
     *     
     * @param dealRegId - Deal Reg Name (Deal_Reg__c.Name)
     * @param partnerEmail - Partner Contact's Email Id
     * @param partnerDomain - Partner Company Name
     * @return Returns matching deal registrations
     */
    @HttpGet
    global static void getRegisteredDeals() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isBulk = endpoint.contains('/bulk') ? true : false;
        Boolean isRequestValid = true;

        String partnerEmail, partnerDomain, dealRegId;
        Map<Id, DealRegistrationQueryResponseModel> dealRegistrationsMap = new Map<Id, DealRegistrationQueryResponseModel>();

        //Validating the input params
        if (isBulk) {
            if (requestParams.size() < 1
                || (!requestParams.containsKey('partnerDomain'))
                    && !requestParams.containsKey('partnerEmail')
                || (null == requestParams.get('partnerDomain')
                    && null == requestParams.get('partnerEmail'))
                || (null != requestParams.get('partnerDomain')
                    && null != requestParams.get('partnerEmail'))) {
                restRes.statusCode = 400;
                restRes.responseBody = Blob.valueOf(INVALID_BULK_REQUEST_INPUT);
                isRequestValid = false;
            }
        } else {
            if (requestParams.size() < 2
                || (!requestParams.containsKey('dealRegId'))
                    && !requestParams.containsKey('partnerEmail')
                || (null == requestParams.get('dealRegId')
                    && null == requestParams.get('partnerEmail'))) {
                restRes.statusCode = 400;
                restRes.responseBody = Blob.valueOf(INVALID_SINGLE_REQUEST_INPUT);
                isRequestValid = false;
            } else if (requestParams.containsKey('dealRegId') 
                && (null == requestParams.get('dealRegId')
                || '' == requestParams.get('dealRegId').trim())) {
                restRes.statusCode = 400;
                restRes.responseBody = Blob.valueOf(INVALID_DEAL_REG_ID);
                isRequestValid = false;
            } else if (requestParams.containsKey('partnerEmail') 
                && (null == requestParams.get('partnerEmail')
                || '' == requestParams.get('partnerEmail').trim())) {
                restRes.statusCode = 400;
                restRes.responseBody = Blob.valueOf(INVALID_PARTNER_EMAIL);
                isRequestValid = false;
            }
        }

        //Stop right here if the request is not valid
        if (!isRequestValid) {
            return;
        }

        //Parse the query parameters
        dealRegId = requestParams.get('dealRegId');
        partnerEmail = requestParams.get('partnerEmail');
        partnerDomain = requestParams.get('partnerDomain');

        //Query the matching deal registrations
        String query = 'SELECT Id, Name, Status__c, Partner_Contact_Name__c, Expiration_Date__c, End_Customer_Name__c, '
                     + '  Account_Manager__r.Name, Account_Manager__r.Phone, Channel_Manager__r.Name, '
                     + '  Channel_Manager__r.Phone, End_Customer_State__c, End_Customer_Country__c, '
                     + '  End_Customer_Contact_Name__c, End_Customer_Contact_Last_Name__c, '
                     + '  End_Customer_Email__c, CreatedDate, Partner_Contact_Last_Name__c, '
                     + '  Channel_Manager_Phone__c, Account_Manager_Phone__c '
                     + '  FROM Deal_Reg__c';

        //Filter the records based on the query parameters provided
        if (isBulk) {
            if (null != partnerEmail) {
                query += ' WHERE Partner_Contact_Email__c = :partnerEmail';
            } else if (null != partnerDomain) {
                query += ' WHERE Partner_Domain__c = :partnerDomain';
            }
        } else {
            query += ' WHERE Partner_Contact_Email__c = :partnerEmail'
                   + '   AND Name = :dealRegId';
        }

        query += ' ORDER BY CreatedDate DESC';

        for (Deal_Reg__c dealRegistration : Database.query(query)) {
            DealRegistrationQueryResponseModel model = new DealRegistrationQueryResponseModel();
            model.dealRegId = dealRegistration.Name;
            model.status = dealRegistration.Status__c;
            model.accountManagerName = dealRegistration.Account_Manager__r.Name;
            model.accountManagerPhone = dealRegistration.Account_Manager_Phone__c;
            model.channelManagerName = dealRegistration.Channel_Manager__r.Name;
            model.channelManagerPhone = dealRegistration.Channel_Manager_Phone__c;
            model.dealRegExpirationDate = dealRegistration.Expiration_Date__c;
            model.partnerContactFirstName = dealRegistration.Partner_Contact_Name__c;
            model.partnerContactLastName = dealRegistration.Partner_Contact_Last_Name__c;
            model.endCustomerName = dealRegistration.End_Customer_Name__c;
            model.endCustomerState = dealRegistration.End_Customer_State__c;
            model.endCustomerCountry = dealRegistration.End_Customer_Country__c;
            model.endCustomerContactFirstName = dealRegistration.End_Customer_Contact_Name__c;
            model.endCustomerContactLastName = dealRegistration.End_Customer_Contact_Last_Name__c;
            model.endCustomerEmail = dealRegistration.End_Customer_Email__c;
            model.dealRegSubmissionDate = dealRegistration.CreatedDate.Date();
            //Todo: Add mapping for new fields to be added - Question to Vidhya
            dealRegistrationsMap.put(dealRegistration.Id, model);
        }

        //Query the opportunities associated to the deal registrations
        for (Opportunity oppty : [SELECT Id, Amount, CloseDate, Deal_Reg__c
                                    FROM Opportunity 
                                   WHERE Deal_Reg__c IN :dealRegistrationsMap.keySet()]) {
            DealRegistrationQueryResponseModel model = dealRegistrationsMap.get(oppty.Deal_Reg__c);
            model.amount = oppty.Amount;
            model.closeDate = oppty.CloseDate;
        }

        System.debug(dealRegistrationsMap.values());

        if (0 == dealRegistrationsMap.values().size()) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            restRes.responseBody = Blob.valueOf(JSON.serialize(dealRegistrationsMap.values()));
        }
    }

    /**
     * Implemenation to handle HTTP POST action that creates a new deal registration
     * Sample request:
     * {"customerCompanyName":"GE", "customerContactCountry":"India", "customerContactEmail":"vijay@ge.com", 
     * "customerContactFirstName":"Vijay", "customerContactLastName":"Prakash", "customerContactPhone":"9876543456", 
     * "customerContactAddress":"1001 Rosewood Ave", "customerContactCity":"San Jose", "customerContactPostalCode":"10010",
     * "customerContactState":"Karnataka", "customerRoleAndTitle":"Test Title", "dealDescription":"Test Description", 
     * "dealRegId":"null", "dealSource":"Zscaler Website", "estimatedAmount":"20000.00", "expectedCloseDate":"2016-10-19", 
     * "numberOfSeats":"2000", "partnerAlternateEmail1":"partner1@zscaler.com", "partnerAlternateEmail2":"partner2@zscaler.com", 
     * "partnerAlternateEmail3":"partner3@zscaler.com", "partnerCompanyName":"Zscaler Partner", 
     * "partnerContactEmail":"naresh.kumar@zscaler.com", "partnerContactFirstName":"Naresh", "partnerContactLastName":"Rana", 
     * "partnerContactName":"null", "partnerPhone":"09876456784", "productAreas":"VZen, PZen", "status":"Submitted"}    
     *          
     * Sample response:
     *     {"status_message":"Thank you for registering the following deal. We will review your request and contact you shortly.\\n\\n
     *     Please note your deal registration request number - ZDR-00670\\n\\nYou can check the status of your deal by clicking the 
     *     \\\"Check Deal Status\\\" button","status_code":"1","dealRegId":"ZDR-00670"}
     *     
     * @param  request Deal registration model request
     * @return         Returns the ID (Deal_Reg__c.Name) of the created record and status
     */
    @HttpPost
    global static void registerNewDeal() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        DealRegistrationResponseModel response = new DealRegistrationResponseModel();
        System.debug(restReq.requestBody.toString());
        DealRegistrationModel request = (DealRegistrationModel)JSON.deserialize(restReq.requestBody.toString(), DealRegistrationModel.class);
        System.debug(request);

        Deal_Reg__c dealReg = new Deal_Reg__c(
                                End_Customer_Name__c = request.customerCompanyName,
                                End_Customer_Contact_Name__c = request.customerContactFirstName,
                                End_Customer_Contact_Last_Name__c = request.customerContactLastName,
                                End_Customer_Phone__c = request.customerContactPhone,
                                End_Customer_Email__c = request.customerContactEmail,
                                End_Customer_Street_Address__c = request.customerContactAddress,
                                End_Customer_City__c = request.customerContactCity,
                                End_Customer_Postal_Code__c = request.customerContactPostalCode,
                                End_Customer_State__c = request.customerContactState,
                                End_Customer_Country__c = request.customerContactCountry,
                                Number_Of_Users__c = request.numberOfSeats,
                                Partner_Company_Name__c = request.partnerCompanyName,
                                Partner_Contact_Email__c = request.partnerContactEmail,
                                Partner_Contact_Name__c = request.partnerContactFirstName,
                                Partner_Contact_Last_Name__c = request.partnerContactLastName,
                                Partner_Phone__c = request.partnerPhone,
                                Expected_Close_Date__c = request.expectedCloseDate,
                                Estimated_Amount__c = request.estimatedAmount,
                                Deal_Description__c = request.dealDescription,
                                Customer_Role_And_Title__c = request.customerRoleAndTitle,
                                Product_Areas__c = request.productAreas,
                                Partner_Alternate_Email_1__c = request.partnerAlternateEmail1,
                                Partner_Alternate_Email_2__c = request.partnerAlternateEmail2,
                                Partner_Alternate_Email_3__c = request.partnerAlternateEmail3,
                                Security_ISA_Name__c = request.partnerISAName,
                                Security_ISA_Email__c = request.partnerISAEmail,
                                Source__c = 'Zscaler Website'
                            );

        try {
            //Create the new deal registration record
            //Creation / assignment of contact / lead has been taken care of in the trigger
            insert dealReg;

            String dealRegName = [SELECT Name FROM Deal_Reg__c WHERE Id = :dealReg.Id LIMIT 1].Name;

            //Set the response parameters
            response.dealRegId = dealRegName;
            response.status_message = SUCCESS_MESSAGE.replace('[DealRegNumber]', dealRegName);
            response.status_code = '1';
            restRes.responseBody = Blob.valueOf(JSON.serialize(response));
        } catch (Exception ex) {
            System.debug('Deal Registration Service Error: ' + ex.getMessage() + '\nStack trace: ' + ex.getStackTraceString());

            //Set the response parameters
            response.dealRegId = null;
            response.status_message = FAILURE_MESSAGE;
            response.status_code = '-1';
            restRes.responseBody = Blob.valueOf(JSON.serialize(response));
            restRes.statusCode = 400;
        }
    }

    /**
     * Wrapper class to send in the POST response body
     */
    global class DealRegistrationResponseModel {
        public String dealRegId;
        public String status_message;
        public String status_code;
    }

    /**
     * Wrapper class to send the GET response body
     */
    global class DealRegistrationQueryResponseModel {
        public Decimal amount;
        public String accountManagerName;
        public String accountManagerPhone;
        public String channelManagerName;
        public String channelManagerPhone;
        public Date closeDate;
        public String dealRegId;
        public Date dealRegExpirationDate;
        public Date dealRegSubmissionDate;
        public String endCustomerContactFirstName;
        public String endCustomerContactLastName;
        public String endCustomerCountry;
        public String endCustomerEmail;
        public String endCustomerName;
        public String endCustomerState; 
        public String partnerContactFirstName;
        public String partnerContactLastName;
        public String status;
    }

    public class DealRegistrationException extends Exception {

    }
}