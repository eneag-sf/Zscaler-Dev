/*****************************************************************************************
Name: QBRSCIReportBatchSchedulerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to test the QBRSCIReportBatchScheduler and QBRSCIReportBatch
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     12-Jun-2017      Initial Development
******************************************************************************************/
@isTest
private class QBRSCIReportBatchSchedulerTest {
    @isTest static void testSchedulerAndBatch() {
        User u = new User(FirstName='Vijay', LastName='CA', Department='Customer Advocacy', ManagerId=UserInfo.getUserId(), ProfileId=UserInfo.getProfileId(), Email='vprakash@example.test.com', Username='vprakash@example.test.com', Alias='vca', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='UTF-8');
        System.runAs(u) {
            ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
            insert zs;
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
            insert opp;
            opportunity opp1 = new opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
            insert opp1;
            RecordType qbrRt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Name = 'QBR' AND SObjectType = 'Significant_Customer_Interaction__c' LIMIT 1];
            Significant_Customer_Interaction__c testSCI1 = new Significant_Customer_Interaction__c(
                                                                RecordTypeId = qbrRt.Id, 
                                                                Primary_Topic_Covered__c = 'QBR', 
                                                                Date__c = system.today()+1,
                                                                Next_Steps__c = 'Test Data',
                                                                Interaction_With__c = 'Customer',
                                                                I_am_the__c = 'Attendee',
                                                                Meeting_Notes__c = 'Test Data',
                                                                Account_Name__c = acc.Id,
                                                                Opportunity_Name__c = opp.Id
                                                            );
            Significant_Customer_Interaction__c testSCI2 = new Significant_Customer_Interaction__c(
                                                                RecordTypeId = qbrRt.Id, 
                                                                Primary_Topic_Covered__c = 'QBR', 
                                                                Date__c = system.today()+1,
                                                                Next_Steps__c = 'Test Data',
                                                                Interaction_With__c = 'Customer',
                                                                I_am_the__c = 'Attendee',
                                                                Meeting_Notes__c = 'Test Data',
                                                                Account_Name__c = acc.Id,
                                                                Opportunity_Name__c = opp1.Id
                                                            );
            insert new List<Significant_Customer_Interaction__c> { testSCI1, testSCI2 };

            Test.startTest();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            QBRSCIReportBatchScheduler schedule = new QBRSCIReportBatchScheduler();
            System.schedule('Test QBR Report Batch', CRON_EXP, schedule);
            Test.stopTest();
        }
    }
}