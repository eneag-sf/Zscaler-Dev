public class LinearityDashboardService {
   public LinearityDashboardService(LinearityDashboardController controller){}
   
    @RemoteAction @ReadOnly
    public static ForecastSummary getTeamForecast(String userId , String fiscalYear, String forecastType ){
        List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
        if(!users.isEmpty()){
            ForecastSummary forecastSummary = new ForecastSummary();
            forecastSummary.UserId = users[0].Id;
            forecastSummary.UserName = users[0].Name;
            Map<string, string> fiscalQtrMap = new map<string, string>();
            fiscalQtrMap.put('first',fiscalYear+'-Q1');
            fiscalQtrMap.put('second',fiscalYear+'-Q2');
            fiscalQtrMap.put('third',fiscalYear+'-Q3');
            fiscalQtrMap.put('fourth',fiscalYear+'-Q4');
            
            Set<String> fiscalQtrSet = new set<String>();
            fiscalQtrSet.add(fiscalYear+'Q1');
            fiscalQtrSet.add(fiscalYear+'Q2');
            fiscalQtrSet.add(fiscalYear+'Q3');
            fiscalQtrSet.add(fiscalYear+'Q4');
            
            map<string,decimal> fscalQtrClosedWonAmtMap = new map<string, decimal>();
            fscalQtrClosedWonAmtMap.put(fiscalYear+'-Q1', 0);
            fscalQtrClosedWonAmtMap.put(fiscalYear+'-Q2', 0);
            fscalQtrClosedWonAmtMap.put(fiscalYear+'-Q3', 0);
            fscalQtrClosedWonAmtMap.put(fiscalYear+'-Q4', 0);
            set<string> forecastTypeSet = new set<String>();
            forecastTypeSet = getForecastTypes(forecastType);
            Map<string, decimal> fiscalQtrQuotaMap = new map<string, decimal>();
            fiscalQtrQuotaMap.put('first',0);
            fiscalQtrQuotaMap.put('second',0);
            fiscalQtrQuotaMap.put('third',0);
            fiscalQtrQuotaMap.put('fourth',0);
            for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c IN: fiscalQtrSet AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                if(salesQuota.FYFQ__c == fiscalYear+'Q1'){
                    if(salesQuota.QuotaAmount__c != null)
                        fiscalQtrQuotaMap.put('first', salesQuota.QuotaAmount__c+fiscalQtrQuotaMap.get('first'));
                }else if(salesQuota.FYFQ__c == fiscalYear+'Q2'){
                    if(salesQuota.QuotaAmount__c != null)
                        fiscalQtrQuotaMap.put('second', salesQuota.QuotaAmount__c+fiscalQtrQuotaMap.get('second'));
                }else if(salesQuota.FYFQ__c  == fiscalYear+'Q3'){
                    if(salesQuota.QuotaAmount__c != null)
                        fiscalQtrQuotaMap.put('third', salesQuota.QuotaAmount__c+fiscalQtrQuotaMap.get('third'));
                }else if(salesQuota.FYFQ__c == fiscalYear+'Q4'){
                    if(salesQuota.QuotaAmount__c != null)
                        fiscalQtrQuotaMap.put('fourth', salesQuota.QuotaAmount__c+fiscalQtrQuotaMap.get('fourth'));
                }
            }
            
            
            forecastSummary.firstQtrQuota = fiscalQtrQuotaMap.get('first');
            forecastSummary.secondQtrQuota =  fiscalQtrQuotaMap.get('second');
            forecastSummary.thirdQtrQuota =  fiscalQtrQuotaMap.get('third');
            forecastSummary.fourthQtrQuota =  fiscalQtrQuotaMap.get('fourth');
            
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            set<String> OppStageSet = new set<String>();
            OppStageSet.add(label.Stage_6_Closed_Won);              /*'13 - Closed & Approved By Finance'*/
            OppStageSet.add(label.Stage_5_Contracts_Complete);      /*'10b - PO recd, pending finance approval'*/
            for( OpportunitySplit oppSplit : [SELECT SplitAmount, OpportunityId, SplitOwnerId, Forecast_Type__c, Opportunity.CloseDate, Opportunity.Fiscal_Period__c, SplitOwner.Name FROM OpportunitySplit Where Opportunity.StageName IN: OppStageSet AND  SplitOwnerId IN : allUserIds AND Opportunity.Fiscal_Period__c IN: fiscalQtrMap.Values() AND Forecast_Type__c IN : forecastTypeSet]){
                fscalQtrClosedWonAmtMap.put(oppSplit.Opportunity.Fiscal_Period__c, fscalQtrClosedWonAmtMap.get(oppSplit.Opportunity.Fiscal_Period__c)+oppSplit.SplitAmount);
            }
            
            forecastSummary.firstQtrClosedWon = fscalQtrClosedWonAmtMap.get(fiscalYear+'-Q1');
            forecastSummary.secondQtrClosedWon = fscalQtrClosedWonAmtMap.get(fiscalYear+'-Q2');
            forecastSummary.thirdQtrClosedWon = fscalQtrClosedWonAmtMap.get(fiscalYear+'-Q3');
            forecastSummary.fourthQtrClosedWon = fscalQtrClosedWonAmtMap.get(fiscalYear+'-Q4');
            
            
            forecastSummary.firstQtrQuotaPercnt = PerformanceStatService.getCoverage(forecastSummary.firstQtrClosedWon, forecastSummary.firstQtrQuota);
            forecastSummary.secondQtrQuotaPercnt = PerformanceStatService.getCoverage(forecastSummary.secondQtrClosedWon, forecastSummary.secondQtrQuota);
            forecastSummary.thirdQtrQuotaPercnt = PerformanceStatService.getCoverage(forecastSummary.thirdQtrClosedWon, forecastSummary.thirdQtrQuota);
            forecastSummary.fourthQtrQuotaPercnt = PerformanceStatService.getCoverage(forecastSummary.fourthQtrClosedWon, forecastSummary.fourthQtrQuota);
            
            
            return forecastSummary;
        }else{
            return null;
        }
    }
   
    @RemoteAction @ReadOnly
    public static MonthlyMetric getMonthlyContriLinearity(String userId , String currentFiscalQtr, String forecastType ){
        MonthlyMetric montlyMet = new MonthlyMetric();
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
        montlyMet.plan = 0;
        montlyMet.mostLikely = 0;
        montlyMet.mostLikely = 0;
        
        string fiscalQtr = currentFiscalQtr.substring(0,4) + '-' +currentFiscalQtr.substring(4,currentFiscalQtr.length());
        
        set<string> forecastTypeSet = new set<String>();
        forecastTypeSet = getForecastTypes(forecastType);
        for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c =: currentFiscalQtr AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
            if(salesQuota.QuotaAmount__c != null)
                montlyMet.plan += salesQuota.QuotaAmount__c;
            
        }
        if(forecastType != '' && forecastType != 'all'){
            for(CustomForecast__c forecast : [SELECT Id, User__c, User__r.Name, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, ForecastType__c, YYWW__c, FYFQ__c, Locked__c FROM CustomForecast__c WHERE FYFQ__c = :currentFiscalQtr AND User__c = :userId AND ForecastType__c =: forecastType ORDER BY YYWW__c DESC limit 1]){
                montlyMet.mostLikely = forecast.QuarterCommit__c != null ? forecast.QuarterCommit__c : 0;
                
            }   
        }else{
            for(CustomForecast__c forecast : [SELECT Id, User__c, User__r.Name, QuarterCommit__c, QuarterPipeline__c, QuarterUpside__c, ForecastType__c, YYWW__c, FYFQ__c, Locked__c FROM CustomForecast__c WHERE FYFQ__c = :currentFiscalQtr AND User__c = :userId AND ForecastType__c!= null ORDER BY YYWW__c DESC limit 3]){
                if(forecast.ForecastType__c == 'new' ||forecast.ForecastType__c == 'upsell' )
                    montlyMet.mostLikely += forecast.QuarterCommit__c != null ? forecast.QuarterCommit__c : 0;
                
            }
        }
        
        set<String> OppStageSet = new set<String>();
        OppStageSet.add(label.Stage_6_Closed_Won);              /*'13 - Closed & Approved By Finance'*/
        OppStageSet.add(label.Stage_5_Contracts_Complete);      /*'10b - PO recd, pending finance approval'*/
        map<integer, decimal> montlyClosedWonOppAmtMap = new map<integer, decimal>();
        integer frstQtrMonth = 0;
        for( OpportunitySplit oppSplit : [SELECT SplitAmount, OpportunityId, SplitOwnerId, Forecast_Type__c, Opportunity.CloseDate, Opportunity.Fiscal_Period__c, SplitOwner.Name FROM OpportunitySplit Where Opportunity.StageName IN: OppStageSet AND  SplitOwnerId IN : allUserIds AND Opportunity.Fiscal_Period__c =: fiscalQtr AND Forecast_Type__c IN : forecastTypeSet]){ 
            if(montlyClosedWonOppAmtMap != null ){
                if(montlyClosedWonOppAmtMap.keySet().Contains(oppSplit.Opportunity.CloseDate.Month()))
                    montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), montlyClosedWonOppAmtMap.get(oppSplit.Opportunity.CloseDate.Month()) + oppSplit.SplitAmount);
                else
                        montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(),oppSplit.SplitAmount);
            }else
                montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), oppSplit.SplitAmount);
            if(frstQtrMonth != 0 )
                frstQtrMonth = frstQtrMonth > oppSplit.Opportunity.CloseDate.Month() ? oppSplit.Opportunity.CloseDate.Month() : frstQtrMonth;
            else
                frstQtrMonth = oppSplit.Opportunity.CloseDate.Month();
        }
        
        montlyMet.closedWonM1 = montlyClosedWonOppAmtMap.keySet().Contains(frstQtrMonth) ? montlyClosedWonOppAmtMap.get(frstQtrMonth) : 0;
        montlyMet.closedWonM2 = montlyClosedWonOppAmtMap.keySet().Contains(frstQtrMonth + 1) ? montlyClosedWonOppAmtMap.get(frstQtrMonth + 1) : 0;
        montlyMet.closedWonM3 = montlyClosedWonOppAmtMap.keySet().Contains(frstQtrMonth + 2) ? montlyClosedWonOppAmtMap.get(frstQtrMonth + 2) : 0;
        return montlyMet;
    }
   
    @RemoteAction @ReadOnly
    public static LinearityMetric getLinearityMetric(String userId , String currentFiscalQtr, String forecastType ){
        
        LinearityMetric linMetric= new LinearityMetric();
        
        linMetric.linearityTargetM1 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM1').Value__c);
        linMetric.linearityTargetM2 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM2').Value__c);
        linMetric.linearityTargetM3 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM3').Value__c);
        
        List<Id> allUserIds = new List<Id>();
        allUserIds.add(userId);
        allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
        
        decimal userQuota = 0;
        set<string> forecastTypeSet = new set<String>();
        forecastTypeSet = getForecastTypes(forecastType);
        for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c =: currentFiscalQtr AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
            if(salesQuota.QuotaAmount__c != null)
                userQuota += salesQuota.QuotaAmount__c;
        }
        linMetric.qtrQuota = userQuota; 
        linMetric.monthlyQuotaM1 = (userQuota*linMetric.linearityTargetM1)/100;
        linMetric.monthlyQuotaM2 = (userQuota*linMetric.linearityTargetM2)/100;
        linMetric.monthlyQuotaM3 = (userQuota*linMetric.linearityTargetM3)/100;     
        
        map<integer, decimal> montlyClosedWonOppAmtMap = new map<integer, decimal>();
        map<integer, decimal> montlyOpenOppAmtMap = new map<integer, decimal>();
        list<integer> monthNoList = new list<Integer>();
        
        string fiscalQtr = currentFiscalQtr.substring(0,4) + '-' +currentFiscalQtr.substring(4,currentFiscalQtr.length());
        
        for( OpportunitySplit oppSplit : [SELECT SplitAmount, OpportunityId, SplitOwnerId, Forecast_Type__c, Opportunity.StageName,Opportunity.CloseDate, Opportunity.Fiscal_Period__c, SplitOwner.Name FROM OpportunitySplit Where  SplitOwnerId IN : allUserIds AND Opportunity.Fiscal_Period__c =: fiscalQtr AND Forecast_Type__c IN : forecastTypeSet AND SplitAmount != null AND Opportunity.ForecastCategoryName != 'Omitted' ]){
        //for(Opportunity opp : [Select Id, Amount, Fiscal_Period__c, CloseDate, Probability, IsClosed, StageName, ForecastCategoryName  from Opportunity Where OwnerId IN :allUserIds AND Forecast_Type__c IN: forecastTypeSet AND Amount != null  AND Fiscal_Period__c =: fiscalQtr AND ForecastCategoryName != 'Omitted']){ 
            if(oppSplit.Opportunity.StageName == label.Stage_6_Closed_Won   /*'13 - Closed & Approved By Finance'*/ || oppSplit.Opportunity.StageName == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ ){
                if(montlyClosedWonOppAmtMap != null ){
                    if(montlyClosedWonOppAmtMap.keySet().Contains(oppSplit.Opportunity.CloseDate.Month()))
                            montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), montlyClosedWonOppAmtMap.get(oppSplit.Opportunity.CloseDate.Month()) + oppSplit.SplitAmount);
                    else
                        montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(),oppSplit.SplitAmount);
                }else{
                    montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), oppSplit.SplitAmount);
                }
            }else{
                if(montlyOpenOppAmtMap != null ){
                    if(montlyOpenOppAmtMap.keySet().Contains(oppSplit.Opportunity.CloseDate.Month()))
                            montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), montlyOpenOppAmtMap.get(oppSplit.Opportunity.CloseDate.Month()) + oppSplit.SplitAmount);
                    else
                        montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(),oppSplit.SplitAmount);
                }else{
                    montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), oppSplit.SplitAmount);
                }
            }
        
        }
        
        set<integer> monthNoSet = new set<integer>();
        monthNoSet.addAll(montlyOpenOppAmtMap.keySet());
        monthNoSet.addAll(montlyClosedWonOppAmtMap.keySet());
        monthNoList.addAll(monthNoSet);
        monthNoList.sort();
        Integer count = 0;
        for(Integer i : monthNoList){
            count++;
            if(count == 1){
                linMetric.closedWonM1 = montlyClosedWonOppAmtMap.get(i) != null ?montlyClosedWonOppAmtMap.get(i):0;
                linMetric.openDealsM1 = montlyOpenOppAmtMap.get(i)!= null ?montlyOpenOppAmtMap.get(i):0;
            }else if(count == 2){
                linMetric.closedWonM2 = montlyClosedWonOppAmtMap.get(i)!= null ?montlyClosedWonOppAmtMap.get(i):0;
                linMetric.openDealsM2 = montlyOpenOppAmtMap.get(i)!= null ?montlyOpenOppAmtMap.get(i):0;
            }else if (count == 3){
                linMetric.closedWonM3 = montlyClosedWonOppAmtMap.get(i)!= null ?montlyClosedWonOppAmtMap.get(i):0;
                linMetric.openDealsM3 = montlyOpenOppAmtMap.get(i)!= null ?montlyOpenOppAmtMap.get(i):0;
            }
        }
        return linMetric;
    }
    
    
    
    @RemoteAction @ReadOnly
    
    
    public static LinearityStack getLinearityStack(LinearityStackFilter req){
        
        List<User> users = [SELECT Id, Name, UserRoleId, Level__c FROM User WHERE Id = :req.userId LIMIT 1];
        if(!users.isEmpty()){
            LinearityStack stackSummary = new  LinearityStack();
            stackSummary.userName = users[0].Name;
            stackSummary.UserId = users[0].Id;
            
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(req.userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(req.userId));
            
            set<string> forecastTypeSet = new set<String>();
            forecastTypeSet = getForecastTypes(req.forecastType);
            
            decimal userQuota = 0;
            for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c =: req.currentFiscalQtr AND ForecastType__c IN: forecastTypeSet AND User__c =: req.userId]){
                if(salesQuota.QuotaAmount__c != null)
                    userQuota += salesQuota.QuotaAmount__c;
            }
            
            
            
            map<string, integer> qtrMonthMap = new map<string, integer>();
            qtrMonthMap.put('Q1',8);
            qtrMonthMap.put('Q2',11);
            qtrMonthMap.put('Q3',2);
            qtrMonthMap.put('Q4',5);
            
            integer qtrMonth1 = qtrMonthMap.get(req.currentFiscalQtr.substring(4,req.currentFiscalQtr.length()));
            integer qtrMonth2 = qtrMonth1 +1;
            integer qtrMonth3 = qtrMonth2 +1;
            
            integer qtrMonthFilter; 
            decimal linearityTarget = 0;
            
            
            
            if(req.month == 'Month 1'){
                qtrMonthFilter = qtrMonth1;
                linearityTarget = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM1').Value__c);
            }else if(req.month == 'Month 2'){
                qtrMonthFilter = qtrMonth2;
                linearityTarget = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM2').Value__c);
            }else if(req.month == 'Month 3'){
                qtrMonthFilter = qtrMonth3;
                linearityTarget = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricM3').Value__c);         
            }
            stackSummary.monthlyQuota =  linearityTarget > 0  && userQuota > 0 ?  (userQuota*linearityTarget)/100 : 0;
            
            string fiscalQtr = req.currentFiscalQtr.substring(0,4) + '-' +req.currentFiscalQtr.substring(4,req.currentFiscalQtr.length());

            map<integer, decimal> montlyClosedWonOppAmtMap = new map<integer, decimal>();
            map<integer, decimal> montlyOpenOppAmtMap = new map<integer, decimal>();
            
            for( OpportunitySplit oppSplit : [SELECT SplitAmount, OpportunityId, SplitOwnerId, Forecast_Type__c, Opportunity.StageName,Opportunity.CloseDate, Opportunity.Fiscal_Period__c, SplitOwner.Name FROM OpportunitySplit Where  SplitOwnerId IN : allUserIds AND Opportunity.Fiscal_Period__c =: fiscalQtr AND Forecast_Type__c IN : forecastTypeSet AND SplitAmount != null AND Opportunity.ForecastCategoryName != 'Omitted' ]){
                if(oppSplit.Opportunity.CloseDate.Month() == qtrMonthFilter){
                    if(oppSplit.Opportunity.StageName == label.Stage_6_Closed_Won   /*'13 - Closed & Approved By Finance'*/ || oppSplit.Opportunity.StageName == label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/ ){
                        if(montlyClosedWonOppAmtMap != null ){
                            if(montlyClosedWonOppAmtMap.keySet().Contains(oppSplit.Opportunity.CloseDate.Month()))
                                    montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), montlyClosedWonOppAmtMap.get(oppSplit.Opportunity.CloseDate.Month()) + oppSplit.SplitAmount);
                            else
                                montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(),oppSplit.SplitAmount);
                        }else{
                            montlyClosedWonOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), oppSplit.SplitAmount);
                        }
                    }else{
                        if(montlyOpenOppAmtMap != null ){
                            if(montlyOpenOppAmtMap.keySet().Contains(oppSplit.Opportunity.CloseDate.Month()))
                                    montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), montlyOpenOppAmtMap.get(oppSplit.Opportunity.CloseDate.Month()) + oppSplit.SplitAmount);
                            else
                                montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(),oppSplit.SplitAmount);
                        }else{
                            montlyOpenOppAmtMap.put(oppSplit.Opportunity.CloseDate.Month(), oppSplit.SplitAmount);
                        }
                    }
                }
                
            
            }
            
            stackSummary.closedWon = montlyClosedWonOppAmtMap.get(qtrMonthFilter) != null ? montlyClosedWonOppAmtMap.get(qtrMonthFilter): 0;
            stackSummary.linearityActual =  stackSummary.monthlyQuota != null && stackSummary.monthlyQuota > 0 ? (stackSummary.closedWon/stackSummary.monthlyQuota)*100: 0 ;
            stackSummary.openDeals = montlyOpenOppAmtMap.get(qtrMonthFilter)  != null ? montlyOpenOppAmtMap.get(qtrMonthFilter): 0;
            return stackSummary;
        }else{
            return null;
        }
        
    }    
    
    @RemoteAction @ReadOnly
    public static QuarterlyLinearityMetric getQuarterlyLinearityMetric(String userId , String forecastType, string firstQtr, String secondQtr, string thirdQtr, string fourthQtr ){
        map<string, decimal> qtrClosedWonMap = new map<string, decimal>();
        map<string, decimal> qtrQuotaMap = new map<string, decimal>();
        qtrClosedWonMap.put(firstQtr.deleteWhitespace().substring(0, 4)+'-'+firstQtr.deleteWhitespace().substring(4, firstQtr.length()),0);
        qtrClosedWonMap.put(secondQtr.deleteWhitespace().substring(0, 4)+'-'+secondQtr.deleteWhitespace().substring(4, secondQtr.length()),0);
        qtrClosedWonMap.put(thirdQtr.deleteWhitespace().substring(0, 4)+'-'+thirdQtr.deleteWhitespace().substring(4, thirdQtr.length()),0);
        qtrClosedWonMap.put(fourthQtr.deleteWhitespace().substring(0, 4)+'-'+fourthQtr.deleteWhitespace().substring(4, fourthQtr.length()),0);
        
        qtrQuotaMap.put((firstQtr.deleteWhitespace()).Remove('-'),0);
        qtrQuotaMap.put((secondQtr.deleteWhitespace()).Remove('-'),0);
        qtrQuotaMap.put((thirdQtr.deleteWhitespace()).Remove('-'),0);
        qtrQuotaMap.put((fourthQtr.deleteWhitespace()).Remove('-'),0);
        
                
        QuarterlyLinearityMetric tempQtrLinMetric = new QuarterlyLinearityMetric();
        List<User> users = [SELECT Id, Name, UserRoleId, Level__c FROM User WHERE Id = :userId LIMIT 1];
        if(!users.isEmpty()){
            set<string> forecastTypeSet = new set<string>(); 
            forecastTypeSet = getForecastTypes(forecastType);
            for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c IN: qtrQuotaMap.KeySet()  AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                if(qtrQuotaMap.keyset().contains(salesQuota.FYFQ__c)){
                    qtrQuotaMap.put(salesQuota.FYFQ__c, qtrQuotaMap.get(salesQuota.FYFQ__c) + salesQuota.QuotaAmount__c);
                }
            }
            
            
            tempQtrLinMetric.quotaQ1 = qtrQuotaMap.get((firstQtr.deleteWhitespace()).Remove('-'));
            tempQtrLinMetric.quotaQ2 = qtrQuotaMap.get((secondQtr.deleteWhitespace()).Remove('-'));
            tempQtrLinMetric.quotaQ3 = qtrQuotaMap.get((thirdQtr.deleteWhitespace()).Remove('-'));
            tempQtrLinMetric.quotaQ4 = qtrQuotaMap.get((fourthQtr.deleteWhitespace()).Remove('-'));
            
            if(forecastType == 'new'){
                tempQtrLinMetric.linearityTargetQ1 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricNewQ1').Value__c);
                tempQtrLinMetric.linearityTargetQ2 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricNewQ2').Value__c);
                tempQtrLinMetric.linearityTargetQ3 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricNewQ3').Value__c);
                tempQtrLinMetric.linearityTargetQ4 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricNewQ4').Value__c);
            }else if(forecastType == 'upsell'){
                tempQtrLinMetric.linearityTargetQ1 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricUpsellQ1').Value__c);
                tempQtrLinMetric.linearityTargetQ2 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricUpsellQ2').Value__c);
                tempQtrLinMetric.linearityTargetQ3 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricUpsellQ3').Value__c);
                tempQtrLinMetric.linearityTargetQ4 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricUpsellQ4').Value__c);
            }else{
                tempQtrLinMetric.linearityTargetQ1 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricAllQ1').Value__c);
                tempQtrLinMetric.linearityTargetQ2 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricAllQ2').Value__c);
                tempQtrLinMetric.linearityTargetQ3 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricAllQ3').Value__c);
                tempQtrLinMetric.linearityTargetQ4 = decimal.valueOf(ZscalerSetting__c.getInstance('LinearityMetricAllQ4').Value__c);
            }
            
            
            List<Id> allUserIds = new List<Id>();
            allUserIds.add(userId);
            allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
            set<String> OppSrageSet = new set<String>();
            OppSrageSet.add(label.Stage_6_Closed_Won   );/*'13 - Closed & Approved By Finance'*/
            OppSrageSet.add(label.Stage_5_Contracts_Complete);/*'10b - PO recd, pending finance approval'*/
            for( OpportunitySplit oppSplit : [SELECT SplitAmount, OpportunityId, SplitOwnerId, Forecast_Type__c, Opportunity.Fiscal_Period__c, SplitOwner.Name FROM OpportunitySplit Where Opportunity.StageName IN: OppSrageSet AND  SplitOwnerId IN : allUserIds AND Opportunity.Fiscal_Period__c In : qtrClosedWonMap.keySet() AND Forecast_Type__c IN : forecastTypeSet]){  
                if(qtrClosedWonMap.keySet().contains(oppSplit.Opportunity.Fiscal_Period__c))
                    qtrClosedWonMap.put(oppSplit.Opportunity.Fiscal_Period__c,qtrClosedWonMap.get(oppSplit.Opportunity.Fiscal_Period__c) + oppSplit.SplitAmount);
            }
            
            tempQtrLinMetric.closedWonQ1 = qtrClosedWonMap.get(firstQtr.deleteWhitespace().substring(0, 4)+'-'+firstQtr.deleteWhitespace().substring(4, firstQtr.length()));
            tempQtrLinMetric.closedWonQ2 = qtrClosedWonMap.get(secondQtr.deleteWhitespace().substring(0, 4)+'-'+secondQtr.deleteWhitespace().substring(4, secondQtr.length()));
            tempQtrLinMetric.closedWonQ3 = qtrClosedWonMap.get(thirdQtr.deleteWhitespace().substring(0, 4)+'-'+thirdQtr.deleteWhitespace().substring(4, thirdQtr.length()));
            tempQtrLinMetric.closedWonQ4 = qtrClosedWonMap.get(fourthQtr.deleteWhitespace().substring(0, 4)+'-'+fourthQtr.deleteWhitespace().substring(4, fourthQtr.length()));
            return tempQtrLinMetric;
        }else
            return null;
    }
    
    public static set<string> getForecastTypes(string forcasteType){
        set<string> tempForcasteTypeSet = new set<string>();
        if(forcasteType == 'all'){
            tempForcasteTypeSet.add('new');
            tempForcasteTypeSet.add('upsell');
        }else{
            tempForcasteTypeSet.add(forcasteType);
        }
        return tempForcasteTypeSet;
    }
    
    public class MonthlyMetric{
        public decimal percentagePlanM1 {get;set;}
        public decimal percentagePlanM2 {get;set;}
        public decimal percentagePlanM3 {get;set;}
        
        public decimal closedWonM1 {get;set;}
        public decimal closedWonM2 {get;set;}
        public decimal closedWonM3 {get;set;}
        
        public decimal percentageMLM1 {get;set;}
        public decimal percentageMLM2 {get;set;}
        public decimal percentageMLM3 {get;set;}
        
        public decimal mostLikely {get;set;}
        public decimal plan {get;set;}
    }
    
    public class ForecastSummary{
        public String UserId { get; set; }
        public String UserName { get; set; }
                
                
        public decimal firstQtrQuota {get;set;}
        public decimal firstQtrClosedWon {get;set;}
        public decimal firstQtrQuotaPercnt {get;set;}
                
        public decimal secondQtrQuota {get;set;}
        public decimal secondQtrClosedWon {get;set;}
        public decimal secondQtrQuotaPercnt {get;set;}
                
                
        public decimal thirdQtrQuota {get;set;}
        public decimal thirdQtrClosedWon {get;set;}
        public decimal thirdQtrQuotaPercnt {get;set;}
                
        public decimal fourthQtrQuota {get;set;}
        public decimal fourthQtrClosedWon {get;set;}
        public decimal fourthQtrQuotaPercnt {get;set;}
                
        public decimal totalAmount {get;set;}
        public decimal totalQuota {get;set;}
        public decimal totalQuotaPercentage{get; set;}   
                
    }
    
    public class LinearityMetric{
        public decimal linearityTargetM1 {get;set;}
        public decimal linearityTargetM2 {get;set;}
        public decimal linearityTargetM3 {get;set;}
        
        public decimal closedWonM1 {get;set;}
        public decimal closedWonM2 {get;set;}
        public decimal closedWonM3 {get;set;}
        
        public decimal openDealsM1 {get;set;}
        public decimal openDealsM2 {get;set;}
        public decimal openDealsM3 {get;set;}
        
        public decimal monthlyQuotaM1 {get;set;}
        public decimal monthlyQuotaM2 {get;set;}
        public decimal monthlyQuotaM3 {get;set;}
        
        public decimal qtrQuota {get;set;}
    }
    
    public class QuarterlyLinearityMetric{
        public decimal linearityTargetQ1 {get;set;}
        public decimal linearityTargetQ2 {get;set;}
        public decimal linearityTargetQ3 {get;set;}
        public decimal linearityTargetQ4 {get;set;}
        
        public decimal closedWonQ1 {get;set;}
        public decimal closedWonQ2 {get;set;}
        public decimal closedWonQ3 {get;set;}
        public decimal closedWonQ4 {get;set;}
        
        
        public decimal quotaQ1 {get;set;}
        public decimal quotaQ2 {get;set;}
        public decimal quotaQ3 {get;set;}
        public decimal quotaQ4 {get;set;}
    }
    
    public class LinearityStack{
        public string userName{get;set;}
        public String UserId { get; set; }
        
        public decimal linearityActual{get;set;}
        public decimal monthlyQuota {get;set;}
        public decimal closedWon {get;set;}
        public decimal toGoPercent {get;set;}
        public decimal openDeals {get;set;}
        public decimal coverage {get;set;}
    }
    
    Public class LinearityStackFilter{
        public String userId {get; set;}
        public String currentFiscalQtr {get; set;} 
        public String forecastType {get; set;}
        public string month {get; set;}
    }
}