/**
 *  This is the ulitity class for triggers.
 *
 */

public class TriggerUtility
{

    private static boolean manageZscalerAttendee= false;
    private static boolean intLogtriggerPRLogic = false;
    private static boolean CampMemActivity= false;
    private static boolean Activityleadterritoryinsert = false;
    private static boolean Activityleadterritoryupdate = false;
    private static boolean ActivityleadterritoryEventinsert = false;
    private static boolean ActivityleadterritoryEventupdate = false;
    private static boolean AcctoActivityTerritory = false;
    private static boolean contactPatchManager = false;
    private static boolean OpportunityPartnerAddition = false;
    private static boolean oppCaseCreation = false;
    private static boolean caseCreationForDefaultTerrirtory = false;
    private static boolean contactOwnerShip = false;
    private static boolean accToContactOwner = false;
    private static boolean conWhiteSpaceUpdate = false;
    private static boolean requestDecommissionPr = false;
    private static boolean oppSpliSalesTeam = false;
    private static boolean dealRegBeforeInsert = false;
    private static boolean dealRegAfterInsert = false;
    private static boolean dealRegAfterUpdate = false;
    private static boolean dealRegBeforeUpdate = false;
    private static boolean accSalesTeam = false;
    private static boolean accterritorypatch = false;
    private static boolean opportunityAccountsScreening = false;
    private static boolean accContactWhiteSpaceUpdate = false;
    private static boolean updateLeadContactForCamp = false;
    private static boolean udpateSCIforEngagement = false;
    private static boolean oppPRProductionStatusUpdate = false;
    private static boolean fsAccountOwnerIdUpdate = false;
    private static boolean oppPatchManagerAfterInsert = false;
    private static boolean oppPatchManagerAfterUpdate = false;
    private static boolean updateContactRoleCount = false;
    private static boolean updateOppNextStepHistory = false;
    //Start of change - Raghu (Tech Validation Next Step History, Architecture Next Step History)
    Private static boolean updateTechValHistory = false;
    Private static boolean architectureHistory = false;
    //End of change - Raghu (Tech Validation Next Step History, Architecture Next Step History)
    private static boolean updateSEManagerEmail = false;
    private static boolean updateSENameFromAccount = false;
    private static boolean updateAccountForApprovedPZEN = false;
    private static boolean ERNotification = false;
    private static boolean updateLatestIBConOpp = false;
    private static boolean SCIOppUpdate = false;
    private static boolean SCIDealRegUpdate = false;
    private static boolean updateForecastCategory = false;
    private static boolean updatedQuote = false;
    //public static map<id, Apttus_Proposal__Proposal__c> oldQuoteMap = new map<id, Apttus_Proposal__Proposal__c>();
    private static boolean updateProposalPriceList = false;
    private static boolean updateGeolocationForDatacenter = false;
    private static boolean updateLeadSalesTeamEmailFields = false;
    private static boolean revisitOpportunitySplitsSalesTerritory = false;
    private static boolean opportunitySplitsAfterUpdate = false;
    private static boolean opportunityOwnershipChange = false;
    private static boolean overrideACVValuesReset = false;
    private static boolean overrideACVValuesResetFromOppty = true;
    private static boolean updatePartnerAccountForSCI = false;
    private static boolean ForecastCategorychanges = false;
    private static boolean ForecastCategorychangessplit = false;
    private static boolean generateYearWiseSplit = false;
    private static boolean updateDasPackageNameInOppty = false;
    private static boolean updateContactLeadStage = false;
    private static boolean captureCustomerNextStepsHistory = false;
    private static boolean updateContractEndDate = false;
    private static boolean skipentireproposaltrigger = false;
    private static boolean BRTriggerExecuted = false;
    private static boolean createInternalAttendeesForMeetingEvent = false;
    private static boolean updateLeadNoOfEmployees = false;
    private static boolean CustomerSuccessUpdatemethod = false;
    private static boolean updateTechnologyPartner = false;
    private static boolean AutocreateZCloudIDcontactUpdate = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    private static boolean ZCloudIDcontactDeletetrigger = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    private static boolean ZCloudIDcontactAfterInserttrigger = false; //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts
    //private static boolean updateTechnologyPartner = false;
    private static boolean beforeUpdateSplit = false;
    private static boolean splitOwnerterritory_Update = false;
    private static boolean revokePendingQuoteApproval = false;
    public static boolean bypassSCITrigger=false;
    public static boolean isGroove2SCIcodeexecuted=false;
    public static boolean skipAccountTrigger = false;
    public static boolean skipCaseTrigger = false;
    public static boolean skipCaseCommentTrigger = false;
    public static boolean skipCaseSkillAssignment = false;
    public static boolean skipCaseEscalation = false;
    public static boolean casebeforeinsert = false;
    public static boolean casebeforeupdate = false;
    public static boolean caseafterudpate = false;
    public static boolean caseEscalationHistoryCreation = false;
    public static boolean skipCaseEntAssignment = false;
    public static boolean caseEscalationNotes = false;
    public static boolean skipCaseCommentAfterInsertTrigger = false;
    public static boolean skipFRTandCustomerNote = false;
    public static boolean caseStatusHistory = false;
    public static boolean skipManualSLA = false;
    public static boolean skipentitlementcreation = false;
    public static boolean skipentitlementupdate = false;
    public static boolean skipCaseCommentBeforeInsertTrigger = false;
    public static boolean skipCustomerNotePublic = false;
    public static Integer accSalesTeamMethodExecution = 0;
    
    public static final String PROSPECT = 'Prospect';
    public static final String ENGAGED = 'Engaged';
    public static final String NO_RECENT_ENGAGEMENT = 'No recent engagement';
    public static final String PIPELINE = 'Pipeline';
    public static final String POC = 'POC';
    public static final String OPPLOST = 'Opportunity Lost';
    public static final String NOT_TOUCHED = 'Not touched';
    public static final String BLANK = '';
    public static boolean containsOpenOpps = false;
    
    public static final String OPP_CLOSED_12 = label.Stage_7_Closed_Lost /*'12 - Closed With No Decision'*/;
    public static map<id, Apttus_Proposal__Proposal__c> oldQuoteMap = new map<id, Apttus_Proposal__Proposal__c>();
    
    //added by Gurjinder for CSU:start
    public static Boolean CustomerSuccessUpdatemethodexecuted() {
        return CustomerSuccessUpdatemethod;
    }

    public static void CustomerSuccessUpdatemethodsettrue() {
        CustomerSuccessUpdatemethod = true;
    }

    public static void CustomerSuccessUpdatemethodsetfalse() {
        CustomerSuccessUpdatemethod = false;
    }
    //added by Gurjinder for CSU:end
    
    public static Boolean isUpdateLeadNoOfEmployeesExecuted() {
        return updateLeadNoOfEmployees;
    }

    public static void updateLeadNoOfEmployeesExecuted() {
        updateLeadNoOfEmployees = true;
    }

    public static void updateLeadNoOfEmployeesReset() {
        updateLeadNoOfEmployees = false;
    }
        
    public static Boolean isCreateInternalAttendeesForMeetingEventExecuted() {
        return createInternalAttendeesForMeetingEvent;
    }

    public static void createInternalAttendeesForMeetingEventExecuted() {
        createInternalAttendeesForMeetingEvent = true;
    }

    public static void createInternalAttendeesForMeetingEventReset() {
        createInternalAttendeesForMeetingEvent = false;
    }
    
