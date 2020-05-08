/**
 * @File Name          : updateAccountProspectType_Batch_Test.cls
 * @Description        : 
 * @Author             : pranjalsingh
 * @Group              : 
 * @Last Modified By   : pranjalsingh
 * @Last Modified On   : 21/6/2019, 5:49:36 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    21/6/2019, 4:47:12 PM       pranjalsingh             Initial Version
**/
@isTest
private class UpdateAccountProspectType_Batch_Test {

    
    static List<Account> updateF2FAccountDate(List<Account> accList,string ProspectType){
		TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        List<Account> accListReturn = new List<Account>();
        for(Account acc: accList){
            if(acc.Last_F2F_Meeting__c == null){
              acc.Last_F2F_Meeting__c = Date.Today().adddays(-230);
              acc.Prospect_Type__c = ProspectType;
              accListReturn.add(acc);
            }
        }
        if(!accListReturn.isEmpty()){
            return accListReturn;
        }
        else{
            return null;
        } 
    }
    static testmethod void testPositive() {
		TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        List<Account> accListPositive = new List<Account>();
        List<Account> accBufferList = new List<Account>();
        accListPositive = Universal_TestData.getAccounts('SampleTestPositive','Prospect',1);
        Test.Starttest();
          accBufferList = updateF2FAccountDate(accListPositive,'No recent engagement');
          Database.insert(accListPositive);
          List<Opportunity> oppList = new List<Opportunity>();
          for(Account acc : accBufferList){
              Opportunity opp = new Opportunity(Name = 'TestOpp',AccountId = acc.Id,StageName = label.Stage_7_Closed_Lost,Sub_Stage__c = label.SubStage_Closed_Lost/*'Closed Lost'*/ /*'12 - Closed With No Decision'*/, 
                                                CloseDate = Date.Today().addDays(20));
              oppList.add(opp);
          }
          insert oppList;
          Database.update(accListPositive);
          
          UpdateAccountProspectType_Batch batchClass = new updateAccountProspectType_Batch();
          Database.executeBatch(batchClass);
        Test.Stoptest();
        System.assertequals([SELECT Prospect_Type__c FROM Account WHERE Name = 'SampleTestPositive' LIMIT 1].Prospect_Type__c,'No recent engagement');
        //System.assertequals([SELECT count() FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename IN ('11 - Closed Lost','12 - Closed With No Decision')) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6 AND Name = 'SampleTestPositive'],1);
        System.assertequals([SELECT count() FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename =:label.Stage_7_Closed_Lost) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6 AND Name = 'SampleTestPositive'],1);
    }
    static testmethod void testNegative() {
		TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        List<Account> accListNegative = new List<Account>();
        List<Account> accBufferList = new List<Account>();
        accListNegative = Universal_TestData.getAccounts('SampleTestNegative','Prospect',1);
        Test.Starttest();
          /*accBufferList = updateF2FAccountDate(accListNegative,'Opportunity Lost');
          Database.insert(accBufferList);
          List<Opportunity> oppList = new List<Opportunity>();
          oppList = Universal_TestData.getOpp(accBufferList,'TestOpp22',TriggerUtility.OPP_CLOSED_12);
          insert oppList;
          Database.update(accBufferList);*/
          accBufferList = updateF2FAccountDate(accListNegative,'Opportunity Lost');
          Database.insert(accListNegative);
          List<Opportunity> oppList = new List<Opportunity>();
          for(Account acc : accBufferList){
              Opportunity opp = new Opportunity(Name = 'TestOpp',AccountId = acc.Id,StageName = label.Stage_7_Closed_Lost,Sub_Stage__c = label.SubStage_Closed_Lost /*'Closed Lost'*/ /*'12 - Closed With No Decision'*/, 
                                                CloseDate = Date.Today().addDays(20));
              oppList.add(opp);
          }
          insert oppList;
          Database.update(accListNegative);
          UpdateAccountProspectType_Batch batchClass = new updateAccountProspectType_Batch();
          Database.executeBatch(batchClass);
        Test.Stoptest();
        //System.assertequals([SELECT count() FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename IN ('11 - Closed Lost','12 - Closed With No Decision')) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6 AND Name = 'SampleTestNegative'],1);
        System.assertequals([SELECT count() FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename =:label.Stage_7_Closed_Lost ) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6 AND Name = 'SampleTestNegative'],1);
        System.assertequals([SELECT Prospect_Type__c,Type FROM Account WHERE Name = 'SampleTestNegative' LIMIT 1].Type,'Prospect');
    }

}