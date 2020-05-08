@isTest
private class OppLossChurnReasonCntrlTest {

	@TestSetup static void SetUpRecs(){
	    Account acc = new Account(Name = 'Test Account',APTS_Platform_Subscription_End_Date__c = Date.today());
	    insert acc;
	    
	    Id RecordTypeIdContact = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
	    
	    Apttus_Config2__PriceList__c  Pricelist = new Apttus_Config2__PriceList__c(Apttus_Config2__AccountId__c = acc.id );
        insert Pricelist;
        
	    Opportunity Opp = new Opportunity(RecordTypeId=RecordTypeIdContact,Name = 'test opp', AccountId = acc.Id, Amount = 100.00, StageName = label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today(),Confirm_Opportunity_Closure__c = true);
        insert Opp;
        
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=Opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =Opp.Id,Lost_Analysis_Call__c = 'Call Conducted');
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =Opp.Id);
        insert churnLoss;
        
        Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.Id,Additional_Organization_domains__c = 'Test',Preferred_Cloud__c = 'Zscaler.net',Send_Initial_l__c = 'ATT Usell',Provisioning_Status__c = 'Requested',Opportunity__c = Opp.Id);
        //insert Pr;
        
        Product2 prod = new Product2(ProductCode = '12345', isBundle__c = true, IsActive = true, Name = 'test Product');
        insert prod;
        
        Apttus_Config2__PriceListItem__c Cpl = new Apttus_Config2__PriceListItem__c(Apttus_Config2__ProductId__c = prod.id, Apttus_Config2__PriceListId__c = Pricelist.id );
        insert cpl;
	}
	
	static testmethod void TestGetChurn(){
	    Test.startTest();
	    Opportunity Opp = [Select Id,StageName,Amount from Opportunity Limit 1];
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c Where Type__c='Loss' Limit 1];
	    //Provisioning_Request__c PR = [select Id,Additional_Organization_domains__c,Preferred_Cloud__c,Send_Initial_l__c,Provisioning_Status__c,Opportunity__c from Provisioning_Request__c Limit 1];
	    OppLossChurnReasonCntrl OppLossChurnReasonClassRef = new OppLossChurnReasonCntrl();
	    OppLossChurnReasonCntrl.getInitData(Opp.Id);
	    OppLossChurnReasonCntrl.getPickListData(Opp.id);
	    OppLossChurnReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,true, true, true, true, true,churn);
	    OppLossChurnReasonCntrl.getChuran(churn.Id);
	    OppLossChurnReasonCntrl.isActivePRpresentOnOpp(Opp.Id);
	    OppLossChurnReasonCntrl.getSCIWraprecords(Opp.Id);
	    OppLossChurnReasonCntrl.getSCIrecords(Opp.Id);
	    Test.stopTest();
	}

}