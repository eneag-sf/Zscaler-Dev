@isTest(SeeAllData=true)
public class RHX_TEST_Equipment_Request {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Equipment_Request__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Equipment_Request__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}