@isTest
public class ZendeskSupportTicketTriggerHelperTest {

    @testSetup static void setup() 
    {
        RecordType recType = [select Id,name from RecordType where name='End User - Customer DS Reviewed' and sObjectType='Account'];
        
        Account cust = new Account();
        cust.Name = 'Customer1';
        cust.RecordTypeId = recType.Id;
        cust.Type = 'Customer';
        cust.DS_Review_Status__c = 'Complete';
        cust.Contract_Review__c = 'Review Complete';
        
        insert cust;
        
        Contact custContact = new Contact();
        custContact.FirstName = 'FirstName';
        custContact.LastName = 'LastName';
        custContact.AccountId = cust.Id;
        custContact.Contact_Type__c = 'Existing Customer';
        custContact.Email = 'test@test.com';
        custContact.LeadSource = 'Webinars';
        
        insert custContact;
        
        Lead ld = new Lead();
        ld.FirstName = 'Lead';
        ld.LastName = 'LName';
        ld.Email = 'ldname@ldname.com';
        ld.LeadSource = 'Webinars';
        ld.Company = 'ABCD';
        
        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = 'zdavav';
        cloudId.Org_Name__c = '';
        cloudId.Status__c = 'Production';
        cloudId.Account__c = cust.Id;
        
        insert cloudId;
    }
    static TestMethod void createTicket()
    {
        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c();
        ticket.Name ='350834_9';
        ticket.Zendesk__Subject__c = 'Test Subject';
        ticket.Zendesk__Ticket_ID__c = '350834_9';
        ticket.Zendesk__Description__c = 'Test Description';
        ticket.Area__c = 'Deployment';
        ticket.Sub_Area__c = 'Project';
        ticket.Zendesk__Status__c = 'Pending';
        ticket.Org_ID__c = 'zdavav';
        
        insert ticket;
    }
    
    static TestMethod void updateTicket()
    {
        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c();
        ticket.Name ='350834_9';
        ticket.Zendesk__Subject__c = 'Test Subject';
        ticket.Zendesk__Ticket_ID__c = '350834_9';
        ticket.Zendesk__Description__c = 'Test Description';
        ticket.Area__c = 'Deployment';
        ticket.Sub_Area__c = 'Project';
        ticket.Zendesk__Status__c = 'Pending';
        ticket.Org_ID__c = 'zdavav';
        
        insert ticket;
        
        ticket.DAS_SKU__c = 'DAS SKU';
        ticket.DAS_Status__c = 'Pending';
        ticket.F90__c = 'Pending';
        ticket.Initial_Design_Plan_URL__c = 'desingplan.com';
        ticket.Final_Design_Plan_URL__c = 'finaldesignplan.com';
        ticket.Current_ZMCA_Score_Card_URL__c = 'scorecard.com';
        ZendeskSupportTicketTriggerHelper.skipTrigger = false;
        update ticket;
    }
    
    static TestMethod void updatePIQTicket()
    {
        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c();
        ticket.Name ='907865';
        ticket.Zendesk__Subject__c = 'Test Survey';
        ticket.Zendesk__Ticket_ID__c = '907865';
        ticket.Zendesk__Description__c = 'Test Description';
        ticket.Area__c = 'Deployment';
        ticket.Sub_Area__c = 'Project';
        ticket.Zendesk__Status__c = 'Pending';
        ticket.Org_ID__c = 'zdavav';
        ticket.Integration_Status__c = 'open';
        ticket.Integration_Requestor_Name__c = 'Raghu Test Corp';
        ticket.Integration_Ticket_Assignee__c = 'Raghu Manchiraju';
        ticket.Integration_Requestor_Email__c ='ldname@ldname.com';
        ticket.Integration_Type__c = 'problem';
        ticket.Integration_Subject__c = 'Test Survey';
        ticket.Integration_Assignee_Id__c = '2991897443';
        ticket.Integration_Assignee_Manager_Id__c = '384558519771';
        
        insert ticket;
        
        ticket.DAS_SKU__c = 'DAS SKU';
        ticket.DAS_Status__c = 'Pending';
        ticket.F90__c = 'Pending';
        ticket.Initial_Design_Plan_URL__c = 'desingplan.com';
        ticket.Final_Design_Plan_URL__c = 'finaldesignplan.com';
        ticket.Current_ZMCA_Score_Card_URL__c = 'scorecard.com';
        
        ticket.Integration_Status__c = 'solved';
        ticket.Integration_Requestor_Name__c = 'Raghu Test Corp';
        ticket.Integration_Ticket_Assignee__c = 'Raghu Manchiraju';
        ticket.Integration_Requestor_Email__c ='abcd@egmail.com';
        ticket.Integration_Type__c = 'problem';
        ticket.Integration_Subject__c = 'Test Survey';
        ticket.Integration_Assignee_Id__c = '2991897443';
        ticket.Integration_Assignee_Manager_Id__c = '384558519771';
        ZendeskSupportTicketTriggerHelper.skipTrigger = false;
        update ticket;
    }
}