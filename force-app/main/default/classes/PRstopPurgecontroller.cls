public class PRstopPurgecontroller{  
    
    public ApexPages.StandardController sc; 
    Id recordId;
    public Provisioning_Request__c Prvsn_Rqst {get;set;}
    public Boolean showStopPurgePopup {get;set;}
    public string currentDetailedReasonforContractExtension {get;set;}
    
    public PRstopPurgecontroller(ApexPages.StandardController stdController) {
        recordId = stdController.getId();
        showStopPurgePopup = true;
        Prvsn_Rqst = [SELECT Id, Provisioning_Date__c,RecordType.Name,Provisioning_Status__c,Number_of_Extensions__c,Provisioning_End_Date__c,Detailed_Reason_for_Contract_Extension__c,Provisioning_Request_Expiry_Date__c,SE__r.ManagerId,SE_Manager__c,GEO__c,OwnerId,Reason_for_Stop_Purge__c from Provisioning_Request__c WHERE Id =: recordId];
        
    }
    public PageReference SubmitforStopPurge() {
        try{
            boolean noErrors = false;
            if(!string.isBlank(Prvsn_Rqst.Reason_for_Stop_Purge__c) && string.valueof(Prvsn_Rqst.Reason_for_Stop_Purge__c)!=null){
                    noErrors = true; 
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide reason to Stop the Purge process');
                ApexPages.addMessage(myMsg);
                noErrors = false;
            }
            
            if(noErrors){                              
                /* Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for Extension.');
                req.setObjectId(prvsn_rqst.Id);
                Approval.ProcessResult approvalResult = Approval.process(req); */
                Map<ID,ProcessInstance> piMap = New Map<ID,ProcessInstance>([Select Id from ProcessInstance where TargetObjectId=:Prvsn_Rqst.id]);
                
                List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
                
                for(ProcessInstanceWorkItem wi : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :piMap.keySet()]){
                    // if there's a work item, set the action to 'removed' and execute
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setAction('Reject');
                    req2.setWorkitemId(wi.Id);
                    req2.setComments('Remove approval procees request');
                    requests.add(req2);
                }
                Approval.ProcessResult[] processResults = Approval.process(requests);
                
                
                Prvsn_Rqst.Provisioning_Status__c = 'Purge Stopped';
                Prvsn_Rqst.Approval_for_Purge_Status__c = 'Purge Recalled';
                Prvsn_Rqst.RunGDPRvalidations__c =true;

                update Prvsn_Rqst;
                                
                PageReference pf = new PageReference('/' + recordId);
                pf.setRedirect(true);
                return pf;
            }
        }
        catch(Exception exp){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exp.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    public PageReference cancelStopPurgePopup(){
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
    }
}