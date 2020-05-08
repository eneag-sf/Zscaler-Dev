public class ProvisioningSHIFTPOCHelper
{
    public static String getAuthenticated()
    {
        String sessionId = '';
        ZscalerShiftLogin__c loginCredential = getLoginCredential();
        String payLoad = 'username=' + EncodingUtil.urlEncode(loginCredential.Username__c, 'UTF-8') + '&password=' + EncodingUtil.urlEncode(loginCredential.Password__c, 'UTF-8') + '&passcode=';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String loginEndpoint = loginCredential.Endpoint__c + '/shift/api/v1/signin';
        req.setEndpoint(loginEndpoint);
        req.setMethod('POST');
        req.setBody(payLoad);
        HttpResponse res = h.send(req);
        String cookieStr = res.getHeader('Set-Cookie');
        return cookieStr;
    }
    
    public static HttpResponse createCompany(String domainName, String customerName)
    {
        Http h = new Http();
        HttpResponse response = null;
        HttpRequest req = buildCreateCompanyRequest(domainName, customerName);
        response = h.send(req);        
        return response;
    }
    
    public static HttpResponse createUser(String customerId, String domain, String contactName, String userEmail, String password)
    {
        Http h = new Http();
        HttpResponse response = null;
        System.debug('customerId=' + customerId + '; domain=' + domain + ';contactName=' + contactName + '; userEmail=' + userEmail + ';password=' + password);
        HttpRequest req = buildCreateUserRequest(customerId, domain, contactName, userEmail, password);
        response = h.send(req);
        system.debug(response.getBody());
        return response;
    }
    
    public static HttpResponse createPOCtraffic(String customerId, DateTime startTime, DateTime endTime)
    {
        Http h = new Http();
        HttpResponse response = null;
        HttpRequest req = buildCreatePOCtrafficRequest(customerId, startTime, endTime);
        response = h.send(req);
        system.debug(response.getBody());
        return response;
    }
    
    
    private static HttpRequest buildCreateCompanyRequest(String domainName, String customerName)
    {
        HttpRequest req = new HttpRequest();
        ZscalerShiftLogin__c loginCredential = getLoginCredential();
        String createCompanyEndpoint = loginCredential.Endpoint__c + '/shift/api/v1/admin/customers/' + loginCredential.Customer_Id__c + '/customers';   
        req.setEndpoint(createCompanyEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', getAuthenticated());
        String reqBody = '{ "name": "' + customerName + '",' +
                            '"domainName": "' + domainName + '",' +
                            '"currencyCode": "USD",' +
                            '"countryCode": "US",' +
                            '"languageCode": "US.EN"'+
                          '}';
                          
        req.setBody(reqBody);
        return req;
    }
    
    private static HttpRequest buildCreateUserRequest(String customerId, String domain, String contactName, String userEmail, String password)
    {
        HttpRequest req = new HttpRequest();
        ZscalerShiftLogin__c loginCredential = getLoginCredential();
        String createUserEndpoint = loginCredential.Endpoint__c + '/shift/api/v1/admin/customers/' + customerId + '/users';
        String username = 'admin@' + domain;  
        req.setEndpoint(createUserEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', getAuthenticated());
        String reqBody = '{ "username": "' + username + '",' +
                            '"password": "' + password + '",' +
                            '"email": "' + userEmail + '",' +
                            '"displayName": "' + contactName + '",' +
                            '"roleId": "2"'+
                          '}';
        System.debug(reqBody);
        req.setBody(reqBody);
        return req;
    }
    
    //builds the create poc traffic request
    private static HttpRequest buildCreatePOCtrafficRequest(String customerId, DateTime startTime, DateTime endTime)
    {
        HttpRequest req = new HttpRequest();
        String weekStart = String.valueOf((startTime.getTime()/1000).intValue());
        String weekEnd = String.valueOf((endTime.getTime()/1000).intValue());
        ZscalerShiftLogin__c loginCredential = getLoginCredential();
        String createPOCEndpoint = loginCredential.Endpoint__c + '/shift/api/v1/analytics/customers/' + customerId + '/actionStats/start/' + weekStart + '/end/' + weekEnd; 
        req.setEndpoint(createPOCEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', getAuthenticated());
        //req.setHeader('Authorization', 'Bearer ' + getPOCSessionId());        
        return req;
    }
    
    private static ZscalerShiftLogin__c getLoginCredential()
    {
        List<Organization> orgs = [select IsSandbox from Organization limit 1];
        ZscalerShiftLogin__c result = new ZscalerShiftLogin__c();
        if(orgs[0].IsSandbox)
        {
            result = ZscalerShiftLogin__c.getInstance('Sandbox');
        }
        else
        {
            result = ZscalerShiftLogin__c.getInstance('Production');
        }
        return result;
    }
}