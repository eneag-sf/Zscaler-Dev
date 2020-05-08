public class MatchingDealRegAccountsControllerExt {
    public List<Account> matchingAccountList {get;set;}
    private Deal_Reg__c deal;
    public MatchingDealRegAccountsControllerExt(ApexPages.StandardController controller) {
        this.deal = (Deal_Reg__c)controller.getRecord();
        matchingAccountList = new list<Account>();
        this.deal = [Select Id,End_Customer_Domain__c from Deal_Reg__c where ID =: deal.Id];
        if(deal.End_Customer_Domain__c  != '' && deal.End_Customer_Domain__c != null ){
            for(Account acc : [Select id, Name, type, NumberOfEmployees, Owner.Name from Account where Domain__c =: deal.End_Customer_Domain__c])
                matchingAccountList.add(acc);        
        }
        
    }
}