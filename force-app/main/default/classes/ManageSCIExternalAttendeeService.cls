/*****************************************************************************************
Name: ManageSCIExternalAttendeeService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to provide methods to manage SCI External Attendees
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Vijay Prakash P J     01-Dec-2016    Initial Development
******************************************************************************************/
public class ManageSCIExternalAttendeeService {
    /**
     * Method to query all the existing external attendees
     * @param  sciId      SCI Record ID
     * @param  sciOwnerId Owner ID
     * @return            Map of external attendees wrapped in SCIExternalAttendeeWrapper type
     */
    public static Map<Id, SCIExternalAttendeeWrapper> fetchExternalAttendees(Id sciId, Id sciOwnerId) {
        Map<Id, SCIExternalAttendeeWrapper> mapExternalAttendees = new Map<Id, SCIExternalAttendeeWrapper>();

        //Add all sales team members as internal participants if new SCI is being created
        if (null != sciId) {
            for (SCI_External_Attendee__c attendee : [SELECT Id, Attendee_Name__c, Attendee_Name_Lead__c, Attendee_Name_Lead__r.Name, Attendee_Name_Lead__r.Email, Attendee_Name_Lead__r.Phone, Attendee_Name_Lead__r.Title, Account__c, Attendee_Name__r.AccountId, Attendee_Name__r.Title,
                                                            Attendee_Name__r.Email, Attendee_Name__r.Phone, Attendee_Name__r.Name, Type__c, Date_Created__c,
                                                            Head_Of_IT__c, Head_Of_Networking__c, Service_Owner__c, Solution_Architect__c, Head_Of_Security__c, Budget_Authority__c, Procurement_Contact__c
                                                       FROM SCI_External_Attendee__c
                                                      WHERE Significant_Customer_Interaction__c = :sciId
                                                      ORDER BY Date_Created__c ASC]) {
                if(attendee.Attendee_Name__c != null){
                    mapExternalAttendees.put(attendee.Attendee_Name__c, new SCIExternalAttendeeWrapper(attendee.Id,
                                            attendee.Attendee_Name__c,
                                            attendee.Attendee_Name__r.Name,
                                            attendee.Attendee_Name__r.AccountId,
                                            attendee.Account__c,
                                            attendee.Attendee_Name__r.Email,
                                            attendee.Attendee_Name__r.Phone,
                                            attendee.Attendee_Name__r.Title,
                                            attendee.Type__c,
                                            attendee.Head_Of_IT__c,
                                            attendee.Head_Of_Networking__c,
                                            attendee.Head_Of_Security__c,
                                            attendee.Budget_Authority__c,
                                            attendee.Procurement_Contact__c,
                                            attendee.Service_Owner__c,
                                            attendee.Solution_Architect__c,
                                            attendee.Date_Created__c
                                        ));
                }else if(attendee.Attendee_Name_Lead__c != null){
                    mapExternalAttendees.put(attendee.Attendee_Name_Lead__c , new SCIExternalAttendeeWrapper(attendee.Id,
                                            attendee.Attendee_Name_Lead__c,
                                            attendee.Attendee_Name_Lead__r.Name,
                                            null,
                                            null,
                                            attendee.Attendee_Name_Lead__r.Email,
                                            attendee.Attendee_Name_Lead__r.Phone,
                                            attendee.Attendee_Name_Lead__r.Title,
                                            attendee.Type__c,
                                            attendee.Head_Of_IT__c,
                                            attendee.Head_Of_Networking__c,
                                            attendee.Head_Of_Security__c,
                                            attendee.Budget_Authority__c,
                                            attendee.Procurement_Contact__c,
                                            attendee.Service_Owner__c,
                                            attendee.Solution_Architect__c,
                                            attendee.Date_Created__c
                                        ));
                }
            }
        }

        System.debug('>>>>> ; ' + mapExternalAttendees);

        return mapExternalAttendees;
    }

    /**
     * Method to query all contacts from the account associated to the SCI
     * @param  accountId                     Associated account ID
     * @param  setExternalAttendeeContactIds Set of already added external attendees (to exclude)
     * @return                               Map of contacts
     */
    public static Map<Id, Contact> getExternalContactsToSuggest(Id accountId, Set<Id> setExternalAttendeeContactIds) {
        Map<Id, Contact> mapExternalAttendeesToReturn = new Map<Id, Contact> ();

        for (Contact externalContact : [SELECT Id, Name, Account.Name, Account.Type, Email, Phone, Title,
                                               Head_Of_It__c, Head_of_Security__c, Service_Owner__c, Cloud_Architect__c, Head_of_networking__c, Budget_Authority__c, Procurement_Contact__c
                                          FROM Contact WHERE AccountId = :accountId AND Id NOT IN :setExternalAttendeeContactIds and Active__c = false LIMIT 100])  {
            mapExternalAttendeesToReturn.put(externalContact.Id, externalContact);
        }

        return mapExternalAttendeesToReturn;
    }

