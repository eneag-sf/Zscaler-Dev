@istest
public class Potential_ZPA_Accounts_Ctrl_Test{
    static testmethod void test1(){
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        Contract_Detail__c  contract = new Contract_Detail__c();
        contract.Name = 'Test Contract';
        contract.Account_Name__c = acct.Id;
        contract.Quantity__c = 5000;
        contract.Contract_Detail_Status__c = 'Active';
        contract.Product_SKU__c = 'ZIA-PRO-BUNDLE';
        contract.Do_not_Aggregate__c = false;
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
        
        Zscaler_Cloud_ID__c   cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = acct.Id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        
        insert cloudId;
        
        BWC_Data__c bd = new BWC_Data__c();
        bd.Name = 'ABC';
        bd.Monthly_Usage__c = LastMonth;
        bd.Total_registered_Devices__c = 10000;
        bd.Cloud_ID__c = cloudId.Id;
        bd.Z_App_ZIA_Enabled__c = 'Enabled';
        insert bd;
        
        Potential_ZPA_Accounts_Ctrl ctrl = new Potential_ZPA_Accounts_Ctrl();
        ctrl.userId = UserInfo.getuserId();
        system.debug(ctrl.us);
        system.debug(ctrl.accwrp);
    }
    static testmethod void test2(){
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        insert acct;
        
        Contract_Detail__c  contract = new Contract_Detail__c();
        contract.Name = 'Test Contract';
        contract.Account_Name__c = acct.Id;
        contract.Quantity__c = 5000;
        contract.Contract_Detail_Status__c = 'Active';
        contract.Product_SKU__c = 'ZIA-PRO-BUNDLE';
        contract.Do_not_Aggregate__c = false;
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
        
        Zscaler_Cloud_ID__c   cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = acct.Id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        
        insert cloudId;
        
        BWC_Data__c bd = new BWC_Data__c();
        bd.Name = 'ABC';
        bd.Monthly_Usage__c = twoMonthsAgo;
        bd.Total_registered_Devices__c = 10000;
        bd.Cloud_ID__c = cloudId.Id;
        bd.Z_App_ZIA_Enabled__c = 'Enabled';
        insert bd;
        
        Potential_ZPA_Accounts_Ctrl ctrl = new Potential_ZPA_Accounts_Ctrl();
        ctrl.userId = UserInfo.getuserId();
        system.debug(ctrl.us);
        system.debug(ctrl.accwrp);
        Potential_ZPA_Accounts_Ctrl.AccountWrapper ctrl3 = new Potential_ZPA_Accounts_Ctrl.AccountWrapper(acct, 0, 0);
    }
}