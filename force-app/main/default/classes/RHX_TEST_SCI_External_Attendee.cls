@isTest(SeeAllData=true)
public class RHX_TEST_SCI_External_Attendee {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM SCI_External_Attendee__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new SCI_External_Attendee__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}