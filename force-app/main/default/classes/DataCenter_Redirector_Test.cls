@isTest
public class DataCenter_Redirector_Test{
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
        
        insert EquiReq;
        Datacenter__c dc = new Datacenter__c(Name='DC1', Equipment_Request__c = EquiReq.Id, Facility_Country__c = 'India', Facility_City__c = 'CBE');
        PageReference pageRef = Page.Datacenter_Navigation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(dc);
        DataCenter_Redirector   ctrl = new DataCenter_Redirector (sc);
        ctrl.init();
        insert dc;
        pageRef = Page.Datacenter_Navigation;
        pageRef.getParameters().put('id', String.valueOf(dc.Id));
        Test.setCurrentPage(pageRef);
        sc = new ApexPages.StandardController(dc);
        ctrl = new DataCenter_Redirector(sc);
        ctrl.init();
    }
}