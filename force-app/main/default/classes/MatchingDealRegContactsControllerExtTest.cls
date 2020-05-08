/*****************************************************************************************
Name: MatchingDealRegContactsControllerExtTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for MatchingDealRegContactsControllerExt
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)   
public class MatchingDealRegContactsControllerExtTest{
    static testMethod void testMatchingDealRegContactsControllerExt(){
        test.startTest();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        insert acc;
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        insert acc1;
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;

        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Name';
        con.AccountId = acc.Id;
        con.Email = 'test@abc.com';
        insert con;
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
        
        PageReference pageRef = Page.MatchingDealRegContacts;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(deal.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        MatchingDealRegContactsControllerExt ext = new MatchingDealRegContactsControllerExt(sc);

        test.stopTest();
    }
}