/*****************************************************************************************
Name: AccountSalesTerritoryAndContactPatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Class to Populate Account Sales territory and Update Patch on Related Contacts.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            17-Nov-2015    Initial Development
******************************************************************************************/ 


Public class AccountSalesTerritoryAndContactPatch{

    Public static void setAccountSalesTerritory(list<Account> newAccList){
        
        Map<Id, Id> accIdPatchIdMap = new Map<Id, Id>();
        Map<Id, Id> patchIdSalesTeritoryIdMap = new Map<Id, Id>();
        try{
            for(Account acc : newAccList){
                if(acc.Patch__c != null)
                    accIdPatchIdMap.put(acc.Id, acc.Patch__c);
                else
                    acc.Sales_Territory__c = null;
            }
            
            for(Patch__c patch : [ select id,PatchTeam__c from Patch__c where Id IN: accIdPatchIdMap.values() AND PatchTeam__c != null]){
                patchIdSalesTeritoryIdMap.put(patch.Id, patch.PatchTeam__c);
            }
            
            for(Account acc : newAccList){
                if(accIdPatchIdMap.containsKey(acc.Id))
                    if(patchIdSalesTeritoryIdMap.containsKey(accIdPatchIdMap.get(acc.Id)))
                        acc.Sales_Territory__c = patchIdSalesTeritoryIdMap.get(accIdPatchIdMap.get(acc.Id));
            }
        }catch(exception e){}
    
    }
    
    Public static void updateContactsPatch(list<Account> newAccList, map<Id, Account> oldAccMap){
        list<Contact> contactUpdateList = new list<Contact>();
        Map<Id, Id> accIdPatchIdMap = new Map<Id, Id>();
        set<id> accIdSet = new set<id>();
        
        try{
            for(Account acc : newAccList){
                if(acc.Patch__c != oldAccMap.get(acc.id).Patch__c){
                    accIdSet.add(acc.Id);
                    if(acc.Patch__c != null)
                        accIdPatchIdMap.put(acc.Id, acc.Patch__c);
                }
            }
            
            if(!accIdSet.isEmpty()){
                for(Contact con : [select Id, AccountId, Patch__c from Contact where AccountId IN: accIdSet]){
                    if(accIdPatchIdMap.containsKey(con.AccountId)){
                        con.Patch__c = accIdPatchIdMap.get(con.AccountId);
                    }else{
                        con.Patch__c = null;
                        con.Account_Manager__c = null;
                        con.Channel_Manager__c = null;
                        con.Customer_Advocate__c = null;
                        con.Sales_Engineer__c = null;
                        con.Lead_Development__c = null;
                        con.ZPA_Manager__c = null;
                        con.ZPA_SE__c = null;
                        con.ZPA_Manager_Email__c = null;
                        con.ZPA_SE_Email__c = null;
                    }
                    contactUpdateList.add(con);
                }
            }
            if(!contactUpdateList.isEmpty())
                database.update(contactUpdateList, false);
            
        }catch (exception e){}
        
    }   
    
 }