public class AccountReportController {
    
    public string accId {get;set;}
    public Account acc {get;set;}
    public AccountReportController(){
        string accountId = '';
        acc = new Account ();
        accountId = ApexPages.currentPage().getParameters().get('id');
        if(accountId != '' && accountId != null){
            list<Account> accList = new list<Account>();
            accList = [select Id, Name, Type, ZPA_Asset_SKU__c, ZPA_Deployed__c from Account where Id =: accountId limit 1];
            if(!accList.isEmpty()){
                acc =accList[0];
                accId = acc.Id;
            }
            
        }else{
            accId = '';

        }
    
    }
}