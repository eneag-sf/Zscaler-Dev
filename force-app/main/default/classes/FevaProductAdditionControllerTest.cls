/*****************************************************************************************
Name: FevaProductAdditionControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for FevaProductAdditionController class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            22-Aug-2016    Initial Development
******************************************************************************************/ 

@isTest(seeAllData = true)
public class FevaProductAdditionControllerTest{
    @isTest static void test(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        test.starttest();
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1', 
                                                                                      Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),
                                                                                      RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(), 
                                                                                      Apttus_Proposal__Approval_Stage__c = 'Draft',
                                                                                      Apttus_QPConfig__BillToAccountId__c = acc.Id,
                                                                                      Apttus_Proposal__ExpectedStartDate__c = Date.today(),
                                                                                      Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(365),
                                                                                      Apttus_Proposal__Primary__c = true,
                                                                                     
                                                                                      Apttus_Proposal__Valid_Until_Date__c = Date.today()
                                                                                      );
        testProposal1.Apttus_Proposal__Opportunity__c = opp.Id;
        testProposal1.Apttus_QPConfig__BillToAccountId__c = acc.Id;
        testProposal1.Apttus_Proposal__Account__c = acc.Id;
        testProposal1.Apttus_QPConfig__ShipToAccountId__c = acc.Id;
        insert testProposal1;
                
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
        }catch(Exception ex){
        
        }
        
        PageReference pageRef = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
        Test.setCurrentPage(pageRef);
        try{
        FevaProductAdditionController controller = new FevaProductAdditionController();
        controller.addProduct();
        controller.removeProduct();
        controller.saveProduct();
        PageReference pageRef1 = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
        Test.setCurrentPage(pageRef1);
        FevaProductAdditionController controller1 = new FevaProductAdditionController();
        
        controller1.productId = controller1.addedProductList[0].Id;
        controller1.removeProduct();
        controller1.productId = controller1.allProductList[0].Id;
        controller1.addProduct();
        controller1.saveProduct();
        }catch(Exception ex){}
        test.stoptest();
        
    }
}