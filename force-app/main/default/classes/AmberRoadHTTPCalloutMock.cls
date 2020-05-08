/*****************************************************************************************
Name: AmberRoadHTTPCalloutMock
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
HTTP Mock class to simulate AmberRoad API
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     17-Oct-2016    Initial Development
******************************************************************************************/
@isTest
public class AmberRoadHTTPCalloutMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public AmberRoadHTTPCalloutMock(Integer code, String status, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        
        if (req.getEndpoint().contains('Amber_Road_Integration') && 200 != this.code) {
            this.body = screenAccountMockInvalidResponse();
        } else if (req.getEndpoint().contains('Amber_Road_Integration') && 'Success' != this.status) {
            this.body = screenAccountMockIntegrationErrorResponse();
        } else if (req.getEndPoint().contains('Amber_Road_Integration')) {
            this.body = screenAccountMockResponse();
        }
        
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

    private String screenAccountMockResponse() {
        return '<PartnerRecord><PartnerId>testPartner</PartnerId><OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode>'
               + '<Name>TestData</Name><Phone>(234)567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>N</SkipNewDpl>'
               + '<EmbargoHold>N</EmbargoHold><CustomEmbargoMatch>N</CustomEmbargoMatch><Status>No Match</Status>'
               + '<Fax>(234)567-8902</Fax><Address1>110 Rose Orchard Way</Address1><City>San Jose</City><State>California</State>'
               + '<Country>United States</Country><PostalCode>95134</PostalCode>'
               + '<IntegrationStatus><StatusCode>1000</StatusCode><StatusDescription>Success</StatusDescription></IntegrationStatus>'
               + '</PartnerRecord>';
    }

    private String screenAccountMockInvalidResponse() {
        return '<PartnerRecord><PartnerId>testPartner</PartnerId><OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode>'
               + '<Name>TestData</Name><Phone>(234)567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>N</SkipNewDpl>'
               + '<EmbargoHold>N</EmbargoHold><CustomEmbargoMatch>N</CustomEmbargoMatch><Status>No Match</Status>'
               + '<Fax>(234)567-8902</Fax><Address1>110 Rose Orchard Way</Address1><City>San Jose</City><State>California</State>'
               + '<Country>United States</Country><PostalCode>95134</PostalCode>'
               + '<IntegrationStatus><StatusCode>1002</StatusCode><StatusDescription>PartnerId is required</StatusDescription></IntegrationStatus>'
               + '</PartnerRecord>';
    }

    private String screenAccountMockIntegrationErrorResponse() {
        return '<PartnerRecord><PartnerId>testPartner</PartnerId><OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode>'
               + '<Name>TestData</Name><Phone>(234)567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>N</SkipNewDpl>'
               + '<EmbargoHold>N</EmbargoHold><CustomEmbargoMatch>N</CustomEmbargoMatch><Status>No Match</Status>'
               + '<Fax>(234)567-8902</Fax><Address1>110 Rose Orchard Way</Address1><City>San Jose</City><State>California</State>'
               + '<Country>United States</Country><PostalCode>95134</PostalCode>'
               + '<IntegrationStatus><StatusCode>1002</StatusCode><StatusDescription>Integration Error</StatusDescription></IntegrationStatus>'
               + '</PartnerRecord>';
    }
}