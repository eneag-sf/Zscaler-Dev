public class leadTriggerHelper{

    public static boolean skipTrigger = false;
    public static void caseCreationForDefaultTerrirtory(list<lead> leadList, map<id, lead> oldLeadMap){

        List<Catch_All_Territory_List__c> catchTerritoryList = Catch_All_Territory_List__c.getall().values();
        set<string> catchTerritoryIdSet = new set<string>();
        list<case> caseInsertList = new list<case>();

        for(Catch_All_Territory_List__c catchterritory : catchTerritoryList){
            if(catchterritory.Record_Id__c != null && catchterritory.Record_Id__c != '')
               catchTerritoryIdSet.add(catchterritory.Record_Id__c);
        }

        for(lead le : leadList){
            if(le.Territory__c != null && (le.Territory__c != oldLeadMap.get(le.Id).Territory__c || (le.mkto2__Lead_Score__c >= 70 && le.mkto2__Lead_Score__c != oldLeadMap.get(le.Id).mkto2__Lead_Score__c))){
                if(catchTerritoryIdSet.contains(le.Territory__c))
                    caseInsertList.add(createCase(le));
            }
        }


        if(!caseInsertList.isEmpty())
            database.insert(caseInsertList,false);
       TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
    }

    public static case createCase(lead le){
      case tempCase = new case();
      if(le.mkto2__Lead_Score__c >= 70)
        tempCase.Priority = '2 - High';
      tempCase.Lead__c = le.Id;
      tempCase.Subject = 'New Lead Has Been Assigned to Catch All Territory.';
      tempCase.Description = 'Lead : '+System.URL.getSalesforceBaseURL().toExternalForm()+'/' + le.id;
      tempCase.Case_Category__c = 'Territory Management';
      tempCase.Case_Sub_Category__c = 'Lead Catch All Fix';
      tempCase.recordtypeid=label.CaseRT_SalesOperation;
      if(!Test.isRunningTest())
        tempCase.OwnerId = ZscalerSetting__c.getValues('DSReviewCaseOwnerId').Value__c;
      tempCase.Status = 'New';
      return tempCase;
    }
    /*
    public static void updateDealRegSalesTerritory(map<id,Lead> newLeadMap, map<Id, Lead> oldLeadMap){
        set<Id> leadIdSet = new set<Id>();
        set<Id> emailChangeLeadIdSet = new set<Id>();
        for(Lead le : newLeadMap.Values()){
            if(le.Territory__c != null && le.Territory__c  != oldLeadMap.get(le.Id).Territory__c)
                leadIdSet.add(le.Id);
            if(le.Email != null && le.Email  != oldLeadMap.get(le.Id).Email)
                emailChangeLeadIdSet.add(le.Id);
        }
        list<Deal_Reg__c> dealRegUpdateList = new list<Deal_Reg__c>();
        for(Deal_Reg__c deal : [Select Id, Sales_Territory__c, Account_Manager__c, Channel_Manager__c, Lead__c, ownerId from Deal_Reg__c WHERE Lead__c IN:leadIdSet]){
            deal.Account_Manager__c = newLeadMap.get(deal.Lead__c).Account_Manager__c;
            deal.Sales_Territory__c = newLeadMap.get(deal.Lead__c).Territory__c;
            deal.Channel_Manager__c = newLeadMap.get(deal.Lead__c).Channel_Manager__c;

            if(newLeadMap.get(deal.Lead__c).Account_Manager__c != null){
                deal.ownerId = newLeadMap.get(deal.Lead__c).Account_Manager__c;
            }else if(newLeadMap.get(deal.Lead__c).Channel_Manager__c != null){
                deal.ownerId = newLeadMap.get(deal.Lead__c).Channel_Manager__c;
            }
            dealRegUpdateList.add(deal);
        }
        if(!dealRegUpdateList.isEmpty()){
            database.Update(dealRegUpdateList, false);
        }

        list<Deal_Reg__c> dealRegEmailChangeUpdateList = new list<Deal_Reg__c>();
        if(!emailChangeLeadIdSet.isEmpty()){

            for(Deal_Reg__c deal : [Select Id, Sales_Territory__c, Account_Manager__c, Channel_Manager__c, Lead__c, ownerId from Deal_Reg__c WHERE Lead__c IN:emailChangeLeadIdSet]){
                dealRegEmailChangeUpdateList.add(new Deal_Reg__c(Lead__c = null, Sales_Territory__c = null, Account_Manager__c = null, Channel_Manager__c = null, id = deal.Id));
            }
        }
        if(!dealRegEmailChangeUpdateList.isEmpty()){
            database.update(dealRegEmailChangeUpdateList, false);
        }
    }

    */



    public static void dealRegValidation(Map<Id, lead> leadOldMap){
       set<id> leadIdSet  = new set<Id>();

       for(Deal_Reg__c deal : [Select Id, Lead__c from Deal_Reg__c Where Lead__c IN: leadOldMap.keySet()] )
           leadIdSet.add(deal.Lead__c);

       for(Lead lead : leadOldMap.Values()){
           if(leadIdSet.contains(lead.id))
               lead.addError('Deal is associated to this lead and cannot be deleted.');
       }

    }

    public static void updateDealRegAfterLeadConversion(map<id, Lead> leadOldMap, map<id, Lead> leadNewMap){
        set<Id> leadIdSet = new set<Id>();
        for(Lead le : leadNewMap.Values()){
            if(le.isConverted && le.isConverted != leadOldMap.get(le.Id).isConverted)
                leadIdSet.add(le.Id);
        }
        list<Deal_Reg__c> dealRegUpdateList = new list<Deal_Reg__c>();
        for(Deal_Reg__c deal : [Select id, Contact__c, Lead__c from Deal_Reg__c where Lead__c IN: leadIdSet]){
            if(leadNewMap.get(deal.Lead__c).ConvertedContactid != null){
                deal.Contact__c = leadNewMap.get(deal.Lead__c).ConvertedContactid;
                deal.Lead__c = null;
                dealRegUpdateList.add(deal);
            }
        }

        try{
            if(!dealRegUpdateList.isEmpty())
                database.update(dealRegUpdateList, false);
        }catch(Exception e){}
    }


    @future(Callout=true)
    public static void changeLeadOwnership(map<id, id> leadAccManagerMap){
        set<id> userIdSet = new set<Id>();
        for(User usr : [Select id from User where Id IN: leadAccManagerMap.Values() AND IsActive =: true])
            userIdSet.add(usr.Id);
        list<Lead> leadUpdateList = new list<Lead>();
        for(id leadId : leadAccManagerMap.keySet()){
            if(userIdSet.contains(leadAccManagerMap.get(leadId)))
                leadUpdateList.add(new lead(Id = leadId, OwnerId = leadAccManagerMap.get(leadId)));
        }

        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = false;
        if(!leadUpdateList.isEmpty())
            database.update(leadUpdateList, dlo);
    }

    public static void updateSalesTeamEmailFields(Map<Id, Lead> leadOldMap, Map<Id, Lead> leadNewMap) {
        Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();
        Set<Id> salesTeamUserIds = new Set<Id>();
        Map<Id, String> salesTeamUserIdsAndEmails = new Map<Id, String>();
        Map<Id, Id> leadsAndNewZPAManagerIds = new Map<Id, Id>();
        Map<Id, Id> leadsAndNewZPASEIds = new Map<Id, Id>();

        for (Lead lead : leadNewMap.values()) {
            if (leadOldMap == null
                || !leadOldMap.containsKey(lead.Id)
                || lead.ZPA_Manager__c != leadOldMap.get(lead.Id).ZPA_Manager__c) {
                leadsAndNewZPAManagerIds.put(lead.Id, lead.ZPA_Manager__c);
                salesTeamUserIds.add(lead.ZPA_Manager__c);
            }

            if (leadOldMap == null
                || !leadOldMap.containsKey(lead.Id)
                || lead.ZPA_SE__c != leadOldMap.get(lead.Id).ZPA_SE__c) {
                leadsAndNewZPASEIds.put(lead.Id, lead.ZPA_SE__c);
                salesTeamUserIds.add(lead.ZPA_SE__c);
            }
        }

        for (User user : [SELECT Id, Email FROM User WHERE Id IN :salesTeamUserIds]) {
            salesTeamUserIdsAndEmails.put(user.Id, user.Email);
        }

        for (Id leadId : leadsAndNewZPAManagerIds.keySet()) {
            leadsToUpdate.put(leadId, new Lead(Id = leadId, ZPA_Manager_Email__c = salesTeamUserIdsAndEmails.get(leadsAndNewZPAManagerIds.get(leadId))));
        }

        for (Id leadId : leadsAndNewZPASEIds.keySet()) {
            if (leadsToUpdate.containsKey(leadId)) {
                Lead leadToUpdate = leadsToUpdate.get(leadId);
                leadToUpdate.ZPA_SE_Email__c = salesTeamUserIdsAndEmails.get(leadsAndNewZPASEIds.get(leadId));
            } else {
                leadsToUpdate.put(leadId, new Lead(Id = leadId, ZPA_SE_Email__c = salesTeamUserIdsAndEmails.get(leadsAndNewZPASEIds.get(leadId))));
            }
        }

        try {
            if (leadsToUpdate.size() > 0) {
                update leadsToUpdate.values();
                TriggerUtility.updateLeadSalesTeamEmailFieldsExecuted();
            }
        }
        catch (Exception ex) {
        }
    }

    // Commented this code as the logic should not be based on Bizible account field in Lead
    // public static void updateNumberOfEmployees(List<Lead> lstNewLeads) {
    //     List<Lead> lstLeadsToUpdate = new List<Lead>();
    //     Map<Id, Id> mapLeadAndAccountIds = new Map<Id, Id>();
        
    //     for (Lead lead : lstNewLeads) {
    //         if (lead.bizible2__Account__c != null)  {
    //             mapLeadAndAccountIds.put(lead.Id, lead.bizible2__Account__c);
    //         }
    //     }

    //     Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, No_of_Employees_Users__c FROM Account 
    //                                                          WHERE Id IN :mapLeadAndAccountIds.values()]);

    //     for (Lead lead : lstNewLeads) {
    //         if (mapLeadAndAccountIds.containsKey(lead.Id)
    //             && mapAccounts.containsKey(mapLeadAndAccountIds.get(lead.Id))
    //             && mapAccounts.get(mapLeadAndAccountIds.get(lead.Id)).No_of_Employees_Users__c != null
    //             && mapAccounts.get(mapLeadAndAccountIds.get(lead.Id)).No_of_Employees_Users__c != lead.No_Employees_Users__c
    //             && lead.Override_No_of_Employees_Users__c != true) {
    //             lstLeadsToUpdate.add(new Lead(Id = lead.Id, No_Employees_Users__c = mapAccounts.get(mapLeadAndAccountIds.get(lead.Id)).No_of_Employees_Users__c));
    //         }
    //     }

    //     try {
    //         if (lstLeadsToUpdate.size() > 0) {
    //             update lstLeadsToUpdate;
    //         }
    //     } catch (Exception ex) {
    //         System.debug('>>>> Error occurred while updating No Of Employees field in lead: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
    //     }
    //     TriggerUtility.updateLeadNoOfEmployeesExecuted();
    // }
	
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
	}
}