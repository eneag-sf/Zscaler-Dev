public class CustomerSummaryBatchHelper 
{
    public List<Cloud_Usage__c> usage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        //
            usageList = [select Id, Total_Policy_Blocks__c,Total_Transactions__c,total_security_blocks__c,Encrypted_Threats_Blocked__c,Total_Office_365_Transactions__c, 
                                          total_botnet_blocks__c,Total_Transactions_Bandwidth__c,total_malware_site_blocks__c ,total_ssl_inspected_transactions__c,
                                          total_ssl_transactions__c,total_phishing_blocks__c  from Cloud_Usage__c where Account__c = :acct.Id 
                                          and Usage_Pull_Date__c = Last_N_months:3];
        return usageList;
    }
     
    public List<Cloud_Usage__c> oldUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        //and Usage_Pull_Date__c = Last_Year
            usageList = [select Id, Total_Policy_Blocks__c,Total_Transactions__c,total_security_blocks__c,Encrypted_Threats_Blocked__c,Total_Office_365_Transactions__c, 
                                          total_botnet_blocks__c,Total_Transactions_Bandwidth__c,total_malware_site_blocks__c,total_ssl_inspected_transactions__c,
                                          total_ssl_transactions__c,total_phishing_blocks__c  from Cloud_Usage__c where Account__c = :acct.Id 
                                           and Usage_Pull_Date__c = Last_N_months:15 and  Usage_Pull_Date__c <> Last_N_months:12];
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAndPreviousMonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAndPreviousMonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAnd6MonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd6MonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAnd12MonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd12MonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }

    public static String getCloudUsageQuery(Id accountId, Map<String, List<Datetime>> usageRange) {
        String query = 'SELECT Id, Account__c, Usage_Pull_Date__c, Total_Transactions__c,Total_Office_365_Transactions__c, Total_Transactions_Bandwidth__c FROM Cloud_Usage__c WHERE Account__c = \'' + accountId + '\' ';

        Map<String, List<Datetime>> mapMonthAndYear = usageRange;
        
        String criteria = ' AND (';
        for (String month : mapMonthAndYear.keySet()) {
            criteria += ' (Usage_Pull_Date__c >= ' + mapMonthAndYear.get(month)[0].format('yyyy-MM-dd') + ' AND Usage_Pull_Date__c <= ' + mapMonthAndYear.get(month)[1].format('yyyy-MM-dd') + ') OR ';
        }
        criteria = criteria.substring(1, criteria.length() - 3);
        criteria += ')';
        
        if (criteria.length() > 7) {
            System.debug(criteria);
            query += criteria;
        }
        
        return query;
    }

    
        
    public Boolean checkNotTooMuchData(String IdData)
    {
        Boolean flag = true;
        Integer counter = 0;
        System.debug('>>>> AccountId: ' + IdData);
        List<AggregateResult> results = [select count(id) from Cloud_Usage__c where Account__c = :IdData and Usage_Pull_Date__c = Last_N_months:3]; 
        for(AggregateResult ar : results)
        {
            Integer data = (integer)ar.get('expr0');
            counter = data;
            if( data > 50000)
            {
                system.debug('Counter Info 1 : '+counter);
                flag = false;
            }
        }
        
        if(flag)
        {
            //Usage_Pull_Date__c = Last_Year and
            results = [select count(id) from Cloud_Usage__c where Account__c = :IdData and 
                        Usage_Pull_Date__c = Last_N_months:15 
                       and  Usage_Pull_Date__c <> Last_N_months:12]; 
            for(AggregateResult ar1 : results)
            {
                Integer data = (integer)ar1.get('expr0')+counter;
                system.debug('Counter Info 1 : '+data);
                if( data > 50000)
                {
                    flag = false;
                }
            }
        }
        return flag;
    }
    
    public Integer calculatePercentage(Decimal currentValue,Decimal oldValue)
    {
        return Integer.ValueOf(((100*currentValue)/oldValue)-100);
    }
    
    public Integer calculateSimplePercentage(Decimal currentValue,Decimal oldValue)
    {
        return Integer.ValueOf(((currentValue)/(oldValue))*100);
    }
    

    public String convertToTeraByte(Decimal value)
    {
        Decimal output = (1*value)/(1000000000);
        return output.setScale(1, RoundingMode.HALF_UP).format();
    }
    public String convertToMillions(String value)
    {
        if(value != null )
        {
            system.debug('Input String :: '+value);
            String[] strSplit = value.split('\\.');
            
            if(strSplit[0] != null)
            {
                if(strSplit[0].length() > 9)
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 1:: '+len);
                    String s1 = strSplit[0].left(len - 9);
                    String s2 = '';
                    if(len == 12)
                    s2 = strSplit[0].substring(len - 9,4);
                    if(len == 11)
                    s2 = strSplit[0].substring(len - 9,3);
                    if(len == 10)
                    s2 = strSplit[0].substring(len - 9,2);
                    
                    return s1+'.'+s2+' Billion';
                    //return s1+' Billion';
                }
                else if(strSplit[0].length() > 6)
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 2:: '+len);
                    String s1 = strSplit[0].left(len - 6);
                    String s2 = '';
                    if(len == 9)
                    s2 = strSplit[0].substring(len - 6,4);
                    if(len == 8)
                    s2 = strSplit[0].substring(len - 6,3);
                    if(len == 7)
                    s2 = strSplit[0].substring(len - 6,2);
                    return s1+'.'+s2+' Million';
                    //return s1+' Million';
                }
                else
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 3:: '+len+' :: '+strSplit[0]);
                    if(len > 3)
                    {
                        String s1 = strSplit[0].left(len - 3);
                        String s2 = strSplit[0].substring(len - 3);
                        system.debug(s1+','+s2);
                        return s1+','+s2;
                    }
                    else
                    {
                        return strSplit[0];
                    }
                }
            }
        }
        
        return null;
    }
    
    public String last3Months(Integer month)
    {
        switch on month {
            when 1 {
                return 'October, November, December';
            }
            when 2 {
                return 'November, December, January';
            }
            when 3 {
                return 'December, January, February';
            }
            when 4 {
                return 'January, February, March';
            }
            when 5 {
                return 'February, March, April';
            }
            when 6 {
                return 'March, April, May';
            }
            when 7 {
                return 'April, May, June';
            }
            when 8 {
                return 'May, June, July';
            }
            when 9 {
                return 'June, July, August';
            }
            when 10 {
                return 'July, August, September';
            }
            when 11 {
                return 'August, September, October';
            }
            when 12 {
                return 'September, October, November';
            }
        }
        return null;
    }
    
    public static Map<String, List<Datetime>> LastAndPreviousMonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;        
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 11;
            previousYear = year - 1;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 12;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 1;
            previousYear = year;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 2;
            previousYear = year;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 3;
            previousYear = year;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 4;
            previousYear = year;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 5;
            previousYear = year;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 6;
            previousYear = year;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 7;
            previousYear = year;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 8;
            previousYear = year;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 9;
            previousYear = year;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 10;
            previousYear = year;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
    
    public static Map<String, List<Datetime>> LastAnd6MonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year - 1 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 7;
            previousYear = year - 1;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 8;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year - 1 });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 9;
            previousYear = year - 1;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year - 1 });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 10;
            previousYear = year - 1;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 11;
            previousYear = year - 1;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 1 });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 12;
            previousYear = year - 1;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 1;
            previousYear = year;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 2;
            previousYear = year;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 3;
            previousYear = year;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 4;
            previousYear = year;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 5;
            previousYear = year;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 6;
            previousYear = year;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
    
    public static Map<String, List<Datetime>> LastAnd12MonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 2 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 12;
            previousYear = year - 2;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 1;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year - 1 });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 2;
            previousYear = year - 1;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year - 1 });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 3;
            previousYear = year - 1;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year - 1 });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 4;
            previousYear = year - 1;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year - 1 });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 5;
            previousYear = year - 1;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year - 1 });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 6;
            previousYear = year - 1;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year - 1 });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 7;
            previousYear = year - 1;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year - 1 });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 8;
            previousYear = year - 1;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year - 1 });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 9;
            previousYear = year - 1;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year - 1 });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 10;
            previousYear = year - 1;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 11;
            previousYear = year - 1;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
}