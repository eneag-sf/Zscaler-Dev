@isTest(SeeAllData=true)
public class RHX_TEST_Significant_Customer_Interac748 {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Significant_Customer_Interaction__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Significant_Customer_Interaction__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}