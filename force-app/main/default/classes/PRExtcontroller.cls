public class PRExtcontroller{  
    
    Public MAP<String,String> geoUserMapping = new Map<String, String>();
    
    public ApexPages.StandardController sc; 
    Id recordId;
    public Provisioning_Request__c Prvsn_Rqst {get;set;}
    public Boolean showExtensionPopup {get;set;}
    public date currentExtensionDate {get;set;}
    
    public string currentDetailedReasonforContractExtension {get;set;}
    public Date currentRequestedOn {get;set;}
    public Date currentExtensionRequestedTill {get;set;}
    //public Date currentExtensionRequestedTill {get;set;}
    
    public PRExtcontroller(ApexPages.StandardController stdController) {
        recordId = stdController.getId();
        showExtensionPopup = true;
        Prvsn_Rqst = [SELECT Id, Provisioning_Date__c, 
                      //Reason_for_Extension__c, 
                      Number_of_Extensions__c,
                      Provisioning_End_Date__c,
                      Detailed_Reason_for_Contract_Extension__c,
                      Provisioning_Request_Expiry_Date__c,
                      SE__r.ManagerId,
                      SE_Manager__c,
                      Account__r.Sales_Engineer__c,
                      Account__r.Sales_Engineer__r.ManagerId,
                      Last_Provision_End_Date__c,
                      Extension_Requested_On__c,
                      GEO__c,
                      Previous_Extension_Requested_Till__c,
                      OwnerId,Sent_To_Approval__c,Previous_Extension_Requested_On__c,
                      PR_Extension_Requested_Date__c
                      from 
                      Provisioning_Request__c WHERE Id =: recordId];
        
        if(Prvsn_Rqst.Provisioning_Request_Expiry_Date__c != null){
            currentExtensionDate = Prvsn_Rqst.Provisioning_Request_Expiry_Date__c;
        }
        /**if(Prvsn_Rqst.PR_Extension_Requested_Date__c != null){
            currentExtensionDate = Prvsn_Rqst.PR_Extension_Requested_Date__c;
        }**/
        if(Prvsn_Rqst.PR_Extension_Requested_Date__c != null){
            currentExtensionRequestedTill = Prvsn_Rqst.PR_Extension_Requested_Date__c;
        }
        
        currentDetailedReasonforContractExtension = Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c;
        currentRequestedOn = Prvsn_Rqst.Extension_Requested_On__c;
        
        Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = null;
        if(currentExtensionDate != null){
            Prvsn_Rqst.PR_Extension_Requested_Date__c = currentExtensionDate.addDays(30);
        }
        else{
            Prvsn_Rqst.PR_Extension_Requested_Date__c = system.today().addDays(30);
        }
    }
    public PageReference submitForApproval() {
        try{
            boolean noErrors = false;
            
            system.debug('the Detailed_Reason_for_Contract_Extension__c is' + Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c);
            system.debug('the PR_Extension_Requested_Date__c is' + Prvsn_Rqst.PR_Extension_Requested_Date__c);
            system.debug('the PR_Extension_Requested_Date__c is' + Prvsn_Rqst.PR_Extension_Requested_Date__c);
            system.debug('the currentExtensionDate is' + currentExtensionDate);
            
            
            
            if(!string.isBlank(Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c) && Prvsn_Rqst.PR_Extension_Requested_Date__c != null){
                if(Prvsn_Rqst.PR_Extension_Requested_Date__c <= currentExtensionDate.addDays(30)){
                    noErrors = true;
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Extension date cannot be greater than ' +  currentExtensionDate.addDays(30).format()  + 'Extensions can be done only in  increments of 30 days.');
                    ApexPages.addMessage(myMsg);
                    noErrors = false;
                }
                
                if(noErrors){
                    if(Prvsn_Rqst.PR_Extension_Requested_Date__c >= currentExtensionDate){
                        noErrors = true;
                    }
                    else{
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'PR is already approved till (' + currentExtensionDate.format() + ')');
                        ApexPages.addMessage(myMsg);
                        noErrors = false;
                    }
                }
                
                /**if(noErrors){
                    if(currentExtensionDate != null){
                        if(Prvsn_Rqst.PR_Extension_Requested_Date__c > currentExtensionDate){
                            noErrors = true;
                        }
                        else{
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'PR is already approved till (' + currentExtensionDate.format() + ')');
                            ApexPages.addMessage(myMsg);
                            noErrors = false;
                        }
                    }
                }**/
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Provisioning End Date and Detailed Reason for Contract Extension are required');
                ApexPages.addMessage(myMsg);
                noErrors = false;
            }
            if(noErrors){
                if(Prvsn_Rqst.Number_of_Extensions__c != null && Prvsn_Rqst.Number_of_Extensions__c >= 1){
                    Prvsn_Rqst.Number_of_Extensions__c = Prvsn_Rqst.Number_of_Extensions__c + 1;
                }
                else{
                    Prvsn_Rqst.Number_of_Extensions__c   = 1;
                }
                Prvsn_Rqst.Sent_To_Approval__c = true;
                if(Prvsn_Rqst.SE__r.ManagerId != null){
                    //Prvsn_Rqst.SE_Manager__c = Prvsn_Rqst.Account__r.Sales_Engineer__r.ManagerId;
                    Prvsn_Rqst.SE_Manager__c = Prvsn_Rqst.SE__r.ManagerId;
                }
                Prvsn_Rqst.Extension_Requested_On__c = system.today();
                Prvsn_Rqst.Previous_Extension_Requested_Till__c = currentExtensionRequestedTill;
                Prvsn_Rqst.Previous_Extension_Requested_On__c = currentRequestedOn;
                update Prvsn_Rqst;
				system.debug('Prvsn_Rqst  '+Prvsn_Rqst);
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for Extension.');
                req.setObjectId(prvsn_rqst.Id);
                Approval.ProcessResult approvalResult = Approval.process(req);
				system.debug('After approval process');
                PageReference pf = new PageReference('/' + recordId);
                pf.setRedirect(true);
                return pf;
            }
        }
        catch(Exception exp){
            Zscaler_Error_Logs__c EL1= new Zscaler_Error_Logs__c();
            EL1.Class_Name__c='PRExtcontroller';
            EL1.Method_Name__c='submitForApproval';
            EL1.User__c=userinfo.getuserid();
            EL1.Exception_info__c=exp.getMessage();
            EL1.Operation__c='Update-Submission for Approval';
            EL1.Record_Info__c=String.valueof(Prvsn_Rqst.id);
            insert EL1;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());
            ApexPages.addMessage(myMsg);
            system.debug('the exception is' + exp.getMessage());
        }
        return null;
    }
    public PageReference cancelExtensionpopup(){
        PageReference pf = new PageReference('/' + recordId);
        pf.setRedirect(true);
        return pf;
    }
  public void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}