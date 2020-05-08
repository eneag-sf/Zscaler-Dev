@isTest
public class CustomerSummaryBatchTest {
	
    @testSetup 
    static void createTestData() 
    {
		Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.DS_Review_Status__c = 'Complete';
        insert acct;
        
        Product2 product = new Product2(ProductCode = 'ZSC-SIP', Name = 'Zscaler Internet Security Platform', Family = 'Zscaler Products',
                                        IsActive = true, Apttus_Config2__ConfigurationType__c = 'Standalone', Apttus_Config2__HasAttributes__c = false,
                                        Apttus_Config2__HasOptions__c = false);
        insert product;
                
        Contract_Detail__c  contract = new Contract_Detail__c();
        contract.Name = 'Test Contract';
        contract.Account_Name__c = acct.Id;
        contract.Quantity__c = 5000;
        contract.Contract_Detail_Status__c = 'Active';
        contract.Product_Name__c = product.Id;
        contract.Do_not_Aggregate__c = false;
        contract.Override_Contract_Detail_Status__c = true;
        contract.Start_Date__c = Date.today().addDays(-100);
        contract.End_Date__c = Date.today().addDays(100);
        contract.Amount_USD__c = 50000.00;
        
        insert contract;
        
        Date dateToday = Date.today();
		Date thisMonth = dateToday.toStartOfMonth();
		date LastMonth = thisMonth.addMonths(-1);
        date twoMonthsAgo = thisMonth.addMonths(-2);
        date threeMonthsAgo = thisMonth.addMonths(-3);
        date lastYearSameTime1 = thisMonth.addMonths(-13);
        date lastYearSameTime2 = thisMonth.addMonths(-14);
        date lastYearSameTime3 = thisMonth.addMonths(-15);
        
        Zscaler_Cloud_ID__c	 cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
		cloudId.Account__c = acct.Id;
		cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        
        insert cloudId;
        
        List<Cloud_Usage__c> cloudList = new List<Cloud_Usage__c>();
        
            
        Cloud_Usage__c c1 = new Cloud_Usage__c();
        c1.Zscaler_Cloud_ID__c = cloudId.Id;
        c1.Account__c = acct.Id;
        c1.Total_Policy_Blocks__c = 200;
        c1.Total_Transactions__c = 1000;
        c1.Total_Transactions_Bandwidth__c = 10000;
        c1.Total_Security_Blocks__c = 600;
        c1.total_botnet_blocks__c = 300;
        c1.total_malware_site_blocks__c   = 100; 
        c1.total_phishing_blocks__c = 200;
        c1.Usage_Pull_Date__c = lastYearSameTime1;
        c1.total_ssl_transactions__c = 300;
        c1.total_ssl_inspected_transactions__c = 150;
        cloudList.add(c1);
        
        Cloud_Usage__c c2 = new Cloud_Usage__c();
        c2.Zscaler_Cloud_ID__c = cloudId.Id;
        c2.Account__c = acct.Id;
        c2.Total_Policy_Blocks__c = 200;
        c2.Total_Transactions__c = 1000;
        c2.Total_Transactions_Bandwidth__c = 200000;
        c2.Total_Security_Blocks__c = 600;
        c2.total_botnet_blocks__c = 300;
        c2.total_malware_site_blocks__c   = 100; 
        c2.total_phishing_blocks__c = 200;
        c2.Usage_Pull_Date__c = lastYearSameTime2;
        c2.total_ssl_transactions__c = 300;
        c2.total_ssl_inspected_transactions__c = 150;
        cloudList.add(c2);
        
        Cloud_Usage__c c3 = new Cloud_Usage__c();
        c3.Zscaler_Cloud_ID__c = cloudId.Id;
        c3.Account__c = acct.Id;
        c3.Total_Policy_Blocks__c = 200;
        c3.Total_Transactions__c = 1000;
        c3.Total_Transactions_Bandwidth__c = 30000;
        c3.Total_Security_Blocks__c = 600;
        c3.total_botnet_blocks__c = 300;
        c3.total_malware_site_blocks__c  = 100; 
        c3.total_phishing_blocks__c = 200;
        c3.Usage_Pull_Date__c = lastYearSameTime3;
        c3.total_ssl_transactions__c = 300;
        c3.total_ssl_inspected_transactions__c = 250;
        cloudList.add(c3);
        
        Cloud_Usage__c c4 = new Cloud_Usage__c();
        c4.Zscaler_Cloud_ID__c = cloudId.Id;
        c4.Account__c = acct.Id;
        c4.Total_Policy_Blocks__c = 300;
        c4.Total_Transactions__c = 1300;
        c4.Total_Transactions_Bandwidth__c = 240000;
        c4.Total_Security_Blocks__c = 630;
        c4.total_botnet_blocks__c = 310;
        c4.total_malware_site_blocks__c   = 110; 
        c4.total_phishing_blocks__c = 210;
        c4.Usage_Pull_Date__c = LastMonth;
        c4.total_ssl_transactions__c = 300;
        c4.total_ssl_inspected_transactions__c = 300;
        cloudList.add(c4);
        
        Cloud_Usage__c c5 = new Cloud_Usage__c();
        c5.Zscaler_Cloud_ID__c = cloudId.Id;
        c5.Account__c = acct.Id;
        c5.Total_Policy_Blocks__c = 300;
        c5.Total_Transactions__c = 1300;
        c5.Total_Transactions_Bandwidth__c = 10000;
        c5.Total_Security_Blocks__c = 630;
        c5.total_botnet_blocks__c = 310;
        c5.total_malware_site_blocks__c   = 110; 
        c5.total_phishing_blocks__c = 210;
        c5.Usage_Pull_Date__c = twoMonthsAgo;
        c5.total_ssl_transactions__c = 300;
        c5.total_ssl_inspected_transactions__c = 200;
        cloudList.add(c5);
        
        Cloud_Usage__c c6 = new Cloud_Usage__c();
        c6.Zscaler_Cloud_ID__c = cloudId.Id;
        c6.Account__c = acct.Id;
        c6.Total_Policy_Blocks__c = 300;
        c6.Total_Transactions__c = 1300;
        c6.Total_Transactions_Bandwidth__c = 350000;
        c6.Total_Security_Blocks__c = 630;
        c6.total_botnet_blocks__c = 310;
        c6.total_malware_site_blocks__c   = 110; 
        c6.total_phishing_blocks__c = 210;
        c6.Usage_Pull_Date__c = threeMonthsAgo;
        c6.total_ssl_transactions__c = 300;
        c6.total_ssl_inspected_transactions__c = 300;
        cloudList.add(c6);
        
        insert cloudList;
    }
    
    @isTest 
    static void testSchduledJob()
    {
        test.startTest();
        CustomerSummarySchedule customerSummarySchedule = new CustomerSummarySchedule();
        String cronExp1 = '0 0 23 * * ?';
        System.schedule('Test Schedule customerSummary', cronExp1, customerSummarySchedule);

        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAndPreviousMonthRange(12, 2019);
        
        CustomerSummaryBatchHelper.LastAnd6MonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAnd6MonthRange(12, 2019);
        
        CustomerSummaryBatchHelper.LastAnd12MonthRange(1, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(2, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(3, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(4, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(5, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(6, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(7, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(8, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(9, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(10, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(11, 2019);
        CustomerSummaryBatchHelper.LastAnd12MonthRange(12, 2019);
        test.stopTest();
    }
}