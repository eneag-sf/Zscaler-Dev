@istest
public class ContactthatMattersTest{
    public static id accid;  
    public static id conid;  
    @testSetup static void setupdata(){
       Account acc= new account(Name='TestAccount1',Type='Prospect',Domain__c='zscaler.com', Additional_Organization_Domains__c='Zscaler.in',Override_CTM_Domain__c=true);
       insert acc;
       accid=acc.id;
       List<Contact> ContactList= new List<Contact>();
       Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
       ContactList.add(con);
       Contact con2= new Contact(accountid = acc.Id,lastname = 'testContact2', email='testContact2@zscaler.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
       ContactList.add(con2);
       Contact con3= new Contact(accountid = acc.Id,lastname = 'testContact3', email='testContact3@zscaler.in',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
       ContactList.add(con3);
       Contact con4= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
       ContactList.add(con4);
     
       insert ContactList;
     conid=ContactList[0].id;
    }
    static testMethod void ContactthatMattersTest1() {
        setupdata();
        String contactname='testContact1';
        String accName='TestAccount1';
        boolean checkdomain=false;
        checkdomain=CTMDomainVerificationandCaseCreation.checkdomain(accid,'testContact1@abc.com');
        checkdomain=CTMDomainVerificationandCaseCreation.checkdomain(accid,'testContact2@zscaler.com');
        checkdomain=CTMDomainVerificationandCaseCreation.checkdomain(accid,'testContact2@Zscaler.in');
        String str=CTMDomainVerificationandCaseCreation.createCase(accid,accName,conid,contactname);
    }
  static testMethod void ContactthatMattersTest2() {
        setupdata();
    PageReference pageRef = Page.ContactThatMatterEditPage;
        Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Accid',accid);
        ContactThatMatterEditController CTMcntrller= new ContactThatMatterEditController();
    //CTMcntrller.AvailableWContactList 
    CTMcntrller.AddCTM();
    CTMcntrller.UpdateCTM();
    CTMcntrller.RemoveCTM();
    PageReference pg= CTMcntrller.GotoAccount();
    
    Account acc2= new Account(id=accid,Override_CTM_Domain__c=false);
    update acc2;
    
    Contact con5= new Contact(accountid = accid,lastname = 'testContact5', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
    insert con5;
    
    }
  static testMethod void ContactthatMattersTest3() {
        setupdata();
    
    
    Account acc2= new Account(id=accid,Override_CTM_Domain__c=false);
    update acc2;
    
    Contact con5= new Contact(accountid = accid,lastname = 'testContact5', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
    insert con5;
    
    PageReference pageRef = Page.ContactThatMatterEditPage;
        Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('Accid',accid);
        ContactThatMatterEditController CTMcntrller= new ContactThatMatterEditController();
    CTMcntrller.AddCTM();
    CTMcntrller.CTMWContactList[0].ContactDetails.Send_CIO_Report__c='';
    CTMcntrller.UpdateCTM();    
    CTMcntrller.RemoveCTM();
    }
  static testMethod void ContactthatMattersTest4() {
        setupdata();
    PageReference pageRef = Page.ContactThatMatters;
        Test.setCurrentPage(pageRef);
    Account acc=[Select id,Name,Type,Domain__c,Additional_Organization_Domains__c,Override_CTM_Domain__c from Account where id=:accid];
    //ApexPages.currentPage().getParameters().put('Accid',accid);
    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ContactThatMattersControllerExt CTMcntrller= new ContactThatMattersControllerExt(sc);
    PageReference pg1 = CTMcntrller.Updatecontacts();
    PageReference pg2 = CTMcntrller.Cancel();
    }
}