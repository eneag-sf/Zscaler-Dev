/*****************************************************************************************
Name: ManageSCIController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to handle ManageSCI page
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Vijay Prakash P J     01-Dec-2016    Initial Development
1.1            Vijay Prakash P J     06-Apr-2017    Changed logic to make external attendees not mandatory when the
                                                    primary parent record is a Lead.
1.2            Vijay Prakash P J     11-Aug-2017    Changed the logic to add / delete specific external attendees
                                                    when the list gets modified.
******************************************************************************************/
public class ManageSCIController {
    /*
    Public properties - Start
     */
    public Significant_Customer_Interaction__c sciRecord { get; set; }
    public Significant_Customer_Interaction__c addMeToSCI;

    public Boolean chooseSciTypeStep { get; set; }
    public Boolean sciDetailsStep { get; set; }
    public Boolean internalAttendeesStep { get; set; }
    public Boolean externalAttendeesStep { get; set; }
    public Boolean isEditMode { get; set; }
    public Boolean isError { get; set; }
    public Boolean showValidationErrors {
                                            get {
                                                return (null != validationErrors && !validationErrors.isEmpty() ? true : false);
                                            }
                                        }
    public Boolean inlinePoc { get; set; }
    public Boolean addMe { get; set; }
    public Boolean showAddedInternalAttendeeMessage { get; set; }
    public Boolean showPopup { get; set; }
    public Boolean addNewExternalAttendee { get; set; }
    public Boolean skipExternalAttendeesRefresh { get; set; }
    public Boolean isPrimaryTopicRequired { get; set; }
    public Boolean isMethodOfInteractionRequired { get; set; }
    public Boolean isPartnerAccountRequired { get; set; }

    public Integer foundExistingSCICount { get; set; }
    public Integer foundMatchingInternalUsersCount { get; set; }
    public Integer foundMatchingExternalUsersCount { get; set; }

    public Id accountId { get; set; }
    public Id opportunityId { get; set; }
    public Id dealRegId { get; set; }
    public Id leadId { get; set; }
    public Id campaignId { get; set; }
    public Id patchTeamId { get; set; }
    public Id internalAttendeeToAdd { get; set; }
    public Id internalAttendeeToRemove { get; set; }
    public Id externalAttendeeToAdd { get; set; }
    public Id externalAttendeeToRemove { get; set; }
    public Id organizerId { get; set; }
    public Id participantId { get; set; }
    public Id addMeToSCIId { get; set; }
    public Id newExternalAttendeeId { get; set; }
    public Id cloneFromId { get; set; }
    public Id regularMeetingRecordTypeId { get; set; }
    public Id selectedSCIRecordTypeId { get; set; }

    public NavigationStep navigationSteps { get; set; }
    public Integer gotoStepNumber {get; set;}
    public Integer currentStep {
                                    get {
                                        return navigationSteps.currentStep;
                                    }
                                }

    public List<ManageSCIService.SCIWrapper> lstExistingSCIs { get; set; }

    public Map<Id, User> mapMatchingInternalUsers { get; set; }
    public Map<Id, ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper> mapInternalAttendees;
    public List<ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper> lstInternalAttendeesToUpsert;
    public List<ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper> lstInternalAttendeesToBind { get; set; }

    public Map<Id, Contact> mapMatchingExternalUsers { get; set; }
    public Map<Id, ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper> mapExternalAttendees;
    public List<ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper> lstExternalAttendeesToUpsert;
    public List<ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper> lstExternalAttendeesToBind { get; set; }
    public Set<Id> setModifiedExternalAttendees { get; set; }

    public List<SelectOption> lstSelectSCITypeOptions { get; set; }
    public List<SelectOption> lstSelectSCITypeOptionsEdit { get; set; }
    public List<SelectOption> participationTypeOptions { get; set; }
    public List<SelectOption> attendeeTypeOptions { get; set; }
    public List<SelectOption> internalAttendeeTypeOptions { get; set; }
    public Map<String, String> validationErrors { get; set; }

    public Map<String, String> mapRecordTypes { get; set; }
    public Map<String, String> mapRecordTypesAndDescriptions { get; set; }

    public SCI_External_Attendee__c sciExternalAttendee { get; set; }
    public SCI_Zscaler_Attendee__c newAddMeAttendee { get; set; }
    public Contact newContact { get; set; }

    public String sciRecordType { get; set; }
    public String sciRecordTypeId { get; set; }
    public String retUrl { get; set; }
    public String pbSectionTitle { get; set; }
    public String pbSectionSubtitle { get; set; }
    public String internalAttendeesSearchText { get; set; }
    public String addInternalAttendeeMessage { get; set; }
    public String externalAttendeesSearchText { get; set; }
    public String externalAttendeesLeadSearchText { get; set; }
    public String addExternalAttendeeMessage { get; set; }
    public String popupMessage { get; set; }
    public String newAttendeeType { get; set; }
    public String newExtenalAttendeeName { get; set; }
    public String sciDateText { get; set; }
    public String newSCIDate { get; set; }
    public String wasPartnerPresentInMeeting { get; set; }
    public String newParticipationType { get; set; }
    public boolean isZsranddisplayzsrlink{ get; set; }
    
    public boolean isawanddisplayawlink{ get; set; }
    public boolean isFederal{ get; set; }

    public User sciOwner;
    /*
    Public properties - End
     */

    /**
     * Default constructor
     */
    public ManageSCIController() {

    }

