/*****************************************************************************************
Name: ContactPatchManagerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for ContactPatchManager Class.
1. Test Class for CaseCreationForAccountAndOpportunity Class.
1. Test Class for AccountSalesTerritoryAndContactPatch Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            13-Nov-2015    Initial Development
******************************************************************************************/
@isTest(SeeAllData=false)
private class ContactPatchManagerTest{
    @isTest(SeeAllData=false)
     static void testContactPatch(){
         test.startTest();
         ZscalerSetting__c zs = new ZscalerSetting__c();
         zs.Name = 'DSReviewCaseOwnerId';
         zs.Value__c = ''+userInfo.Getuserid();
         insert zs;
         TriggerUtility.accSalesTeamExecuted();
         PatchTeam__c salestert  = new PatchTeam__c();
         salestert.District__c = 'District 1';
         salestert.Theater__c = 'AMER';
         salestert.Region__c = 'Central';
         salestert.Territory__c = 'SF Bay Area 1';
         salestert.Name = 'Sales Team';
         insert salestert;



         PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
         SalesTeamMem1.Role__c = 'Account Manager';
         SalesTeamMem1.PatchTeam__c = salestert.Id;
         SalesTeamMem1.User__c = userinfo.GetuserId();
         insert SalesTeamMem1 ;


         PatchTeamMember__c SalesTeamMem2 = new PatchTeamMember__c();
         SalesTeamMem2.Role__c = 'Channel Manager';
         SalesTeamMem2.PatchTeam__c = salestert.Id;
         SalesTeamMem2.User__c = userinfo.GetuserId();
         insert SalesTeamMem2 ;


         PatchTeamMember__c SalesTeamMem3 = new PatchTeamMember__c();
         SalesTeamMem3.Role__c = 'Customer Advocate';
         SalesTeamMem3.PatchTeam__c = salestert.Id;
         SalesTeamMem3.User__c = userinfo.GetuserId();
         insert SalesTeamMem3 ;


         PatchTeamMember__c SalesTeamMem4 = new PatchTeamMember__c();
         SalesTeamMem4.Role__c = 'Lead Development';
         SalesTeamMem4.PatchTeam__c = salestert.Id;
         SalesTeamMem4.User__c = userinfo.GetuserId();
         insert SalesTeamMem4 ;


         PatchTeamMember__c SalesTeamMem5 = new PatchTeamMember__c();
         SalesTeamMem5.Role__c = 'Sales Engineer';
         SalesTeamMem5.PatchTeam__c = salestert.Id;
         SalesTeamMem5.User__c = userinfo.GetuserId();
         insert SalesTeamMem5 ;

         PatchTeamMember__c SalesTeamMem6 = new PatchTeamMember__c();
         SalesTeamMem6.Role__c = 'ZPA Manager';
         SalesTeamMem6.PatchTeam__c = salestert.Id;
         SalesTeamMem6.User__c = userinfo.GetuserId();
         insert SalesTeamMem6 ;

         PatchTeamMember__c SalesTeamMem7 = new PatchTeamMember__c();
         SalesTeamMem7.Role__c = 'ZPA SE';
         SalesTeamMem7.PatchTeam__c = salestert.Id;
         SalesTeamMem7.User__c = userinfo.GetuserId();
         insert SalesTeamMem7 ;

         Patch__c patch  = new Patch__c();
         patch.Active__c = true;
         patch.PatchTeam__c = salestert.Id ;
         patch.PatchName__c = 'Test Patch';
         insert patch;

         Account acc = new account();
         Acc.Name = 'Test Data';
         acc.Patch__c = patch.Id;
         insert acc;

         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Test';
         con.AccountId = acc.id;
         insert con;

         TriggerUtility.contactPatchManagerReset();

         acc.Patch__c = patch.Id;
         update acc;

         con.AccountId = acc.id;
         update con;

         acc.Patch__c = null;
         acc.DS_Review_Status__c = null;
         update acc;

         Opportunity opp = new Opportunity();
         opp.Name = 'test Opp';
         opp.AccountId = acc.Id;
         Opp.StageName = label.Stage_1_Alignment /*'01 - Prospect'*/;
         opp.CloseDate = system.today();
         insert opp;
         test.stopTest();
     }


}