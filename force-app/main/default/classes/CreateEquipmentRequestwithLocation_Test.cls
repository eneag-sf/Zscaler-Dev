@isTest
public class CreateEquipmentRequestwithLocation_Test{
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
        PageReference pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(Opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        CreateEquipmentRequestwithLocation  ctrl = new CreateEquipmentRequestwithLocation(sc);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.onSave();
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        EquiReq.Approval_Status__c='Approved';
        update EquiReq;
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.indextoRemove = '1';
        ctrl.RemoveLocation();
        ctrl.onCancel();
        ctrl.onSave();
        Test.stopTest();
    }
}