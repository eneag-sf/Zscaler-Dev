/*****************************************************************************************
Name: ManageSCIInternalAttendeeService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to provide methods to manage SCI Internal Attendees
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     01-Dec-2016    Initial Development
******************************************************************************************/
public class ManageSCIInternalAttendeeService {
    /**
     * Method to query existing internal attendees
     * @param  sciId      SCI record ID
     * @param  sciOwnerId Owner ID
     * @return            Map of Internal attendees wrapped in SCIInternalAttendeeWrapper type
     */
    public static Map<Id, SCIInternalAttendeeWrapper> fetchInternalAttendees(Id sciId, Id sciOwnerId) {
        System.debug('>>>> sciId: ' + sciId + ' ; ' + sciOwnerId);
        Map<Id, SCIInternalAttendeeWrapper> mapInternalAttendees = new Map<Id, SCIInternalAttendeeWrapper>();

        //Add all sales team members as internal participants if new SCI is being created
        if (null != sciId) {
            for (SCI_Zscaler_Attendee__c attendee : [SELECT Id, Attendee_Name__c, Attendee_Department__c, Organizer__c, Participation__c, Attendee_Name__r.Name
                                                       FROM SCI_Zscaler_Attendee__c
                                                      WHERE Significant_Customer_Interaction__c = :sciId]) {
                mapInternalAttendees.put(attendee.Attendee_Name__c, new SCIInternalAttendeeWrapper(attendee.Id, 
                                            attendee.Attendee_Name__r.Name,
                                            attendee.Attendee_Name__c, 
                                            attendee.Attendee_Department__c, 
                                            (attendee.Organizer__c ? 'Organizer' : 'Attendee'), 
                                            attendee.Participation__c,
                                            false
                                        ));
            }
        }

        System.debug('>>>>> ; ' + mapInternalAttendees);

        return mapInternalAttendees;
    }

    /**
     * Method to query the sales team users
     * @param  patchTeamId                 Patch Team ID
     * @param  setInternalAttendeesUserIds Set of already added internal attendees
     * @return                             Map of sales team users
     */
    public static Map<Id, User> getInternalAttendeesToSuggest(Id patchTeamId, Set<Id> setInternalAttendeesUserIds) {
        Map<Id, User> mapSuggestedUsers = new Map<Id, User>();
        
        for (User user : [SELECT Id, Name, Department 
                            FROM User 
                           WHERE Id IN (SELECT User__c 
                            FROM PatchTeamMember__c 
                           WHERE PatchTeam__c = :patchTeamId)
                             AND Id NOT IN :setInternalAttendeesUserIds]) {
            mapSuggestedUsers.put(user.Id, user);
        }
        
        return mapSuggestedUsers;
    }

    /**
     * Helper method to search for an user
     * @param  searchTerm Search text
     * @return            List of matching users
     */
    public static List<User> searchInternalUsers(String searchTerm) {
        List<User> lstMatchingUsers = new List<User>();

        if (searchTerm.containsAny('%?=`')) {
            return null;
        }

        for (User matchingUser : (List<User>)Database.query('SELECT Id, Name, Department FROM User WHERE IsActive = TRUE AND Name LIKE \'' + searchTerm + '%\' LIMIT 20')) {
            lstMatchingUsers.add(matchingUser);
        }

        return lstMatchingUsers;
    }

    /**
     * Wrapper class for listing the internal attendees
     */
    public class SCIInternalAttendeeWrapper {
        public String Id { get; set; }
        public String name { get; set; }
        public String userId { get; set; }
        public String department { get; set; }
        public String isOrganizer { get; set; }
        public String participation { get; set; }
        public Boolean isReadOnly { get; set; }

        public SCIInternalAttendeeWrapper(String id, String name, String userId, String department, String isOrganizer, String participation, Boolean isReadOnly) {
            this.Id = id;
            this.name = name;
            this.userId = userId;
            this.department = department;
            this.isOrganizer = isOrganizer;
            this.participation = participation;
            this.isReadOnly = isReadOnly;
        }
    }    
}