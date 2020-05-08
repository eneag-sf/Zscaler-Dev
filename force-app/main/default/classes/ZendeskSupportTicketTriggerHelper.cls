/*
*  Trigger on Zendesk Support Ticket Object
*  Author              Version     Description
*  Raghu Manchiraju    v1.0        Initial Trigger Helper. Added logic to add Account if OrgId is populated correctly.
*  Raghu Manchiraju    v1.1        Adding logic for DAS ::  Area="Deployment" and Sub Area ="Project" or "Kick off Call"
*
*/

public class ZendeskSupportTicketTriggerHelper
{
    public static boolean skipTrigger = false;
    
    public void OnBeforeInsert(List<Zendesk__Zendesk_Ticket__c> newSupportTickets)
    {
        Set<String> orgIds = new Set<String>();
        //Org_ID__c
        for(Zendesk__Zendesk_Ticket__c ticket : newSupportTickets)
        {
            if(ticket.Org_ID__c != null && ticket.Zendesk__Organization__c == null)
            {
                orgIds.add(ticket.Org_ID__c);
            }
        }
        
        List<Zscaler_Cloud_ID__c> CloudInfoList = [select Id,Name,Account__c from Zscaler_Cloud_ID__c where name in :orgIds];
        
        Map<String,String> mapCloudInfo = new Map<String,String>();
        for(Zscaler_Cloud_ID__c zCloud : CloudInfoList)
        {
            mapCloudInfo.put(zCloud.Name,zCloud.Account__c);
        }
        
        for(Zendesk__Zendesk_Ticket__c ticket : newSupportTickets)
        {
            if(ticket.Org_ID__c != null && ticket.Zendesk__Organization__c == null && (mapCloudInfo.get(ticket.Org_ID__c) != null))
            {
                ticket.Zendesk__Organization__c = mapCloudInfo.get(ticket.Org_ID__c);
            }
        }
        
    }
    
    public void OnAfterInsert(List<Zendesk__Zendesk_Ticket__c> newSupportTickets)
    {
        Set<Id> accountIdSet = new Set<Id>();
        Map<String,Zendesk__Zendesk_Ticket__c> mapTickets = new Map<String,Zendesk__Zendesk_Ticket__c>();
        
        
    }
    
    public void OnBeforeUpdate(Map<Id,Zendesk__Zendesk_Ticket__c> oldSupportTickets,Map<Id,Zendesk__Zendesk_Ticket__c> newSupportTickets)
    {
        List<String> orgIds = new List<String>();
        List<Account> accounts = new List<Account>();
        Map<String,String> accountTicketMap = new Map<String,String>();
        
        List<String> ticketEmails = new List<String>();
        List<Contact> contacts = new List<Contact>();
        Map<String,String> contactTicketMap = new Map<String,String>();
        
        for(Zendesk__Zendesk_Ticket__c ticket : newSupportTickets.values())
        {
            if(ticket.Integration_Status__c != null && oldSupportTickets.get(ticket.id).Integration_Status__c != null &&
               ticket.Integration_Status__c.equalsIgnoreCase('Solved') && 
               !(oldSupportTickets.get(ticket.id).Integration_Status__c.equalsIgnoreCase('Solved')))
            {
                if((ticket.Integration_Type__c.equalsIgnoreCase('Problem') ||
                    ticket.Integration_Type__c.equalsIgnoreCase('Incident') ||
                    ticket.Integration_Type__c.equalsIgnoreCase('Question')) ||
                   
                   (ticket.Integration_Type__c.equalsIgnoreCase('Task') && 
                    ticket.Integration_Area__c.equalsIgnoreCase('Deployment') &&
                    ticket.Integration_Sub_Area__c.equalsIgnoreCase('Project')
                   ))
                {
                    ticket.Send_Survey__c = true;
                }
            }
            else if(ticket.Integration_Status__c != null && !(ticket.Integration_Status__c.equalsIgnoreCase('Solved')))
            {
                ticket.Send_Survey__c = false;
            }
            
            if(ticket.Zendesk__Organization__c == null && ticket.Zendesk_Organization_Id__c != null)
            {
                orgIds.add(ticket.Zendesk_Organization_Id__c);
            }
            
            if(ticket.Zendesk__Requester__c == null && ticket.Integration_Requestor_Email__c != null)
            {
                if(isSandbox())
                {
                    ticketEmails.add(ticket.Integration_Requestor_Email__c+'.sandbox');
                }
                else
                {
                    ticketEmails.add(ticket.Integration_Requestor_Email__c);
                }
                
            }
        }
        
        
        
        accounts = [Select Id,Name,Zendesk__Zendesk_Organization_Id__c from Account
                    where Zendesk__Zendesk_Organization_Id__c in :orgIds];
        
        contacts = [select Id,email from Contact where email in:ticketEmails];
        
        for(Account acct : accounts)
        {
            accountTicketMap.put(acct.Zendesk__Zendesk_Organization_Id__c,acct.Id);
        }
        
        for(Contact ct : contacts)
        {
            contactTicketMap.put(ct.email,ct.Id);
        }
        
        for(Zendesk__Zendesk_Ticket__c ticket : newSupportTickets.values())
        {
            if(ticket.Zendesk__Organization__c == null && ticket.Zendesk_Organization_Id__c != null)
            {
                ticket.Zendesk__Organization__c = accountTicketMap.get(ticket.Zendesk_Organization_Id__c);
            }
            
            if(ticket.Zendesk__Requester__c == null && ticket.Integration_Requestor_Email__c != null)
            {
                if(isSandbox())
                {
                    ticket.Zendesk__Requester__c = contactTicketMap.get(ticket.Integration_Requestor_Email__c+'.sandbox');
                }
                else
                {
                    ticket.Zendesk__Requester__c = contactTicketMap.get(ticket.Integration_Requestor_Email__c);
                }
                
            }
        }
        
    }
    