    /**
     * Constructor
     * @param  controller Significant_Customer_Interaction__c
     */
    public ManageSCIController(ApexPages.StandardController controller) {
        foundExistingSCICount = 0;
        foundMatchingInternalUsersCount = 0;
        addMe = false;
        isPrimaryTopicRequired = false;
        isMethodOfInteractionRequired = false;
        isPartnerAccountRequired = false;
        isFederal = false;

        //Query all record types
        mapRecordTypes = new Map<String, String>();
        mapRecordTypesAndDescriptions = new Map<String, String>();
        lstSelectSCITypeOptions = new List<SelectOption>();
        lstSelectSCITypeOptionsEdit = new List<SelectOption>();
        lstSelectSCITypeOptions.add(new SelectOption('', '--Select--'));
        for (RecordType recordType : [SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE sObjectType = 'Significant_Customer_Interaction__c' AND IsActive = TRUE]) {
            if(recordType.DeveloperName != 'Very_Important_Conf_Call' && recordType.DeveloperName != 'F2F_Meeting' && recordType.DeveloperName != 'Online_Demo_Presentation' && recordType.DeveloperName != 'Very_Important_Email'){
                mapRecordTypes.put(recordType.Id, recordType.Name);
                mapRecordTypesAndDescriptions.put(recordType.Name, recordType.Description);
                if(recordType.DeveloperName != 'Upcoming_Meeting'){
                    lstSelectSCITypeOptions.add(new SelectOption(recordType.Id, recordType.Name));
                }
                lstSelectSCITypeOptionsEdit.add(new SelectOption(recordType.Id, recordType.Name));

                if ('regular meeting' == recordType.Name.toLowerCase()) {
                    regularMeetingRecordTypeId = recordType.Id;
                }
            }
        }

        participationTypeOptions = new List<SelectOption>();
        participationTypeOptions.add(new SelectOption('', '--Select--'));
        for (Schema.PicklistEntry picklistEntry : SCI_Zscaler_Attendee__c.Participation__c.getDescribe().getPicklistValues()) {
            participationTypeOptions.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
        }
        System.debug(participationTypeOptions);

        attendeeTypeOptions = new List<SelectOption>();
        for (Schema.PicklistEntry picklistEntry : SCI_External_Attendee__c.Type__c.getDescribe().getPicklistValues()) {
            attendeeTypeOptions.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
        }

        internalAttendeeTypeOptions = new List<SelectOption>();
        internalAttendeeTypeOptions.add(new SelectOption('Attendee', 'Attendee'));
        internalAttendeeTypeOptions.add(new SelectOption('Organizer', 'Organizer'));

        //Parse query string parameters
        String recordId;
        Map<String, String> queryParams = ApexPages.currentPage().getParameters();
        recordId = queryParams.get('id');
        retUrl = queryParams.get('retUrl');
        accountId = (!String.isBlank(queryParams.get('accountId')) ? queryParams.get('accountId') : null);
        opportunityId = (!String.isBlank(queryParams.get('opportunityId')) ? queryParams.get('opportunityId') : null);
        dealRegId = (!String.isBlank(queryParams.get('dealRegId')) ? queryParams.get('dealRegId') : null);
        leadId = (!String.isBlank(queryParams.get('leadId')) ? queryParams.get('leadId') : null);
        campaignId = (!String.isBlank(queryParams.get('campaignId')) ? queryParams.get('campaignId') : null);
        patchTeamId = (!String.isBlank(queryParams.get('patchTeamId')) ? queryParams.get('patchTeamId') : null);
        addMe = (!String.isBlank(queryParams.get('addMe')) ? (queryParams.get('addMe').equalsIgnoreCase('true') ? true : false ) : false);
        gotoStepNumber = (!String.isBlank(queryParams.get('step')) && queryParams.get('step').isNumeric() ? Integer.valueOf(queryParams.get('step')) : null);
        newExternalAttendeeId = (!String.isBlank(queryParams.get('newExternalAttendeeId')) ? queryParams.get('newExternalAttendeeId') : null);
        cloneFromId = (!String.isBlank(queryParams.get('cloneFromId')) ? queryParams.get('cloneFromId') : null);

        System.debug('>>>> addMe: ' + addMe);

        mapInternalAttendees = new Map<Id, ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper>();
        mapExternalAttendees = new Map<Id, ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper>();
        setModifiedExternalAttendees = new Set<Id>();
        navigationSteps = new NavigationStep();

        //Query everything about the SCI record if ID is present and valid
        //Otherwise, throw an error
        if(String.isNotBlank(recordId)) {
            pbSectionTitle = '';
            pbSectionSubtitle = 'Significant Customer Interaction Details';
            isEditMode = true;
            chooseSciTypeStep = false;
            sciDetailsStep = true;

            try {
                sciRecord = [SELECT Id, Name, RecordTypeId, RecordType.Name, Opportunity_Name__c, Opportunity_Name__r.Is_Federal_Opportunity_Sync__c,
                                    Interaction_With__c, Date__c, Next_Steps__c, Meeting_Notes__c,
                                    Area_of_Influence__c, Account_Name__c, Account_Name__r.Is_Federal_Account_Sync__c, Campaign__c, Lead__c, Deal_Reg__c,
                                    I_am_the__c, Participation__c, Primary_Topic_Covered__c, OwnerId, Account_Name__r.Name,
                                    Current_POC_Phase__c, Age_of_POC__c, POC_Start_Date__c, POC_Phases__c,
                                    POC_End_Date__c, Evaluation_Progress_Notes__c, Exec_Sponsor_Program__c, Method_of_Interaction__c,
                                    Partner_Present_In_The_Meeting__c, Partner_Account__c, ZSR_link__c, Architecture_Workshop_Link__c, Next_ZSR_Date__c, Next_Architecture_Workshop_Date__c,Zscaler_CXO_Advisor__c  
                               FROM Significant_Customer_Interaction__c
                              WHERE Id = :recordId LIMIT 1];
                if(sciRecord.RecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('QBR').getRecordTypeId()){
                    isZsranddisplayzsrlink = true; 
                    isawanddisplayawlink = false;
                }else if(sciRecord.RecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('Architecture Session').getRecordTypeId()){
                    isZsranddisplayzsrlink = false; 
                    isawanddisplayawlink = true;
                }else{
                    isZsranddisplayzsrlink = false; 
                    isawanddisplayawlink = false;
                }
                
                if(sciRecord.Opportunity_Name__r.Is_Federal_Opportunity_Sync__c || sciRecord.Account_Name__r.Is_Federal_Account_Sync__c){
                    isFederal = true;
                }
            } catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to find the SCI or invalid record ID.'));
                return;
            }

            sciRecordType = sciRecord.RecordType.Name;
            accountId = sciRecord.Account_Name__c;
            opportunityId = sciRecord.Opportunity_Name__c;
            leadId = sciRecord.Lead__c;
            dealRegId = sciRecord.Deal_Reg__c;
            campaignId = sciRecord.Campaign__c;
            inlinePoc = (sciRecordType.equalsIgnoreCase('poc inline')) ? true : false;

            navigationSteps.addStep(new NavigationStepItem(1, 'Select SCI Type', false, false));
            navigationSteps.addStep(new NavigationStepItem(2, 'Enter SCI Details', true, true));
            navigationSteps.addStep(new NavigationStepItem(3, 'Manage Zscaler Attendees', false, true));
            navigationSteps.addStep(new NavigationStepItem(4, 'Manage External Attendees', false, true));
            navigationSteps.setCurrentStep(2);
        } else if (String.isNotBlank(cloneFromId)){
            pbSectionTitle = '';
            pbSectionSubtitle = 'Significant Customer Interaction Details';
            isEditMode = true;
            chooseSciTypeStep = false;
            sciDetailsStep = true;

            try {
                sciRecord = [SELECT Id, Name, RecordTypeId, RecordType.Name, Opportunity_Name__c, Opportunity_Name__r.Is_Federal_Opportunity_Sync__c, Account_Name__r.Is_Federal_Account_Sync__c,
                                    Interaction_With__c, Date__c, Next_Steps__c, Meeting_Notes__c,
                                    Area_of_Influence__c, Account_Name__c, Campaign__c, Lead__c, Deal_Reg__c,
                                    I_am_the__c, Participation__c, Primary_Topic_Covered__c, OwnerId, Account_Name__r.Name,
                                    Current_POC_Phase__c, Age_of_POC__c, POC_Start_Date__c, POC_Phases__c,
                                    POC_End_Date__c, Evaluation_Progress_Notes__c, Exec_Sponsor_Program__c, Method_of_Interaction__c,
                                    Partner_Present_In_The_Meeting__c, Partner_Account__c, ZSR_link__c, Architecture_Workshop_Link__c, Next_ZSR_Date__c, Next_Architecture_Workshop_Date__c,Zscaler_CXO_Advisor__c  
                               FROM Significant_Customer_Interaction__c
                              WHERE Id = :cloneFromId LIMIT 1];
                if(sciRecord.RecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('QBR').getRecordTypeId()){
                    isZsranddisplayzsrlink = true; 
                    isawanddisplayawlink = false;
                }else if(sciRecord.RecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('Architecture Session').getRecordTypeId()){
                    isZsranddisplayzsrlink = false; 
                    isawanddisplayawlink = true;
                }else{
                    isZsranddisplayzsrlink = false; 
                    isawanddisplayawlink = false;
                }
                if(sciRecord.Opportunity_Name__r.Is_Federal_Opportunity_Sync__c || sciRecord.Account_Name__r.Is_Federal_Account_Sync__c){
                    isFederal = true;
                }
            } catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to find the SCI or invalid record ID.'));
                return;
            }

