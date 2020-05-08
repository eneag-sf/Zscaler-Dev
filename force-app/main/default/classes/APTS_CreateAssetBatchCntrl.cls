public class APTS_CreateAssetBatchCntrl  {


    @RemoteAction
    public static void createAssetsFromContractDetails () {
        APTS_CreateAssetBatch b = new APTS_CreateAssetBatch('select id,name,Platform_Renewal_Date__c,No_of_Platform_Seats__c,APTS_Platform_Subscription_End_Date__c,APTS_No_of_Platform_Seats__c,APTS_Asset_SKU__c  from account');
        database.executebatch(b,10);
    }
}