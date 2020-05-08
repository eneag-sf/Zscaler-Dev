/*************************************************************************************************************************
 @Name: APTS_EquipmentRequest_Trigger_Test
 @Author: Anay Bhande
 @Created Date: 15/12/2016
 @Descripton: Test Class for APTS_EquipmentRequest_Trigger
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTS_EquipmentRequest_Trigger_Test {
    public static testMethod void testMyController() {
        Id caviumcardER = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Cavium Card').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        
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
        deal.Partner_Account__c = accountId;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        insert deal;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, REcordtypeId = caviumcardER);
        insert EquiReq;
        EquiReq.Approval_Status__c='Approved';
        EquiReq.Federal_Deal_Approved_EQ__c = true;
        update EquiReq;
        EquiReq.Federal_Deal_Approved_EQ__c = false;
        //EquiReq.Opportunity__c = null;
        Equireq.Deal_Registration__c = deal.Id;
        update EquiReq;
        Test.stopTest();
    }
    public static testMethod void testMyController1() {
        Id caviumcardER = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByName().get('Professional Services').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        
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
        deal.Partner_Account__c = accountId;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        insert deal;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, REcordtypeId = caviumcardER);
        insert EquiReq;
        EquiReq.Approval_Status__c='Approved';
        EquiReq.Federal_Deal_Approved_EQ__c = true;
        update EquiReq;
        EquiReq.Federal_Deal_Approved_EQ__c = false;
        //EquiReq.Opportunity__c = null;
        Equireq.Deal_Registration__c = deal.Id;
        update EquiReq;
        Test.stopTest();
    }
}