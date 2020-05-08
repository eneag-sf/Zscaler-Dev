@isTest
private class SiteApprovalRequestControllerTest {

    @isTest static void testSiteRequestController() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Equipment_Request__c' AND Name = 'Middle Eastern Approval' LIMIT 1];
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(RecordTypeId = rt.Id, Opportunity__c=Opportunity.Id, Localized_content__c=true);
        insert EquiReq;

        Site_Request__c sr = new Site_Request__c(
                Contact_Email__c = 'vprakas@ZScaler.com',Contact_Name__c='Vijay',Contact_phone__c='098756756',Country_for_ME_Node__c='Qatar',
                Customer_City__c='Qatar',Customer_Country_New__c='Qatar',Customer_Name__c=account.Id,Customer_State__c='Qatar',
                Customer_Street_Address__c='123, Golden Palm Road',Domain_Name__c='test.com',Estimated_Start_Date__c=Date.today(),
                Estimated_Stop_Date__c=Date.today()+1,ISP_Used__c='verizon',ME_Equipment_Request__c=EquiReq.Id,
                Number_of_users__c=12345,Zscaler_Suite_and_any_Add_ons_to_be_quot__c='test', Is_this_for_a_POC__c = 'Yes'
            );
        insert sr;

        SiteApprovalRequestController ctrlr = new SiteApprovalRequestController();
        ctrlr.equipmentRequestRecordId = EquiReq.Id;

        ctrlr.getSiteRequests();

        delete sr;
    }
}