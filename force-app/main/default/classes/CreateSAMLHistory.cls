public without sharing class CreateSAMLHistory {
    public static void createSSOsamlhistory(Map<String, String> req, String res, String accountId,String email,String status, String accName, String ziaorzpa){
        SSO_SAML_History__c sso = new SSO_SAML_History__c();
        String request = '{';
        for(String s: req.keyset()){
            request += s + ': ' + req.get(s) + ',';
        }
        request += '}';
        sso.SAML_Request__c = request;
        sso.SAML_Response__c = res;
        sso.Account_Id__c = accountId;
        sso.Email__c = email;
        sso.Status__c = status;
        sso.Account_Name__c = accName;
        sso.SSO_Initiated_from__c = ziaorzpa;
        sso.Found_Account__c = accountId != null && accountId != '';
        sso.Found_Email__c = email != null && email != '';
        insert sso ;
    }
}