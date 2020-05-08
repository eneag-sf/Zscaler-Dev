public class churnEditController {

    private final Churn__c churn;
    public churnEditController(ApexPages.StandardController stdController) {
        this.churn = (Churn__c)stdController.getRecord();
    }
    
    public pagereference onload(){
        
        List<Churn__c> churnLst = [Select Id, Type__c, Opportunity__c, RecordType.Name from Churn__c Where Id =: this.churn.Id];
        if(!churnLst.isEmpty()){
            if(churnLst[0].RecordType.Name == 'Renewals'){
                pagereference pf = new pagereference('/apex/SubmitChurnForm?id=' + churnLst[0].Opportunity__c + '&churnId=' + churnLst[0].Id);
                pf.setRedirect(true);
                return pf;
            }
            else{
                pagereference pf = new pagereference('/apex/OppLossReasonFormPage?oppId=' + churnLst[0].Opportunity__c + '&id=' + churnLst[0].Id);
                pf.setRedirect(true);
                return pf;
            }
        }
        return null;
    }

}