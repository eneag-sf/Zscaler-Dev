public class InvokePartnerMarginCalc implements System.Queueable
{
    public Id oppId = null;
    public Id propId = null;
    public InvokePartnerMarginCalc(Id pId, Id oId) 
    {
        propId = pId;
        oppId = oId;
    }

    public void execute(QueueableContext context) {
        
        Apttus_Proposal__Proposal__c proptoUpdate = new Apttus_Proposal__Proposal__c(Id = propId);
        proptoUpdate.Total_Net_to_Zscaler__c = 0;
        proptoUpdate.Primary_Partner_AW_Margin__c = 0;
        proptoUpdate.Primary_Partner_Deal_Reg_Margin__c = 0;
        proptoUpdate.Primary_Partner_Fulfilment_Margin__c = 0;
        proptoUpdate.Primary_Partner_POV_Margin__c = 0;

        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLines = new List<Apttus_Proposal__Proposal_Line_Item__c>();

        quoteLines = [select Id,Net_to_Zscaler__c,Primary_Partner_AW_Margin__c,Primary_Partner_Deal_Reg_Margin__c,Primary_Partner_Fulfilment_Margin__c,Primary_Partner_POV_Margin__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c= :propId];

        for(Apttus_Proposal__Proposal_Line_Item__c quoteLine : quoteLines)
        {
            proptoUpdate.Total_Net_to_Zscaler__c = proptoUpdate.Total_Net_to_Zscaler__c + quoteLine.Net_to_Zscaler__c;
            proptoUpdate.Primary_Partner_AW_Margin__c += quoteLine.Primary_Partner_AW_Margin__c;
            proptoUpdate.Primary_Partner_Deal_Reg_Margin__c += quoteLine.Primary_Partner_Deal_Reg_Margin__c;
            proptoUpdate.Primary_Partner_Fulfilment_Margin__c += quoteLine.Primary_Partner_Fulfilment_Margin__c;
            proptoUpdate.Primary_Partner_POV_Margin__c += quoteLine.Primary_Partner_POV_Margin__c;
        }

        update proptoUpdate;
    }
}