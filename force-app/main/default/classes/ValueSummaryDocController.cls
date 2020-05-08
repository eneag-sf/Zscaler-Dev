public without sharing class ValueSummaryDocController {

    public string proposalId{get;set;}
    public string accountId{get;set;}
    public string renderAs{get;set;}
    public string attachId{get;set;}
    
    public ValueSummaryDocController(){}
    
    public PageReference initquote(){
          
        accountId = apexpages.currentpage().getparameters().get('id');
        List<Account> acc = [Select Id, name, Value_Summary_Format__c from Account where Id = :accountId];
        renderAs = !acc.isEmpty() && acc[0].Value_Summary_Format__c != null ? acc[0].Value_Summary_Format__c : 'pdf';
        /*List<Apttus_Proposal__Proposal__c> prop = [select id,Apttus_QPConfig__PriceListId__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Primary__c,Apttus_QPConfig__BillToAccountId__c,Apttus_Proposal__Opportunity__r.AccountId,Apttus_Proposal__Account__c, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c  where Apttus_Proposal__Approval_Stage__c != 'Approval Required' and Apttus_Proposal__Account__c=:accountId and Apttus_Proposal__Primary__c = false];
        if(!prop.isEmpty()){
            proposalId = prop[0].Id;
            oldstage = prop[0].Apttus_Proposal__Approval_Stage__c;
        }*/
        /*List<Opportunity> opportunity = [Select Id from Opportunity where AccountId = :accountId and Recordtype.name = 'Renewal Opportunity' limit 1];
        if(!opportunity.isEmpty()){
            opptyId = opportunity[0].Id;
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Renewal Opportunity on this Account');
            ApexPages.addMessage(myMsg);
            return null;
        }*/
        
        /*Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = acc[0].Name, Apttus_Proposal__Account__c = accountId, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId, Apttus_Proposal__Opportunity__c = opptyId, Apttus_Proposal__Primary__c = false);
        insert proposal;
        proposalId = proposal.Id;
        return null;*/
        
        List<Apttus_Proposal__Proposal__c > prop = [Select Id, Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c where Id = :Label.DummyQuote_ValueSummary];
        if(!prop.isEmpty() || test.isRunningTest()){
            try{
                prop[0].Apttus_Proposal__Account__c = accountId;
                prop[0].Apttus_Proposal__Proposal_Name__c = acc[0].Name;
                update prop;
                proposalId = prop[0].Id;
            }catch(Exception ex){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Update Error on Value Summary Quote. Please reach out to SFDC support team.');
                ApexPages.addMessage(myMsg);
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Value Summary Quote is missing. Please reach out to SFDC support team.');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    @RemoteAction
    public static String generateDoc(String proposalaccId){
        
        List<String> propIdstg = proposalaccId != '' ? proposalaccId.split('---') : new List<String>();
        String userIdfortask, format, acctId , proposalId = acctId = format = userIdfortask = '';
        if(!propIdstg.isEmpty()){
            proposalId = propIdstg[0];
            acctId = propIdstg[1];
            format = propIdstg[2] != null && propIdstg[2] != '' ? propIdstg[2].toLowerCase() : 'pdf';
            userIdfortask = propIdstg[3] != null && propIdstg[3] != '' ? propIdstg[3] : UserInfo.getUserId();
        }
        
        Value_Summary_Key_Secret__c csck = Value_Summary_Key_Secret__c.getValues('Value_Summary');
        String password = '{!$Credential.Password}';
        String clientId = csck != null ? csck.Consumer_Key__c : '';
        String clientSecret = csck != null ? csck.Consumer_Secret__c : '';
        String username = '{!$Credential.UserName}';
        String URLtohit = 'callout:ValueSummaryAdminCred';
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
        HttpResponse res;
        List<NamedCredential> lstnamedcred = [SELECT DeveloperName,Id FROM NamedCredential where DeveloperName = 'ValueSummaryAdminCred'];
        if(!lstnamedcred.isEmpty()){
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setMethod('POST');
            req.setEndpoint(URLtohit+'/services/oauth2/token');
            req.setBody(reqbody);
            
            if(!test.isrunningtest()){
                res = h.send(req);
            }
        }
        
        List<Apttus__APTS_Template__c> temp = [Select Id from Apttus__APTS_Template__c where Name = 'Value Summary'];
        String templateId = '';
        String msg = '';
        if(!temp.isEmpty()){
            templateId = temp[0].Id;
        }
        String accessLevel = 'Read Only';
        String docFormat = format;
        string sessionId = res != null && res.getBody() != null && res.getStatusCode() == 200? (String)((Map<String,Object>)JSON.deserializeUntyped(res.getBody())).get('access_token') : UserInfo.getSessionID();

        String apiServerURL  = Apttus_Config2__ConfigSystemProperties__c.getAll().get('System Properties').Apttus_Config2__InstanceUrl__c + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        boolean isDraft = false;
        String generatedDocId = '';
        if(!test.isrunningTest() && sessionId != ''){
            generatedDocId = Apttus_Proposal.MergeWebService.generateDoc2(templateId
                                                                          , proposalId
                                                                          , accessLevel
                                                                          , docFormat
                                                                          , isDraft
                                                                          , sessionId
                                                                          , apiServerURL);
        }
        if((generatedDocId != '' && generatedDocId != null && generatedDocId.substring(0,3) == '00P') || test.isRunningTest()){
            try{
                msg =  generatedDocId;
                Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c(Id = proposalId);
                prop.Apttus_Proposal__Proposal_Name__c = 'Dummy Proposal for Value Summary - DO NOT DELETE';
                prop.Apttus_Proposal__Account__c = Label.CorpZu_ValueSummary;
                update prop;
                //Task actHistory = new Task(Subject='Generated Value Summary Document', WhatId=Id.valueOf(acctId), Status='Completed', ActivityDate=Date.today(), Description='Generated Value Summary Document', OwnerId = Id.valueOf(userIdfortask) ,Priority='Normal', type='Other');
                //actHistory.WhoId = null;
                //insert actHistory;
            }catch(Exception ex){
                return 'Error on Doc Generation: ' + ex;
            }
        }else{
            msg = 'Error: Failure Occured. Please reach out to SFDC support team';
        }
        return msg;
    }
    
    /*@RemoteAction
    public static String updateProposal(String proposalIdstage){
        List<String> propIdstg = proposalIdstage != '' ? proposalIdstage.split('---') : new List<String>();
        String oldstage , proposalId = oldstage = '';
        if(!propIdstg.isEmpty()){
            proposalId = propIdstg[0];
            oldstage = propIdstg[1];
        }
        List<Apttus_Proposal__Proposal__c> prop = [select id, Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c  where Id=:proposalId];
        if(!prop.isEmpty() && prop[0].Apttus_Proposal__Approval_Stage__c != oldstage){
            Apttus_Proposal__Proposal__c proprec = new Apttus_Proposal__Proposal__c(Id=proposalId, Apttus_Proposal__Approval_Stage__c = oldstage);
            try{
                update proprec;
                return  'Success: Document has been Generated... Redirecting...';
            }catch(Exception ex){
                return 'Error in Updating Quote: ' + ex ;
            }
        }
        
        return  'Success: Document has been Generated... Redirecting...';
        
    }*/
    
    public Pagereference redirectToURL() {
        System.debug('***'+ attachId);
        String accountId = apexpages.currentpage().getparameters().get('id') != null ? apexpages.currentpage().getparameters().get('id'): '';
        if(attachId != null){
            try{
                //Attachment tempAtt = new Attachment(Id = attachId);
                //delete tempAtt;
                if(accountId != ''){
                    Task actHistory = new Task(Subject='Generated Value Summary Document', WhatId=accountId, Status='Completed', ActivityDate=Date.today(), Description='Generated Value Summary Document', OwnerId = UserInfo.getUserId() ,Priority='Normal', type='Other');
                    actHistory.WhoId = null;
                    insert actHistory;
                }
            }catch(Exception ex){
                System.debug('++++'+ ex);
            }
            String url = '/servlet/servlet.FileDownload?file='+attachId;
            return new Pagereference('/'+url);
        }
        String url = apexpages.currentpage().getparameters().get('id') != null ? apexpages.currentpage().getparameters().get('id'): '';
        return new Pagereference('/'+url);
    }
    
}