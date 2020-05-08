@isTest
private class oppTechPartnerValidationTest {

	@isTest static void testBooster(){
	    oppTechPartnerValidationHelper.booster();
	}
	
	@isTest static void test(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        TriggerUtility.realignPatchReset();
        insert opp;

        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
		try{
        insert pr;
		}catch(Exception ex){}

        opp.StageName = Label.Stage_7_Closed_Lost;
        opp.Primary_Reason_For_Loss__c = 'test';
        opp.isChurnpresent__c = false;
        opp.Sub_Stage__c = Label.SubStage_Closed_Lost;
        opp.Validation_Stage__c = ZScalarConstants.Opp_Validation_Stage_7_Technical_Loss;
        update opp;


        Id erRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = 'Approved';
        er.RecordTypeId = erRecordTypeId;
        er.Opportunity__c = opp.Id;
        //er.OwnerId = userinfo.getUserId();
        er.Localized_content__c = true;
        insert er;

        opp.StageName = Label.Stage_6_Closed_Won;
        opp.Sub_Stage__c = Label.SubStage_Closed_Lost;
        opp.isChurnpresent__c = false;
        update opp;



        test.stoptest();
    }

}