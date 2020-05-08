@istest(Seealldata=false)
public class AutocreateZscalerCloudIDContactTest{
    
    /* public static void Setupdata(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        
    }
     */
    public static testmethod void test1(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        //Setupdata();
        system.debug('in test1 ');
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        TriggerUtility.ZCloudIDcontactAfterInserttriggersetfalse();
        List<Zscaler_Cloud_ID_Contact__c> ZSCClist= new List<Zscaler_Cloud_ID_Contact__c>();
        Zscaler_Cloud_ID_Contact__c  ZCC= new Zscaler_Cloud_ID_Contact__c(Account__c=acctTest.id,Contact__c=con.id,Zscaler_Cloud_ID__c=ZSClIDlist[0].id);
        ZSCClist.add(ZCC);
        insert ZSCClist;

        //TriggerUtility.ZCloudIDcontactAfterInserttriggersetfalse();
        AutocreateZscalerCloudIDContact.UpdateContactonZSCloudContactInsert(ZSCClist);
        
        delete ZCC;
        
        delete ZSClIDlist;
        
        test.stoptest();        
    }
        /* public static testmethod void test2(){
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        system.debug('in test1 ');
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test1',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Account__c=acctTest.Id,NS_Org_ID__c='Zscloud.net-3926test2',Zscaler_Cloud_Domain__c='testacc.com.au.test2',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true,Send_CIO_Report__c='Send');
        insert con; 
        test.starttest();
        
        Zscaler_Cloud_ID_Contact__c  ZCC= new Zscaler_Cloud_ID_Contact__c(Account__c=acctTest.id,Contact__c=con.id,Zscaler_Cloud_ID__c=ZSClIDlist[0].id);
        insert ZCC;
        
        // delete ZCC;
        
        //delete ZSClIDlist; 
        
        test.stoptest();        
    } */
        
}