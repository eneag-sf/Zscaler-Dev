@isTest(SeeAllData=true)
public class RHX_TEST_Apttus_Config2_AssetLineItem {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Apttus_Config2__AssetLineItem__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Apttus_Config2__AssetLineItem__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}