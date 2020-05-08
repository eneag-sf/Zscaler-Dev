public with sharing class ZendeskTicketsListForTDController {
    public Id accountId { get; set; }
    public Id tamDetailsId { get; set; }
    public Tam_Details__c tamDetails { get; set; }

    public ZendeskTicketsListForTDController(ApexPages.StandardController ctrlr) {
        tamDetailsId = ApexPages.currentPage().getParameters().get('id');

        if (tamDetailsId != null) {
            tamDetails = [SELECT Id, Account_Name__c FROM Tam_Details__c WHERE Id = :tamDetailsId];
            accountId = tamDetails.Account_Name__c;
        }
    }
}