    public static Boolean isBRAttachmentValidationExecuted() {
        return BRTriggerExecuted ;
    }

    public static void BRAttachmentValidationExecuted() {
        BRTriggerExecuted = true;
    }

    public static void BRAttachmentValidationReset() {
        BRTriggerExecuted = false;
    }

    public static Boolean isskipentireproposaltriggerExecuted() {
        return skipentireproposaltrigger;
    }

    public static void skipentireproposaltriggerExecuted() {
        skipentireproposaltrigger = true;
    }

    public static void skipentireproposaltriggerReset() {
        skipentireproposaltrigger = false;
    }
    
    public static Boolean isUpdateContractEndDateExecuted() {
        return updateContractEndDate;
    }

    public static void updateContractEndDateExecuted() {
        updateContractEndDate = true;
    }

    public static void updateContractEndDateReset() {
        updateContractEndDate = false;
    }
    
    public static Boolean isintLogtriggerPRLogicExecuted() {
        return intLogtriggerPRLogic;
    }

    public static void intLogtriggerPRLogicExecuted() {
        intLogtriggerPRLogic = true;
    }

    public static void intLogtriggerPRLogicReset() {
        intLogtriggerPRLogic = false;
    }

    public static Boolean isCaptureCustomerNextStepsHistoryExecuted() {
        return captureCustomerNextStepsHistory;
    }

    public static void captureCustomerNextStepsHistoryExecuted() {
        captureCustomerNextStepsHistory = true;
    }

    public static void captureCustomerNextStepsHistoryReset() {
        captureCustomerNextStepsHistory = false;
    }

    public static Boolean isSCIDealRegUpdateExecuted() {
        return SCIDealRegUpdate;
    }

    public static void SCIDealRegUpdateExecuted() {
        SCIDealRegUpdate = true;
    }

    public static void SCIDealRegUpdateReset() {
        SCIDealRegUpdate = false;
    }

    public static Boolean isUpdateContactLeadStageExecuted() {
        return updateContactLeadStage;
    }

    public static void updateContactLeadStageExecuted() {
        updateContactLeadStage = true;
    }

    public static void updateContactLeadStageReset() {
        updateContactLeadStage = false;
    }

    public static Boolean isUpdateDasPackageNameInOpptyExecuted() {
        return updateDasPackageNameInOppty;
    }

    public static void updateDasPackageNameInOpptyExecuted() {
        updateDasPackageNameInOppty = true;
    }

    public static void updateDasPackageNameInOpptyReset() {
        updateDasPackageNameInOppty = false;
    }

    public static Boolean isGenerateYearWiseSplitExecuted() {
        return generateYearWiseSplit;
    }

    public static void generateYearWiseSplitExecuted() {
        generateYearWiseSplit = true;
    }

    public static void generateYearWiseSplitReset() {
        generateYearWiseSplit = false;
    }

    public static Boolean isOverrideACVValuesResetFromOpptyExecuted() {
        return overrideACVValuesResetFromOppty;
    }

    public static void overrideACVValuesResetFromOpptyExecuted() {
        overrideACVValuesResetFromOppty = true;
    }

    public static void overrideACVValuesResetFromOpptyReset() {
        overrideACVValuesResetFromOppty = false;
    }

    public static Boolean isupdatePartnerAccountForSCIExecuted() {
        return updatePartnerAccountForSCI;
    }

    public static void updatePartnerAccountForSCIExecuted() {
        updatePartnerAccountForSCI = true;
    }

    public static void updatePartnerAccountForSCIReset() {
        updatePartnerAccountForSCI = false;
    }

    public static Boolean isOverrideACVValuesResetExecuted() {
        return overrideACVValuesReset;
    }

    public static void overrideACVValuesResetExecuted() {
        overrideACVValuesReset = true;
    }

    public static void overrideACVValuesResetReset() {
        overrideACVValuesReset = false;
    }

    public static Boolean isOpportunityOwnershipChangeExecuted() {
        return opportunityOwnershipChange;
    }

    public static void opportunityOwnershipChangeExecuted() {
        opportunityOwnershipChange = true;
    }

    public static void OpportunityOwnershipChangeReset() {
        opportunityOwnershipChange = false;
    }

    public static Boolean isOpportunitySplitsAfterUpdateExecuted() {
        return opportunitySplitsAfterUpdate;
    }

    public static void opportunitySplitsAfterUpdateExecuted() {
        opportunitySplitsAfterUpdate = true;
    }

    public static void opportunitySplitsAfterUpdateReset() {
        opportunitySplitsAfterUpdate = false;
    }

    public static Boolean isRevisitOpportunitySplitsSalesTerritoryExecuted() {
        return revisitOpportunitySplitsSalesTerritory;
    }

    public static void revisitOpportunitySplitsSalesTerritoryExecuted() {
        revisitOpportunitySplitsSalesTerritory = true;
    }

    public static void revisitOpportunitySplitsSalesTerritoryReset() {
        revisitOpportunitySplitsSalesTerritory = false;
    }

    public static boolean isUpdateLeadSalesTeamEmailFieldsExecuted() {
        return updateLeadSalesTeamEmailFields;
    }

    public static void updateLeadSalesTeamEmailFieldsExecuted() {
        updateLeadSalesTeamEmailFields = true;
    }

    public static void updateLeadSalesTeamEmailFieldsReset() {
        updateLeadSalesTeamEmailFields = false;
    }

    public static boolean isUpdateGeolocationForDatacenterExecuted() {
        return updateProposalPriceList;
    }

    public static void updateGeolocationForDatacenterExecuted() {
        updateProposalPriceList = true;
    }

    public static void updateGeolocationForDatacenterReset() {
        updateProposalPriceList = false;
    }

    public static boolean isUpdateProposalPriceListExecuted() {
        return updateProposalPriceList;
    }

    public static void updateProposalPriceListExecuted() {
        updateProposalPriceList = true;
    }

    public static void updateProposalPriceListReset() {
        updateProposalPriceList = false;
    }

    public static boolean isUpdatedQuoteExecuted() {
        return updatedQuote;
    }


    public static void updatedQuoteExecuted() {
        updatedQuote = true;
    }


    public static void updatedQuoteReset() {
        updatedQuote = false;
    }

    public static boolean isUpdateForecastCategoryExecuted() {
        return updateForecastCategory;
    }


    public static void updateForecastCategoryExecuted() {
        updateForecastCategory = true;
    }


    public static void updateForecastCategoryReset() {
        updateForecastCategory = false;
    }

    public static boolean isSCIOppUpdateExecuted() {
        return SCIOppUpdate;
    }


    public static void SCIOppUpdateExecuted() {
        SCIOppUpdate = true;
    }


    public static void SCIOppUpdateReset() {
        SCIOppUpdate = false;
    }

    public static boolean isupdateLatestIBConOppExecuted() {
        return updateLatestIBConOpp;
    }


    public static void updateLatestIBConOppExecuted() {
        updateLatestIBConOpp = true;
    }

    public static void updateLatestIBConOppReset() {
        updateLatestIBConOpp = false;
    }

    public static boolean isERNotificationExecuted() {
        return ERNotification;
    }


    public static void ERNotificationExecuted() {
        ERNotification = true;
    }

    public static void ERNotificationReset() {
        ERNotification = false;
    }

    public static boolean isUpdateAccountForApprovedPZEN() {
        return updateAccountForApprovedPZEN;
    }

    public static void updateAccountForApprovedPZENExecuted() {
        updateAccountForApprovedPZEN = true;
    }

