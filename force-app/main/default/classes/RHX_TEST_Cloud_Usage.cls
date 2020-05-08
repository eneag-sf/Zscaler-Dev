@isTest(SeeAllData=true)
public class RHX_TEST_Cloud_Usage {
     static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
                   FROM Cloud_Usage__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Cloud_Usage__c()
            );
        }
         rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}