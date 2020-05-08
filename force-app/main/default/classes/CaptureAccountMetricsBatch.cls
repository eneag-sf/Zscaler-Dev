/*****************************************************************************************
Name: CaptureAccountMetricsBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to compute below metrics on account.
    #F2F Meetings
    Last F2F Meeting
    Last QBR Date
    Active POC
    Other Touches
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            21-Oct-2015    Initial Development
******************************************************************************************/



global class CaptureAccountMetricsBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator([select Id from Account]);
    }

    global void execute (Database.BatchableContext context, List<sObject> accountList){
        Set<Id> accIdSet = new set<Id>();
        map<Id, set<id>> accIdSCIIdSetMap = new map<id, Set<Id>>();
        map<Id, set<id>> accIdDemoSCIIdSetMap = new map<id, Set<Id>>();
        map<Id, set<id>> accIdTaskIdSetMap = new map<id, Set<Id>>();
        map<id, date> accLastF2FSCIDateMap = new map<id, date>();
        map<id, date> accLastSCIDateMap = new map<id, date>();
        map<id, date> accLastQBRDateMap = new map<id, date>();
        map<id, Significant_Customer_Interaction__c> acclatestzsrmap = new map<id, Significant_Customer_Interaction__c>();
        map<id, Significant_Customer_Interaction__c> acclatestarchsessionmap = new map<id, Significant_Customer_Interaction__c>();
        map<id, date> accLastDemoDateMap = new map<id, date>();
        //map<id, date> accLastArchDateMap = new map<id,date>();
        map<id, id> accIdActiveSCIIdMap = new map<id, id>();
//        map<Id, integer> accActHistoryCountMap = new map<Id, integer>();
        map<id, set<id>> accIdImpConfSCIIdMap = new map<id, set<id>>();
        map<Id, decimal> accIdOpenPipelineMap = new map<Id, Decimal>();
        map<Id, decimal> scislast6months = new map<Id, Decimal>();
        map<Id, decimal> scislast12months = new map<Id, Decimal>();
        map<Id, decimal> allscis = new map<Id, Decimal>();
        map<Id, decimal> f2flast6months = new map<Id, Decimal>();
        map<Id, decimal> f2flast12months = new map<Id, Decimal>();
        map<Id, decimal> allf2fs = new map<Id, Decimal>();
        map<Id, decimal> MCICountmap = new map<Id, Decimal>(); //Added by Gurjinder to count Active MCI
        map<Id, decimal> MCIlast6monthsCount = new map<Id, Decimal>(); //Added by Gurjinder to count last 6 months MCI
        list<Account> accUpdateList = new list<Account>();
        for(sObject acc : accountList ){
            accIdSet.add((Id)acc.get('Id'));
        }
        /*
        for(Account acc : [select Id, (SELECT ActivityDate, Description FROM ActivityHistories where CreatedDate = LAST_N_DAYS:90) from Account where ID IN: accIdSet]){
            integer i = 0;
            for(ActivityHistory acctHist : acc.ActivityHistories){
                i = i+1;
            }
            accActHistoryCountMap.put(acc.id, i);
        }
        */
        try{

        for(Opportunity opp : [Select Id, AccountId, Amount, CloseDate from Opportunity Where CloseDate != null AND CloseDate > Today AND AccountId IN: accIdSet AND IsClosed =: false AND StageName != '0 - Initial Prospecting']){
            decimal tempAmnt = 0;
            if(opp.Amount != null)
                tempAmnt += opp.Amount;
            if(accIdOpenPipelineMap.containsKey(Opp.AccountId)){
                tempAmnt += accIdOpenPipelineMap.get(Opp.AccountId);
            }
            accIdOpenPipelineMap.put(Opp.AccountId, tempAmnt);
        }
        
        for(Significant_Customer_Interaction__c sci: [Select Id,CreatedDate, Method_of_Interaction__c, Account_Name__c, Account_Name__r.Id, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name, RecordType.DeveloperName from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet or Opportunity_Name__r.AccountId in :accIdSet) and Recordtype.name not in ('CAB')]){
            if(sci.Account_Name__c != null && allscis.containsKey(sci.Account_Name__c)){
                allscis.put(sci.Account_Name__c, allscis.get(sci.Account_Name__c) + 1);
            }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && allscis.containsKey(sci.Opportunity_Name__r.AccountId)){
                allscis.put(sci.Opportunity_Name__r.AccountId, allscis.get(sci.Opportunity_Name__r.AccountId) + 1);
            }else if(sci.Account_Name__c != null){
                allscis.put(sci.Account_Name__c, 1);
            }else if(sci.Opportunity_Name__r.AccountId != null){
                allscis.put(sci.Opportunity_Name__r.AccountId, 1);
            }
            if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-6)){
                if(sci.Account_Name__c != null && scislast6months.containsKey(sci.Account_Name__c)){
                    scislast6months.put(sci.Account_Name__c, scislast6months.get(sci.Account_Name__c) + 1);
                }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && scislast6months.containsKey(sci.Opportunity_Name__r.AccountId)){
                    scislast6months.put(sci.Opportunity_Name__r.AccountId, scislast6months.get(sci.Opportunity_Name__r.AccountId) + 1);
                }else if(sci.Account_Name__c != null){
                    scislast6months.put(sci.Account_Name__c, 1);
                }else if(sci.Opportunity_Name__r.AccountId != null){
                    scislast6months.put(sci.Opportunity_Name__r.AccountId, 1);
                }
            }
            if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-12)){
                if(sci.Account_Name__c != null && scislast12months.containsKey(sci.Account_Name__c)){
                    scislast12months.put(sci.Account_Name__c, scislast12months.get(sci.Account_Name__c) + 1);
                }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && scislast12months.containsKey(sci.Opportunity_Name__r.AccountId)){
                    scislast12months.put(sci.Opportunity_Name__r.AccountId, scislast12months.get(sci.Opportunity_Name__r.AccountId) + 1);
                }else if(sci.Account_Name__c != null){
                    scislast12months.put(sci.Account_Name__c, 1);
                }else if(sci.Opportunity_Name__r.AccountId != null){
                    scislast12months.put(sci.Opportunity_Name__r.AccountId, 1);
                }
            }
            
            if(sci.Method_of_Interaction__c == 'F2F' && sci.Recordtype.name != 'Marketing/CXO Event'){
                if(sci.Account_Name__c != null && allf2fs.containsKey(sci.Account_Name__c)){
                    allf2fs.put(sci.Account_Name__c, allf2fs.get(sci.Account_Name__c) + 1);
                }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && allf2fs.containsKey(sci.Opportunity_Name__r.AccountId)){
                    allf2fs.put(sci.Opportunity_Name__r.AccountId, allf2fs.get(sci.Opportunity_Name__r.AccountId) + 1);
                }else if(sci.Account_Name__c != null){
                    allf2fs.put(sci.Account_Name__c, 1);
                }else if(sci.Opportunity_Name__r.AccountId != null){
                    allf2fs.put(sci.Opportunity_Name__r.AccountId, 1);
                }
                if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-6)){
                    if(sci.Account_Name__c != null && f2flast6months.containsKey(sci.Account_Name__c)){
                        f2flast6months.put(sci.Account_Name__c, f2flast6months.get(sci.Account_Name__c) + 1);
                    }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && f2flast6months.containsKey(sci.Opportunity_Name__r.AccountId)){
                        f2flast6months.put(sci.Opportunity_Name__r.AccountId, f2flast6months.get(sci.Opportunity_Name__r.AccountId) + 1);
                    }else if(sci.Account_Name__c != null){
                        f2flast6months.put(sci.Account_Name__c, 1);
                    }else if(sci.Opportunity_Name__r.AccountId != null){
                        f2flast6months.put(sci.Opportunity_Name__r.AccountId, 1);
                    }
                }
                if(sci.Date__c != null && sci.Date__c >= date.today().addmonths(-12)){
                    if(sci.Account_Name__c != null && f2flast12months.containsKey(sci.Account_Name__c)){
                        f2flast12months.put(sci.Account_Name__c, f2flast12months.get(sci.Account_Name__c) + 1);
                    }else if(sci.Account_Name__c == null && sci.Opportunity_Name__r.AccountId != null && f2flast12months.containsKey(sci.Opportunity_Name__r.AccountId)){
                        f2flast12months.put(sci.Opportunity_Name__r.AccountId, f2flast12months.get(sci.Opportunity_Name__r.AccountId) + 1);
                    }else if(sci.Account_Name__c != null){
                        f2flast12months.put(sci.Account_Name__c, 1);
                    }else if(sci.Opportunity_Name__r.AccountId != null){
                        f2flast12months.put(sci.Opportunity_Name__r.AccountId, 1);
                    }
                }
            }
            
        }

        set<Id> tempIdSet = new set<Id>();
        for(Significant_Customer_Interaction__c sci : [Select Id,CreatedDate, Method_of_Interaction__c, Account_Name__c, Account_Name__r.Id, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name, RecordType.DeveloperName from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet OR  Opportunity_Name__r.AccountId IN: accIdSet ) AND CreatedDate = LAST_N_DAYS:90 order by Date__c DESC]){
            if(sci.RecordType.DeveloperName ==  'Regular_Meeting' && sci.Method_of_Interaction__c == 'F2F'){
                tempIdSet = new set<Id>();
                if(accIdSCIIdSetMap.containsKey(sci.Account_Name__c)){
                    tempIdSet = accIdSCIIdSetMap.get(sci.Account_Name__c);
                    tempIdSet.add(sci.Id);
                    accIdSCIIdSetMap.put(sci.Account_Name__c,tempIdSet);
                }else{
                    tempIdSet.add(sci.Id);
                    accIdSCIIdSetMap.put(sci.Account_Name__c,tempIdSet);
                }

                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null){
                    tempIdSet = new set<Id>();
                    if(accIdSCIIdSetMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                        tempIdSet = accIdSCIIdSetMap.get(sci.Opportunity_Name__r.AccountId);
                        tempIdSet.add(sci.Id);
                        accIdSCIIdSetMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }else{
                        tempIdSet.add(sci.Id);
                        accIdSCIIdSetMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }
                }


            }else if(sci.RecordType.DeveloperName == 'Regular_Meeting' && sci.Method_of_Interaction__c == 'Webex/Call'){
                tempIdSet = new set<Id>();
                if(accIdDemoSCIIdSetMap.containsKey(sci.Account_Name__c)){
                    tempIdSet = accIdDemoSCIIdSetMap.get(sci.Account_Name__c);
                    tempIdSet.add(sci.Id);
                    accIdDemoSCIIdSetMap.put(sci.Account_Name__c,tempIdSet);
                }else{
                    tempIdSet.add(sci.Id);
                    accIdDemoSCIIdSetMap.put(sci.Account_Name__c,tempIdSet);
                }

                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null){
                    tempIdSet = new set<Id>();
                    if(accIdDemoSCIIdSetMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                        tempIdSet = accIdDemoSCIIdSetMap.get(sci.Opportunity_Name__r.AccountId);
                        tempIdSet.add(sci.Id);
                        accIdDemoSCIIdSetMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }else{
                        tempIdSet.add(sci.Id);
                        accIdDemoSCIIdSetMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }
                }
            }
            /*else if(sci.RecordType.Name == 'POC Inline' ){
                if(sci.Current_POC_Phase__c  != '' && sci.Current_POC_Phase__c  != null && sci.Current_POC_Phase__c  != '0-POC Not Required' && sci.Current_POC_Phase__c  != '9-Technical Win' && sci.Current_POC_Phase__c  != '10-Technical Loss' && sci.POC_End_Date__c == null){
                    if( !accIdActiveSCIIdMap.containsKey(sci.Account_Name__c)){
                         accIdActiveSCIIdMap.put(sci.Account_Name__c, sci.Id);
                    }
                    if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !accIdActiveSCIIdMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                        accIdActiveSCIIdMap.put(sci.Opportunity_Name__r.AccountId, sci.Id);
                    }
                }

            }else if(sci.RecordType.Name == 'Very Important Conf Call' ){
                tempIdSet = new set<Id>();
                if(accIdImpConfSCIIdMap.containsKey(sci.Account_Name__c)){
                    tempIdSet = accIdImpConfSCIIdMap.get(sci.Account_Name__c);
                    tempIdSet.add(sci.Id);
                    accIdImpConfSCIIdMap.put(sci.Account_Name__c,tempIdSet);
                }else{
                    tempIdSet.add(sci.Id);
                    accIdImpConfSCIIdMap.put(sci.Account_Name__c,tempIdSet);
                }

                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null){
                    tempIdSet = new set<Id>();
                    if(accIdImpConfSCIIdMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                        tempIdSet = accIdImpConfSCIIdMap.get(sci.Opportunity_Name__r.AccountId);
                        tempIdSet.add(sci.Id);
                        accIdImpConfSCIIdMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }else{
                        tempIdSet.add(sci.Id);
                        accIdImpConfSCIIdMap.put(sci.Opportunity_Name__r.AccountId,tempIdSet);
                    }
                }
            }
            else if(sci.RecordType.Name == 'Architecture Session' && sci.Date__c != null){
                accLastArchDateMap.put(sci.Account_Name__r.Id,sci.Date__c);
            }*/

        }

 for(Significant_Customer_Interaction__c sci : [Select Id,CreatedDate, Account_Name__c, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet OR  Opportunity_Name__r.AccountId IN: accIdSet ) AND (RecordType.DeveloperName =: 'Regular_Meeting' or RecordType.DeveloperName = 'QBR' or RecordType.DeveloperName = 'Architecture_Session') AND Method_of_Interaction__c =: 'F2F' order by Date__c DESC NULLS LAST]){
            if(sci.Date__c != null){
                if(!accLastF2FSCIDateMap.containsKey(sci.Account_Name__c)){
                    accLastF2FSCIDateMap.put(sci.Account_Name__c, sci.Date__c);
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !accLastF2FSCIDateMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                    accLastF2FSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.Date__c);
                }
            }else{
                if(accLastF2FSCIDateMap.containsKey(sci.Account_Name__c)  ){
                    if(sci.CreatedDate.Date() > accLastF2FSCIDateMap.get(sci.Account_Name__c))
                        accLastF2FSCIDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }else{
                    accLastF2FSCIDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && accLastF2FSCIDateMap.containsKey(sci.Opportunity_Name__r.AccountId) ){
                    if(sci.CreatedDate.Date() > accLastF2FSCIDateMap.get(sci.Opportunity_Name__r.AccountId))
                        accLastF2FSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }else{
                    accLastF2FSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }
            }
        }
       
        for(Significant_Customer_Interaction__c sci : [Select Id,CreatedDate, Account_Name__c, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet OR  Opportunity_Name__r.AccountId IN: accIdSet ) AND (RecordType.DeveloperName =: 'Regular_Meeting') order by Date__c DESC NULLS LAST]){
            if(sci.Date__c != null){
                if(!accLastSCIDateMap.containsKey(sci.Account_Name__c)){
                    accLastSCIDateMap.put(sci.Account_Name__c, sci.Date__c);
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !accLastSCIDateMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                    accLastSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.Date__c);
                }
            }else{
                if(accLastSCIDateMap.containsKey(sci.Account_Name__c)  ){
                    if(sci.CreatedDate.Date() > accLastSCIDateMap.get(sci.Account_Name__c))
                        accLastSCIDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }else{
                    accLastSCIDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && accLastSCIDateMap.containsKey(sci.Opportunity_Name__r.AccountId) ){
                    if(sci.CreatedDate.Date() > accLastSCIDateMap.get(sci.Opportunity_Name__r.AccountId))
                        accLastSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }else{
                    accLastSCIDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }
            }
        }


        for(Significant_Customer_Interaction__c sci : [Select Id,CreatedDate, Account_Name__c, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name, Next_ZSR_Date__c, ZSR_link__c, Architecture_Workshop_Link__c, Next_Architecture_Workshop_Date__c, RecordType.DeveloperName from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet OR  Opportunity_Name__r.AccountId IN: accIdSet ) AND (RecordType.DeveloperName = 'QBR' or RecordType.DeveloperName = 'Architecture_Session') order by Date__c DESC NULLS LAST]){
            if(sci.RecordType.DeveloperName == 'QBR'){
                if(sci.Date__c != null){
                    if(!accLastQBRDateMap.containsKey(sci.Account_Name__c)){
                        accLastQBRDateMap.put(sci.Account_Name__c, sci.Date__c);
                    }
                    if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !accLastQBRDateMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                        accLastQBRDateMap.put(sci.Opportunity_Name__r.AccountId, sci.Date__c);
                    }
                }else{
                    if(accLastQBRDateMap.containsKey(sci.Account_Name__c)  ){
                        if(sci.CreatedDate.Date() > accLastQBRDateMap.get(sci.Account_Name__c))
                            accLastQBRDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                    }else{
                        accLastQBRDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                    }
                    if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && accLastQBRDateMap.containsKey(sci.Opportunity_Name__r.AccountId) ){
                        if(sci.CreatedDate.Date() > accLastQBRDateMap.get(sci.Opportunity_Name__r.AccountId))
                            accLastQBRDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                    }else{
                        accLastQBRDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                    }
                }

                if(!acclatestzsrmap.containsKey(sci.Account_Name__c)){
                    acclatestzsrmap.put(sci.Account_Name__c, sci);
                }else{
                    if(sci.CreatedDate > acclatestzsrmap.get(sci.Account_Name__c).CreatedDate)
                    acclatestzsrmap.put(sci.Account_Name__c, sci);
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !acclatestzsrmap.containsKey(sci.Opportunity_Name__r.AccountId)){
                    acclatestzsrmap.put(sci.Opportunity_Name__r.AccountId, sci);
                }else{
                    if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && sci.CreatedDate > acclatestzsrmap.get(sci.Opportunity_Name__r.AccountId).CreatedDate)
                    acclatestzsrmap.put(sci.Opportunity_Name__r.AccountId, sci);
                }
            }else{
                if(!acclatestarchsessionmap.containsKey(sci.Account_Name__c)){
                    acclatestarchsessionmap.put(sci.Account_Name__c, sci);
                }else{
                    if(sci.CreatedDate > acclatestarchsessionmap.get(sci.Account_Name__c).CreatedDate)
                    acclatestarchsessionmap.put(sci.Account_Name__c, sci);
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !acclatestarchsessionmap.containsKey(sci.Opportunity_Name__r.AccountId)){
                    acclatestarchsessionmap.put(sci.Opportunity_Name__r.AccountId, sci);
                }else{
                    if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && sci.CreatedDate > acclatestarchsessionmap.get(sci.Opportunity_Name__r.AccountId).CreatedDate)
                    acclatestarchsessionmap.put(sci.Opportunity_Name__r.AccountId, sci);
                }
            }
        }

        for(Significant_Customer_Interaction__c sci : [Select Id,CreatedDate, Account_Name__c, Date__c, POC_End_Date__c, Current_POC_Phase__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, RecordTypeId, RecordType.Name from Significant_Customer_Interaction__c where (Account_Name__c IN: accIdSet OR  Opportunity_Name__r.AccountId IN: accIdSet ) AND RecordType.DeveloperName =: 'Regular_Meeting' And Method_of_Interaction__c =: 'Webex/Call' order by Date__c DESC NULLS LAST]){
            if(sci.Date__c != null){
                if(!accLastDemoDateMap.containsKey(sci.Account_Name__c)){
                    accLastDemoDateMap.put(sci.Account_Name__c, sci.Date__c);
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && !accLastDemoDateMap.containsKey(sci.Opportunity_Name__r.AccountId)){
                    accLastDemoDateMap.put(sci.Opportunity_Name__r.AccountId, sci.Date__c);
                }
            }else{
                if(accLastDemoDateMap.containsKey(sci.Account_Name__c)  ){
                    if(sci.CreatedDate.Date() > accLastDemoDateMap.get(sci.Account_Name__c))
                        accLastDemoDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }else{
                    accLastDemoDateMap.put(sci.Account_Name__c, sci.CreatedDate.Date());
                }
                if(sci.Opportunity_Name__c != null && sci.Opportunity_Name__r.AccountId != null && accLastDemoDateMap.containsKey(sci.Opportunity_Name__r.AccountId) ){
                    if(sci.CreatedDate.Date() > accLastDemoDateMap.get(sci.Opportunity_Name__r.AccountId))
                        accLastDemoDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }else{
                    accLastDemoDateMap.put(sci.Opportunity_Name__r.AccountId, sci.createdDate.Date());
                }
            }
        }

        for(Task ts : [Select WhatId, Id from Task Where WhatId IN: accIdSet AND CreatedDate = LAST_N_DAYS:90]){

            tempIdSet = new set<Id>();
                if(accIdTaskIdSetMap.containsKey(ts.WhatId)){
                    tempIdSet = accIdTaskIdSetMap.get(ts.WhatId);
                    tempIdSet.add(ts.Id);
                    accIdTaskIdSetMap.put(ts.WhatId,tempIdSet);
                }else{
                    tempIdSet.add(ts.Id);
                    accIdTaskIdSetMap.put(ts.WhatId,tempIdSet);
                }
        }
        
        //Update the Count of Active MCI(Campaign Member) :Added by Gurjinder:Start
        for(CampaignMember CmpgnMem : [Select Id,Account__c,createddate,First_Associate_Date__c 
 from CampaignMember Where Account__c IN:accIdSet AND IsDeleted=false]){
            decimal MCIcount=0;
            if(MCICountmap.containskey(CmpgnMem.Account__c)){
                    MCIcount=MCICountmap.get(CmpgnMem.Account__c);
                    MCIcount++;
                    MCICountmap.put(CmpgnMem.Account__c,MCIcount);
            }else{
                MCIcount++;
                MCICountmap.put(CmpgnMem.Account__c,MCIcount);
            }
            //Update the Count of Last 6 months MCI(Campaign Member):Start
            if(CmpgnMem.First_Associate_Date__c != null && CmpgnMem.First_Associate_Date__c >= date.today().addmonths(-6)){
                if(CmpgnMem.Account__c != null && MCIlast6monthsCount.containsKey(CmpgnMem.Account__c)){
                    MCIlast6monthsCount.put(CmpgnMem.Account__c, MCIlast6monthsCount.get(CmpgnMem.Account__c) + 1);
                }else if(CmpgnMem.Account__c != null ){
                    MCIlast6monthsCount.put(CmpgnMem.Account__c, 1);
                }
            }
            //Update the Count of Last 6 months MCI(Campaign Member):End
        }
        //Update the Count of Active MCI(Campaign Member) :Added by Gurjinder:End
                    
        for(id accId: accIdSet){
            Account acc = new Account ();
            acc.Id = accId;
            decimal sciCount = 0;
           // decimal actHistory = 0;
            decimal taskCount = 0;
            if(accIdTaskIdSetMap.containsKey(accId)){
                taskCount = (accIdTaskIdSetMap.get(accId)).size();
            }
            /*
            if(accActHistoryCountMap.containsKey(accId)){
                actHistory = accActHistoryCountMap.get(accId);
            }
            */
            if(accIdSCIIdSetMap.containsKey(accId)){
                acc.F2F_Meetings__c = (accIdSCIIdSetMap.get(accId)).size();
            }else{
                acc.F2F_Meetings__c = 0;
            }
            if(accIdDemoSCIIdSetMap.containsKey(accId)){
                acc.WebEx_Presentations_L12W__c = (accIdDemoSCIIdSetMap.get(accId)).size();
            }else{
                acc.WebEx_Presentations_L12W__c = 0;
            }

             if(accLastF2FSCIDateMap.containsKey(accId)){
                acc.Last_F2F_Meeting__c = accLastF2FSCIDateMap.get(accId);
            }else{
                acc.Last_F2F_Meeting__c = null;
            }
            
            if(accLastSCIDateMap.containsKey(accId)){
                acc.LastRegularSCIdate__c= accLastSCIDateMap.get(accId);
            }else{
                acc.LastRegularSCIdate__c= null;
            }

            /* if(accLastDemoDateMap.containsKey(accId)){
                acc.Last_WebEx_Demo_Presentation__c = accLastDemoDateMap.get(accId);
            }else{
                acc.Last_WebEx_Demo_Presentation__c = null;
            } */

            if(accLastQBRDateMap.containsKey(accId)){
                acc.Last_QBR_Date__c = accLastQBRDateMap.get(accId);
            }else{
                acc.Last_QBR_Date__c = null;
            }

            if(accIdActiveSCIIdMap.containsKey(accId)){
                acc.Active_POC__c = accIdActiveSCIIdMap.get(accId);
            }else{
                acc.Active_POC__c = null;
            }

            if(accIdImpConfSCIIdMap.containsKey(accId)){
                sciCount = (accIdImpConfSCIIdMap.get(accId)).size();
            }
          //  acc.Other_Touches__c  = taskCount+sciCount+actHistory;

            if(accIdOpenPipelineMap.containsKey(accId)){
                acc.Total_Open_Pipeline__c = accIdOpenPipelineMap.get(accId);
            }else{
                acc.Total_Open_Pipeline__c = 0;
            }
            
            if(scislast6months.containsKey(accId)){
                acc.SCI_s_in_the_last_6_Months__c = scislast6months.get(accId);
            }
            if(scislast12months.containsKey(accId)){
                acc.SCI_s_in_the_last_12_Months__c  = scislast12months.get(accId);
            }
            if(allscis.containsKey(accId)){
                acc.All_time_of_SCI__c = allscis.get(accId);
            }
            if(f2flast6months.containsKey(accId)){
                acc.F2F_SCI_s_in_the_last_6_Months__c = f2flast6months.get(accId);
            }
            if(f2flast12months.containsKey(accId)){
                acc.F2F_SCI_s_in_the_last_12_Months__c = f2flast12months.get(accId);
            }
            if(allf2fs.containsKey(accId)){
                acc.All_time_F2F_of_SCI__c = allf2fs.get(accId);
            }

            if(acclatestzsrmap.containsKey(accId)){
                acc.Latest_SCI_Number__c = acclatestzsrmap.get(accId).Id;
                /*if(acclatestzsrmap.get(accId).Next_ZSR_Date__c != null
                    && acclatestzsrmap.get(accId).Next_ZSR_Date__c >= Date.today()){
                    acc.Next_QBR_Date__c = acclatestzsrmap.get(accId).Next_ZSR_Date__c;
                }*/
                acc.ZSR_Link__c = acclatestzsrmap.get(accId).ZSR_link__c;
            }
            if(acclatestarchsessionmap.containsKey(accId)){
                acc.Architecture_Workshop_Link__c = acclatestarchsessionmap.get(accId).Architecture_Workshop_Link__c;
                acc.Last_Architecture_SCI__c = acclatestarchsessionmap.get(accId).Id;
                if(acclatestarchsessionmap.get(accId).Date__c != null){
                    acc.Last_Architecture_Workshop_Date__c = acclatestarchsessionmap.get(accId).Date__c;
                }
                /*if(acclatestarchsessionmap.get(accId).Next_Architecture_Workshop_Date__c != null){
                    acc.Next_Architecture_Workshop_Date__c = acclatestarchsessionmap.get(accId).Next_Architecture_Workshop_Date__c;
                }*/
            }
            if(MCICountmap.containskey(accId)){
                acc.Count_of_MCI__c=MCICountmap.get(accId);
            }
            
            if(MCIlast6monthsCount.containsKey(accId)){
                acc.MCI_s_in_the_last_6_Months__c=MCIlast6monthsCount.get(accId);               
            }else{
                system.debug('inside else part');
            }
            
            accUpdateList.add(acc);
        }
        /*if(!accLastArchDateMap.isEmpty())
        {
            List<Account> acctList = new List<Account>();
            for(Id accId : accLastArchDateMap.keySet())
            {
                Account acct = new Account();
                acct.Id = accId;
                acct.Last_Architecture_Workshop_Date__c = accLastArchDateMap.get(accId);
                acctList.add(acct);
            }
            if(acctList.size() > 0)
                database.update(acctList,false);
        }
        */
        if(!accUpdateList.isEmpty())
            database.update(accUpdateList,false);

        }catch(exception e){
            System.debug('>>>> Exception: ' + e.getMessage() + '; ' + e.getStackTraceString());
        }

    }


    global void finish(Database.BatchableContext context){
    }
}