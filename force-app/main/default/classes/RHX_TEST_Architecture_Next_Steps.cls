@isTest(SeeAllData=true)
public class RHX_TEST_Architecture_Next_Steps {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Architecture_Next_Steps__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Architecture_Next_Steps__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}