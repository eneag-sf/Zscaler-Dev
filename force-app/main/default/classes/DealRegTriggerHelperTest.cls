/*****************************************************************************************
Name: DealRegTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for AssociatedOpportunityDealRegsExt
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            4-OCT-2016    Initial Development
******************************************************************************************/


@isTest(SeeAllData=false)
public class DealRegTriggerHelperTest{
    public static Map<String, Account> mapAccounts;

    static testMethod void testDealRegTriggerHelper(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc1);

        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Reseller';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc2);
        insert accInsertList;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = acc2.Id;
        insert con;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.startTest();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        insert le;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        
        list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();

        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        dealRegInsertList.add(deal);

        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abcd.com';
        deal1.End_Customer_Email__c  = 'jhon@abcd.com';
        deal1.End_Customer_Name__c = 'ABC Inc';
        deal1.End_Customer_Phone__c = '123456789';
        deal1.End_Customer_State__c = 'US';
        deal1.DS_Review_Status__c = 'Pending Review';
        deal1.Estimated_Amount__c = 1234567;
        deal1.Expected_Close_Date__c = system.today() + 30;
        deal1.Market_Segment__c = 'SMB';
        deal1.Number_of_Users__c = 1234567;
        deal1.Partner_Company_Name__c = 'Test partner';
        deal1.Partner_Contact_Email__c = 'Test@partner.com';
        deal1.Partner_Contact_Name__c = 'Test';
        deal1.Partner_Contact_Last_Name__c  = 'Partner';
        deal1.Partner_Country__c  = 'US';
        deal1.Partner_Domain__c  = 'partner.com';
        deal1.Source__c = 'Deal Reg';
        deal1.Status__c = 'Submitted';
        deal1.Lead__c = le.id;
        deal1.Contact__c = con.id;
        dealRegInsertList.add(deal1);

        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Submitted';
        dealRegInsertList.add(deal2);

        insert dealRegInsertList;
        test.stopTest();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());

        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        insert Opp;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        deal1.Status__c = 'Approved';
        update deal1;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        
    }
    
    /*public static testmethod void testsplitdealregtest(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        List<Lead> ldlst = new List<lead>();
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.ZPA_Interactive_Lead__c = true;
        ldlst.add(le);
        
        Lead le1 = new Lead();
        le1.Company = 'test Company';
        le1.FirstName = 'Test';
        le1.LastName = 'Name';
        le1.Email = 'test@abc.com';
        ldlst.add(le1);
        insert ldlst;
        //le1.ZPA_Interactive_Lead__c = true;
        le1.Lead_Development__c = [Select Id from User where isactive = true limit 1].Id;
        update le1;
        
        test.starttest();
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        insert deal;
        
        map<String, Deal_Reg__c> dealRegMap = new map<string, Deal_Reg__c>();
        dealRegMap.put(deal.End_Customer_Email__c, deal);
        DealRegTriggerHelper.createLeadForDealReg(dealRegMap);
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.stoptest();
    
    }*/
    static testMethod void dealRegAutoUpdateScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        Test.startTest();
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business').Id;
        dealReg.Market_Segment__c = 'SMB';
        dealReg.DS_Review_Status__c = 'Complete';
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }

    static testMethod void dealRegApprovalSubmissionScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        Test.startTest();
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
		DealRegTriggerHelper.booster();
        Test.stopTest();
    }

   /*  static testMethod void dealRegGEOEscalationScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();

        list<Account> accInsertList = new list<Account>();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner parent';
        acc1.Domain__c = 'partner.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc1);

        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Reseller';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc2);
        insert accInsertList;

        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;

        mapAccounts = new Map<String, Account>();
        mapAccounts.put(acc.Name, acc);
        mapAccounts.put(acc1.Name, acc1);
        mapAccounts.put(acc2.Name, acc2);

        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Partner_Account__c = mapAccounts.get('Test partner parent').Id;
        update dealReg;

        Test.startTest();
        dealReg.Escalated_To_GEO_Leader__c = true;
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }  */

    static testMethod void dealRegAutoRejectionScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Approval_Status__c = 'Channel Manager Rejected';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        update dealReg;

        Test.startTest();
        dealReg.Escalated_To_GEO_Leader__c = true;
        update dealReg;
        
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }

    static testMethod void dealRegNoPartnerAccountFoundScenario() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);

        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');

        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        update dealReg;

        Test.startTest();
        dealReg.Partner_Account__c = null;
        dealReg.DS_Review_Status__c = 'Complete';
        update dealReg;
        System.debug('>>>> ' + dealReg);
        System.debug('>>>> ' + dealReg.Name);
        Test.stopTest();
    }
    
}