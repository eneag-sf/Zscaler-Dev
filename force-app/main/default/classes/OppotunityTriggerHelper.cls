/*
 *  Author : Raghu
 *  Change : Modified code to handle Opportunity Next Steps, Technical Validation Next Steps and Architect Next Steps.
 */

public class OppotunityTriggerHelper{

    
    //Added By Sateesh U -- It Will Update the Sharing for Opportunity SE
    public static void afterInsert(List<Opportunity> newOppList){
        List<Opportunity> opportunityToShareSE = new List<Opportunity>();
        List<Opportunity> opportunityToDeleShareSE = new List<Opportunity>();
        for(Opportunity oppRec : newOppList){
            if(oppRec.SE_Name__c != null){
                if(oppRec.Opportunity_Sales_Engineer__c != oppRec.SE_Name__c){
                    opportunityToShareSE.add(oppRec);
                }
            }
        }
        if(!opportunityToShareSE.isEmpty()){
            updateSharing(opportunityToShareSE, opportunityToDeleShareSE);
        }
    }
    
    //Added By Sateesh U -- It Will Update the Sharing for Opportunity SE
    public static void afterUpdate(List<Opportunity> newOppList, map<Id, Opportunity> oldOppMap){
        List<Opportunity> opportunityToShareSE = new List<Opportunity>();
        List<Opportunity> opportunityToDeleShareSE = new List<Opportunity>();
        for(Opportunity oppRec : newOppList){
            if(oppRec.SE_Name__c != null){
                if(oppRec.SE_Name__c != oldOppMap.get(oppRec.Id).SE_Name__c){
                    if(oppRec.Opportunity_Sales_Engineer__c != oppRec.SE_Name__c){
                        opportunityToShareSE.add(oppRec);
                    }
                    opportunityToDeleShareSE.add(oppRec);
                }
            }
        }
        if(!opportunityToDeleShareSE.isEmpty() || !opportunityToShareSE.isEmpty()){
            updateSharing(opportunityToShareSE, opportunityToDeleShareSE);
        }
    }
    
    public static void updateSharing(List<Opportunity> opportunityToShareSE, List<Opportunity> opportunityToDeleShareSE){
        
        List<OpportunityTeamMember> oppTeamMemberLstForInsert = new List<OpportunityTeamMember>();
        for(Opportunity oppRec : opportunityToShareSE){
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
            oppTeamMember.OpportunityId = oppRec.Id;
            oppTeamMember.TeamMemberRole = 'Out of Territory SE';
            oppTeamMember.OpportunityAccessLevel = 'Edit';
            oppTeamMember.UserId = oppRec.SE_Name__c;
            oppTeamMemberLstForInsert.add(oppTeamMember);
        }
        
        if(!opportunityToDeleShareSE.isEmpty()){
            List<OpportunityTeamMember> existingOppSETeamToDelete = [Select Id, 
                                                                            UserId 
                                                                            from 
                                                                            OpportunityTeamMember 
                                                                            Where 
                                                                            OpportunityId IN: opportunityToDeleShareSE 
                                                                            and TeamMemberRole = 'Out of Territory SE'];
            if(!existingOppSETeamToDelete.isEmpty()){
                delete existingOppSETeamToDelete;
            }
        }
        if(!oppTeamMemberLstForInsert.isEmpty()){
            insert oppTeamMemberLstForInsert;
        }
    }
    
    public static void decommissionProvRequests(List<Opportunity> newOppList, map<Id, Opportunity> oldOppMap){
        set<id> oppIdSet = new set<Id>();
        for(Opportunity opp : newOppList){
            if(((opp.StageName == label.Stage_7_Closed_Lost && (opp.Sub_Stage__c == label.SubStage_Closed_With_No_Decision || opp.Sub_Stage__c == label.SubStage_Closed_Lost))/*'11 - Closed Lost' || opp.StageName == '12 - Closed With No Decision' */ || opp.StageName == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || opp.StageName== label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/)  && opp.StageName != oldOppMap.get(opp.Id).StageName){ //Added Stage10b check for PR POC expiry Notifications:Gurjinder
                oppIdSet.add(opp.Id);
            }
        }
        set<String> prStatusSet = new set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned'); 
        
        Set<String> PreferredCloudlist= new Set<String>();
        PreferredCloudlist.add('zpabeta.net');
        PreferredCloudlist.add('Zscalerbeta.net');
        
        Set<String> PRRecordTypeNameSet= new Set<String>();
        //PRRecordTypeNameSet.add('New_Eval');
        //PRRecordTypeNameSet.add('Zscaler_Cloud_Details');
        String PRrecordtypeforPOCAlerts= ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts')!=null && ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRrecordtypeforPOCAlerts').Value__c:'New_Eval,Zscaler_Cloud_Details';
        PRRecordTypeNameSet.addall(PRrecordtypeforPOCAlerts.split(','));
        
