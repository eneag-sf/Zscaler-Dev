global class APTS_AssetExpiringNotificationSchedule implements Schedulable{

    global void execute(SchedulableContext SC) {
        
        Set<Id> accountIds = new Set<Id>();
        for(Account acnt : [select Id, Name from Account])
        {
            accountIds.add(acnt.Id);
        }
        
        if(accountIds.size() > 0)
        {
          Id batchInstanceId = Database.executeBatch(new APTS_AssetLineItemNotificationBatch(accountIds), 1);
        }
    }
    
}