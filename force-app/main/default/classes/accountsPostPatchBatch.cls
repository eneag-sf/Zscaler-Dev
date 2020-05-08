public class accountsPostPatchBatch implements Database.Batchable<SObject>,Database.Stateful {
    
    private List<Id> recordIds;
    
    public accountsPostPatchBatch(List<Id> patchIds){
        this.recordIds = patchIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //String testAccountId = '0017000000bOBdY';
        //return Database.getQueryLocator('Select Id from Account Where Id =: testAccountId');
        if(recordIds != null && recordIds.size() > 0){
            return Database.getQueryLocator('Select Id from Account Where Patch__c IN: recordIds');
        }
        else{
            return Database.getQueryLocator('Select Id from Account');
        }
    }
    
    public void execute(Database.BatchableContext context, Account[] accounts) {
        TriggerUtility.realignPatch();
        accounts = [Select Id, Patch__c, 
                                    Sales_Territory__c,
                                    Area_Director__c,
                                    Account_Manager__c,
                                    Channel_Manager__c,
                                    Customer_Advocate__c,
                                    Sales_Engineer__c,
                                    lead_development2__c
                                    from Account Where Id IN: accounts];
        
        Map<Id, Id> accIdPatchIdMap = new Map<Id, Id>();
        Map<Id, Id> patchIdSalesTeritoryIdMap = new Map<Id, Id>();
        try{
            for(Account acc : accounts){
                if(acc.Patch__c != null){
                    accIdPatchIdMap.put(acc.Id, acc.Patch__c);
                }
                else{
                    acc.Sales_Territory__c = null;
                }
            }
            
            for(Patch__c patch : [ select id,PatchTeam__c from Patch__c where Id IN: accIdPatchIdMap.values() AND PatchTeam__c != null]){
                patchIdSalesTeritoryIdMap.put(patch.Id, patch.PatchTeam__c);
            }
            for(Account acc : accounts){
                if(accIdPatchIdMap.containsKey(acc.Id)){
                    if(patchIdSalesTeritoryIdMap.containsKey(accIdPatchIdMap.get(acc.Id))){
                        acc.Sales_Territory__c = patchIdSalesTeritoryIdMap.get(accIdPatchIdMap.get(acc.Id));
                    }
                }
            }
            
            set<id> salesTerritoryIdSet = new set<id>();
            for(Account acc : accounts){
                if(acc.Sales_Territory__c != null){
                    salesTerritoryIdSet.add(acc.Sales_Territory__c);
                }
            }
            Map<String, Id> territorySalesUserIdMap = new Map<String, Id>();
            if(!salesTerritoryIdSet.isEmpty()){
                for(PatchTeam__c territory : [Select id,Lead_Development__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: salesTerritoryIdSet]){
                    system.debug('inside for loop  '+territory);
                    for(PatchTeamMember__c salesTeam : territory.PatchTeamMembers__r){
                        if(salesTeam.Role__c == 'Account Manager'){
                            territorySalesUserIdMap.put(''+territory.id+'AccountManager', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'Area Director'){
                            territorySalesUserIdMap.put(''+territory.id+'AreaDirector', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'Channel Manager'){
                            territorySalesUserIdMap.put(''+territory.id+'ChannelManager', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'Customer Advocate'){
                            territorySalesUserIdMap.put(''+territory.id+'CustomerAdvocate', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'Sales Engineer'){
                            territorySalesUserIdMap.put(''+territory.id+'SalesEngineer', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'ZPA Manager'){
                            territorySalesUserIdMap.put(''+territory.id+'ZPAManager', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'ZPA SE'){
                            territorySalesUserIdMap.put(''+territory.id+'ZPASE', salesTeam.User__c);
                        }
                        else if(salesTeam.Role__c == 'Lead Development'){
                            territorySalesUserIdMap.put(''+territory.id+'LeadDevelopment', salesTeam.User__c);
                        }
                    }
                    
                }
                system.debug('territorySalesUserIdMap   '+territorySalesUserIdMap);
                for(Account acc : accounts){
                    if(acc.Sales_Territory__c!= null){                    
                        acc.Area_Director__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'AreaDirector');
                        acc.Account_Manager__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'AccountManager');
                        acc.Channel_Manager__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'ChannelManager');
                        acc.Customer_Advocate__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'CustomerAdvocate');
                        acc.Sales_Engineer__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'SalesEngineer');
                        //acc.ZPA_Manager__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'ZPAManager');
                        //acc.ZPA_SE__c = territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'ZPASE');
                        acc.lead_development2__c=territorySalesUserIdMap.get(''+acc.Sales_Territory__c+'LeadDevelopment');
                        
                    }else{
                        system.debug('in else part');
                        acc.Area_Director__c = null;
                        acc.Account_Manager__c = null;
                        acc.Channel_Manager__c = null;
                        acc.Customer_Advocate__c = null;
                        acc.Sales_Engineer__c = null;
                        //acc.ZPA_Manager__c = null;
                        //acc.ZPA_SE__c = null;
                        acc.lead_development2__c=null;
                    }
                }
            }
            
            if(!accounts.isEmpty()){
                update accounts;
            }
        TriggerUtility.realignPatchReset();   
        }
        catch(exception e){
            
        }
    }
    
    public void finish(Database.BatchableContext context) {
        if(!Test.isRunningTest()){
            Database.executeBatch(new contactsPostPatchBatch(recordIds), 200);
        }
    }
}