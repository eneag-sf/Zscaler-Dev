@isTest
public class genericSiteRequestTriggerTest {
    @isTest static void Test1(){
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true);
        insert EquiReq;
        
        Site_Request__c SiteReq = new Site_Request__c();
        SiteReq.Customer_Name__c = account.Id;
        SiteReq.Number_of_users__c = 10;
        SiteReq.Country_for_ME_Node__c = 'Qatar';
        SiteReq.ISP_Used__c = 'Test';
        SiteReq.Domain_Name__c = 'Test';
        SiteReq.Is_this_for_a_POC__c = 'Yes';
        SiteReq.Estimated_Start_Date__c = system.today();
        SiteReq.Estimated_Stop_Date__c = system.today();
        SiteReq.Contact_Name__c = 'Test';
        SiteReq.Contact_Email__c = 'Test@Test.com';
        SiteReq.ME_Equipment_Request__c = EquiReq.Id;
        insert SiteReq; 
        
        try
			{
				Delete 	SiteReq;
			}
			catch(Exception ee)
			{}
    }
}