    public static void updateAccountForApprovedPZENReset() {
        updateAccountForApprovedPZEN = false;
    }

    public static boolean isupdateSENameFromAccountExecuted() {
        return updateSENameFromAccount;
    }

    public static void updateSENameFromAccountExecuted() {
        updateSENameFromAccount = true;
    }

    public static void updateSENameFromAccountReset() {
        updateSENameFromAccount = false;
    }

    public static boolean isupdateSEManagerEmailExecuted() {
        return updateSEManagerEmail;
    }

    public static void updateSEManagerEmailExecuted() {
        updateSEManagerEmail = true;
    }

    public static void updateSEManagerEmailReset() {
        updateSEManagerEmail = false;
    }

    public static boolean isupdateOppNextStepHistoryExecuted() {
        return updateOppNextStepHistory;
    }

    public static void updateOppNextStepHistoryExecuted() {
        updateOppNextStepHistory = true;
    }

    public static void updateOppNextStepHistoryReset() {
        updateOppNextStepHistory = false;
    }

    //start of change - Raghu

    public static boolean isupdateTechValHistoryExecuted() {
        return updateTechValHistory;
    }

    public static void updateTechValHistoryExecuted() {
        updateTechValHistory = true;
    }

    public static void updateTechValHistoryReset() {
        updateTechValHistory = false;
    }

    public static boolean isarchitectureHistoryExecuted() {
        return architectureHistory;
    }

    public static void architectureHistoryExecuted() {
        architectureHistory = true;
    }

    public static void architectureHistoryReset() {
        architectureHistory = false;
    }
    //End of change - Raghu

    public static boolean isupdateContactRoleCountExecuted() {
        return updateContactRoleCount;
    }

    public static void updateContactRoleCountExecuted() {
        updateContactRoleCount = true;
    }

    public static void updateContactRoleCountReset() {
        updateContactRoleCount = false;
    }

    public static boolean isOppPatchManagerAfterInsertExecuted() {
        return oppPatchManagerAfterInsert;
    }

    public static void oppPatchManagerAfterInsertExecuted() {
        oppPatchManagerAfterInsert = true;
    }

    public static void oppPatchManagerAfterInsertReset() {
        oppPatchManagerAfterInsert = false;
    }

    public static boolean isOppPatchManagerAfterUpdateExecuted() {
        return oppPatchManagerAfterUpdate;
    }

    public static void oppPatchManagerAfterUpdateExecuted() {
        oppPatchManagerAfterUpdate = true;
    }

    public static void oppPatchManagerAfterUpdateReset() {
        oppPatchManagerAfterUpdate = false;
    }

    public static boolean isFsAccountOwnerIdUpdateExecuted() {
        return fsAccountOwnerIdUpdate;
    }

    public static void fsAccountOwnerIdUpdateExecuted() {
        fsAccountOwnerIdUpdate = true;
    }

    public static void fsAccountOwnerIdUpdateReset() {
        fsAccountOwnerIdUpdate = false;
    }

    public static boolean isOppPRProductionStatusUpdateExecuted() {
        return oppPRProductionStatusUpdate;
    }

    public static void oppPRProductionStatusUpdateExecuted() {
        oppPRProductionStatusUpdate = true;
    }

    public static void oppPRProductionStatusUpdateReset() {
        oppPRProductionStatusUpdate = false;
    }

    public static boolean isudpateSCIforEngagement() {
        return udpateSCIforEngagement;
    }

    public static void udpateSCIforEngagementExecuted() {
        udpateSCIforEngagement = true;
    }

    public static void udpateSCIforEngagementReset() {
        udpateSCIforEngagement = false;
    }

    public static boolean isUpdateLeadContactForCampExecuted() {
        return accContactWhiteSpaceUpdate;
    }

    public static void updateLeadContactForCampExecuted() {
        accContactWhiteSpaceUpdate = true;
    }

    public static void updateLeadContactForCampReset() {
        accContactWhiteSpaceUpdate = false;
    }



    public static boolean isAccContactWhiteSpaceUpdateExecuted() {
        return accContactWhiteSpaceUpdate;
    }

    public static void accContactWhiteSpaceUpdateExecuted() {
        accContactWhiteSpaceUpdate = true;
    }

    public static void accContactWhiteSpaceUpdateReset() {
        accContactWhiteSpaceUpdate = false;
    }


    public static boolean isOpportunityAccountsScreeningExecuted() {
        return opportunityAccountsScreening;
    }

    public static void opportunityAccountsScreeningExecuted() {
        opportunityAccountsScreening = true;
    }

    public static void opportunityAccountsScreeningReset() {
        opportunityAccountsScreening = false;
    }


    public static boolean isAccSalesTeamExecuted(){
        return accSalesTeam;
    }

    public static void accSalesTeamExecuted(){
        accSalesTeam= true;
    }
    public static void accSalesTeamReset(){
        accSalesTeam= false;
    }

    public static boolean isAccTerritoryPatchexecuted(){
        return accterritorypatch;
    }

    public static void accTerritoryPatchExecuted(){
        accterritorypatch = true;
    }
    public static void accterritorypatchReset(){
        accterritorypatch = false;
    }

    public static boolean isDealRegBeforeUpdateExecuted(){
        return dealRegBeforeUpdate;
    }

    public static void dealRegBeforeUpdateExecuted(){
        dealRegBeforeUpdate= true;
    }
    public static void dealRegBeforeUpdateReset(){
        dealRegBeforeUpdate= false;
    }

    public static boolean isDealRegAfterUpdateExecuted(){
        return dealRegAfterUpdate;
    }

    public static void dealRegAfterUpdateExecuted(){
        dealRegAfterUpdate= true;
    }
    public static void dealRegAfterUpdateReset(){
        dealRegAfterUpdate= false;
    }

    public static boolean isDealRegAfterInsertExecuted(){
        return dealRegAfterInsert;
    }

    public static void dealRegAfterInsertExecuted(){
        dealRegAfterInsert= true;
    }
    public static void dealRegAfterInsertReset(){
        dealRegAfterInsert= false;
    }

    public static boolean isDealRegBeforeInsertExecuted(){
        return dealRegBeforeInsert;
    }

    public static void dealRegBeforeInsertExecuted(){
        dealRegBeforeInsert= true;
    }
    public static void dealRegBeforeInsertReset(){
        dealRegBeforeInsert= false;
    }


    public static boolean isOppSpliSalesTeamExecuted(){
        return oppSpliSalesTeam;
    }

    public static void oppSpliSalesTeamExecuted(){
        oppSpliSalesTeam= true;
    }
    public static void oppSpliSalesTeamReset(){
        oppSpliSalesTeam= false;
    }


    public static boolean isRequestDecommissionPrExecuted(){
        return requestDecommissionPr;
    }

    public static void requestDecommissionPrExecuted(){
        requestDecommissionPr= true;
    }
    public static void requestDecommissionPrReset(){
        requestDecommissionPr= false;
    }


    public static boolean isconWhiteSpaceUpdateExecuted(){
        return conWhiteSpaceUpdate;
    }

    public static void conWhiteSpaceUpdateExecuted(){
        conWhiteSpaceUpdate= true;
    }
    public static void conWhiteSpaceUpdateReset(){
        conWhiteSpaceUpdate= false;
    }

    public static boolean isaccToContactOwnerExecuted(){
        return accToContactOwner;
    }

    public static void accToContactOwnerExecuted(){
        accToContactOwner= true;
    }
    public static void accToContactOwnerReset(){
        accToContactOwner= false;
    }

