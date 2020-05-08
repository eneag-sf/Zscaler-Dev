@isTest(SeeAllData=true)
public class RHX_TEST_Apttus_Config2_LineItem {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Apttus_Config2__LineItem__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Apttus_Config2__LineItem__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}