            sciRecord.Id = null;
            sciRecordType = sciRecord.RecordType.Name;
            accountId = sciRecord.Account_Name__c;
            opportunityId = sciRecord.Opportunity_Name__c;
            leadId = sciRecord.Lead__c;
            dealRegId = sciRecord.Deal_Reg__c;
            campaignId = sciRecord.Campaign__c;
            inlinePoc = (sciRecordType.equalsIgnoreCase('poc inline')) ? true : false;
            newSCIDate = Datetime.newInstance(sciRecord.Date__c.year(), sciRecord.Date__c.month(), sciRecord.Date__c.day()).format('MM/dd/yyyy');

            mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(cloneFromId, null);
            mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(cloneFromId, null);
            setModifiedExternalAttendees.addAll(mapExternalAttendees.keySet());

            navigationSteps.addStep(new NavigationStepItem(1, 'Select SCI Type', false, false));
            navigationSteps.addStep(new NavigationStepItem(2, 'Enter SCI Details', true, true));
            navigationSteps.addStep(new NavigationStepItem(3, 'Manage Zscaler Attendees', false, true));
            navigationSteps.addStep(new NavigationStepItem(4, 'Manage External Attendees', false, true));
            navigationSteps.setCurrentStep(2);
        } else {
            //if (null == accountId && null == opportunityId && null == leadId && null == dealRegId && null == campaignId) {
            //    isError = true;
            //    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,
            //        'Invalid input parent Id to associate with the SCI. Expecting at most one out of these - Account, Opportunity, Lead, Campaign, Deal Reg')
            //    );
            //    return;
            //}

            pbSectionTitle = 'New Significant Customer Interaction';
            pbSectionSubtitle = 'Select Significant Customer Interaction Type';
            isEditMode = false;
            chooseSciTypeStep = true;

            if (null != sciRecordTypeId) {
                sciRecordType = mapRecordTypes.get(sciRecordTypeId);
            } else {
                List<String> lstRecordTypeIds = new List<String>(mapRecordTypes.keySet());
                sciRecordTypeId = null;
                sciRecordType = mapRecordTypes.get(lstRecordTypeIds[0]);
            }

            System.debug('>>>> ' + sciRecordType);
            inlinePoc = (sciRecordType.equalsIgnoreCase('poc inline')) ? true : false;
            if(accountId != null){
                List<Account> acclst = [Select Id, Is_Federal_Account_Sync__c from Account where Id = :accountId];
                if(!acclst.isEmpty()){
                    isFederal = acclst[0].Is_Federal_Account_Sync__c;
                }
            }
            if(!isFederal && opportunityId != null){
                List<Opportunity> opplst = [Select Id, Is_Federal_Opportunity_Sync__c from Opportunity where Id = :opportunityId ];
                if(!opplst.isEmpty()){
                    isFederal = opplst[0].Is_Federal_Opportunity_Sync__c;
                }
            }

            sciRecord = new Significant_Customer_Interaction__c(RecordTypeId = sciRecordTypeId,
                                                                Account_Name__c = accountId,
                                                                Opportunity_Name__c = opportunityId,
                                                                Lead__c = leadId,
                                                                Deal_Reg__c = dealRegId,
                                                                Campaign__c = campaignId
                                                            );
            selectedSCIRecordTypeId = sciRecordTypeId;

            navigationSteps.addStep(new NavigationStepItem(1, 'Select SCI Type', true, true));
            navigationSteps.addStep(new NavigationStepItem(2, 'Enter SCI Details', false, false));
            navigationSteps.addStep(new NavigationStepItem(3, 'Manage Zscaler Attendees', false, false));
            navigationSteps.addStep(new NavigationStepItem(4, 'Manage External Attendees', false, false));
            navigationSteps.setCurrentStep(1);
        }
        if(isFederal){
            List<PermissionSetAssignment> psa = [Select Id, AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId = :UserInfo.getUserId() and PermissionSet.Name = 'SCI_Federal_Exception'];
            if(!psa.isEmpty()){
                isFederal = false;
            }
        }
        
        toggleRequiredFields();

        Id sciOwnerId;
        if (null != sciRecord.OwnerId) {
            sciOwnerId = sciRecord.OwnerId;
        } else {
            sciOwnerId = UserInfo.getUserId();
        }

        sciOwner = [SELECT Id, Name, Department FROM User WHERE Id = :sciOwnerId];

        if (true == addMe) {
            showAddedInternalAttendeeMessage = true;
            gotoStepNumber = 3;
            setCurrentStep();
        }
    }

    public PageReference pageLoad() {
        if (null != newExternalAttendeeId) {
            mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id);
            externalAttendeeToAdd = newExternalAttendeeId;
            addExternalAttendee();
            addNewExternalAttendee = true;
            newExtenalAttendeeName = mapExternalAttendees.get(newExternalAttendeeId).Name;

            try {
                if (null != sciRecord
                    && null != sciRecord.Id) {
                        if(newExternalAttendeeId != null && newExternalAttendeeId.getSobjectType() == Schema.Contact.SObjectType){
                            sciExternalAttendee = new SCI_External_Attendee__c(
                                                Attendee_Name__c = newExternalAttendeeId,
                                                Significant_Customer_Interaction__c = sciRecord.Id,
                                                Type__c = mapExternalAttendees.get(newExternalAttendeeId).AttendeeType
                                            );
                        }else if(newExternalAttendeeId != null && newExternalAttendeeId.getSobjectType() == Schema.Lead.SObjectType){
                            sciExternalAttendee = new SCI_External_Attendee__c(
                                                Attendee_Name_Lead__c = newExternalAttendeeId,
                                                Significant_Customer_Interaction__c = sciRecord.Id,
                                                Type__c = mapExternalAttendees.get(newExternalAttendeeId).AttendeeType
                                            );
                        }
                    insert sciExternalAttendee;
                }
            } catch (Exception ex) {
                isError = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to add the new external attendee'));
                return null;
            }

            validateExternalAttendees();
        } else {
            addNewExternalAttendee = false;
        }

        if (null != gotoStepNumber
            && gotoStepNumber >= 2 && gotoStepNumber <=4) {
            setCurrentStep();
        }

        return null;
    }

    /*
    Methods common to all steps - Start
     */

    /**
     * Method to validate the internal and external attendees list
     */
    public PageReference validate() {
        validateInternalAttendees();
        validateExternalAttendees();

        return null;
    }

    /**
     * Helper method to validate the internal attandees
     */
    public void validateInternalAttendees() {
        Boolean organizerFound = false;
        Boolean participationTypeInvalid = false;

        if (null == validationErrors) {
            validationErrors = new Map<String, String>();
        }

        if (null != sciRecord && null != sciRecord.Id
            && null != sciOwner && null != sciOwner.Id
            && (null == mapInternalAttendees
                || mapInternalAttendees.isEmpty())) {
            mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id);
        }

        if (null != mapInternalAttendees
            && !mapInternalAttendees.isEmpty()) {
            for (String internalAttendee : mapInternalAttendees.keySet()) {
                System.debug(mapInternalAttendees.get(internalAttendee));
                System.debug(mapInternalAttendees.get(internalAttendee).isOrganizer);
                if (mapInternalAttendees.get(internalAttendee).participation == null
                    || !(mapInternalAttendees.get(internalAttendee).participation.equalsIgnoreCase('in person')
                        || mapInternalAttendees.get(internalAttendee).participation.equalsIgnoreCase('remote'))) {
                    System.debug('>>>> after participant check');
                    participationTypeInvalid = true;
                }

                if (mapInternalAttendees.get(internalAttendee).isOrganizer.equalsIgnoreCase('organizer')) {
                    organizerFound = true;
                }
                System.debug('>>>> before participant check');
            }
        }

        if (!organizerFound) {
            validationErrors.put('NoOrganizerFound', 'At most one internal attendee must be added as an organizer');
        }

        if (participationTypeInvalid) {
            validationErrors.put('ParticipationTypeInvalid', 'Participation field has to be set for each attendee');
        }

        if (organizerFound || !participationTypeInvalid) {
            if (organizerFound && validationErrors.containsKey('NoOrganizerFound')) {
                validationErrors.remove('NoOrganizerFound');
            }

            if (!participationTypeInvalid && validationErrors.containsKey('ParticipationTypeInvalid')) {
                validationErrors.remove('ParticipationTypeInvalid');
            }
        }

        System.debug('>>In: ' + mapInternalAttendees);
        System.debug('>>In: ' + organizerFound);
        System.debug('>>In: ' + validationErrors);
    }

    /**
     * Helper method to validate external attendees list
     */
    public void validateExternalAttendees() {
        if (null == validationErrors) {
            validationErrors = new Map<String, String>();
        }

        //If the primary parent record is a Lead, then external attendees is not required
        if (null != sciRecord.Lead__c
            && null == sciRecord.Account_Name__c
            && null == sciRecord.Opportunity_Name__c
            && null == sciRecord.Deal_Reg__c) {
            return;
        }

        if (null != sciRecord && null != sciRecord.Id
            && null != sciOwner && null != sciOwner.Id
            && (null == mapExternalAttendees
                || mapExternalAttendees.isEmpty())
            && skipExternalAttendeesRefresh != true) {
            mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id);
        }

        if (null == mapExternalAttendees
            || mapExternalAttendees.isEmpty()) {
            validationErrors.put('ExternalAttendeesNotFound', 'At least one external attendee must be added');
        } else {
            if (validationErrors.containsKey('ExternalAttendeesNotFound')) {
                validationErrors.remove('ExternalAttendeesNotFound');
            }
        }

        System.debug('>>>EX: ' + validationErrors);
    }

    /*
    Methods common to all steps - End
     */

    /*
    Page Block Button Actions - Start
     */

    /**
     * Action method to Save changes to SCI (upsert)
     * @return PageReference
     */
    public PageReference save() {
        List<SCI_Zscaler_Attendee__c> lstInternalAttendeesToUpsert = new List<SCI_Zscaler_Attendee__c>();
        List<SCI_External_Attendee__c> lstExternalAttendeesToUpsert = new List<SCI_External_Attendee__c>();

        //Validations
        if (null != validationErrors
            && !validationErrors.isEmpty()) {
            validationErrors.clear();
        }

        validate();
        if (validationErrors.size() > 0) {
            return null;
        }

        Savepoint sp = Database.setSavepoint();

        //Upsert the SCI record
        try {
            Set<String> engagementWith = new Set<String>();
            for (Contact externalAttendee : [SELECT Id, Name, AccountId, Head_Of_It__c, Head_of_networking__c, Service_Owner__c, Cloud_Architect__c, Head_of_Security__c,
                                                    Budget_Authority__c, Procurement_Contact__c
                                               FROM Contact
                                              WHERE Id IN :mapExternalAttendees.keySet()]) {

                // if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && externalAttendee.Service_Owner__c)
                //     || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && mapExternalAttendees.get(externalAttendee.Id).ServiceOwner)) {
                //     engagementWith.add('Service Owner;');
                // }
                //
                // if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && externalAttendee.Cloud_Architect__c)
                //     || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && mapExternalAttendees.get(externalAttendee.Id).SolutionArchitect)) {
                //     engagementWith.add('Solution Architect;');
                // }

                if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && externalAttendee.Head_Of_It__c)
                    || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && mapExternalAttendees.get(externalAttendee.Id).HeadOfIT)) {
                    engagementWith.add('Head of IT;');
                }
                if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && externalAttendee.Head_of_networking__c)
                    || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && mapExternalAttendees.get(externalAttendee.Id).HeadOfNetworking)) {
                    engagementWith.add('Head of Networking;');
                }
                if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && externalAttendee.Head_of_Security__c)
                    || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                        && mapExternalAttendees.get(externalAttendee.Id).HeadOfSecurity)) {
                    engagementWith.add('Head of Security;');
                }
                // if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && externalAttendee.Budget_Authority__c)
                //     || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && mapExternalAttendees.get(externalAttendee.Id).BudgetAuthority)) {
                //     engagementWith.add('Budget Authority;');
                // }
                // if ((setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && externalAttendee.Procurement_Contact__c)
                //     || (!setModifiedExternalAttendees.contains(externalAttendee.Id)
                //         && mapExternalAttendees.get(externalAttendee.Id).ProcurementContact)) {
                //     engagementWith.add('Procurement Contact;');
                // }
            }

            String engagementWithList = '';
            for (String engagementWithType : engagementWith) {
                engagementWithList += engagementWithType;
            }

            sciRecord.Area_of_Influence__c = engagementWithList;
            sciRecord.I_am_the__c = '';
            sciRecord.Participation__c = '';

            if (String.isNotBlank(newSCIDate)) {
                List<String> lstDateParts = newSCIDate.split('/');
                sciRecord.Date__c = Date.newInstance(Integer.valueOf(lstDateParts[2]), Integer.valueOf(lstDateParts[0]), Integer.valueOf(lstDateParts[1]));
            }

            TriggerUtility.manageZscalerAttendeeExecuted();

            upsert sciRecord;

            //To prevent trigger from clearing out the Area_of_Influence__c field.
            TriggerUtility.udpateSCIforEngagementExecuted();

            //Process the Zscaler attendees, delete all existing
            if (null != mapInternalAttendees
                && !mapInternalAttendees.isEmpty()) {
                List<SCI_Zscaler_Attendee__c> lstZscalerAttendeesToDelete = new List<SCI_Zscaler_Attendee__c>();
                for (ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper attendee : ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id).values()) {
                    if (null != attendee.Id) {
                        lstZscalerAttendeesToDelete.add(new SCI_Zscaler_Attendee__c(Id=attendee.Id));
                    }
                }

                System.debug('>>>> ' + ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id).values());
                delete lstZscalerAttendeesToDelete;

                for (ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper newAttendee : mapInternalAttendees.values()) {
                    lstInternalAttendeesToUpsert.add(new SCI_Zscaler_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciRecord.Id,
                                                    Attendee_Name__c = newAttendee.userId,
                                                    Organizer__c = (newAttendee.isOrganizer.equalsIgnoreCase('organizer') ? true : false),
                                                    Participation__c = newAttendee.participation
                                                ));
                }

                System.debug('>>>> ' + lstZscalerAttendeesToDelete);
                System.debug('>>>> ' + mapInternalAttendees.values());
                System.debug('>>>> ' + lstInternalAttendeesToUpsert);

                insert lstInternalAttendeesToUpsert;
            }

            if (null != lstExternalAttendeesToBind) {
                List<SCI_External_Attendee__c> lstExternalAttendeesToDelete = new List<SCI_External_Attendee__c>();
                for (ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper attendee : ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id).values()) {
                    if (null != attendee.Id) {
                        lstExternalAttendeesToDelete.add(new SCI_External_Attendee__c(Id=attendee.Id));
                    }
                }

                delete lstExternalAttendeesToDelete;

                for (ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper newAttendee : lstExternalAttendeesToBind) {
                    if((Id)newAttendee.ContactId != null && ((Id)newAttendee.ContactId).getSobjectType() == Schema.Contact.SObjectType){
                        lstExternalAttendeesToUpsert.add(new SCI_External_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciRecord.Id,
                                                    Attendee_Name__c = newAttendee.ContactId,
                                                    Type__c = newAttendee.AttendeeType,
                                                    Head_Of_IT__c = newAttendee.HeadOfIT,
                                                    Head_Of_Networking__c = newAttendee.HeadOfNetworking,
                                                    Head_Of_Security__c = newAttendee.HeadOfSecurity,
                                                    Budget_Authority__c = newAttendee.BudgetAuthority,
                                                    Procurement_Contact__c = newAttendee.ProcurementContact,
                                                    Solution_Architect__c = newAttendee.SolutionArchitect,
                                                    Service_Owner__c = newAttendee.ServiceOwner,
                                                    Date_Created__c = newAttendee.DateCreated
                                                ));
                    }else if((Id)newAttendee.ContactId != null && ((Id)newAttendee.ContactId).getSobjectType() == Schema.Lead.SObjectType){
                        lstExternalAttendeesToUpsert.add(new SCI_External_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciRecord.Id,
                                                    Attendee_Name_Lead__c = newAttendee.ContactId,
                                                    Type__c = newAttendee.AttendeeType,
                                                    Date_Created__c = newAttendee.DateCreated
                                                ));
                    }
                }

                insert lstExternalAttendeesToUpsert;
            }

            mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id);
            mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id);
        } catch (Exception ex) {
            System.debug('>>>> ' + ex.getMessage() + ' ' + ex.getStackTraceString());
            String err = 'Unable to save the SCI. ' + ex.getMessage();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to save the SCI. Please contact the administrator.'));
            //validationErrors.put('ExceptionOccurredAtSave', 'Unable to save the SCI. Please contact the administrator.');
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, err));
            validationErrors.put('ExceptionOccurredAtSave', err);
            Database.rollback(sp);
            return null;
        }

        PageReference sciDetailPage = new PageReference('/' + sciRecord.Id);

        return sciDetailPage;
    }

    /**
     * Action method to handle cancel button click
     */
    public PageReference cancel() {
        try {
            if (null != newContact
                && null != newContact.Id) {
                delete newContact;
            }

            if (null != sciExternalAttendee
                && null != sciExternalAttendee.Id) {
                delete sciExternalAttendee;
            }
        } catch (Exception ex) {
            System.debug('>>>> ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }

        PageReference reference;
        if (isEditMode
            && null != sciRecord.Id) {
            reference = new PageReference('/' + sciRecord.Id);
        } else {
            if (null != retUrl
                && '' != retUrl.trim()) {
                reference = new PageReference(retUrl);
                reference.setRedirect(true);
            } else {
                reference = new PageReference('/home/home.jsp');
            }
        }

        return reference;
    }

    /**
     * Set the current step in the wizard
     */
    public PageReference setCurrentStep() {
        if (!navigationSteps.isStepEnabled(gotoStepNumber)) {
            return null;
        }

        Integer currentStepNumber = navigationSteps.currentStep;

        System.debug('>>>> currentStepNumber: ' + currentStepNumber);
        if (3 == currentStepNumber) {
            validateInternalAttendees();
            if (!validationErrors.isEmpty()) {
                return null;
            }
        } else if (4 == currentStepNumber) {
            validateExternalAttendees();
            if (!validationErrors.isEmpty()) {
                return null;
            }
        }

        showAddedInternalAttendeeMessage = false;

        if (1 == gotoStepNumber) {
            chooseSciTypeStep = true;
            sciDetailsStep = false;
            internalAttendeesStep = false;
            externalAttendeesStep = false;
            pbSectionTitle = 'Significant Customer Interaction';
            pbSectionSubtitle = 'Select Significant Customer Interaction Type';
        } else if (2 == gotoStepNumber) {
            chooseSciTypeStep = false;
            sciDetailsStep = true;
            internalAttendeesStep = false;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Significant Customer Interaction Details';
            pbSectionTitle = '';
        } else if (3 == gotoStepNumber) {
            chooseSciTypeStep = false;
            sciDetailsStep = false;
            internalAttendeesStep = true;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Zscaler Attendees';
            pbSectionTitle = '';

            if (null == mapInternalAttendees || mapInternalAttendees.isEmpty()) {
                mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id);
            }
        } else if (4 == gotoStepNumber) {
            chooseSciTypeStep = false;
            sciDetailsStep = false;
            internalAttendeesStep = false;
            externalAttendeesStep = true;
            pbSectionSubtitle = 'External Attendees';
            pbSectionTitle = '';

            if (null == mapExternalAttendees || mapExternalAttendees.isEmpty()) {
                mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id);
            }
        }

        navigationSteps.setCurrentStep(gotoStepNumber);
        return null;
    }

    /**
     * Action method to handle Next button click
     */
    public PageReference goNext() {
        System.debug('>>>> next buttom clicked');
        showAddedInternalAttendeeMessage = false;
        System.debug('>>> next ' + chooseSciTypeStep);
        if (true == chooseSciTypeStep) {
            chooseSciTypeStep = false;
            sciDetailsStep = true;
            internalAttendeesStep = false;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Significant Customer Interaction Details';
            pbSectionTitle = '';
            navigationSteps.setCurrentStep(2);
        } else if (true == sciDetailsStep) {
            chooseSciTypeStep = false;
            sciDetailsStep = false;
            internalAttendeesStep = true;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Zscaler Attendees';
            pbSectionTitle = '';
            navigationSteps.setCurrentStep(3);

            if (null == mapInternalAttendees || mapInternalAttendees.isEmpty()) {
                mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id);
            }
        } else if (true == internalAttendeesStep) {
            validateInternalAttendees();
            if (!validationErrors.isEmpty()) {
                return null;
            }

            chooseSciTypeStep = false;
            sciDetailsStep = false;
            internalAttendeesStep = false;
            externalAttendeesStep = true;
            pbSectionSubtitle = 'External Attendees';
            pbSectionTitle = '';
            navigationSteps.setCurrentStep(4);

            if (null == mapExternalAttendees || mapExternalAttendees.isEmpty()) {
                mapExternalAttendees = ManageSCIExternalAttendeeService.fetchExternalAttendees(sciRecord.Id, sciOwner.Id);
            }
        }

        return null;
    }

    /**
     * Action method to handle Previous button click
     */
    public PageReference goPrevious() {
        showAddedInternalAttendeeMessage = false;
        System.debug('>>> prev ' + chooseSciTypeStep);
        if (true == sciDetailsStep) {
            chooseSciTypeStep = true;
            sciDetailsStep = false;
            internalAttendeesStep = false;
            externalAttendeesStep = false;
            pbSectionTitle = 'Significant Customer Interaction';
            pbSectionSubtitle = 'Select Significant Customer Interaction Type';
            navigationSteps.setCurrentStep(1);
        } else if (true == internalAttendeesStep) {
            validateInternalAttendees();
            if (!validationErrors.isEmpty()) {
                return null;
            }

            chooseSciTypeStep = false;
            sciDetailsStep = true;
            internalAttendeesStep = false;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Significant Customer Interaction Details';
            pbSectionTitle = '';
            navigationSteps.setCurrentStep(2);
        } else if (true == externalAttendeesStep) {
            validateExternalAttendees();
            if (!validationErrors.isEmpty()) {
                return null;
            }

            chooseSciTypeStep = false;
            sciDetailsStep = false;
            internalAttendeesStep = true;
            externalAttendeesStep = false;
            pbSectionSubtitle = 'Zscaler Attendees';
            pbSectionTitle = '';
            navigationSteps.setCurrentStep(3);

            if (null == mapInternalAttendees || mapInternalAttendees.isEmpty()) {
                mapInternalAttendees = ManageSCIInternalAttendeeService.fetchInternalAttendees(sciRecord.Id, sciOwner.Id);
            }
        }

        return null;
    }

    /*
    Page Block Button Actions - End
     */

    /*
    Methods for Step 1 - Existing SCIs records - Start
     */

    /**
     * Method to return the SCI date string in MM/dd/yyyy format
     * @return Returns SCI date in MM/dd/yyyy format.
     */
    public String getSCIDate() {
        Datetime returnDate = Datetime.newInstance(sciRecord.Date__c.year(), sciRecord.Date__c.month(), sciRecord.Date__c.day());
        return returnDate.format('MM/dd/yyyy');
    }

    /**
     * Action method to query existing SCI details
     */
    public PageReference fetchExistingSCIs() {
        foundExistingSCICount = 0;
        Datetime sciDate, startDate, endDate;

        //Parse the date
        List<String> dateParts = sciDateText.split('/');
        if (null != dateParts
            && dateParts.size() == 3) {
            sciDate = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
        } else {
            sciDate = Datetime.now();
        }

        sciRecord.Date__c = sciDate.date();
        startDate = sciDate.addDays(-1);
        endDate = sciDate.addDays(1);

        lstExistingSCIs = ManageSCIService.getExistingSCIs(accountId, opportunityId, leadId, dealRegId, campaignId, sciRecordTypeId, startDate, endDate);
        foundExistingSCICount = (null != lstExistingSCIs) ? lstExistingSCIs.size() : 0;

        if (0 == foundExistingSCICount) {
            addNewSCI();
        }

        return null;
    }

    /**
     * Action method to create a new SCI - New SCI button
     */
    public PageReference addNewSCI() {
        navigationSteps.toggleEnableSteps(new Set<Integer> { 2, 3, 4 });
        gotoStepNumber = 2;
        setCurrentStep();

        if (null != sciRecordTypeId) {
            sciRecordType = mapRecordTypes.get(sciRecordTypeId);
        } else {
            List<String> lstRecordTypeIds = new List<String>(mapRecordTypes.keySet());
            sciRecordTypeId = lstRecordTypeIds[0];
            sciRecordType = mapRecordTypes.get(lstRecordTypeIds[0]);
        }
        
        if(sciRecordTypeId != null && sciRecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('QBR').getRecordTypeId()){
            isZsranddisplayzsrlink = true; 
            isawanddisplayawlink = false;
        }else if(sciRecordTypeId != null && sciRecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('Architecture Session').getRecordTypeId()){
            isZsranddisplayzsrlink = false; 
            isawanddisplayawlink = true;
        }else if(sciRecordTypeId != null){
            isZsranddisplayzsrlink = false; 
            isawanddisplayawlink = false;
        }
        
        inlinePoc = (sciRecordType.equalsIgnoreCase('poc inline')) ? true : false;

        sciRecord = new Significant_Customer_Interaction__c(RecordTypeId = sciRecordTypeId,
                                                            Date__c = sciRecord.Date__c,
                                                            Account_Name__c = accountId,
                                                            Opportunity_Name__c = opportunityId,
                                                            Lead__c = leadId,
                                                            Deal_Reg__c = dealRegId,
                                                            Campaign__c = campaignId
                                                        );

        //Add the SCI creator as the organizer
        if (null == mapInternalAttendees) {
            mapInternalAttendees = new Map<Id, ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper>();
        }

        internalAttendeeToAdd = sciOwner.Id;
        addInternalAttendee();

        if (mapInternalAttendees.containsKey(sciOwner.Id)) {
            mapInternalAttendees.get(sciOwner.Id).isOrganizer = 'Organizer';
        }
        System.debug('After adding owner: ' + mapInternalAttendees);
        //To make sure the internal attendees validation error messages are cleared
        validateInternalAttendees();

        //Cleanup existing SCIs list
        lstExistingSCIs = null;

        return null;
    }

    /**
     * Method to handle Add Me click in existing SCIs list
     */
    public PageReference handleAddMeClick() {
        System.debug('>>>> add me to sci id:' + addMeToSCIId);
        try {

            User attendee = [SELECT Id, Name, Department FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            Integer count = 0;
            count = Database.countQuery('SELECT Count() FROM SCI_Zscaler_Attendee__c WHERE Significant_Customer_Interaction__c = \'' + addMeToSCIId + '\' AND Attendee_Name__c = \'' + attendee.Id + '\' LIMIT 1');
            System.debug('>>>> ' + count);
            if (count == 0) {
                addMeToSCI = [SELECT Id, Account_Name__c, Opportunity_Name__c, Deal_Reg__c, Lead__c, Campaign__c,Zscaler_CXO_Advisor__c
                                FROM Significant_Customer_Interaction__c
                               WHERE Id = :addMeToSCIId LIMIT 1];
                System.debug(addMeToSCI);
                newAddMeAttendee = new SCI_Zscaler_Attendee__c(
                                Significant_Customer_Interaction__c = addMeToSCIId,
                                Attendee_Name__c = attendee.Id,
                                Organizer__c = false,
                                Participation__c = ''
                            );

                insert newAddMeAttendee;
                System.debug('>>>> newAttendee: ' + newAddMeAttendee);
                if (null == mapInternalAttendees) {
                    mapInternalAttendees = new Map<Id, ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper>();
                }

                mapInternalAttendees.put(attendee.Id, new ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper(
                                                        newAddMeAttendee.Id,
                                                        attendee.Name,
                                                        attendee.Id,
                                                        attendee.Department,
                                                        'Attendee',
                                                        '',
                                                        false
                                                    ));
                System.debug('>>>> JSON.serialize(mapInternalAttendees):'  + JSON.serialize(mapInternalAttendees));
                String url = '/apex/ManageSCI?id=' + addMeToSCI.Id + '&edit=true&retUrl=' + retUrl + '&accountId='
                            + addMeToSCI.Account_name__c + '&opportunityId=' + addMeToSCI.Opportunity_Name__c
                            + '&dealRegId=' + addMeToSCI.Deal_Reg__c + '&leadId=' + addMeToSCI.Lead__c
                            + '&campaignId=' + addMeToSCI.Campaign__c + '&patchTeamId=' + patchTeamId + '&addMe=true';
                url = url.replaceAll('null', '');
                PageReference redirectTo = new PageReference(url);
                redirectTo.setRedirect(true);
                return redirectTo;
            }

        } catch(Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            isError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,
                'Error occurred while adding internal attendee record.')
            );
        }

        return null;
    }

    /**
     * @description Method to rerender specific portions of the page
     * @return Null
     **/
    public PageReference toggleRequiredFields() {
        System.debug('>>>> regularMeetingRecordTypeId: ' + regularMeetingRecordTypeId);
        System.debug('>>>> isPrimaryTopicRequired: ' + isPrimaryTopicRequired);
        if (regularMeetingRecordTypeId == selectedSCIRecordTypeId) {
            isPrimaryTopicRequired = true;
            isMethodOfInteractionRequired = true;
        } else {
            isPrimaryTopicRequired = false;
            isMethodOfInteractionRequired = false;
        }
        
       if(selectedSCIRecordTypeId != null && selectedSCIRecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('QBR').getRecordTypeId()){
            isZsranddisplayzsrlink = true; 
            isawanddisplayawlink = false;
        }else if(selectedSCIRecordTypeId != null && selectedSCIRecordTypeId == Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('Architecture Session').getRecordTypeId()){
            isZsranddisplayzsrlink = false; 
            isawanddisplayawlink = true;
        }else if(selectedSCIRecordTypeId != null){
            isZsranddisplayzsrlink = false; 
            isawanddisplayawlink = false;
        }
        return null;
    }

    /**
     * @description Method to make Partner Account required or not
     * @return Null
     */
    public PageReference togglePartnerAccountField() {
        System.debug('>>>> wasPartnerPresentInMeeting: ' + wasPartnerPresentInMeeting);
        if (null != wasPartnerPresentInMeeting
            && 'yes' == wasPartnerPresentInMeeting.toLowerCase()) {
            isPartnerAccountRequired = true;
        } else {
            isPartnerAccountRequired = false;
        }

        return null;
    }

    /*
    Methods for Step 1 - Existing SCIs records - End
     */

    /*
    Methods for Step 3 - Manage Internal Attendees - Start
     */

    /**
     * Property method to get the list of internal attendees to VF
     * @return List of Internal Attendees Wrapper
     */
    public List<ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper> getInternalAttendees() {
        lstInternalAttendeesToBind = new List<ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper>();

        lstInternalAttendeesToBind.addAll(mapInternalAttendees.values());

        return lstInternalAttendeesToBind;
    }

    /**
     * Property method to return the list of internal users who were added to existing SCIs
     * @return List of matching users
     */
    public List<User> getSuggestedInternalUsers() {
        foundMatchingInternalUsersCount = 0;

        mapMatchingInternalUsers = ManageSCIInternalAttendeeService.getInternalAttendeesToSuggest(patchTeamId, mapInternalAttendees.keySet());

        if (null != mapInternalAttendees
            && !mapInternalAttendees.containsKey(sciOwner.Id)) {
            mapMatchingInternalUsers.put(sciOwner.Id, sciOwner);
        }

        foundMatchingInternalUsersCount = mapMatchingInternalUsers.size();
        System.debug('>>>> mapMatchingInternalUsers: ' + mapMatchingInternalUsers);

        return mapMatchingInternalUsers.values();
    }

    /**
     * Remote action to handle autocomplete search request for internal attendees
     * @param  searchTerm Search string
     * @return            List of users
     */
    @RemoteAction
    public static List<User> searchInternalUsers(String searchTerm) {
        return ManageSCIInternalAttendeeService.searchInternalUsers(searchTerm);
    }

    /**
     * Adds an user to the internal attendee list
     */
    public PageReference addInternalAttendee() {
        System.debug('>>>>> ' + internalAttendeeToAdd);
        System.debug('>>>>> ' + mapInternalAttendees);
        if (mapInternalAttendees.containsKey(internalAttendeeToAdd)) {
            addInternalAttendeeMessage = 'Attendee has been added already.';
            return null;
        }

        addInternalAttendeeMessage = '';

        User newInternalAttendee = new User();
        try {
            if (null != mapMatchingInternalUsers
                && mapMatchingInternalUsers.containsKey(internalAttendeeToAdd)) {
                newInternalAttendee = mapMatchingInternalUsers.get(internalAttendeeToAdd);
            } else {
                newInternalAttendee = [SELECT Id, Name, Department FROM User WHERE Id = :internalAttendeeToAdd LIMIT 1];
            }
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred while adding internal attendee.'));
            return null;
        }

        mapInternalAttendees.put(newInternalAttendee.Id, new ManageSCIInternalAttendeeService.SCIInternalAttendeeWrapper(
                                    null,
                                    newInternalAttendee.Name,
                                    newInternalAttendee.Id,
                                    newInternalAttendee.Department,
                                    'Attendee',
                                    '',
                                    false
                                ));

        if (null != mapMatchingInternalUsers
            && mapMatchingInternalUsers.containsKey(newInternalAttendee.Id)) {
            mapMatchingInternalUsers.remove(newInternalAttendee.Id);
            foundMatchingInternalUsersCount -= 1;
        }

        validateInternalAttendees();

        return null;
    }

    /**
     * Action method to remove an user from internal attendees list
     */
    public PageReference removeInternalAttendee() {
        System.debug('>>>> : : ' + internalAttendeeToRemove);
        System.debug('>>>> : : ' + mapInternalAttendees);
        mapInternalAttendees.remove(internalAttendeeToRemove);

        User removedAttendee = [SELECT Id, Name, Department FROM User WHERE Id = :internalAttendeeToRemove LIMIT 1];
        mapMatchingInternalUsers.put(removedAttendee.Id, removedAttendee);

        validateInternalAttendees();

        return null;
    }

    /**
     * Method to handle Organizer field value change in Internal attendees list
     */
    public PageReference handleOrganizerChange() {
        if (null != organizerId
            && null != newAttendeeType
            && newAttendeeType.equalsIgnoreCase('organizer')
            && mapInternalAttendees.containsKey(organizerId)) {
            for (String key : mapInternalAttendees.keySet()) {
                if (organizerId == key) {
                    mapInternalAttendees.get(key).isOrganizer = 'Organizer';
                } else {
                    mapInternalAttendees.get(key).isOrganizer = 'Attendee';
                }
            }
        }

        validateInternalAttendees();

        return null;
    }

    public PageReference handleParticipationChange() {
        Boolean hasInPersonParticipant = false;
        if (null != participantId
            && null != newParticipationType
            && mapInternalAttendees.containsKey(participantId)) {
            mapInternalAttendees.get(participantId).participation = newParticipationType;

            for (String key : mapInternalAttendees.keySet()) {
                if (null != mapInternalAttendees.get(key).participation
                    && mapInternalAttendees.get(key).participation.equalsIgnoreCase('in person')) {
                    hasInPersonParticipant = true;
                }
            }

            if (hasInPersonParticipant) {
                sciRecord.Method_of_Interaction__c = 'F2F';
            } else {
                sciRecord.Method_of_Interaction__c = 'Webex/Call';
            }
        }

        validateInternalAttendees();

        return null;
    }

    /*
    Methods for Step 3 - Manage Internal Attendees - End
     */

    /*
    Methods for Step 4 - Manage External Attendees - Start
     */

    /**
     * Property method to get the list of external attendees to VF
     * @return List of External Attendees Wrapper
     */
    public List<ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper> getExternalAttendees() {
        lstExternalAttendeesToBind = new List<ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper>();

        lstExternalAttendeesToBind.addAll(mapExternalAttendees.values());

        return lstExternalAttendeesToBind;
    }


    /**
     * Returns the list of contacts belonging to the SCI account
     * @return List of Contacts
     */
    public List<Contact> getSuggestedExternalUsers() {
        foundMatchingExternalUsersCount = 0;
        System.debug('>>>>> ' + accountId);
        mapMatchingExternalUsers = ManageSCIExternalAttendeeService.getExternalContactsToSuggest(sciRecord.Account_Name__c, mapExternalAttendees.keySet());
        foundMatchingExternalUsersCount = mapMatchingExternalUsers.size();
        System.debug('>>>> mapMatchingExternalUsers: ' + mapMatchingExternalUsers);

        return mapMatchingExternalUsers.values();
    }

    /**
     * Remote action to handle autocomplete search request for external contacts
     * @param  searchTerm Search string
     * @return            List of contacts
     */
    @RemoteAction
    public static List<Contact> searchExternalUsers(String searchTerm) {
        return ManageSCIExternalAttendeeService.searchExternalUsers(searchTerm);
    }
    
    @RemoteAction
    public static List<Lead> searchLeads(String searchTermLead) {
        return ManageSCIExternalAttendeeService.searchLeads(searchTermLead);
    }

    /**
     * Adds a particular attendee from the Matching Internal Attendee
     */
    public PageReference addExternalAttendee() {
        System.debug('>>>>> ' + externalAttendeeToAdd + '; Owner: ' + sciOwner.Id);
        if (mapExternalAttendees.containsKey(externalAttendeeToAdd)) {
            addExternalAttendeeMessage = 'Attendee has been added already.';
            return null;
        }
        
        if(externalAttendeeToAdd.getSobjectType() == Schema.Contact.SObjectType){
            Contact newExternalAttendee = new Contact();
            try {
                if (null != mapMatchingExternalUsers
                    && mapMatchingExternalUsers.containsKey(externalAttendeeToAdd)) {
                    newExternalAttendee = mapMatchingExternalUsers.get(externalAttendeeToAdd);
                } else {
                    newExternalAttendee = [SELECT Id, Name, AccountId, Account.Name, Account.Type, Email, Phone, Title,
                                                  Head_Of_It__c, Head_of_Security__c, Head_of_networking__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c
                                             FROM Contact WHERE Id = :externalAttendeeToAdd LIMIT 1];
                }
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred while adding external attendee.'));
                return null;
            }
        

        mapExternalAttendees.put(newExternalAttendee.Id, new ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper(
                                                            null,
                                                            newExternalAttendee.Id,
                                                            newExternalAttendee.Name,
                                                            newExternalAttendee.AccountId,
                                                            newExternalAttendee.Account.Name,
                                                            newExternalAttendee.Email,
                                                            newExternalAttendee.Phone,
                                                            newExternalAttendee.Title,
                                                            ((null != newExternalAttendee.Account
                                                                && null != newExternalAttendee.Account.Type
                                                                && newExternalAttendee.Account.Type.toLowerCase().contains('partner')) ? 'Partner' : 'Customer'
                                                            ),
                                                            newExternalAttendee.Head_Of_IT__c,
                                                            newExternalAttendee.Head_Of_Networking__c,
                                                            newExternalAttendee.Head_Of_Security__c,
                                                            newExternalAttendee.Budget_Authority__c,
                                                            newExternalAttendee.Procurement_Contact__c,
                                                            newExternalAttendee.Service_Owner__c,
                                                            newExternalAttendee.Cloud_Architect__c,
                                                            null
                                                        ));
                                                        
            setModifiedExternalAttendees.add(newExternalAttendee.Id);                                       
        }else if(externalAttendeeToAdd.getSobjectType() == Schema.Lead.SObjectType){
            Lead newExternalAttendee = new Lead();
            try {
                newExternalAttendee = [SELECT Id, Name, Email, Phone, Title 
                                         FROM Lead WHERE Id = :externalAttendeeToAdd LIMIT 1];
                
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error occurred while adding external attendee.'));
                return null;
            }
        

            mapExternalAttendees.put(newExternalAttendee.Id, new ManageSCIExternalAttendeeService.SCIExternalAttendeeWrapper(
                                                            null,
                                                            newExternalAttendee.Id,
                                                            newExternalAttendee.Name,
                                                            null,
                                                            '',
                                                            newExternalAttendee.Email,
                                                            newExternalAttendee.Phone,
                                                            newExternalAttendee.Title,
                                                            '',
                                                            false,
                                                            false,
                                                            false,
                                                            false,
                                                            false,
                                                            false,
                                                            false,
                                                            null
                                                        ));
                                                        
            setModifiedExternalAttendees.add(newExternalAttendee.Id);
        }

        validateExternalAttendees();
        return null;
    }

    /**
     * Action method to remove an user from internal attendees list
     */
    public PageReference removeExternalAttendee() {
        System.debug('>>>> : : ' + externalAttendeeToRemove);
        System.debug('>>>> : : ' + mapExternalAttendees);
        mapExternalAttendees.remove(externalAttendeeToRemove);
        
        if(externalAttendeeToRemove.getSobjectType() == Schema.Contact.SObjectType){
            Contact removedAttendee = [SELECT Id, Name, Account.Name, Account.Type, Email, Phone, Title,
                                              Head_Of_It__c, Head_of_Security__c, Head_of_networking__c, Budget_Authority__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c
                                         FROM Contact WHERE Id = :externalAttendeeToRemove LIMIT 1];
            mapMatchingExternalUsers.put(removedAttendee.Id, removedAttendee);
        }

        skipExternalAttendeesRefresh = true;
        validateExternalAttendees();
        skipExternalAttendeesRefresh = false;

        if (setModifiedExternalAttendees.contains(externalAttendeeToRemove)) {
            setModifiedExternalAttendees.remove(externalAttendeeToRemove);
        }
        sciRecord.Partner_Account__c = mapExternalAttendees.size() > 0 ? mapExternalAttendees.values()[mapExternalAttendees.size() - 1].AccountId : null;

        return null;
    }

    /**
     * Method to display the New Contact Creation popup
     */
    public PageReference showNewContactPopup() {
        newContact = new Contact(AccountId = accountId);
        showPopup = true;

        return null;
    }

    /**
     * Method to close the popup without saving
     */
    public PageReference cancelPopup() {
        newContact = null;
        showPopup = false;
        return null;
    }

    /**
     * Method to create the new contact and add it to external attendees list
     * @return [description]
     */
    public PageReference createAndAddExternalAttendee() {
        System.debug(newContact);
        try {
            insert newContact;
            showPopup = false;

            externalAttendeeToAdd = newContact.Id;
            addExternalAttendee();
        } catch (Exception ex) {
            popupMessage = 'Error occurred while adding new contact.';
            showPopup = true;
        }

        return null;
    }

    /*
    Methods for Step 4 - Manage External Attendees - End
     */

    /*
    Breadcrumb navigation code - Start
     */

    /**
     * Wrapper class to build breadcrumb navigation bar
     */
    public class NavigationStep {
        public List<NavigationStepItem> steps { get; set; }
        public Integer currentStep { get; set; }

        /**
         * Constructor
         */
        public NavigationStep() {
            steps = new List<NavigationStepItem>();
        }

        /**
         * Adds a new step to the navigation steps
         * @param step  NavigationStepItem object
         */
        public void addStep(NavigationStepItem step) {
            steps.add(step);
        }

        /**
         * Method to check if the given step is enabled or not
         * @param  stepNumber Step number
         * @return            True / false
         */
        public Boolean isStepEnabled(Integer stepNumber) {
            for (NavigationStepItem stepItem : steps) {
                if (stepNumber == stepItem.stepNumber) {
                    return stepItem.isEnabled;
                }
            }

            return null;
        }

        /**
         * Sets the step with given step number as current
         * @param stepNumber Step number
         */
        public void setCurrentStep(Integer stepNumber) {
            for (NavigationStepItem stepItem : steps) {
                if (stepNumber == stepItem.stepNumber) {
                    stepItem.isCurrentStep = true;
                    currentStep = stepItem.stepNumber;
                    break;
                } else {
                    stepItem.isCurrentStep = false;
                }
            }
        }

        /**
         * Sets the steps' IsEnabled flagged to false and enables the list of step numbers provided.
         * @param stepsToBeEnabled List of step numbers to be enabled
         */
        public void toggleEnableSteps(Set<Integer> stepsToBeEnabled) {
            for (NavigationStepItem stepItem : steps) {
                if (stepsToBeEnabled.contains(stepItem.stepNumber)) {
                    stepItem.isEnabled = true;
                } else {
                    stepItem.isEnabled = false;
                }
            }
        }
    }

    /**
     * Wrapper class for breadcrumb navigation step item
     */
    public class NavigationStepItem {
        public Integer stepNumber { get; set; }
        public String stepName { get; set; }
        public Boolean isCurrentStep { get; set; }
        public Boolean isEnabled { get; set; }

        public NavigationStepItem(Integer stepNumber, String stepName, Boolean isCurrentStep, Boolean isEnabled) {
            this.stepNumber = stepNumber;
            this.stepName = stepName;
            this.isCurrentStep = isCurrentStep;
            this.isEnabled = isEnabled;
        }
    }

    /*
    Breadcrumb navigation code - End
     */
}