    public static boolean iscontactOwnerShipExecuted(){
        return contactOwnerShip;
    }

    public static void contactOwnerShipExecuted(){
        contactOwnerShip= true;
    }
    public static void contactOwnerShipReset(){
        contactOwnerShip= false;
    }

    public static boolean isOpptyTriggerFCexecuted(){
        return ForecastCategorychanges;
    }

    public static void OpptyTriggerFCexecuted(){
        ForecastCategorychanges = true;
    }
    public static void OpptyTriggerFCReset(){
        ForecastCategorychanges = false;
    }

    public static boolean isOpptySplitTriggerFCexecuted(){
        return ForecastCategorychangessplit;
    }

    public static void OpptySplitTriggerFCexecuted(){
        ForecastCategorychangessplit = true;
    }
    public static void OpptySplitTriggerFCReset(){
        ForecastCategorychangessplit = false;
    }






    public static boolean isOppCaseCreationExecuted(){
        return manageZscalerAttendee;
    }

    public static void oppCaseCreationExecuted(){
        manageZscalerAttendee= true;
    }
    public static void oppCaseCreationReset(){
        manageZscalerAttendee= false;
    }



    public static boolean ismanageZscalerAttendeeExecuted(){
        return manageZscalerAttendee;
    }

    public static void manageZscalerAttendeeExecuted(){
        manageZscalerAttendee= true;
    }
    public static void manageZscalerAttendeeReset(){
        manageZscalerAttendee= false;
    }

    public static boolean isCampMemActivityExecuted(){
        return CampMemActivity;
    }

    public static void CampMemActivityExecuted(){
        CampMemActivity= true;
    }
    public static void CampMemActivityReset(){
        CampMemActivity= false;
    }

    public static boolean isActivityleadterritoryinsertExecuted(){
        return Activityleadterritoryinsert;
    }
    public static void ActivityleadterritoryinsertExecuted(){
        Activityleadterritoryinsert = true;
    }
    public static void isActivityleadterritoryinsertReset(){
        Activityleadterritoryinsert = false;
    }
    
    public static boolean isActivityleadterritoryupdateExecuted(){
        return Activityleadterritoryupdate;
    }
    public static void ActivityleadterritoryupdateExecuted(){
        Activityleadterritoryupdate = true;
    }
    public static void isActivityleadterritoryupdateReset(){
        Activityleadterritoryupdate = false;
    }

    public static boolean isActivityleadterritoryEventinsertExecuted(){
        return ActivityleadterritoryEventinsert;
    }
    public static void ActivityleadterritoryEventinsertExecuted(){
        ActivityleadterritoryEventinsert = true;
    }
    public static void isActivityleadterritoryEventinsertReset(){
        ActivityleadterritoryEventinsert = false;
    }
    
    public static boolean isActivityleadterritoryEventupdateExecuted(){
        return ActivityleadterritoryEventupdate;
    }
    public static void ActivityleadterritoryEventupdateExecuted(){
        ActivityleadterritoryEventupdate = true;
    }
    public static void isActivityleadterritoryEventupdateReset(){
        ActivityleadterritoryEventupdate = false;
    }

    public static boolean isAcctoActivityTerritoryExecuted(){
        return AcctoActivityTerritory;
    }
    public static void AcctoActivityTerritoryExecuted(){
        AcctoActivityTerritory = true;
    }
    public static void AcctoActivityTerritoryReset(){
        AcctoActivityTerritory = false;
    }


    public static boolean isContactPatchManagerExecuted(){
        return contactPatchManager;
    }

    public static void contactPatchManagerExecuted(){
        contactPatchManager = true;
    }
    public static void contactPatchManagerReset(){
        contactPatchManager = false;
    }


    public static boolean isOpportunityPartnerAddition(){
        return contactPatchManager;
    }

    public static void OpportunityPartnerAdditionExecuted(){
        contactPatchManager = true;
    }
    public static void OpportunityPartnerAdditionReset(){
        contactPatchManager = false;
    }


    public static boolean isCaseCreationForLeadTerrirtory(){
        return caseCreationForDefaultTerrirtory ;
    }

    public static void caseCreationForLeadTerrirtoryExecuted(){
        caseCreationForDefaultTerrirtory  = true;
    }
    public static void caseCreationForLeadTerrirtoryReset(){
        caseCreationForDefaultTerrirtory  = false;
    }



    public static String  GetMarketSegment(String noOfEmployeesPicklist, Integer noOfEmployees, Boolean isEMEARegion)
    {
        String marketSegment1 = TriggerUtility.GetMarketSegmentFromPicklist(noOfEmployeesPicklist, noOfEmployees, isEMEARegion);
        return marketSegment1;
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 START
        //String marketSegment2 = TriggerUtility.GetMarketSegmentFromNumber(noOfEmployees, isEMEARegion);

        /*System.debug('*** marketSegment1: ' + marketSegment1);
        System.debug('*** marketSegment2: ' + marketSegment2);
        if(marketSegment1 == 'LE' || marketSegment2 =='LE')
        {
            return 'Large Enterprise';
        }
        else if(marketSegment1 =='ENT' || marketSegment2 == 'ENT')
        {
            return 'Enterprise';
        }
        else if(marketSegment1 =='COMM' || marketSegment2 == 'COMM')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='SMB' || marketSegment2 =='SMB')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='SOHO' || marketSegment2 =='SOHO')
        {
            return 'General Business';
        }
        else if(marketSegment1 =='GB' || marketSegment2 =='GB')
        {
            return 'General Business';
        }
        else
        {
            return 'General Business';
        }*/
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 END
    }

    public static String getMarketSegmentFromPicklist(String noOfEmployeesPicklist, Integer noOfEmployees, Boolean isEMEARegion)
    {   
        // New logic per the FY19 Market Segmentation
        String marketSegment = '';
        if ( noOfEmployees == null && noOfEmployeesPicklist == null )
            return 'Corp sales';
        
        Integer startRange = 0, endRange = 0;
        if( noOfEmployeesPicklist != null ) {
            startRange =  noOfEmployeesPicklist.contains(' - ') ?  
                            Integer.valueOf( noOfEmployeesPicklist.split(' - ')[0].trim() ) : 
                            0;
            endRange = noOfEmployeesPicklist.contains(' - ') ?  Integer.valueOf( noOfEmployeesPicklist.split(' - ')[1].trim() ) : 0;
            startRange = noOfEmployeesPicklist.contains('+') ?  
                        Integer.valueOf( noOfEmployeesPicklist.substringBefore('+').trim() ) : 
                        startRange;
                        
        }
        
        if ( (noOfEmployees != null && noOfEmployeesPicklist != null && startRange > noOfEmployees) || (noOfEmployees == null && noOfEmployeesPicklist != null)) {
            for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                if(noOfEmployeesPicklist.contains(' - ') && setting.Start_Range__c <= startRange && setting.End_Range__c >= endRange) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                } else if( noOfEmployeesPicklist.contains('+') && setting.Start_Range__c <= startRange ) {
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                }
            }  
            
