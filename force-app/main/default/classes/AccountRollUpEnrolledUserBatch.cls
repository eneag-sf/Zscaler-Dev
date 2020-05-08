global class AccountRollUpEnrolledUserBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,ZPA_Use_Cases__c, (SELECT ID, ZPA_Enrolled_Users_L31D_Rollup__c, ZPA_Enrolled_Users_L6M_Rollup__c,ZPA_Enrolled_Users_L90D_Rollup__c FROM Zscaler_Cloud_IDs__R WHERE Cloud_Type__c = \'ZPA\') FROM Account WHERE ZPA_Use_Cases__c != null' 
        );
    }
    global void execute(Database.BatchableContext bc, List<Account> records){
        List<Account> accList = new List<Account>();
        Map< Id, Decimal> L31Map = new Map< Id, Decimal>();
        Map< Id, Decimal> L6Map = new Map< Id, Decimal>();
        Map< Id, Decimal> L90Map = new Map< Id, Decimal>();
        Map< Id, Integer> countMap = new Map< Id, Integer>();
        
        for (Account acc : records)  {
            for (Zscaler_Cloud_ID__c cid : acc.Zscaler_Cloud_IDs__R)  {
                
                L31Map.put( acc.Id , L31Map.containsKey(acc.Id) ? L31Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L31D_Rollup__c): checknull(cid.ZPA_Enrolled_Users_L31D_Rollup__c) );
                
                L6Map.put( acc.Id , L6Map.containsKey(acc.Id) ? L6Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L6M_Rollup__c) : checknull(cid.ZPA_Enrolled_Users_L6M_Rollup__c) );
    
                L90Map.put( acc.Id , L90Map.containsKey(acc.Id) ? L90Map.get(acc.Id)  + checknull(cid.ZPA_Enrolled_Users_L90D_Rollup__c) : checknull(cid.ZPA_Enrolled_Users_L90D_Rollup__c) );
    
                if(countMap.containsKey(acc.Id))
                    countMap.put( acc.Id, countMap.get(acc.Id) + 1);
                else 
                    countMap.put( acc.Id, 1);
                    
            }
            
            if(!acc.Zscaler_Cloud_IDs__R.isEmpty()) {
                acc.ZPA_Enrolled_Users_L31D__c = L31Map.get(acc.Id) / countMap.get(acc.Id);
                acc.ZPA_Enrolled_Users_L6M__c = L6Map.get(acc.Id)/ countMap.get(acc.Id);
                acc.ZPA_Enrolled_Users_L90D__c = L90Map.get(acc.Id)/ countMap.get(acc.Id);
                accList.add(acc);
            } else {
                acc.ZPA_Enrolled_Users_L31D__c = 0;
                acc.ZPA_Enrolled_Users_L6M__c = 0;
                acc.ZPA_Enrolled_Users_L90D__c = 0;
                accList.add(acc);
            }
        }
        
        if(!accList.isEmpty()){
            update accList;
        }
                    
    }    

    global void finish(Database.BatchableContext bc){
        
    } 
    
    global Decimal checknull(Decimal value) {
        if(value != null) 
            return value;
        return 0.0;
    }
}