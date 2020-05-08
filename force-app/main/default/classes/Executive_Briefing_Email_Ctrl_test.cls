@istest
public class Executive_Briefing_Email_Ctrl_test{
    
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
        
        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(opportunity__c = opp.Id, Is_Meeting_Confirmed__c = false, date_of_meeting__c = date.today());
        insert eb;
        
        
        
        Test.StartTest();
        
        Executive_Briefing_Email_Controller ctrl = new Executive_Briefing_Email_Controller ();
        ctrl.ebId = eb.Id;
        ctrl.typeofTemplate = 'Approved';
        
        
        system.debug(ctrl.EB);
        system.debug(ctrl.url);
        system.debug(ctrl.approverName);
        system.debug(ctrl.yearVal);
        system.debug(ctrl.timeZone);
        system.debug(ctrl.meetingStartDate);
        system.debug(ctrl.meetingEndDate);
        system.debug(ctrl.meetingStartTime);
        system.debug(ctrl.meetingEndTime);
        
        system.debug(ctrl.closeDate);
        system.debug(ctrl.executiveName);
        
        
        Test.stopTest();
    }
    
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
        
        
        Executive_Briefing_External_Attendees__c ebrEA = new Executive_Briefing_External_Attendees__c(
            Executive_Briefing_Request__c = eb.id,
            Attendee__c=con1.id
        );
        Executive_Briefing_External_Attendees__c ebrEA1 = new Executive_Briefing_External_Attendees__c(
            Executive_Briefing_Request__c = eb.id,
            Attendee__c=con2.id
        );
        insert new List<Executive_Briefing_External_Attendees__c> { ebrEA, ebrEA1 };
        
        
        Test.StartTest();
        
        Executive_Briefing_Email_Controller ctrl = new Executive_Briefing_Email_Controller ();
        ctrl.ebId = eb.Id;
        ctrl.typeofTemplate = 'Approved';
        
        
        system.debug(ctrl.EB);
        system.debug(ctrl.url);
        system.debug(ctrl.approverName);
        system.debug(ctrl.yearVal);
        system.debug(ctrl.timeZone);
        system.debug(ctrl.meetingStartDate);
        system.debug(ctrl.meetingEndDate);
        system.debug(ctrl.meetingStartTime);
        system.debug(ctrl.meetingEndTime);
        
        system.debug(ctrl.closeDate);
        system.debug(ctrl.executiveName);
        system.debug(ctrl.comments);
            
        ctrl.getFormattedTime(Time.newInstance(18, 2, 3, 4));
        ctrl.getFormattedTime(Time.newInstance(12, 2, 3, 4));
        ctrl.getFormattedTime(Time.newInstance(0, 2, 3, 4));
        ctrl.getMonthVal(1);
        ctrl.getMonthVal(2);
        ctrl.getMonthVal(3);
        ctrl.getMonthVal(4);
        ctrl.getMonthVal(5);
        ctrl.getMonthVal(6);
        ctrl.getMonthVal(7);
        ctrl.getMonthVal(8);
        ctrl.getMonthVal(9);
        ctrl.getMonthVal(10);
        ctrl.getMonthVal(11);
        ctrl.getMonthVal(12);
        ctrl.getMonthVal(22);
        
        Test.stopTest();
    }
    
}