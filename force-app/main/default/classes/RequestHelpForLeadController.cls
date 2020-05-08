/*****************************************************************************************
Name: RequestHelpForLeadController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Controller class for RequestHelpForLead VF page .
    
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            27-Sept-2017    Initial Development
******************************************************************************************/ 
public class RequestHelpForLeadController {
    public string subject {get; set;}
    public string description {get; set;}
    public Case newCase {get; set;}
    public string leadId {get; set;}
    public boolean hasSaved {get; set;}
    public RequestHelpForLeadController(){
        hasSaved = false;
        newCase = new Case();
        subject = '';
        description = '';
        leadId = '';
        leadId = ApexPages.currentPage().getParameters().get('id');
    }

    public void Save(){
        string salesOperationQueueId = '';
        salesOperationQueueId = ZscalerSetting__c.getValues('SalesOperationQueueId').Value__c;
        newCase.Case_Category__c = 'Leads / Contacts';
        newCase.Case_Sub_Category__c = 'Data Updates';
        newCase.Lead__c = leadId;
        newCase.User__c = userInfo.getUserId();
        newCase.Priority = '4 - Low';
        newCase.RecordTypeId = Label.CaseRT_SalesOperation;
        if(salesOperationQueueId != '' && salesOperationQueueId != null)
            newCase.OwnerId = salesOperationQueueId;
        insert newCase;
        hasSaved = true;
        PageReference leadDetailPage = new PageReference('/' + leadId);
        //return leadDetailPage;    
    }

    public void Cancel(){
        PageReference leadDetailPage = new PageReference('/' + leadId);
        //return leadDetailPage;    
    }
    
}