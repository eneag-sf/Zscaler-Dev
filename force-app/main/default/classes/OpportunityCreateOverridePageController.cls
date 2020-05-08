public class OpportunityCreateOverridePageController {

    private final sObject mysObject;
    public String userProfileId { get; set; }
    public String userId { get; set; }
    public String retUrl { get; set; }
    public Boolean showError { get; set; }
    public Map<String, String> queryParams { get; set; }
    public Id contactId { get; set; }
    public Id accountId { get; set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public OpportunityCreateOverridePageController(ApexPages.StandardController stdController) {
        userProfileId = UserInfo.getProfileId();
        userId = UserInfo.getUserId();
        queryParams = ApexPages.currentPage().getParameters();
        retUrl = queryParams.get('retUrl');
        accountId = queryParams.containsKey('accId') ? queryParams.get('accId') : null;
        contactId = queryParams.containsKey('conId') ? queryParams.get('conId') : null;
    }

    public PageReference redirect() {
        ZscalerSetting__c setting = ZscalerSetting__c.getValues('OpportunityCreateOverrideProfileIds');
        ZscalerSetting__c Useridsetting = ZscalerSetting__c.getValues('OpportunityCreateOverrideUserIds');

        if ((setting != null && setting.Value__c != null && setting.Value__c.contains(userProfileId.subString(0, 15))) 
            || (Useridsetting != null && Useridsetting.Value__c != null && Useridsetting.Value__c.contains(userId))
            || contactId != null) {
            String params = '?';
            for (String key : queryParams.keySet()) {
                if (!key.equalsIgnoreCase('save_new')) {
                    params += (key + '=' + queryParams.get(key) + '&');
                }
            }
            params += 'nooverride=1';

            PageReference opptyCreate = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=' + EncodingUtil.urlEncode(retURL, 'UTF-8') + '&save_new_url=%2F006%2Fe' + EncodingUtil.urlEncode(params, 'UTF-8'));
            opptyCreate.setRedirect(true);
            return opptyCreate;
        } else {
            showError = true;
            return null;
        }
    }

    public PageReference goBack() {
        return new PageReference(retUrl);
    }
}