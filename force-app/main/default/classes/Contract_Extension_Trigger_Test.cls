@isTest
public class Contract_Extension_Trigger_Test{

    static testMethod void test1(){
        Id userId = UserInfo.getUserId();

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName= label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate=Date.today());
        insert opp;
        
        Contract_Extension_Request__c cer = new Contract_Extension_Request__c();
        cer.Opportunity__c = opp.Id;
        cer.Approval_Status__c = 'Pending Approval';
        insert cer;
        
        cer.Approval_Status__c = 'Approved';
        update cer;
    
    }
}