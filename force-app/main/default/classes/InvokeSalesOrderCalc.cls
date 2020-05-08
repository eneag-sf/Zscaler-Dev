public class InvokeSalesOrderCalc implements System.Queueable{
    public Id oppId = null;
    public Id propId = null;
    public InvokeSalesOrderCalc(Id pId, Id oId){
        propId = pId;
        oppId = oId;
    }
    public void execute(QueueableContext context) {
        CreateSalesOrderExtension ctrl = new CreateSalesOrderExtension();
        ctrl.opportunityId  = oppId;
        ctrl.pageLoad();
        ctrl.adjustACVandTCV();
        Apttus_Proposal__Proposal__c proptoUpdate = new Apttus_Proposal__Proposal__c(Id = propId);
        proptoUpdate.Total_New_ACV__c = 0;
        proptoUpdate.Total_New_TCV__c = 0;
        proptoUpdate.Total_Renewal_ACV__c = 0;
        proptoUpdate.Total_Renewal_TCV__c = 0;
        proptoUpdate.Total_Upsell_ACV__c = 0;
        proptoUpdate.Total_Upsell_TCV__c = 0;

        for(CreateSalesOrderExtension.LinestoNS pli: ctrl.lstfinallinestoNS){
            proptoUpdate.Total_New_ACV__c += pli.newACV;
            proptoUpdate.Total_New_TCV__c += pli.newTCV;
            proptoUpdate.Total_Renewal_ACV__c += pli.RenewalACV;
            proptoUpdate.Total_Renewal_TCV__c += pli.RenewalTCV;
            proptoUpdate.Total_Upsell_ACV__c += pli.UpsellACV;
            proptoUpdate.Total_Upsell_TCV__c += pli.UpsellTCV;
        }
        update proptoUpdate;
    }
}