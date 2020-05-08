/*****************************************************************************************
Name: ZPAUserNameCheckService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Restful Service Class to check the existance of ZPA User name(in Contact)
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Puneeth Bharath       19-Dec-2019       Initial Version
******************************************************************************************/
@RestResource(urlMapping = '/checkZPAUserName/*')
global without sharing class ZPAUserNameCheckService {
    //Get method receives two paramemters ZPA Org ID and ZPA UserName.
    global static final String NO_CONTACT_FOUND = 'No Contact Found';
    global static final String ERROR_SF = 'Error Occured in Salesforce';
    global static final String EMAIL_FOUND = 'Email Found';
    global static final String PARAMETER_MISSING = 'One or More of the Required parameters are missing in the request';
    @HttpGet
    global static ResponseStructure checkZPAUser(){
       
       RestRequest request = RestContext.request;
       ResponseStructure response;
       String email;
       String status;
       String accountId;
       String excepmsg = '';
       if(request.params!=null && request.params.containsKey('zpaOrgId')
          &&  request.params.containsKey('zpaUserName')
          &&  String.isNotBlank(request.params.get('zpaOrgId')) 
          &&  String.isNotBlank(request.params.get('zpaUserName'))){
            system.debug('zpaOrgId '+request.params.get('zpaOrgId'));
            system.debug('zpaUserName '+request.params.get('zpaUserName'));
            List<Contact> contactList;
            List<Zscaler_Cloud_ID__c> zScalerCloudList = [SELECT Id, Name,Org_Name__c,Account__c FROM Zscaler_Cloud_ID__c WHERE Name = : request.params.get('zpaOrgId') LIMIT 1];
            accountId = zScalerCloudList!= null && !zScalerCloudList.isEmpty() && zScalerCloudList[0].Account__c!=null ?
                         zScalerCloudList[0].Account__c : null;
            System.debug('contactList '+contactList);
            if(String.isNotBlank(accountId)){
                contactList = [Select Id,FirstName, LastName, Email,ZPA_User_Name__c FROM Contact WHERE (ZPA_User_Name__c = :request.params.get('zpaUserName') or Email = :request.params.get('zpaUserName')) AND AccountId = :accountId LIMIT 1];
            }
            if(contactList!=null && !contactList.isEmpty() && contactList[0].Email != null){
                email = contactList[0].Email;
                String usercreationstatus = CreatePortalUser.checkforPortalUser(contactList[0], 'Customer Community User Profile',email);
                if(usercreationstatus == 'Success'){
                    status = EMAIL_FOUND;
                }else{
                    status = ERROR_SF;
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
       ResponseStructure res = new ResponseStructure(accountId,email,status);
       
       CreateSAMLHistory.createSSOsamlhistory(request.params, JSON.serialize(res), accountId,email,status == ERROR_SF ? status + ' - ' + excepmsg : status,'', 'ZPA');
       return res;
    }

    //Response Structure.
    global class ResponseStructure{
        String accountId;
        String email;
        String status;

        global ResponseStructure(String accountId,String email,String status){
            this.accountId = accountId;
            this.email = email;
            this.status = status;
        }

    }

}