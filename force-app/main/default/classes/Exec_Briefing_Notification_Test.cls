@istest
public class Exec_Briefing_Notification_Test{
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = 'Test Stage', SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(Opportunity__c = opp.id, date_of_meeting__c = date.today().adddays(1), Approval_Status__c = 'Approved');
        insert eb;
        
        Executive_Briefing_Internal_Attendees__c ebi = new Executive_Briefing_Internal_Attendees__c (Executive_Briefing_Request__c = eb.id);
        insert ebi;
        
        Exec_Briefing_Notification_CC_List__c csrec = new Exec_Briefing_Notification_CC_List__c(name='Avaideeswaran@zscaler.com');
        insert csrec;
        
        
        Exec_Briefing_Notification batch;
        batch = new Exec_Briefing_Notification();
        batch.errorlst.add('abc');
        Database.executeBatch(batch,1);
    }
}