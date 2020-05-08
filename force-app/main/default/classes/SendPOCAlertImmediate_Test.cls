@isTest
public class SendPOCAlertImmediate_Test{
    static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Provisioning_Request__c PRRec= new Provisioning_Request__c();
        PRRec.Account__c = acctTest.Id;
        PRRec.Provisioning_Status__c = 'Production';
        PRRec.Organization_Domain__c = 'motabilityoperations.co.uk';
        PRRec.Send_Initial_l__c = 'SE';
        PRRec.SE__c = u.Id;
        PRRec.Approval_for_Purge_Status__c = 'Not Yet Submitted for Purge Approval';
        PRRec.Provisioning_Date__c = system.today().addDays(-30);
        PRRec.Provisioning_Request_Expiry_Date__c = system.today();
        PRRec.Email_Sent__c = date.today().adddays(-5);
        PRRec.Send_Reminder_Emails__c = true;
		try{
        insert PRRec; 
        
        SendPOCAlertImmediate.pocSendEmail(PRRec.Id);
		}catch(Exception ex){
		}
        
    }
}