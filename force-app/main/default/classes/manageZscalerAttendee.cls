/*****************************************************************************************
Name: manageZscalerAttendee
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Class to manage Zscaler Attendee on Insert/Update of SCI.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/

public class manageZscalerAttendee{

    /**
    *@purpose : Method to create/update zscaler attendee
    *@param : New Map of SCI and Old Map of SCI.
    *@return : None
    **/
    public static void addZscalerAttendee(map<id,Significant_Customer_Interaction__c> newSCIMap, map<id,Significant_Customer_Interaction__c> oldSCIMap){
        list<SCI_Zscaler_Attendee__c> zscaleAttdUpdateList = new list<SCI_Zscaler_Attendee__c>();
        list<SCI_Zscaler_Attendee__c> zscaleAttdInsertList = new list<SCI_Zscaler_Attendee__c>();
        id userId = userInfo.getUserId();
        map<string, SCI_Zscaler_Attendee__c> sciIDZscalAttdMap = new map<string, SCI_Zscaler_Attendee__c>();

        for(SCI_Zscaler_Attendee__c zscalAttend : [Select id, Attendee_Name__c, Organizer__c, Participation__c, Significant_Customer_Interaction__c from SCI_Zscaler_Attendee__c where  Significant_Customer_Interaction__c IN: newSCIMap.keySet() AND Attendee_Name__c =: userInfo.getUserId() order by createdDate DESC]){

            if(sciIDZscalAttdMap != null ){
                if(!sciIDZscalAttdMap.ContainsKey(zscalAttend.Significant_Customer_Interaction__c))
                    sciIDZscalAttdMap.put(''+zscalAttend.Significant_Customer_Interaction__c+zscalAttend.Attendee_Name__c, zscalAttend);
            }else{
                sciIDZscalAttdMap.put(''+zscalAttend.Significant_Customer_Interaction__c+zscalAttend.Attendee_Name__c, zscalAttend);
            }

        }

        SCI_Zscaler_Attendee__c tempZscaleAttd = new SCI_Zscaler_Attendee__c();
        for(Significant_Customer_Interaction__c sci : newSCIMap.values()){
            tempZscaleAttd = new SCI_Zscaler_Attendee__c();
            if(oldSCIMap != null){
                if(sci.I_am_the__c != null && sci.I_am_the__c != '' && sci.I_am_the__c != oldSCIMap.get(sci.Id).I_am_the__c  && !sci.I_am_the__c.equalsIgnoreCase('Not Applicable') && sciIDZscalAttdMap.containsKey(''+sci.Id+UserId)){
                    tempZscaleAttd = sciIDZscalAttdMap.get(''+sci.Id+UserId);
                    if(sci.I_am_the__c.equalsIgnoreCase('Organizer') && !tempZscaleAttd.Organizer__c){
                        tempZscaleAttd.Organizer__c = true;
                    }
                    if(sci.I_am_the__c.equalsIgnoreCase('Attendee') && tempZscaleAttd.Organizer__c){
                        tempZscaleAttd.Organizer__c = false;
                    }
                    zscaleAttdUpdateList.add(tempZscaleAttd);
                }
            }else{
                if(sci.I_am_the__c != null && sci.I_am_the__c != '' && !sci.I_am_the__c.equalsIgnoreCase('Not Applicable'))
                    zscaleAttdInsertList.add(createZscalerAttendee(sci));
            }

        }

        if(!zscaleAttdUpdateList.isEmpty())
            database.update(zscaleAttdUpdateList,false);
        if(!zscaleAttdInsertList.isEmpty())
            database.insert(zscaleAttdInsertList,false);
        TriggerUtility.manageZscalerAttendeeExecuted();
    }
    /**
    *@purpose : Method to init Zscaler Attendee recrd
    *@param : SCI Record
    *@return : Zscaler Attendee
    **/
    public static SCI_Zscaler_Attendee__c createZscalerAttendee(Significant_Customer_Interaction__c sci){
        SCI_Zscaler_Attendee__c tempZscaleAttd = new SCI_Zscaler_Attendee__c();
        if(sci.I_am_the__c.equalsIgnoreCase('Organizer') ){
            tempZscaleAttd.Organizer__c = true;
        }
        if(sci.I_am_the__c.equalsIgnoreCase('Attendee') ){
            tempZscaleAttd.Organizer__c = false;
        }
        tempZscaleAttd.Significant_Customer_Interaction__c = sci.Id;
        tempZscaleAttd.Participation__c = sci.Participation__c;
        tempZscaleAttd.Attendee_Name__c = userinfo.getUserId();
        return tempZscaleAttd;
    }

    /**
     * @description Creates internal attendee records
     * @param Map<Id, String> Map of SCI Ids and Map of user Ids and type of attendees
     **/
    public static void createInternalAttendees(Map<Id, Map<Id, Boolean>> mapSCIIdsAndInternalAttendees) {
        List<SCI_Zscaler_Attendee__c> lstInternalAttendeesToInsert = new List<SCI_Zscaler_Attendee__c>();

        for (Id sciId : mapSCIIdsAndInternalAttendees.keySet()) {
            for (Id attendeeId : mapSCIIdsAndInternalAttendees.get(sciId).keySet()) {
                lstInternalAttendeesToInsert.add(new SCI_Zscaler_Attendee__c(
                                                    Significant_Customer_Interaction__c = sciId,
                                                    Attendee_Name__c = attendeeId,
                                                    Organizer__c = mapSCIIdsAndInternalAttendees.get(sciId).get(attendeeId),
                                                    Participation__c = 'Remote'
                                                ));
            }
        }

        try {
            if (lstInternalAttendeesToInsert.size() > 0) {
                Database.insert(lstInternalAttendeesToInsert, true);
            }
        } catch (Exception ex) {
            System.debug('>>>> Exception occurred while creating internal attendees for meeting event. Exception: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }
}