    public void onAfterUpdate(Map<Id,Zendesk__Zendesk_Ticket__c> oldSupportTickets,Map<Id,Zendesk__Zendesk_Ticket__c> newSupportTickets)
    {
        List<Zendesk__Zendesk_Ticket__c> surveyTickets = new List<Zendesk__Zendesk_Ticket__c>();
        //update Ticket Info on Account
        updateZDTicketInfoAcct(newSupportTickets.values());
        createContacts(newSupportTickets.values());
        //create Surveys
        for(Zendesk__Zendesk_Ticket__c zdTicket: newSupportTickets.values())
        {
            if(zdTicket.Send_Survey__c == true && oldSupportTickets.get(zdTicket.Id).Send_Survey__c == false)
            {
                surveyTickets.add(zdTicket);

            }
        }
        //createSurveys(newSupportTickets.values());
        createSurveys(surveyTickets);
    }
    
    public void onBeforeDelete(Map<Id,Zendesk__Zendesk_Ticket__c> oldSupportTickets)
    {
        
    }
    
    public void onAfterDelete(Map<Id,Zendesk__Zendesk_Ticket__c> oldSupportTickets)
    {
        
    }
    
    public void onAfterUndelete(Map<Id,Zendesk__Zendesk_Ticket__c> newSupportTickets)
    {
        
    }
    
