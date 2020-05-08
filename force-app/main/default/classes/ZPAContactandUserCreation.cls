@RestResource(urlMapping = '/createZPAcontactandUser/*')
global without sharing class ZPAContactandUserCreation {
    //Get method receives two paramemters ZPA Org ID and ZPA UserName.
    global static final String ERROR_SF = 'Error Occured in Salesforce';
    global static final String EMAIL_FOUND = 'Email Found';
    global static final String PARAMETER_MISSING = 'One or More of the Required parameters are missing in the request';
    @HttpGet
    global static ResponseStructure createZPAcontactandUser(){
       
       RestRequest request = RestContext.request;
       ResponseStructure response;
       String email;
       String status;
       String accountId;
       String excepmsg = '';
       if(request.params!=null && request.params.containsKey('accountId')
          &&  request.params.containsKey('zpaUserName') 
          && request.params.containsKey('zpaEmail')
          &&  request.params.containsKey('firstName')
          &&  request.params.containsKey('lastName') 
          &&  String.isNotBlank(request.params.get('accountId')) 
          &&  String.isNotBlank(request.params.get('zpaUserName')) 
          &&  String.isNotBlank(request.params.get('zpaEmail')) 
          &&  String.isNotBlank(request.params.get('firstName')) 
          &&  String.isNotBlank(request.params.get('lastName'))){
            system.debug('zpaOrgId '+request.params.get('zpaOrgId'));
            system.debug('zpaUserName '+request.params.get('zpaUserName'));
            List<Contact> contactList = [Select Id,Email,FirstName, LastName, ZPA_User_Name__c from contact where Email = :request.params.get('zpaEmail')  and AccountId = :request.params.get('accountId')];
            accountId = request.params.get('accountId');
            if(!contactList.isEmpty()){
                contactList[0].Email = request.params.get('zpaEmail');
                contactList[0].ZPA_User_Name__c = request.params.get('zpaUserName');
                ContactTriggerHelper.skipTrigger = true;
                TriggerUtility.realignPatch();
                TriggerUtility.SkipAccTriggerExecuted();
                try{
                    update contactList;
                    email = contactList[0].Email;
                    String usercreationstatus = CreatePortalUser.checkforPortalUser(contactList[0], 'Customer Community User Profile',email);
                    if(usercreationstatus == 'Success'){
                        status = EMAIL_FOUND;
                    }else{
                        status = ERROR_SF;
                        excepmsg = usercreationstatus;
                    }
                }catch(Exception ex){
                    status = ERROR_SF;
                    excepmsg = '' + ex.getMessage();
                }
            }else{
                Contact con = new Contact();
                con.FirstName = request.params.get('firstName');
                con.LastName = request.params.get('lastName');
                con.AccountId = request.params.get('accountId');
                con.ZPA_User_Name__c = request.params.get('zpaUserName');
                con.Email = request.params.get('zpaEmail');
                
                try{
                    ContactTriggerHelper.skipTrigger = true;
                    TriggerUtility.realignPatch();
                    TriggerUtility.SkipAccTriggerExecuted();
                    insert con;
                    email = con.Email;
                    String usercreationstatus = CreatePortalUser.checkforPortalUser(con, 'Customer Community User Profile',email );
                    if(usercreationstatus == 'Success'){
                        status = EMAIL_FOUND;
                    }else{
                        status = ERROR_SF;
                        excepmsg = usercreationstatus;
                    }
                }catch(Exception ex){
                    status = ERROR_SF;
                    excepmsg = '' + ex.getMessage();
                }
            }
       }
       else{
            status = PARAMETER_MISSING;                    
       }
       ResponseStructure res = new ResponseStructure(accountId,email,status);
       
       CreateSAMLHistory.createSSOsamlhistory(request.params, JSON.serialize(res), accountId,email,status == ERROR_SF ? status + ' - ' + excepmsg : status,'', 'ZPA-Contact-User-Creation');
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