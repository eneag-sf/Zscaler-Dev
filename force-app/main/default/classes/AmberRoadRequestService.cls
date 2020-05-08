/*****************************************************************************************
Name: AmberRoadRequestService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to consume Amber Road API
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     12-Oct-2016    Initial Development
******************************************************************************************/
public class AmberRoadRequestService {
    /*
    Constants Section - Start
     */
    private static final String AMBER_ROAD_NAMED_CREDENTIAL = 'Amber_Road_Integration';
    private static final String DEFAULT_CONTENT_TYPE = 'application/xml';
    private static final String DEFAULT_ACCEPT = 'application/xml';
    /*
    Constants Section - End
     */

    /**
     * Method to hit the Synchronous Export On-Demand API to check for the status
     * @param  inboundXML Inbound XML body string
     * @return            Returns the response body (XML string)
     */
    public static String screenAccount(String inboundXML) {
        HttpRequest request;
        HttpResponse response;
        String responseBody;

        //Validate the inbound XML
        if (null == inboundXML || '' == inboundXML) {
            throw new AmberRoadRequestServiceException('Inbound XML is required');
        }

        try {
            request = createHttpRequest('GET', inboundXML, DEFAULT_CONTENT_TYPE, DEFAULT_ACCEPT, null);
            Http http = new Http();
            response = http.send(request);
            System.debug('Amber Road Response: ' + response.getBody() + ';' + response.getStatusCode());
            if (200 != response.getStatusCode()) {
                throw new AmberRoadRequestServiceException('Received non-success status code :' + response.getStatusCode());
            }

            responseBody = response.getBody();
        } catch (Exception ex) {
            throw new AmberRoadRequestServiceException('Exception occurred while screening account: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        
        return responseBody;
    }

    /**
     * Helper method to construct the HTTP request
     * @param  method      HTTP Method Name
     * @param  body        Request body
     * @param  contentType Content-Type header value
     * @param  accept      Accept header value
     * @param  queryParams Query string parameters
     * @return             Returns a HttpRequest object
     */
    private static HttpRequest createHttpRequest(String method, String body, String contentType, String accept, Map<String, String> queryParams) {
        HttpRequest request = new HttpRequest();
        String queryParamsString = '';

        if (null != queryParams
            && !queryParams.isEmpty()) {
            Integer index = 0;
            for (String key : queryParams.keySet()) {
                queryParamsString += (0 == index ? '?' : '&') + queryParams.get(key);
            }
        }

        request.setEndpoint(String.format('callout:{0}{1}', new List<String> {AMBER_ROAD_NAMED_CREDENTIAL, queryParamsString}));
        request.setMethod(method);
        request.setBody(body);

        if (null != contentType) {
            request.setHeader('Content-Type', contentType);
        }

        if (null != accept) {
            request.setHeader('Accept', accept);
        }

        return request;
    }

    /**
     * Custom exception class for AmberRoadRequestService
     */
    public class AmberRoadRequestServiceException extends Exception {

    }
}