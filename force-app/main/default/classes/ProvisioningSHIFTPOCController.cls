public class ProvisioningSHIFTPOCController
{
    private String provisioningRequestId = ApexPages.currentPage().getParameters().get('id');
    private Provisioning_Request__c thisProvisioningRequest = null;
    private String userEmail = '';
    private String password = '';
    private String orgId = '';
    private String contactName = '';
    private String domain = '';
    private String ErrorPrefix = 'Error from the SHIFT Cloud: ';
    private List<MessageInfo> messages= new List<MessageInfo>();
    
    public ProvisioningSHIFTPOCController()
    {
        Step = 0;
    }
    
    public Integer Step { get; set; }
    
    public PageReference createCompany()
    {
        List<Provisioning_Request__c> existingDomainProvis = [select Id from Provisioning_Request__c where Organization_Domain__c = :thisProvisioningRequest.Organization_Domain__c and Org_ID_with_cloud__c != null and Id != :thisProvisioningRequest.Id AND RecordType.DeveloperName =: 'SHIFT_Evaluation' limit 1];
        if(existingDomainProvis.size() > 0)
        {
            messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'The record with same domain already exist. Click <a href="/'+existingDomainProvis[0].Id+'">here</a> to review.'));
            Step = 0;
        }
        else
        {   
            string compName = '';
            if(thisProvisioningRequest.Opportunity__r.Account.Name != null){
                compName = thisProvisioningRequest.Opportunity__r.Account.Name;
            }else if(thisProvisioningRequest.Account__r.Name != null){
                compName = thisProvisioningRequest.Account__r.Name;
            }
            HttpResponse httpresponse = ProvisioningSHIFTPOCHelper.createCompany(thisProvisioningRequest.Organization_Domain__c, compName);
            if(httpresponse != null)
            {
                Integer statusCode = httpresponse.getStatusCode();
                String responseBody = httpresponse.getBody().replace('[', '').replace(']','');

                Map<String,String> responseMap = (Map<String,String>)JSON.deSerialize(responseBody,Map<String,String>.class);
                if(statusCode != null && statusCode == 201)
                {
                    String customerId =  responseMap.get('customerId');
                    thisProvisioningRequest.Provisioning_Status__c = 'Requested';
                    thisProvisioningRequest.Org_ID_with_cloud__c = customerId;
                    thisProvisioningRequest.FailedReason__c = null;                                   
                    messages.add(new MessageInfo(ApexPages.Severity.Info, 'Company profile has been created. Trying to create user...'));
                    Step = 2;
                }
                else
                {
                    String errorReason =  responseMap.get('reason'); 
                    thisProvisioningRequest.Provisioning_Status__c = 'Failed';
                    thisProvisioningRequest.FailedReason__c = ErrorPrefix + errorReason;                
                    messages.add(new MessageInfo(ApexPages.Severity.ERROR, errorReason));
                    Step = 0;
                }
                update thisProvisioningRequest; 
            }
            else
            {
                step = 0;
            }
        }
        showMessages();
        return null;
    }
    
    public PageReference createUser()
    {
        generateUserInfo();
        HttpResponse httpresponse = ProvisioningSHIFTPOCHelper.createUser(orgId, domain, contactName, userEmail, password);
        if(httpresponse != null)
        {
            Integer statusCode = httpresponse.getStatusCode();
            String responseBody = httpresponse.getBody().replace('[', '').replace(']','');
            Map<String,String> responseMap =   (Map<String,String>)JSON.deSerialize(responseBody,Map<String,String>.class);
            if(statusCode != null && statusCode == 201)
            {
                thisProvisioningRequest.Provisioning_Status__c = 'Provisioned';
                thisProvisioningRequest.FailedReason__c = null; 
                thisProvisioningRequest.Provisioning_Date__c = Date.today();
                String userId =  responseMap.get('id');                 
                messages.add(new MessageInfo(ApexPages.Severity.Info, 'User has been created. Sending email notification...'));
                Step = 3;
            }
            else
            {
                String errorReason = responseMap.get('reason');  
                thisProvisioningRequest.Provisioning_Status__c = 'Failed';
                thisProvisioningRequest.FailedReason__c = ErrorPrefix + errorReason;                  
                messages.add(new MessageInfo(ApexPages.Severity.ERROR, errorReason));
                Step = 0;
            }
            update thisProvisioningRequest;
        }
        else
        {
            Step = 0;
        }
        showMessages();
        return null;
    }
    
    public PageReference sendUserEmailNotification()
    {
        List<EmailTemplate> tems = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = 'Shift_Provisioning_Welcome_Email' limit 1];
        if(tems.size() > 0)
        {
            String emailBody = String.isBlank(tems[0].HtmlValue) ? '' : tems[0].HtmlValue;
            String emailSubject = tems[0].Subject;
            emailBody = emailBody.replace('{!name}', contactName).replace('{!username}', 'admin@' + domain).replace('{!password}', password);
            String textBody = String.isBlank(tems[0].Body) ? '' : tems[0].Body;
            textBody = textBody.replace('{!name}', contactName).replace('{!username}', 'admin@' + domain).replace('{!password}', password);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //Set list of people who should get the email
            List<String> sendTo = new List<String>();
            Task actHistory = new Task(Subject='Email: ' + emailSubject, WhatId=thisProvisioningRequest.Id, Status='Completed', ActivityDate=Date.today(), Description=textBody);
            actHistory.WhoId = null;
            for(string str : thisProvisioningRequest.Send_Initial_l__c.split(';')){
                if(str == 'Customer'){
                    sendTo.add(thisProvisioningRequest.Primary_Eval_Contact__r.Email);
                }else if(str == 'Partner'){
                    sendTo.add(thisProvisioningRequest.Partner_Contact__r.Email);
                }else if(str == 'SE'){
                    sendTo.add(thisProvisioningRequest.SE__r.Email);
                }
            }
            /*
            if(thisProvisioningRequest.Send_Initial_l__c == 'Customer')
            {
                sendTo.add(userEmail);
                actHistory.WhoId = thisProvisioningRequest.Primary_Eval_Contact__c;
            }
            else if(thisProvisioningRequest.Send_Initial_l__c == 'Partner')
            {
                sendTo.add(thisProvisioningRequest.Partner_Contact__r.Email);
                actHistory.WhoId = thisProvisioningRequest.Partner_Contact__c;
            }
            else if(thisProvisioningRequest.Send_Initial_l__c == 'SE')
            {
                sendTo.add(thisProvisioningRequest.SE__r.Email);
                actHistory.WhoId = null;
            }
            */
            mail.setToAddresses(sendTo);
            mail.setReplyTo('CustomerSuccess@zscaler.com');
            mail.setSenderDisplayName('zscaler');
            mail.setSubject(emailSubject);
            mail.setHtmlBody(emailBody);
            mail.setPlainTextBody(textBody);
            mails.add(mail);
            try
            {
                Messaging.sendEmail(mails);
                insert actHistory;
                messages.add(new MessageInfo(ApexPages.Severity.INFO, 'Email notification has been sent out to ' + thisProvisioningRequest.Send_Initial_l__c));
                Step = 4;
            }
            catch(Exception ex)
            {
                messages.add(new MessageInfo(ApexPages.Severity.Error, 'Failed to send notification email. ' + ex.getMessage()));
                step = 0;
            }
        }
        else
        {
            messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Email template is not found. Email notification aborted.'));
            Step = 0;
        }
        showMessages();
        return null;
    }
    
    public PageReference goback()
    {
        PageReference ref = new PageReference('/' + provisioningRequestId);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference initProvisionRequest()
    {
        Boolean validated = true;
        if(provisioningRequestId != null && provisioningRequestId instanceOf ID)
        {
            
            List<Provisioning_Request__c> provisioningRequests = [select Id, FailedReason__c, Account__c, Account__r.Name, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Id =:provisioningRequestId]; 
            //List<Provisioning_Request__c> provisioningRequests = [select Id, FailedReason__c, Account__c, Account__r.Name, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name,  RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Id =:provisioningRequestId]; 
            if(provisioningRequests.size() > 0)
            {
                thisProvisioningRequest = provisioningRequests[0];
                if(thisProvisioningRequest.Organization_Domain__c == null)
                {
                    validated = false;
                    messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Please specify domain name.'));
                }
                if(thisProvisioningRequest.Org_ID_with_cloud__c != null && thisProvisioningRequest.Provisioning_Status__c == 'Provisioned')
                {
                    validated = false;
                    messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'This provisioning request has been setup.'));
                }
                /*
                if(thisProvisioningRequest.Send_Initial_l__c == null)
                {
                    validated = false;
                    messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Please specify who is going to receive the login credential.'));
                }
                if(thisProvisioningRequest.Opportunity__r.Account.Name == null && thisProvisioningRequest.Account__r.Name == null)
                {
                   validated = false;
                   messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Customer Name is empty.'));
                }
                if(thisProvisioningRequest.Send_Initial_l__c == 'SE' && thisProvisioningRequest.SE__r.Email == null)
                {
                   validated = false;
                   messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Please specify the SE user'));
                }
                if(thisProvisioningRequest.Send_Initial_l__c == 'Partner' && thisProvisioningRequest.Partner_Contact__r.Email == null)
                {
                   validated = false;
                   messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'The request must have a partner contact.'));
                }
                if(thisProvisioningRequest.Send_Initial_l__c == 'Customer' && thisProvisioningRequest.Primary_Eval_Contact__r.Email == null)
                {
                   validated = false;
                   messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'The request must have a primary contact.'));
                }
                */
                if(thisProvisioningRequest.RecordType.DeveloperName != 'SHIFT_Evaluation')
                {
                   validated = false;
                   messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Only "SHIFT Evaluation" request can be setup.'));
                }
            }
            else
            {
                validated = false;
                messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Provisioning request cannot be found.'));
            }
        }
        else
        {
            validated = false;
            messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Provisioning request cannot be found.'));
        }
        if(validated)
        {
            if(thisProvisioningRequest.Org_ID_with_cloud__c != null && (thisProvisioningRequest.Provisioning_Status__c == 'Requested' || thisProvisioningRequest.Provisioning_Status__c == 'Failed'))
            {
                Step = 2;
            }
            else
            {
                Step = 1;
            }
            messages.add(new MessageInfo(ApexPages.Severity.Info, 'Trying to create company profile...'));
        }
        showMessages();
        return null;
    }

    private void generateUserInfo()
    {
        List<Provisioning_Request__c> requests = [select Id, Send_Initial_l__c, Primary_Eval_Contact__c, Primary_Eval_Contact__r.Name, Primary_Eval_Contact__r.Email, Partner_Contact__c, Partner_Contact__r.Email, Partner_Contact__r.Name, SE__c, SE__r.Email, SE__r.Name, Org_ID_with_cloud__c, Organization_Domain__c from Provisioning_Request__c where Id =:provisioningRequestId limit 1];
        //List<Provisioning_Request__c> requests = [select Id,  Primary_Eval_Contact__c, Primary_Eval_Contact__r.Name, Primary_Eval_Contact__r.Email, Partner_Contact__c, Partner_Contact__r.Email, Partner_Contact__r.Name, SE__c, SE__r.Email, SE__r.Name, Org_ID_with_cloud__c, Organization_Domain__c from Provisioning_Request__c where Id =:provisioningRequestId limit 1];
        if(requests.size() > 0)
        {
            orgId = requests[0].Org_ID_with_cloud__c;
            /*
            if(requests[0].Send_Initial_l__c == 'SE')
            {
                contactName = requests[0].SE__R.Name;
                userEmail = requests[0].SE__R.Email;
            }
            else if(requests[0].Send_Initial_l__c == 'Partner')
            {
                contactName = requests[0].Partner_Contact__r.Name;
                userEmail = requests[0].Partner_Contact__r.Email;
            }
            else
            {
                contactName = requests[0].Primary_Eval_Contact__r.Name;
                userEmail = requests[0].Primary_Eval_Contact__r.Email;
            }
            */
            if(requests[0].Primary_Eval_Contact__c != null){
                contactName = requests[0].Primary_Eval_Contact__r.Name;
                userEmail = requests[0].Primary_Eval_Contact__r.Email;
            }
            password = generateRandomString(10)+'$';
            domain = requests[0].Organization_Domain__c;
        }
        else
        {
            messages.add(new MessageInfo(ApexPages.Severity.ERROR, 'Failed to create user.'));
        }
    }
    
    private String generateRandomString(Integer len)
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) 
        {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    private void showMessages()
    {
        for(MessageInfo msg : messages)
        {
            ApexPages.addMessage(new ApexPages.Message(msg.svr, msg.message));
        }
    }
    
    public class MessageInfo
    {
        public ApexPages.Severity svr;
        public String message;
        
        public MessageInfo(ApexPages.Severity svr, String message)
        {
            this.svr = svr;
            this.message = message;
        }
    }
}