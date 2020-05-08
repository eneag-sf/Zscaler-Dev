trigger genericOpportunitySnapTrigger on Opportunity_Snapshot__c (after insert) {
    if(trigger.isInsert && Trigger.isAfter){
        list<Opportunity_Issue__c> oppIssueInsertList = new list<Opportunity_Issue__c>();
        set<id> misngPartnerOppIdSet = new set<id>();
        set<Id> oppIdSet = new set<Id>();
        set<String> oppTypeSet = new set<String>();
        oppTypeSet.add('New Business');
        oppTypeSet.add('Existing Customer (Add On)');
        oppTypeSet.add('Existing Customer (Renewal)');
        
        for(Opportunity_Snapshot__c oppSnapshot : trigger.new){
            if(oppSnapshot.Opportunity__c != null)
                oppIdSet.add(oppSnapshot.Opportunity__c);
        }
        list<String> oppStageList = new list<String>();
        oppStageList.add(label.Stage_1_Alignment);
        oppStageList.add(label.Stage_4_Economic_Buyer_Signoff);
        
        /*oppStageList.add('0 - Initial Prospecting');  
        oppStageList.add('1 - Qualified and Budgeted');  
        oppStageList.add('2 - Eval Expected');
        oppStageList.add('3 - Qualified and Provisioned');
        oppStageList.add('4 - Eval Active');
        oppStageList.add('5 - Eval Stalled');
        oppStageList.add('6 - Technical Win');
        oppStageList.add('7 - Negotiation & Review');
        oppStageList.add('8 - Expecting Order');
        oppStageList.add('9 - Deal Stuck');*/
        
        

        Map<Id, Opportunity> oppMap = new map<id, Opportunity>();
        for(Opportunity opp : [Select Id, NextStep, CreatedDate, Last_Next_Step_Updated_Date__c, StageName, Type, Fiscal_Quarter_To_Close__c, (select AccountToId, AccountTo.Name from OpportunityPartnersFrom where IsPrimary=true) from Opportunity where ID IN: oppIdSet AND StageName IN : oppStageList AND IsClosed = false AND Type IN: oppTypeSet]){
            oppMap.put(opp.Id, Opp);
        }
        
        for(Opportunity_Snapshot__c oppSnapshot : trigger.new){
            if(oppSnapshot.Issue_Type__c != null){
                for(string str : oppSnapshot.Issue_Type__c.split(',') ){
                    Opportunity_Issue__c oppIssue = new Opportunity_Issue__c();
                    oppIssue.Issue_Type__c = str;
                    oppIssue.Opportunity__c = oppSnapshot.Opportunity__c;
                    oppIssue.Opportunity_Snapshot__c= oppSnapshot.Id;
                    oppIssueInsertList.add(oppIssue);
                }
            }
        }
        
        for(Opportunity_Snapshot__c oppSnapshot : trigger.new){
            
            if(oppMap.keyset().contains(oppSnapshot.Opportunity__c)){
                Opportunity opp = new Opportunity();
                opp = oppMap.get(oppSnapshot.Opportunity__c);
                
                if(opp.OpportunityPartnersFrom.size()<1 && (Opp.Type == 'New Business' || Opp.Type == 'Existing Customer (Add On)' ) && /*opp.StageName != '0 - Initial Prospecting' &&*/ opp.stageName != label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/){
                    Opportunity_Issue__c oppIssue = new Opportunity_Issue__c();
                    oppIssue.Issue_Type__c = 'Missing Primary Partner';
                    oppIssue.Opportunity__c = oppSnapshot.Opportunity__c;
                    oppIssue.Opportunity_Snapshot__c= oppSnapshot.Id;
                    oppIssueInsertList.add(oppIssue);
                }
                //if(opp.stageName != '8 - Expecting Order' && opp.stageName != '9 - Deal Stuck' ){
                if(opp.stageName != label.Stage_4_Economic_Buyer_Signoff){
                    if(opp.NextStep != null){
                        if(opp.Last_Next_Step_Updated_Date__c != null && ((opp.Fiscal_Quarter_To_Close__c == 0 && opp.Last_Next_Step_Updated_Date__c + 10 < system.today() && opp.Last_Next_Step_Updated_Date__c < System.today()) || (opp.Fiscal_Quarter_To_Close__c == 1 && opp.Last_Next_Step_Updated_Date__c + 30 < System.today() && opp.Last_Next_Step_Updated_Date__c < System.Today() )) /*&& opp.StageName != '0 - Initial Prospecting' */ ){
                            Opportunity_Issue__c oppIssue = new Opportunity_Issue__c();
                            oppIssue.Issue_Type__c = 'Next step needs update';
                            oppIssue.Opportunity__c = oppSnapshot.Opportunity__c;
                            oppIssue.Opportunity_Snapshot__c= oppSnapshot.Id;
                            oppIssueInsertList.add(oppIssue);
                        }
                    }else{
                        date oppCreatedDate  =date.newinstance(opp.CreatedDate.year(), opp.CreatedDate.month(), opp.CreatedDate.day());
                        if((opp.Fiscal_Quarter_To_Close__c == 0 && oppCreatedDate + 10 < system.today() && oppCreatedDate < System.today()) || (opp.Fiscal_Quarter_To_Close__c == 1 && oppCreatedDate + 30 < System.today() && oppCreatedDate < System.Today() )){
                            Opportunity_Issue__c oppIssue = new Opportunity_Issue__c();
                            oppIssue.Issue_Type__c = 'Next step needs update';
                            oppIssue.Opportunity__c = oppSnapshot.Opportunity__c;
                            oppIssue.Opportunity_Snapshot__c= oppSnapshot.Id;
                            oppIssueInsertList.add(oppIssue);
                        }
                    }
                }
                
            }
            
            
                
        }
        
        
        if(!oppIssueInsertList.isEmpty())
            database.insert(oppIssueInsertList, false);
    }
}