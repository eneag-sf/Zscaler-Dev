@isTest
public class Equipment_Request_with_Site_Info_Test{
    static testmethod void test1(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        insert new Requested_Hardware_Model_Values__c(name='ZIA_Service_Edge_PZEN', Values__c = 'HW1');
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        
        insert EquiReq;
        
        Equipment_Request_with_Site_Info ctrl = new Equipment_Request_with_Site_Info();
        ctrl.typeofTemplate = 'abc';
        ctrl.equipmentRequestRecordId = EquiReq.Id;
        ctrl = new Equipment_Request_with_Site_Info();
        system.debug(ctrl.url);
    }
}