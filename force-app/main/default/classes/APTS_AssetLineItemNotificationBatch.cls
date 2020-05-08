/*************************************************************************************************************************
 @Name: APTS_AssetLineItemNotificationBatch
 @Author: Shishir Bose
 @Created Date: 11/08/2016
 @Descripton: This batch job sends notification for Asset expiration
 @Used By: 
*************************************************************************************************************************/
global class APTS_AssetLineItemNotificationBatch implements Database.Batchable<sObject>,
Database.AllowsCallouts, Database.Stateful {

    global final String Query;
    global final set<Id> accountIds;
    
   global APTS_AssetLineItemNotificationBatch(set<Id> acntIds){
     
      accountIds = acntIds;    
      Query = 'select Id, Name, ownerId, owner.Name, owner.email '
      + 'from Account where id in :accountIds';
   }
   
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
      for(Sobject s : scope)
      {
        APTS_AssetLineItemUtil.processAssetLineItems((Account)s);           
      }
   }

   global void finish(Database.BatchableContext BC){
      
   }
   
   
}