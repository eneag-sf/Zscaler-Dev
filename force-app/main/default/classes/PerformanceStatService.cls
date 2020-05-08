public with sharing class PerformanceStatService{
            public PerformanceStatService(PerformanceController controller) { }
            
            @RemoteAction @ReadOnly
    public static ForecastSummary GetForecastSummary(String userId , String fiscalQuarter, String forecastType ){
                User user;
                List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
                if(users.size() > 0){
                    ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
                    ForecastSummary forecastSummary = new ForecastSummary();
                    forecastSummary.UserId = users[0].Id;
                    forecastSummary.UserName = users[0].Name;
                    map<integer, integer> qtrMap = new map<integer, integer>(); 
                    integer fsicalYear = system.Today().Year();
                    for(Integer i = 1; i <=12; i++){
                       if(i ==8 || i == 9 || i == 10){
                           qtrMap.put(i, 10);
                       }else if(i ==11 || i == 12 || i == 1){
                           qtrMap.put(i, 1);
                       }else if(i ==2 || i == 3 || i == 4){
                           qtrMap.put(i, 4);
                       }else if (i ==5 || i == 6 || i == 7){
                           qtrMap.put(i, 7);
                       }
                   } 
                   
                   if( system.Today().Month() == 11 || system.Today().Month() == 12){
                       fsicalYear += 1;
                   }
                date lastMonthDateQtr = date.newInstance(fsicalYear, qtrMap.get(system.Today().Month()), 1);
               
                string firstQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(3), 1);
                string secondQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(6), 1);
                string thirdQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(9), 1);
                string fourthQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(12), 1);
               
                set<string> fiscalQtrSet = new set<String>();
                fiscalQtrSet.add(firstQtr);
                fiscalQtrSet.add(secondQtr);
                fiscalQtrSet.add(thirdQtr);
                fiscalQtrSet.add(fourthQtr);
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                
                decimal frstQtrQuota = 0;
                decimal secondQtrQuota = 0;
                decimal thirdQtrQuota = 0;
                decimal fourthQtrQuota = 0;
               
                for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c IN: fiscalQtrSet AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                   if(salesQuota.FYFQ__c == firstQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            frstQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == secondQtr){
                       if(salesQuota.QuotaAmount__c != null)
                            secondQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c  == thirdQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            thirdQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == fourthQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            fourthQtrQuota += salesQuota.QuotaAmount__c;
                    }
               }
               
               forecastSummary.firstQtrQuota = frstQtrQuota;
               forecastSummary.secondQtrQuota =  secondQtrQuota;
               forecastSummary.thirdQtrQuota =  thirdQtrQuota;
               forecastSummary.fourthQtrQuota =  fourthQtrQuota;
               
               forecastSummary.firstQtrQuota = forecastSummary.firstQtrQuota != null ? forecastSummary.firstQtrQuota : 0;
               forecastSummary.secondQtrQuota = forecastSummary.secondQtrQuota != null ? forecastSummary.secondQtrQuota : 0;
               forecastSummary.thirdQtrQuota = forecastSummary.thirdQtrQuota != null ? forecastSummary.thirdQtrQuota : 0;
               forecastSummary.fourthQtrQuota = forecastSummary.fourthQtrQuota != null ? forecastSummary.fourthQtrQuota : 0;
                
               
               map<string, string> fiscalQtrMap = new map<String, string>();
               fiscalQtrMap.put('first', getQueryQtrFormat(firstQtr));
               fiscalQtrMap.put('second', getQueryQtrFormat(secondQtr));
               fiscalQtrMap.put('third', getQueryQtrFormat(thirdQtr));
               fiscalQtrMap.put('fourth', getQueryQtrFormat(fourthQtr));
               forecastSummary = loadPipeLineData(forecastSummary, userId, fiscalQtrMap, forecastTypeSet);
               return forecastSummary;
                }else{
                    return null;
                }
            }
            
            
            public static string getQueryQtrFormat(string qtr){
                string str = '';
                str = ''+qtr.substring(0,4) + '-' + qtr.substring(4,6);
                return str;
            }
            
            public static set<string> getForecastTypes(string forecastType){
                set<string> forecastTypeSet = new set<String>();
                if(String.isNotBlank(forecastType) && forecastType == 'all'){
                    forecastTypeSet.add('New');
                    forecastTypeSet.add('Upsell');
                    forecastTypeSet.add('Renewal');
                }else{
                    forecastTypeSet.add(forecastType);
                }
                return forecastTypeSet; 
            }
            
            
            public static forecastSummary loadPipeLineData(ForecastSummary forecastSummary, String userId, map<string, String> fiscalQtrMap, Set<String> forecastTypeSet){
                if(forecastSummary != null ){
                    List<Id> allUserIds = new List<Id>();
                    allUserIds.add(userId);
                    allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                    
                    set<string> oppForecastSet = new set<string>();
                    oppForecastSet.add('Upside');
                    oppForecastSet.add('Commit');
                    oppForecastSet.add('Pipeline');
                    oppForecastSet.add('Closed');
                    
                    
                    map<string, Decimal> fiscalQtrPipelineMap = new map<string, Decimal>();
                    map<string, Decimal> fiscalQtrClosedWonMap = new map<string, Decimal>();
                    map<string, Decimal> fiscalQtrTotalAmtMap = new map<string, Decimal>();
                    
                    String firstFiscalQtr = fiscalQtrMap.get('first');
                    
                    for(Opportunity opp : [Select Id, Amount, Fiscal_Period__c, Probability, IsClosed, StageName, ForecastCategoryName  from Opportunity Where OwnerId IN :allUserIds AND Forecast_Type__c IN: forecastTypeSet  AND Amount != null AND StageName != '0 - Initial Prospecting' AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND ForecastCategoryName IN: oppForecastSet]){ 
                            decimal tempAmt = 0;
                       // if((firstFiscalQtr == opp.Fiscal_Period__c && Opp.ForecastCategoryName != 'Pipeline') || firstFiscalQtr != opp.Fiscal_Period__c){
                            if(fiscalQtrPipelineMap != null && fiscalQtrPipelineMap.containsKey(opp.Fiscal_Period__c) ){
                                tempAmt = fiscalQtrPipelineMap.get(opp.Fiscal_Period__c);
                                tempAmt += opp.Amount;
                            }else{
                                tempAmt += opp.Amount;
                            }
                                fiscalQtrPipelineMap.put(opp.Fiscal_Period__c, tempAmt);
                        //}
                            
                        if(opp.StageName == label.Stage_6_Closed_Won){
                            decimal oppAmt = 0;
                            if(fiscalQtrClosedWonMap != null && fiscalQtrClosedWonMap.containsKey(opp.Fiscal_Period__c)){
                                oppAmt = fiscalQtrClosedWonMap.get(opp.Fiscal_Period__c);
                                    oppAmt += opp.Amount;
                                }else{
                                    oppAmt += opp.Amount;
                                }
                                fiscalQtrClosedWonMap.put(opp.Fiscal_Period__c, oppAmt);  
                            }
                            
                            if(opp.StageName == label.Stage_6_Closed_Won || opp.ForecastCategoryName == 'Upside' || opp.ForecastCategoryName == 'Commit'){
                              decimal oppAmt = 0;
                              if(fiscalQtrTotalAmtMap != null && fiscalQtrTotalAmtMap.containsKey(opp.Fiscal_Period__c)){
                                    oppAmt = fiscalQtrTotalAmtMap.get(opp.Fiscal_Period__c);
                                    oppAmt += opp.Amount;
                                }else{
                                    oppAmt += opp.Amount;
                                }
                                fiscalQtrTotalAmtMap.put(opp.Fiscal_Period__c, oppAmt);  
                            }
                            
                    }
                    for(string fiscalQtr : fiscalQtrMap.keySet()){
                        if(fiscalQtr == 'first'){
                            forecastSummary.firstQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('first'));
                            forecastSummary.firstQtrClosedWon = fiscalQtrClosedWonMap.containsKey(fiscalQtrMap.get('first'))?fiscalQtrClosedWonMap.get(fiscalQtrMap.get('first')):0;
                        }else if(fiscalQtr == 'second'){
                            forecastSummary.secondQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('second'));
                            forecastSummary.secondQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('second'));
                        }else if(fiscalQtr == 'third'){
                           forecastSummary.thirdQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('third'));
                           forecastSummary.thirdQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('third'));
                        }else if(fiscalQtr == 'fourth'){
                            forecastSummary.fourthQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('fourth'));
                            forecastSummary.fourthQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('fourth'));
                        }
                    }
                    
                    forecastSummary.firstQtrCoverage = getCoverage(forecastSummary.firstQtrPipeline, forecastSummary.firstQtrQuota);
                    forecastSummary.secondQtrCoverage = getCoverage(forecastSummary.secondQtrPipeline, forecastSummary.secondQtrQuota);
                    forecastSummary.thirdQtrCoverage = getCoverage(forecastSummary.thirdQtrPipeline, forecastSummary.thirdQtrQuota);
                    forecastSummary.fourthQtrCoverage = getCoverage(forecastSummary.fourthQtrPipeline, forecastSummary.fourthQtrQuota);
                    
                    forecastSummary.firstQtrQuotaPercnt = getCoverage(forecastSummary.firstQtrClosedWon, forecastSummary.firstQtrQuota);
                    forecastSummary.secondQtrQuotaPercnt = getCoverage(forecastSummary.secondQtrClosedWon, forecastSummary.secondQtrQuota);
                    forecastSummary.thirdQtrQuotaPercnt = getCoverage(forecastSummary.thirdQtrClosedWon, forecastSummary.thirdQtrQuota);
                    forecastSummary.fourthQtrQuotaPercnt = getCoverage(forecastSummary.fourthQtrClosedWon, forecastSummary.fourthQtrQuota);
                    forecastSummary.totalAmount = fiscalQtrTotalAmtMap.containsKey(fiscalQtrMap.get('first'))? fiscalQtrTotalAmtMap.get(fiscalQtrMap.get('first')):0;
                    
                    forecastSummary.quotaPercentage = getCoverage(forecastSummary.firstQtrClosedWon, forecastSummary.firstQtrQuota) * 100;
                    
                }
                return forecastSummary;
            }
            
            
            public static decimal getCoverage(Decimal pipeLine, Decimal quota){
                if(pipeLine == null || quota == null )
                    return 0;
                else if(quota < 1) 
                    return 0;
                else 
                    return (pipeLine/quota).setscale(2) ;    
            }
            
            public class ForecastSummary
            {
                public String UserId { get; set; }
                public String UserName { get; set; }
                
                
                public decimal firstQtrPipeline {get;set;}
                public decimal firstQtrQuota {get;set;}
                public decimal firstQtrCoverage {get;set;}
                public decimal firstQtrClosedWon {get;set;}
                public decimal firstQtrQuotaPercnt {get;set;}
                
                public decimal secondQtrPipeline {get;set;}
                public decimal secondQtrQuota {get;set;}
                public decimal secondQtrCoverage {get;set;}
                public decimal secondQtrClosedWon {get;set;}
                public decimal secondQtrQuotaPercnt {get;set;}
                
                
                public decimal thirdQtrPipeline {get;set;}
                public decimal thirdQtrQuota {get;set;}
                public decimal thirdQtrCoverage {get;set;}
                public decimal thirdQtrClosedWon {get;set;}
                public decimal thirdQtrQuotaPercnt {get;set;}
                
                public decimal fourthQtrPipeline {get;set;}
                public decimal fourthQtrQuota {get;set;}
                public decimal fourthQtrCoverage {get;set;}
                public decimal fourthQtrClosedWon {get;set;}
                public decimal fourthQtrQuotaPercnt {get;set;}
                
                public decimal totalAmount {get;set;}
                public decimal quotaPercentage{get; set;}   
                
               
            }
            
            
            @RemoteAction @ReadOnly
            public static list<sourceFunnelSummary> LoadSourceFunnelData(String forecastType, string userId){
                List<Id> allUserIds = new List<Id>();
                allUserIds.add(userId);
                allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                system.debug('# allUserIds : '+allUserIds);
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                
                
                Date qtrStartDate = getQtrStartDateTime().Date();
                date qtrEndDate = getQtrEndDate();
                
                set<String> oppSourceSet = new set<String>(); 
                
                list<sourceFunnelSummary> sourceFunnelList = new list<sourceFunnelSummary>();
                map<string, decimal > sourceClsdwonOppAmtMap = new map<string, decimal>();
                map<string, decimal > sourceCommitOppAmtMap = new map<string, decimal>();
                map<string, decimal > sourceUpsideOppAmtMap = new map<string, decimal>();
                weekInformations weekInfo = new weekInformations(Date.Today());
                
                map<string, decimal > lastWeekSourceClsdWonOppAmtMap = new map<string, decimal>();
                map<string, decimal > lastWeekSourceCommitOppAmtMap = new map<string, decimal>();
                map<string, decimal > lastWeekSourceUpsideOppAmtMap = new map<string, decimal>();
                
                lastWeekSourceClsdWonOppAmtMap.put('None', 0);
                lastWeekSourceCommitOppAmtMap.put('None', 0);
                lastWeekSourceUpsideOppAmtMap.put('None', 0);
                sourceClsdwonOppAmtMap.put('None', 0);
                sourceCommitOppAmtMap.put('None', 0);
                sourceUpsideOppAmtMap.put('None', 0);
                for( Schema.PicklistEntry f : Opportunity.Source__c.getDescribe().getPicklistValues()){
                    lastWeekSourceClsdWonOppAmtMap.put(f.getValue(), 0);
                    lastWeekSourceCommitOppAmtMap.put(f.getValue(), 0);
                    lastWeekSourceUpsideOppAmtMap.put(f.getValue(), 0);
                    sourceClsdwonOppAmtMap.put(f.getValue(), 0);
                    sourceCommitOppAmtMap.put(f.getValue(), 0);
                    sourceUpsideOppAmtMap.put(f.getValue(), 0);
                    oppSourceSet.add(f.getValue());
                }
                
                
                for(Opportunity opp : [Select Source__c, Amount, StageName, ForecastCategoryName,CloseDate  from Opportunity where Amount != null AND Forecast_Type__c IN: forecastTypeSet AND CloseDate >=: qtrStartDate AND CloseDate <=: qtrEndDate AND OwnerId IN: allUserIds AND StageName != '0 - Initial Prospecting']){
                    
                    string oppSource = opp.Source__c != null && opp.Source__c != '' ? opp.Source__c : 'None';
                    
                    decimal tempAmt = 0;
                    
                    if(opp.StageName == label.Stage_6_Closed_Won){
                        tempAmt = sourceClsdwonOppAmtMap.get(oppSource);
                        tempAmt += opp.Amount;
                        sourceClsdwonOppAmtMap.put(oppSource, tempAmt);
                        
                        if(opp.CloseDate < weekInfo.thisWeekStartdate){
                            tempAmt = 0;
                            tempAmt = lastWeekSourceClsdWonOppAmtMap.get(oppSource);
                            tempAmt += opp.Amount;
                            lastWeekSourceClsdWonOppAmtMap.put(oppSource, tempAmt);
                        }
                    }else if(opp.ForecastCategoryName == 'Commit'){
                        tempAmt = 0;
                        tempAmt = sourceCommitOppAmtMap.get(oppSource);
                        tempAmt += opp.Amount;
                        sourceCommitOppAmtMap.put(oppSource, tempAmt);
                    }else if (opp.ForecastCategoryName == 'Upside'){
                        tempAmt = 0;
                        tempAmt = sourceUpsideOppAmtMap.get(oppSource);
                        tempAmt += opp.Amount;
                        sourceUpsideOppAmtMap.put(oppSource, tempAmt);
                    }
                    
                }
                
                for(Opportunity_Snapshot__c opp : [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Created_Date__c, Snapshot_Date__c from Opportunity_Snapshot__c where Snapshot_Date__c =: weekInfo.thisWeekStartdate AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting' AND Amount__c != null AND Forecast_Type__c IN: forecastTypeSet]){
                    
                    string oppSource = opp.Source__c != null && opp.Source__c != '' ? opp.Source__c : 'None';
                    decimal tempAmt = 0;
                    if(opp.Forecast_Category__c == 'Commit'){
                        tempAmt = 0;
                        tempAmt = lastWeekSourceCommitOppAmtMap.get(oppSource);
                        tempAmt += opp.Amount__c;
                        lastWeekSourceCommitOppAmtMap.put(oppSource, tempAmt);
                    }else if (opp.Forecast_Category__c == 'Upside'){
                        tempAmt = 0;
                        tempAmt = lastWeekSourceUpsideOppAmtMap.get(oppSource);
                        tempAmt += opp.Amount__c;
                        lastWeekSourceUpsideOppAmtMap.put(oppSource, tempAmt);
                    }
                }
                
                
                list<string> oppSourceList = new list<string>();
                oppSourceList.addAll(oppSourceSet);
                oppSourceList.sort();
                oppSourceList.add('None');
                decimal totalClosedWon = 0;
                decimal totalUpside = 0;
                decimal totalCommit = 0;
                decimal totalClosedWonWOW = 0;
                decimal totalUpsideWOW = 0;
                decimal totalCommitWOW = 0;
                for(String str : oppSourceList){
                
                    sourceFunnelSummary tempSourceFunnelSumm = new sourceFunnelSummary();
                    tempSourceFunnelSumm.Source = str;
                    tempSourceFunnelSumm.closedwonQTD = sourceClsdwonOppAmtMap.get(str);
                    tempSourceFunnelSumm.commitQTD = sourceCommitOppAmtMap.get(str);
                    tempSourceFunnelSumm.upsideQTD = sourceUpsideOppAmtMap.get(str);
                    totalCommit += sourceCommitOppAmtMap.get(str);
                    totalUpside += sourceUpsideOppAmtMap.get(str);
                    totalClosedWon += sourceClsdwonOppAmtMap.get(str);
                    
                    tempSourceFunnelSumm.closedwonWOW = lastWeekSourceClsdWonOppAmtMap.get(str);
                    tempSourceFunnelSumm.commitWOW = lastWeekSourceCommitOppAmtMap.get(str);
                    tempSourceFunnelSumm.upsideWOW = lastWeekSourceUpsideOppAmtMap.get(str);
                    totalCommitWOW += lastWeekSourceCommitOppAmtMap.get(str);
                    totalUpsideWOW += lastWeekSourceUpsideOppAmtMap.get(str);
                    totalClosedWonWOW += lastWeekSourceClsdWonOppAmtMap.get(str);
                    
                    /*
                    if(tempSourceFunnelSumm.closedwonQTD > 0 && lastWeekSourceClsdWonOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.closedwonWOW = 100;
                    }else if(tempSourceFunnelSumm.closedwonQTD == 0 && lastWeekSourceClsdWonOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.closedwonWOW = 0;
                    }else{
                        tempSourceFunnelSumm.closedwonWOW = ((tempSourceFunnelSumm.closedwonQTD - lastWeekSourceClsdWonOppAmtMap.get(str))/lastWeekSourceClsdWonOppAmtMap.get(str)) * 100;
                    }
                    
                    if(tempSourceFunnelSumm.commitQTD > 0 && lastWeekSourceCommitOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.commitWOW = 100;
                    }else if(tempSourceFunnelSumm.commitQTD == 0 && lastWeekSourceCommitOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.commitWOW = 0;
                    }else{
                        tempSourceFunnelSumm.commitWOW = ((tempSourceFunnelSumm.commitQTD - lastWeekSourceCommitOppAmtMap.get(str))/lastWeekSourceCommitOppAmtMap.get(str)) * 100;
                    }
                    
                    if(tempSourceFunnelSumm.upsideQTD > 0 && lastWeekSourceUpsideOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.upsideWOW = 100;
                    }else if(tempSourceFunnelSumm.upsideQTD == 0 && lastWeekSourceUpsideOppAmtMap.get(str) == 0){
                        tempSourceFunnelSumm.upsideWOW = 0;
                    }else{
                        tempSourceFunnelSumm.upsideWOW = ((tempSourceFunnelSumm.closedwonQTD - lastWeekSourceUpsideOppAmtMap.get(str))/lastWeekSourceUpsideOppAmtMap.get(str)) * 100;
                    }
                    */
                    
                    //if(tempSourceFunnelSumm != null)
                        sourceFunnelList.add(tempSourceFunnelSumm);
                   
                }
                
                for(sourceFunnelSummary tempSourceFunnelSumm : sourceFunnelList){
                    tempSourceFunnelSumm.totalClosedWon = totalClosedWon;
                    tempSourceFunnelSumm.totalCommit = totalCommit;
                    tempSourceFunnelSumm.totalUpside = totalUpside;
                    
                    tempSourceFunnelSumm.totalClosedWonWOW = totalClosedWonWOW;
                    tempSourceFunnelSumm.totalCommitWOW = totalCommitWOW;
                    tempSourceFunnelSumm.totalUpsideWOW = totalUpsideWOW;
                }
                
                
                return sourceFunnelList;
            }
            
            public static DateTime getQtrStartDateTime(){
                date d = date.today();
                map<integer, integer> monthQtrMap = new map<integer, integer>();
                monthQtrMap.put(8, 8);
                monthQtrMap.put(9, 8);
                monthQtrMap.put(10, 8);
                monthQtrMap.put(11, 11);
                monthQtrMap.put(12, 11);
                monthQtrMap.put(1, 11);
                monthQtrMap.put(2, 2);
                monthQtrMap.put(3, 2);
                monthQtrMap.put(4, 2);
                monthQtrMap.put(5, 5);
                monthQtrMap.put(6, 5);
                monthQtrMap.put(7, 5);
                
                integer dateYear = d.Year();
                if(d.month() == 1 )
                    dateYear = dateYear - 1;
                DateTime qtrStartDate = DateTime.newinstance(dateYear, monthQtrMap.get(d.month()), 1,0,0,0);
                return qtrStartDate;
            }
            
            public static date getQtrEndDate(){
                date d = date.today();
                map<integer, integer> monthQtrMap = new map<integer, integer>();
                monthQtrMap.put(8, 8);
                monthQtrMap.put(9, 8);
                monthQtrMap.put(10, 8);
                monthQtrMap.put(11, 11);
                monthQtrMap.put(12, 11);
                monthQtrMap.put(1, 11);
                monthQtrMap.put(2, 2);
                monthQtrMap.put(3, 2);
                monthQtrMap.put(4, 2);
                monthQtrMap.put(5, 5);
                monthQtrMap.put(6, 5);
                monthQtrMap.put(7, 5);
                
                map<integer, integer> monthEndQtrMap = new map<integer, integer>();
                monthEndQtrMap.put(8, 10);
                monthEndQtrMap.put(11, 1);
                monthEndQtrMap.put(2, 4);
                monthEndQtrMap.put(5, 7);
                
                map<integer, integer> monthEndDaysMap = new map<integer, integer>();
                monthEndDaysMap.put(8, 31);
                monthEndDaysMap.put(11, 31);
                monthEndDaysMap.put(2, 30);
                monthEndDaysMap.put(5, 31);
                
                date qtrEndDate;
                
                if(monthEndQtrMap.get(monthQtrMap.get(d.month())) == 1)
                    if(d.month() == 11 || d.month() == 12){
                        qtrEndDate = Date.newinstance(d.Year() + 1, monthEndQtrMap.get(monthQtrMap.get(d.month())), monthEndDaysMap.get(monthQtrMap.get(d.month())));
                    }else{
                        qtrEndDate = Date.newinstance(d.Year(), monthEndQtrMap.get(monthQtrMap.get(d.month())), monthEndDaysMap.get(monthQtrMap.get(d.month())));   
                    }
                    
                else
                    qtrEndDate = Date.newinstance(d.Year(), monthEndQtrMap.get(monthQtrMap.get(d.month())), monthEndDaysMap.get(monthQtrMap.get(d.month())));
                return qtrEndDate;
            }
            
            public class sourceFunnelSummary{
                public string source{get;set;}
                public decimal closedwonQTD {get;set;}
                public decimal closedwonWOW {get;set;}
                public decimal totalClosedWon {get;set;}
                public decimal totalClosedWonWOW {get;set;}
                public decimal commitQTD {get;set;}
                public decimal commitWOW {get;set;}
                public decimal totalCommit {get;set;}
                public decimal totalCommitWOW {get;set;}
                public decimal upsideQTD {get;set;}
                public decimal upsideWOW {get;set;}
                public decimal totalUpside {get;set;}
                public decimal totalUpsideWOW {get;set;}
                public sourceFunnelSummary(){}
            }
            
            public class weekInformations{
                public date thisWeekStartdate{get; set;}
                public date thisWeekEnddate{get; set;}
                public date lastWeekStartdate{get; set;}
                public date lastWeekEnddate{get; set;}
                public date PriorWeekStartdate{get; set;}
                public date PriorWeekEnddate{get; set;}
                public date PriorToPriorWeekStartdate{get; set;}
                public date PriorToPriorWeekEnddate{get; set;}
                public weekInformations( Date oppDate){
                    Date tempDate = oppDate.toStartOfWeek();
                    this.thisWeekStartdate = tempDate.addDays(-2);
                    this.thisWeekEnddate = thisWeekStartdate.addDays(6);
                    this.lastWeekStartdate = thisWeekStartdate.addDays(-7);
                    this.lastWeekEnddate = thisWeekStartdate.addDays(-1);
                    this.PriorWeekStartdate = lastWeekStartdate.addDays(-7);
                    this.PriorWeekEnddate = lastWeekStartdate.addDays(-1);
                    this.PriorToPriorWeekStartdate = PriorWeekStartdate.addDays(-7);
                    this.PriorToPriorWeekEnddate = PriorWeekStartdate.addDays(-1);
                }
            }
            
            
            
            public class funnelChangeWOWSummary{
                public string Stage{get;set;}
                public decimal thisWeek {get;set;}
                public decimal lastWeek {get;set;}
                public decimal priorWeek {get;set;}
                public decimal QTD {get;set;}
                public funnelChangeWOWSummary(){}
            }
            
            @RemoteAction @ReadOnly
            public static list<funnelChangeWOWSummary> LoadFunnelWOWChange(String forecastType, string userId){
                list<funnelChangeWOWSummary> tempFunnelChangeWOWSummList = new list<funnelChangeWOWSummary>();
                List<Id> allUserIds = new List<Id>();
                allUserIds.add(userId);
                allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                tempFunnelChangeWOWSummList.add(getFunnelChange('Closed Won', allUserIds, forecastType));
                tempFunnelChangeWOWSummList.add(getFunnelChange('Commit', allUserIds, forecastType));
                tempFunnelChangeWOWSummList.add(getFunnelChange('Upside', allUserIds, forecastType));
                tempFunnelChangeWOWSummList.add(getFunnelChange('Lost', allUserIds, forecastType));
                return tempFunnelChangeWOWSummList;
            }
            
            public static funnelChangeWOWSummary getFunnelChange(string oppType,list<Id> allUserIds,  string foreCastType){
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                
                funnelChangeWOWSummary tempFunnelChangeWOW = new funnelChangeWOWSummary();
                weekInformations weeksInfo = new weekInformations(Date.Today());
                list<Opportunity> oppList = new List<Opportunity>();
                list<Opportunity_Snapshot__c> oppSnapshotList = new List<Opportunity_Snapshot__c>();
                
                Map<String, Decimal> thisWeekAmtMap = new Map<String, Decimal>();
                Map<String, Decimal> lastWeekAmtMap = new Map<String, Decimal>();
                Map<String, Decimal> priorWeekAmtMap = new Map<String, Decimal>();
                Map<String, Decimal> previosWeekAmtMap = new Map<String, Decimal>();
                Date qtrStartDate = getQtrStartDateTime().Date();
                
                map<integer, integer> monthEndDaysMap = new map<integer, integer>();
                monthEndDaysMap.put(8, 31);
                monthEndDaysMap.put(11, 31);
                monthEndDaysMap.put(2, 30);
                monthEndDaysMap.put(5, 31);
                
                date qtrEndDate = getQtrEndDate();
                
                
                if(oppType == 'Closed Won'){
                    oppList = [Select id, StageName, ForecastCategoryName, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND StageName =: label.Stage_6_Closed_Won AND CloseDate >=: qtrStartDate AND CloseDate <=: qtrEndDate AND Amount != null AND StageName != '0 - Initial Prospecting'];
                    
                }   
                if(oppType == 'Commit'){
                    oppList = [Select id, StageName, ForecastCategoryName, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND ForecastCategoryName =: 'Commit' AND CloseDate >=: qtrStartDate AND CloseDate <=: qtrEndDate  AND Amount != null AND StageName != '0 - Initial Prospecting'];
                    
                    oppSnapShotList = [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Created_Date__c,Snapshot_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Snapshot_Date__c >=: weeksInfo.PriorWeekStartdate AND Forecast_Category__c=: 'Commit' AND Close_Date__c >=: qtrStartDate AND Close_Date__c <=: qtrEndDate];
                }
                if(oppType == 'Upside'){
                    
                    oppList = [Select id, StageName, ForecastCategoryName, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND ForecastCategoryName =: 'Upside' AND CloseDate >=: qtrStartDate AND CloseDate <=: qtrEndDate AND Amount != null AND StageName != '0 - Initial Prospecting'];
                    
                    oppSnapShotList = [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Created_Date__c,Snapshot_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Snapshot_Date__c >=: weeksInfo.PriorWeekStartdate AND Forecast_Category__c=: 'Upside' AND Close_Date__c >=: qtrStartDate AND Close_Date__c <=: qtrEndDate];
                }
                if(oppType == 'Lost'){
                    
                    oppList = [Select id, StageName,Sub_Stage__c, ForecastCategoryName, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND (StageName =:label.Stage_7_Closed_Lost AND (Sub_Stage__c = :Label.SubStage_Closed_With_No_Decision OR Sub_Stage__c = :Label.SubStage_Closed_Lost) ) /* OR StageName =:'12 - Closed With No Decision' */ AND CloseDate >=: qtrStartDate AND CloseDate <=: qtrEndDate AND Amount != null AND StageName != '0 - Initial Prospecting'];
                    
                    oppSnapShotList = [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Opportunity__c, Created_Date__c,Snapshot_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Snapshot_Date__c >=: weeksInfo.PriorWeekStartdate AND (Stage__c = :label.Stage_7_Closed_Lost /*:'11 - Closed Lost' OR Stage__c =:'12 - Closed With No Decision'*/ )AND Close_Date__c >=: qtrStartDate AND Close_Date__c <=: qtrEndDate];
                }
                
                decimal tempAmt = 0;
                tempFunnelChangeWOW.QTD = 0;
                thisWeekAmtMap.put(oppType, tempAmt);
                lastWeekAmtMap.put(oppType, tempAmt);
                priorWeekAmtMap.put(oppType, tempAmt);
                previosWeekAmtMap.put(oppType, tempAmt);
                
                for(Opportunity opp : oppList){
                    tempFunnelChangeWOW.QTD += opp.Amount;
                    //if(opp.CloseDate <= weeksInfo.thisWeekEnddate){
                        tempAmt = 0;
                        tempAmt = thisWeekAmtMap.get(oppType);
                        tempAmt += opp.Amount;
                        thisWeekAmtMap.put(oppType, tempAmt);
                    //}
                    
                    if(oppType == 'Closed Won'){
                        if(opp.CloseDate < weeksInfo.thisWeekStartdate){
                            tempAmt = 0;
                            tempAmt = lastWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount;
                            lastWeekAmtMap.put(oppType, tempAmt);
                        }
                        
                        if(opp.CloseDate < weeksInfo.lastWeekStartdate){
                            tempAmt = 0;
                            tempAmt = priorWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount;
                            priorWeekAmtMap.put(oppType, tempAmt);
                        }
                        
                        if (opp.CloseDate < weeksInfo.PriorWeekStartdate){
                            tempAmt = 0;
                            tempAmt = previosWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount;
                            previosWeekAmtMap.put(oppType, tempAmt);
                        }   
                    }
                }
                
                for(Opportunity_Snapshot__c opp : oppSnapshotList){
                        if(opp.Snapshot_Date__c == weeksInfo.thisWeekStartdate){
                            tempAmt = 0;
                            tempAmt = lastWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount__c;
                            lastWeekAmtMap.put(oppType, tempAmt);
                        }else if(opp.Snapshot_Date__c == weeksInfo.lastWeekStartdate){
                            tempAmt = 0;
                            tempAmt = priorWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount__c;
                            priorWeekAmtMap.put(oppType, tempAmt);
                    
                        }else if (opp.Snapshot_Date__c == weeksInfo.PriorWeekStartdate){
                            tempAmt = 0;
                            tempAmt = previosWeekAmtMap.get(oppType);
                            tempAmt += opp.Amount__c;
                            previosWeekAmtMap.put(oppType, tempAmt);
                        }
                }   
                
            tempFunnelChangeWOW.Stage = oppType;
            tempFunnelChangeWOW.thisWeek = thisWeekAmtMap.get(oppType);
            tempFunnelChangeWOW.lastWeek = lastWeekAmtMap.get(oppType);
            tempFunnelChangeWOW.priorWeek = priorWeekAmtMap.get(oppType);

            /*
            if(thisWeekAmtMap.get(oppType) > 0 && lastWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.thisWeek = 100;
            }else if(thisWeekAmtMap.get(oppType) == 0 && lastWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.thisWeek = 0;
            }else{
                tempFunnelChangeWOW.thisWeek = ((thisWeekAmtMap.get(oppType) - lastWeekAmtMap.get(oppType))/lastWeekAmtMap.get(oppType)) * 100;
            }
            

            if(lastWeekAmtMap.get(oppType) > 0 && priorWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.lastWeek = 100;
            }else if(lastWeekAmtMap.get(oppType) == 0 && priorWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.lastWeek = 0;
            }else{
                tempFunnelChangeWOW.lastWeek = ((lastWeekAmtMap.get(oppType) - priorWeekAmtMap.get(oppType))/priorWeekAmtMap.get(oppType)) * 100;
            }
            
            if(priorWeekAmtMap.get(oppType) > 0 && previosWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.priorWeek = 100;
            }else if(priorWeekAmtMap.get(oppType) == 0 && previosWeekAmtMap.get(oppType) == 0){
                tempFunnelChangeWOW.priorWeek = 0;
            }else{
                tempFunnelChangeWOW.priorWeek = ((priorWeekAmtMap.get(oppType) - previosWeekAmtMap.get(oppType))/previosWeekAmtMap.get(oppType)) * 100;
            }
            */
            return tempFunnelChangeWOW;
            }
            
            
            
            public class WOWFunnelDistribution{
                public String oppStage { get; set; }
                public decimal totalAmount {get; set;}
                public boolean isPercentage {get; set;}
                public string currentWeekStartDate {get;set;}
                public decimal qtrQuota { get; set; }
                public decimal week1 { get; set; }
                public decimal week2 { get; set; }
                public decimal week3 { get; set; }
                public decimal week4 { get; set; }
                public decimal week5 { get; set; }
                public decimal week6 { get; set; }
                public decimal week7 { get; set; }
                public decimal week8 { get; set; }
                public decimal week9 { get; set; }
                public decimal week10 { get; set; }
                public decimal week11 { get; set; }
                public decimal week12 { get; set; }
                public decimal week13 { get; set; }
                
                public String week1StartDate { get; set; }
                public String week2StartDate { get; set; }
                public String week3StartDate { get; set; }
                public String week4StartDate { get; set; }
                public String week5StartDate { get; set; }
                public String week6StartDate { get; set; }
                public String week7StartDate { get; set; }
                public String week8StartDate { get; set; }
                public String week9StartDate { get; set; }
                public String week10StartDate { get; set; }
                public String week11StartDate { get; set; }
                public String week12StartDate { get; set; }
                public String week13StartDate { get; set; }
                
                public String week1EndDate { get; set; }
                public String week2EndDate { get; set; }
                public String week3EndDate { get; set; }
                public String week4EndDate { get; set; }
                public String week5EndDate { get; set; }
                public String week6EndDate { get; set; }
                public String week7EndDate { get; set; }
                public String week8EndDate { get; set; }
                public String week9EndDate { get; set; }
                public String week10EndDate { get; set; }
                public String week11EndDate { get; set; }
                public String week12EndDate { get; set; }
                public String week13EndDate { get; set; }
                
                public WOWFunnelDistribution(){}
            }
            
            public static date getDateFromString(string dateString){
                list<String> dateStringValList = dateString.split('/');
                date tempDate = Date.newInstance(integer.ValueOf(dateStringValList[2]), integer.ValueOf(dateStringValList[0]), integer.ValueOf(dateStringValList[1]));
                return tempDate ;
            } 
            
            
            @RemoteAction @ReadOnly
            public static list<WOWFunnelDistribution> loadWOWFunnelDistribution(String forecastType, string userId, String fiscalQtr){
                string year = fiscalQtr.substring(0,4);
                integer qtrNo = integer.valueOf(fiscalQtr.substring(5,6));
                decimal quota = 0;
                
                set<String> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(foreCastType);
                for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c =: fiscalQtr AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                    if(salesQuota.QuotaAmount__c != null)
                        quota += salesQuota.QuotaAmount__c; 
                }   
                
                
                List<Period> periods = [SELECT Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name FROM Period WHERE Type = 'Quarter' AND FiscalYearSettings.Name =: year AND Number =:qtrNo LIMIT 1];
                
                
                list<WOWFunnelDistribution> tempWOWFunnelDistributionList = new list<WOWFunnelDistribution>();
                WOWFunnelDistribution temWOWFunnelDistribution = new WOWFunnelDistribution();
                List<Id> allUserIds = new List<Id>();
                allUserIds.add(userId);
                allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                
                tempWOWFunnelDistributionList.add(getWOWFunnelDistChange('Closed Won', allUserIds, forecastType, periods[0].StartDate, periods[0].EndDate));
                
                tempWOWFunnelDistributionList.add(getWOWFunnelDistChange('Commit', allUserIds, forecastType, periods[0].StartDate, periods[0].EndDate));
                tempWOWFunnelDistributionList.add(getWOWFunnelDistChange('Upside', allUserIds, forecastType, periods[0].StartDate, periods[0].EndDate));
                if(system.today() < periods[0].StartDate)
                    tempWOWFunnelDistributionList.add(getWOWFunnelDistChange('Pipeline', allUserIds, forecastType, periods[0].StartDate, periods[0].EndDate));
                temWOWFunnelDistribution.oppStage = '% Total Funnel';
                temWOWFunnelDistribution.isPercentage = true;
                
                for(WOWFunnelDistribution wowFunnelDist : tempWOWFunnelDistributionList){
                    temWOWFunnelDistribution.totalAmount = temWOWFunnelDistribution.totalAmount != null ? temWOWFunnelDistribution.totalAmount + wowFunnelDist.totalAmount : wowFunnelDist.totalAmount;
                    temWOWFunnelDistribution.Week1 = temWOWFunnelDistribution.week1 != null ? temWOWFunnelDistribution.week1 + wowFunnelDist.week1 : wowFunnelDist.Week1;
                    temWOWFunnelDistribution.Week2 = temWOWFunnelDistribution.week2 != null ? temWOWFunnelDistribution.week2 + wowFunnelDist.week2 : wowFunnelDist.Week2;
                    temWOWFunnelDistribution.Week3 = temWOWFunnelDistribution.week3 != null ? temWOWFunnelDistribution.week3 + wowFunnelDist.week3 : wowFunnelDist.Week3;
                    temWOWFunnelDistribution.Week4 = temWOWFunnelDistribution.week4 != null ? temWOWFunnelDistribution.week4 + wowFunnelDist.week4 : wowFunnelDist.Week4;
                    temWOWFunnelDistribution.Week5 = temWOWFunnelDistribution.week5 != null ? temWOWFunnelDistribution.week5 + wowFunnelDist.week5 : wowFunnelDist.Week5;
                    temWOWFunnelDistribution.Week6 = temWOWFunnelDistribution.week6 != null ? temWOWFunnelDistribution.week6 + wowFunnelDist.week6 : wowFunnelDist.Week6;
                    temWOWFunnelDistribution.Week7 = temWOWFunnelDistribution.week7 != null ? temWOWFunnelDistribution.week7 + wowFunnelDist.week7 : wowFunnelDist.Week7;
                    temWOWFunnelDistribution.Week8 = temWOWFunnelDistribution.week8 != null ? temWOWFunnelDistribution.week8 + wowFunnelDist.week8 : wowFunnelDist.Week8;
                    temWOWFunnelDistribution.Week9 = temWOWFunnelDistribution.week9 != null ? temWOWFunnelDistribution.week9 + wowFunnelDist.week9 : wowFunnelDist.Week9;
                    temWOWFunnelDistribution.Week10 = temWOWFunnelDistribution.week10 != null ? temWOWFunnelDistribution.week10 + wowFunnelDist.week10 : wowFunnelDist.Week10;
                    temWOWFunnelDistribution.Week11 = temWOWFunnelDistribution.week11 != null ? temWOWFunnelDistribution.week11 + wowFunnelDist.week11 : wowFunnelDist.Week11;
                    temWOWFunnelDistribution.Week12 = temWOWFunnelDistribution.week12 != null ? temWOWFunnelDistribution.week12 + wowFunnelDist.week12 : wowFunnelDist.Week12;
                    temWOWFunnelDistribution.Week13 = temWOWFunnelDistribution.week13 != null ? temWOWFunnelDistribution.week13 + wowFunnelDist.week13 : wowFunnelDist.Week13;
                }
                    temWOWFunnelDistribution.Week1 = ((temWOWFunnelDistribution.Week1/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week2 = ((temWOWFunnelDistribution.Week2/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount :1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week3 = ((temWOWFunnelDistribution.Week3/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week4 = ((temWOWFunnelDistribution.Week4/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week5 = ((temWOWFunnelDistribution.Week5/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week6 = ((temWOWFunnelDistribution.Week6/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week7 = ((temWOWFunnelDistribution.Week7/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week8 = ((temWOWFunnelDistribution.Week8/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week9 = ((temWOWFunnelDistribution.Week9/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week10 = ((temWOWFunnelDistribution.Week10/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week11 = ((temWOWFunnelDistribution.Week11/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week12 = ((temWOWFunnelDistribution.Week12/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.Week13 = ((temWOWFunnelDistribution.Week13/(temWOWFunnelDistribution.totalAmount > 0 ? temWOWFunnelDistribution.totalAmount:1 ))*100).setScale(2);
                    temWOWFunnelDistribution.totalAmount = 100;
                tempWOWFunnelDistributionList.add(temWOWFunnelDistribution);
                
                
                temWOWFunnelDistribution = new WOWFunnelDistribution();
                temWOWFunnelDistribution.oppStage = '% Total Quota';
                temWOWFunnelDistribution.isPercentage = true;
                
                system.debug('# tempWOWFunnelDistributionList[0] : '+tempWOWFunnelDistributionList[0]);
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week1StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week1 = quota > 0 ? (tempWOWFunnelDistributionList[0].week1/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? (tempWOWFunnelDistributionList[0].week1/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week1 = 0;                 
                
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week2StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week2 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week2=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week3StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week3 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3)/quota)*100:0;
                
                }else
                    temWOWFunnelDistribution.week3=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week4StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week4 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4)/quota)*100:0;
                
                }else
                    temWOWFunnelDistribution.week4=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week5StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week5 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5)/quota)*100:0;
                
                }else
                    temWOWFunnelDistribution.week5=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week6StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week6 = quota > 0 ? (( tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? (( tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6)/quota)*100:0;
                
                }else
                    temWOWFunnelDistribution.week6=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week7StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week7 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7)/quota)*100:0;
                
                }else
                    temWOWFunnelDistribution.week7=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week8StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week8 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week8=0;
                
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week9StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week9 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week9=0;
                
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week10StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week10= quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount= temWOWFunnelDistribution.week10;
                }else
                    temWOWFunnelDistribution.week10=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week11StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week11 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week11=0;
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week12StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week12 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11 + tempWOWFunnelDistributionList[0].week12)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11 + tempWOWFunnelDistributionList[0].week12)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week12=0;
                
                If(tempWOWFunnelDistributionList[0].currentWeekStartDate == '' || getDateFromString(tempWOWFunnelDistributionList[0].week13StartDate) <= getDateFromString(tempWOWFunnelDistributionList[0].currentWeekStartDate)){
                    temWOWFunnelDistribution.week13 = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11 + tempWOWFunnelDistributionList[0].week12 + tempWOWFunnelDistributionList[0].week13)/quota)*100:0;
                    temWOWFunnelDistribution.totalAmount = quota > 0 ? ((tempWOWFunnelDistributionList[0].week1 + tempWOWFunnelDistributionList[0].week2 + tempWOWFunnelDistributionList[0].week3 + tempWOWFunnelDistributionList[0].week4/quota + tempWOWFunnelDistributionList[0].week5 + tempWOWFunnelDistributionList[0].week6 + tempWOWFunnelDistributionList[0].week7 + tempWOWFunnelDistributionList[0].week8 + tempWOWFunnelDistributionList[0].week9 + tempWOWFunnelDistributionList[0].week10 + tempWOWFunnelDistributionList[0].week11 + tempWOWFunnelDistributionList[0].week12 + tempWOWFunnelDistributionList[0].week13)/quota)*100:0;
                }else
                    temWOWFunnelDistribution.week13=0;
                
                
                tempWOWFunnelDistributionList.add(temWOWFunnelDistribution);
                
                tempWOWFunnelDistributionList.add(getWOWFunnelDistChange('Lost', allUserIds, forecastType, periods[0].StartDate, periods[0].EndDate));
                return tempWOWFunnelDistributionList;
            }
            
            public static map<string, integer> getAddDaysMap( string startDayOfWeek){
                map<string, integer> addDaysForEndDateMap = new map<String, integer>();
                
                if((startDayOfWeek == 'Friday')){
                    addDaysForEndDateMap.put('Saturday',5);
                    addDaysForEndDateMap.put('Sunday',4);
                    addDaysForEndDateMap.put('Monday',3);
                    addDaysForEndDateMap.put('Tuesday',2);
                    addDaysForEndDateMap.put('Wednesday',1);
                    addDaysForEndDateMap.put('Thrusday',0);
                }else if((startDayOfWeek == 'Saturday')){
                    addDaysForEndDateMap.put('Sunday',5);
                    addDaysForEndDateMap.put('Monday',4);
                    addDaysForEndDateMap.put('Tuesday',3);
                    addDaysForEndDateMap.put('Wednesday',2);
                    addDaysForEndDateMap.put('Thrusday',1);
                    addDaysForEndDateMap.put('Friday',0);
                }else if((startDayOfWeek == 'Sunday')){
                    addDaysForEndDateMap.put('Monday',5);
                    addDaysForEndDateMap.put('Tuesday',4);
                    addDaysForEndDateMap.put('Wednesday',3);
                    addDaysForEndDateMap.put('Thrusday',2);
                    addDaysForEndDateMap.put('Friday',1);
                    addDaysForEndDateMap.put('Saturday',0);
                }else if((startDayOfWeek == 'Monday')){
                    addDaysForEndDateMap.put('Tuesday',5);
                    addDaysForEndDateMap.put('Wednesday',4);
                    addDaysForEndDateMap.put('Thrusday',3);
                    addDaysForEndDateMap.put('Friday',2);
                    addDaysForEndDateMap.put('Saturday',1);
                    addDaysForEndDateMap.put('Sunday',0);
                }else if((startDayOfWeek == 'Tuesday')){
                    addDaysForEndDateMap.put('Wednesday',5);
                    addDaysForEndDateMap.put('Thrusday',4);
                    addDaysForEndDateMap.put('Friday',3);
                    addDaysForEndDateMap.put('Saturday',2);
                    addDaysForEndDateMap.put('Sunday',1);
                    addDaysForEndDateMap.put('Monday',0);
                }else if((startDayOfWeek == 'Wednesday')){
                    addDaysForEndDateMap.put('Thrusday',5);
                    addDaysForEndDateMap.put('Friday',4);
                    addDaysForEndDateMap.put('Saturday',3);
                    addDaysForEndDateMap.put('Sunday',2);
                    addDaysForEndDateMap.put('Monday',1);
                    addDaysForEndDateMap.put('Tuesday',0);
                }else{
                    addDaysForEndDateMap.put('Friday',5);
                    addDaysForEndDateMap.put('Saturday',4);
                    addDaysForEndDateMap.put('Sunday',3);
                    addDaysForEndDateMap.put('Monday',2);
                    addDaysForEndDateMap.put('Tuesday',1);
                    addDaysForEndDateMap.put('Wednesday',0);
                }   
                return addDaysForEndDateMap;
            }
            
            public static WOWFunnelDistribution getWOWFunnelDistChange(string oppStage, list<id> allUserIds, string forecastType , Date startDate, Date qtrEndDate){
                WOWFunnelDistribution tempWOWFunnelDist = new WOWFunnelDistribution();
                
                list<Opportunity> oppList = new list<Opportunity> ();
                list<Opportunity> oppSnapshotList = new list<Opportunity> ();
                
                set<string> forecastTypeSet = new set<string>();
                forecastTypeSet = getForecastTypes(foreCastType);
                
                //date qtrEndDate = getQtrEndDate();
                
                DateTime qtrStartDate =  DateTime.newInstance(startDate.year(), startDate.Month(), startDate.day(), 0,0,0);
                String dayOfWeek = qtrStartDate.format('EEEE');
                map<integer, date> weekNoAndStartDateMap = new map<integer, date>();
                map<integer, date> weekNoAndEndDateMap = new map<integer, date>();
                date firstEndDate;
                date firstStartDate;

                String startDayOfWeek = ZscalerSetting__c.getValues('StartingDayOfWeek').Value__c;
                firstStartDate = qtrStartDate.Date();
                map<string, integer> addDaysForEndDateMap = new map<String, integer>();
                addDaysForEndDateMap = getAddDaysMap(startDayOfWeek);
                
                integer maxNoOfWeeks = 1;
                if(!dayOfWeek.equalsIgnoreCase(startDayOfWeek) ){
                    firstEndDate = firstStartDate.addDays(addDaysForEndDateMap.get(dayOfWeek));
                    
                }else{
                    firstStartDate = qtrStartDate.Date();
                    firstEndDate = firstStartDate.addDays(6);
                }

                weekNoAndStartDateMap.put(1,firstStartDate);
                weekNoAndEndDateMap.put(1,firstEndDate);
                
                for(integer i = 2; i < 14; i++){
                    date tempStartDate;
                    date tempEndDate;
                    if(weekNoAndStartDateMap.get(i-1) <= qtrEndDate){
                        tempStartDate = weekNoAndEndDateMap.get(i-1).addDays(1);
                        tempEndDate = tempStartDate.addDays(6);
                        weekNoAndStartDateMap.put(i,tempStartDate);
                        if(i == 13)
                            weekNoAndEndDateMap.put(i,qtrEndDate);
                        else 
                            weekNoAndEndDateMap.put(i,tempEndDate);
                        maxNoOfWeeks = i;
                    }
                }
                
                integer currentWeekNo = getWeekNo(system.Today(), weekNoAndEndDateMap, weekNoAndStartDateMap);
                tempWOWFunnelDist.currentWeekStartDate = getDateString(weekNoAndStartDateMap.get(currentWeekNo));
                if(oppStage == 'Closed Won'){
                    oppList = [Select id, StageName, ForecastCategoryName, Amount, CreatedDate,CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND StageName =: label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/ AND CloseDate >=: qtrStartDate.date() AND CloseDate <=: qtrEndDate  AND Amount != null AND StageName != '0 - Initial Prospecting'];
                    
                }   
                if(oppStage == 'Commit'){
                    oppList = [Select id, StageName, ForecastCategoryName, Amount, CreatedDate,CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND ForecastCategoryName =: 'Commit' AND CloseDate >=: qtrStartDate.date() AND CloseDate <=: qtrEndDate  AND Amount != null AND StageName != '0 - Initial Prospecting'];
                
                }
                if(oppStage == 'Upside'){
                    oppList = [Select id, StageName, ForecastCategoryName, CreatedDate, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND ForecastCategoryName =: 'Upside' AND CloseDate >=: qtrStartDate.date() AND CloseDate <=: qtrEndDate AND Amount != null  AND Amount != null AND StageName != '0 - Initial Prospecting'];
                }
                if(oppStage == 'Pipeline'){
                    oppList = [Select id, StageName, ForecastCategoryName, CreatedDate, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND ForecastCategoryName =: 'Pipeline' AND CloseDate >=: qtrStartDate.date() AND CloseDate <=: qtrEndDate AND Amount != null  AND Amount != null AND StageName != '0 - Initial Prospecting'];
                }
                if(oppStage == 'Lost'){
                    oppList = [Select id, StageName, CreatedDate,Sub_Stage__c, ForecastCategoryName, Amount, CloseDate from Opportunity Where Forecast_Type__c IN: forecastTypeSet AND OwnerId IN: allUserIds AND (StageName =:label.Stage_7_Closed_Lost AND (Sub_Stage__c = :Label.SubStage_Closed_With_No_Decision OR Sub_Stage__c = :Label.SubStage_Closed_Lost) ) /* OR StageName =:'12 - Closed With No Decision'*/  AND CloseDate >=: qtrStartDate.date() AND CloseDate <=: qtrEndDate AND Amount != null AND StageName != '0 - Initial Prospecting'];
                }
                tempWOWFunnelDist.oppStage = oppStage;
                tempWOWFunnelDist.totalAmount = 0;
                map<integer, Decimal> weekNoAmtMap = new map<integer, Decimal>();
                
                
                for(Opportunity opp : oppList){
                    decimal amt = 0;
                    for(integer i = 1; i< 14; i++){
                        if(opp.CloseDate >= weekNoAndStartDateMap.get(i) && opp.CloseDate <= weekNoAndEndDateMap.get(i)){
                            if(weekNoAmtMap != null && weekNoAmtMap.containsKey(i)){
                                amt = weekNoAmtMap.get(i);
                                amt += opp.Amount;
                                weekNoAmtMap.put(i, amt);
                            }else{
                                amt += opp.Amount;
                                weekNoAmtMap.put(i, amt);
                            }
                        }
                    }
                }
                
                
                tempWOWFunnelDist.week1StartDate = getDateString(weekNoAndStartDateMap.get(1));
                tempWOWFunnelDist.week2StartDate = getDateString(weekNoAndStartDateMap.get(2));
                tempWOWFunnelDist.week3StartDate = getDateString(weekNoAndStartDateMap.get(3));
                tempWOWFunnelDist.week4StartDate = getDateString(weekNoAndStartDateMap.get(4));
                tempWOWFunnelDist.week5StartDate = getDateString(weekNoAndStartDateMap.get(5));
                tempWOWFunnelDist.week6StartDate = getDateString(weekNoAndStartDateMap.get(6));
                tempWOWFunnelDist.week7StartDate = getDateString(weekNoAndStartDateMap.get(7));
                tempWOWFunnelDist.week8StartDate = getDateString(weekNoAndStartDateMap.get(8));
                tempWOWFunnelDist.week9StartDate = getDateString(weekNoAndStartDateMap.get(9));
                tempWOWFunnelDist.week10StartDate = getDateString(weekNoAndStartDateMap.get(10));
                tempWOWFunnelDist.week11StartDate = getDateString(weekNoAndStartDateMap.get(11));
                tempWOWFunnelDist.week12StartDate = getDateString(weekNoAndStartDateMap.get(12));
                tempWOWFunnelDist.week13StartDate = getDateString(weekNoAndStartDateMap.get(13));
                
                tempWOWFunnelDist.week1EndDate = getDateString(weekNoAndEndDateMap.get(1));
                tempWOWFunnelDist.week2EndDate = getDateString(weekNoAndEndDateMap.get(2));
                tempWOWFunnelDist.week3EndDate = getDateString(weekNoAndEndDateMap.get(3));
                tempWOWFunnelDist.week4EndDate = getDateString(weekNoAndEndDateMap.get(4));
                tempWOWFunnelDist.week5EndDate = getDateString(weekNoAndEndDateMap.get(5));
                tempWOWFunnelDist.week6EndDate = getDateString(weekNoAndEndDateMap.get(6));
                tempWOWFunnelDist.week7EndDate = getDateString(weekNoAndEndDateMap.get(7));
                tempWOWFunnelDist.week8EndDate = getDateString(weekNoAndEndDateMap.get(8));
                tempWOWFunnelDist.week9EndDate = getDateString(weekNoAndEndDateMap.get(9));
                tempWOWFunnelDist.week10EndDate = getDateString(weekNoAndEndDateMap.get(10));
                tempWOWFunnelDist.week11EndDate = getDateString(weekNoAndEndDateMap.get(11));
                tempWOWFunnelDist.week12EndDate = getDateString(weekNoAndEndDateMap.get(12));
                tempWOWFunnelDist.week13EndDate = getDateString(weekNoAndEndDateMap.get(13));
                
                
                if(weekNoAmtMap.containsKey(1)){
                    tempWOWFunnelDist.week1 = weekNoAmtMap.get(1);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week1;
                }else 
                    tempWOWFunnelDist.week1 = 0;
                
                if(weekNoAmtMap.containsKey(2)){
                    tempWOWFunnelDist.week2 = weekNoAmtMap.get(2);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week2;
                }else 
                    tempWOWFunnelDist.week2 = 0;
                
                if(weekNoAmtMap.containsKey(3)){
                    tempWOWFunnelDist.week3 = weekNoAmtMap.get(3);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week3;
                }else 
                    tempWOWFunnelDist.week3 = 0;
                
                if(weekNoAmtMap.containsKey(4)){
                    tempWOWFunnelDist.week4 = weekNoAmtMap.get(4);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week4;
                }else 
                    tempWOWFunnelDist.week4 = 0;
                
                if(weekNoAmtMap.containsKey(5)){
                    tempWOWFunnelDist.week5 = weekNoAmtMap.get(5);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week5;
                }else 
                    tempWOWFunnelDist.week5 = 0;
                
                if(weekNoAmtMap.containsKey(6)){
                    tempWOWFunnelDist.week6 = weekNoAmtMap.get(6);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week6;
                }else 
                    tempWOWFunnelDist.week6 = 0;
                if(weekNoAmtMap.containsKey(7)){
                    tempWOWFunnelDist.week7 = weekNoAmtMap.get(7);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week7;
                }else 
                    tempWOWFunnelDist.week7 = 0;
                
                if(weekNoAmtMap.containsKey(8)){
                    tempWOWFunnelDist.week8 = weekNoAmtMap.get(8);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week8;
                }else 
                    tempWOWFunnelDist.week8 = 0;
                
                if(weekNoAmtMap.containsKey(9)){
                    tempWOWFunnelDist.week9 = weekNoAmtMap.get(9);  
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week9;
                }else 
                    tempWOWFunnelDist.week9 = 0;
                
                if(weekNoAmtMap.containsKey(10)){
                    tempWOWFunnelDist.week10 = weekNoAmtMap.get(10);    
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week10;
                }else 
                    tempWOWFunnelDist.week10 = 0;
                if(weekNoAmtMap.containsKey(11)){
                    tempWOWFunnelDist.week11 = weekNoAmtMap.get(11);    
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week11;
                }else 
                    tempWOWFunnelDist.week11 = 0;
                
                if(weekNoAmtMap.containsKey(12)){
                    tempWOWFunnelDist.week12 = weekNoAmtMap.get(12);    
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week12;
                }else 
                    tempWOWFunnelDist.week12 = 0;
                
                if(weekNoAmtMap.containsKey(13)){
                    tempWOWFunnelDist.week13 = weekNoAmtMap.get(13);    
                    tempWOWFunnelDist.totalAmount += tempWOWFunnelDist.week13;
                }else 
                    tempWOWFunnelDist.week13 = 0;
                
                return tempWOWFunnelDist;
            }
            
            public static string getDateString(Date tempdate){
                string str = '';
                if(tempdate != null){
                    str += tempdate.month() + '/' + tempdate.day() + '/' + tempdate.year();
                    return str;
                }else{
                    return str;
                }
            }
            
            
            
            public static integer getWeekNo(Date closeDate, map<integer, Date> weekNoAndEndDateMap, map<integer, Date> weekNoAndStartDateMap){
                integer tempWeekNo = 0; 
                for(integer i = 1; i <= 13; i++){
                    if(weekNoAndStartDateMap.get(i) <= closeDate && weekNoAndEndDateMap.get(i) >= closeDate ){
                        tempWeekNo = i;
                        break;
                    }
                }
                return tempWeekNo;
            }
            
            @RemoteAction @ReadOnly
            public static list<SourceSummary> GetSourceSummary(String userId , String forecastType ){
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                List<Id> allUserIds = new List<Id>();
                allUserIds.add(userId);
                allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                    
                set<string> oppForecastSet = new set<string>();
                oppForecastSet.add('Upside');
                oppForecastSet.add('Commit');
                oppForecastSet.add('Pipeline');
                oppForecastSet.add('Closed');
                    
                map<integer, integer> qtrMap = new map<integer, integer>(); 
                    integer fsicalYear = system.Today().Year();
                    for(Integer i = 1; i <=12; i++){
                       if(i ==8 || i == 9 || i == 10){
                           qtrMap.put(i, 10);
                       }else if(i ==11 || i == 12 || i == 1){
                           qtrMap.put(i, 1);
                       }else if(i ==2 || i == 3 || i == 4){
                           qtrMap.put(i, 4);
                       }else if (i ==5 || i == 6 || i == 7){
                           qtrMap.put(i, 7);
                       }
                   } 
                   
                   if( system.Today().Month() == 11 || system.Today().Month() == 12){
                       fsicalYear += 1;
                   }
                date lastMonthDateQtr = date.newInstance(fsicalYear, qtrMap.get(system.Today().Month()), 1);
               
                string firstQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(3), 1);
                string secondQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(6), 1);
                string thirdQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(9), 1);
                string fourthQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(12), 1);
               
                set<string> fiscalQtrSet = new set<String>();
                fiscalQtrSet.add(firstQtr);
                fiscalQtrSet.add(secondQtr);
                fiscalQtrSet.add(thirdQtr);
                fiscalQtrSet.add(fourthQtr);
                
                
                decimal frstQtrQuota = 0;
                decimal secondQtrQuota = 0;
                decimal thirdQtrQuota = 0;
                decimal fourthQtrQuota = 0;
               
                for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c IN: fiscalQtrSet AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                   if(salesQuota.FYFQ__c == firstQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            frstQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == secondQtr){
                       if(salesQuota.QuotaAmount__c != null)
                            secondQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c  == thirdQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            thirdQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == fourthQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            fourthQtrQuota += salesQuota.QuotaAmount__c;
                    }
               }
               
                map<string, string> fiscalQtrMap = new map<String, string>();
                fiscalQtrMap.put('first', getQueryQtrFormat(firstQtr));
                fiscalQtrMap.put('second', getQueryQtrFormat(secondQtr));
                fiscalQtrMap.put('third', getQueryQtrFormat(thirdQtr));
                fiscalQtrMap.put('fourth', getQueryQtrFormat(fourthQtr));
            
                List<string> oppSourceList = new list<string>();
                for( Schema.PicklistEntry f : Opportunity.Source__c.getDescribe().getPicklistValues()){
                    oppSourceList.add(f.getValue());
                }
                
                oppSourceList.sort();
                oppSourceList.add('None');
                list<SourceSummary> SourceSummaryList = new list<SourceSummary>();
                for(string oppSource : oppSourceList){
                    string src = oppSource;
                    SourceSummary srcSummary= new SourceSummary();
                    srcSummary.Source = oppSource;
                    srcSummary.firstQtrQuota = frstQtrQuota;
                    srcSummary.secondQtrQuota =  secondQtrQuota;
                    srcSummary.thirdQtrQuota =  thirdQtrQuota;
                    srcSummary.fourthQtrQuota =  fourthQtrQuota;
                    if(oppSource == 'None'){
                        src = '';
                        srcSummary.firstQtrQuota = 0;
                        srcSummary.secondQtrQuota =  0;
                        srcSummary.thirdQtrQuota =  0;
                        srcSummary.fourthQtrQuota =  0;
                    }
                    
                       
                    srcSummary.firstQtrQuota = srcSummary.firstQtrQuota != null ? srcSummary.firstQtrQuota : 0;
                    srcSummary.secondQtrQuota = srcSummary.secondQtrQuota != null ? srcSummary.secondQtrQuota : 0;
                    srcSummary.thirdQtrQuota = srcSummary.thirdQtrQuota != null ? srcSummary.thirdQtrQuota : 0;
                    srcSummary.fourthQtrQuota = srcSummary.fourthQtrQuota != null ? srcSummary.fourthQtrQuota : 0;
                    
                    map<string, Decimal> fiscalQtrPipelineMap = new map<string, Decimal>();
                    map<string, Decimal> fiscalQtrClosedWonMap = new map<string, Decimal>();
                    map<string, Decimal> fiscalQtrTotalAmtMap = new map<string, Decimal>();
                    
                    String firstFiscalQtr = fiscalQtrMap.get('first');
                    
                    for(Opportunity opp : [Select Id, Amount, Fiscal_Period__c, Probability, IsClosed, StageName, ForecastCategoryName  from Opportunity Where OwnerId IN :allUserIds AND Forecast_Type__c IN: forecastTypeSet  AND Amount != null AND StageName != '0 - Initial Prospecting' AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND ForecastCategoryName IN: oppForecastSet AND Source__c =: src]){
                        //if((firstFiscalQtr == opp.Fiscal_Period__c && Opp.ForecastCategoryName != 'Pipeline') || firstFiscalQtr != opp.Fiscal_Period__c){
                            decimal tempAmt = 0;
                            if(fiscalQtrPipelineMap != null && fiscalQtrPipelineMap.containsKey(opp.Fiscal_Period__c) ){
                                tempAmt = fiscalQtrPipelineMap.get(opp.Fiscal_Period__c);
                                tempAmt += opp.Amount;
                            }else{
                                tempAmt += opp.Amount;
                            }
                                fiscalQtrPipelineMap.put(opp.Fiscal_Period__c, tempAmt);
                        //}
                            
                        if(opp.StageName == label.Stage_6_Closed_Won){
                            decimal oppAmt = 0;
                            if(fiscalQtrClosedWonMap != null && fiscalQtrClosedWonMap.containsKey(opp.Fiscal_Period__c)){
                                oppAmt = fiscalQtrClosedWonMap.get(opp.Fiscal_Period__c);
                                oppAmt += opp.Amount;
                            }else{
                                oppAmt += opp.Amount;
                            }
                            fiscalQtrClosedWonMap.put(opp.Fiscal_Period__c, oppAmt);  
                        }
                            
                        if(opp.StageName == label.Stage_6_Closed_Won || opp.ForecastCategoryName == 'Upside' || opp.ForecastCategoryName == 'Commit'){
                            decimal oppAmt = 0;
                            if(fiscalQtrTotalAmtMap != null && fiscalQtrTotalAmtMap.containsKey(opp.Fiscal_Period__c)){
                                oppAmt = fiscalQtrTotalAmtMap.get(opp.Fiscal_Period__c);
                                oppAmt += opp.Amount;
                            }else{
                                oppAmt += opp.Amount;
                            }
                            fiscalQtrTotalAmtMap.put(opp.Fiscal_Period__c, oppAmt);  
                        }
                    }
                    
                    for(string fiscalQtr : fiscalQtrMap.keySet()){
                        if(fiscalQtr == 'first'){
                            srcSummary.firstQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('first'));
                            srcSummary.firstQtrClosedWon = fiscalQtrClosedWonMap.containsKey(fiscalQtrMap.get('first'))?fiscalQtrClosedWonMap.get(fiscalQtrMap.get('first')):0;
                        }else if(fiscalQtr == 'second'){
                            srcSummary.secondQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('second'));
                            srcSummary.secondQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('second'));
                        }else if(fiscalQtr == 'third'){
                           srcSummary.thirdQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('third'));
                           srcSummary.thirdQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('third'));
                        }else if(fiscalQtr == 'fourth'){
                            srcSummary.fourthQtrPipeline = fiscalQtrPipelineMap.get(fiscalQtrMap.get('fourth'));
                            srcSummary.fourthQtrClosedWon = fiscalQtrClosedWonMap.get(fiscalQtrMap.get('fourth'));
                        }
                    }
                    
                    srcSummary.firstQtrCoverage = getCoverage(srcSummary.firstQtrPipeline, srcSummary.firstQtrQuota);
                    srcSummary.secondQtrCoverage = getCoverage(srcSummary.secondQtrPipeline, srcSummary.secondQtrQuota);
                    srcSummary.thirdQtrCoverage = getCoverage(srcSummary.thirdQtrPipeline, srcSummary.thirdQtrQuota);
                    srcSummary.fourthQtrCoverage = getCoverage(srcSummary.fourthQtrPipeline, srcSummary.fourthQtrQuota);
                    
                    srcSummary.firstQtrQuotaPercnt = getCoverage(srcSummary.firstQtrClosedWon, srcSummary.firstQtrQuota);
                    srcSummary.secondQtrQuotaPercnt = getCoverage(srcSummary.secondQtrClosedWon, srcSummary.secondQtrQuota);
                    srcSummary.thirdQtrQuotaPercnt = getCoverage(srcSummary.thirdQtrClosedWon, srcSummary.thirdQtrQuota);
                    srcSummary.fourthQtrQuotaPercnt = getCoverage(srcSummary.fourthQtrClosedWon, srcSummary.fourthQtrQuota);
                    
                    srcSummary.firstQtrPipeline = srcSummary.firstQtrPipeline != null ? srcSummary.firstQtrPipeline : 0;
                    srcSummary.secondQtrPipeline = srcSummary.secondQtrPipeline != null ? srcSummary.secondQtrPipeline : 0;
                    srcSummary.thirdQtrPipeline = srcSummary.thirdQtrPipeline != null ? srcSummary.thirdQtrPipeline : 0;
                    srcSummary.fourthQtrPipeline = srcSummary.fourthQtrPipeline != null ? srcSummary.fourthQtrPipeline : 0;
                    
                    
                    srcSummary.totalQtrPipeline = srcSummary.firstQtrPipeline + srcSummary.secondQtrPipeline + srcSummary.thirdQtrPipeline + srcSummary.fourthQtrPipeline;
                    srcSummary.totalQtrQuota = srcSummary.firstQtrQuota + srcSummary.secondQtrQuota +srcSummary.thirdQtrQuota + srcSummary.fourthQtrQuota;
                    srcSummary.totalQtrCoverage = getCoverage(srcSummary.totalQtrPipeline, srcSummary.totalQtrQuota);
                    
                    //srcSummary.totalAmount = fiscalQtrTotalAmtMap.containsKey(fiscalQtrMap.get('first'))? fiscalQtrTotalAmtMap.get(fiscalQtrMap.get('first')):0;
                    
                    //srcSummary.quotaPercentage = getCoverage(srcSummary.firstQtrClosedWon, srcSummary.firstQtrQuota) * 100;
                    //srcSummary.firstQtrPipeline + srcSummary.secondQtrPipeline + srcSummary.thirdQtrPipeline + srcSummary.fourthQtrPipeline;
                    SourceSummaryList.add(srcSummary);  
                }
                return SourceSummaryList;
            }
            
            
            public class SourceSummary{
                public String Source{ get; set; }
                
                public decimal firstQtrPipeline {get;set;}
                public decimal firstQtrQuota {get;set;}
                public decimal firstQtrCoverage {get;set;}
                public decimal firstQtrClosedWon {get;set;}
                public decimal firstQtrQuotaPercnt {get;set;}
                
                public decimal secondQtrPipeline {get;set;}
                public decimal secondQtrQuota {get;set;}
                public decimal secondQtrCoverage {get;set;}
                public decimal secondQtrClosedWon {get;set;}
                public decimal secondQtrQuotaPercnt {get;set;}
                
                
                public decimal thirdQtrPipeline {get;set;}
                public decimal thirdQtrQuota {get;set;}
                public decimal thirdQtrCoverage {get;set;}
                public decimal thirdQtrClosedWon {get;set;}
                public decimal thirdQtrQuotaPercnt {get;set;}
                
                public decimal fourthQtrPipeline {get;set;}
                public decimal fourthQtrQuota {get;set;}
                public decimal fourthQtrCoverage {get;set;}
                public decimal fourthQtrClosedWon {get;set;}
                public decimal fourthQtrQuotaPercnt {get;set;}
                
                public decimal totalQtrPipeline {get;set;}
                public decimal totalQtrQuota {get;set;}
                public decimal totalQtrCoverage {get;set;}
                public decimal totalQtrClosedWon {get;set;}
                public decimal totalQtrQuotaPercnt {get;set;}  
                
                public SourceSummary(){
                    Source = '';
                    
                    firstQtrPipeline = 0;
                    firstQtrQuota = 0;
                    firstQtrCoverage = 0;
                    firstQtrClosedWon = 0;
                    firstQtrQuotaPercnt = 0;
                    
                    secondQtrPipeline = 0;
                    secondQtrQuota = 0;
                    secondQtrCoverage = 0;
                    secondQtrClosedWon = 0;
                    secondQtrQuotaPercnt = 0;
                    
                    
                    thirdQtrPipeline = 0;
                    thirdQtrQuota = 0;
                    thirdQtrCoverage = 0;
                    thirdQtrClosedWon = 0;
                    thirdQtrQuotaPercnt = 0;
                    
                    fourthQtrPipeline = 0;
                    fourthQtrQuota = 0;
                    fourthQtrCoverage = 0;
                    fourthQtrClosedWon = 0;
                    fourthQtrQuotaPercnt = 0;
                    
                    totalQtrPipeline = 0;
                    totalQtrQuota = 0;
                    totalQtrCoverage = 0;
                    totalQtrClosedWon = 0;
                    totalQtrQuotaPercnt = 0; 
                }
            }
            
            @RemoteAction @ReadOnly
            public static list<fourQtrSourceWOWSummary> getFourQtrSourceWOW(String forecastType, string userId){
                List<Id> allUserIds = new List<Id>();
                allUserIds.add(userId);
                allUserIds.addAll(ForecastingService.getAllSubordinateUserIds(userId));
                
                map<integer, integer> qtrMap = new map<integer, integer>(); 
                    integer fsicalYear = system.Today().Year();
                    for(Integer i = 1; i <=12; i++){
                       if(i ==8 || i == 9 || i == 10){
                           qtrMap.put(i, 10);
                       }else if(i ==11 || i == 12 || i == 1){
                           qtrMap.put(i, 1);
                       }else if(i ==2 || i == 3 || i == 4){
                           qtrMap.put(i, 4);
                       }else if (i ==5 || i == 6 || i == 7){
                           qtrMap.put(i, 7);
                       }
                   } 
                   
                   if( system.Today().Month() == 11 || system.Today().Month() == 12){
                       fsicalYear += 1;
                   }
                date lastMonthDateQtr = date.newInstance(fsicalYear, qtrMap.get(system.Today().Month()), 1);
               
                string firstQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(3), 1);
                string secondQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(6), 1);
                string thirdQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(9), 1);
                string fourthQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(12), 1);
                
                map<string, string> fiscalQtrMap = new map<String, string>();
                fiscalQtrMap.put('first', getQueryQtrFormat(firstQtr));
                fiscalQtrMap.put('second', getQueryQtrFormat(secondQtr));
                fiscalQtrMap.put('third', getQueryQtrFormat(thirdQtr));
                fiscalQtrMap.put('fourth', getQueryQtrFormat(fourthQtr));
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                set<string> oppForecastSet = new set<string>();
                oppForecastSet.add('Upside');
                oppForecastSet.add('Commit');
                oppForecastSet.add('Pipeline');
                oppForecastSet.add('Closed');
                
                Date qtrStartDate = getQtrStartDateTime().Date();
                date qtrEndDate = getQtrEndDate();
                
                list<String> oppSourcelist = new list<String>();
                for( Schema.PicklistEntry f : Opportunity.Source__c.getDescribe().getPicklistValues()){
                    oppSourcelist.add(f.getValue());
                }
                oppSourcelist.sort();
                oppSourcelist.add('None');
                list<fourQtrSourceWOWSummary> fourQtrSourceWOWSummaryList = new list<fourQtrSourceWOWSummary>();
                weekInformations weeksInfo = new weekInformations(Date.Today());
                for(String oppSource : oppSourcelist){
                    fourQtrSourceWOWSummary fourQtrSumm = new fourQtrSourceWOWSummary();
                    fourQtrSumm.source = oppSource;
                    string source = oppSource ==  'None' ? '' : oppSource;
                    decimal thisWeekAmount = 0;
                    decimal lastWeekAmount = 0;
                    decimal priorWeekAmount = 0;
                    decimal prevWeekAmount = 0;
                    
                    for(Opportunity opp : [Select Id, Amount, Fiscal_Period__c, Probability, IsClosed, StageName, ForecastCategoryName  from Opportunity Where OwnerId IN :allUserIds AND Forecast_Type__c IN: forecastTypeSet  AND Amount != null AND StageName != '0 - Initial Prospecting' AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND ForecastCategoryName IN: oppForecastSet AND Source__c =: source]){
                        thisWeekAmount += opp.Amount;
                    }
                    
                    for(Opportunity_Snapshot__c oppSnap : [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Opportunity__c, Created_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND Snapshot_Date__c =: weeksInfo.thisWeekStartdate AND Source__c =: source  AND Forecast_Category__c IN: oppForecastSet]){
                        //if(oppSnap.StageName == '13 - Closed & Approved By Finance' || oppSnap.Forecast_Category__c == 'Upside' || oppSnap.Forecast_Category__c == 'Commit'){
                            lastWeekAmount += oppSnap.Amount__c;
                        //}
                    }
                    for(Opportunity_Snapshot__c oppSnap : [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Opportunity__c, Created_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND Snapshot_Date__c =: weeksInfo.lastWeekStartdate AND Source__c =: source AND Forecast_Category__c IN: oppForecastSet]){
                        //if(oppSnap.StageName == '13 - Closed & Approved By Finance' || oppSnap.Forecast_Category__c == 'Upside' || oppSnap.Forecast_Category__c == 'Commit'){
                            priorWeekAmount += oppSnap.Amount__c;
                        //} 
                    }
                    for(Opportunity_Snapshot__c oppSnap : [Select Id, Amount__c, Source__c, Stage__c, Fiscal_Period__c, Forecast_Category__c, Opportunity_Owner_ID__c, Type__c, CreatedDate, Opportunity__c, Created_Date__c from Opportunity_Snapshot__c where  Amount__c != null AND OwnerId IN: allUserIds AND Stage__c != '0 - Initial Prospecting'  AND Forecast_Type__c IN: forecastTypeSet AND Fiscal_Period__c IN: fiscalQtrMap.Values() AND Snapshot_Date__c =: weeksInfo.PriorWeekStartdate AND Source__c =: source AND Forecast_Category__c IN: oppForecastSet]){
                        //if(oppSnap.StageName == '13 - Closed & Approved By Finance' || oppSnap.Forecast_Category__c == 'Upside' || oppSnap.Forecast_Category__c == 'Commit'){
                            prevWeekAmount += oppSnap.Amount__c;
                        //} 
                    }
                    fourQtrSumm.thisWeek = thisWeekAmount; 
                    fourQtrSumm.lastWeek = lastWeekAmount ;
                    fourQtrSumm.priorWeek = priorWeekAmount; 
                    
                    // % Change Claculation Remaining
                    
                    fourQtrSourceWOWSummaryList.add(fourQtrSumm);
                }
                return fourQtrSourceWOWSummaryList;
            }
            
            public class fourQtrSourceWOWSummary{
                public string source{get;set;}
                public decimal thisWeek{get;set;}
                public decimal thisWeekChnage{get;set;}
                public decimal lastWeek{get;set;}
                public decimal lastWeekChange{get;set;}
                public decimal priorWeek{get;set;}
                public decimal priorWeekChange{get;set;}
                public fourQtrSourceWOWSummary(){
                    this.source = '';
                    this.thisWeek = 0;
                    this.thisWeekChnage = 0;
                    this.lastWeek = 0;
                    this.lastWeekChange = 0;
                    this.priorWeek = 0;
                    this.priorWeekChange = 0;
                }
            }   
            
            
            @RemoteAction @ReadOnly
    public static ForecastSummary GetFunnelAchievement(String userId , String fiscalQuarter, String forecastType ){
                User user;
                List<User> users = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :userId LIMIT 1];
                if(users.size() > 0){
                    ForecastingDataModel.FiscalQuarterInfo qtr = new ForecastingDataModel.FiscalQuarterInfo(fiscalQuarter);
                    ForecastSummary forecastSummary = new ForecastSummary();
                    forecastSummary.UserId = users[0].Id;
                    forecastSummary.UserName = users[0].Name;
                    map<integer, integer> qtrMap = new map<integer, integer>(); 
                    integer fsicalYear = system.Today().Year();
                    for(Integer i = 1; i <=12; i++){
                       if(i ==8 || i == 9 || i == 10){
                           qtrMap.put(i, 10);
                       }else if(i ==11 || i == 12 || i == 1){
                           qtrMap.put(i, 1);
                       }else if(i ==2 || i == 3 || i == 4){
                           qtrMap.put(i, 4);
                       }else if (i ==5 || i == 6 || i == 7){
                           qtrMap.put(i, 7);
                       }
                   } 
                   
                   if( system.Today().Month() == 11 || system.Today().Month() == 12){
                       fsicalYear += 1;
                   }
                date lastMonthDateQtr = date.newInstance(fsicalYear, qtrMap.get(system.Today().Month()), 1);
               
                string firstQtr = PerformanceService.getQtrString(lastMonthDateQtr, 1);
                string secondQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(3), 1);
                string thirdQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(6), 1);
                string fourthQtr = PerformanceService.getQtrString(lastMonthDateQtr.addMonths(9), 1);
               
                set<string> fiscalQtrSet = new set<String>();
                fiscalQtrSet.add(firstQtr);
                fiscalQtrSet.add(secondQtr);
                fiscalQtrSet.add(thirdQtr);
                fiscalQtrSet.add(fourthQtr);
                
                set<string> forecastTypeSet = new set<String>();
                forecastTypeSet = getForecastTypes(forecastType);
                
                decimal frstQtrQuota = 0;
                decimal secondQtrQuota = 0;
                decimal thirdQtrQuota = 0;
                decimal fourthQtrQuota = 0;
               
                for(SalesQuota__c salesQuota : [select id, ForecastType__c, FYFQ__c, QuotaAmount__c, User__c from SalesQuota__c where FYFQ__c IN: fiscalQtrSet AND ForecastType__c IN: forecastTypeSet AND User__c =: userId]){
                   if(salesQuota.FYFQ__c == firstQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            frstQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == secondQtr){
                       if(salesQuota.QuotaAmount__c != null)
                            secondQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c  == thirdQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            thirdQtrQuota += salesQuota.QuotaAmount__c;
                    }else if(salesQuota.FYFQ__c == fourthQtr){
                        if(salesQuota.QuotaAmount__c != null)
                            fourthQtrQuota += salesQuota.QuotaAmount__c;
                    }
               }
               
               forecastSummary.firstQtrQuota = frstQtrQuota;
               forecastSummary.secondQtrQuota =  secondQtrQuota;
               forecastSummary.thirdQtrQuota =  thirdQtrQuota;
               forecastSummary.fourthQtrQuota =  fourthQtrQuota;
               
               forecastSummary.firstQtrQuota = forecastSummary.firstQtrQuota != null ? forecastSummary.firstQtrQuota : 0;
               forecastSummary.secondQtrQuota = forecastSummary.secondQtrQuota != null ? forecastSummary.secondQtrQuota : 0;
               forecastSummary.thirdQtrQuota = forecastSummary.thirdQtrQuota != null ? forecastSummary.thirdQtrQuota : 0;
               forecastSummary.fourthQtrQuota = forecastSummary.fourthQtrQuota != null ? forecastSummary.fourthQtrQuota : 0;
                
               
               map<string, string> fiscalQtrMap = new map<String, string>();
               fiscalQtrMap.put('first', getQueryQtrFormat(firstQtr));
               fiscalQtrMap.put('second', getQueryQtrFormat(secondQtr));
               fiscalQtrMap.put('third', getQueryQtrFormat(thirdQtr));
               fiscalQtrMap.put('fourth', getQueryQtrFormat(fourthQtr));
               forecastSummary = loadPipeLineData(forecastSummary, userId, fiscalQtrMap, forecastTypeSet);
               return forecastSummary;
                }else{
                    return null;
                }
            }
            
        }