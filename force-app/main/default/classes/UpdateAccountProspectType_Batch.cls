/**
 * @File Name          : UpdateAccountProspectType_Batch.cls
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 24/5/2019, 5:56:00 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    23/5/2019, 7:17:51 PM   pranjalsingh@zscaler.com     Initial Version
**/
global class UpdateAccountProspectType_Batch implements Database.Batchable<sObject>
{
  global Database.QueryLocator start(Database.BatchableContext BC)
  {
    String Stage = label.Stage_7_Closed_Lost;
    String SubStageClosedWithNoDes = Label.SubStage_Closed_With_No_Decision;
    String SubStringClosedLost = Label.SubStage_Closed_Lost;
    List<String> StageList = new List<String>(); 
    StageList.add(Stage);
    //return Database.getQueryLocator('SELECT Id,Prospect_Type__c,Last_F2F_Meeting__c,Type FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename IN (\'11 - Closed Lost\',\'12 - Closed With No Decision\')) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6');
    return Database.getQueryLocator('SELECT Id,Prospect_Type__c,Last_F2F_Meeting__c,Type FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Stagename IN:StageList AND (Sub_Stage__c =:SubStageClosedWithNoDes OR Sub_Stage__c =:SubStringClosedLost)) AND Last_F2F_Meeting__c != null AND Last_F2F_Meeting__c < LAST_N_MONTHS:6');
  }

  global void execute(Database.BatchableContext BC,List<Account> scope)
  {
    List <Account> lstAccount = new list<Account>();
    if(!scope.isEmpty()){
      for(Account acc : scope){
        
          if(acc.Type == TriggerUtility.PROSPECT){
              acc.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
          }
          else{
              acc.Prospect_Type__c = TriggerUtility.BLANK;
          }
          lstAccount.add(acc);
       
      }
      if(!lstAccount.isEmpty())
        Database.update(lstAccount);
        
    }
  }

  global void finish(Database.BatchableContext BC)
  {
      //Post Processing 
  }

}