/*****************************************************************************************
Name: IBCTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Trigger Helper class for SCI.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            10-Jan-2016    Initial Development
******************************************************************************************/

public class IBCTriggerHelper{
	
    public static void updateLatestIBConOpp(list<ecosystems_svcs__IBC__c  > IBCNewList, map<id,ecosystems_svcs__IBC__c  > IBCOldMap){
       /* set<Id> oppIdSet = new set<Id>();
        if(IBCNewList != null){
            for(ecosystems_svcs__IBC__c ibc : IBCNewList){
                if(IBCOldMap != null){
                    if(ibc.ecosystems_svcs__Opportunity__c != null && ((ibc.ecosystems_svcs__salesPlay__c != null && ibc.ecosystems_svcs__salesPlay__c != '') || (ibc.VMO_URL__c != null && ibc.VMO_URL__c != '')) && (ibc.VMO_URL__c != IBCOldMap.get(ibc.id).VMO_URL__c || ibc.ecosystems_svcs__salesPlay__c != IBCOldMap.get(ibc.Id).ecosystems_svcs__salesPlay__c))
                        oppIdSet.add(ibc.ecosystems_svcs__Opportunity__c);
                }else{
                    if(ibc.ecosystems_svcs__Opportunity__c != null && ((ibc.ecosystems_svcs__salesPlay__c != null && ibc.ecosystems_svcs__salesPlay__c != '') || (ibc.VMO_URL__c != null && ibc.VMO_URL__c != ''))){
                        oppIdSet.add(ibc.ecosystems_svcs__Opportunity__c);
                     }   
                }
            }
        }else{
            for(ecosystems_svcs__IBC__c ibc : IBCOldMap.Values()){
                if(ibc.ecosystems_svcs__Opportunity__c != null)
                    oppIdSet.add(ibc.ecosystems_svcs__Opportunity__c);
            }
        }

        Map<id,string> oppIdSalesPlayMap = new map<Id, string>();
        Map<id,string> oppIdActionMap = new map<Id, string>();
        list<Opportunity> oppUpdateList = new list<Opportunity>();
        Map<Id, Opportunity> oppUpdateMap = new Map<Id, Opportunity>();

        System.debug('>>>> oppIdSet: ' + oppIdSet);
        for(ecosystems_svcs__IBC__c ibc : [Select Id, ecosystems_svcs__Opportunity__c, ecosystems_svcs__salesPlay__c, VMO_URL__c from ecosystems_svcs__IBC__c WHERE ecosystems_svcs__Opportunity__c IN: oppIdSet ORDER BY CreatedDate DESC]){
            if((ibc.ecosystems_svcs__salesPlay__c != null && ibc.ecosystems_svcs__salesPlay__c != '') || (ibc.VMO_URL__c != null && ibc.VMO_URL__c != '')){
                if(!oppIdSalesPlayMap.keySet().Contains(ibc.ecosystems_svcs__Opportunity__c))
                    oppIdSalesPlayMap.put(ibc.ecosystems_svcs__Opportunity__c, String.isBlank(ibc.ecosystems_svcs__salesPlay__c) ? '' : ibc.ecosystems_svcs__salesPlay__c);
                if(!oppIdActionMap.keySet().Contains(ibc.ecosystems_svcs__Opportunity__c))  
                    oppIdActionMap.put(ibc.ecosystems_svcs__Opportunity__c, String.isBlank(ibc.VMO_URL__c) ? '' : ibc.VMO_URL__c);
            }
        }
        if(IBCNewList != null){
            for(ecosystems_svcs__IBC__c ibc : IBCNewList){
                if(oppIdActionMap.keySet().Contains(ibc.ecosystems_svcs__Opportunity__c)
                    && !oppUpdateMap.containsKey(ibc.ecosystems_svcs__Opportunity__c)){
                    //oppUpdateList.add(new Opportunity(id = ibc.ecosystems_svcs__Opportunity__c, VMO_Play__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c),VMO_Play_New__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), Value_Management_Business_Case__c = oppIdActionMap.get(ibc.ecosystems_svcs__Opportunity__c)));    
                    oppUpdateMap.put(ibc.ecosystems_svcs__Opportunity__c, new Opportunity(id = ibc.ecosystems_svcs__Opportunity__c, VMO_Play__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), VMO_Play_New__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), Value_Management_Business_Case__c = oppIdActionMap.get(ibc.ecosystems_svcs__Opportunity__c)));
                }
            }
            
        }else{
            for(ecosystems_svcs__IBC__c ibc : IBCOldMap.Values()){
                if(oppIdActionMap.keySet().Contains(ibc.ecosystems_svcs__Opportunity__c)
                    && !oppUpdateMap.containsKey(ibc.ecosystems_svcs__Opportunity__c)){
                    //oppUpdateList.add(new Opportunity(id = ibc.ecosystems_svcs__Opportunity__c, VMO_Play__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), VMO_Play_New__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), Value_Management_Business_Case__c = oppIdActionMap.get(ibc.ecosystems_svcs__Opportunity__c)));    
                    oppUpdateMap.put(ibc.ecosystems_svcs__Opportunity__c, new Opportunity(id = ibc.ecosystems_svcs__Opportunity__c, VMO_Play__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), VMO_Play_New__c = oppIdSalesPlayMap.get(ibc.ecosystems_svcs__Opportunity__c), Value_Management_Business_Case__c = oppIdActionMap.get(ibc.ecosystems_svcs__Opportunity__c)));
                } else {
                    oppUpdateMap.put(ibc.ecosystems_svcs__Opportunity__c, new Opportunity(id = ibc.ecosystems_svcs__Opportunity__c, VMO_Play__c = '', VMO_Play_New__c = '', Value_Management_Business_Case__c = oppIdActionMap.get(ibc.ecosystems_svcs__Opportunity__c)));
                }
            }
        }

        if(!oppUpdateMap.isEmpty())
            //database.update(oppUpdateList, false);
            database.update(oppUpdateMap.values(), false);
            */
       // TriggerUtility.updateLatestIBConOppExecuted();  
    }
    
}