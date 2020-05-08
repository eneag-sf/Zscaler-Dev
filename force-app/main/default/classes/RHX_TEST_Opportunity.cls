@isTest(SeeAllData=true)
public class RHX_TEST_Opportunity {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM Opportunity where APTS_Primary_Proposal_Lookup__c != null LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Opportunity()
            );
        }
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}