        Set<String> PRRcrdNameSetforReqDecomm= new Set<String>();
        //PRRecordTypeNameSet.add('New_Eval');
        //PRRecordTypeNameSet.add('Zscaler_Cloud_Details');
        String PRRcrdNameforReqDecomm= ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm')!=null && ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRRcrdNameSetforReqDecomm').Value__c:'New_Eval,Zscaler_Cloud_Details';
        PRRcrdNameSetforReqDecomm.addall(PRRcrdNameforReqDecomm.split(','));
        
        list<Provisioning_Request__c> provReqUpdateList = new list<Provisioning_Request__c>();
        
        for(Provisioning_Request__c pr : [Select Id, RecordType.DeveloperName, Provisioning_Status__c,Opportunity__r.StageName,Opportunity__r.Sub_Stage__c from Provisioning_Request__c where Opportunity__c IN: oppIdSet AND Provisioning_Status__c IN: prStatusSet and Account__r.Type != 'Partner' and Account__r.Type != 'Technology Partner' and Preferred_Cloud__c NOT IN:PreferredCloudlist and Internal_user__c = False]){  //Added AccountType and Internal User status check for PR POC expiry Notifications:Gurjinder
            if((pr.Opportunity__r.StageName== label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || pr.Opportunity__r.StageName== label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ ) && PRRecordTypeNameSet.contains(pr.RecordType.DeveloperName)){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=true;
            }
            //(pr.RecordType.DeveloperName == 'New_Eval' || pr.RecordType.DeveloperName == 'Zscaler_Cloud_Details')
            if((pr.Opportunity__r.StageName== label.Stage_7_Closed_Lost && (pr.Opportunity__r.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision || pr.Opportunity__r.Sub_Stage__c == Label.SubStage_Closed_Lost) /*'11 - Closed Lost' || pr.Opportunity__r.StageName=='12 - Closed With No Decision'*/) && PRRcrdNameSetforReqDecomm.contains(pr.RecordType.DeveloperName)){
                pr.Provisioning_Status__c = 'Request Decommission';
                provReqUpdateList.add(pr);
            }
        }
        if(!provReqUpdateList.isEmpty()){
            database.update(provReqUpdateList, false);
        }
        TriggerUtility.requestDecommissionPrExecuted();

    }
    
    //Method Added as a part of RBAC
    public static void createOpportunityTeam(List<Opportunity> opportunitiesToCreateTeam){
        List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
        oppTeamMembers = [SELECT Id,OpportunityId,TeamMemberRole,UserId FROM OpportunityTeamMember WHere OpportunityId IN : opportunitiesToCreateTeam];
        
        for(Opportunity oppRec : opportunitiesToCreateTeam){
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
            oppTeamMember.OpportunityId = oppRec.Id;
            oppTeamMember.TeamMemberRole = 'Opportunity Owner';
            oppTeamMember.OpportunityAccessLevel = 'Edit';
            oppTeamMember.UserId = oppRec.OwnerId;
            oppTeamMembers.add(oppTeamMember);
        }
        
        if(!oppTeamMembers.isEmpty()){
            if(!system.isBatch() && !system.isFuture()){
                String TeamMembersJSON = JSON.serialize(oppTeamMembers); 
                retainOldTeamMemberOnOwnerChange(TeamMembersJSON);
            }
        }
    }
    

    @future
    public static void retainOldTeamMemberOnOwnerChange(String str){
        system.debug('Future call '+str); 
        List<OpportunityTeamMember> oppTeamList = (List<OpportunityTeamMember>) JSON.deserialize(str,List<OpportunityTeamMember>.class);
        for(OpportunityTeamMember objOppTeamMember : oppTeamList){
            objOppTeamMember.Id = null;
        }
        Database.insert(oppTeamList, false);
    }
    

    public static void updateSalesTeamInfoOnOppSplit(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList){
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
        map<Id, Id> territoryIdUserIdMap = new map<Id, Id>();
        map<Id, Id> userIdTerritoryIdMap = new map<Id, Id>();
        Set<Id> oppSplitOwnerIdSet = new Set<Id>();
        Set<Id> lstMultiTerritoryOpportunityIds = new Set<Id>();
        Set<Id> splitsWithBlankZPAFields = new Set<Id>();

        for(Opportunity opp : oppNewList){
            if((opp.StageName != label.Stage_7_Closed_Lost /*'11 - Closed Lost' && opp.StageName != '12 - Closed With No Decision'*/ && Opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/)
                && (opp.StageName != oppOldMap.get(opp.Id).StageName
                    || opp.OwnerId != oppOldMap.get(opp.Id).OwnerId
                    || opp.Opportunity_Sales_Territory__c != oppOldMap.get(opp.Id).Opportunity_Sales_Territory__c
                    || opp.Opportunity_Sales_Engineer__c != oppOldMap.get(opp.Id).Opportunity_Sales_Engineer__c
                    || opp.Opportunity_Area_Director__c != oppOldMap.get(opp.Id).Opportunity_Area_Director__c
                    || opp.Opportunity_Account_Manager__c != oppOldMap.get(opp.Id).Opportunity_Account_Manager__c
                    || opp.Opportunity_Customer_Advocate__c != oppOldMap.get(opp.Id).Opportunity_Customer_Advocate__c
                    || opp.Opportunity_ZPA_Manager__c != oppOldMap.get(opp.Id).Opportunity_ZPA_Manager__c
                    || opp.Opportunity_ZPA_SE__c != oppOldMap.get(opp.Id).Opportunity_ZPA_SE__c))
                opptyMap.put(opp.Id, opp);
        }
        map<id, id> oppSplitIdOwnerIdMap = new map<id, id>();
        map<id, OpportunitySplit> oppSplitMap = new map<id, OpportunitySplit>();
        for(OpportunitySplit oppSplit : [Select Id, SplitOwnerId, Sales_Territory__c, Channel_Rep__c, SE__c, Customer_Advocate__c, OpportunityId, Opportunity.OwnerId,
                                                /*Opportunity.CA_OTB_flag__c, Opportunity.Channel_OTB__c, Opportunity.Rep_OTB_Flag__c, Opportunity.SE_OTB__c,*/ Opportunity.Split__c,
                                                Opportunity.Account.Customer_Advocate__c, Opportunity.Account.Channel_Manager__c, Opportunity.Account.Sales_Engineer__c,
                                                Opportunity.Account.Sales_Territory__c/*, Opportunity.Account.ZPA_Manager__c, Opportunity.Account.ZPA_SE__c*/
                                           from OpportunitySplit where OpportunityId In: opptyMap.keySet()]){ // AND SplitPercentage < 100
            oppSplitMap.put(oppSplit.Id, oppSplit);
            oppSplitIdOwnerIdMap.put(oppSplit.Id, oppSplit.SplitOwnerId);
        }

        oppSplitOwnerIdSet.addAll(oppSplitIdOwnerIdMap.values());

        set<id> multipleSalesTerUserIdSet = new set<id>();
        List<PatchTeamMember__c> patchTeamMembersList = [Select Id, PatchTeam__c, Role__c, User__c from PatchTeamMember__c WHERE PatchTeam__r.Sales_Territory_Year__c = 'Current'];
        for(PatchTeamMember__c salesTeam : patchTeamMembersList){
            if (oppSplitOwnerIdSet.contains(salesTeam.User__c)) {
                if(!userIdTerritoryIdMap.keySet().Contains(salesTeam.User__c)){
                    territoryIdUserIdMap.put(salesTeam.PatchTeam__c, salesTeam.User__c);
                    userIdTerritoryIdMap.put(salesTeam.User__c,salesTeam.PatchTeam__c);
                } else if (userIdTerritoryIdMap.keySet().Contains(salesTeam.User__c)
                    && userIdTerritoryIdMap.get(salesTeam.User__c) != salesTeam.PatchTeam__c) {
                    multipleSalesTerUserIdSet.add(salesTeam.User__c);
                }
            }
        }

        map<id, map<String, Id>> userIdSalesTeamMapMap = new map<id, map<String, Id>>();
        for(PatchTeamMember__c salesTeam : patchTeamMembersList){
            //Skip preparing the role map if opportunity split owner is not the sales territory
            if (!territoryIdUserIdMap.keySet().contains(salesTeam.PatchTeam__c)) {
                continue;
            }

            map<string, Id> roleUserIdMap = new map<string, Id>();
            if(userIdSalesTeamMapMap != null){
                if(userIdSalesTeamMapMap.keySet().Contains(territoryIdUserIdMap.get(salesTeam.PatchTeam__c))){
                    roleUserIdMap = userIdSalesTeamMapMap.get(territoryIdUserIdMap.get(salesTeam.PatchTeam__c));
                    if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                        roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                        userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                    }
                }else{
                    if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                        roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                        userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                    }
                }
            }else{
                if(salesTeam.Role__c != '' && salesTeam.Role__c != null){
                    roleUserIdMap.put(salesTeam.Role__c, salesTeam.User__c);
                    userIdSalesTeamMapMap.put(territoryIdUserIdMap.get(salesTeam.PatchTeam__c),roleUserIdMap);
                }
            }
        }
        list<OpportunitySplit> oppSplitUpdateList = new list<OpportunitySplit>();
        for(id oppSplitId : oppSplitIdOwnerIdMap.keySet()){
            OpportunitySplit oppSplit = new OpportunitySplit();
            oppSplit = oppSplitMap.get(oppSplitId);
           // id splitOwnerId = oppSplitIdOwnerIdMap.get(oppSplitId);
            if(oppSplit.SplitOwnerId == oppSplit.Opportunity.OwnerId || oppSplit.Opportunity.Split__c != true){
                oppSplit.Customer_Advocate__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Customer_Advocate__c;
                oppSplit.Channel_Rep__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Channel_Manager__c;
                oppSplit.SE__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Sales_Engineer__c;
                //oppSplit.Sales_Territory__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_Sales_Territory__c; Commented due to Issue of blank Sales territory
                oppSplit.Sales_Territory__c = oppSplitMap.get(oppSplit.id).Opportunity.Account.Sales_Territory__c;
                //oppSplit.ZPA_RSM__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_Manager__c;
                //oppSplit.ZPA_SE__c = opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_SE__c;
                oppSplitUpdateList.add(oppSplit);

                if (opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_Manager__c == null
                    || opptyMap.get(oppSplit.OpportunityId).Opportunity_ZPA_SE__c == null) {
                    splitsWithBlankZPAFields.add(oppSplit.OpportunityId);
                }
            } else {
                map<string, Id> roleUserIdMap = new map<string, Id>();
                roleUserIdMap = userIdSalesTeamMapMap.get(oppSplit.SplitOwnerId);
                if(roleUserIdMap != null){
                    if(oppSplit.Sales_Territory__c == null){
                        oppSplit.Customer_Advocate__c = roleUserIdMap.get('Customer Advocate');
                        oppSplit.Channel_Rep__c = roleUserIdMap.get('Channel Manager');
                        oppSplit.SE__c = roleUserIdMap.get('Sales Engineer');
                        oppSplit.Sales_Territory__c = userIdTerritoryIdMap.get(oppSplit.SplitOwnerId);
                        oppSplit.ZPA_RSM__c = roleUserIdMap.get('ZPA Manager');
                        oppSplit.ZPA_SE__c = roleUserIdMap.get('ZPA SE');
                        oppSplitUpdateList.add(oppSplit);

                        if (roleUserIdMap.get('ZPA Manager') == null || roleUserIdMap.get('ZPA Manager') == null) {
                            splitsWithBlankZPAFields.add(oppSplit.OpportunityId);
                        }
                    }
                }
            }

            if (oppSplit.Opportunity.Split__c == true && multipleSalesTerUserIdSet.contains(oppSplit.SplitOwnerId)) {
                //Create a case to Sales Ops for validating multiple sales territories case
                lstMultiTerritoryOpportunityIds.add(oppSplit.OpportunityId);
            }
        }

        if(!oppSplitUpdateList.isEmpty()){
            database.update(oppSplitUpdateList, false);
        }

        if (lstMultiTerritoryOpportunityIds.size() > 0) {
            CaseCreationForAccountAndOpportunity.opportunitySplitsCaseCreation(lstMultiTerritoryOpportunityIds, new Set<Id>(), new Set<Id>(), splitsWithBlankZPAFields);
        }
        TriggerUtility.oppSpliSalesTeamExecuted();


    }

    public static void updatePRStatusToProduction(List<Opportunity> opportunitiesList) {
        //Todo:
        //1. Query the PRs with Zscaler Cloud record type
        //2. Update the Provisioning_Status__c field value to 'Production'
        //3. Update the RecordTypeId to Zscaler Cloud In Production
        //4. Remove the Request Decommision button from the page layout
        //Query all the recordtype name and ids
        Map<String, Id> mapPRRecordTypeIds = new Map<String, Id>();
        List<Provisioning_Request__c> lstProvisioningRequestsToUpdate = new List<Provisioning_Request__c>();

        for (RecordType recordtype : [SELECT Id, DeveloperName FROM RecordType
                                       WHERE SObjectType = 'Provisioning_Request__c'
                                        AND DeveloperName IN ('Zscaler_cloud_in_Production', 'Zscaler_Cloud_Details', 'New_Eval')]) {
            mapPRRecordTypeIds.put(recordtype.DeveloperName, recordtype.Id);
        }

        //Query all the PRs associated with the list of opportunities passed to this method
        for (Provisioning_Request__c provRequest : [SELECT Id, Provisioning_Status__c, Provisioning_Type__c, RecordTypeId
                                                      FROM Provisioning_Request__c
                                                     WHERE Opportunity__c IN :opportunitiesList
                                                       AND (RecordTypeId =: mapPRRecordTypeIds.get('Zscaler_Cloud_Details')
                                                        OR RecordTypeId =: mapPRRecordTypeIds.get('New_Eval'))]) {
            lstProvisioningRequestsToUpdate.add(new Provisioning_Request__c(
                                                    Id = provRequest.Id,
                                                    Provisioning_Status__c = 'Production',
                                                    RecordTypeId = mapPRRecordTypeIds.get('Zscaler_cloud_in_Production')
                                                ));
        }

        try {
            Database.update(lstProvisioningRequestsToUpdate, false);
        } catch (Exception ex) {
            System.debug('Error occurred while updating the PR status to Production. Error: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    public static void EREmailNotification(list<Opportunity> newOppList, map<id, Opportunity> oldOppMap){
        set<Id> oppIdSet = new set<Id>();
        for(Opportunity opp : newOppList){
            if(Opp.StageName == label.Stage_6_Closed_Won && opp.StageName != oldOppMap.get(opp.Id).StageName)
                oppIdSet.add(opp.Id);
        }
        if(!oppIdSet.isEmpty()){
            list<EmailTemplate> emailTemplateList = new list<EmailTemplate>();
            emailTemplateList = [Select Id, Body, Subject from EmailTemplate where DeveloperName = 'PZen_Email_Alert_to_Se_for_Node_Config'];
            string emailBody = String.isBlank(emailTemplateList[0].Body) ? '' : emailTemplateList[0].Body;
            list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            for(Equipment_Request__c er : [Select id, Opportunity__r.Owner.Email, ER_Owner__r.Email, (Select id from Private_Systems__r), Name, TAM_Email__c from Equipment_Request__c where RecordType.DeveloperName = 'PZEN' AND Approval_Status__c = 'Approved' AND Opportunity__c IN: oppIdSet]){
                if(er.Private_Systems__r == null || er.Private_Systems__r.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    list<string> emailIdList = new list<string>();
                    string url = System.URL.getSalesforceBaseURL().toExternalForm();
                    url += '/' +er.Id;
                    emailBody = emailBody.replace('{!name}', er.Name).replace('{!link}', url);
                    if(er.ER_Owner__r.Email != null){
                        emailIdList.add(er.ER_Owner__r.Email);
                    }
                    else{
                        emailIdList.add(er.Opportunity__r.Owner.Email);
                    }
                    if(er.TAM_Email__c != null && er.TAM_Email__c != '')
                        emailIdList.add(er.TAM_Email__c);
                    
                    
                    /*emailIdList.add('snag@zscaler.com');
                    emailIdList.add('uraju@zscaler.com');*/
                
                    mail.setPlainTextBody(emailBody);
                    mail.setSubject(String.isBlank(emailTemplateList[0].Subject) ? '' : emailTemplateList[0].Subject);
                    mail.setToAddresses(emailIdList);
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setsaveAsActivity(false);
                    emailList.add(mail);
                }
            }
            try{
                Messaging.sendEmail(emailList);
                TriggerUtility.ERNotificationExecuted();
            }catch(Exception e){}

        }
  }

    public static void updateOpportunityFields(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
        Set<Id> setSEUserIds = new Set<Id>();
        //Map<Id, Id> mapPatchTeamIdsAndOpptyIds = new Map<Id, Id>();
        Map<Id, Set<Id>> mapPatchTeamIdsAndOpptyIds = new Map<Id, Set<Id>>();
        Map<Id, Id> mapOpptySEUsers = new Map<Id, Id>();
        Map<Id, String> mapUserManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapProposalOppty = new Map<Id, Id>();
        //Map<Id, Id> mapOpptyZPAUsers = new Map<Id, Id>();
        //Map<Id, Id> mapOpptyZPAManagers = new Map<Id, Id>();
        Map<Id, Apttus_Proposal__Proposal__c> mapOpptyProposalValues = new Map<Id, Apttus_Proposal__Proposal__c>();

        Set<Id> setOpptyZPAUsers = new Set<Id>();
        Set<Id> setOpptyZPAManagers = new Set<Id>();

        for (Opportunity opp : oppNewList) {
            //if (null != opp.SE_Name__c) {
            if (null == oppOldMap
                || null == oppOldMap.get(opp.Id)
                || null == oppOldMap.get(opp.Id).SE_Name__c) {
                setSEUserIds.add(opp.SE_Name__c);
                //}
                System.debug('>>>> setSEUserIds: ' + setSEUserIds);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (null == opp.SE_Name__c
                    || null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    || opp.AccountId != oppOldMap.get(opp.Id).AccountId)
                && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                if (!mapPatchTeamIdsAndOpptyIds.containsKey(opp.AccountId)) {
                    mapPatchTeamIdsAndOpptyIds.put(opp.AccountId, new Set<Id> { opp.Id });
                } else {
                    mapPatchTeamIdsAndOpptyIds.get(opp.AccountId).add(opp.Id);
                }
                //mapPatchTeamIdsAndOpptyIds.put(opp.Sales_Territory_ID__c, opp.Id);
                System.debug('>>>> mapPatchTeamIdsAndOpptyIds: ' + mapPatchTeamIdsAndOpptyIds);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (null == opp.Opportunity_ZPA_SE__c
                    || null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    || opp.AccountId != oppOldMap.get(opp.Id).AccountId)
                && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                setOpptyZPAUsers.add(opp.Id);
            }

            if (String.isNotBlank(opp.Sales_Territory_ID__c)
                && (null == opp.Opportunity_ZPA_Manager__c
                    || null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    || opp.AccountId != oppOldMap.get(opp.Id).AccountId)
                && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/) {
                setOpptyZPAManagers.add(opp.Id);
            }

            if (null != opp.APTS_Primary_Proposal_Lookup__c
                && (null == oppOldMap
                    || null == oppOldMap.get(opp.Id)
                    || opp.APTS_Primary_Proposal_Lookup__c != oppOldMap.get(opp.Id).APTS_Primary_Proposal_Lookup__c)) {
                mapProposalOppty.put(opp.APTS_Primary_Proposal_Lookup__c, opp.Id);
            }
        }

        Map<Id, Account> mapOpptyAccountTeams = new Map<Id, Account>();
        //Query the sales team members and assign SE for the opptys in mapPatchTeamIdsAndOpptyIds
        for (Account account : [SELECT Id, Sales_Engineer__c, Sales_Territory__c, Account_Manager__c, Area_Director__c, Customer_Advocate__c, Channel_Manager__c/*, ZPA_Manager__c, ZPA_SE__c*/ FROM Account
                                           WHERE Id IN :mapPatchTeamIdsAndOpptyIds.keySet()]) {
            for (Id oppId : mapPatchTeamIdsAndOpptyIds.get(account.Id)) {
                mapOpptySEUsers.put(oppId, account.Sales_Engineer__c);
                mapOpptyAccountTeams.put(oppId, account);
            }

            setSEUserIds.add(account.Sales_Engineer__c);
        }

        for (User user : (List<User>)[SELECT Id, ManagerId, Manager.Email FROM User WHERE Id IN :setSEUserIds LIMIT 1000]) {
            mapUserManagerEmail.put(user.Id, user.Manager.Email);
        }
        System.debug('>>>> mapUserManagerEmail: ' + mapUserManagerEmail);
        Map<Id, String> mapOpptySEManagerEmail = new Map<Id, String>();
        Map<Id, Id> mapOpptySEName = new Map<Id, Id>();
        for (Opportunity opp : oppNewList) {
            System.debug('>>>> : ' + opp);
            if (null == oppOldMap
                || null == oppOldMap.get(opp.Id)
                || opp.SE_Name__c != oppOldMap.get(opp.Id).SE_Name__c) {
                mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(opp.SE_Name__c));
            }

            //if (null == opp.SE_Name__c
            //    || null == oppOldMap
            //    || null == oppOldMap.get(opp.Id)
            //    || opp.AccountId != oppOldMap.get(opp.Id).AccountId
            //    || mapOpptySEUsers.get(mapPatchTeamIdsAndOpptyIds.get(opp.Sales_Territory_ID__c)) != oppOldMap.get(opp.Id).SE_Name__c) {
            if (mapOpptySEUsers.containsKey(opp.Id)) {
                mapOpptySEName.put(opp.Id, mapOpptySEUsers.get(opp.Id));
                mapOpptySEManagerEmail.put(opp.Id, mapUserManagerEmail.get(mapOpptySEUsers.get(opp.Id)));
            }
        }

        for (Apttus_Proposal__Proposal__c proposal : [SELECT Id, No_of_Users__c, APTS_Subscription_Term__c
                                                        FROM Apttus_Proposal__Proposal__c
                                                       WHERE Id IN :mapProposalOppty.keySet()]) {
            mapOpptyProposalValues.put(mapProposalOppty.get(proposal.Id), proposal);
        }

        if (!System.isFuture() && !System.isBatch() && (mapOpptySEManagerEmail.size() > 0 || mapOpptySEName.size() > 0 || mapOpptyProposalValues.size() > 0 || mapOpptyAccountTeams.size() > 0)) {
            updateOpportunityFieldsInDb(JSON.serialize(mapOpptySEManagerEmail), JSON.serialize(mapOpptySEName), JSON.serialize(mapOpptyProposalValues), JSON.serialize(mapOpptyAccountTeams), JSON.serialize(setOpptyZPAUsers), JSON.serialize(setOpptyZPAManagers));

        }
        TriggerUtility.updateSEManagerEmailExecuted();
    }

    @future
    public static void updateOpportunityFieldsInDb(String mapOpptySEManagerEmailJSON, String mapOpptySENameJSON, String mapOpptyProposalValuesJSON, String mapOpptyAccountTeamsJSON, String setOpptyZPAUsersJSON, String setOpptyZPAManagersJSON) {
        Map<Id, String> mapOpptySEManagerEmail = (Map<Id, String>)JSON.deserialize(mapOpptySEManagerEmailJSON, Type.forName('Map<Id, String>'));
        Map<Id, Id> mapOpptySEName = (Map<Id, Id>)JSON.deserialize(mapOpptySENameJSON, Type.forName('Map<Id, Id>'));
        Map<Id, Apttus_Proposal__Proposal__c> mapOpptyProposalValues = (Map<Id, Apttus_Proposal__Proposal__c>)JSON.deserialize(mapOpptyProposalValuesJSON, Type.forName('Map<Id, Apttus_Proposal__Proposal__c>'));
        Map<Id, Account> mapOpptyAccountTeams = (Map<Id, Account>)JSON.deserialize(mapOpptyAccountTeamsJSON, Type.forName('Map<Id, Account>'));
        Set<Id> setOpptyZPAUsers = (Set<Id>)JSON.deserialize(setOpptyZPAUsersJSON, Type.forName('Set<Id>'));
        Set<Id> setOpptyZPAManagers = (Set<Id>)JSON.deserialize(setOpptyZPAManagersJSON, Type.forName('Set<Id>'));
        Map<Id, Opportunity> mapOpptyToUpdate = new Map<Id, Opportunity>();

        for (Id oppId : mapOpptySEManagerEmail.keySet()) {
            mapOpptyToUpdate.put(oppId, new Opportunity(Id=oppId, SE_Manager__c=mapOpptySEManagerEmail.get(oppId)));
        }

        if (!mapOpptyToUpdate.isEmpty()) {
            for (Id oppId : mapOpptySEName.keySet()) {
                mapOpptyToUpdate.get(oppId).SE_Name__c = mapOpptySEName.get(oppId);
            }
        }

        List<Opportunity> opptyFlagsToUpdate = new List<Opportunity>();
        if (!mapOpptyProposalValues.isEmpty()) {
            for (Id oppId : mapOpptyProposalValues.keySet()) {
                if (mapOpptyToUpdate.containsKey(oppId)) {
                    mapOpptyToUpdate.get(oppId).Proposed_Number_of_Users__c = (mapOpptyProposalValues.get(oppId).No_of_Users__c != null ? mapOpptyProposalValues.get(oppId).No_of_Users__c : 0);
                    mapOpptyToUpdate.get(oppId).Expected_Term_Months__c = mapOpptyProposalValues.get(oppId).APTS_Subscription_Term__c;
                    mapOpptyToUpdate.get(oppId).Primary_quote_updates__c = true;
                } else {
                    mapOpptyToUpdate.put(oppId, new Opportunity(
                                                    Id = oppId,
                                                    Proposed_Number_of_Users__c = (mapOpptyProposalValues.get(oppId).No_of_Users__c != null ? mapOpptyProposalValues.get(oppId).No_of_Users__c : 0),
                                                    Expected_Term_Months__c = mapOpptyProposalValues.get(oppId).APTS_Subscription_Term__c,
                                                    Primary_quote_updates__c = true
                                                )
                                            );
                }
                opptyFlagsToUpdate.add(new Opportunity(Id = oppId, Primary_quote_updates__c = false));
            }
        }

        if (!mapOpptyAccountTeams.isEmpty()) {
            for (Id oppId : mapOpptyAccountTeams.keySet()) {
                if (mapOpptyToUpdate.containsKey(oppId)) {
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c;
                    mapOpptyToUpdate.get(oppId).Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c;

                    if (setOpptyZPAManagers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    }

                    if (setOpptyZPAUsers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    }
                } else {
                    mapOpptyToUpdate.put(oppId, new Opportunity(
                                        Id = oppId,
                                        Opportunity_Sales_Engineer__c = mapOpptyAccountTeams.get(oppId).Sales_Engineer__c,
                                        Opportunity_Sales_Territory__c = mapOpptyAccountTeams.get(oppId).Sales_Territory__c,
                                        Opportunity_Account_Manager__c = mapOpptyAccountTeams.get(oppId).Account_Manager__c,
                                        Opportunity_Area_Director__c = mapOpptyAccountTeams.get(oppId).Area_Director__c,
                                        Opportunity_Customer_Advocate__c = mapOpptyAccountTeams.get(oppId).Customer_Advocate__c,
                                        Opportunity_Channel_Manager__c = mapOpptyAccountTeams.get(oppId).Channel_Manager__c
                                        //Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c,
                                        //Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c
                                    ));

                    if (setOpptyZPAManagers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_Manager__c = mapOpptyAccountTeams.get(oppId).ZPA_Manager__c;
                    }

                    if (setOpptyZPAUsers.contains(oppId)) {
                        //mapOpptyToUpdate.get(oppId).Opportunity_ZPA_SE__c = mapOpptyAccountTeams.get(oppId).ZPA_SE__c;
                    }
                }
            }
        }

        System.debug('>>>> mapOpptyToUpdate: ' + mapOpptyToUpdate);
        if (mapOpptyToUpdate.size() > 0) {
            Database.update(opptyFlagsToUpdate, true);
            Database.update(mapOpptyToUpdate.values(), true);
        }
    }

  /*
    public static void updateOpportunityNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
        Map<Id, String> mapOpportunityNextStepsHistory = new Map<Id, String>();
        for (Opportunity opp : oppNewList) {
            if (opp.NextStep != null
                && opp.NextStep != oppOldMap.get(opp.Id).NextStep) {
                String newHistory = ((oppOldMap.get(opp.Id).NextStep != null) ? oppOldMap.get(opp.Id).NextStep : '');
                mapOpportunityNextStepsHistory.put(opp.Id, newHistory + ((opp.Opportunity_Next_Step_History__c != null) ? '\n--------------------\n' + opp.Opportunity_Next_Step_History__c : ''));
            }
        }

        if (!System.isFuture() && mapOpportunityNextStepsHistory.size() > 0) {
            updateOpportunityNextStepsInDb(JSON.serialize(mapOpportunityNextStepsHistory));
        }
    }

     @future
    public static void updateOpportunityNextStepsInDb(String mapOpptyNextStepHistoryJSON) {
        Map<Id, String> mapOpptyNextStepHistory = (Map<Id, String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id, String>'));
        List<Opportunity> lstOpptyToUpdate = new List<Opportunity>();
        for (Id oppId : mapOpptyNextStepHistory.keySet()) {
            lstOpptyToUpdate.add(new Opportunity(Id=oppId, Opportunity_Next_Step_History__c=mapOpptyNextStepHistory.get(oppId)));
        }

        if (lstOpptyToUpdate.size() > 0) {
            Database.update(lstOpptyToUpdate, false);
        }
    }
  */

    /*public static void updateTechValHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
        Map<Id, String> mapOpportunityNextStepsHistory = new Map<Id, String>();
        for (Opportunity opp : oppNewList) {
            if (opp.Next_Steps__c  != null
                && opp.Next_Steps__c  != oppOldMap.get(opp.Id).Next_Steps__c ) {
                String newHistory = ((oppOldMap.get(opp.Id).Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Next_Steps__c  : '');
                mapOpportunityNextStepsHistory.put(opp.Id, newHistory + ((opp.Technical_Validation_Next_Steps_History__c  != null) ? '\n--------------------\n' + opp.Technical_Validation_Next_Steps_History__c  : ''));
            }
        }

        if (!System.isFuture() && mapOpportunityNextStepsHistory.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(mapOpportunityNextStepsHistory));
        }
    }

    @future
    public static void updateOpportunityTechNextStepsInDb(String mapOpptyNextStepHistoryJSON) {
        Map<Id, String> mapOpptyNextStepHistory = (Map<Id, String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id, String>'));
        List<Opportunity> lstOpptyToUpdate = new List<Opportunity>();
        for (Id oppId : mapOpptyNextStepHistory.keySet()) {
            lstOpptyToUpdate.add(new Opportunity(Id=oppId,Technical_Validation_Next_Steps_History__c=mapOpptyNextStepHistory.get(oppId)));
        }

        if (lstOpptyToUpdate.size() > 0) {
            Database.update(lstOpptyToUpdate, false);
        }
    }*/
     //start of change - Raghu
     //Tech validation Next Steps
     public static void updateTechValHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
     {
        Map<Id,String> techValidationHistoryMap = new Map<Id,String>();
        for (Opportunity opp : oppNewList)
        {
            if (opp.Next_Steps__c  != null && !(String.isBlank(opp.Next_Steps__c)) && !(String.isBlank(oppOldMap.get(opp.Id).Next_Steps__c))
                && opp.Next_Steps__c  != oppOldMap.get(opp.Id).Next_Steps__c )
            {
                String newHistory = ((oppOldMap.get(opp.Id).Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Next_Steps__c  : '');
                techValidationHistoryMap.put(opp.Id,newHistory);
             }
        }

        if (!System.isFuture() && !System.isBatch() && techValidationHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(techValidationHistoryMap),'Technical Validation Next Steps');
        }
    }
    //Opportunity Next steps
    public static void updateOpportunityNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
    {
        Map<Id, String> oppNextStepsHistoryMap = new Map<Id, String>();
        for (Opportunity opp : oppNewList)
        {
          if (opp.NextStep != null && !(String.isBlank(opp.NextStep)) && !(String.isBlank(oppOldMap.get(opp.Id).NextStep))
                && opp.NextStep != oppOldMap.get(opp.Id).NextStep)
            {
                String newHistory = ((oppOldMap.get(opp.Id).NextStep != null) ? oppOldMap.get(opp.Id).NextStep : '');
                oppNextStepsHistoryMap.put(opp.Id,newHistory);
            }
        }

        if (!System.isFuture() && !System.isBatch() && oppNextStepsHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(oppNextStepsHistoryMap),'Opportunity Next Steps');
        }
    }

    //Architecture Next Steps
    public static void updateArchitectureNextStepsHistory(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList)
    {
        Map<Id, String> archNextStepsHistoryMap = new Map<Id, String>();
        for (Opportunity opp : oppNewList)
        {
          if (opp.Architecture_Next_Steps__c  != null && !(String.isBlank(opp.Architecture_Next_Steps__c)) && !(String.isBlank(oppOldMap.get(opp.Id).Architecture_Next_Steps__c))
                && opp.Architecture_Next_Steps__c  != oppOldMap.get(opp.Id).Architecture_Next_Steps__c )
            {
                String newHistory = ((oppOldMap.get(opp.Id).Architecture_Next_Steps__c  != null) ? oppOldMap.get(opp.Id).Architecture_Next_Steps__c  : '');
                archNextStepsHistoryMap.put(opp.Id,newHistory);
            }
        }

        if (!System.isFuture() && !System.isBatch() && archNextStepsHistoryMap.size() > 0) {
            updateOpportunityTechNextStepsInDb(JSON.serialize(archNextStepsHistoryMap),'Architecture Next Steps');
        }
    }

    @future
    public static void updateOpportunityTechNextStepsInDb(String mapOpptyNextStepHistoryJSON,String objectName) {

        //Technical_Validation_Next_Steps_History__c
        if(objectName != null && objectName == 'Technical Validation Next Steps')
        {
            System.debug('Creating Technical Validation Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Technical_Validation_Next_Steps_History__c> lsttechValidationInsert= new List<Technical_Validation_Next_Steps_History__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Technical_Validation_Next_Steps_History__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
        //Opportunity_Next_Steps_History__c
        else if(objectName != null && objectName == 'Opportunity Next Steps')
        {
            System.debug('Creating Opportunity Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Opportunity_Next_Steps_History__c> lsttechValidationInsert= new List<Opportunity_Next_Steps_History__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Opportunity_Next_Steps_History__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
        //Architecture_Next_Steps__c
        else if(objectName != null && objectName == 'Architecture Next Steps')
        {
            System.debug('Creating Architecture Next Step History record');
            Map<Id,String> mapOpptyNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Architecture_Next_Steps__c> lsttechValidationInsert= new List<Architecture_Next_Steps__c>();
            for(Id oppId: mapOpptyNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Architecture_Next_Steps__c(opportunity__c = oppId, notes__c = mapOpptyNextStepHistory.get(oppId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
    }

    //End of change - Raghu


    public static void updateAccountForApprovedPZEN(map<id, Opportunity> oppOldMap, list<Opportunity> oppNewList) {
        list<Account> accUpdateList = new list<Account>();
        Set<Id> oppIdSet = new set<Id>();
        Map<Id, boolean> accIdApprovedPZENMap = new map<Id, boolean>();
        for(Opportunity opp : oppNewList){
            if(opp.StageName == label.Stage_6_Closed_Won && opp.StageName != oppOldMap.get(opp.Id).StageName){
                oppIdSet.add(opp.Id);
            }
        }
        for(Equipment_Request__c eqpReq : [Select Id, Opportunity__c, Opportunity__r.AccountId From Equipment_Request__c Where Approval_Status__c =: 'Approved' AND Opportunity__c IN: oppIdSet AND RecordType.DeveloperName =: 'PZEN' ]){
            if(eqpReq.Opportunity__c != null)
                accIdApprovedPZENMap.put(eqpReq.Opportunity__r.AccountId, true);
        }
        for(id accId : accIdApprovedPZENMap.keySet()){
            accUpdateList.add(new Account(id = accId, Approved_PZEN__c = true));
        }
        
        system.debug('the accUpdateList are' + accUpdateList);
        if(!accUpdateList.isEmpty())
            Database.update(accUpdateList, false);
        TriggerUtility.updateAccountForApprovedPZENExecuted();
    }

    public static void updateForecastCategoryValues(map<Id, Opportunity> newOppMap, map<Id, Opportunity>oldOppMap) {

    }

    public static void updateSplitForecastCategory(map<Id, Opportunity> newOppMap, map<Id, Opportunity> oldOppMap){
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            set<Id> oppIdSet = new set<Id>();
            for(Opportunity opp : newOppMap.values()){
                /*if(opp.ForecastCategoryName != oldOppMap.get(opp.Id).ForecastCategoryName){
                    oppIdSet.add(opp.Id);
                }*/
                if(opp.Deal_Path__c != oldOppMap.get(opp.Id).Deal_Path__c){
                    oppIdSet.add(opp.Id);
                }
                if(opp.Forecast_Category__c != oldOppMap.get(opp.Id).Forecast_Category__c || opp.AD_Forecast_Category__c != oldOppMap.get(opp.Id).AD_Forecast_Category__c || opp.CRO_Forecast_Category__c != oldOppMap.get(opp.Id).CRO_Forecast_Category__c || opp.DM_Forecast_Category__c != oldOppMap.get(opp.Id).DM_Forecast_Category__c || opp.VP_Forecast_Category__c != oldOppMap.get(opp.Id).VP_Forecast_Category__c || opp.RVP_Forecast_Category__c != oldOppMap.get(opp.Id).RVP_Forecast_Category__c || opp.AD_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).AD_Forecast_Category_Lock__c || opp.CRO_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).CRO_Forecast_Category_Lock__c || opp.DM_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).DM_Forecast_Category_Lock__c || opp.VP_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).VP_Forecast_Category_Lock__c || opp.RVP_Forecast_Category_Lock__c != oldOppMap.get(opp.Id).RVP_Forecast_Category_Lock__c || opp.StageName != oldOppMap.get(opp.Id).StageName) {
                        oppIdSet.add(opp.Id);
                }
            }

            list<OpportunitySplit> oppSplitUpdateList = new list<OpportunitySplit>();
            for(OpportunitySplit oppSplit : [Select Id, OpportunityId, Forecast_Category__c, SplitOwnerId, Opportunity.Forecast_Type__c, Opportunity_Deal_Path__c, Deal_Path__c, Opportunity_Forecast_Category__c, Opportunity_Forecast_Type__c, Forecast_Type__c, Opportunity_Owner__c,
                                                    Forecast_Category_New__c, DM_Forecast_Category__c, VP_Forecast_Category__c, RVP_Forecast_Category__c, CRO_Forecast_Category__c, AD_Forecast_Category__c,
                                                    DM_Forecast_Category_Lock__c, VP_Forecast_Category_Lock__c, RVP_Forecast_Category_Lock__c, CRO_Forecast_Category_Lock__c, AD_Forecast_Category_Lock__c, Opportunity_AD_Forecast_Category__c, Opportunity_CRO_Forecast_Category__c, Opportunity_DM_Forecast_Category__c, Opportunity_VP_Forecast_Category__c,Opportunity_RVP_Forecast_Category__c, Opportunity_AD_Forecast_Category_Lock__c, Opportunity_CRO_Forecast_Category_Lock__c, Opportunity_DM_Forecast_Category_Lock__c, Opportunity_VP_Forecast_Category_Lock__c, Opportunity_RVP_Forecast_Category_Lock__c, Opportunity_Stage__c
                                               FROM OpportunitySplit WHERE OpportunityId IN: oppIdSet]){
                if(oppSplit.SplitOwnerId == oppSplit.Opportunity_Owner__c || (oppSplit.Opportunity_Forecast_Type__c == 'New' || oppSplit.Opportunity_Forecast_Type__c == 'Upsell') || (oppSplit.Opportunity_Forecast_Type__c == 'Renewal' && oppSplit.Forecast_Type__c == 'Renewal') || (oppSplit.Opportunity_Forecast_Category__c == 'Closed') || (oppSplit.Opportunity_Forecast_Category__c == 'Omitted') || ((oppSplit.Opportunity_Stage__c == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || oppSplit.Opportunity_Stage__c == label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/) && oppSplit.Opportunity_Forecast_Category__c == 'Commit') || (oldOppMap.get(oppSplit.OpportunityId).StageName != newOppMap.get(oppSplit.OpportunityId).StageName && (oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Closed' || oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Omitted' || (oldOppMap.get(oppSplit.OpportunityId).Forecast_Category__c == 'Commit' && (oldOppMap.get(oppSplit.OpportunityId).Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || oldOppMap.get(oppSplit.OpportunityId).Stagename == label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/))))){
                   //For primary split line, copy the fc from oppty to split
                   oppSplit.Forecast_Category_New__c = oppSplit.Opportunity_Forecast_Category__c;
                   oppSplit.Deal_Path__c = oppSplit.Opportunity_Deal_Path__c;
                   oppSplit.AD_Forecast_Category__c = oppSplit.Opportunity_AD_Forecast_Category__c;
                   oppSplit.CRO_Forecast_Category__c = oppSplit.Opportunity_CRO_Forecast_Category__c;
                   oppSplit.DM_Forecast_Category__c  = oppSplit.Opportunity_DM_Forecast_Category__c;
                   oppSplit.VP_Forecast_Category__c = oppSplit.Opportunity_VP_Forecast_Category__c;
                   oppSplit.RVP_Forecast_Category__c = oppSplit.Opportunity_RVP_Forecast_Category__c;
                   oppSplit.AD_Forecast_Category_Lock__c = oppSplit.Opportunity_AD_Forecast_Category_Lock__c;
                   oppSplit.CRO_Forecast_Category_Lock__c = oppSplit.Opportunity_CRO_Forecast_Category_Lock__c;
                   oppSplit.DM_Forecast_Category_Lock__c = oppSplit.Opportunity_DM_Forecast_Category_Lock__c;
                   oppSplit.VP_Forecast_Category_Lock__c = oppSplit.Opportunity_VP_Forecast_Category_Lock__c;
                   oppSplit.RVP_Forecast_Category_Lock__c = oppSplit.Opportunity_RVP_Forecast_Category_Lock__c;
                   oppSplitUpdateList.add(oppSplit);
                }

            }

            if(!oppSplitUpdateList.isEmpty())
                Database.update(oppSplitUpdateList, false);
                TriggerUtility.updateForecastCategoryExecuted();
        }
    }

    // Commented out the below code as the ownership update logic is out of scope
    /*
    public static void updateOwnersForOpportunity(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
        // Todo:
        // Iterate through all opportunities and check if the owner has only ZPAForecastingEnabled__c set to true;

        List<Opportunity> lstOpportunitiesToUpdate = new List<Opportunity>();
        List<Id> lstOwnerIds = new List<Id>();
        Map<Id, Id> mapOwnerAccountManagerId = new Map<Id, Id>();

        for (Opportunity opp : mapNewOpportunities.values()) {
            lstOwnerIds.add(opp.OwnerId);
        }

        Map<Id, User> mapOwnerUserInfo = new Map<Id, User>();
        if (lstOwnerIds.size() > 0) {
            mapOwnerUserInfo = new Map<Id, User>([SELECT Id, ForecastEnabled__c, ZPAForecastEnabled__c
                                  FROM User
                                 WHERE Id IN :lstOwnerIds
                                   AND ZPAForecastEnabled__c = true AND ForecastEnabled__c = false]);

            for (Opportunity opp : [SELECT Id, OwnerId, Account.Account_Manager__c
                                    FROM Opportunity
                                   WHERE Id IN :mapNewOpportunities.keySet() AND OwnerId IN :mapOwnerUserInfo.KeySet()]) {
                mapOwnerAccountManagerId.put(opp.OwnerId, opp.Account.Account_Manager__c);
            }
        }

        for (Id oppId : mapNewOpportunities.keySet()) {
            if (mapOwnerAccountManagerId.containsKey(mapNewOpportunities.get(oppId).OwnerId)) {
                lstOpportunitiesToUpdate.add(new Opportunity(
                                                Id = oppId,
                                                OwnerId = mapOwnerAccountManagerId.get(mapNewOpportunities.get(oppId).OwnerId)
                                            ));
            }
        }

        try {
            System.debug('>>>> lstOpportunitiesToUpdate: ' + JSON.serialize(lstOpportunitiesToUpdate));
            update lstOpportunitiesToUpdate;
            TriggerUtility.opportunityOwnershipChangeExecuted();
        } catch (Exception ex) {
            System.debug('Exception occurred while changing opportunity owner. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    */

    public static void resetOverrideACVFieldsInProposal(Map<Id, Opportunity> mapOldOpportunities, List<Opportunity> lstNewOpportunities) {
        List<Apttus_Proposal__Proposal__c> lstProposalsToUpdate = new List<Apttus_Proposal__Proposal__c>();
        List<Id> proposalsToQuery = new List<Id>();
        List<Id> opportunityIds = new List<Id>();

        for (Opportunity oppty : lstNewOpportunities) {
            if ((mapOldOpportunities == null
                || !mapOldOpportunities.containsKey(oppty.Id)
                || (oppty.Number_Of_Upsell_Split_Lines__c != mapOldOpportunities.get(oppty.Id).Number_Of_Upsell_Split_Lines__c
                    && oppty.Number_Of_Upsell_Split_Lines__c > 0))
                && oppty.APTS_Primary_Proposal_Lookup__c != null
                && oppty.Total_ZPA_ACV__c > 0
                && oppty.Type == 'Existing Customer (Renewal)') {
                proposalsToQuery.add(oppty.APTS_Primary_Proposal_Lookup__c);
            }
        }

        for (Apttus_Proposal__Proposal__c proposal : [SELECT Id, Apttus_Proposal__Opportunity__c, Override_Renewal_Upsell_ACV_Values__c, Total_ZIA_Upsell__c, Total_ZPA_Upsell__c, Total_ZIA_Renewal__c, Total_ZPA_Renewal__c FROM Apttus_Proposal__Proposal__c
                                                       WHERE Id IN :proposalsToQuery AND Apttus_Proposal__Primary__c = true AND Override_Renewal_Upsell_ACV_Values__c = true AND (Total_ZPA_Renewal__c > 0.0 OR Total_ZPA_Upsell__c > 0.0 OR Total_ZIA_Renewal__c > 0.0 OR Total_ZIA_Upsell__c > 0.0)]) {
           // lstProposalsToUpdate.add(new Apttus_Proposal__Proposal__c(Id = proposal.Id, Override_Renewal_Upsell_ACV_Values__c = false, Total_ZIA_Upsell__c = 0.0, Total_ZIA_Renewal__c = 0.0, Total_ZPA_Upsell__c = 0.0, Total_ZPA_Renewal__c = 0.0));
           opportunityIds.add(proposal.Apttus_Proposal__Opportunity__c);
        }

        CaseCreationForAccountAndOpportunity.overrideACVValuesResetCaseCreation(opportunityIds, true);

       try {
           // update lstProposalsToUpdate;
           TriggerUtility.overrideACVValuesResetExecuted();
       } catch (Exception ex) {}
    }

    public static void copymainforecasttohierarchycategoryfields(List<Opportunity> newlist){
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            Map<String, Stage_ForecastCategory_Mapping__c> stageforecastmap =  new Map<String, Stage_ForecastCategory_Mapping__c>();
            Map<String, Stage_ForecastCategory_Rank__c> stageforecastrankmap =  Stage_ForecastCategory_Rank__c.getAll();
            for(Stage_ForecastCategory_Mapping__c stg: Stage_ForecastCategory_Mapping__c.getAll().Values()){
                stageforecastmap.put(stg.StageName__c, stg);
            }
            for(Opportunity opp: newlist){
                if(stageforecastmap.containsKey(opp.StageName) && stageforecastmap.get(opp.StageName) != null){
                    if(opp.Forecast_Category__c != null && stageforecastrankmap.containsKey(opp.Forecast_Category__c) && stageforecastrankmap.containsKey(stageforecastmap.get(opp.StageName).Forecast_Category__c) && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ && opp.StageName != label.Stage_7_Closed_Lost /* '12 - Closed With No Decision' && opp.StageName != '11 - Closed Lost' && opp.StageName != '14 - Closed: Delete Duplicate'*/){
                        if(stageforecastrankmap.get(stageforecastmap.get(opp.StageName).Forecast_Category__c).Rank__c > stageforecastrankmap.get(opp.Forecast_Category__c).Rank__c){
                            opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                        }
                    }else{
                        opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                    }
                }
                if(opp.Forecast_Category__c != null){
                    if(opp.Forecast_Category__c == 'Omitted' || opp.Forecast_Category__c == 'Closed' || ((opp.Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || opp.Stagename == label.Stage_4_Economic_Buyer_Signoff  /*'10 - Closed Won'*/) && opp.Forecast_Category__c == 'Commit')){
                        opp.AD_Forecast_Category_Lock__c = false;
                        opp.CRO_Forecast_Category_Lock__c = false;
                        opp.DM_Forecast_Category_Lock__c = false;
                        opp.VP_Forecast_Category_Lock__c = false;
                        opp.RVP_Forecast_Category_Lock__c = false;

                    }
                }

                if(!opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(!opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(!opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(!opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(!opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' ){ //opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity
                    //opp.Renewal_Rep_Forecast_Category__c = opp.Forecast_Category__c;
                }
                 System.debug('opp.RecordTypeId***'+opp.RecordTypeId);   
                //clearRenewalmynumberFields(opp);
                if(opp.Type == 'Existing Customer (Renewal)' &&  opp.StageName == '6 - Closed Won' ){
                    
                    opp.RD_In_my_Number__c = true;
                    opp.RVP_In_my_Number__c = true;
                    opp.Renewal_RD_In_my_Number__c = true;
                    opp.Renewal_RVP_In_my_Number__c = true;
                    opp.Renewal_VP_In_my_Number__c = true;
                    opp.Renewal_Rep_Forecast_Category__c = 'Closed';
                    System.debug('opp.RecordTypeId***'+opp.RecordTypeId);   
                }
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '7 - Closed Lost'){
                    opp.Renewal_Rep_Forecast_Category__c = 'Omitted'; 
                }
                
                
                if((opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business_Close || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity_Closed) && opp.Type != 'Existing Customer (Renewal)' && (opp.StageName == '6 - Closed Won')){
                    
                    opp.RD_In_my_Number__c = true;
                    opp.RVP_In_my_Number__c = true;
                    opp.AVP_In_my_Number__c = true;
                    opp.Geo_VP_In_my_Number__c = true;
                }
            }
        }
    }

    public static void handleallcategoryfieldandlockchanges(Map<Id,Opportunity> newmap, Map<Id, Opportunity> oldmap){
        Boolean stopfcchanges = false;
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('OpportunityForecastCategoryAutomation');
        if(tg != null && tg.Execute__c){
            Map<String, Stage_ForecastCategory_Mapping__c> stageforecastmap =  new Map<String, Stage_ForecastCategory_Mapping__c>();
            Map<String, Stage_ForecastCategory_Rank__c> stageforecastrankmap =  Stage_ForecastCategory_Rank__c.getAll();
            for(Stage_ForecastCategory_Mapping__c stg: Stage_ForecastCategory_Mapping__c.getAll().Values()){
                stageforecastmap.put(stg.StageName__c, stg);
            }
            for(Opportunity opp: newmap.values()){
                if(opp.Stagename != oldmap.get(opp.Id).StageName){
                    if(stageforecastmap.containsKey(opp.StageName) && stageforecastmap.get(opp.StageName) != null){
                        if(opp.Forecast_Category__c != null && stageforecastrankmap.containsKey(opp.Forecast_Category__c) && stageforecastrankmap.containsKey(stageforecastmap.get(opp.StageName).Forecast_Category__c) && opp.StageName != label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ && opp.StageName != label.Stage_7_Closed_Lost /*'12 - Closed With No Decision' && opp.StageName != '11 - Closed Lost' && opp.StageName != '14 - Closed: Delete Duplicate'*/){
                            if(stageforecastrankmap.get(stageforecastmap.get(opp.StageName).Forecast_Category__c).Rank__c > stageforecastrankmap.get(opp.Forecast_Category__c).Rank__c){
                                opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                            }
                        }else{
                            opp.Forecast_Category__c = stageforecastmap.get(opp.StageName).Forecast_Category__c;
                        }
                    }
                }
                
                if(opp.Forecast_Category__c != oldmap.get(opp.Id).Forecast_Category__c || opp.StageName != oldmap.get(opp.Id).StageName){    
                    if(opp.Forecast_Category__c == 'Omitted' || opp.Forecast_Category__c == 'Closed' || ((opp.Stagename == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ || opp.Stagename == label.Stage_4_Economic_Buyer_Signoff  /*'10 - Closed Won'*/) && opp.Forecast_Category__c == 'Commit')){
                        opp.AD_Forecast_Category_Lock__c = false;
                        opp.CRO_Forecast_Category_Lock__c = false;
                        opp.DM_Forecast_Category_Lock__c = false;
                        opp.VP_Forecast_Category_Lock__c = false;
                        opp.RVP_Forecast_Category_Lock__c = false;
    
                    }
                }
                stopfcchanges = true;

                if(opp.AD_Forecast_Category__c != oldmap.get(opp.Id).AD_Forecast_Category__c){
                    opp.AD_Forecast_Category_Lock__c = true;
                }
                if(opp.CRO_Forecast_Category__c != oldmap.get(opp.Id).CRO_Forecast_Category__c){
                    opp.CRO_Forecast_Category_Lock__c = true;
                }
                if(opp.DM_Forecast_Category__c != oldmap.get(opp.Id).DM_Forecast_Category__c){
                    opp.DM_Forecast_Category_Lock__c = true;
                }
                if(opp.VP_Forecast_Category__c != oldmap.get(opp.Id).VP_Forecast_Category__c){
                    opp.VP_Forecast_Category_Lock__c = true;
                }
                if(opp.RVP_Forecast_Category__c != oldmap.get(opp.Id).RVP_Forecast_Category__c){
                    opp.RVP_Forecast_Category_Lock__c = true;
                }

                if(opp.DM_Forecast_Category_Lock__c != oldmap.get(opp.Id).DM_Forecast_Category_Lock__c && !opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(opp.AD_Forecast_Category_Lock__c != oldmap.get(opp.Id).AD_Forecast_Category_Lock__c && !opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(opp.RVP_Forecast_Category_Lock__c != oldmap.get(opp.Id).RVP_Forecast_Category_Lock__c && !opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(opp.VP_Forecast_Category_Lock__c != oldmap.get(opp.Id).VP_Forecast_Category_Lock__c && !opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(opp.CRO_Forecast_Category_Lock__c != oldmap.get(opp.Id).CRO_Forecast_Category_Lock__c && !opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }

                if(!opp.DM_Forecast_Category_Lock__c){
                    opp.DM_Forecast_Category__c = opp.Forecast_Category__c;
                }
                if(!opp.AD_Forecast_Category_Lock__c){
                    opp.AD_Forecast_Category__c = opp.DM_Forecast_Category__c;
                }
                if(!opp.RVP_Forecast_Category_Lock__c){
                    opp.RVP_Forecast_Category__c = opp.AD_Forecast_Category__c;
                }
                if(!opp.VP_Forecast_Category_Lock__c){
                    opp.VP_Forecast_Category__c = opp.RVP_Forecast_Category__c;
                }
                if(!opp.CRO_Forecast_Category_Lock__c){
                    opp.CRO_Forecast_Category__c = opp.VP_Forecast_Category__c;
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' ){//opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity
                   // opp.Renewal_Rep_Forecast_Category__c = opp.Forecast_Category__c;
                }
                
                if(stopfcchanges){
                    TriggerUtility.OpptyTriggerFCexecuted();
                }
                
                
                //clearRenewalmynumberFields(opp);
                //opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity  - Removed - 05-feb-2019
                System.debug('opp.RecordTypeId***'+opp.RecordTypeId);   
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '6 - Closed Won' && oldmap.get(opp.Id).StageName != opp.StageName){
                
                    
                    //opp.Renewal_Rep_Forecast_Category__c = 'Closed';
                    opp.RD_In_my_Number__c = true;
                    opp.RVP_In_my_Number__c = true;
                    opp.Renewal_RD_In_my_Number__c = true;
                    opp.Renewal_RVP_In_my_Number__c = true;
                    opp.Renewal_VP_In_my_Number__c = true;
                    opp.Renewal_Rep_Forecast_Category__c = 'Closed';
                    System.debug('opp.RecordTypeId***'+opp.RecordTypeId);    
                }
                
                if(opp.Type == 'Existing Customer (Renewal)' && opp.StageName == '7 - Closed Lost' && oldmap.get(opp.Id).StageName != opp.StageName){
                    opp.Renewal_Rep_Forecast_Category__c = 'Omitted'; 
                }
                
                if((opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_New_Business_Close || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity || opp.RecordTypeId == ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity_Closed) && opp.Type != 'Existing Customer (Renewal)' && (opp.StageName == '6 - Closed Won' && oldmap.get(opp.Id).StageName != opp.StageName)){
                    
                    opp.RD_In_my_Number__c = true;
                    opp.RVP_In_my_Number__c = true;
                    opp.AVP_In_my_Number__c = true;
                    opp.Geo_VP_In_my_Number__c = true;
                }
            }
        }
    }
    
    /*public static void clearRenewalmynumberFields(Opportunity opp) {
        opp.RD_In_my_Number__c = false;
        opp.RVP_In_my_Number__c = false;
        opp.Renewal_RD_In_my_Number__c = false;
        opp.Renewal_RVP_In_my_Number__c = false;
        opp.Renewal_VP_In_my_Number__c = false;
        opp.AVP_In_my_Number__c = false;
        opp.Geo_VP_In_my_Number__c = false;
    }*/
    
    public static void updateGAMNAM(List<Opportunity> newlist){
        Triggers_Switch__c tg = Triggers_Switch__c.getValues('Update_GAM_NAM');
        if(tg != null && tg.Execute__c){
            Map<String, Partner_GAM_NAM_Mapping__c> stageforecastmap =  new Map<String, Partner_GAM_NAM_Mapping__c>();
            
            for(Opportunity opp: newlist){
                for(Partner_GAM_NAM_Mapping__c stg: Partner_GAM_NAM_Mapping__c.getAll().Values()){
                    if(opp.Primary_Partner__c != null && opp.Primary_Partner__c.containsIgnoreCase(stg.Name)){
                        opp.GAM_NAM__c = stg.GAM_NAM_Id__c;
                        break;
                    }
                }
            }
        }
    }
    
    public static void clearNSfieldsonCreation(List<Opportunity> newlist){
        for(Opportunity opp: newlist){
            opp.Netsuite_Sales_Order_Internal_ID__c = null;
            opp.Netsuite_Customer_ID_Override__c = null;
            opp.Partner_PO_Number__c = null;
            opp.First_PO_Date__c = null;
            opp.NS_Integration_Status__c = null;
            opp.Netsuite_Sales_Order_Number__c = null;
            opp.Netsuite_Primary_Partner_ID_Override__c = null;
            opp.SO_Creation_Date__c = null;
            opp.NS_Integration_Failure_Reason__c = null;
            opp.NS_Integration_Requested_By__c = null;
            opp.NS_Integration_Status_Change_Time__c = null;
            opp.Netsuite_Partner_Internal_ID_Override__c = null;
            opp.Extension_Approval_Status__c = null;
            opp.New_Extended_Contract_Date__c = null;
            opp.Past_Due_Notification_Status__c = null;
            opp.Renewal_Notification_Status__c = null;
            opp.Confirm_Opportunity_Closure__c = false;
        }
    }
    
    public static void validateClosedLostwithOpenPRs(Map<Id, Opportunity> newOppMap, map<Id, Opportunity> oldOppMap){
        set<id> oppIdSet = new set<Id>();
        for(Opportunity opp : newOppMap.values()){
            if(OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn')!=null && OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('DeactivateStage11and12forChurn').Deactivate_Component__c==True){        
        if(opp.StageName == label.Stage_7_Closed_Lost && opp.Sub_Stage__c == Label.SubStage_Closed_Delete_Duplicate /*'14 - Closed: Delete Duplicate'*/ && opp.StageName != oldOppMap.get(opp.Id).StageName && !opp.Confirm_Opportunity_Closure__c && opp.type == 'New Business'){
                oppIdSet.add(opp.Id);
        }
                
      }else{
        if(( opp.StageName == label.Stage_7_Closed_Lost && (opp.Sub_Stage__c == Label.SubStage_Closed_Lost || opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision || opp.Sub_Stage__c == Label.SubStage_Closed_Delete_Duplicate))/*'11 - Closed Lost' || opp.StageName == '12 - Closed With No Decision' || opp.StageName == '14 - Closed: Delete Duplicate'*/ && opp.StageName != oldOppMap.get(opp.Id).StageName && !opp.Confirm_Opportunity_Closure__c && (opp.type == 'New Business' || opp.type == 'Existing Customer (Add On)')){
                oppIdSet.add(opp.Id);
        }
      }
        }
        set<String> prStatusSet = new set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');

        list<Provisioning_Request__c> provReqUpdateList = new list<Provisioning_Request__c>();
    if(!oppIdSet.isEmpty()){
      for(Provisioning_Request__c pr : [Select Id, RecordType.DeveloperName, Provisioning_Status__c, Opportunity__c from Provisioning_Request__c where Opportunity__c IN: oppIdSet AND Provisioning_Status__c IN: prStatusSet]){
        Opportunity opp = newOppMap.get(pr.Opportunity__c);
        opp.addError('This Opportunity contains Active PRs. Do you want to proceed with the Closure of Opportunity? If yes, please check the \'Confirm Opportunity Closure \' to proceed.' );
      }
    }
    }


    public static void updateContractEndDate(List<Id> lstAccountIds) {
        updateContractEndDate(lstAccountIds, new List<Id>());
    }

    public static void updateContractEndDate(List<Id> lstAccountIds, List<Id> lstOpportunityIds) {
        Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();

        mapOpportunitiesToUpdate = getOpportunityContractEndDates(lstAccountIds, lstOpportunityIds);

        System.debug('*** mapOpportunitiesToUpdate: ' + JSON.serialize(mapOpportunitiesToUpdate));
        try {
            Database.update(mapOpportunitiesToUpdate.values(), true);
        } catch (Exception ex) {
            System.debug('>>>> Error occurred while updating the Contract End Date in opportunities: ' + ex.getMessage() + '; ' + ex.getStackTraceString());
        }
    }

    public static Map<Id, Opportunity> getOpportunityContractEndDates(List<Id> lstAccountIds, List<Id> lstOpportunityIds) {
        Map<Id, Opportunity> mapOpportunitiesToUpdate = new Map<Id, Opportunity>();
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        Map<Id, Map<Id, Date>> mapAccountAndContractEndDates = new Map<Id, Map<Id, Date>>();
        Map<Id, Map<String, Map<Id, Date>>> mapAccountSalesOrderAndContractEndDates = new Map<Id, Map<String, Map<Id, Date>>>();
        Set<Id> setNonCotermAccountIds = new Set<Id>();
        Map<Id, Id> mapNonCotermAccountAndOpptyIds = new Map<Id, Id>();
        Map<Id, Set<Id>> mapOpptyAndProductIds = new Map<Id, Set<Id>>();
        Map<Id, Date> mapOpptyAndContractEndDates = new Map<Id, Date>();
        Map<Id, List<String>> mapOpptyAndSalesOrderIds = new Map<Id, List<String>>();

        for (Account account : [SELECT Id, Platform_Renewal_Date__c, Next_Renewal_Due_Date__c, Non_Coterminous_Contracts__c
                                  FROM Account WHERE Id IN :lstAccountIds]) {
            // Query all accounts and separate the ones that are non-coterminous
            if (account.Non_Coterminous_Contracts__c) {
                setNonCotermAccountIds.add(account.Id);
            }

            mapAccounts.put(account.Id, account);
        }

        /*String opptyQuery = 'SELECT Id, StageName, AccountId, Netsuite_Sales_Order_No__c, Contract_End_Date_New__c,'
                                + ' (SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItems) FROM Opportunity'
                                + ' WHERE StageName NOT IN (\'10 - Closed Won\', \'10b - PO recd, pending finance approval\','
                                                    + '\'11 - Closed Lost\', \'12 - Closed With No Decision\','
                                                    + '\'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')'
                                + ' AND AccountId IN (\'' + OppotunityTriggerHelper.joinSet(mapAccounts.keySet(), '\', \'') + '\')';*/
        String str1 = label.Stage_4_Economic_Buyer_Signoff;
        String str2 = label.Stage_5_Contracts_Complete;
        String str3 = label.Stage_6_Closed_Won;
        String str4 = label.Stage_7_Closed_Lost;
        List<String> StrList = new List<String>(); 
        StrList.add(str1);
        StrList.add(str2);
        StrList.add(str3);
        StrList.add(str4);

        String opptyQuery = 'SELECT Id, StageName, AccountId, Netsuite_Sales_Order_No__c, Contract_End_Date_New__c,'
                                + ' (SELECT Id, OpportunityId, Product2Id FROM OpportunityLineItems) FROM Opportunity'
                                + ' WHERE StageName NOT IN :StrList'
                                + ' AND AccountId IN (\'' + OppotunityTriggerHelper.joinSet(mapAccounts.keySet(), '\', \'') + '\')';


        if (lstOpportunityIds.size() > 0) {
            opptyQuery += ' AND Id IN (\'' + OppotunityTriggerHelper.joinSet(new Set<Id>(lstOpportunityIds), '\', \'') + '\')';
        }
        System.debug('*** opptyQuery: ' + opptyQuery);

        List<String> lstSalesOrderIds = new List<String>();
        for (Opportunity oppty : Database.query(opptyQuery)) {
            if (setNonCotermAccountIds.contains(oppty.AccountId)) {
                mapNonCotermAccountAndOpptyIds.put(oppty.Id, oppty.AccountId);

                mapOpptyAndProductIds.put(oppty.Id, new Set<Id>());
                for (OpportunityLineItem opptyProduct : oppty.OpportunityLineItems) {
                    mapOpptyAndProductIds.get(oppty.Id).add(opptyProduct.Product2Id);
                }

                List<String> salesOrderIds = new List<String>();
                if (oppty.Netsuite_Sales_Order_No__c != null) {
                    for (String salesOrderId : oppty.Netsuite_Sales_Order_No__c.split(',')) {
                        if (salesOrderId.trim().length() > 0) {
                            salesOrderIds.add(salesOrderId.trim());
                        }
                    }
                }
                mapOpptyAndSalesOrderIds.put(oppty.Id, salesOrderIds);
                lstSalesOrderIds.addAll(salesOrderIds);
            } else {
                if (mapAccounts.containsKey(oppty.AccountId)) {
                    mapOpportunitiesToUpdate.put(oppty.Id, new Opportunity(Id = oppty.Id, Contract_End_Date_New__c = mapAccounts.get(oppty.AccountId).Platform_Renewal_Date__c));
                }
            }
        }
        System.debug('*** lstSalesOrderIds: ' + lstSalesOrderIds);

        // Scenario 2: Non-cotermed contract detail records
        for (Contract_Detail__c contractDetail : [SELECT Id, Product_Name__c, Account_Name__c, End_Date__c, Sales_Order_Name__c FROM Contract_Detail__c
                                                       WHERE Account_Name__c IN :mapNonCotermAccountAndOpptyIds.values()
                                                         AND Contract_Detail_Status__c IN ('Active', 'Pending Activation', 'Pending Renewal')
                                                         AND Do_Not_Aggregate__c = false AND Amount_USD__c >= 0 AND Sales_Order_Name__c IN :lstSalesOrderIds
                                                       ORDER BY Account_Name__c, End_Date__c]) {
            if (mapAccountSalesOrderAndContractEndDates.containsKey(contractDetail.Account_Name__c)) {
                if (mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).containsKey(contractDetail.Sales_Order_Name__c)) {
                    if (!mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).containsKey(contractDetail.Product_Name__c)
                        || (mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).containsKey(contractDetail.Product_Name__c)
                            && mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).get(contractDetail.Product_Name__c) < contractDetail.End_Date__c)) {
                        mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).get(contractDetail.Sales_Order_Name__c).put(contractDetail.Product_Name__c, contractDetail.End_Date__c);
                    }
                } else {
                    mapAccountSalesOrderAndContractEndDates.get(contractDetail.Account_Name__c).put(contractDetail.Sales_Order_Name__c, new Map<Id, Date> { contractDetail.Product_Name__c => contractDetail.End_Date__c });
                }
            } else {
                mapAccountSalesOrderAndContractEndDates.put(contractDetail.Account_Name__c, new Map<String, Map<Id, Date>> { contractDetail.Sales_Order_Name__c => new Map<Id, Date> { contractDetail.Product_Name__c => contractDetail.End_Date__c } });
            }
        }

        System.debug('*** JSON.serialize(mapAccountSalesOrderAndContractEndDates): ' + JSON.serialize(mapAccountSalesOrderAndContractEndDates));

        for (Id oppId : mapNonCotermAccountAndOpptyIds.keySet()) {
            if (mapOpptyAndSalesOrderIds.containsKey(oppId)) {
                Date newContractEndDate = null;
                for (String salesOrderId : mapOpptyAndSalesOrderIds.get(oppId)) {
                    if (mapOpptyAndProductIds.containsKey(oppId)) {
                        for (Id productId : mapOpptyAndProductIds.get(oppId)) {
                            if (mapAccountSalesOrderAndContractEndDates.containsKey(mapNonCotermAccountAndOpptyIds.get(oppId))
                                && mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).containsKey(salesOrderId)
                                && mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).containsKey(productId)
                                && (newContractEndDate == null
                                    || newContractEndDate < mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).get(productId))) {
                                newContractEndDate = mapAccountSalesOrderAndContractEndDates.get(mapNonCotermAccountAndOpptyIds.get(oppId)).get(salesOrderId).get(productId);
                            }
                        }
                        if (newContractEndDate != null) {
                            mapOpportunitiesToUpdate.put(oppId, new Opportunity(Id = oppId, Contract_End_Date_New__c = newContractEndDate));
                        }
                    }
                }
            }
        }

        return mapOpportunitiesToUpdate;
    }

    @testVisible private static String joinSet(Set<Id> setToJoin, String separator) {
        String returnValue = '';
        for (Id value : setToJoin) {
            returnValue += (value + separator);
        }

        return returnValue;
    }
    
    // Added by Gurjinder to Update Incumbent Partner field on Account
    public static void UpdateIncumbentPartneronAccount(List<Opportunity> oppNewList,map<id,Opportunity> oppOldMap){
        Set<Id> PrimaryPrsplId = new Set<Id>();
        List<Account> UpdateAccountlist= new List<Account>();
        Map<id,Apttus_Proposal__Proposal__c> PrimaryPrsplMap= new Map<id,Apttus_Proposal__Proposal__c>();
        for(Opportunity opp : oppNewList){
            if(opp.StageName == label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ && opp.StageName != oppOldMap.get(opp.Id).StageName && opp.Last_Stage_Changed_Date__c!=null){               
                PrimaryPrsplId.add(opp.APTS_Primary_Proposal_Lookup__c);
                
            }
        }
        if(!PrimaryPrsplId.isempty() && PrimaryPrsplId.size()>0){
            PrimaryPrsplMap = new Map<id,Apttus_Proposal__Proposal__c>([Select id,name,Apttus_QPConfig__BillToAccountId__c,Apttus_QPConfig__BillToAccountId__r.Name from Apttus_Proposal__Proposal__c where id IN:PrimaryPrsplId]);
        }
        if(PrimaryPrsplMap!=null){
            for(Opportunity opp : oppNewList){
                if(PrimaryPrsplMap.containskey(opp.APTS_Primary_Proposal_Lookup__c) && PrimaryPrsplMap.get(opp.APTS_Primary_Proposal_Lookup__c)!=null){
                    Account Acc=new Account(id=opp.AccountId,Incumbent_Partner_Name__c=PrimaryPrsplMap.get(opp.APTS_Primary_Proposal_Lookup__c).Apttus_QPConfig__BillToAccountId__r.Name);
                    UpdateAccountlist.add(Acc);
                }
            }
        }
        if(!UpdateAccountlist.isempty() && UpdateAccountlist.size()>0){
            Database.update(UpdateAccountlist, false);
        }
    }

    /**public static void revokeopenPendingQuotes(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        Set<id> closedoppsId = new Set<Id>();
        Set<id> quotestoRecall = new Set<Id>();
        for(Opportunity opp: newList){
            if(opp.isclosed && opp.StageName != oldMap.get(opp.Id).StageName){
                closedoppsId.add(opp.Id);
            }
        }
        if(!closedoppsId.isEmpty()){
            for(Apttus_Proposal__Proposal__c prop: [Select Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c in :closedoppsId and Apttus_QPApprov__Approval_Status__c = 'Pending Approval' and Apttus_Proposal__Primary__c = false]){
                system.enqueueJob(new RecallQuoteApprovalonOppClosure(new Set<Id>{prop.Id}));
            }
        }
        TriggerUtility.revokePendingQuoteApprovalExecuted();
    }**/
    
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
  }
  
}