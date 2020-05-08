Public class SCITriggerHelper{
    public static void afterInsert(map<Id,Significant_Customer_Interaction__c> newSCIMap){
        if (!TriggerUtility.isSCIDealRegUpdateExecuted())
            updateDealRegForSCI(newSCIMap);

        if (!TriggerUtility.isCreateInternalAttendeesForMeetingEventExecuted()) {
            createInternalAttendeesForMeetingEvent(newSCIMap.values());
        }
    }

    public static void afterUpdate(Map<Id, Significant_Customer_Interaction__c> newSCIMap) {
        if (!TriggerUtility.isSCIDealRegUpdateExecuted()) {
            updateDealRegForSCI(newSCIMap);
        }
    }

    public static void updateDealRegForSCI(map<Id,Significant_Customer_Interaction__c> newSCIMap){
        list<Deal_Reg__c> dealRegUpdateList = new list<Deal_Reg__c>();
        set<id> dealRegIdSet = new set<id>();

        for(Significant_Customer_Interaction__c sci : newSCIMap.values()){
            if(sci.Deal_Reg__c != null)
                dealRegIdSet.add(sci.Deal_Reg__c);
        }

        for(Deal_Reg__c deal : [Select Id, SCI__c from Deal_Reg__c where Id IN: dealRegIdSet AND SCI__c =: false]){
            deal.SCI__c = true;
            dealRegUpdateList.add(deal);
        }

        if(!dealRegUpdateList.isEmpty()){
            try{
                database.update(dealRegUpdateList);
                TriggerUtility.SCIDealRegUpdateExecuted();
            }catch(exception e){}
        }
    }


    public static void updateLatestSCIonOpp(list<Significant_Customer_Interaction__c > SCINewList, map<id,Significant_Customer_Interaction__c > SCIOldMap){
        set<Id> oppIdSet = new set<Id>();
        Id solutionArchTypeId = Schema.SObjectType.Significant_Customer_Interaction__c.getRecordTypeInfosByName().get('Architecture Session').getRecordTypeId();
        System.debug('>>>>> : ' + solutionArchTypeId);
        if(SCINewList != null){
            for(Significant_Customer_Interaction__c sci : SCINewList){
                System.debug('>>>> sci: ' + JSON.serialize(sci));
                if(SCIOldMap != null){
                    if((SCIOldMap.get(sci.Id).Primary_Topic_Covered__c == 'Solution Architecture' || SCIOldMap.get(sci.Id).RecordTypeId == solutionArchTypeId || sci.Primary_Topic_Covered__c == 'Solution Architecture' || sci.RecordTypeId == solutionArchTypeId) /*&& (sci.Primary_Topic_Covered__c != SCIOldMap.get(sci.Id).Primary_Topic_Covered__c || sci.RecordTypeId != SCIOldMap.get(sci.Id).RecordTypeId)*/ && sci.Opportunity_Name__c != null)
                        oppIdSet.add(sci.Opportunity_Name__c);
                }else{
                    if(((sci.Primary_Topic_Covered__c != null && sci.Primary_Topic_Covered__c == 'Solution Architecture') || sci.RecordTypeId == solutionArchTypeId) && sci.Opportunity_Name__c != null){
                        oppIdSet.add(sci.Opportunity_Name__c);
                    }
                }
            }
        }else{
            for(Significant_Customer_Interaction__c sci : SCIOldMap.Values()){
                if(sci.Opportunity_Name__c != null)
                    oppIdSet.add(sci.Opportunity_Name__c);
            }
        }
        System.debug('>>>> oppIdSet: ' + oppIdSet);
        Map<id,Id> oppSCINumberMap = new map<Id, Id>();
        Map<Id, Date> oppSCIDateMap = new Map<Id, Date>();
        Map<Id, String> oppSCILinkMap = new Map<Id, String>();
        for(Significant_Customer_Interaction__c sci : [Select id, Name, Opportunity_Name__c, Date__c, Primary_Topic_Covered__c, Architecture_Workshop_Link__c from Significant_Customer_Interaction__c where Opportunity_Name__c IN: oppIdSet AND (Primary_Topic_Covered__c = 'Solution Architecture' OR RecordTypeId = :solutionArchTypeId) ORDER BY CreatedDate DESC] ){
            if(!oppSCINumberMap.keySet().Contains(sci.Opportunity_Name__c)) {
                oppSCINumberMap.put(sci.Opportunity_Name__c, sci.Id);
                oppSCIDateMap.put(sci.Opportunity_Name__c, sci.Date__c);
                oppSCILinkMap.put(sci.Opportunity_Name__c, sci.Architecture_Workshop_Link__c);
            }
        }
        list<Opportunity> oppUpdateList = new list<Opportunity>();
        if(SCINewList != null){
            for(Significant_Customer_Interaction__c sci : SCINewList){
                oppUpdateList.add(new Opportunity(Id = sci.Opportunity_Name__c, Architecture_Workshop_SCI__c = oppSCINumberMap.get(sci.Opportunity_Name__c), Architecture_Workshop_SCI_Date__c = oppSCIDateMap.get(sci.Opportunity_Name__c), Architecture_Document__c = oppSCILinkMap.get(sci.Opportunity_Name__c)));
            }
        }else{
            for(Significant_Customer_Interaction__c sci : SCIOldMap.Values()){
                oppUpdateList.add(new Opportunity(Id = sci.Opportunity_Name__c, Architecture_Workshop_SCI__c = oppSCINumberMap.get(sci.Opportunity_Name__c), Architecture_Workshop_SCI_Date__c = oppSCIDateMap.get(sci.Opportunity_Name__c), Architecture_Document__c = oppSCILinkMap.get(sci.Opportunity_Name__c)));
            }
        }
        if(!oppUpdateList.isEmpty())
            database.update(oppUpdateList, false);
        TriggerUtility.SCIOppUpdateExecuted();
    }

    public static void createInternalAttendeesForMeetingEvent(List<Significant_Customer_Interaction__c> lstNewSCIs) {
        Map<Id, Map<Id, Boolean>> mapSCIIdsAndInternalAttendees = new Map<Id, Map<Id, Boolean>>();
        Map<Id, Id> mapMeetingIds = new Map<Id, Id>();
        Map<Id, Id> mapsciwithwhoid = new Map<Id, Id>();
        Set<Id> EventownerIds = new Set<Id>();

        for (Significant_Customer_Interaction__c sci : lstNewSCIs) {
            if (sci.Meeting_ID__c != null) {
                mapMeetingIds.put(sci.Meeting_ID__c, sci.Id);
            }
        }
        List<Event> eventlst = [SELECT WhoId, OwnerId, Sales_Person__c FROM Event WHERE Id IN :mapMeetingIds.keySet()];
        Map<Id, String> mapuserdepartment = new Map<Id, String>();
        for(Event event : eventlst){
            EventownerIds.add(event.ownerId);
        }
        for(User u: [Select Id, Department from User where Id in :EventownerIds]){
            mapuserdepartment.put(u.Id, u.Department);
        }
        
        if (mapMeetingIds.size() > 0) {
            for (Event event : eventlst) {
                Map<Id, Boolean> mapAttendees = new Map<Id, Boolean>();
                mapAttendees.put(event.OwnerId, (event.WhoId.getSobjectType() == Schema.Lead.SObjectType && mapuserdepartment.containsKey(event.OwnerId) && mapuserdepartment.get(event.OwnerId) == 'Demand Generation' ? true : false));
                mapAttendees.put(event.OwnerId, (event.WhoId.getSobjectType() == Schema.Contact.SObjectType && mapuserdepartment.containsKey(event.OwnerId) && (mapuserdepartment.get(event.OwnerId) == 'Field Sales' || mapuserdepartment.get(event.OwnerId) == 'Inside Sales') ? true : false));
                mapAttendees.put(event.Sales_Person__c, false);

                mapSCIIdsAndInternalAttendees.put(mapMeetingIds.get(event.Id), mapAttendees);
                mapsciwithwhoid.put(mapMeetingIds.get(event.Id), event.WhoId);
            }
        }

        if (mapSCIIdsAndInternalAttendees.size() > 0) {
            manageZscalerAttendee.createInternalAttendees(mapSCIIdsAndInternalAttendees);
        }
        
        if (mapsciwithwhoid.size() > 0) {
            ManageSCIExternalAttendeeService.createExternalAttendees(mapsciwithwhoid);
        }

        TriggerUtility.createInternalAttendeesForMeetingEventExecuted();
    }

}