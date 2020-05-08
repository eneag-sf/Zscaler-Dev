/*****************************************************************************************
Name: ZIAUserNameCheckService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Restful Service Class to check the existance of ZIA User name(in Contact)
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Abhishek V           31-Dec-2019       Initial Version
******************************************************************************************/
@RestResource(urlMapping = '/checkZIAUserName/*')
global without sharing class ZIAUserNameCheckService{
    //Get method receives two paramemters zia Org ID and zia UserName.
    global static final String NO_CONTACT_FOUND = 'No Contact Found';
    global static final String ERROR_SF = 'Error Occured in Salesforce';
    global static final String EMAIL_FOUND = 'Email Found';
    global static final String PARAMETER_MISSING = 'One or More of the Required parameters are missing in the request';
    @HttpGet
    global static ResponseStructure checkziaUser(){
       
       RestRequest request = RestContext.request;
       ResponseStructure response;
       String email;
       String status;
       String accountId;
       String accName;
       String excepmsg = '';
       if(request.params!=null && request.params.containsKey('ziaOrgId')
          &&  request.params.containsKey('ziaUserName')
          &&  String.isNotBlank(request.params.get('ziaOrgId')) 
          &&  String.isNotBlank(request.params.get('ziaUserName'))){
            system.debug('ziaOrgId '+request.params.get('ziaOrgId'));
            system.debug('ziaUserName '+request.params.get('ziaUserName'));
            List<Contact> contactList;
            List<Zscaler_Cloud_ID__c> zScalerCloudList = [SELECT Id, Name,Org_Name__c,Account__c, Account__r.Name FROM Zscaler_Cloud_ID__c WHERE Name = : request.params.get('ziaOrgId') LIMIT 1];
            accountId = zScalerCloudList!= null && !zScalerCloudList.isEmpty() && zScalerCloudList[0].Account__c!=null ?
                         zScalerCloudList[0].Account__c : null;
            accName = zScalerCloudList!= null && !zScalerCloudList.isEmpty() && zScalerCloudList[0].Account__r.Name!=null ?
                         zScalerCloudList[0].Account__r.Name : null;
            System.debug('contactList '+contactList);
            if(String.isNotBlank(accountId)){
                contactList = [Select Id,Email,FirstName, LastName, zia_User_Name__c FROM Contact WHERE (zia_User_Name__c = :request.params.get('ziaUserName') or Email = :request.params.get('ziaUserName')) AND AccountId = :accountId LIMIT 1];
            }
            if(contactList!=null && !contactList.isEmpty() && contactList[0].Email != null){
                email = contactList[0].Email;
                String usercreationstatus = CreatePortalUser.checkforPortalUser(contactList[0], 'Customer Community User Profile', request.params.get('ziaUserName'));
                if(usercreationstatus == 'Success'){
                    status = EMAIL_FOUND;
                }else{
                    status = EMAIL_FOUND;
                    excepmsg = usercreationstatus;
                }
            }
            else {
                status = NO_CONTACT_FOUND;
            }   
       }
       else{
            status = PARAMETER_MISSING;                    
       }
       ResponseStructure res = new ResponseStructure(accountId,email,status, accName);
       
       CreateSAMLHistory.createSSOsamlhistory(request.params, JSON.serialize(res), accountId,email, status + excepmsg, accName, 'ZIA');
       return res;
    }

    //Response Structure.
    global class ResponseStructure{
        String accountId;
        String accountName;
        String email;
        String status;

        global ResponseStructure(String accountId,String email,String status, String accName){
            this.accountId = accountId;
            this.accountName = accName;
            this.email = email;
            this.status = status;
        }

    }

}