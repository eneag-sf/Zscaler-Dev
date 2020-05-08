@isTest
public class churnEditControllerTest {
    @TestSetup static void setuprecs(){
        Account acc = new Account(name='testaccount');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'test opp', AccountId = acc.Id, StageName = label.Stage_1_Alignment  /*'Qualified'*/, CloseDate = Date.Today());
        insert opp;
        Churn__c churn = new Churn__c(recordTypeId = Schema.SObjectType.Churn__c.getRecordTypeInfosByName().get('NewBusiness_Upsell').getRecordTypeId(), Type__c = 'Churn', Opportunity__c =opp.Id);
        insert churn;
        Churn__c churnLoss = new Churn__c(recordTypeId = Schema.SObjectType.Churn__c.getRecordTypeInfosByName().get('Renewals').getRecordTypeId(), Type__c = 'Loss', Opportunity__c =opp.Id);
        insert churnLoss;
    }
    
    static testmethod void testChurnctrl(){
        Churn__c churn = [Select Id,Type__c from Churn__c Where recordType.Name ='NewBusiness_Upsell' Limit 1];
        Apexpages.StandardController sc = new Apexpages.StandardController(churn);
        churnEditController ctrl = new churnEditController(sc);
        ctrl.onload();
    }
     static testmethod void testChurnLossctrl(){
        Churn__c churn = [Select Id,Type__c from Churn__c Where recordType.Name ='Renewals' Limit 1];
        Apexpages.StandardController sc = new Apexpages.StandardController(churn);
        churnEditController ctrl = new churnEditController(sc);
        ctrl.onload();
    }
}