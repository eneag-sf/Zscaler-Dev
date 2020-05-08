@isTest
public class SurveyTriggerHelperTest {
    
    @TestSetup
    static void makeData(){
        insert TestDatafactory_Zscaler.getDefaultData();
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

        Zendesk__Zendesk_Ticket__c ticket = new Zendesk__Zendesk_Ticket__c();
        ticket.Name ='907865';
        ticket.Zendesk__Subject__c = 'Test Survey';
        ticket.Zendesk__Ticket_ID__c = '907865';
        ticket.Zendesk__Description__c = 'Test Description';
        ticket.Area__c = 'Deployment';
        ticket.Sub_Area__c = 'Project';
        ticket.Zendesk__Status__c = 'Pending';
        ticket.Org_ID__c = 'zdavav';
        ticket.Integration_Status__c = 'solved';
        ticket.Integration_Requestor_Name__c = 'Raghu Test Corp';
        ticket.Integration_Ticket_Assignee__c = 'Raghu Manchiraju';
        ticket.Integration_Requestor_Email__c ='abcd@egmail.com';
        ticket.Integration_Type__c = 'problem';
        ticket.Integration_Subject__c = 'Test Survey';
        ticket.Integration_Assignee_Id__c = '2991897443';
        ticket.Integration_Assignee_Manager_Id__c = '384558519771';
        ticket.Zendesk__Organization__c =cust.Id;
        insert ticket;
    }

    @isTest static void createPromoterSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Survey_Status__c = 'Survey Sent';

        insert sury;

        sury.Survey_Response_Received__c =true;
        sury.Survey_Status__c = 'Response Received';
        //NPS
        sury.Will_you_recommend_Zscaler__c = 10;
        sury.Easy_to_handle_Issue__c = '7 - Strongly Agree';
        
        sury.Rate_your_experience__c = 4.0;

        update sury;
    }


    @isTest static void createPassiveSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Survey_Status__c = 'Survey Sent';
        sury.Case_Owner_Manager__c = userinfo.getUserId();

        insert sury;

        sury.Survey_Response_Received__c =true;
        sury.Survey_Status__c = 'Response Received';
        sury.Will_you_recommend_Zscaler__c = 8;
        sury.How_can_we_make_you_happier__c ='blah blah..';
        sury.Easy_to_handle_Issue__c = '5 - Somewhat Agree';
        sury.One_thing_we_could_do_to_mak__c = '';

        sury.Rate_your_experience__c = 3.0;

        update sury;
    }


    @isTest static void createDetractorSurvey()
    {
        Survey__c sury = new Survey__c();
        sury.recordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        sury.Zendesk_ticket__c = [Select Id from Zendesk__Zendesk_Ticket__c limit 1].Id;
        sury.Contact_Email__c ='abcd@egmail.com';
        sury.Contact_Name__c = 'Contact Name';
        sury.Ticket_Assignee__c = 'Assignee Name';
        sury.Type__c = 'Problem';
        sury.Ticket_Status__c = 'Solved';
        sury.Assignee_Manager__c = 'rmanchiraju@zscaler.com';
        sury.Case_Owner_Manager__c = userinfo.getUserId();
        sury.Survey_Status__c = 'Survey Sent';

        insert sury;

        sury.Survey_Response_Received__c =true;
        sury.Survey_Status__c = 'Response Received';
        sury.Will_you_recommend_Zscaler__c = 5;
        sury.How_can_we_make_you_happier__c ='blah blah..';
        sury.Easy_to_handle_Issue__c = '3 - Somewhat Disagree';
        sury.One_thing_we_could_do_to_mak__c = '';

        sury.Rate_your_experience__c = 2.0;

        update sury;
    }
}