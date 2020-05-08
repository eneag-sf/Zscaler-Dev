/*****************************************************************************************
Name: PartnerAccountInfoService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
REST webservice class to query the partner account details
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Vijay Prakash P J     07-Sept-2016    Initial Development
1.1            Vijay Prakash P J     12-Mar-2018     Changed the query condition to use Account.Type field for filtering
                                                     Accounts.
******************************************************************************************/
@RestResource(urlMapping='/PartnerAccountInfoService/*')
global class PartnerAccountInfoService  {

    global static final String INVALID_INPUT = 'Invalid request. Provide a valid partner account domain name.';
    global static final String NO_DATA_FOUND = 'No matching partner account found.';
    global static final String DOMAIN_PATTERN = '^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}$';

    /**
     * HTTP GET Method implementation to query the partner account details like Name and SF ID
     * Sample Request: /PartnerAccountInfoService?domain=zscaler.com
     * Sample Response: {"name": "Zscaler Inc.,", "id": "XXXX"}
     * @return Returns an object containing the matching Partner Account Name and the SF ID
     */
    @HttpGet
    global static void fetchPartnerAccount() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Map<String, String> partnerAccountDetailsMap = new Map<String, String>();

        //Validate the input
        Map<String, String> queryParametersMap = req.params;

        if (queryParametersMap.size() == 0
            || !queryParametersMap.containsKey('domain')
            || null == queryParametersMap.get('domain')
            || '' == queryParametersMap.get('domain').trim()
            || !queryParametersMap.get('domain').contains('.')) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(INVALID_INPUT);
            return;
        }

        String domain = queryParametersMap.get('domain');

        //Regex pattern validation for the domain name
        try {
            Pattern regex = Pattern.compile(DOMAIN_PATTERN);
            Matcher matcher = regex.matcher(domain);

            if (!matcher.matches()) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(INVALID_INPUT);
                return;
            }
        } catch(Exception ex) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(INVALID_INPUT);
            return;
        }

        String domainPattern = '%' + domain + '%';

        /* Commenting the below section as the Partner accounts will be identified if the Partner Type contains 'Partner' */
        ////Query the Partner Accounts and return the matching one based on Domain value
        ////and the Account Partner Type is any of the below:
        Set<String> partnerTypeSet = new Set<String>();
        partnerTypeSet.add('Partner-SP');
        partnerTypeSet.add('Partner-Reseller');
        partnerTypeSet.add('Partner-Distributor');
        partnerTypeSet.add('Partner-Integrator');
        partnerTypeSet.add('Partner-DC-BW');
        partnerTypeSet.add('Global SP/SI Partner');

        List<Account> partnerAccountList = [SELECT Id, Name, Domain__c, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.Name
                                              FROM Account
                                             WHERE Type = 'Partner'
                                               AND (Domain__c = :domain
                                                OR  Additional_Organization_Domains__c LIKE :domainPattern)
                                             ORDER BY CreatedDate DESC LIMIT 1];

        if (partnerAccountList.size() > 0) {
            if (partnerAccountList[0].Ultimate_Parent_Account__c != null) {
                partnerAccountDetailsMap.put('id', partnerAccountList[0].Ultimate_Parent_Account__c);
                partnerAccountDetailsMap.put('name', partnerAccountList[0].Ultimate_Parent_Account__r.Name);
            } else {
                partnerAccountDetailsMap.put('id', partnerAccountList[0].Id);
                partnerAccountDetailsMap.put('name', partnerAccountList[0].Name);
            }
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(partnerAccountDetailsMap));
        } else {
            //Set the response body and the HTTP status code if no matching account is found.
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(NO_DATA_FOUND);
        }
    }
}