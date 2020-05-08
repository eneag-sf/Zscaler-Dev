@isTest
public class getOppLossReasonController_Test {
    @TestSetup static void setuprecs(){
        TriggerUtility.prospectTypeUpdExecuted();
        Account acc = APTS_TestUtil.creatAccount();
        Id RecordTypeIdContact = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(RecordTypeId=RecordTypeIdContact,Name = 'test opp', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today());
        insert opp;

        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =opp.Id);
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =opp.Id);
        insert churnLoss;
    }
    
    static testmethod void testResonctrl(){
        test.startTest();
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id from Opportunity];
        Churn__c churn = [Select Id,Type__c from Churn__c Where Type__c='Loss' Limit 1];
        ApexPages.currentPage().getParameters().put('oppId',opp[0].id);
        Apexpages.StandardController sc = new Apexpages.StandardController(churn);
        getOppLossReasonController ctrl = new getOppLossReasonController(sc);
        list<SelectOption> piclList = getOppLossReasonController.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        test.stopTest();
    }
    static testmethod void testResonEditctrl(){
        test.startTest();
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id from Opportunity];
        Churn__c churn = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Loss' Limit 1];
        ApexPages.currentPage().getParameters().put('oppId',opp[0].id);
        ApexPages.currentPage().getParameters().put('Id',churn.id);
        Apexpages.StandardController sc = new Apexpages.StandardController(churn);
        getOppLossReasonController ctrl = new getOppLossReasonController(sc);
        list<SelectOption> piclList = getOppLossReasonController.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        getOppLossReasonController.saveResponse churnRes = getOppLossReasonController.saveForm(opp[0].id,churn.id,'Not planning on local breakouts','Not moving apps to the cloud','Quality - Support','Quality - Lingering Issues','Quality - Support','Quality - Lingering Issues','No internal champion','Low Executive Meetings','M&A - company acquired/merged','Zscaler Product EOL','Price','Lost Budget','Test','Other','Akamai (ETP)','Bitglass','additionalNotes',churn.SCINumber__c,'11- Closed Lost', true, true);
        getOppLossReasonController.getChuran(churn.Id);
        getOppLossReasonController.saveResponse churnRes1 = getOppLossReasonController.saveForm(opp[0].id,churn.id,'Not planning on local breakouts','Please select','Quality - Support','Please select','Quality - Support','Please select','No internal champion','Please select','M&A - company acquired/merged','Please select','Price','Please select','Test','Please select','Akamai (ETP)','Please select','additionalNotes', null ,'11- Closed Lost', false, false);

        test.stopTest();
        //Util_ChurnReasonMethods.getOpportunityRecordType(opp[0].Id);
        //Util_ChurnReasonMethods.getOpp(opp[0].Id);
        //Util_ChurnReasonMethods.getProducts(opp[0].Id);
        //Util_ChurnReasonMethods.ResultSet obj;
        /*if(opp[0].id != null){
            obj.Id  = opp[0].id;
            obj.Name  = 'Test';
            obj.Description  = 'Test';
            obj.sObjectName  = 'Opportunity';
        }*/
        //Util_ChurnReasonMethods.ResultSet obj1 = new Util_ChurnReasonMethods.ResultSet(obj.Id,obj.Name,obj.Description);
    }

}