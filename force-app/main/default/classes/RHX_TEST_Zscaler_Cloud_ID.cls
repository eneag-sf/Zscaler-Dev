@isTest(SeeAllData=true)
public class RHX_TEST_Zscaler_Cloud_ID {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Zscaler_Cloud_ID__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Zscaler_Cloud_ID__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}