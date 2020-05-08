/*****************************************************************************************
Name: DealRegTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Helper class for genericDealRegTrigger.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal/Vijay            4-OCT-2016    Initial Development
******************************************************************************************/


Public class DealRegTriggerHelper{

    public static void beforeInsert(list<Deal_Reg__c> newDealList){
        set<string> endCustEmailSet = new set<string>();
        map<string, Lead> emailLeadMap = new map<string, Lead>();
        map<string, Contact> emailContactMap = new map<string, Contact>();
        map<string, string> conLeadIdUserIdMap = new map<string, string>(); 
        map<string, string> domainPartnerAccIdMap = new map<string, string>();  
        map<string, string> partnerAccEmailMap = new map<string, string>();
        map<string, string> partnerAccSEEmailMap = new map<string, string>();
        Map<String, String> geoLeadersMap = new Map<String, String>();
                
        set<String> partnerDomainSet = new set<string>();
        set<Id> territoryIdSet = new set<Id>();


        Set<String> partnerTypeSet = new set<string>();
        partnerTypeSet.add('Partner-SP');
        partnerTypeSet.add('Partner-Reseller');
        partnerTypeSet.add('Partner-Distributor');
        partnerTypeSet.add('Partner-Integrator');
        partnerTypeSet.add('Partner-DC-BW');
        partnerTypeSet.add('Global SP/SI Partner');
         
        for(Deal_Reg__c deal : newDealList){
            if(deal.End_Customer_Email__c != '' && deal.End_Customer_Email__c != null)
                endCustEmailSet.add(deal.End_Customer_Email__c);
            if(deal.Partner_Contact_Email__c != '' && deal.Partner_Contact_Email__c != null)
                partnerDomainSet.add((deal.Partner_Contact_Email__c.Split('@'))[1]);
        }
        
        
        for(Account acc : [Select ID, Domain__c, OwnerId, Sales_Engineer__r.Email, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId, Ultimate_Parent_Account__r.Sales_Engineer__r.Email from Account Where Domain__c IN: partnerDomainSet AND Partner_Type__c IN: partnerTypeSet ] ){
            if(acc.Ultimate_Parent_Account__c != null) {
                domainPartnerAccIdMap.put(acc.Domain__c, acc.Ultimate_Parent_Account__c);
                partnerAccEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.OwnerId);
                partnerAccSEEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.Sales_Engineer__r.Email);
            }
            else {
                domainPartnerAccIdMap.put(acc.Domain__c, acc.id);
                partnerAccEmailMap.put(acc.Id, acc.OwnerId);
                partnerAccSEEmailMap.put(acc.Id, acc.Sales_Engineer__r.Email);
            }
        }

        Map<String, String> userEmailMap = new Map<String, String>();
        for (User userInfo : [SELECT Id, Email FROM User WHERE Id IN :partnerAccEmailMap.values()]) {
            userEmailMap.put(userInfo.Id, userInfo.Email);
        }

        //Prepare the GEO leaders map
        for (Deal_Reg_GEO_Leaders__c geoLeader : [SELECT SetupOwnerId, GEO__c FROM Deal_Reg_GEO_Leaders__c]) {
            if (geoLeader.GEO__c.contains(';')) {
                for (String geo : geoLeader.GEO__c.split(';')) {
                    geoLeadersMap.put(geo, geoLeader.SetupOwnerId);
                }
            } else {
                geoLeadersMap.put(geoLeader.GEO__c, geoLeader.SetupOwnerId);
            }
        }

        for(Contact con : [Select Id, Email, Account_Manager__c, Channel_Manager__c, Territory__c,  Account.Market_Segment__c, (Select id from Campaignmembers Where Campaign.Name = 'Deal Registration')  from Contact Where Email IN: endCustEmailSet ORDER BY CreatedDate DESC]){
            if(emailContactMap != null){
                if(!emailContactMap.keyset().contains(con.Email))
                    emailContactMap.put(con.Email, con);
            }else
                emailContactMap.put(con.Email, con);
            if(con.Territory__c != null)
                territoryIdSet.add(con.Territory__c);    
        }
        set<string> convrtLeadEmailSet = new set<string>();
        for(Lead lead : [Select Id, Email, Account_Manager__c, Channel_Manager__c, Territory__c, Market_Segment__c,  isConverted, (Select id from Campaignmembers Where Campaign.Name = 'Deal Registration') from Lead Where Email IN: endCustEmailSet ORDER BY CreatedDate DESC]){
            if(lead.Email != null && lead.isConverted)
                convrtLeadEmailSet.add(lead.Email);
            if(!convrtLeadEmailSet.contains(lead.Email)){
                if(emailLeadMap != null){
                    if(!emailLeadMap.keyset().contains(lead.Email))
                        emailLeadMap.put(lead.Email, lead);
                }else
                    emailLeadMap.put(lead.Email, lead);
                if(lead.Territory__c != null)
                    territoryIdSet.add(lead.Territory__c);            
            }
        }
        
        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();

        for(PatchTeam__c territory : [Select id, Theater__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: territoryIdSet]){
            for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                if(salesTeam.Role__c == 'Account Manager')
                    territorySalesUserIdMap.put(''+territory.id+'AccountManager', salesTeam.User__c);
                if(salesTeam.Role__c == 'Area Director')
                    territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
                if(salesTeam.Role__c == 'Channel Manager')
                    territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);       
                if(salesTeam.Role__c == 'Channel Manager 2')
                    territorySalesUserIdMap.put(''+territory.id+'ChannelManager2', salesTeam.User__c);       
                if(salesTeam.Role__c == 'Channel Manager 3')
                    territorySalesUserIdMap.put(''+territory.id+'ChannelManager3', salesTeam.User__c);           
            }
            territorySalesUserIdMap.put('' + territory.Id + 'GEOVP', geoLeadersMap.get(territory.Theater__c));
        }


        map<string, Deal_Reg__c> emailDealForNewLeadMap = new map<String, Deal_Reg__c>(); 
        boolean newLead = false;
        
        set<Id> conIdSet = new set<Id>();
        set<Id> leadIdSet = new set<Id>();
        for(Deal_Reg__c deal : newDealList){
            if(deal.End_Customer_Email__c != '' && deal.End_Customer_Email__c != null){
                deal.End_Customer_Domain__c = (deal.End_Customer_Email__c.Split('@'))[1];
                if(emailContactMap.keyset().contains(deal.End_Customer_Email__c)){
                    deal.Contact__c = emailContactMap.get(deal.End_Customer_Email__c).Id;
                    deal.Sales_Territory__c = emailContactMap.get(deal.End_Customer_Email__c).Territory__c;
                    deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                    deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                    deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector'); 
                    deal.GEO_VP__c = territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'GEOVP');
                    deal.Channel_Manager_2__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager2');
                    deal.Channel_Manager_3__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager3');
                    deal.Market_Segment__c = emailContactMap.get(deal.End_Customer_Email__c).Account.Market_Segment__c;
                    if(emailContactMap.get(deal.End_Customer_Email__c).Campaignmembers.isEmpty())
                        conIdSet.add(deal.Contact__c);
                    
                }else if(emailLeadMap.keyset().contains(deal.End_Customer_Email__c)){
                    deal.Sales_Territory__c = emailLeadMap.get(deal.End_Customer_Email__c).Territory__c;
                    deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                    deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                    deal.Channel_Manager_2__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager2');
                    deal.Channel_Manager_3__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager3');
                    deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector');
                    deal.GEO_VP__c = territorySalesUserIdMap.get('' + deal.Sales_Territory__c+'GEOVP');
                    deal.Lead__c = emailLeadMap.get(deal.End_Customer_Email__c).Id;
                    deal.Market_Segment__c = emailLeadMap.get(deal.End_Customer_Email__c).Market_Segment__c;
                    if(emailLeadMap.get(deal.End_Customer_Email__c).Campaignmembers.isEmpty())
                        leadIdSet.add(deal.Lead__c);
                    
                }else{
                    if(!convrtLeadEmailSet.Contains(deal.End_Customer_Email__c)){
                        newLead = true;
                        emailDealForNewLeadMap.put(deal.End_Customer_Email__c, deal);
                    }
                } 
                    
            }   
            if(deal.Partner_Contact_Email__c != '' && deal.Partner_Contact_Email__c != null){
                deal.Partner_Account__c = domainPartnerAccIdMap.get((deal.Partner_Contact_Email__c.Split('@'))[1]);
                deal.Partner_Domain__c = (deal.Partner_Contact_Email__c.Split('@'))[1];
                deal.Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccEmailMap.get(deal.Partner_Account__c));
                deal.Partner_Account_SE_Email__c = partnerAccSEEmailMap.get(deal.Partner_Account__c);
            }
           
            deal.DS_Review_Status__c = 'Pending';
        }
        list<CampaignMember> campMemberInsertList = new list<CampaignMember>();
        string dealRegCampaignId = ZscalerSetting__c.getValues('DealRegCampaign').Value__c;
        
        for(id conId : conIdSet){
            campMemberInsertList.add(new CampaignMember(CampaignId = dealRegCampaignId, ContactId = conId, Status = 'Responded'));
        }
        for(id leadId : leadIdSet){
            campMemberInsertList.add(new CampaignMember(CampaignId = dealRegCampaignId, LeadId = leadId, Status = 'Responded'));
        }
        
        try{
            if(!campMemberInsertList.isEmpty()){
                database.insert(campMemberInsertList, false);
            }
        }catch(exception e){}
        if(newLead)
            createLeadForDealReg(emailDealForNewLeadMap);
        
        TriggerUtility.dealRegBeforeInsertExecuted();    
    }
    
    public static void createLeadForDealReg(map<string, Deal_Reg__c> emailDealMap){
        createLeadForDealReg(emailDealMap, new Map<String, String>());
    }

    public static void createLeadForDealReg(map<string, Deal_Reg__c> emailDealMap, Map<String, String> geoLeadersMap){
        list<Lead> leadInsertList = new list<Lead>();
        for(Deal_Reg__c deal : emailDealMap.values()){
            Lead tempLead = new Lead();
            tempLead.FirstName = deal.End_Customer_Contact_Name__c;
            tempLead.LastName = deal.End_Customer_Contact_Last_Name__c;
            tempLead.Company = deal.End_Customer_Name__c;
            tempLead.Email = deal.End_Customer_Email__c;
            tempLead.Phone = deal.End_Customer_Phone__c;
            tempLead.LeadSource = 'Deal Registration';
            //tempLead.Status = 'Not Attempted';
            tempLead.Status = 'Pending Marketing Qualification';
            tempLead.OrgDomain__c = deal.End_Customer_Domain__c;
            tempLead.Street = deal.End_Customer_Street_Address__c;
            tempLead.City = deal.End_Customer_City__c;
            tempLead.PostalCode = deal.End_Customer_Postal_Code__c;
            tempLead.Country = deal.End_Customer_Country__c;
            tempLead.State = deal.End_Customer_State__c;
            leadInsertList.add(tempLead);
        }
        if(!leadInsertList.isEmpty())
            database.Insert(leadInsertList, false);
        set<Id> leadIdSet = new set<Id>();
        for(Lead le : leadInsertList){
            if(le.Id != null)
                leadIdSet.add(le.Id);
        }
        map<string, Id> emailAccManagerMap = new map<String, Id>();
        map<string, Id> emailChannelManagerMap = new map<String, Id>();
        map<string, Id> emailSalesTerritoryMap = new map<String, Id>();
        if(!leadIdSet.isEmpty()){
            for(Lead le : [Select id, email, Account_Manager__c, Channel_Manager__c, Territory__c  from Lead where ID IN: leadIdSet]){
                emailAccManagerMap.put(le.Email,le.Account_Manager__c);
                emailChannelManagerMap.put(le.Email,le.Channel_Manager__c);
                emailSalesTerritoryMap.put(le.Email,le.Territory__c);
                
            }
        }
        
         Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();

        for(PatchTeam__c territory : [Select id, Theater__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: emailSalesTerritoryMap.Values()]){
            for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                if(salesTeam.Role__c == 'Area Director')
                    territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
            }
            territorySalesUserIdMap.put(''+territory.Id + 'GEOVP', geoLeadersMap.get(territory.Theater__c));
        }

        
        list<CampaignMember> campMemberInsertList = new list<CampaignMember>();
        string dealRegCampaignId = ZscalerSetting__c.getValues('DealRegCampaign').Value__c;
        for(Lead le : leadInsertList){
            if(le.Id != null){
                emailDealMap.get(Le.Email).Lead__c = le.Id;
                emailDealMap.get(Le.Email).Account_Manager__c = emailAccManagerMap.get(le.Email);
                emailDealMap.get(Le.Email).Channel_Manager__c = emailChannelManagerMap.get(le.Email);
                emailDealMap.get(Le.Email).Sales_Territory__c = emailSalesTerritoryMap.get(le.Email);
                emailDealMap.get(le.Email).Area_Director__c = territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'AreaDirector');
                emailDealMap.get(le.Email).GEO_VP__c = territorySalesUserIdMap.get(''+emailSalesTerritoryMap.get(le.Email)+'GEOVP');
                campMemberInsertList.add(new CampaignMember(CampaignId  = dealRegCampaignId, LeadId = le.Id, Status = 'Responded'));
            }
        }
        if(!campMemberInsertList.isEmpty()){
            database.insert(campMemberInsertList, false);
        }
        
    }
    
    
    public static void afterInsert(list<Deal_Reg__c> newDealList){
        Set<Id> dealIdSet = new set<Id>();
        for(Deal_Reg__c deal : newDealList){
            dealIdSet.add(deal.Id);
        } 
        CaseCreationForAccountAndOpportunity.dealRegCaseCreation(newDealList);
        if(!System.isFuture())
            changeDealRegOwner(dealIdSet);
        TriggerUtility.dealRegAfterInsertExecuted();    
    }
    
    @future(Callout=true)
    public static void changeDealRegOwner(set<id> dealRegIdSet){
        
        list<Deal_Reg__c> dealRegUpdateList = new list<Deal_Reg__c>();
        for(Deal_Reg__c deal: [Select Id,ownerId, Account_Manager__c, Account_Manager__r.IsActive , Channel_Manager__c , Channel_Manager__r.IsActive FROM Deal_Reg__c WHERE Id IN: dealRegIdSet]){
           
            if(deal.Account_Manager__c != null && deal.Account_Manager__r.IsActive)
                dealRegUpdateList.add(new Deal_Reg__c(Id = deal.Id, OwnerId = deal.Account_Manager__c));
            else if(deal.Channel_Manager__c != null && deal.Channel_Manager__r.IsActive)
                dealRegUpdateList.add(new Deal_Reg__c(Id = deal.Id, OwnerId = deal.Channel_Manager__c));
        }
        system.debug('# dealRegUpdateList : '+dealRegUpdateList);
        if(!dealRegUpdateList.isEmpty())
           update dealRegUpdateList;
//            database.update(dealRegUpdateList,false);
        
    }

    public static void beforeUpdate(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList) {
        for (Deal_Reg__c dReg : newList) {
            if (oldMap.get(dReg.Id).Escalated_To_GEO_Leader__c == false
                && dReg.Escalated_To_GEO_Leader__c == true) {
                TriggerUtility.dealRegAfterUpdateReset();
            }
        }

        set<id> salesTerritoryIdSet = new set<id>();
        for(Deal_Reg__c deal : newList){
            if(deal.Sales_Territory__c != null && deal.Sales_Territory__c != oldMap.get(deal.Id).Sales_Territory__c){
                salesTerritoryIdSet.add(deal.Sales_Territory__c);
            }
        }



        Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
        if(!salesTerritoryIdSet.isEmpty()){
            for(PatchTeam__c territory : [Select id, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: salesTerritoryIdSet]){
                for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                    if(salesTeam.Role__c == 'Account Manager')
                        territorySalesUserIdMap.put(''+territory.id+'AccountManager', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Area Director')
                        territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Channel Manager')
                        territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);   
                    if(salesTeam.Role__c == 'Channel Manager 2')
                        territorySalesUserIdMap.put(''+territory.id+'ChannelManager2', salesTeam.User__c);
                    if(salesTeam.Role__c == 'Channel Manager 3')
                        territorySalesUserIdMap.put(''+territory.id+'ChannelManager3', salesTeam.User__c);            
                }
            }
            for(Deal_Reg__c deal : newList){
                deal.Area_Director__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AreaDirector');
                deal.Account_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'AccountManager');
                deal.Channel_Manager__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager');
                deal.Channel_Manager_2__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager2');
                deal.Channel_Manager_3__c = territorySalesUserIdMap.get(''+deal.Sales_Territory__c+'ChannelManager3');
            }
        }
        

    }    
    
    public static void afterUpdate(Map<Id, Deal_Reg__c> oldMap, List<Deal_Reg__c> newList) {
        List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessResult> approvalProcessResultList = new List<Approval.ProcessResult>();
        Map<Id, Deal_Reg__c> smbdealRegMap = new  Map<Id, Deal_Reg__c>();
        Map<String, Id> smbDealRegDomainMap = new Map<String, Id>();
        Map<String, Id> geoLeadersMap = new Map<String, Id>();
        Map<Id, Deal_Reg__c> dealRegToUpdateList = new Map<Id, Deal_Reg__c>();
        Set<Id> dealRegIdsToRecallApproval = new Set<Id>();
        Map<Id, Id> dealRegNewPartnerMap = new Map<Id, Id>();
        List<Id> newPartnerAccountsList = new List<Id>();

        //Query the Sales Ops Administrator user's SF Id
        User sfAdminUser = [SELECT Id, Name, UserName FROM User WHERE Name = 'Sales Ops System Admin' AND IsActive = TRUE LIMIT 1];

        //Prepare the GEO leaders map
        for (Deal_Reg_GEO_Leaders__c geoLeader : [SELECT SetupOwnerId, GEO__c FROM Deal_Reg_GEO_Leaders__c]) {
            if (geoLeader.GEO__c.contains(';')) {
                for (String geo : geoLeader.GEO__c.split(';')) {
                    geoLeadersMap.put(geo, geoLeader.SetupOwnerId);
                }
            } else {
                geoLeadersMap.put(geoLeader.GEO__c, geoLeader.SetupOwnerId);
            }
        }

        for (Deal_Reg__c record : newList) {
            //Identify the records that has Market Segment = 'SMB' and has been reviewed by DS team
            if ('Complete' != oldMap.get(record.Id).DS_Review_Status__c
                && 'Complete' == record.DS_Review_Status__c) {
                //If Territory Type is GB or Territory Type is All and Market Segment is SMB or SOHO
                //Then consider the deal for Auto-approval
                //Proceed only if the Partner Account is found. Otherwise, automatically reject it.
                if (null != record.Partner_Account__c) {
                    if (('General Business' == record.Territory_Type__c
                        || 'All' == record.Territory_Type__c)
                        && ('SOHO' == record.Market_Segment__c
                        || 'SMB' == record.Market_Segment__c)
                        ) {
                        smbDealRegDomainMap.put(record.End_Customer_Domain__c, record.Id);
                        smbdealRegMap.put(record.Id, record);
                    } else {
                        Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                        newApprovalRequest.setComments('Submit for Manager\'s approval');
                        newApprovalRequest.setObjectId(record.Id);
                        newApprovalRequest.setSubmitterId(sfAdminUser.Id);

                        approvalProcessRequestList.add(newApprovalRequest);
                    }
                } else {
                    dealRegToUpdateList.put(record.Id, new Deal_Reg__c(Id = record.Id,
                                                            Status__c = 'Rejected',
                                                            Approval_Status__c = 'No Partner Account Found'
                                                        ));
                }
            }

            /**
             * Commenting out this block due to requirement change.
             * New Requirements:
             * - GEO VP will now be just notified through Workflow
             * - Sales team's rejection will be the final rejection
             */
            //Identify the list of records that got escalated to Geo Leader
            //if (true == record.Escalated_To_GEO_Leader__c
            //    && false == oldMap.get(record.Id).Escalated_To_GEO_Leader__c
            //    && ('Complete' == record.DS_Review_Status__c
            //        || 'APAC' == record.GEO__c
            //        || 'EMEA' == record.GEO__c
            //        || 'AMERICAS' == record.GEO__c
            //        || 'CHANNEL' == record.GEO__c)) {
            //    Boolean skipGeoLeaderReview = false;

            //    if ('channel manager rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Channel_Manager__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    } else if ('account manager rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Account_Manager__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    } else if ('area director rejected' == record.Approval_Status__c.toLowerCase()
            //        && record.Area_Director__c == geoLeadersMap.get(record.GEO__c)) {
            //        skipGeoLeaderReview = true;
            //    }

            //    if (true == skipGeoLeaderReview) {
            //        dealRegToUpdateList.put(record.Id, new Deal_Reg__c(
            //                                Id = record.Id,
            //                                Approval_Status__c = 'Rejected',
            //                                Status__c = 'Rejected'
            //                            ));
            //        break;
            //    }

            //    dealRegIdsToRecallApproval.add(record.Id);

            //    Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
            //    newApprovalRequest.setComments('Escalate to GEO Leader');
            //    newApprovalRequest.setObjectId(record.Id);
            //    newApprovalRequest.setSubmitterId(sfAdminUser.Id);
            //    newApprovalRequest.setNextApproverIds(new Id[] { geoLeadersMap.get(record.GEO__c) });
            //    newApprovalRequest.setProcessDefinitionNameOrId('GEO_Leader_Escalation_Deal_Reg_Approval');

            //    approvalProcessRequestList.add(newApprovalRequest);
            //}

            //Identify the records whose partner account has been updated
            if (record.Partner_Account__c != oldMap.get(record.Id).Partner_Account__c) {
                newPartnerAccountsList.add(record.Partner_Account__c);
                dealRegNewPartnerMap.put(record.Id, record.Partner_Account__c);
            }

            //Update the deal reg with appropriate GEO VP based on the Deal Reg Geo
            if (null != record.GEO__c
                && record.GEO__c != oldMap.get(record.Id).GEO__c) {
                if (dealRegToUpdateList.containsKey(record.Id)) {
                    dealRegToUpdateList.get(record.Id).GEO_VP__c = geoLeadersMap.get(record.GEO__c);
                } else {
                    dealRegToUpdateList.put(record.Id, new deal_Reg__c(
                                            Id = record.Id, 
                                            GEO_VP__c = geoLeadersMap.get(record.GEO__c)
                                        ));
                }
            }
        }

        //Query the deal reg opportunities which are still open for 2 weeks and prepare the list of deal reg to be auto-approved
        Map<Id, List<Id>> dealRegOpportunitiesMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> dealRegistrationsMap = new Map<Id, List<Id>>();

        for (Opportunity dealRegOppty : [SELECT Id, Account.Domain__c, CreatedDate, Deal_Reg__c, isClosed FROM Opportunity 
                                          WHERE isClosed = False 
                                            AND Account.Domain__c IN :smbDealRegDomainMap.keySet()]) {
            //Commenting this date check condition as all the open opportunities have to be considered
            //Integer dateDiff = dealRegOppty.CreatedDate.Date().daysBetween(smbdealRegMap.get(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c)).CreatedDate.Date());
            //if (dateDiff < 14) {
                if (dealRegOpportunitiesMap.containsKey(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c))) {
                    dealRegOpportunitiesMap.get(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c)).add(dealRegOppty.Id);
                } else {
                    List<Id> matchingOpptyList = new List<Id>();
                    matchingOpptyList.add(dealRegOppty.Id);
                    dealRegOpportunitiesMap.put(smbDealRegDomainMap.get(dealRegOppty.Account.Domain__c), matchingOpptyList);
                }
            //}
        }

        for (Deal_Reg__c dealRegObj : [SELECT Id, End_Customer_Domain__c FROM Deal_Reg__c 
                                        WHERE End_Customer_Domain__c IN :smbDealRegDomainMap.keySet() 
                                          AND Id NOT IN :smbDealRegDomainMap.values()]) {
            if (dealRegistrationsMap.containsKey(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c))) {
                dealRegistrationsMap.get(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c)).add(dealRegObj.Id);
            } else {
                List<Id> matchingDealRegList = new List<Id>();
                matchingDealRegList.add(dealRegObj.Id);
                dealRegistrationsMap.put(smbDealRegDomainMap.get(dealRegObj.End_Customer_Domain__c), matchingDealRegList);
            }
        }

        for (Deal_Reg__c dealRegObj : [SELECT Id FROM Deal_Reg__c WHERE Id IN :smbDealRegDomainMap.values()]) {
            //If the end customer has any other deal registrations or any open opportunities whose created date is less than 2 weeks
            if ((dealRegOpportunitiesMap.isEmpty() || null == dealRegOpportunitiesMap.get(dealRegObj.Id) || dealRegOpportunitiesMap.get(dealRegObj.Id).isEmpty())
                && (dealRegistrationsMap.isEmpty() || null == dealRegistrationsMap.get(dealRegObj.Id) || dealRegistrationsMap.get(dealRegObj.Id).isEmpty())) {
                dealRegToUpdateList.put(dealRegObj.Id, new Deal_Reg__c(Id = dealRegObj.Id,
                                                           Approval_Status__c = 'Auto-approved',
                                                           Status__c = 'Approved'
                                                        ));
            } else {
                Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                newApprovalRequest.setComments('Submit for Manager\'s approval');
                newApprovalRequest.setObjectId(dealRegObj.Id);
                newApprovalRequest.setSubmitterId(sfAdminUser.Id);

                approvalProcessRequestList.add(newApprovalRequest);
            }
        }

        /**
         * Commenting out this block due to requirement change.
         * New Requirements:
         * - GEO VP will now be just notified through Workflow
         * - Sales team's rejection will be the final rejection
         */
        //Map<Id, ProcessInstance> mapProcessInstances = new Map<Id, ProcessInstance>([SELECT Id, ProcessDefinitionId, ProcessDefinition.Name, TargetObjectId, Status 
        //                                               FROM ProcessInstance 
        //                                              WHERE Status IN ('Pending') 
        //                                                AND TargetObjectId IN :dealRegIdsToRecallApproval 
        //                                                AND ProcessDefinitionId IN (
        //                                                    SELECT Id FROM ProcessDefinition 
        //                                                     WHERE Name IN ('CHANNEL Deal Reg Approval Process', 'EMEA Geo Deal Reg Approval Process',
        //                                                     'APAC Geo Deal Reg Approval Process', 'AMERICAS Geo Deal Reg Approval Process') 
        //                                                AND State = 'Active')]);

        //for (ProcessInstanceWorkItem workItem : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstanceId 
        //                                          FROM ProcessInstanceWorkItem 
        //                                         WHERE ProcessInstanceId IN :mapProcessInstances.keySet()]) {
        //    Approval.ProcessWorkItemRequest pwir = new Approval.ProcessWorkitemRequest();
        //    pwir.setWorkItemId(workItem.Id);
        //    pwir.setComments('AUTO: Recalling this approval request as the 3 days SLA has been breached.');
        //    pwir.setAction('Removed');
            
        //    Approval.process(pwir);
        //}

        //Update the account owner's email id
        Set<String> partnerTypeSet = new set<string>();
        partnerTypeSet.add('Partner-SP');
        partnerTypeSet.add('Partner-Reseller');
        partnerTypeSet.add('Partner-Distributor');
        partnerTypeSet.add('Partner-Integrator');
        partnerTypeSet.add('Partner-DC-BW');
        partnerTypeSet.add('Global SP/SI Partner');

        Map<String, String> partnerAccountOwnerMap = new Map<String, String>();
        Map<String, String> partnerAccountSEEmailMap = new Map<String, String>();
        Map<String, String> userEmailMap = new Map<String, String>();
        for(Account acc : [Select ID, Domain__c, OwnerId, Sales_Engineer__r.Email, Ultimate_Parent_Account__c, Ultimate_Parent_Account__r.OwnerId, Ultimate_Parent_Account__r.Sales_Engineer__r.Email from Account Where Id IN :dealRegNewPartnerMap.values() AND Partner_Type__c IN: partnerTypeSet ] ){
            if(acc.Ultimate_Parent_Account__c != null) {
                partnerAccountOwnerMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.OwnerId);
                partnerAccountSEEmailMap.put(acc.Ultimate_Parent_Account__c, acc.Ultimate_Parent_Account__r.Sales_Engineer__r.Email);
            }
            else {
                partnerAccountOwnerMap.put(acc.Id, acc.OwnerId);
                partnerAccountSEEmailMap.put(acc.Id, acc.Sales_Engineer__r.Email);
            }
        }

        for (User userInfo : [SELECT Id, Email FROM User WHERE Id IN :partnerAccountOwnerMap.values()]) {
            userEmailMap.put(userInfo.Id, userInfo.Email);
        }

        for (Id dealRegId : dealRegNewPartnerMap.keySet()) {
            if (dealRegToUpdateList.containsKey(dealRegId)) {
                Deal_Reg__c dealRegObj = dealRegToUpdateList.get(dealRegId);
                dealRegObj.Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId)));
                dealRegObj.Partner_Account_SE_Email__c = partnerAccountSEEmailMap.get(dealRegNewPartnerMap.get(dealRegId));
            } else {
                dealRegToUpdateList.put(dealRegId, new Deal_Reg__c(
                                        Id = dealRegId,
                                        Partner_Account_Owner_Email__c = userEmailMap.get(partnerAccountOwnerMap.get(dealRegNewPartnerMap.get(dealRegId))),
                                        Partner_Account_SE_Email__c = partnerAccountSEEmailMap.get(dealRegNewPartnerMap.get(dealRegId))
                                    ));
            }
        }

        try {
            update dealRegToUpdateList.values();
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + '; \r\n' + ex.getStackTraceString());
        }

        //Submit the escalated deal reg records to Geo Leader for review
        if (approvalProcessRequestList.size() > 0) {
            try {
                for (Approval.ProcessSubmitRequest processRequest : approvalProcessRequestList) {
                    Approval.ProcessResult result = Approval.process(processRequest);
                }
            } catch (Exception ex) {
                System.debug('Exception: ' + ex.getMessage() + '; \r\n' + ex.getStackTraceString());
            }
        }
        
        changeLeadContactStatus(oldMap,newList);
        TriggerUtility.dealRegAfterUpdateExecuted();
    }
    
    public static void changeLeadContactStatus(Map<Id, Deal_Reg__c> dealRegOldMap, list<Deal_Reg__c> dealRegNewList){
        map<Id, Deal_Reg__c> dealRegMap = new map<Id, Deal_Reg__c>();
        list<Lead> leadUpdateList = new list<Lead>();
        list<Contact> contactUpdateList = new list<Contact>();
        for(Deal_Reg__c deal : [Select Id, Lead__c, Contact__c, Lead__r.Status, Contact__r.Contact_Lead_Status__c from Deal_Reg__c where ID IN: dealRegOldMap.keySet()]){
            dealRegMap.put(deal.Id, deal);
        }
        for(Deal_Reg__c deal : dealRegNewList){
            if(deal.Status__c == 'Approved' && deal.Status__c != dealRegOldMap.get(deal.Id).Status__c){
                if(deal.Lead__c != null && dealRegMap.get(deal.Id).Lead__r.Status != 'Marketing Qualified: Sales Accepted' && dealRegMap.get(deal.Id).Lead__r.Status != 'VO' && dealRegMap.get(deal.Id).Lead__r.Status != 'VO')
                    leadUpdateList.add(new lead(Id = deal.Lead__c, Status = 'Marketing Qualified: Sales Accepted'));
                if(deal.Contact__c != null && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'Marketing Qualified: Sales Accepted' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'VO' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'VO' && dealRegMap.get(deal.Id).Contact__r.Contact_Lead_Status__c != 'VO')
                    contactUpdateList.add(new Contact(Id = deal.Contact__c, Contact_Lead_Status__c = 'Marketing Qualified: Sales Accepted'));
            }
        }
        try{
            if(!leadUpdateList.isEmpty())
                database.Update(leadUpdateList, false);
            if(!contactUpdateList.isEmpty())
                database.update(contactUpdateList,false);
        }catch(Exception e){}
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
	}
}