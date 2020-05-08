/*****************************************************************************************
Name: ApprovalItemsControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for ApprovalItemsController.
    
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            5-May-2017    Initial Development
******************************************************************************************/ 


@isTest
private class ApprovalItemsControllerTest {
    public static Account acc;
    public static Account acc1;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    
    @isTest static void testApprovalItemsController() {
        
            TriggerUtility.prospectTypeUpdExecuted();
            acc = APTS_TestUtil.creatAccount();
            acc1 = APTS_TestUtil.creatAccount();
            
            pricelist = new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
            insert Pricelist;
            Pricebook2 Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
            insert Pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            
            Apttus_Config2__ConfigSystemProperties__c config=new Apttus_Config2__ConfigSystemProperties__c(Name='System Properties',Apttus_Config2__InstanceUrl__c=URL.getSalesforceBaseUrl().toExternalForm() + '/');
            insert config;
            
            opp = APTS_TestUtil.createOpportunity (acc.Id,pricelist.Id);
            
            prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);
            Test.startTest();
            Apttus_Approval__Approval_Request__c appReq = new Apttus_Approval__Approval_Request__c();
            appReq.Apttus_Approval__Approval_Status__c = 'Assigned';
            appReq.Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId();
            appReq.Apttus_QPApprov__ProposalId__c = prop.Id;
            insert appReq;
            PageReference pageRef = new PageReference('/apex/ApprovalItems');
            Test.setCurrentPage(pageRef);
            ApprovalItemsController controller = new ApprovalItemsController();
            controller.sortField = 'Apttus_QPApprov__ProposalId__c';
            controller.doSorting();
            controller.doSorting();
            controller.refereshAppReq();
        Test.stopTest();
    }
    
    @isTest static void testApprovalItemsController1() {
        Test.startTest();
        TriggerUtility.prospectTypeUpdReset();
        TriggerUtility.AutocreateZCloudIDcontactUpdateExecuted();
        TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
        TriggerUtility.AutocreateZCloudIDcontactUpdatesetfalse();
        TriggerUtility.ZCloudIDcontactDeletetriggerExecuted();
        TriggerUtility.ZCloudIDcontactDeletetriggersettrue();
        TriggerUtility.ZCloudIDcontactDeletetriggersetfalse();
        TriggerUtility.ZCloudIDcontactAfterInserttriggerExecuted();
        TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
        TriggerUtility.ZCloudIDcontactAfterInserttriggersetfalse();
        //String testVar = TriggerUtility.getMarketSegmentFromNumber(2,True);
        //TriggerUtility.getMarketSegmentFromPicklist('0 - 99',100,false);
        TriggerUtility.OpportunityPartnerAdditionExecuted();
        TriggerUtility.OpportunityPartnerAdditionReset();
        TriggerUtility.isCaseCreationForLeadTerrirtory();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryReset();
        TriggerUtility.isContactPatchManagerExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.contactPatchManagerReset();
        TriggerUtility.AcctoActivityTerritoryExecuted();
        TriggerUtility.AcctoActivityTerritoryReset();
        TriggerUtility.requestDecommissionPrReset();
        TriggerUtility.isconWhiteSpaceUpdateExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.conWhiteSpaceUpdateReset();
        TriggerUtility.isaccToContactOwnerExecuted();
        TriggerUtility.accToContactOwnerReset();
        TriggerUtility.iscontactOwnerShipExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.contactOwnerShipReset();
        TriggerUtility.OpptyTriggerFCexecuted();
        TriggerUtility.OpptyTriggerFCReset();
        TriggerUtility.isOpptySplitTriggerFCexecuted();
        TriggerUtility.OpptySplitTriggerFCexecuted();
        TriggerUtility.OpptySplitTriggerFCReset();
        TriggerUtility.isOppCaseCreationExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.oppCaseCreationReset();
        TriggerUtility.ismanageZscalerAttendeeExecuted();
        TriggerUtility.manageZscalerAttendeeExecuted();
        TriggerUtility.manageZscalerAttendeeReset();
        TriggerUtility.isCampMemActivityExecuted();
        TriggerUtility.CampMemActivityExecuted();
        TriggerUtility.CampMemActivityReset();
        TriggerUtility.isActivityleadterritoryinsertExecuted();
        TriggerUtility.ActivityleadterritoryinsertExecuted();
        TriggerUtility.isActivityleadterritoryinsertReset();
        TriggerUtility.isActivityleadterritoryupdateExecuted();
        TriggerUtility.ActivityleadterritoryupdateExecuted();
        TriggerUtility.isActivityleadterritoryupdateReset();
        TriggerUtility.isActivityleadterritoryEventinsertExecuted();
        TriggerUtility.ActivityleadterritoryEventinsertExecuted();
        TriggerUtility.isActivityleadterritoryEventinsertReset();
        TriggerUtility.isActivityleadterritoryEventupdateExecuted();
        TriggerUtility.ActivityleadterritoryEventupdateExecuted();
        TriggerUtility.isActivityleadterritoryEventupdateReset();
        TriggerUtility.accToContactOwnerReset();
        TriggerUtility.iscontactOwnerShipExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.contactOwnerShipReset();
        TriggerUtility.requestDecommissionPrReset();
        TriggerUtility.isconWhiteSpaceUpdateExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.conWhiteSpaceUpdateReset();
        TriggerUtility.isaccToContactOwnerExecuted();
        TriggerUtility.oppSpliSalesTeamReset();
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accterritorypatchReset();
        TriggerUtility.isDealRegBeforeUpdateExecuted();
        TriggerUtility.dealRegBeforeUpdateExecuted();
        TriggerUtility.dealRegBeforeUpdateReset();
        TriggerUtility.isDealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterUpdateReset();
        TriggerUtility.isDealRegAfterInsertExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegAfterInsertReset();
        TriggerUtility.isDealRegBeforeInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.dealRegBeforeInsertReset();
        TriggerUtility.accSalesTeamExecuted();
        TriggerUtility.accSalesTeamReset();
        TriggerUtility.CustomerSuccessUpdatemethodsettrue();
        TriggerUtility.CustomerSuccessUpdatemethodsetfalse();
        TriggerUtility.isUpdateLeadNoOfEmployeesExecuted();
        TriggerUtility.updateLeadNoOfEmployeesExecuted();
        TriggerUtility.updateLeadNoOfEmployeesReset();
        TriggerUtility.isCreateInternalAttendeesForMeetingEventExecuted();
        TriggerUtility.createInternalAttendeesForMeetingEventExecuted();
        TriggerUtility.createInternalAttendeesForMeetingEventReset();
        TriggerUtility.isBRAttachmentValidationExecuted();
        TriggerUtility.BRAttachmentValidationExecuted();
        TriggerUtility.BRAttachmentValidationReset();
        TriggerUtility.skipentireproposaltriggerExecuted();
        TriggerUtility.skipentireproposaltriggerReset();
        TriggerUtility.updateContractEndDateReset();
        TriggerUtility.isintLogtriggerPRLogicExecuted();
        TriggerUtility.intLogtriggerPRLogicExecuted();
        TriggerUtility.intLogtriggerPRLogicReset();
        TriggerUtility.captureCustomerNextStepsHistoryReset();
        TriggerUtility.isSCIDealRegUpdateExecuted();
        TriggerUtility.SCIDealRegUpdateExecuted();
        TriggerUtility.SCIDealRegUpdateReset();
        TriggerUtility.isUpdateContactLeadStageExecuted();
        TriggerUtility.updateContactLeadStageExecuted();
        TriggerUtility.updateContactLeadStageReset();
        TriggerUtility.isUpdateDasPackageNameInOpptyExecuted();
        TriggerUtility.updateDasPackageNameInOpptyExecuted();
        TriggerUtility.updateDasPackageNameInOpptyReset();
        TriggerUtility.generateYearWiseSplitReset();
        TriggerUtility.isOverrideACVValuesResetFromOpptyExecuted();
        TriggerUtility.overrideACVValuesResetFromOpptyExecuted();
        TriggerUtility.overrideACVValuesResetFromOpptyReset();
        TriggerUtility.isupdatePartnerAccountForSCIExecuted();
        TriggerUtility.updatePartnerAccountForSCIExecuted();
        TriggerUtility.updatePartnerAccountForSCIReset();
        TriggerUtility.overrideACVValuesResetReset();
        TriggerUtility.isOpportunityOwnershipChangeExecuted();
        TriggerUtility.opportunityOwnershipChangeExecuted();
        TriggerUtility.OpportunityOwnershipChangeReset();
        TriggerUtility.opportunitySplitsAfterUpdateExecuted();
        TriggerUtility.opportunitySplitsAfterUpdateReset();
        TriggerUtility.revisitOpportunitySplitsSalesTerritoryReset();
        TriggerUtility.isUpdateLeadSalesTeamEmailFieldsExecuted();
        TriggerUtility.updateLeadSalesTeamEmailFieldsExecuted();
        TriggerUtility.updateLeadSalesTeamEmailFieldsReset();
        TriggerUtility.isUpdateGeolocationForDatacenterExecuted();
        TriggerUtility.updateGeolocationForDatacenterExecuted();
        TriggerUtility.updateGeolocationForDatacenterReset();
        TriggerUtility.updateProposalPriceListReset();
        TriggerUtility.updatedQuoteReset();
        TriggerUtility.updateForecastCategoryExecuted();
        TriggerUtility.updateForecastCategoryReset();
        TriggerUtility.isSCIOppUpdateExecuted();
        TriggerUtility.SCIOppUpdateExecuted();
        TriggerUtility.SCIOppUpdateReset();
        Test.stopTest();
    }
    
}