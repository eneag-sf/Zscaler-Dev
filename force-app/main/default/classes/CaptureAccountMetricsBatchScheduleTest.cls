/*****************************************************************************************
Name: CaptureAccountMetricsBatchScheduleTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for CaptureAccountMetricsBatch & CaptureAccountMetricsBatchSchedule
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Oct-2015    Initial Development
******************************************************************************************/ 

@isTest(SeeAllData=false)
private class CaptureAccountMetricsBatchScheduleTest {
    static testmethod void test() {
       ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
       insert zs;
       Account acc = new Account(Name = 'Test Account');
       insert acc;
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
       insert opp;
       List<Significant_Customer_Interaction__c> scilst = new List<Significant_Customer_Interaction__c>();

       /*
       Commenting the below code as POC Inline record type has been deactivated.
        */
       //String pocInlineRecTypeId = Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('POC Inline').RecordTypeId;
       
       string impConfRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Very Important Conf Call').RecordTypeId;
       string meetingRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Regular Meeting').RecordTypeId;
       string zsrrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('QBR').RecordTypeId;
       string archsessionrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Architecture Session').RecordTypeId;
       
       
       Significant_Customer_Interaction__c sci1 = new Significant_Customer_Interaction__c(); 
       sci1.Date__c = system.today()+1;
       sci1.Next_Steps__c = 'Test Data';
       sci1.Interaction_With__c = 'Customer';
       sci1.I_am_the__c = 'Attendee'; 
       sci1.RecordTypeId = meetingRecTypeId;
       sci1.Meeting_Notes__c = 'Test Data';
       sci1.Account_Name__c = acc.Id;
       sci1.Opportunity_Name__c = opp.Id;
       sci1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci1.Method_Of_Interaction__c = 'F2F';
       insert sci1;
       
       Significant_Customer_Interaction__c sci2 = new Significant_Customer_Interaction__c(); 
       sci2.Date__c = system.today()+2;
       sci2.Next_Steps__c = 'Test Data';
       sci2.Interaction_With__c = 'Customer';
       sci2.I_am_the__c = 'Attendee'; 
       sci2.RecordTypeId = meetingRecTypeId;
       sci2.Meeting_Notes__c = 'Test Data';
       sci2.Account_Name__c = acc.Id;
       sci2.Opportunity_Name__c = opp.Id;
       sci2.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci2.Method_Of_Interaction__c = 'F2F';
       insert sci2;
       
       /*
       Commenting the below code as POC Inline record type has been deactivated.
        */
       //Significant_Customer_Interaction__c sci3 = new Significant_Customer_Interaction__c(); 
       //sci3.Date__c = system.today()+1;
       //sci3.Next_Steps__c = 'Test Data';
       //sci3.Interaction_With__c = 'Customer';
       //sci3.I_am_the__c = 'Attendee'; 
       //sci3.RecordTypeId = pocInlineRecTypeId;
       //sci3.Meeting_Notes__c = 'Test Data';
       //sci3.Account_Name__c = acc.Id;
       //sci3.Opportunity_Name__c = opp.Id;
       //sci3.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       //insert sci3;
       
       //Significant_Customer_Interaction__c sci4 = new Significant_Customer_Interaction__c(); 
       //sci4.Date__c = system.today()+2;
       //sci4.Next_Steps__c = 'Test Data';
       //sci4.Interaction_With__c = 'Customer';
       //sci4.I_am_the__c = 'Attendee'; 
       //sci4.RecordTypeId = pocInlineRecTypeId;
       //sci4.Meeting_Notes__c = 'Test Data';
       //sci4.Account_Name__c = acc.Id;
       //sci4.Opportunity_Name__c = opp.Id;
       //sci4.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       //insert sci4;
       
       Significant_Customer_Interaction__c sci5 = new Significant_Customer_Interaction__c(); 
       sci5.Date__c = system.today()+1;
       sci5.Next_Steps__c = 'Test Data';
       sci5.Interaction_With__c = 'Customer';
       sci5.I_am_the__c = 'Attendee'; 
       sci5.RecordTypeId = meetingRecTypeId;
       sci5.Meeting_Notes__c = 'Test Data';
       sci5.Account_Name__c = acc.Id;
       sci5.Opportunity_Name__c = opp.Id;
       sci5.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci5.Method_Of_Interaction__c = 'Webex/Call';
       insert sci5;
       
       Significant_Customer_Interaction__c sci6 = new Significant_Customer_Interaction__c(); 
       sci6.Date__c = system.today()+1;
       sci6.Next_Steps__c = 'Test Data';
       sci6.Interaction_With__c = 'Customer';
       sci6.I_am_the__c = 'Attendee'; 
       sci6.RecordTypeId = meetingRecTypeId;
       sci6.Meeting_Notes__c = 'Test Data';
       sci6.Account_Name__c = acc.Id;
       sci6.Opportunity_Name__c = opp.Id;
       sci6.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci6.Method_Of_Interaction__c = 'Webex/Call';
       insert sci6;
       
       test.startTest();
       Significant_Customer_Interaction__c sci7 = new Significant_Customer_Interaction__c(); 
       sci7.Date__c = system.today()+2;
       sci7.Next_Steps__c = 'Test Data';
       sci7.Interaction_With__c = 'Customer';
       sci7.I_am_the__c = 'Attendee'; 
       sci7.RecordTypeId = zsrrtid;
       sci7.Meeting_Notes__c = 'Test Data';
       sci7.Account_Name__c = acc.Id;
       sci7.Opportunity_Name__c = opp.Id;
       sci7.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci7.Method_Of_Interaction__c = 'F2F';
       insert sci7;
       
       Significant_Customer_Interaction__c sci8 = new Significant_Customer_Interaction__c(); 
       sci8.Date__c = system.today()+2;
       sci8.Next_Steps__c = 'Test Data';
       sci8.Interaction_With__c = 'Customer';
       sci8.I_am_the__c = 'Attendee'; 
       sci8.RecordTypeId = archsessionrtid;
       sci8.Meeting_Notes__c = 'Test Data';
       sci8.Account_Name__c = acc.Id;
       sci8.Opportunity_Name__c = opp.Id;
       sci8.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci8.Method_Of_Interaction__c = 'F2F';
       insert sci8;
       
       
       Significant_Customer_Interaction__c sci9 = new Significant_Customer_Interaction__c(); 
       sci9.Next_Steps__c = 'Test Data';
       sci9.Interaction_With__c = 'Customer';
       sci9.I_am_the__c = 'Attendee'; 
       sci9.RecordTypeId = archsessionrtid;
       sci9.Meeting_Notes__c = 'Test Data';
       sci9.Opportunity_Name__c = opp.Id;
       sci9.Account_Name__c = acc.Id;
       sci9.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci9.Method_Of_Interaction__c = 'F2F';
       insert sci9;
       
       Significant_Customer_Interaction__c sci10 = new Significant_Customer_Interaction__c(); 
       sci10.Next_Steps__c = 'Test Data';
       sci10.Interaction_With__c = 'Customer';
       sci10.I_am_the__c = 'Attendee'; 
       sci10.RecordTypeId = zsrrtid;
       sci10.Meeting_Notes__c = 'Test Data';
       sci10.Opportunity_Name__c = opp.Id;
       sci10.Account_Name__c = acc.Id;
       sci10.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci10.Method_Of_Interaction__c = 'F2F';
       insert sci10;
       
       Significant_Customer_Interaction__c sci13 = new Significant_Customer_Interaction__c(); 
       sci13.Next_Steps__c = 'Test Data';
       sci13.Interaction_With__c = 'Customer';
       sci13.I_am_the__c = 'Attendee'; 
       sci13.RecordTypeId = meetingRecTypeId;
       sci13.Meeting_Notes__c = 'Test Data';
       sci13.Opportunity_Name__c = opp.Id;
       sci13.Account_Name__c = acc.Id;
       sci13.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci13.Method_Of_Interaction__c = 'Webex/Call';
       insert sci13;
       
       Significant_Customer_Interaction__c sci14 = new Significant_Customer_Interaction__c(); 
       sci14.Next_Steps__c = 'Test Data';
       sci14.Interaction_With__c = 'Customer';
       sci14.I_am_the__c = 'Attendee'; 
       sci14.RecordTypeId = meetingRecTypeId;
       sci14.Meeting_Notes__c = 'Test Data';
       sci14.Account_Name__c = acc.Id;
       sci14.Opportunity_Name__c = opp.Id;
       sci14.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci14.Method_Of_Interaction__c = 'Webex/Call';
       insert sci14;
       
       
       
       task ts = new task();
       ts.OwnerId = userinfo.getUserId();
       ts.Subject = 'Test Subject';
       ts.whatId = acc.Id;
       insert ts;
       
       task ts1 = new task();
       ts1.OwnerId = userinfo.getUserId();
       ts1.Subject = 'Test Subject';
       ts1.whatId = acc.Id;
       insert ts1;
       
       String CRON_EXP = '0 0 0 15 3 ? 2022';
       String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new CaptureAccountMetricsBatchSchedule());
       test.stopTest();
    }
    
    static testmethod void test2() {
       ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
       insert zs;
       Account acc = new Account(Name = 'Test Account');
       insert acc;
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
       insert opp;
       List<Significant_Customer_Interaction__c> scilst = new List<Significant_Customer_Interaction__c>();

       /*
       Commenting the below code as POC Inline record type has been deactivated.
        */
       //String pocInlineRecTypeId = Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('POC Inline').RecordTypeId;
       
       string impConfRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Very Important Conf Call').RecordTypeId;
       string meetingRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Regular Meeting').RecordTypeId;
       string zsrrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('QBR').RecordTypeId;
       string archsessionrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Architecture Session').RecordTypeId;
       
       Significant_Customer_Interaction__c sci1_1 = new Significant_Customer_Interaction__c(); 
       sci1_1.Date__c = system.today()+1;
       sci1_1.Next_Steps__c = 'Test Data';
       sci1_1.Interaction_With__c = 'Customer';
       sci1_1.I_am_the__c = 'Attendee'; 
       sci1_1.RecordTypeId = meetingRecTypeId;
       sci1_1.Meeting_Notes__c = 'Test Data';
       sci1_1.Opportunity_Name__c = opp.Id;
       sci1_1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci1_1.Method_Of_Interaction__c = 'F2F';
       insert sci1_1;
       
       Significant_Customer_Interaction__c sci2_1 = new Significant_Customer_Interaction__c(); 
       sci2_1.Date__c = system.today()+2;
       sci2_1.Next_Steps__c = 'Test Data';
       sci2_1.Interaction_With__c = 'Customer';
       sci2_1.I_am_the__c = 'Attendee'; 
       sci2_1.RecordTypeId = meetingRecTypeId;
       sci2_1.Meeting_Notes__c = 'Test Data';
       sci2_1.Opportunity_Name__c = opp.Id;
       sci2_1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci2_1.Method_Of_Interaction__c = 'F2F';
       insert sci2_1;
       
       
       /*
       Commenting the below code as POC Inline record type has been deactivated.
        */
       //Significant_Customer_Interaction__c sci3 = new Significant_Customer_Interaction__c(); 
       //sci3.Date__c = system.today()+1;
       //sci3.Next_Steps__c = 'Test Data';
       //sci3.Interaction_With__c = 'Customer';
       //sci3.I_am_the__c = 'Attendee'; 
       //sci3.RecordTypeId = pocInlineRecTypeId;
       //sci3.Meeting_Notes__c = 'Test Data';
       //sci3.Account_Name__c = acc.Id;
       //sci3.Opportunity_Name__c = opp.Id;
       //sci3.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       //insert sci3;
       
       //Significant_Customer_Interaction__c sci4 = new Significant_Customer_Interaction__c(); 
       //sci4.Date__c = system.today()+2;
       //sci4.Next_Steps__c = 'Test Data';
       //sci4.Interaction_With__c = 'Customer';
       //sci4.I_am_the__c = 'Attendee'; 
       //sci4.RecordTypeId = pocInlineRecTypeId;
       //sci4.Meeting_Notes__c = 'Test Data';
       //sci4.Account_Name__c = acc.Id;
       //sci4.Opportunity_Name__c = opp.Id;
       //sci4.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       //insert sci4;
       
       Significant_Customer_Interaction__c sci5 = new Significant_Customer_Interaction__c(); 
       sci5.Date__c = system.today()+1;
       sci5.Next_Steps__c = 'Test Data';
       sci5.Interaction_With__c = 'Customer';
       sci5.I_am_the__c = 'Attendee'; 
       sci5.RecordTypeId = meetingRecTypeId;
       sci5.Meeting_Notes__c = 'Test Data';
       sci5.Opportunity_Name__c = opp.Id;
       sci5.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci5.Method_Of_Interaction__c = 'Webex/Call';
       insert sci5;
       
       Significant_Customer_Interaction__c sci6 = new Significant_Customer_Interaction__c(); 
       sci6.Date__c = system.today()+1;
       sci6.Next_Steps__c = 'Test Data';
       sci6.Interaction_With__c = 'Customer';
       sci6.I_am_the__c = 'Attendee'; 
       sci6.RecordTypeId = meetingRecTypeId;
       sci6.Meeting_Notes__c = 'Test Data';
       sci6.Opportunity_Name__c = opp.Id;
       sci6.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci6.Method_Of_Interaction__c = 'Webex/Call';
       insert sci6;
       
       test.startTest();
       Significant_Customer_Interaction__c sci7 = new Significant_Customer_Interaction__c(); 
       sci7.Date__c = system.today()+2;
       sci7.Next_Steps__c = 'Test Data';
       sci7.Interaction_With__c = 'Customer';
       sci7.I_am_the__c = 'Attendee'; 
       sci7.RecordTypeId = zsrrtid;
       sci7.Meeting_Notes__c = 'Test Data';
       sci7.Opportunity_Name__c = opp.Id;
       sci7.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci7.Method_Of_Interaction__c = 'F2F';
       insert sci7;
       
       Significant_Customer_Interaction__c sci8 = new Significant_Customer_Interaction__c(); 
       sci8.Date__c = system.today()+2;
       sci8.Next_Steps__c = 'Test Data';
       sci8.Interaction_With__c = 'Customer';
       sci8.I_am_the__c = 'Attendee'; 
       sci8.RecordTypeId = archsessionrtid;
       sci8.Meeting_Notes__c = 'Test Data';
       sci8.Opportunity_Name__c = opp.Id;
       sci8.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci8.Method_Of_Interaction__c = 'F2F';
       insert sci8;
       
       
       Significant_Customer_Interaction__c sci11 = new Significant_Customer_Interaction__c(); 
       sci11.Next_Steps__c = 'Test Data';
       sci11.Interaction_With__c = 'Customer';
       sci11.I_am_the__c = 'Attendee'; 
       sci11.RecordTypeId = archsessionrtid;
       sci11.Meeting_Notes__c = 'Test Data';
       sci11.Opportunity_Name__c = opp.Id;
       sci11.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci11.Method_Of_Interaction__c = 'F2F';
       insert sci11;
       
       Significant_Customer_Interaction__c sci12 = new Significant_Customer_Interaction__c(); 
       sci12.Next_Steps__c = 'Test Data';
       sci12.Interaction_With__c = 'Customer';
       sci12.I_am_the__c = 'Attendee'; 
       sci12.RecordTypeId = zsrrtid;
       sci12.Meeting_Notes__c = 'Test Data';
       sci12.Opportunity_Name__c = opp.Id;
       sci12.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci12.Method_Of_Interaction__c = 'F2F';
       insert sci12;
       
       Significant_Customer_Interaction__c sci13 = new Significant_Customer_Interaction__c(); 
       sci13.Next_Steps__c = 'Test Data';
       sci13.Interaction_With__c = 'Customer';
       sci13.I_am_the__c = 'Attendee'; 
       sci13.RecordTypeId = meetingRecTypeId;
       sci13.Meeting_Notes__c = 'Test Data';
       sci13.Opportunity_Name__c = opp.Id;
       sci13.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci13.Method_Of_Interaction__c = 'Webex/Call';
       insert sci13;
       
       Significant_Customer_Interaction__c sci14 = new Significant_Customer_Interaction__c(); 
       sci14.Next_Steps__c = 'Test Data';
       sci14.Interaction_With__c = 'Customer';
       sci14.I_am_the__c = 'Attendee'; 
       sci14.RecordTypeId = meetingRecTypeId;
       sci14.Meeting_Notes__c = 'Test Data';
       sci14.Opportunity_Name__c = opp.Id;
       sci14.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci14.Method_Of_Interaction__c = 'Webex/Call';
       insert sci14;
       
       
       
       task ts = new task();
       ts.OwnerId = userinfo.getUserId();
       ts.Subject = 'Test Subject';
       ts.whatId = acc.Id;
       insert ts;
       
       task ts1 = new task();
       ts1.OwnerId = userinfo.getUserId();
       ts1.Subject = 'Test Subject';
       ts1.whatId = acc.Id;
       insert ts1;
       
       String CRON_EXP = '0 0 0 15 3 ? 2022';
       String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new CaptureAccountMetricsBatchSchedule());
       test.stopTest();
    }
}