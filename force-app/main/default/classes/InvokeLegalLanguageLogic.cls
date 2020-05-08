public class InvokeLegalLanguageLogic implements System.Queueable{
    
    public Id propId = null;
    
    public InvokeLegalLanguageLogic(Id pId){
        propId = pId;
    }

    public void execute(QueueableContext context){
        Boolean isLegalLanguageProposal = false;
        String preSKUNames = '';
        Apttus_Proposal__Proposal__c proptoUpdate = [Select Id,Show_Legal_Language_for_PRE_SKUs__c,PRE_SKUs_for_Legal_Language__c,Apttus_Proposal__Account__c,Apttus_Proposal__Account__r.Name from Apttus_Proposal__Proposal__c where Id = :propId];
        if(proptoUpdate.Apttus_Proposal__Account__c != null && Customers_for_Legal_Language__c.getValues(proptoUpdate.Apttus_Proposal__Account__r.Name.trim()) != null){
            isLegalLanguageProposal = true;
        }
        if(isLegalLanguageProposal){
            List<Apttus_Proposal__Proposal_Line_Item__c> quoteLines = [select Id,Name,APTS_Product_Code__c,Apttus_Proposal__Product__r.Name from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :propId order by Name];
            for(Apttus_Proposal__Proposal_Line_Item__c quoteLine : quoteLines){
                if(quoteLine.APTS_Product_Code__c != null && PRE_SKUs_for_Legal_Language__c.getValues(quoteLine.APTS_Product_Code__c.trim()) != null){
                    if(preSKUNames == '')
                        preSKUNames = quoteLine.Apttus_Proposal__Product__r.Name;
                    else
                        preSKUNames += ', ' + quoteLine.Apttus_Proposal__Product__r.Name;
                }    
            }
            if(preSKUNames != ''){
                proptoUpdate.PRE_SKUs_for_Legal_Language__c = preSKUNames;
                proptoUpdate.Show_Legal_Language_for_PRE_SKUs__c = true;
                update proptoUpdate;
            }else{
                if(proptoUpdate.Show_Legal_Language_for_PRE_SKUs__c){
                    proptoUpdate.Show_Legal_Language_for_PRE_SKUs__c = false;
                    proptoUpdate.PRE_SKUs_for_Legal_Language__c = '';
                    update proptoUpdate;
                }
            }
        }
    }
}