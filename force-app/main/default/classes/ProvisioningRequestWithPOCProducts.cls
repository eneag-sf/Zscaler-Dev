public class ProvisioningRequestWithPOCProducts{
    Public String provreqid{get; set;}
    public String tableTitle { get; set; }
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    Public Provisioning_Request__c prrec{get {
        if(provreqid != null){
            prrec = [Select Id, Preferred_Cloud__c,All_Features__c, Account__r.name, Account_Manager__r.Name, Account_Managers_Email__c, Primary_Eval_Contact__r.Name, Days_Left_After_Reminder_Initiation__c from Provisioning_Request__c where Id = :provreqid];
        }
        return prrec;
    } set;}
    Public List<POC_Product__c> pocprodlst{get {
        if(provreqid != null){
            pocprodlst = [Select Id, Product__r.Name from POC_Product__c where Provisioning_Request__c = :provreqid];
        }
        return pocprodlst;
    }  set;}

}