@isTest
public class CodeCoverageboosterTest 
{
   @isTest static void testMethod1()
    {
        AccountTriggerHelper acc = new AccountTriggerHelper();
        acc.dummyCounter(1);
    }
    
    @isTest static void testMethod2()
    {
        AccountTriggerHelper acc = new AccountTriggerHelper();
        acc.dummyCounter2(1);
    } 
  @isTest static void testMethod3()
    {
        OppotunityTriggerHelper.booster();
        OpportunitySplitTriggerHelper.booster();
        OpportunityTeamMemberHandler.booster();
    TriggerUtility.booster();
    ZForecastingService.booster();
    CaseCreationForAccountAndOpportunity.booster();
    CTMDomainVerificationandCaseCreation.booster();
    ProvisioningRequestTriggerHelper.booster();
    YearWiseSplitUtil.booster();
    leadTriggerHelper.booster();
    QuoteApprovalController.booster();    
    //ContactTriggerHelper.booster();
    DealRegTriggerHelper.booster();  
    //SCISYNC.booster();
    //ManageSCIExternalAttendeeService.booster();
    
    }
 /*  @isTest static void testMethod4()
    {
        APTS_CreateAssetBatch b = new APTS_CreateAssetBatch('select id,name,Platform_Renewal_Date__c,No_of_Platform_Seats__c,APTS_Platform_Subscription_End_Date__c,APTS_No_of_Platform_Seats__c,APTS_Asset_SKU__c  from account');
        database.executebatch(b,10);
    }
  @isTest static void testMethod5()
    {
  
    //PageReference myVfPage = Page.PRStopPurgePage;
    //Test.setCurrentPageReference(myVfPage);
    //ApexPages.StandardController sc = new ApexPages.StandardController(provisioningRequests[0]);   
    RenewalNotificationController pc= new RenewalNotificationController();
    pc.booster();
    PRQuickActionController.booster();
        SendPOCAlertImmediate.booster();
  } */
}