    /**
     * Helper method to search contacts to be added as external attendee
     * @param  searchTerm Search text
     * @return            List of matching contacts
     */
    public static List<Contact> searchExternalUsers(String searchTerm) {
        List<Contact> lstMatchingContacts = new List<Contact>();

        if (searchTerm.containsAny('%?=`')) {
            return null;
        }

        for (Contact matchingContact : (List<Contact>)Database.query('SELECT Id, Name, Account.Name, Email, Phone, Title FROM Contact WHERE AccountId <> NULL AND Active__c = false and Name LIKE \'' + searchTerm + '%\' LIMIT 50')) {
            lstMatchingContacts.add(matchingContact);
        }

        return lstMatchingContacts;
    }
    
    public static List<Lead> searchLeads(String searchTerm) {
        List<Lead> lstMatchingLeads = new List<Lead>();

        if (searchTerm.containsAny('%?=`')) {
            return null;
        }

        for (Lead matchingLead : (List<Lead>)Database.query('SELECT Id, Name, Email, Phone, Title FROM Lead WHERE Name LIKE \'' + searchTerm + '%\' LIMIT 50')) {
            lstMatchingLeads.add(matchingLead);
        }

        return lstMatchingLeads;
    }
    
    /**
     * @description Creates external attendee records
     * @param Map<Id, String> Map of SCI Ids and Map of user Ids and type of attendees
     **/
    public static void createExternalAttendees(Map<Id, Id> sciextattendeemap) {
        List<SCI_External_Attendee__c > lstExternalAttendeesToInsert = new List<SCI_External_Attendee__c >();

        for (Id sciId : sciextattendeemap.keyset()){
            if(sciextattendeemap.get(sciId).getSobjecttype() == Schema.Contact.SObjectType){
                lstExternalAttendeesToInsert.add(new SCI_External_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciId,
                                                    Attendee_Name__c = sciextattendeemap.get(sciId),
                                                    Type__c = 'Customer'
                                                ));
                                                
            }else if(sciextattendeemap.get(sciId).getSobjecttype() == Schema.Lead.SObjectType){
                lstExternalAttendeesToInsert.add(new SCI_External_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciId,
                                                    Attendee_Name_Lead__c = sciextattendeemap.get(sciId),
                                                    Type__c = 'Customer'
                                                ));
            }
        }

        try {
            if (lstExternalAttendeesToInsert.size() > 0) {
                Database.insert(lstExternalAttendeesToInsert, true);
            }
        } catch (Exception ex) {
            System.debug('>>>> Exception occurred while creating external attendees for meeting event. Exception: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }

    /**
     * Wrapper class for external attendees
     */
    public class SCIExternalAttendeeWrapper {
        public String Id { get; set; }
        public String ContactId { get; set; }
        public String Name { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
        public String Email { get; set; }
        public String Phone { get; set; }
        public String Title { get; set; }
        public String AttendeeType { get; set; }
        public Boolean HeadOfIT { get; set; }
        public Boolean HeadOfNetworking { get; set; }
        public Boolean HeadOfSecurity { get; set; }
        public Boolean BudgetAuthority { get; set; }
        public Boolean ProcurementContact { get; set; }
        public Boolean ServiceOwner { get; set; }
        public Boolean SolutionArchitect { get; set; }
        public Datetime DateCreated { get; set; }

        /**
         * Constructor
         */
        public SCIExternalAttendeeWrapper(String Id, String ContactId, String Name,
                String AccountId, String AccountName, String Email, String Phone,
                String Title, String AttendeeType) {

        }

        public SCIExternalAttendeeWrapper(String Id, String ContactId, String Name,
                String AccountId, String AccountName, String Email, String Phone,
                String Title, String AttendeeType, Boolean HeadOfIT, Boolean HeadOfNetworking,
                Boolean HeadOfSecurity, Boolean BudgetAuthority, Boolean ProcurementContact, Boolean ServiceOwner, Boolean SolutionArchitect) {

        }

        public SCIExternalAttendeeWrapper(String Id, String ContactId, String Name,
                String AccountId, String AccountName, String Email, String Phone,
                String Title, String AttendeeType, Boolean HeadOfIT, Boolean HeadOfNetworking,
                Boolean HeadOfSecurity, Boolean BudgetAuthority, Boolean ProcurementContact, Boolean ServiceOwner,
                Boolean SolutionArchitect, Datetime DateCreated) {
            this.Id = Id;
            this.ContactId = ContactId;
            this.Name = Name;
            this.AccountId = AccountId;
            this.AccountName = AccountName;
            this.Email = Email;
            this.Phone = Phone;
            this.Title = Title;
            this.AttendeeType = AttendeeType;
            this.HeadOfIT = HeadOfIT;
            this.HeadOfNetworking = HeadOfNetworking;
            this.HeadOfSecurity = HeadOfSecurity;
            this.BudgetAuthority = BudgetAuthority;
            this.ProcurementContact = ProcurementContact;
            this.ServiceOwner = ServiceOwner;
            this.SolutionArchitect = SolutionArchitect;
            this.DateCreated = DateCreated;
        }
    }
}