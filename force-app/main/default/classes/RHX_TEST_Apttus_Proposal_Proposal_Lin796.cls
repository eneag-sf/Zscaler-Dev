@isTest(SeeAllData=true)
public class RHX_TEST_Apttus_Proposal_Proposal_Lin796 {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Apttus_Proposal__Proposal_Line_Item__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Apttus_Proposal__Proposal_Line_Item__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}