public class ZendeskTicketsListForFAController {
    public Id accountId { get; set; }
    public Id focusAccountId { get; set; }
    public Focus_Accounts__c focusAccount { get; set; }

    public ZendeskTicketsListForFAController(ApexPages.StandardController ctrlr) {
        focusAccountId = ApexPages.currentPage().getParameters().get('id');

        if (focusAccountId != null) {
            focusAccount = [SELECT Id, Account_Name__c FROM Focus_Accounts__c WHERE Id = :focusAccountId];
            accountId = focusAccount.Account_Name__c;
        }
    }
}