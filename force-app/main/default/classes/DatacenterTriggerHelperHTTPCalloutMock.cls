@isTest
public class DatacenterTriggerHelperHTTPCalloutMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public DatacenterTriggerHelperHTTPCalloutMock(Integer code, String status, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }

        if (req.getEndpoint().contains('RequestInvalid')) {
            this.body = '{"error_message" : "Browser API keys cannot have referer restrictions when used with this API.","results" : [],"status" : "REQUEST_DENIED"}';
            this.code = 400;
            this.status = 'BAD REQUEST';
        } else if (req.getEndpoint().contains('AuthError')) {
            this.body = '{"error_message" : "Browser API keys cannot have referer restrictions when used with this API.","results" : [],"status" : "REQUEST_DENIED"}';
            this.code = 200;
            this.status = 'OK';
        } else {
            this.body = '{"results":[{"address_components":[{"long_name":"San Jose","short_name":"San Jose","types":["locality","political"]},{"long_name":"Santa Clara County","short_name":"Santa Clara County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]}],"formatted_address":"San Jose, CA, USA","geometry":{"bounds":{"northeast":{"lat":37.4695381,"lng":-121.589154},"southwest":{"lat":37.124493,"lng":-122.0456719}},"location":{"lat":37.3382082,"lng":-121.8863286},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":37.4695381,"lng":-121.589154},"southwest":{"lat":37.124493,"lng":-122.0456719}}},"place_id":"ChIJ9T_5iuTKj4ARe3GfygqMnbk","types":["locality","political"]}],"status":"OK"}';
            this.code = 200;
            this.status = 'OK';
        }

        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        
        return res;
    }

}