@istest
public class ExecutiveBriefingApprovalControllerTest {

    
    static testmethod void test2(){
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
        
        
        
        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(Customer__c = account.Id,
                                                                             Is_Meeting_Confirmed__c = true,
                                                                             Start_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                             End_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                             Time_Zone__c = '(GMT+05:30) India Standard Time (Asia/Kolkata)',
                                                                             Executive_Name__c = userInfo.getUserId(),
                                                                             date_of_meeting__c = date.today());
        insert eb;
        
        
        Executive_Briefing_Request__c eb1 = new Executive_Briefing_Request__c(Customer__c = account.Id,
                                                                             Is_Meeting_Confirmed__c = true,
                                                                             Start_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                             End_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                             Time_Zone__c = '(GMT+05:30) India Standard Time (Asia/Kolkata)',
                                                                             Executive_Name__c = userInfo.getUserId(),
                                                                             date_of_meeting__c = date.today(),
                                                                             Internal_Attendees__c = 'Test',
                                                                             Approval_Status__c = 'Approved');
        insert eb1;
        
        
        Executive_Briefing_Request__c eb2 = new Executive_Briefing_Request__c(Customer__c = account.Id,
                                                                              Is_Meeting_Confirmed__c = true,
                                                                              Start_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                              End_Time__c = Time.newInstance(4, 2, 3, 4),
                                                                              Time_Zone__c = '(GMT+05:30) India Standard Time (Asia/Kolkata)',
                                                                              Executive_Name__c = userInfo.getUserId(),
                                                                              date_of_meeting__c = date.today(),
                                                                              Internal_Attendees__c = 'Test' );
        insert eb2;
        
        
        
        Test.StartTest();
        
        ExecutiveBriefingApprovalController.SubmitForApproval(eb.id);
        ExecutiveBriefingApprovalController.SubmitForApproval(eb1.id);
        ExecutiveBriefingApprovalController.SubmitForApproval(eb2.id);
        
        Test.stopTest();
    }
}