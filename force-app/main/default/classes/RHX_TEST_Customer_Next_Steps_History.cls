@isTest(SeeAllData=true)
public class RHX_TEST_Customer_Next_Steps_History {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Customer_Next_Steps_History__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Customer_Next_Steps_History__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}