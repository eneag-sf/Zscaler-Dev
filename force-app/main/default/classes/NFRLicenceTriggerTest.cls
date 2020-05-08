@isTest
private class NFRLicenceTriggerTest {

	private static testMethod void test() {
	      
	    Test.StartTest();
        
        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByName().get('Partners').getRecordTypeId();
	    Contact c=new Contact(
        FirstName='test',
        LastName = 'test',
        Email = 'Test@gmail.com',
        Phone = '0097438003'); 
        insert c;
        
        Product2 prod = new Product2(Name = 'Test', Product_SKU_External_ID__c = 'ZSC-SIP',
                                     Family = 'Hardware');
        insert prod;
        
        NFR__c NFR = new NFR__c();
        NFR.Name = 'Test';
        NFR.Organisation_Domain__c = 'Test';
        NFR.Partner_Contact__c = c.Id;
        NFR.Preferred_Cloud__c = 'Zscalereone.net';
        NFR.Send_Initial_Credentials_To__c = 'Partner';
        NFR.NFR_Licence_Status__c = 'Not Active';
        NFR.Approval_Status__c = 'Approved';
        NFR.ZIA_NFR__c = false;
        NFR.ZPA_NFR__c = true;
        NFR.SIP__c = true;
        NFR.Start_Date__c = system.today();
        NFR.Expiry_Date_FromStartDate__c = system.today();
        NFR.RecordTypeId = TechPartnerRecordTypeId;
        NFR.Is_Customer_Using_ZIA__c = 'Yes';
        NFR.User_Authentication_Domains__c = 'Test';
        NFR.Is_Zapp_used__c = 'Yes';
        insert NFR;
        List<NFR__c> NFRList = new List<NFR__c>();
        NFRList.Add(NFR);
        
		NFR.Name = 'Test1';
        NFR.Approval_Status__c = 'Submitted';
        NFR.Start_Date__c = system.today().addMonths(1);  
        NFR.NFR_Licence_Status__c = 'In-Progress';
        Update NFR; 		
        
        NFR.Name = 'Test2';
        NFR.Approval_Status__c = 'Approved';
        NFR.NFR_Licence_Status__c = 'In-Progress';
        Update NFR; 
        
        NFRLicenceTriggerHandler.provisionRequestCreate(NFR,'ZIA');
        Test.StopTest();
	}
    
    private static testMethod void testTriggerHelper(){
        
        string UserId = UserInfo.getUserId();
        set<id> OwnerId = new set<id>();
        
        Test.StartTest();
        NFRLicenceTriggerHelper Helper = new NFRLicenceTriggerHelper();
        NFRLicenceTriggerHelper.getAccountOwnerEmails(OwnerId);
        NFRLicenceTriggerHelper.getSpecificUserEMails();
        Test.StopTest();
    }

}