public class ProvisioningFevaRequestController {
    
    private String provisioningRequestId = ApexPages.currentPage().getParameters().get('id');
    public integer Step{get;set;}
    public ProvisioningFevaRequestController(){
        step = 0;
    }
    public PageReference initUserCreation() {

     List<Provisioning_Request__c> provisioningRequests = [select Id, Name, Customer_Account_from_Opportunity__c, FailedReason__c, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Id =:provisioningRequestId]; 
     if(provisioningRequests.size() > 0)
         FeVaUserCreationUtil.createUsers(provisioningRequests[0]);
     PageReference pg = new PageReference('/'+provisioningRequestId);
        
        
        return pg;
    }
    
    public PageReference initFevaProcess() {
       Step = 1;
       return null;
    }
}