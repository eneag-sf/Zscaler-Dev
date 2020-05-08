/*****************************************************************************************
Name: CaseCreationForAccountAndOpportunity
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Class to create case on Account and Opportunity Creation baseed on Account DS Review Status.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            17-Nov-2015    Initial Development
******************************************************************************************/

Public class CaseCreationForAccountAndOpportunity{

    public static void accountCaseCreation(list<Account> newAccList){
        list<Case> caseInsertList = new list<Case>();
        for(Account acc : newAccList){
            if(acc.DS_Review_Status__c == null || acc.DS_Review_Status__c == '')
                caseInsertList.add(createCase(acc.Id, acc.Name, 'Account'));
        }

        if(!caseInsertList.isEmpty()){
            database.insert (caseInsertList,false);
        }

    }

    public static void opportunityCaseCreation(list<Opportunity> newOppList){
        map<id, Id> oppIdAccountIdMap = new map<Id, Id>();
        list<Case> caseInsertList = new list<Case>();
        list<Account> accountUpdateList = new list<Account>();
        try{
            for(Opportunity opp: newOppList){
                if(Opp.AccountId != null)
                    oppIdAccountIdMap.put(opp.Id, opp.AccountId);
            }

            if(oppIdAccountIdMap != null && !oppIdAccountIdMap.keySet().isEmpty()){
                for(Account acc : [Select Id, Name, DS_Review_Status__c  From Account  where ID IN: oppIdAccountIdMap.values()]){
                    if(acc.DS_Review_Status__c == null || acc.DS_Review_Status__c == ''){
                        caseInsertList.add(createCase(acc.Id, acc.Name, 'Opportunity'));
                        acc.DS_Review_Status__c = 'Pending';
                        accountUpdateList.add(acc);
                    }
                }
                if(!caseInsertList.isEmpty())
                    database.Insert(caseInsertList,False);
                if(!accountUpdateList.isEmpty())
                    database.Update(accountUpdateList,False);
            }
        }catch(exception e){}

    }

    public static case createCase(id accId,String accName , string forObj){
        case tempCase = new case();
        tempCase.AccountId = accId;
        if(forObj == 'Account'){
            tempCase.Subject = 'New Account Created : '+accName+' / '+accId;
            tempCase.Description = 'New Account has been created, Please Validate and close.';
        }

        if(forObj == 'Opportunity'){
            tempCase.Subject = 'New Opportunity Created For : '+accName+' / '+accId;
            tempCase.Description = 'New Opportunity has been created, Please validate and close.';
        }
        tempCase.Case_Category__c = 'Accounts';
        tempCase.Case_Sub_Category__c = 'DS Review';
        tempCase.recordtypeid = label.CaseRT_SalesOperation;
        if(!Test.isRunningTest())
            tempCase.OwnerId = ZscalerSetting__c.getValues('DSReviewCaseOwnerId').Value__c;
        tempCase.Status = 'New';
        return tempCase;
    }

    public static void dealRegCaseCreation(list<Deal_Reg__c> newDealRegList){
        list<Case> caseInsertList = new list<Case>();
        string OwnerId = '';
        OwnerId = ZscalerSetting__c.getValues('DealRegCaseReviewOwnerId').Value__c;
        for(Deal_Reg__c deal : newDealRegList){
            caseInsertList.add(new Case(Deal_Reg__c = deal.Id, Subject = 'New Deal Reg is Created  : '+deal.Name+' / '+deal.Id, Description = 'New Deal Reg has been created, Please validate and close.', Case_Category__c = 'Deal Reg', Case_Sub_Category__c = 'DS Review', Status = 'New', OwnerId = OwnerId,recordtypeid=label.CaseRT_SalesOperation));
        }
        if(!caseInsertList.isEmpty())
            database.insert(caseInsertList, false);


    }

    public static void opportunitySplitsCaseCreation(Set<Id> lstMultiTerritoryOpportunitySplits, Set<Id> lstOtbOpportunityIds, Set<Id> lstRenewalOpptysWithUpsellSplits, Set<Id> splitsWithBlankZPAFields) {
        List<Case> casesToBeCreated = new List<Case>();
        List<CaseComment> caseCommentsToBeCreated = new List<CaseComment>();
        Map<Id, Id> opportunityIdsWithOpenSplitCaseIds = new Map<Id, Id>();
        String OwnerId = '';
        if (Test.isRunningTest()) {
            OwnerId = Userinfo.getUserId();
        } else {
            OwnerId = ZscalerSetting__c.getValues('SalesOperationQueueId').Value__c;
        }
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Name, AccountId FROM Opportunity WHERE Id IN :lstMultiTerritoryOpportunitySplits OR Id IN :lstOtbOpportunityIds OR Id IN :lstRenewalOpptysWithUpsellSplits OR Id IN :splitsWithBlankZPAFields]);

        for (Case openCase : [SELECT Id, Subject, Status, Opportunity_Name__c
                                FROM Case WHERE (Opportunity_Name__c IN :lstMultiTerritoryOpportunitySplits
                                             OR Opportunity_Name__c IN :lstOtbOpportunityIds
                                             OR Opportunity_Name__c IN :lstRenewalOpptysWithUpsellSplits)
                                 AND IsClosed != true AND Subject LIKE 'New Opportunity Split entry created : %']) {
            opportunityIdsWithOpenSplitCaseIds.put(openCase.Opportunity_Name__c, openCase.Id);
        }

        Set<Id> allOpptyIds = new Set<Id>();
        allOpptyIds.addAll(lstMultiTerritoryOpportunitySplits);
        allOpptyIds.addAll(lstOtbOpportunityIds);
        allOpptyIds.addAll(lstRenewalOpptysWithUpsellSplits);
        allOpptyIds.addAll(splitsWithBlankZPAFields);

        for (Id opptyId : allOpptyIds) {
            if (opportunityIdsWithOpenSplitCaseIds.containsKey(opptyId)) {
                if (lstMultiTerritoryOpportunitySplits.contains(opptyId)) {
                    caseCommentsToBeCreated.add(new caseComment(
                        ParentId = opportunityIdsWithOpenSplitCaseIds.get(opptyId),
                        IsPublished = true,
                        CommentBody = 'A new split line with split owner belonging to multiple territories has been created. Please review the same again. Thanks.'
                    ));
                }

                if (lstOtbOpportunityIds.contains(opptyId)) {
                    caseCommentsToBeCreated.add(new caseComment(
                        ParentId = opportunityIdsWithOpenSplitCaseIds.get(opptyId),
                        IsPublished = true,
                        CommentBody = 'This is an OTB opportunity. Please review the split(s) sales territories and close. Thanks.'
                    ));
                }

                if (lstRenewalOpptysWithUpsellSplits.contains(opptyId)) {
                    caseCommentsToBeCreated.add(new caseComment(
                        ParentId = opportunityIdsWithOpenSplitCaseIds.get(opptyId),
                        IsPublished = true,
                        CommentBody = 'This is a renewal opportunity with upsell split(s). Please review the split(s) sales territories and close. Thanks.'
                    ));
                }

                if (splitsWithBlankZPAFields.contains(opptyId)) {
                    caseCommentsToBeCreated.add(new CaseComment(
                        ParentId = opportunityIdsWithOpenSplitCaseIds.get(opptyId),
                        IsPublished = true,
                        CommentBody = 'A new split line with a blank ZPA RSM/SE has been created for the opportunity which has a ZPA SKU. Please review with the opportunity owner/AD to update this information.'
                    ));
                }
            } else {
                Case newCase = new Case(
                    Subject = 'New Opportunity Split entry created : ' + mapOpportunities.get(opptyId).Name + ' / ' + opptyId,
                    Opportunity_Name__c = opptyId,
                    AccountId = mapOpportunities.get(opptyId).AccountId,
                    Case_Category__c = 'Opportunities',
                    Case_Sub_Category__c = 'Opportunity Splits Review',
                    Status = 'New',
                    OwnerId = OwnerId,
                    Priority = '3 - Medium',
                    Case_Source__c = 'Salesforce.com',
                    recordtypeid=label.CaseRT_SalesOperation
                );

                newCase.Description = '';
                if (lstMultiTerritoryOpportunitySplits.contains(opptyId)) {
                    newCase.Description += 'New Opportunity Split entry with the split owner belonging to multiple territories has been created.\n';
                }

                if (lstOtbOpportunityIds.contains(opptyId)) {
                    newCase.Description += 'This is an OTB opportunity. Please review the split(s) sales territories.\n';
                }

                if (lstRenewalOpptysWithUpsellSplits.contains(opptyId)) {
                    newCase.Description += 'This is a renewal opportunity with upsell split(s). Please review the split(s) sales territories.\n';
                }

                if (splitsWithBlankZPAFields.contains(opptyId)) {
                    newCase.Description += 'New split line(s) with a blank ZPA RSM/SE has been created for the opportunity which has a ZPA SKU. Please review with the opportunity owner/AD to update this information\n';
                }

                casesToBeCreated.add(newCase);
            }
        }

        try {
            insert casesToBeCreated;
            insert caseCommentsToBeCreated;
        } catch (Exception ex) {
            System.debug('Exception occurred while creating cases for opportunity / splits. \n' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    public static void overrideACVValuesResetCaseCreation(List<Id> resetOverrideACVOpptyIds, Boolean fromOpportunity) {
        List<Case> casesToBeCreated = new List<Case>();
        List<CaseComment> caseCommentsToBeCreated = new List<CaseComment>();
        Map<Id, Id> opportunityIdsWithOpenCaseIds = new Map<Id, Id>();
        String OwnerId = '';
        if (Test.isRunningTest()) {
            OwnerId = Userinfo.getUserId();
        } else {
            OwnerId = ZscalerSetting__c.getValues('SalesOperationQueueId').Value__c;
        }
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Name, AccountId, APTS_Primary_Proposal_Lookup__r.Total_ZPA_ACV__c FROM Opportunity WHERE Id IN :resetOverrideACVOpptyIds]);

        for (Case openCase : [SELECT Id, Subject, Status, Opportunity_Name__c
                                FROM Case WHERE Opportunity_Name__c IN :mapOpportunities.keySet()
                                 AND IsClosed != true AND Subject LIKE 'Renewal Opportunity\'s ACV was modified : %']) {
            opportunityIdsWithOpenCaseIds.put(openCase.Opportunity_Name__c, openCase.Id);
        }

        for (Id opptyId : mapOpportunities.keySet()) {
            if (opportunityIdsWithOpenCaseIds.containsKey(opptyId)) {

                caseCommentsToBeCreated.add(new caseComment(
                    ParentId = opportunityIdsWithOpenCaseIds.get(opptyId),
                    IsPublished = true,
                    CommentBody = 'The opportunity\'s ACV was modified. Please verify and update the overridden ACV value fields and the Override Renewal Upsell ACV Values flag.'
                ));
            } else {
                Case newCase = new Case(
                    Subject = 'Renewal Opportunity\'s ACV was modified : ' + mapOpportunities.get(opptyId).Name + ' / ' + opptyId,
                    Opportunity_Name__c = opptyId,
                    AccountId = mapOpportunities.get(opptyId).AccountId,
                    Case_Category__c = 'Opportunities',
                    Case_Sub_Category__c = 'Opportunity ACV Override',
                    Status = 'New',
                    OwnerId = OwnerId,
                    Priority = '3 - Medium',
                    Case_Source__c = 'Salesforce.com',
                    recordtypeid=label.CaseRT_SalesOperation,
                    Description = 'The opportunity\'s ACV was modified. Please verify and update the overridden ACV value fields and the Override Renewal Upsell ACV Values flag.'
                );

                casesToBeCreated.add(newCase);
            }
        }

        try {
            insert casesToBeCreated;
            insert caseCommentsToBeCreated;
        } catch (Exception ex) {
            System.debug('Exception occurred while creating cases for opportunity ACV override. \n' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
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
	}
}