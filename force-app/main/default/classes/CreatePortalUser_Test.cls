@isTest
public class CreatePortalUser_Test {
    @testSetup static void setupdata(){
    insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
    
    List<Account>  CreateAccounts= new List<Account>(); 
        Integer numAccts=1;
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i,Type='Customer',Domain__c='TestAccount'+i+'.com',Current_ARR__c=5);
            CreateAccounts.add(a);
        }
        TriggerUtility.SkipAccTriggerExecuted();
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        insert CreateAccounts;
    }
    @IsTest
    static void test1(){
        List<Contact> CntctList= new List<Contact>();
        
        Account Acc= [Select id,domain__c from Account Limit 1];
        
        Contact Con= new Contact(Accountid=Acc.id,FirstName='Test',LastName='Con1',email='TestCon1@'+acc.domain__c,Head_of_It__c=true,ZPA_Interactive_Prospect__c=true);
        CntctList.add(Con);
        Contact Con2= new Contact(Accountid=Acc.id,FirstName='Test',LastName='Con1',email='TestCon1@'+acc.domain__c,Head_of_Networking__c=true,Head_of_Security__c=true,ZPA_Interactive_Prospect__c=false);
        CntctList.add(Con2);
        ContactTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        insert CntctList;
        CreatePortalUser.checkforPortalUser(Con, 'Zscaler Partner Community User', con.email);
        CreatePortalUser.booster();
    }
}