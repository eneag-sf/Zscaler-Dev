@isTest(SeeAllData=true)
public class RHX_TEST_Technical_Validation_Next_St315 {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Technical_Validation_Next_Steps_History__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Technical_Validation_Next_Steps_History__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}