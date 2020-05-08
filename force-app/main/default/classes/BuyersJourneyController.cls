global class BuyersJourneyController {
    private static final Double STAGE1_MAX_SCORE = 4.0;
    private static final Double STAGE2_MAX_SCORE = 4.0;
    private static final Double STAGE3_MAX_SCORE = 5.0;
    private static final Double STAGE4_MAX_SCORE = 5.0;

    public Opportunity opportunityRecord { get; set; }
    public Integer currentStage { get; set; }
    public Buyers_Journey_Checklist__c checklist { get; set; }
    public Boolean isError { get; set; }

    public Boolean inAddChangeAgentMode { get; set; }
    public Boolean inEditChangeAgentMode { get; set; }
    public String changeAgentSearchText { get; set; }
    public String changeAgentContactId { get; set; }
    public Map<Id, Contact> mapChangeAgents { get; set; }
    public String changeAgentToDeleteId { get; set; }

    public String primaryPartnerType { get; set; }
    public String primaryPartnerName { get; set; }
    public Boolean primaryPartnerFound { get; set; }
    public Integer newStage { get; set; }

    public Boolean inAddEndorsersMode { get; set; }
    public Boolean inEditEndorsersMode { get; set; }
    public String endorsersSearchText { get; set; }
    public String endorsersContactId { get; set; }
    public String endorsersToDeleteId { get; set; }
    public Map<Id, Contact> mapEndorsers { get; set; }

    public String saveTimestamp { get; set; }
    public Boolean isSaving { get; set; }

    public Boolean vmoPlanInSFDC { get; set; }
    public Boolean techValidationPlanInSFDC { get; set; }
    public Boolean oldSentPromisetoProceedEmail { get; set; }

    public BuyersJourneyController() {
    
    }

    public BuyersJourneyController(ApexPages.StandardController controller) {
        opportunityRecord = [SELECT Id, Name, StageName, Architecture_Workshop_SCI__c, Architecture_Workshop_SCI__r.Name 
                               FROM Opportunity 
                              WHERE Id = :controller.getId() LIMIT 1];

        List<Buyers_Journey_Checklist__c> checklistRecords = [SELECT Id, Opportunity__c, Opportunity__r.AccountId
                                                               FROM Buyers_Journey_Checklist__c 
                                                              WHERE Opportunity__c = :opportunityRecord.Id 
                                                              ORDER BY CreatedDate DESC 
                                                              LIMIT 1];

        if (checklistRecords.size() > 0) {
            checklist = checklistRecords[0];
        } else {
            checklist = new Buyers_Journey_Checklist__c(Opportunity__c = opportunityRecord.Id);
        }
        String Stage_1 = label.Stage_1_Alignment ;
        String Stage_2 = label.Stage_2_Qualified_Budgeted ;
        String Stage_3 = label.Stage_4_Economic_Buyer_Signoff ;
        String Stage_4 = label.Stage_5_Contracts_Complete ;
        String Stage_5 = label.Stage_6_Closed_Won ;
        currentStage = 1;
        if ('0 - initial prospecting' == opportunityRecord.StageName.toLowerCase()) {
            currentStage = 1;
        } else if (/*'1 - qualified and budgeted'*/ 
                    Stage_1.toLowerCase() == opportunityRecord.StageName.toLowerCase()) {
            currentStage = 2;
        } else if (/*'2 - technical validation'*/ 
                    Stage_2.toLowerCase() == opportunityRecord.StageName.toLowerCase()) {
            currentStage = 3;
        } else if (
            /*'7 - negotiation & review'*/ 
            Stage_3.toLowerCase() == opportunityRecord.StageName.toLowerCase()
            //|| '10 - closed won' == opportunityRecord.StageName.toLowerCase()             //Commented as 7 - negotiation & review and 10 - closed won have same replacement value:- Stage_4_Economic_Buyer_Signoff
            || /*'10b - po recd, pending finance approval'*/
            Stage_4.toLowerCase() == opportunityRecord.StageName.toLowerCase()
            || /*'13 - closed & approved by finance'*/ 
            Stage_5.toLowerCase() == opportunityRecord.StageName.toLowerCase()) {
            currentStage = 4;
        }
    }

    public PageReference pageload() {
        if (null == checklist.Id) {
            insert checklist;
        }

        List<Buyers_Journey_Checklist__c> checklistRecords = [SELECT Agrees_to_review_F90_MAP_Implementation__c,Business_case_submitted_internally__c,
                                                                     Colloborated_on_business_case__c,Combine_POC_and__c,CreatedById,CreatedDate,
                                                                     Customer_Responded_to_Promise_Email__c,Due_Diligence_to_Understand_Use_Cases__c,
                                                                     F90_Handoff_Status__c,Finalize_VMO_Business_Case__c,Get_Agreement_to_Start_POC_Pilot_Feva__c,
                                                                     Has_spoken_with_references__c,Have_Customer_Run_Security_Preview__c,
                                                                     Id,Identify_Change_Agents__c,Identify_Key_Stakeholders__c,Identify_Partner_Name__c,
                                                                     Identify_Partner_Type__c,Interaction_with_Business_Case__c,Introduce_VMO_Concept__c,
                                                                     Introductory_Meeting__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,
                                                                     MAP_Review__c,Multiple_Unique_Leads_from_Account__c,Name,Name_of_Identified_Change_Agents__c,
                                                                     Opportunity__c,Participated_in_Architectural_Workshop__c,Participated_in_POC_Planning__c,
                                                                     POC_Exec_Findings_Meeting_Conducted__c,Post_Sales_Support_Team_Intros__c,
                                                                     Provide_Customer_References__c,Provide_Relevant_Use_Cases__c,Schedule_Architectural_Workshop__c,
                                                                     Schedule_conduct_POC_planning_meeting__c,SecurityPreview_Grade__c,Sent_Promise_to_Proceed_Email__c,
                                                                     SystemModstamp,VMO_Plan_in_SFDC__c,Zscaler_Advantages_Reflected_in__c, Opportunity__r.Architecture_Workshop_SCI__c,
                                                                     Opportunity__r.Architecture_Workshop_SCI__r.Name, Opportunity__r.AccountId, Create_and_Share_POC_Plan_Criteria__c,
                                                                     Create_and_share_Mutual_Activity_Plan__c, Conduct_POC_Kick_Off_Meeting__c, Schedule_POC_Exec_Findings_Meeting__c,
                                                                     Confirm_Budget_To_Purchase_Solution__c, Customer_Agrees_And_Returns_MAP__c, Customer_Accepts_Tech_Validation_Plan__c,
                                                                     Date_of_POC_Kick_off_Meeting__c, Date_of_POC_Exec_Findings_Meeting__c, Conduct_POC_Execs_Findings_Meeting__c,
                                                                     Opportunity__r.Validation_Plan__c, Opportunity__r.VMO_Play__c, F90_Handoff_Status_Flag__c
                                                               FROM Buyers_Journey_Checklist__c 
                                                              WHERE Opportunity__c = :opportunityRecord.Id 
                                                              ORDER BY CreatedDate DESC 
                                                              LIMIT 1];

        if (checklistRecords.size() > 0) {
            checklist = checklistRecords[0];
            if (null != checklist.Opportunity__r.AccountId) {
                for (AccountPartner partnerAccount : [SELECT Id, AccountFromId, AccountToId, AccountTo.Name, OpportunityId, Role, IsPrimary, AccountTo.Partner_Type__c
                                                        FROM AccountPartner 
                                                       WHERE AccountFromId = :checklist.Opportunity__r.AccountId 
                                                         AND OpportunityId = :checklist.Opportunity__c
                                                         AND IsPrimary = true]) {
                    primaryPartnerFound = true;
                    primaryPartnerType = partnerAccount.AccountTo.Partner_Type__c;
                    primaryPartnerName = partnerAccount.AccountTo.Name;
                }
            }

            vmoPlanInSFDC = (null != checklist.Opportunity__r.VMO_Play__c && 'none' != checklist.Opportunity__r.VMO_Play__c.toLowerCase()) ? true : false;
            techValidationPlanInSFDC = (null != checklist.Opportunity__r.Validation_Plan__c) ? true : false;
            oldSentPromisetoProceedEmail = checklist.Sent_Promise_to_Proceed_Email__c;

            if (null != checklist.Opportunity__r.Architecture_Workshop_SCI__c) {
                checklist.Schedule_Architectural_Workshop__c = true;
            }
        }

        return null;
    }

    /*
    Scoring methods - Start
     */
    public Integer getStage1Score() {
        Double score = 0.0;

        if (true == checklist.Multiple_Unique_Leads_from_Account__c) {
            score += 1.0;
        }

        if (null != checklist.SecurityPreview_Grade__c) {
            score += 1.0;
        }

        if (true == checklist.Customer_Responded_to_Promise_Email__c) {
            score += 1.0;
        }

        if (null != mapChangeAgents
            && !mapChangeAgents.isEmpty()) {
            score += 1.0;
        }

        System.debug('>>>>>: ' + score);
        System.debug('>>>>>: ' + (score / STAGE1_MAX_SCORE) * 100.0);

        //Calculate the % of score
        return Integer.valueOf((score / STAGE1_MAX_SCORE) * 100.0);
    }

    public Integer getStage2Score() {
        Double score = 0.0;

        if (true == checklist.Colloborated_on_business_case__c) {
            score += 1.0;
        }

        if (true == checklist.Has_spoken_with_references__c) {
            score += 1.0;
        }

        if (null != checklist.Opportunity__r.Architecture_Workshop_SCI__c) {
            score += 1.0;
        }

        if (true == checklist.Participated_in_POC_Planning__c) {
            score += 1.0;
        }

        return Integer.valueOf((score / STAGE2_MAX_SCORE) * 100.0);
    }

    public Integer getStage3Score() {
        Double score = 0.0;

        if (true == checklist.Confirm_Budget_To_Purchase_Solution__c) {
            score += 1.0;
        }

        if (true == checklist.Customer_Agrees_And_Returns_MAP__c) {
            score += 1.0;
        }

        if (true == checklist.Customer_Accepts_Tech_Validation_Plan__c) {
            score += 1.0;
        }

        if (null != checklist.Date_of_POC_Kick_off_Meeting__c) {
            score += 1.0;
        }

        if (null != checklist.Date_of_POC_Exec_Findings_Meeting__c) {
            score += 1.0;
        }

        return Integer.valueOf((score / STAGE3_MAX_SCORE) * 100.0);
    }

    public Integer getStage4Score() {
        Double score = 0.0;

        if (true == checklist.Interaction_with_Business_Case__c) {
            score += 1.0;
        }

        if (null != mapEndorsers
            && mapEndorsers.size() > 0) {
            score += 1.0;
        }

        if (true == checklist.Business_case_submitted_internally__c) {
            score += 1.0;
        }

        if (true == checklist.Zscaler_Advantages_Reflected_in__c) {
            score += 1.0;
        }

        if (true == checklist.Agrees_to_review_F90_MAP_Implementation__c) {
            score += 1.0;
        }

        return Integer.valueOf((score / STAGE4_MAX_SCORE) * 100.0);
    }
    /*
    Scoring methods - End
     */

    public PageReference saveStart() {
        isSaving = true;
        return null;
    }

    public PageReference setCurrentStage() {
        System.debug(newStage + ';' + currentStage);
        currentStage = newStage;

        return null;
    }

    public PageReference save() {
        System.debug('>>>>: ' + checklist);

        try {
            checklist.Stage_1_Score__c = getStage1Score();
            checklist.Stage_2_Score__c = getStage2Score();
            checklist.Stage_3_Score__c = getStage3Score();
            checklist.Stage_4_Score__c = getStage4Score();

            upsert checklist;
        }
        catch (Exception ex) {
            System.debug('Exception occurred while saving the checklist: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new BuyersJourneyControllerException('Exception occurred while saving the checklist: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        saveTimestamp = Datetime.now().format();
        isSaving = false;
        return null;
    }

    /*
    Common methods - Start
     */
    @RemoteAction
    global static List<Contact> searchContacts(String searchText, String accountId) {
        List<Contact> lstMatchingContacts = new List<Contact>();

        if (searchText.containsAny('%?=`')) {
            return null;
        }

        String query = 'SELECT Id, Name, Account.Name, Email, Phone, Title FROM Contact WHERE Name LIKE \'' + searchText + '%\'';

        if (null != accountId
            && !String.isEmpty(accountId)) {
            query += ' AND AccountId = \'' + accountId + '\'';
        }

        query += 'LIMIT 20';

        for (Contact matchingContact : (List<Contact>)Database.query(query)) {
            lstMatchingContacts.add(matchingContact);
        }

        return lstMatchingContacts;
    }
    /*
    Common methods - End
     */

    /*
    Stage 1 Methods - Start
     */
    public PageReference addChangeAgent() {
        if (null == changeAgentContactId
            || String.isBlank(changeAgentContactId)) {
            return null;
        }

        try {
            Contact contact = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Id =:changeAgentContactId LIMIT 1];

            OpportunityContactRole newRole = new OpportunityContactRole(
                                                ContactId = contact.Id,
                                                OpportunityId = opportunityRecord.Id,
                                                Role = 'Change Agent'
                                            );
            insert newRole;

            inAddChangeAgentMode = false;

            if (null == mapChangeAgents) {
                mapChangeAgents = new Map<Id, Contact>();
            }

            mapChangeAgents.put(changeAgentContactId, contact);

            checklist.Stage_1_Score__c = getStage1Score();
            update checklist;
        }
        catch (Exception ex) {
            System.debug('Exception occurred while adding change agent: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            return null;
        }

        return null;
    }

    public PageReference deleteChangeAgent() {
        System.debug('>>>> changeAgentToDeleteId: ' + changeAgentToDeleteId);
        if (null == changeAgentToDeleteId || String.isBlank(changeAgentToDeleteId)) {
            return null;
        }

        try {
            OpportunityContactRole roleToDelete = new OpportunityContactRole();
            List<OpportunityContactRole> roles = [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunityRecord.Id AND ContactId = :changeAgentToDeleteId AND Role = 'Change Agent' LIMIT 1];

            if (null != roles
                && roles.size() > 0) {
                roleToDelete = roles[0];
            }

            delete roleToDelete;

            mapChangeAgents.remove(changeAgentToDeleteId);

            checklist.Stage_1_Score__c = getStage1Score();
            update checklist;
        } catch (Exception ex) {
            System.debug('Exception occurred while deleting change agent: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            return null;
        }


        return null;
    }

    public PageReference enableAddChangeAgentMode() {
        inEditChangeAgentMode = false;
        inAddChangeAgentMode = true;
        return null;
    }

    public PageReference disableAddChangeAgentMode() {
        inAddChangeAgentMode = false;
        return null;
    }

    public PageReference enableEditChangeAgentMode() {
        inAddChangeAgentMode = false;
        inEditChangeAgentMode = true;
        return null;
    }

    public PageReference disableEditChangeAgentMode() {
        inEditChangeAgentMode = false;
        return null;
    }

    public List<Contact> getChangeAgents() {
        if (null == mapChangeAgents) {
            mapChangeAgents = new Map<Id, Contact>();
        }

        for (OpportunityContactRole role : [SELECT Id, ContactId, Contact.FirstName, Contact.LastName,
                                                    Contact.Name, Contact.AccountId, Contact.Account.Name
                                              FROM OpportunityContactRole
                                             WHERE OpportunityId = :opportunityRecord.Id
                                               AND Role = 'Change Agent']) {
            mapChangeAgents.put(role.ContactId, role.Contact);
        }

        System.debug('>>>> mapChangeAgents: ' + mapChangeAgents);
        return (null != mapChangeAgents) ? mapChangeAgents.values() : new List<Contact>();
    }
    /*
    Stage 1 Methods - End
     */
    
    /*
    Endorsers Methods - Start
     */
    public PageReference enableAddEndorsersMode() {
        inEditEndorsersMode = false;
        inAddEndorsersMode = true;
        return null;
    }

    public PageReference disableAddEndorsersMode() {
        inAddEndorsersMode = false;
        return null;
    }

    public PageReference enableEditEndorsersMode() {
        inAddEndorsersMode = false;
        inEditEndorsersMode = true;
        return null;
    }

    public PageReference disableEditEndorsersMode() {
        inEditEndorsersMode = false;
        return null;
    }

    public List<Contact> getEndorsers() {
        if (null == mapEndorsers) {
            mapEndorsers = new Map<Id, Contact>();
        }
        
        for (OpportunityContactRole role : [SELECT Id, ContactId, Contact.FirstName, Contact.LastName,
                                                    Contact.Name, Contact.AccountId, Contact.Account.Name
                                              FROM OpportunityContactRole
                                             WHERE OpportunityId = :opportunityRecord.Id
                                               AND Role = 'Endorser']) {
            mapEndorsers.put(role.ContactId, role.Contact);
        }

        System.debug('>>>> mapEndorsers: ' + mapEndorsers);
        return (null != mapEndorsers) ? mapEndorsers.values() : new List<Contact>();
    }

    public PageReference addEndorsers() {
        if (null == endorsersContactId
            || String.isBlank(endorsersContactId)) {
            return null;
        }

        try {
            Contact contact = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Id =:endorsersContactId LIMIT 1];

            OpportunityContactRole newRole = new OpportunityContactRole(
                                                ContactId = contact.Id,
                                                OpportunityId = opportunityRecord.Id,
                                                Role = 'Endorser'
                                            );
            insert newRole;

            inAddEndorsersMode = false;

            if (null == mapEndorsers) {
                mapEndorsers = new Map<Id, Contact>();
            }

            mapEndorsers.put(endorsersContactId, contact);

            checklist.Stage_4_Score__c = getStage4Score();
            update checklist;
        }
        catch (Exception ex) {
            System.debug('Exception occurred while adding endorser: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            return null;
        }

        return null;
    }

    public PageReference deleteEndorsers() {
        System.debug('>>>> endorsersToDeleteId: ' + endorsersToDeleteId);
        if (null == endorsersToDeleteId || String.isBlank(endorsersToDeleteId)) {
            return null;
        }

        try {
            OpportunityContactRole roleToDelete = new OpportunityContactRole();
            List<OpportunityContactRole> roles = [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :opportunityRecord.Id AND ContactId = :endorsersToDeleteId AND Role = 'Endorser' LIMIT 1];

            if (null != roles
                && roles.size() > 0) {
                roleToDelete = roles[0];
            }

            delete roleToDelete;

            mapEndorsers.remove(endorsersToDeleteId);

            checklist.Stage_4_Score__c = getStage4Score();
            update checklist;
        } catch (Exception ex) {
            System.debug('Exception occurred while deleting endorser: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            return null;
        }

        return null;
    }
    /*
    Endorsers Methods - End
     */

    /*
     *Custom exception class
     */
    public class BuyersJourneyControllerException extends Exception {}
}