@isTest
public class PRExtcontrollerTest {
    
    
    @testSetup static void setup() {
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Provisioning_Request__c PRRec= new Provisioning_Request__c();
        PRRec.Account__c = acctTest.Id;
        PRRec.Provisioning_Status__c = 'Provisioned';
        PRRec.Organization_Domain__c = 'motabilityoperations.co.uk';
        PRRec.Send_Initial_l__c = 'SE';
        PRRec.SE__c = u.Id;
        PRRec.Provisioning_Date__c = system.today().addDays(-30);
        PRRec.Provisioning_Request_Expiry_Date__c = system.today();
		try{
        insert PRRec;      
		}catch(Exception ex){}
    }
    
    static testMethod void testPRAutoApprove(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(20);
            prc.Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = 'need extension more';
            prc.submitForApproval();
            Test.stopTest();
            
            List<Provisioning_Request__c> afterSubmittion = [Select Id,
                                                                    Number_of_Extensions__c,
                                                                    Provisioning_Extension_Status__c
                                                                    from 
                                                                    Provisioning_Request__c
                                                                    Where 
                                                                    Id =: provisionRequest[0].Id];
            system.assertEquals(1, afterSubmittion[0].Number_of_Extensions__c);
            system.assertEquals('Extended', afterSubmittion[0].Provisioning_Extension_Status__c);
        }
    }
    
    static testMethod void testPRExtensionGreaterThan30Days(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(40);
            prc.Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = 'need extension more';
            prc.submitForApproval();
            Test.stopTest();
            
            for(Apexpages.Message thisMsg : ApexPages.getMessages()){
                system.assert(thisMsg.getDetail().contains('Extension date cannot be greater than'));
            }
        }
    }
    
    static testMethod void testPRExtensionAlreadyApproved(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(-10);
            prc.Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = 'need extension more';
            prc.submitForApproval();
            Test.stopTest();
            system.debug('the page messages are' + ApexPages.getMessages());
            for(Apexpages.Message thisMsg : ApexPages.getMessages()){
                system.assert(thisMsg.getDetail().contains('PR is already approved till'));
            }
        }
    }
    
    static testMethod void testPRExtensionWithNoDetails(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(-10);
            prc.submitForApproval();
            Test.stopTest();
            system.debug('the page messages are' + ApexPages.getMessages());
            for(Apexpages.Message thisMsg : ApexPages.getMessages()){
                system.assert(thisMsg.getDetail().contains('Provisioning End Date and Detailed Reason for Contract Extension are required'));
            }
        }
    }
    
    static testMethod void testCancelPopUp(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(provisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(-10);
            prc.cancelExtensionpopup();
            Test.stopTest();
        }
    }
    static testMethod void testPRAutoManualApprove(){
        List<Provisioning_Request__c> provisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c LIMIT 1];
        if(!provisionRequest.isEmpty()){
            provisionRequest[0].PR_Extension_Requested_Date__c =  system.today().addDays(20);
            provisionRequest[0].Number_of_Extensions__c =  1;
            update provisionRequest[0];
            
            List<Provisioning_Request__c> updatedprovisionRequest = [Select Id,
                                                                Account__c,
                                                                Provisioning_Status__c,
                                                                Organization_Domain__c,
                                                                Send_Initial_l__c,
                                                                SE__c,
                                                                Extension_Requested_On__c,
                                                                Provisioning_Request_Expiry_Date__c,
                                                                PR_Extension_Requested_Date__c,
                                                                Number_of_Extensions__c
                                                                from Provisioning_Request__c 
                                                                Where
                                                                Id =: provisionRequest[0].Id 
                                                                LIMIT 1];
            
            Test.startTest();
            PageReference myVfPage = Page.ProvisionExtensionPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(updatedprovisionRequest[0]);
            PRExtcontroller prc = new PRExtcontroller(sc);
            prc.Prvsn_Rqst.PR_Extension_Requested_Date__c =  system.today().addDays(25);
            prc.Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = 'need extension more';
            prc.submitForApproval();
            Test.stopTest();
            List<Provisioning_Request__c> afterSubmittion = [Select Id,
                                                                    Number_of_Extensions__c,
                                                                    Provisioning_Extension_Status__c
                                                                    from 
                                                                    Provisioning_Request__c
                                                                    Where 
                                                                    Id =: provisionRequest[0].Id];
            system.assertEquals(1, afterSubmittion[0].Number_of_Extensions__c);
            system.assertEquals('PR Extension Rejected', afterSubmittion[0].Provisioning_Extension_Status__c);
        }
    }
}