            return marketSegment;
        } else if ( noOfEmployees != null) {
            for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                if( setting.Start_Range__c <= noOfEmployees && setting.End_Range__c >= noOfEmployees) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                    marketSegment = setting.Market_Segmentation__c;
                    break;
                }
            }  
        }

        return marketSegment;
        
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 START
        // // New logic per the FY19 Market Segmentation
        // if (!isEMEARegion) {
        //     if (noOfEmployeesPicklist == '0 - 99' || noOfEmployeesPicklist == '100 - 499' || noOfEmployeesPicklist == '500 - 999' || noOfEmployeesPicklist == '1000 - 1999') {
        //         return 'GB';
        //     } else if (noOfEmployeesPicklist == '2000 - 4999' || noOfEmployeesPicklist == '5000 - 9999') {
        //         return 'ENT';
        //     } else if (noOfEmployeesPicklist == '10000 - 14999' || noOfEmployeesPicklist == '15000 - 24999' || noOfEmployeesPicklist == '25000+') {
        //         return 'LE';
        //     }
        // } else {
        //     if (noOfEmployeesPicklist == '0 - 99' || noOfEmployeesPicklist == '100 - 499' || noOfEmployeesPicklist == '500 - 999' || noOfEmployeesPicklist == '1000 - 1999') {
        //         return 'GB';
        //     } else if (noOfEmployeesPicklist == '2000 - 4999' || noOfEmployeesPicklist == '5000 - 9999' || noOfEmployeesPicklist == '10000 - 14999') {
        //         return 'ENT';
        //     } else if (noOfEmployeesPicklist == '15000 - 24999' || noOfEmployeesPicklist == '25000+') {
        //         return 'LE';
        //     }
        // }

        // return 'GB';
        //Previous FY19 Market segmentation is deactivated on 31-01-2020 END 
        
        // Below is the old logic:
        // Integer noOfEmployeesConverted;

        // if(String.isNotEmpty(noOfEmployeesPicklist))
        // {
        //     try
        //     {
        //         noOfEmployeesConverted = Integer.valueOf(noOfEmployeesPicklist);
        //     }
        //     catch(TypeException ex)
        //     {
        //         System.debug('An error occorred when converting string to integer.');
        //     }
        // }
        // if(noOfEmployeesConverted != null)
        // {
        //     return TriggerUtility.GetMarketSegmentFromNumber(noOfEmployeesConverted, isEMEARegion);
        // }
        // else
        // {
        //     if(noOfEmployeesPicklist == '1 - 100' )
        //     {
        //         return 'SOHO';
        //     }
        //     else if(noOfEmployeesPicklist == '100 - 250' || noOfEmployeesPicklist == '250 - 500' || ((noOfEmployeesPicklist == '500 - 1500') && noOfEmployees < 1000))
        //     {
        //         return 'SMB';
        //     }
        //     else if( noOfEmployeesPicklist == '500 - 1500' || noOfEmployeesPicklist == '1500 - 3000')
        //     {
        //         return 'COMM';
        //     }
        //     if (noOfEmployeesPicklist == '3000 - 5000') {
        //         // Condition for EMEA region
        //         if (isEMEARegion) {
        //             return 'GB';
        //         } else {
        //             return 'ENT';
        //         }
        //     }
        //     else if((noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '> 5000') && isEMEARegion && (noOfEmployees == null || noOfEmployees < 15000))
        //     {
        //         return 'ENT';
        //     }
        //     else if((noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '> 5000') && noOfEmployees < 10000)
        //     {
        //         return 'ENT';
        //     }
        //     else if(noOfEmployeesPicklist == '5000 - 20000' || noOfEmployeesPicklist == '5001 - 20000' || noOfEmployeesPicklist == '> 5000' || noOfEmployeesPicklist == '> 20000')
        //     {
        //         return 'LE';
        //     }
        //     else
        //     {
        //         return 'N/A';
        //     }
        // }
    }

    public static String getMarketSegmentFromNumber(Integer noOfEmployees, Boolean isEMEARegion)
    {
        // Condition for EMEA region
        //Changes 0-2k and 2k-15k  from 0-5k and 5k-15k  as part of Market segment
        
        
        if (isEMEARegion) {
            if (noOfEmployees > 0 && noOfEmployees < 2000) {
                return 'GB';
            } else if (noOfEmployees >= 2000 && noOfEmployees < 15000) {
                return 'ENT';
            } else if (noOfEmployees >= 15000) {
                return 'LE';
            }
        } else {
            if (noOfEmployees > 0 && noOfEmployees < 2000) {
                return 'GB';
            } else if (noOfEmployees >= 2000 && noOfEmployees < 10000) {
                return 'ENT';
            } else if (noOfEmployees >= 10000) {
                return 'LE';
            }
        }

        return 'GB';

        // if(noOfEmployees > 0 && noOfEmployees < 100)
        // {
        //     return 'SOHO';
        // }
        // else if(noOfEmployees >= 100 && noOfEmployees < 1000)
        // {
        //     return 'SMB';
        // }
        // else if(noOfEmployees >= 1000 && noOfEmployees < 3000)
        // {
        //     return 'COMM';
        // }
        // else if(noOfEmployees >= 3000 && noOfEmployees < 10000)
        // {
        //     return 'ENT';
        // }
        // else if(noOfEmployees >= 10000)
        // {
        //     return 'LE';
        // }
        // else
        // {
        //     return 'N/A';
        // }
    }
    
    //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts :start
    public static Boolean AutocreateZCloudIDcontactUpdateExecuted() {
        return AutocreateZCloudIDcontactUpdate;
    }

    public static void AutocreateZCloudIDcontactUpdatesettrue() {
        AutocreateZCloudIDcontactUpdate = true;
    }

    public static void AutocreateZCloudIDcontactUpdatesetfalse() {
        AutocreateZCloudIDcontactUpdate = false;
    }
    
    public static Boolean ZCloudIDcontactDeletetriggerExecuted() {
        return ZCloudIDcontactDeletetrigger;
    }

    public static void ZCloudIDcontactDeletetriggersettrue() {
        ZCloudIDcontactDeletetrigger = true;
    }

    public static void ZCloudIDcontactDeletetriggersetfalse() {
        ZCloudIDcontactDeletetrigger = false;
    }
    
    public static Boolean ZCloudIDcontactAfterInserttriggerExecuted() {
        return ZCloudIDcontactAfterInserttrigger;
    }

    public static void ZCloudIDcontactAfterInserttriggersettrue() {
        ZCloudIDcontactAfterInserttrigger = true;
    }

    public static void ZCloudIDcontactAfterInserttriggersetfalse() {
        ZCloudIDcontactAfterInserttrigger = false;
    }
    
    public static Boolean isTechpartnerupdateExecuted() {
        return updateTechnologyPartner;
    }

    public static void TechpartnerupdateExecuted() {
        updateTechnologyPartner = true;
    }

    public static void TechpartnerupdateReset() {
        updateTechnologyPartner = false;
    }
    //added by Gurjinder for Autocreation of Zscaler Cloud ID Contacts :End
    
    private static boolean prospectTypeUpdate = false;
    public static boolean isProspectUpdateExecuted(){
        return prospectTypeUpdate;
    }
    public static void prospectTypeUpdExecuted(){
        prospectTypeUpdate = true;
    }
    public static void prospectTypeUpdReset(){
        prospectTypeUpdate = false;
    }
    public static String sendEmailMethod(Provisioning_Request__c prObj,EmailTemplate et, String[] recepients){
    
         String response;
         //Get all recepients to be notified. SE Manager, PR Creator, Opp Owner
                
                //list of emails
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                
                //initiallize messaging method
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setToAddresses(recepients);
                
                //set template Id
                singleMail.setTemplateId(et.Id);
                
                String accId = [SELECT Id,AccountId FROM Opportunity WHERE Id =: prObj.Opportunity__c].AccountId;
                singleMail.setTargetObjectId([SELECT Id From Contact where AccountId =: accId LIMIT 1].Id);
                
                //flag to false to stop inserting activity history
                singleMail.setSaveAsActivity(true);
                singleMail.setWhatId(prObj.id);
                singleMail.setTreatTargetObjectAsRecipient(false);
                
                //add mail
                emails.add(singleMail);
               
               try{            
                     Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);
                     if(resultMail[0].isSuccess()){
                          response = 'SUCCESS';
                          system.debug('EMAIL SENT!');
                     }
                     else{
                          response = resultMail[0].getErrors().get(0).getMessage();
                     }
                                    
                }catch(System.EmailException ex){
                     response = ex.getMessage();
                }  
           return response;     
    }
    //added bu Sateesh as a part of RBAC
    private static boolean patchRealign = false;
    public static boolean isPatchRealigning(){
        return patchRealign;
    }
    public static void realignPatch(){
        patchRealign = true;
    }
    public static void realignPatchReset(){
        patchRealign = false;
    }
    
    public static String getUsersEmail(Id userId){
        return [SELECT Id,Email FROM User WHERE Id =: userId].Email;
    }
    
    public static boolean isbeforeUpdateSplitExecuted(){
        return beforeUpdateSplit;
    }
    public static void beforeUpdateSplitExecuted(){
        beforeUpdateSplit = true;
    }
    public static void beforeUpdateSplitReset(){
        beforeUpdateSplit = false;
    }
    
    public static boolean issplitOwnerterritory_UpdateExecuted(){
        return splitOwnerterritory_Update;
    }
    public static void splitOwnerterritory_UpdateExecuted(){
        splitOwnerterritory_Update = true;
    }
    public static void splitOwnerterritory_UpdateReset(){
        splitOwnerterritory_Update = false;
    }
    
     //added by Gurjinder for Updating Account Extension :start
    /**private static boolean UpdateAccountExtensionmethod = false;
    public static Boolean UpdateAccountExtensionmethodExecuted() {
        return UpdateAccountExtensionmethod;
    }

    public static void UpdateAccountExtensionmethodsettrue() {
        UpdateAccountExtensionmethod = true;
    }

    public static void UpdateAccountExtensionmethodsetfalse() {
        UpdateAccountExtensionmethod = false;
    }
    //added by Gurjinder for Updating Account Extension :End
    **/
    //added by Gurjinder for Account Workflow Optimization :start
    private static boolean AccountWorkflowOptimizationmethod = false;
    public static Boolean AccountWorkflowOptimizationmethodExecuted() {
        return AccountWorkflowOptimizationmethod;
    }

    public static void AccountWorkflowOptimizationmethodsettrue() {
        AccountWorkflowOptimizationmethod = true;
    }

    public static void AccountWorkflowOptimizationmethodsetfalse() {
        AccountWorkflowOptimizationmethod = false;
    }
    //added by Gurjinder for  Account Workflow Optimization :End
    public static Boolean isrevokePendingQuoteApprovalExecuted() {
        return revokePendingQuoteApproval;
    }

    public static void revokePendingQuoteApprovalExecuted() {
        revokePendingQuoteApproval = true;
    }

    public static void revokePendingQuoteApprovalReset() {
        revokePendingQuoteApproval = false;
    }
    //added by Gurjinder for Amber Road Screening 
    
    private static boolean ScreenAccountsWithAmberRoadExecuted = false; //added by Gurjinder for Amber Road Screening
    public static Boolean ScreenAccountsWithAmberRoadExecuted() {
        return ScreenAccountsWithAmberRoadExecuted;
    }

    public static void ScreenAccountsWithAmberRoadExecutedsettrue() {
        ScreenAccountsWithAmberRoadExecuted = true;
    }

    public static void ScreenAccountsWithAmberRoadExecutedsetfalse() {
        ScreenAccountsWithAmberRoadExecuted = false;
    }
    
    public static Boolean isSkipAccTriggerExecuted() {
        return skipAccountTrigger;
    }

    public static void SkipAccTriggerExecuted() {
        skipAccountTrigger = true;
    }

    public static void SkipAccTriggerReset() {
        skipAccountTrigger = false;
    }
    
    public static Boolean isSkipCaseTriggerExecuted() {
        return skipCaseTrigger;
    }

    public static void SkipCaseTriggerExecuted() {
        skipCaseTrigger = true;
    }

    public static void SkipCaseTriggerReset() {
        skipCaseTrigger = false;
    }
    
    public static Boolean isCaseBeforeInsertExecuted() {
        return casebeforeinsert;
    }

    public static void CaseBeforeInsertExecuted() {
        casebeforeinsert = true;
    }

    public static void CaseBeforeInsertReset() {
        casebeforeinsert = false;
    }
    
    public static Boolean isCaseBeforeUpdateExecuted() {
        return casebeforeupdate;
    }

    public static void CaseBeforeUpdateExecuted() {
        casebeforeupdate = true;
    }

    public static void CaseBeforeUpdateReset() {
        casebeforeupdate = false;
    }

    public static Boolean isCaseAfterUpdateExecuted() {
        return caseafterudpate;
    }

    public static void CaseAfterUpdateExecuted() {
        caseafterudpate = true;
    }

    public static void CaseAfterUpdateReset() {
        caseafterudpate = false;
    }

    public static Boolean isCaseEscalationHistoryExecuted() {
        return caseEscalationHistoryCreation;
    }

    public static void CaseEscalationHistoryExecuted() {
        caseEscalationHistoryCreation = true;
    }

    public static void CaseEscalationHistoryReset() {
        caseEscalationHistoryCreation = false;
    }
    
    public static Boolean isCaseSkillAssignmentExecuted() {
        return skipCaseSkillAssignment;
    }

    public static void CaseSkillAssignmentExecuted() {
        skipCaseSkillAssignment = true;
    }

    public static void CaseSkillAssignmentReset() {
        skipCaseSkillAssignment = false;
    }
    
    public static Boolean isskipCaseEscalationExecuted() {
        return skipCaseEscalation;
    }

    public static void skipCaseEscalationExecuted() {
        skipCaseEscalation = true;
    }

    public static void skipCaseEscalationReset() {
        skipCaseEscalation = false;
    }
    
    public static Boolean isCaseEntitlementAssigned() {
        return skipCaseEntAssignment;
    }

    public static void CaseEntitlementAssigned() {
        skipCaseEntAssignment = true;
    }

    public static void CaseEntitlementReset() {
        skipCaseEntAssignment = false;
    }
    
    public static Boolean isCaseEscalationNotesExecuted() {
        return caseEscalationNotes;
    }

    public static void CaseEscalationNotesExecuted() {
        caseEscalationNotes = true;
    }

    public static void CaseEscalationNotesReset() {
        caseEscalationNotes = false;
    }
    
    public static Boolean isSkipCaseCommentTriggerExecuted() {
        return skipCaseCommentTrigger;
    }

    public static void SkipCaseCommentTriggerExecuted() {
        skipCaseCommentTrigger = true;
    }

    public static void SkipCaseCommentTriggerReset() {
        skipCaseCommentTrigger = false;
    }
    
    public static Boolean isCaseCommentAfterInsertExecuted() {
        return skipCaseCommentAfterInsertTrigger;
    }

    public static void CaseCommentAfterInsertExecuted() {
        skipCaseCommentAfterInsertTrigger = true;
    }

    public static void CaseCommentAfterInsertReset() {
        skipCaseCommentAfterInsertTrigger = false;
    }
    
    public static Boolean isFRTandCustomerNoteExecuted() {
        return skipFRTandCustomerNote;
    }

    public static void FRTandCustomerNoteExecuted() {
        skipFRTandCustomerNote = true;
    }

    public static void FRTandCustomerNoteReset() {
        skipFRTandCustomerNote = false;
    }
    
    public static Boolean isCaseStatusHistoryExecuted() {
        return caseStatusHistory;
    }

    public static void CaseStatusHistoryExecuted() {
        caseStatusHistory = true;
    }

    public static void CaseStatusHistoryReset() {
        caseStatusHistory = false;
    }
    
    public static Boolean isManualSLAExecuted() {
        return skipManualSLA;
    }

    public static void ManualSLAExecuted() {
        skipManualSLA = true;
    }

    public static void ManualSLAReset() {
        skipManualSLA = false;
    }
    
    public static Boolean isProspectEntitlementExecuted() {
        return skipentitlementcreation;
    }

    public static void ProspectEntitlementExecuted() {
        skipentitlementcreation = true;
    }

    public static void ProspectEntitlementReset() {
        skipentitlementcreation = false;
    }
    
    public static Boolean isEntitlementUpdateExecuted() {
        return skipentitlementupdate;
    }

    public static void EntitlementUpdateExecuted() {
        skipentitlementupdate = true;
    }

    public static void EntitlementUpdateReset() {
        skipentitlementupdate = false;
    }
    
    public static Boolean isCaseCommentBeforeInsertExecuted() {
        return skipCaseCommentBeforeInsertTrigger;
    }

    public static void CaseCommentBeforeInsertExecuted() {
        skipCaseCommentBeforeInsertTrigger = true;
    }

    public static void CaseCommentBeforeInsertReset() {
        skipCaseCommentBeforeInsertTrigger = false;
    }
    
    public static Boolean isCustomerNotePublicExecuted() {
        return skipCustomerNotePublic;
    }

    public static void CustomerNotePublicExecuted() {
        skipCustomerNotePublic = true;
    }

    public static void CustomerNotePublicReset() {
        skipCustomerNotePublic = false;
    }
    
    //added by Gurjinder for SOQL 101 Optimization
    private static boolean UpdatingMarketsegmentforEMEA = false; 
    public static Boolean UpdatingMarketsegmentforEMEAExecuted() {
        return UpdatingMarketsegmentforEMEA;
    }

    public static void UpdatingMarketsegmentforEMEAsettrue() {
        UpdatingMarketsegmentforEMEA = true;
    }

    public static void UpdatingMarketsegmentforEMEAsetfalse() {
        UpdatingMarketsegmentforEMEA = false;
    }
    
    public static boolean iSupdateProspectTypeOnAccountmethodExecuted=false;
    //public static boolean IsCSMmanagerEmailCodeexecuted=false;
    
    //added by Gurjinder for avoid query in Workflow Optimization method
    private static boolean IsCSMmanagerEmailCodeexecuted = false; 
    public static Boolean IsCSMmanagerEmailCodeexecuted() {
        return IsCSMmanagerEmailCodeexecuted;
    }

    public static void IsCSMmanagerEmailCodeexecutedsettrue() {
        IsCSMmanagerEmailCodeexecuted = true;
    }

    public static void IsCSMmanagerEmailCodeexecutedsetfalse() {
        IsCSMmanagerEmailCodeexecuted = false;
    }


    private static boolean skipEmailMessageTrigger = false; 
    public static Boolean isSkipEmailMessageTriggerExecured() {
        return skipEmailMessageTrigger;
    }

    public static void SkipEmailMessageTriggerExecured() {
        skipEmailMessageTrigger = true;
    }

    public static void SkipEmailMessageTriggerReset() {
        skipEmailMessageTrigger = false;
    }

    private static boolean skipEmailMessageAfterInsertTrigger = false; 
    public static Boolean isEmailMessageAfterInsertExecuted() {
        return skipEmailMessageAfterInsertTrigger;
    }

    public static void EmailMessageAfterInsertExecuted() {
        skipEmailMessageAfterInsertTrigger = true;
    }

    public static void EmailMessageAfterInsertReset() {
        skipEmailMessageAfterInsertTrigger = false;
    }

    private static boolean skipEmailMessagetoCaseComment = false; 
    public static Boolean isEmailMessagetoCaseCommentExecuted() {
        return skipEmailMessagetoCaseComment;
    }

    public static void EmailMessagetoCaseCommentExecuted() {
        skipEmailMessagetoCaseComment = true;
    }

    public static void EmailMessagetoCaseCommentReset() {
        skipEmailMessagetoCaseComment = false;
    }

    private static boolean skipUserTriggerExecuted = false; 
    public static Boolean isSkipUserTriggerExecuted() {
        return skipUserTriggerExecuted;
    }

    public static void SkipUserTriggerExecuted() {
        skipUserTriggerExecuted = true;
    }

    public static void SkipUserTriggerReset() {
        skipUserTriggerExecuted = false;
    }

    private static boolean UserAfterInsertExecuted = false; 
    public static Boolean isUserAfterInsertExecuted() {
        return UserAfterInsertExecuted;
    }

    public static void UserAfterInsertExecuted() {
        UserAfterInsertExecuted = true;
    }

    public static void UserAfterInsertReset() {
        UserAfterInsertExecuted = false;
    }

    private static boolean UserAfterUpdateExecuted = false; 
    public static Boolean isUserAfterUpdateExecuted() {
        return UserAfterUpdateExecuted;
    }

    public static void UserAfterUpdateExecuted() {
        UserAfterUpdateExecuted = true;
    }

    public static void UserAfterUpdateReset() {
        UserAfterUpdateExecuted = false;
    }

    private static boolean userskillassninsert = false; 
    public static Boolean isUserSkillAssignmentInsertExecuted() {
        return userskillassninsert;
    }

    public static void UserSkillAssignmentInsertExecuted() {
        userskillassninsert = true;
    }

    public static void UserSkillAssignmentInsertReset() {
        userskillassninsert = false;
    }

    private static boolean userskillassnupdate = false; 
    public static Boolean isUserSkillAssignmentUpdateExecuted() {
        return userskillassnupdate;
    }

    public static void UserSkillAssignmentUpdateExecuted() {
        userskillassnupdate = true;
    }

    public static void UserSkillAssignmentUpdateReset() {
        userskillassnupdate = false;
    }
    
    private static boolean prafterinsert = false; 
    public static Boolean isPRafterInsertExecuted() {
        return prafterinsert;
    }

    public static void PRafterInsertExecuted() {
        prafterinsert = true;
    }

    public static void PRafterInsertReset() {
        prafterinsert = false;
    }
    
    private static boolean prafterupdate = false; 
    public static Boolean isPRafterUpdateExecuted() {
        return prafterupdate;
    }

    public static void PRafterUpdateExecuted() {
        prafterupdate = true;
    }

    public static void PRafterUpdateReset() {
        prafterupdate = false;
    }
    
    private static boolean ccinsertpr = false; 
    public static Boolean isCaseCreationInsertPRExecuted() {
        return ccinsertpr;
    }

    public static void CaseCreationInsertPRExecuted() {
        ccinsertpr = true;
    }

    public static void CaseCreationInsertPRReset() {
        ccinsertpr = false;
    }

    private static boolean ccupdatepr = false; 
    public static Boolean isCaseCreationUpdatePRExecuted() {
        return ccupdatepr;
    }

    public static void CaseCreationUpdatePRExecuted() {
        ccupdatepr = true;
    }

    public static void CaseCreationUpdatePRReset() {
        ccupdatepr = false;
    }

    private static boolean getfeedback = false; 
    public static Boolean isGetFeedbackExecuted() {
        return getfeedback;
    }

    public static void GetFeedbackExecuted() {
        getfeedback = true;
    }

    public static void GetFeedbackReset() {
        getfeedback = false;
    }

    private static boolean dsatcase = false; 
    public static Boolean isDSATCaseCreationExecuted() {
        return dsatcase;
    }

    public static void DSATCaseCreationExecuted() {
        dsatcase = true;
    }

    public static void DSATCaseCreationReset() {
        dsatcase = false;
    }
    
    private static boolean userbeforeinsert = false; 
    public static Boolean isUserBeforeInsertExecuted() {
        return userbeforeinsert;
    }

    public static void UserBeforeInsertExecuted() {
        userbeforeinsert = true;
    }

    public static void UserBeforeInsertReset() {
        userbeforeinsert = false;
    }

    private static boolean userbeforeupdate = false; 
    public static Boolean isUserBeforeUpdateExecuted() {
        return userbeforeupdate;
    }

    public static void UserBeforeUpdateExecuted() {
        userbeforeupdate = true;
    }

    public static void UserBeforeUpdateReset() {
        userbeforeupdate = false;
    }

    private static boolean emailmessageFRT = false; 
    public static Boolean isEmailMessageFRTExecuted() {
        return emailmessageFRT;
    }

    public static void EmailMessageFRTExecuted() {
        emailmessageFRT = true;
    }

    public static void EmailMessageFRTReset() {
        emailmessageFRT = false;
    }

    private static boolean skipfeeditemtrigger = false; 
    public static Boolean isSkipFeedItemTriggerExecuted() {
        return skipfeeditemtrigger;
    }

    public static void SkipFeedItemTriggerExecuted() {
        skipfeeditemtrigger = true;
    }

    public static void SkipFeedItemTriggerReset() {
        skipfeeditemtrigger = false;
    }

    private static boolean skipfeeditemafterinserttrigger = false; 
    public static Boolean isFeedItemAfterTriggerExecuted() {
        return skipfeeditemafterinserttrigger;
    }

    public static void FeedItemAfterTriggerExecuted() {
        skipfeeditemafterinserttrigger = true;
    }

    public static void FeedItemAfterTriggerReset() {
        skipfeeditemafterinserttrigger = false;
    }

    private static boolean skipfeeditembeforeinserttrigger = false; 
    public static Boolean isFeedItemBeforeTriggerExecuted() {
        return skipfeeditembeforeinserttrigger;
    }

    public static void FeedItemBeforeTriggerExecuted() {
        skipfeeditembeforeinserttrigger = true;
    }

    public static void FeedItemBeforeTriggerReset() {
        skipfeeditembeforeinserttrigger = false;
    }

    private static boolean skipfeeditemiternalpost = false; 
    public static Boolean isFeedItemInternalPostExecuted() {
        return skipfeeditemiternalpost;
    }

    public static void FeedItemInternalPostExecuted() {
        skipfeeditemiternalpost = true;
    }

    public static void FeedItemInternalPostReset() {
        skipfeeditemiternalpost = false;
    }

    private static boolean skipfeedcommentaftertrigger = false; 
    public static Boolean isFeedCommentAfterTriggerExecuted() {
        return skipfeedcommentaftertrigger;
    }

    public static void FeedCommentAfterTriggerExecuted() {
        skipfeedcommentaftertrigger = true;
    }

    public static void FeedCommentAfterTriggerReset() {
        skipfeedcommentaftertrigger = false;
    }

    private static boolean skipfeedcommenttrigger = false; 
    public static Boolean isSkipFeedCommentTriggerExecuted() {
        return skipfeedcommenttrigger;
    }

    public static void SkipFeedCommentTriggerExecuted() {
        skipfeedcommenttrigger = true;
    }

    public static void SkipFeedCommentTriggerReset() {
        skipfeedcommenttrigger = false;
    }

    private static boolean skipCaseAfterInsert = false; 
    public static Boolean isCaseAfterInsertExecuted() {
        return skipCaseAfterInsert;
    }

    public static void CaseAfterInsertExecuted() {
        skipCaseAfterInsert = true;
    }

    public static void CaseAfterInsertReset() {
        skipCaseAfterInsert = false;
    }

    private static boolean CaseDesctoComment = false; 
    public static Boolean isCaseDesctoCommentExecuted() {
        return CaseDesctoComment;
    }

    public static void CaseDesctoCommentExecuted() {
        CaseDesctoComment = true;
    }

    public static void CaseDesctoCommentReset() {
        CaseDesctoComment = false;
    }

    private static boolean SkipContactTrigger = false; 
    public static Boolean isSkipContactTriggerExecuted() {
        return SkipContactTrigger;
    }

    public static void SkipContactTriggerExecuted() {
        SkipContactTrigger = true;
    }

    public static void SkipContactTriggerReset() {
        SkipContactTrigger = false;
    }

    private static boolean casecloseMilestone = false; 
    public static Boolean isCloseMilestonesonCaseCloseExecuted() {
        return casecloseMilestone;
    }

    public static void CloseMilestonesonCaseCloseExecuted() {
        casecloseMilestone = true;
    }

    public static void CloseMilestonesonCaseCloseReset() {
        casecloseMilestone = false;
    }
    
    private static boolean UpdateDetailsonMasterCase = false; 
    public static Boolean isUpdateDetailsonMasterCaseExecuted() {
        return UpdateDetailsonMasterCase;
    }

    public static void UpdateDetailsonMasterCaseExecuted() {
        UpdateDetailsonMasterCase = true;
    }

    public static void UpdateDetailsonMasterCaseReset() {
        UpdateDetailsonMasterCase = false;
    }
    
    private static boolean cldtrigger = false; 
    public static Boolean isSkipContentDocLinkTriggerExecuted() {
        return cldtrigger;
    }

    public static void SkipContentDocLinkTriggerExecuted() {
        cldtrigger = true;
    }

    public static void SkipContentDocLinkTriggerReset() {
        cldtrigger = false;
    }
    
    private static boolean cdlafterinsert = false; 
    public static Boolean isCDLAfterInsertExecuted() {
        return cdlafterinsert;
    }

    public static void CDLAfterInsertExecuted() {
        cdlafterinsert = true;
    }

    public static void CDLAfterInsertReset() {
        cdlafterinsert = false;
    }
    
    private static boolean emailcdltocaseedl = false; 
    public static Boolean isEmailCDLtoCaseEDLExecuted() {
        return emailcdltocaseedl;
    }

    public static void EmailCDLtoCaseEDLExecuted() {
        emailcdltocaseedl = true;
    }

    public static void EmailCDLtoCaseEDLReset() {
        emailcdltocaseedl = false;
    }
    
    private static boolean updateOppPartonMakePrimary = false; 
    public static Boolean isUpdateOppPartneronPrimaryChangeExecuted() {
        return updateOppPartonMakePrimary;
    }

    public static void UpdateOppPartneronPrimaryChangeExecuted() {
        updateOppPartonMakePrimary = true;
    }

    public static void UpdateOppPartneronPrimaryChangeReset() {
        updateOppPartonMakePrimary = false;
    }
    
    public static void booster(){
    integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;    
  }
}