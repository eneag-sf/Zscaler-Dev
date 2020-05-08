public class Contract_Extension_Controller{
    Public String contractextensionId{get; set;}
    public boolean isapprovalrequested {get; set;}
    public boolean isapproved {get; set;}
    public boolean isrejected {get; set;}
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    public String yearVal {
        get{
            return String.valueOf(date.today().year());
        } set;
    }
    Public Opportunity opp{get {
        if(contractextensionId != null){
            opp = [Select Id, Name,Type,Opportunity_Customer_Advocate__c, Opportunity_Customer_Advocate__r.Phone, Opportunity_Customer_Advocate__r.Email, Primary_Partner__c, Account.Zscaler_Customer_Summary__c, Account.Generate_Value_Summary__c, Contract_End_Date_New__c from Opportunity where Id in (Select Opportunity__c from Contract_Extension_Request__c where Id = :contractextensionId)];
        }
        return opp;
    } set;}
    Public Contract_Extension_Request__c ContractExtensionreq{get {
        if(contractextensionId != null){
            ContractExtensionreq = [Select Id, Name,Opportunity__r.Account.Name, Opportunity__r.Amount, Opportunity__r.Contract_End_Date_New__c,ACV__c, Detailed_Reason_for_Contract_Extension__c,  Opportunity__c, Opportunity__r.Name, Opportunity__r.New_Extended_Contract_Date__c, Reason_for_Extension__c, Contract_Extension_Date__c from Contract_Extension_Request__c where Id = :contractextensionId];
        }
        return ContractExtensionreq ;
    } set;}
    
}