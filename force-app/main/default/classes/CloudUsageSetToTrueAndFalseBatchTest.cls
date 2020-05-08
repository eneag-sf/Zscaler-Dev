/*****************************************************************************************
Name: CloudUsageSetToTrueAndFalseBatchTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for CloudUsageSetToTrueBatch and CloudUsageSetToFalseBatch.

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            16-Nov-2016    Initial Development
******************************************************************************************/


@isTest(SeeAllData=false)
private class CloudUsageSetToTrueAndFalseBatchTest{
    static testmethod void test() {
        Account acc = new Account(Name = 'Test Account');
       insert acc;
       Zscaler_Cloud_ID__c zsCloud = new Zscaler_Cloud_ID__c();
       zsCloud.Name = 'Test.Data';
       zsCloud.Status__c = 'Test';
       zsCloud.Account__c = acc.Id;
       zsCloud.Org_Name__c = 'Test';
       zsCloud.Cloud_Type__c = 'ZIA';
       insert zsCloud;

       Cloud_Usage__c cldUsage1 = new Cloud_Usage__c();
       cldUsage1.Name = 'Test Data';
       cldUsage1.Account__c = acc.Id;
       cldUsage1.Usage_Pull_Date__c = system.today() - 30;
       cldUsage1.Cloud_Usage_Type__c = 'ZIA';
       cldUsage1.Zscaler_Cloud_ID__c = zsCloud.Id;
       insert cldUsage1;

       Cloud_Usage__c cldUsage2 = new Cloud_Usage__c();
       cldUsage2.Name = 'Test Data';
       cldUsage2.Account__c = acc.Id;
       cldUsage2.Usage_Pull_Date__c = system.today() - 200;
       cldUsage2.Cloud_Usage_Type__c = 'ZIA';
       cldUsage2.Zscaler_Cloud_ID__c = zsCloud.Id;
       cldUsage2.Last_6_Months__c = true;
       insert cldUsage2;

       database.executeBatch(new CloudUsageSetToTrueBatch(), 1);

    }
}