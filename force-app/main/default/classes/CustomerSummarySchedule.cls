public class CustomerSummarySchedule implements Schedulable {
    
    public void execute(SchedulableContext ctx)
    {
        String query = 'select Id, Name,No_of_Platform_Seats__c, Total_Transactions__c, Total_Policy_Blocks__c,'+
            'Total_Botnet_Calls__c, Total_Malware__c,Total_Bandwidth__c,Total_Transactions_Same_Time__c,'+
            'Total_Bandwidth_Same_Time__c,Total_Phishing_Attacks__c,First_Contract_Date__c,Total_Security_Blocks__c, '+
            'Value_Summary_Months__c,Total_Bandwidth_Growth__c,Total_Transaction_Growth__c from Account where No_of_Platform_Seats__c > 0 and Type=\'Customer\' and Skip_Value_Summary_Generation__c = false';
		CustomerSummaryBatch cus = new CustomerSummaryBatch(query);
		
        Database.executeBatch(cus,1);
    }

}