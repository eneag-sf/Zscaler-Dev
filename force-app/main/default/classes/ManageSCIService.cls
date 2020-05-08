/*****************************************************************************************
Name: ManageSCIService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to provide methods to manage SCIs
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     01-Dec-2016    Initial Development
******************************************************************************************/
public class ManageSCIService {
	/**
     * Method to query the existing SCIs from the Database
     * @param  accountId       Account ID
     * @param  opportunityId   Opportunity ID
     * @param  leadId          Lead ID
     * @param  dealRegId       Deal Reg ID
     * @param  campaignId      Campaign ID
     * @param  sciRecordTypeId Type of SCI
     * @param  startDate       Start date of meeting
     * @param  endDate         End date of meeting
     * @return                 List of SCIs in SCIWrapper type
     */
    public static List<SCIWrapper> getExistingSCIs(Id accountId, Id opportunityId, Id leadId, Id dealRegId, Id campaignId, String sciRecordTypeId, Datetime startDate, Datetime endDate) {
        List<SCIWrapper> lstExistingSCIs = new List<SCIWrapper>();
        Map<String, String> mapFilterCriteria = new Map<String, String> { 
                                                    'Account_Name__c' => accountId, 
                                                    'Opportunity_Name__c' => opportunityId, 
                                                    'Lead__c' => leadId, 
                                                    'Deal_Reg__c' => dealRegId, 
                                                    'Campaign__c' => campaignId 
                                                };

        String query = 'SELECT Id, Name, RecordType.Name, Date__c, CreatedBy.Name, Opportunity_Name__c, Account_Name__c, Lead__c, Deal_Reg__c, Campaign__c, Method_of_Interaction__c, Primary_Topic_Covered__c, Interaction_With__c, ' + 
                              '(SELECT Id, Attendee_Name__c, Attendee_Name__r.Name, Organizer__c FROM SCI_Zscaler_Attendee__r WHERE Attendee_Name__c = \'' + UserInfo.getUserId() + '\' OR Organizer__c = true)' + 
                         ' FROM Significant_Customer_Interaction__c ' + 
                        ' WHERE Date__c >= ' + startDate.format('yyyy-MM-dd') + 
                          ' AND Date__c <= ' + endDate.format('yyyy-MM-dd');
        
        if (null != accountId
            || null != opportunityId
            || null != leadId
            || null != dealRegId
            || null != campaignId) {
            query += ' AND ( ';
            Boolean isAdditionalCriteria = false;
            for (String key : mapFilterCriteria.keySet()) {
                if (null != mapFilterCriteria.get(key)) {
                    if (isAdditionalCriteria) {
                        query += ' OR ';
                    }

                    query += key + ' = \'' + mapFilterCriteria.get(key) + '\'';

                    if (!isAdditionalCriteria) {
                        isAdditionalCriteria = true;
                    }
                }
            }

            query += ' )';
        }
        
        query += ' LIMIT 1000';
        System.debug(query);
        for (Significant_Customer_Interaction__c sci : Database.query(query)) {
            SCIWrapper existingSCI = new SCIWrapper(
                                        sci.Id,
                                        'Edit',
                                        sci.Name,
                                        sci.RecordType.Name,
                                        String.valueOf(sci.Date__c),
                                        '',
                                        sci.Primary_Topic_Covered__c,
                                        sci.Interaction_With__c,
                                        'N',
                                        sci.Account_Name__c,
                                        sci.Opportunity_Name__c,
                                        sci.Lead__c,
                                        sci.Deal_Reg__c,
                                        sci.Campaign__c,
                                        sci.Method_Of_Interaction__c
                                    );

            for (SCI_Zscaler_Attendee__c internalAttendee : sci.SCI_Zscaler_Attendee__r) {
                if (UserInfo.getUserId() == internalAttendee.Attendee_Name__c) {
                    existingSCI.wasIAdded = 'Y';
                }

                if (true == internalAttendee.Organizer__c) {
                    existingSCI.createdBy = internalAttendee.Attendee_Name__r.Name;
                }
            }

            lstExistingSCIs.add(existingSCI);
        }

        return lstExistingSCIs;
    }

    /**
     * Wrapper for listing the existing SCIs in UI
     */
    public class SCIWrapper {
        public String Id { get; set; }
        public String action { get; set; }
        public String sciNumber { get; set; }
        public String sciType { get; set; }
        public String dateOfMeeting { get; set; }
        public String createdBy { get; set; }
        public String primaryTopicCovered { get; set; }
        public String interactionWith { get; set; }
        public String wasIAdded { get; set; }
        public String accountId { get; set; }
        public String opportunityId { get; set; }
        public String leadId { get; set; }
        public String dealRegId { get; set; }
        public String campaignId { get; set; }
        public String methodOfInteraction { get; set; }

        /**
         * Constructor
         */
        public SCIWrapper(String id, String action, String sciNumber, String sciType, String dateOfMeeting, 
            String createdBy, String primaryTopicCovered, String interactionWith, String wasIAdded,
            String accountId, String opportunityId, String leadId, String dealRegId, String campaignId, String methodOfInteraction) {
            this.Id = id;
            this.action = action;
            this.sciNumber = sciNumber;
            this.sciType = sciType;
            this.dateOfMeeting = dateOfMeeting;
            this.createdBy = createdBy;
            this.primaryTopicCovered = primaryTopicCovered;
            this.interactionWith = interactionWith;
            this.wasIAdded = wasIAdded;
            this.accountId = accountId;
            this.opportunityId = opportunityId;
            this.leadId = leadId;
            this.dealRegId = dealRegId;
            this.campaignId = campaignId;
            this.methodOfInteraction = methodOfInteraction;
        }

        public SCIWrapper(String id, String action, String sciNumber, String sciType, String dateOfMeeting, 
            String createdBy, String primaryTopicCovered, String interactionWith, String wasIAdded,
            String accountId, String opportunityId, String leadId, String dealRegId, String campaignId) {

        }
    }
}