    public void createContacts(List<Zendesk__Zendesk_Ticket__c> zdTicketList)
    {
        Map<String,String> missedEmails = new Map<String,String>();
        Map<String,String> emailMap = new Map<String,String>();
        Map<String,String> emailNamesMap = new Map<String,String>();
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        
        for(Zendesk__Zendesk_Ticket__c ticket : zdTicketList)
        {
            if(ticket.Zendesk__Requester__c == null && ticket.Integration_Requestor_Email__c != null)
            {
                emailMap.put(ticket.Integration_Requestor_Email__c,ticket.Zendesk__Organization__c);
                emailNamesMap.put(ticket.Integration_Requestor_Email__c,ticket.Integration_Requestor_Name__c);
                missedEmails.put(ticket.Integration_Requestor_Email__c,ticket.Integration_Requestor_Email__c);
            }
        }
        
        leads = [select Id,OwnerId,Email from Lead where email in :missedEmails.values() and IsConverted = false];
        for(Lead led : leads)
        {
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(led.Id);
            lc.setOwnerId(led.OwnerId);
            //lc.ConvertedStatus = 'Converted - Additional Contact';
            lc.ConvertedStatus = 'VO';
            lc.setDoNotCreateOpportunity(true);
            lc.setAccountId(emailMap.get(led.Email));
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            missedEmails.remove(led.Email);
        }
        
        for(String data : missedEmails.values())
        {
            Contact ct = new Contact();
            ct.LastName = emailNamesMap.get(data);
            if(isSandbox())
            {
               ct.Email = data+'.sandbox';
            }
            else
            {
                ct.Email = data;
            }
            
            ct.Project_Role__c = 'Other';
            ct.LeadSource = 'External DM';
            ct.AccountId = emailMap.get(data);
            contacts.add(ct);
        }
        
        if(contacts.size() > 0)
        {
            insert contacts;
        }
        
    }
    public void updateZDTicketInfoAcct(List<Zendesk__Zendesk_Ticket__c> zdTicketList)
    {
        Set<Id> accountIdSet = new Set<Id>();
        Map<String,Zendesk__Zendesk_Ticket__c> mapTickets = new Map<String,Zendesk__Zendesk_Ticket__c>();
        
        for(Zendesk__Zendesk_Ticket__c ticket : zdTicketList)
        {
            if(ticket.Area__c != null && ticket.Area__c.equalsIgnoreCase('Deployment') && ticket.Sub_Area__c !=null &&
               (ticket.Sub_Area__c.equalsIgnoreCase('Project') || ticket.Sub_Area__c.equalsIgnoreCase('das_kick_off_call'))
               && ticket.Zendesk__Status__c != 'Solved'
               && ticket.Zendesk__Organization__c != null)
            {
                accountIdSet.add(ticket.Zendesk__Organization__c);
                mapTickets.put(ticket.Zendesk__Organization__c,ticket);
            }
            
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([select Id,Name,DAS_SKU__c,DAS_Status__c,DAS_Stage__c,
                                                          F90_Project_Status__c,Initial_Design_Plan_URL__c,
                                                          Final_Design_Plan_URL__c,Current_ZMCA_Score_Card_URL__c, DAS_Expiration_Date__c, 
                                                          of_Customer_Meetings__c, Expired_DAS_Extensions__c, DAS_Start_Date__c, 
                                                          Design_Completed_Date__c                                                        
                                                          from Account where Id in :accountIdSet]);
        
        updateAccounts(accountMap.values(), mapTickets);
    }
    
    public void updateAccounts(List<Account> accounts, Map<String,Zendesk__Zendesk_Ticket__c> mapTickets)
    {
        List<Account> accountList = new List<Account>();
        
        for(Account acct: accounts)
        {
            acct.DAS_SKU__c = mapTickets.get(acct.Id).DAS_SKU__c;
            acct.DAS_Stage__c = mapTickets.get(acct.Id).DAS_Stage__c;
            acct.DAS_Status__c = mapTickets.get(acct.Id).DAS_Status__c;
            acct.DAS_Start_Date__c = mapTickets.get(acct.Id).DAS_Start_Date__c;
            acct.F90_Project_Status__c = mapTickets.get(acct.Id).F90__c;
            acct.Initial_Design_Plan_URL__c = mapTickets.get(acct.Id).Initial_Design_Plan_URL__c;
            acct.Final_Design_Plan_URL__c = mapTickets.get(acct.Id).Final_Design_Plan_URL__c;
            acct.Current_ZMCA_Score_Card_URL__c = mapTickets.get(acct.Id).Current_ZMCA_Score_Card_URL__c;
            acct.Management_Notes__c = mapTickets.get(acct.Id).Management_Notes__c;
            acct.Pilot_Start_Date__C = mapTickets.get(acct.Id).Pilot_Start_Date__C;
            acct.Kick_Off_Call_Date__c = mapTickets.get(acct.Id).Kick_Off_Call_Date__c;
            acct.Design_Completed_Date__c = mapTickets.get(acct.Id).Design_Completed_Date__c;
            acct.Production_Start_Date__c = mapTickets.get(acct.Id).Production_Start_Date__c;
            acct.Assigned_DAS_Engr__c = mapTickets.get(acct.Id).Assigned_DAS_Engr__c;
            acct.of_Customer_Meetings__c = mapTickets.get(acct.Id).of_Customer_Meetings__c;
            acct.Expired_DAS_Extensions__c = mapTickets.get(acct.Id).Expired_DAS_Extensions__c;
            acct.DAS_Expiration_Date__c = mapTickets.get(acct.Id).DAS_Expiration_Date__c;
            accountList.add(acct);
        }
        
        if(accountList.size() > 0)
        {
            update accountList;
        }
    }
    
    public void createSurveys(List<Zendesk__Zendesk_Ticket__c> zdTicketList)
    {
        List<Case> CustomerCases = new List<Case>();
        List<Survey__c> ticketList = new List<Survey__c>();
        for(Zendesk__Zendesk_Ticket__c ticket : zdTicketList)
        {
            if(ticket.Integration_Status__c != null)
            {
                if(ticket.Send_Survey__c == true)
                {
                    ticketList.add(createSurvey(ticket));
                }
                
            }
            
            //not sure why we are not thinking about it but we should have created case when ticket is created vs solved.  
            
            /*if(ticket.Zendesk__Organization__c == null && ticket.Zendesk_Organization_Id__c != null)
            {
                Case cs = createCase('Zendesk Ticket # '+ticket.Zendesk__Ticket_ID__c+' does not associated with any salesforce account.',ticket.Id);
                CustomerCases.add(cs);
            } */
        }
        
        if(ticketList.size() > 0)
        {
            insert ticketList;
        }
        
        /*if(CustomerCases.size() > 0)
        {
            upsert CustomerCases;
        }*/
    }
    
    
    public Boolean isSandbox()
    {
        Boolean flag = true;
        
        Organization org = [Select IsSandbox,InstanceName from Organization];
        
        flag = org.IsSandbox;
        return flag;
    }
    
    /*public Case createCase(String subject,String zendeskId){
        
        List<Case> caseList = [select Id,Status,Subject,Description,Case_Category__c,Case_Sub_Category__c,OwnerId
                                    from Case where Ticket__c = :zendeskId and status != 'Closed'];
        case cas = new case();
        if(caseList.size() == 0)
        {
            cas.Status = 'New';
            cas.Subject = subject;
            cas.Description = subject;
        
            cas.Case_Category__c = 'Accounts';
            cas.Case_Sub_Category__c = 'DS Review';
        
            if(!Test.isRunningTest())
                cas.OwnerId = ZscalerSetting__c.getValues('DSReviewCaseOwnerId').Value__c;            
        }
        else
        {
            cas = caseList.get(0);
        }
        
        return cas;
    }*/
    
    public Survey__c createSurvey(Zendesk__Zendesk_Ticket__c ticket)
    {
        Survey__c ticketFeedback = new Survey__c();
        if(ticket.Integration_Type__c.equalsIgnoreCase('Problem') ||
           ticket.Integration_Type__c.equalsIgnoreCase('Incident') ||
           ticket.Integration_Type__c.equalsIgnoreCase('Question'))
        {
            ticketFeedback.RecordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='CSAT_Survey'].Id;
        }
        else
        {
            ticketFeedback.RecordTypeId = [select Id from RecordType where SobjectType ='Survey__c' and DeveloperName ='DAS_Survey'].Id;
        }
        
        ticketFeedback.Zendesk_ticket__c = ticket.Id;
        if(ticket.Zendesk__Organization__c != null)
        {
            ticketFeedback.Account__c = ticket.Zendesk__Organization__c;
        }
        if(ticket.Zendesk__Requester__c != null)
        {
            ticketFeedback.Contact__c = ticket.Zendesk__Requester__c;
        }
        ticketFeedback.Zendesk_Area__c = ticket.Integration_Area__c;
        ticketFeedback.Zendesk_Sub_Area__c = ticket.Integration_Sub_Area__c;
        if(isSandbox())
        {
            ticketFeedback.Contact_Email__c = Label.surveySandboxEmail;
        }
        else
        {
            ticketFeedback.Contact_Email__c = ticket.Integration_Requestor_Email__c; 
        }
        
        ticketFeedback.Contact_Name__c = ticket.Integration_Requestor_Name__c;
        ticketFeedback.Ticket_Assignee__c = ticket.Integration_Ticket_Assignee__c;
        ticketFeedback.Type__c = ticket.Integration_Type__c;
        ticketFeedback.Ticket_Status__c = ticket.Integration_Status__c;
        ticketFeedback.Assignee_Manager__c = ticket.Integration_Assignee_Manager__c;
        return ticketFeedback;
    }
    
}