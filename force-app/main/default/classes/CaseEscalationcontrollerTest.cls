@isTest(Seealldata=false)
public class CaseEscalationcontrollerTest{
    @isTest static void test(){
        test.starttest();
      
            Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
            insert acc;
            
            Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
            
            Insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
            TriggerUtility.SkipCaseTriggerExecuted();
            insert cs;
            //List<Case> Caselist = [select Id, RecordTypeId, RecordType.DeveloperName from Case limit 1]; 
     
                
            //PageReference ref = new PageReference('/apex/PRStopPurgePage?id=' +Pr.Id);
            //Test.setCurrentPage(ref);
            //ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
            //Pagereference pgref=con.SubmitforStopPurge();
            //
            
            PageReference myVfPage = Page.CaseEscalationPage;
            Test.setCurrentPageReference(myVfPage);
            ApexPages.StandardController sc = new ApexPages.StandardController(cs);   
            CaseEscalationcontroller pc= new CaseEscalationcontroller(sc);
            pc.SubmitforCaseEscalation();
            Pagereference pgref=pc.cancelCaseEscalationPopup();
            
            List<SelectOption> SOlist= new List<SelectOption>();
            SOlist=pc.getDefconlevels();
            pc.ChangeDefcon();
           // pc.booster();
    
            
        test.stoptest();
    }
}