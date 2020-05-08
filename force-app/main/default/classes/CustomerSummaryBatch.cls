/*
 *  Author : Raghu Manchiraju
 *  This class is used to roll up cloud usage summary of Customer onto Account
 * 
 */ 
global class CustomerSummaryBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String query;
    global Map<Id,String> errorMap;
    global Account acct;
    global CustomerSummaryBatch(String q)
    {
        query = q;
        errorMap = new Map<Id,String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator(query);
    }

    /* select Id,Usage_Pull_Date__c from Cloud_Usage__c 
        * where Account__c ='0017000000jfWgR' and Usage_Pull_Date__c = Last_N_months:3
        * #Users: ZIA Platform, Total Transactions,Total Security Blocks, L3M
        * Generate this value statement only if ZIA Platform seats is greater than zero. 
        */
   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
       Decimal totalTransactions = 0;
       Decimal totalOldTransactions = 0;
       Decimal totalOldBandwidth = 0;
       Decimal totalPolicyViolations = 0;
       Decimal totalBotnet = 0;
       Decimal totalMalware = 0;
       Decimal totalPhishingAttacks = 0;
       Decimal totalEncryptedThreatsBlocks = 0;
       Decimal totalEncryptedtransactions=0;
       Decimal totalEncryptedInspectedtransactions=0;
       Decimal totalOffice365Transactions = 0;
       Integer percentageSSLTrafic = 0;
       Integer percentageSSLInspected = 0;
       Decimal totalLastTransactions = 0;
       Decimal totalLastBandwidth = 0; 
       Decimal totalPreviousTransactions =0;
       Decimal totalPreviousBandwidth = 0;
       Decimal total6MLastTransactions = 0;
       Decimal total6MLastBandwidth = 0;
       Decimal total6MPreviousTransactions = 0;
       Decimal total6MPreviousBandwidth = 0;
       Decimal total12MLastTransactions = 0;
       Decimal total12MLastBandwidth = 0;
       Decimal total12MPreviousTransactions = 0;
       Decimal total12MPreviousBandwidth = 0;
               
       List<Account> accountList = new List<Account>();
       try
       {
       String last3Months = new CustomerSummaryBatchHelper().last3Months(Date.today().month());
       for(sObject s : scope)
       {
           Account customer = (Account)s;
		   acct = customer;
           customer.Total_Transactions__c = 0.0;
           customer.Total_Policy_Blocks__c = 0.0;
           customer.Total_Botnet_Calls__c = 0.0;//total_botnet_blocks__c
           customer.Total_Malware__c = 0.0; //total_malware_site_blocks__c  
           customer.Total_Phishing_Attacks__c = 0.0; //total_phishing_blocks__c 
           customer.Total_Security_Blocks__c = 0.0;//total_security_blocks__c
           customer.Total_Transactions_Same_Time__c = 0.0;
           customer.Total_Bandwidth__c = 0.0;
           customer.Total_Bandwidth_Same_Time__c = 0.0;
           customer.Value_Summary_Months__c = '';
           customer.Total_Bandwidth_Growth__c =0.0;
           customer.Total_Transaction_Growth__c = 0.0;
           customer.Traffic_Encrypted__c = '';
           customer.Encrypted_Traffic_Inspected__c = '';
           customer.Encrypted_Threats_Blocked__c = '';
           boolean noDataflag = true;
           boolean nottoomuchData = true;
           
           List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
           List<Cloud_Usage__c> usageListOld = new List<Cloud_Usage__c>();
           List<Cloud_Usage__c> lastAndPreviousMonthList = new List<Cloud_Usage__c>();
           List<Cloud_Usage__c> lastAnd6MonthList = new List<Cloud_Usage__c>();
           List<Cloud_Usage__c> lastAnd12MonthList = new List<Cloud_Usage__c>();
           
           nottoomuchData = new CustomerSummaryBatchHelper().checkNotTooMuchData(customer.Id);
           Date dateToday = Date.today();
           Date thisMonth = dateToday.toStartOfMonth();
           date months18Ago = thisMonth.addMonths(-18);
           
           if(nottoomuchData)
           {
                usageList = new CustomerSummaryBatchHelper().usage(customer);
                usageListOld = new CustomerSummaryBatchHelper().oldUsage(customer);
                lastAndPreviousMonthList = new CustomerSummaryBatchHelper().getLastAndPreviousMonthUsage(customer);
                lastAnd6MonthList = new CustomerSummaryBatchHelper().getLastAnd6MonthUsage(customer);
                lastAnd12MonthList = new CustomerSummaryBatchHelper().getLastAnd12MonthUsage(customer);
           }
           
           if(usageListOld.size() > 0)
           {
                for(Cloud_Usage__c cloudUsageOld : usageListOld)
                {
                    totalOldTransactions = totalOldTransactions + cloudUsageOld.Total_Transactions__c;
                    totalOldBandwidth = totalOldBandwidth + cloudUsageOld.Total_Transactions_Bandwidth__c;
                }
               customer.Total_Transactions_Same_Time__c = totalOldTransactions;
               customer.Total_Bandwidth_Same_Time__c = totalOldBandwidth;
               customer.Total_Transactions_Same_Time_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions_Same_Time__c));
               customer.Total_Bandwidth_Same_Time_Text__c = new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB';
           }
           
           Date today = Date.today();
           Date lastStartDate, lastEndDate, previousStartDate, previousEndDate;
           Map<String, List<Datetime>> mapLastAndPreviousMonthDateRange = CustomerSummaryBatchHelper.LastAndPreviousMonthRange(today.month(), today.year());
           lastStartDate = mapLastAndPreviousMonthDateRange.get('last')[0].date();
           lastEndDate = mapLastAndPreviousMonthDateRange.get('last')[1].date();
           previousStartDate = mapLastAndPreviousMonthDateRange.get('previous')[0].date();
           previousEndDate = mapLastAndPreviousMonthDateRange.get('previous')[1].date();
           
           
           
           for (Cloud_Usage__c usage : lastAndPreviousMonthList) {
                if (lastStartDate <= usage.Usage_Pull_Date__c
                    && lastEndDate >= usage.Usage_Pull_Date__c) {
                    totalLastTransactions = usage.Total_Transactions__c + totalLastTransactions;
                    totalLastBandwidth = usage.Total_Transactions_Bandwidth__c + totalLastBandwidth;
                } else if (previousStartDate <= usage.Usage_Pull_Date__c
                    && previousEndDate >= usage.Usage_Pull_Date__c) {
                    totalPreviousTransactions = usage.Total_Transactions__c + totalPreviousTransactions;
                    totalPreviousBandwidth = usage.Total_Transactions_Bandwidth__c + totalPreviousBandwidth;
                }
           }
            
            if (totalLastTransactions != null && totalPreviousTransactions != null && totalLastTransactions != 0 && totalPreviousTransactions != 0)
                customer.Transactions_LM_vs_PM__c = new CustomerSummaryBatchHelper().calculatePercentage(totalLastTransactions, totalPreviousTransactions);
            
            if (totalLastBandwidth != null && totalPreviousBandwidth != null && totalLastBandwidth != 0 && totalPreviousBandwidth != 0)
                customer.Bandwidth_LM_Vs_PM__c = new CustomerSummaryBatchHelper().calculatePercentage(totalLastBandwidth, totalPreviousBandwidth);
           
           Map<String, List<Datetime>> mapLastAnd6MonthDateRange = CustomerSummaryBatchHelper.LastAnd6MonthRange(today.month(), today.year());
           lastStartDate = mapLastAnd6MonthDateRange.get('last')[0].date();
           lastEndDate = mapLastAnd6MonthDateRange.get('last')[1].date();
           previousStartDate = mapLastAnd6MonthDateRange.get('previous')[0].date();
           previousEndDate = mapLastAnd6MonthDateRange.get('previous')[1].date();
           for (Cloud_Usage__c usage : lastAnd6MonthList) {
                if (lastStartDate <= usage.Usage_Pull_Date__c
                    && lastEndDate >= usage.Usage_Pull_Date__c) {
                    total6MLastTransactions = usage.Total_Transactions__c + total6MLastTransactions;
                    total6MLastBandwidth = usage.Total_Transactions_Bandwidth__c + total6MLastBandwidth;
                } else if (previousStartDate <= usage.Usage_Pull_Date__c
                    && previousEndDate >= usage.Usage_Pull_Date__c) {
                    total6MPreviousTransactions = usage.Total_Transactions__c + total6MPreviousTransactions;
                    total6MPreviousBandwidth = usage.Total_Transactions_Bandwidth__c+total6MPreviousBandwidth;
                }
           }
           
            if (total6MLastTransactions != null && total6MPreviousTransactions != null && total6MLastTransactions != 0 && total6MPreviousTransactions != 0)
                customer.Transactions_LM_vs_6M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total6MLastTransactions, total6MPreviousTransactions);
            
           
            if (total6MLastBandwidth != null && total6MPreviousBandwidth != null && total6MLastBandwidth != 0 && total6MPreviousBandwidth != 0)
                customer.Bandwidth_LM_Vs_6M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total6MLastBandwidth, total6MPreviousBandwidth);
           
           Map<String, List<Datetime>> mapLastAnd12MonthDateRange = CustomerSummaryBatchHelper.LastAnd12MonthRange(today.month(), today.year());
           lastStartDate = mapLastAnd12MonthDateRange.get('last')[0].date();
           lastEndDate = mapLastAnd12MonthDateRange.get('last')[1].date();
           previousStartDate = mapLastAnd12MonthDateRange.get('previous')[0].date();
           previousEndDate = mapLastAnd12MonthDateRange.get('previous')[1].date();
           for (Cloud_Usage__c usage : lastAnd12MonthList) {
                if (lastStartDate <= usage.Usage_Pull_Date__c
                    && lastEndDate >= usage.Usage_Pull_Date__c) {
                    total12MLastTransactions = usage.Total_Transactions__c+total12MLastTransactions;
                    total12MLastBandwidth = usage.Total_Transactions_Bandwidth__c+total12MLastBandwidth;
                } else if (previousStartDate <= usage.Usage_Pull_Date__c
                    && previousEndDate >= usage.Usage_Pull_Date__c) {
                    total12MPreviousTransactions = usage.Total_Transactions__c+total12MPreviousTransactions;
                    total12MPreviousBandwidth = usage.Total_Transactions_Bandwidth__c+total12MPreviousBandwidth;
                }
           }
            
            if (total12MLastTransactions != null && total12MPreviousTransactions != null && total12MLastTransactions != 0 && total12MPreviousTransactions != 0)
                customer.Transactions_LM_vs_12M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total12MLastTransactions, total12MPreviousTransactions);
          
            if (total12MLastBandwidth != null && total12MPreviousBandwidth != null && total12MLastBandwidth != 0&& total12MPreviousBandwidth != 0)
                customer.Bandwidth_LM_Vs_12M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total12MLastBandwidth, total12MPreviousBandwidth);
           
           for(Cloud_Usage__c cloudUsage : usageList)
           {
               if(cloudUsage.Total_Transactions__c != null)
                   customer.Total_Transactions__c = customer.Total_Transactions__c + cloudUsage.Total_Transactions__c;
               if(cloudUsage.Total_Transactions_Bandwidth__c != null)
                   customer.Total_Bandwidth__c = customer.Total_Bandwidth__c + cloudUsage.Total_Transactions_Bandwidth__c;
               if(cloudUsage.Total_Policy_Blocks__c != null)
                   customer.Total_Policy_Blocks__c = customer.Total_Policy_Blocks__c + cloudUsage.Total_Policy_Blocks__c;
               if(cloudUsage.total_botnet_blocks__c != null)
               customer.Total_Botnet_Calls__c = customer.Total_Botnet_Calls__c + cloudUsage.total_botnet_blocks__c;
               if(cloudUsage.total_malware_site_blocks__c  != null)
               customer.Total_Malware__c = customer.Total_Malware__c + cloudUsage.total_malware_site_blocks__c ;
               if(cloudUsage.total_phishing_blocks__c  != null)
               customer.Total_Phishing_Attacks__c = customer.Total_Phishing_Attacks__c  + cloudUsage.total_phishing_blocks__c ;
               if(cloudUsage.total_security_blocks__c  != null)
               customer.Total_Security_Blocks__c =  customer.Total_Security_Blocks__c  + cloudUsage.total_security_blocks__c ;
               
               totalEncryptedThreatsBlocks = cloudUsage.Encrypted_Threats_Blocked__c+ totalEncryptedThreatsBlocks;
               totalEncryptedtransactions = cloudUsage.total_ssl_transactions__c+ totalEncryptedtransactions;
               totalEncryptedInspectedtransactions = cloudUsage.total_ssl_inspected_transactions__c+totalEncryptedInspectedtransactions;
               totalOffice365Transactions = cloudUsage.Total_Office_365_Transactions__c  + totalOffice365Transactions;
           
           }
           
           if(customer.No_of_Platform_Seats__c > 0 && last3Months != null && nottoomuchData)
           {
               customer.Value_Summary_Months__c = last3Months;
               customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/> '+
                   'Below is the snapshot of value delivered for '+customer.Name+' in the last 3 months ('+last3Months+'):<br/><ul style="font-size:14px">';
                 
               if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
               {
                   noDataflag = false;
                   customer.Total_Transactions_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions__c));
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions__c))+' transactions processed. </li>';
               }
               
               if(customer.Total_Bandwidth__c != null && customer.Total_Bandwidth__c > 0.0)
               {
                   noDataflag = false;
                   customer.Total_Bandwidth_Text__c = new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c)+' TB';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c)+' TB traffic (bandwidth) processed. </li>';
               }
               
               if(totalOldBandwidth > 0 && customer.Total_Bandwidth__c > totalOldBandwidth)
               {
                   noDataflag = false;
                   Integer growth = new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c);
                   customer.Total_Bandwidth_Growth__c = growth;
                   if(growth >= 10 && growth <=1000)
                   {
                       customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown by '+ new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c)+'% - from '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';

                   }
                   else if(growth >1000)
                   {
                       customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown from '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
                   }
                                   
               }
               
               if(customer.Total_Policy_Blocks__c != null && customer.Total_Policy_Blocks__c > 0.0)
               {
                   noDataflag = false;
                   customer.Total_Policy_Blocks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c));
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c))+' policy violations prevented. </li>';
               }
               
               if(customer.Total_Security_Blocks__c!= null && customer.Total_Security_Blocks__c > 0.0)
               {
                   noDataflag = false;
                   customer.Total_Security_Blocks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Security_Blocks__c));
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Security_Blocks__c)) + ' security threats blocked.';//, including <ul>
                   
                   if(customer.Total_Botnet_Calls__c != null && customer.Total_Botnet_Calls__c > 0.0)
                   {
                       customer.Total_Botnet_Calls_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Botnet_Calls__c));
                       //customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Botnet_Calls__c)) + ' Botnet Calls</li>';
                   }
                   if(customer.Total_Malware__c != null && customer.Total_Malware__c > 0.0)
                   {
                       customer.Total_Malware_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Malware__c));
                       //customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Malware__c)) + ' Malware threats</li>';
                   }
                   if(customer.Total_Phishing_Attacks__c != null && customer.Total_Phishing_Attacks__c > 0.0)
                   {
                       customer.Total_Phishing_Attacks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Phishing_Attacks__c));
                       //customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Phishing_Attacks__c)) + ' Phishing Attacks</li>';
                   }
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</li>';//</ul>
               }
               
               
                
               if(totalOldTransactions > 0 && customer.Total_Transactions__c > totalOldTransactions)
               {
                   noDataflag = false;
                   customer.Total_Transaction_Growth__c =  new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Transactions__c,customer.Total_Transactions_Same_Time__c);
                   //customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> The number of Transactions from same time last year has grown by '+ new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Transactions__c,customer.Total_Transactions_Same_Time__c)+'% - from '+new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions_Same_Time__c))+' Transactions to '+new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions__c)) +' Transactions.</li>';
               }
               
               /*if(totalOldBandwidth > 0 && customer.Total_Bandwidth__c > totalOldBandwidth)
               {
                   noDataflag = false;
                   Integer growth = new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c);
                   customer.Total_Bandwidth_Growth__c = growth;
                   if(growth >= 10)
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown by '+ new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c)+'% - from '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
               }*/
               
               customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul></p>';
               
               if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
               {
                   percentageSSLTrafic = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalEncryptedtransactions,customer.Total_Transactions__c);
                   //we exclude 0365 Traffic as that is already inspected by Microsoft.
                   percentageSSLInspected = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalEncryptedInspectedtransactions,(totalEncryptedtransactions-totalOffice365Transactions));
               	   
                   customer.Total_Encrypted_Transaction__c = totalEncryptedtransactions;
                   customer.Total_Encrypted_Inspected_Transaction__c = totalEncryptedInspectedtransactions;
                   //This contains 0365 Encryption as  well
                   customer.Traffic_Encrypted__c = String.valueOf(percentageSSLTrafic);
                   customer.Encrypted_Traffic_Inspected__c = String.valueOf(percentageSSLInspected);
                   customer.Encrypted_Threats_Blocked__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(totalEncryptedThreatsBlocks));
               }
               
               customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">';
               
               if(percentageSSLInspected >= 40 && !(noDataflag) && nottoomuchData) 
               {
                   Decimal threadPercentage = 0.00;
                   
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> is reducing its business risk by inspecting encrypted traffic.';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> traffic was Encrypted.</li>';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(totalEncryptedThreatsBlocks))+ '</strong> threats hidden in encrypted traffic were detected and blocked.</li>';
                   
                   /*if(customer.Total_Security_Blocks__c != null && customer.Total_Security_Blocks__c > 0)
                   {
                       threadPercentage = totalEncryptedThreatsBlocks/customer.Total_Security_Blocks__c;
                       
                       if(threadPercentage > 40)
                       {
                           customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+threadPercentage+ '%</strong> of total threats are encrypted threats.</li>';
                       }
                   }*/
                       
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul>';
               }
               else if(percentageSSLInspected >= 20 && percentageSSLInspected <40 && !(noDataflag) && nottoomuchData) 
                   
               {
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> could further reduce its business risk by increasing inspection of  encrypted traffic.';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> traffic was Encrypted.</li>';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+customer.Name+'\'s</strong> Zscaler Deployment is configured to only inspect <strong>'+percentageSSLInspected+'%</strong> of the encrypted traffic. </li></ul>';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Name+'</strong> should consider configuring Zscaler to increase inspection of encrypted traffic.</p> ';
               }
               else if(percentageSSLInspected < 20 && !(noDataflag) && nottoomuchData)
               {
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> could reduce its business risk by inspecting encrypted traffic.';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> total traffic was Encrypted.</li>';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li>Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Name+'</strong> is likely not blocking a significant amount of threats.</li></ul>';
                   customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px"> Zscaler recommends inspecting encrypted traffic.</p';
   
               }
               
               customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</p>';
               
               if(noDataflag)
               {
                   customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/></p> ';
               } 
           
           }
           
           if(!nottoomuchData)
           {
              customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/>'+
                 +'We have too much data to process cannot generate Zscaler Value Summary.</p> ';
 
           }
           
           accountList.add(customer);
       }
       
         update accountList;  
       }
       catch(Exception ex)
       {
           System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
       	 errorMap.put(acct.Id,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());  
       }
       
       
   }

   global void finish(Database.BatchableContext BC)
   {
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorMap.Values().isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Customer Summary Batch Job Failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' account records that have failed: \n';
            for(Id s: errorMap.keySet()){
                msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(errorMap.Values().isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Customer Summary Batch Job Completed ');
            mail.setPlainTextBody('Customer Summary Batch Job Completed');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
   }
}