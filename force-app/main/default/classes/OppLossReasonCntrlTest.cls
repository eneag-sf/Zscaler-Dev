@isTest
private class OppLossReasonCntrlTest {

	@TestSetup static void SetUpRecs(){
	    Account acc = new Account(Name = 'Test Account',APTS_Platform_Subscription_End_Date__c = Date.today());
	    insert acc;
	    Id RecordTypeIdContact = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
	    Opportunity Opp = new Opportunity(RecordTypeId=RecordTypeIdContact,Name = 'test opp', AccountId = acc.Id,Amount = 100.00, StageName = label.Stage_1_Alignment/*'Qualified'*/, CloseDate = Date.Today());
        insert Opp;
        
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=Opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =Opp.Id,Lost_Analysis_Call__c = 'Call Conducted');
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =Opp.Id);
        insert churnLoss;
        
        Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.Id,Additional_Organization_domains__c = 'Test',Preferred_Cloud__c = 'Zscaler.net',Send_Initial_l__c = 'ATT Usell',Provisioning_Status__c = 'Requested',Opportunity__c = Opp.Id);
        //insert Pr;
	}
	
	static testmethod void TestGetChuran(){ 
	    Test.startTest();
	    Opportunity Opp = [Select Id,StageName from Opportunity Limit 1];
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c Where Type__c='Loss' Limit 1];
	    //Provisioning_Request__c PR = [select Id,Additional_Organization_domains__c,Preferred_Cloud__c,Send_Initial_l__c,Provisioning_Status__c,Opportunity__c from Provisioning_Request__c Limit 1];
	    OppLossReasonCntrl OppLossReasonClass = new OppLossReasonCntrl();
	    OppLossReasonCntrl.getInitData(Opp.Id);
	    OppLossReasonCntrl.getPickListData();
	    OppLossReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,Opp.StageName,True,churn);
	    OppLossReasonCntrl.getChuran(churn.Id);
	    OppLossReasonCntrl.isActivePRpresentOnOpp(Opp.Id);
	    OppLossReasonCntrl.getSCIWraprecords(Opp.Id);
	    OppLossReasonCntrl.getSCIrecords(Opp.Id);
	    Test.stopTest();
	}

}