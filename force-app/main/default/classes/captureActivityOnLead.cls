/*****************************************************************************************
Name: captureActivityOnLead
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Class to capture activity detail on Campign Member.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Sep-2015    Initial Development
******************************************************************************************/ 


public class captureActivityOnLead{
    /**
    *@purpose : Method to update campaign member with activity detail.
    *@param : Modified(Trigger.oldMap) Map of Tasks.
    *@return : void
    **/
    public static void getActivityDetail(map<id, Task> newActivityMap){
        try{
            set<id> leadIdSet = new set<id>();
            set<id> ConIdSet = new set<id>();
            map<id, Task> leadIdTaskMap = new map<id, Task>();
            map<id, Task> contactIdTaskMap = new map<id, Task>();
            for(task t : newActivityMap.values()){
                if(t.WhoId != null){
                    Schema.SObjectType token = t.WhoId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Lead'){
                        leadIdSet.add(t.WhoId);
                        leadIdTaskMap.Put(t.WhoId, t);
                    }   
                    if(objName == 'Contact'){   
                        conIdSet.add(t.WhoId);
                        contactIdTaskMap.Put(t.WhoId, t);
                    }
                }
            }
            list<CampaignMember> campMemUpdateList = new list<CampaignMember>();
            if(!leadIdSet.isEmpty() || !conIdSet.isEmpty()){
                for(CampaignMember campMem : [Select id, CreatedDate, LeadId, Contactid, Activity_Subject__c, Activity_Id__c from CampaignMember where (LeadId IN: leadidSet OR ContactId IN: conIdSet) AND Contacted_On__c =: NULL AND CreatedDate = LAST_N_DAYS:30 ORDER BY CreatedDate DESC]){
                    campMem.Contacted_On__c= system.now();
                    if(campMem.LeadId != null && leadIdTaskMap.keyset().contains(campMem.LeadId)){
                        campMem.Activity_Subject__c = leadIdTaskMap.get(campMem.LeadId).subject; 
                        campMem.Activity_Id__c = leadIdTaskMap.get(campMem.LeadId).Id;
                    }
                        
                    if(campMem.contactid != null && contactIdTaskMap.keyset().contains(campMem.contactid)){
                        campMem.Activity_Subject__c = contactIdTaskMap.get(campMem.contactid).subject;
                        campMem.Activity_Id__c = contactIdTaskMap.get(campMem.contactid).Id;
                    }
                    campMemUpdateList.add(campMem);
                }
            }
            if(!campMemUpdateList.isempty())
                database.update(campMemUpdateList,false);
            TriggerUtility.campMemActivityExecuted();
        }catch(exception e){}
    }
    /*public static void assignleadterritory(List<Task> newTasklst, Map<Id, Task> oldtaskmap, Boolean isInsert, Boolean isUpdate){
        try{
            set<id> leadIdSet = new set<id>();
            set<id> accountIdSet = new set<id>();
            Map<Id, Lead> ldmap = new Map<Id, Lead>();
            Map<Id, Account> accmap = new Map<Id, Account>();
            List<Task> tasklst = [Select Id, WhoId, WhatId, AccountId, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Task where Id in :newTasklst];
            for(task t : tasklst){
                if(t.WhoId != null && (isInsert || (isUpdate && t.WhoId != oldtaskmap.get(t.Id).WhoId))){
                    Schema.SObjectType token = t.WhoId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Lead'){
                        leadIdSet.add(t.WhoId);
                    } 
                }     
                if(t.WhatId != null && (isInsert || (isUpdate && t.WhatId != oldtaskmap.get(t.Id).WhatId))){
                    Schema.SObjectType token = t.WhatId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Account'){
                        accountIdSet.add(t.WhatId);
                    }
                }        
                if(t.AccountId != null && (isInsert || (isUpdate && t.AccountId != oldtaskmap.get(t.Id).AccountId))){
                    accountIdSet.add(t.AccountId);
                }
            }
            
            if(!leadIdSet.isEmpty()){
                ldmap = new Map<Id, Lead>([Select Id, Territory_Type__c, Territory_Name__c, Territory__r.Area__c, Territory__r.Theater__c from Lead where Id in :leadIdSet]);
            }
            if(!accountIdSet.isEmpty()){
                accmap = new Map<Id, Account>([Select Id, Territory_Type__c, Sales_Territory__r.Name, Sales_Territory__r.Area__c,  Sales_Territory__r.Theater__c from Account where Id in :accountIdSet]);
            }
            for(task t : tasklst){
                if(t.WhatId != null && accmap.containsKey(t.WhatId) && accmap.get(t.WhatId) != null){
                    t.Sales_Territory__c =  accmap.get(t.WhatId).Sales_Territory__r.Name;
                    t.Territory_Area__c =  accmap.get(t.WhatId).Sales_Territory__r.Area__c;
                    t.Territory_Geo__c =  accmap.get(t.WhatId).Sales_Territory__r.Theater__c;
                    t.Territory_Type__c =  accmap.get(t.WhatId).Territory_Type__c;
                }else if(t.AccountId != null && accmap.containsKey(t.AccountId) && accmap.get(t.AccountId) != null){
                    t.Sales_Territory__c =  accmap.get(t.AccountId).Sales_Territory__r.Name;
                    t.Territory_Area__c =  accmap.get(t.AccountId).Sales_Territory__r.Area__c;
                    t.Territory_Geo__c =  accmap.get(t.AccountId).Sales_Territory__r.Theater__c;
                    t.Territory_Type__c =  accmap.get(t.AccountId).Territory_Type__c;
                }else if(t.WhoId != null && ldmap.containsKey(t.WhoId) && ldmap.get(t.WhoId) != null){
                    t.Sales_Territory__c =  ldmap.get(t.WhoId).Territory_Name__c;
                    t.Territory_Area__c =  ldmap.get(t.WhoId).Territory__r.Area__c;
                    t.Territory_Geo__c =  ldmap.get(t.WhoId).Territory__r.Theater__c;
                    t.Territory_Type__c =  ldmap.get(t.WhoId).Territory_Type__c;
                }/*else{
                    t.Sales_Territory__c = '';
                    t.Territory_Area__c = '';
                    t.Territory_Geo__c = '';
                    t.Territory_Type__c = '';
                }--commented
                
            }
            if(isinsert){
                TriggerUtility.ActivityleadterritoryinsertExecuted();
            }
            
            if(isupdate){
                TriggerUtility.ActivityleadterritoryupdateExecuted();
            }
            update tasklst;
        }catch(exception e){}
    }
    
    public static void assignleadterritoryEvent(List<Event> newEventlst, Map<Id, Event> oldEventmap, Boolean isInsert, Boolean isUpdate){
        try{
            set<id> leadIdSet = new set<id>();
            set<id> accountIdSet = new set<id>();
            Map<Id, Lead> ldmap = new Map<Id, Lead>();
            Map<Id, Account> accmap = new Map<Id, Account>();
            List<Event> Eventlst = [Select Id, WhoId, WhatId, AccountId, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Event where Id in :newEventlst];
            for(Event t : Eventlst){
                if(t.WhoId != null && (isInsert || (isUpdate && t.WhoId != oldEventmap.get(t.Id).WhoId))){
                    Schema.SObjectType token = t.WhoId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Lead'){
                        leadIdSet.add(t.WhoId);
                    } 
                }     
                if(t.WhatId != null && (isInsert || (isUpdate && t.WhatId != oldEventmap.get(t.Id).WhatId))){
                    Schema.SObjectType token = t.WhatId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Account'){
                        accountIdSet.add(t.WhatId);
                    }
                }        
                if(t.AccountId != null && (isInsert || (isUpdate && t.AccountId != oldEventmap.get(t.Id).AccountId))){
                    accountIdSet.add(t.AccountId);
                }
            }
            
            if(!leadIdSet.isEmpty()){
                ldmap = new Map<Id, Lead>([Select Id, Territory_Type__c, Territory_Name__c, Territory__r.Area__c, Territory__r.Theater__c from Lead where Id in :leadIdSet]);
            }
            if(!accountIdSet.isEmpty()){
                accmap = new Map<Id, Account>([Select Id, Territory_Type__c, Sales_Territory__r.Name, Sales_Territory__r.Area__c,  Sales_Territory__r.Theater__c from Account where Id in :accountIdSet]);
            }
            for(Event t : Eventlst){
                if(t.WhatId != null && accmap.containsKey(t.WhatId) && accmap.get(t.WhatId) != null){
                    t.Sales_Territory__c =  accmap.get(t.WhatId).Sales_Territory__r.Name;
                    t.Territory_Area__c =  accmap.get(t.WhatId).Sales_Territory__r.Area__c;
                    t.Territory_Geo__c =  accmap.get(t.WhatId).Sales_Territory__r.Theater__c;
                    t.Territory_Type__c =  accmap.get(t.WhatId).Territory_Type__c;
                }else if(t.AccountId != null && accmap.containsKey(t.AccountId) && accmap.get(t.AccountId) != null){
                    t.Sales_Territory__c =  accmap.get(t.AccountId).Sales_Territory__r.Name;
                    t.Territory_Area__c =  accmap.get(t.AccountId).Sales_Territory__r.Area__c;
                    t.Territory_Geo__c =  accmap.get(t.AccountId).Sales_Territory__r.Theater__c;
                    t.Territory_Type__c =  accmap.get(t.AccountId).Territory_Type__c;
                }else if(t.WhoId != null && ldmap.containsKey(t.WhoId) && ldmap.get(t.WhoId) != null){
                    t.Sales_Territory__c =  ldmap.get(t.WhoId).Territory_Name__c;
                    t.Territory_Area__c =  ldmap.get(t.WhoId).Territory__r.Area__c;
                    t.Territory_Geo__c =  ldmap.get(t.WhoId).Territory__r.Theater__c;
                    t.Territory_Type__c =  ldmap.get(t.WhoId).Territory_Type__c;
                }/*else{
                    t.Sales_Territory__c = '';
                    t.Territory_Area__c = '';
                    t.Territory_Geo__c = '';
                    t.Territory_Type__c = '';
                }--commented
                
            }
            if(isinsert){
                TriggerUtility.ActivityleadterritoryEventinsertExecuted();
            }
            
            if(isupdate){
                TriggerUtility.ActivityleadterritoryEventupdateExecuted();
            }
            update Eventlst;
        }catch(exception e){}
    }*/
    
}