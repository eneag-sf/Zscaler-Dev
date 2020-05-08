@isTest(seeAllData = true)
public class ProvisioningFevaRequestControllerTest{
    @isTest static void test(){
        test.starttest();
            List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Opportunity__c != null  AND Account__c != null  limit 1]; 
     
            PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +provisioningRequests[0].Id);
            Test.setCurrentPage(ref);
            ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
            con.initUserCreation();
            FeVaUserCreationUtil.UpdateProvReq(provisioningRequests[0], 'Error');
            
        test.stoptest();
    }
}