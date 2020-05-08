@isTest
public class Equipment_request_redirector_Test{
    static testmethod void test1(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        PageReference pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        Equipment_request_redirector  ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
        insert EquiReq;
        pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
    }
    
    static testmethod void test2(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        PageReference pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        Equipment_request_redirector  ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
        insert EquiReq;
        pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
    }
    
    static testmethod void test3(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Virtual_ZEN').getRecordTypeId();
        Test.startTest();
        //Admin Entries
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        PageReference pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        Equipment_request_redirector  ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
        insert EquiReq;
        pageRef = Page.Equipment_Request_navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(opportunity.Id));
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new Equipment_request_redirector(sc);
        ctrl.init();
    }
}