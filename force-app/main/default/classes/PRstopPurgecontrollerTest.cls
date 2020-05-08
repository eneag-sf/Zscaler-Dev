@isTest(Seealldata=true)
public class PRstopPurgecontrollerTest{
    @isTest static void test(){
        test.starttest();
      
            Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
            insert acc;
            
            Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            
            Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.id,
                                                                 RecordTypeId = inlineRecordTypeId,
                                                                 Organization_Domain__c = 'Test',
                                                                 Additional_Organization_domains__c = 'Test',/*'Zscaler.net'*/
                                                                 Send_Initial_l__c = 'ATT Usell',
                                                                 Provisioning_Status__c = 'To Be Purged');
            //insert Pr;
            List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Opportunity__c != null  AND Account__c != null limit 1]; 
     
                
            //PageReference ref = new PageReference('/apex/PRStopPurgePage?id=' +Pr.Id);
            //Test.setCurrentPage(ref);
            //ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
            //Pagereference pgref=con.SubmitforStopPurge();
            
            PageReference myVfPage = Page.PRStopPurgePage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisioningRequests[0]);   
            PRstopPurgecontroller pc= new PRstopPurgecontroller(sc);
            pc.booster();
			
			PageReference myVfPage2 = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage2);
            ApexPages.StandardController sc2 = new ApexPages.StandardController(provisioningRequests[0]);   
            PRExtcontroller pc2= new PRExtcontroller(sc2);
            pc2.booster();
            
        test.stoptest();
    }
}