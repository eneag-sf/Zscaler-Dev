public class PLIExportExcel_Ctrl {

    public List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList { get; set; }
    public list<Apttus_Config2__AssetLineItem__c> assetLineItemList {get;set;}
    
    public PLIExportExcel_Ctrl (){
        assetLineItemList = new list<Apttus_Config2__AssetLineItem__c>();
        if(ApexPages.currentpage().getparameters().get('payload') != ''){
            proposalLineItemList = [Select Id, APTS_Product_Code__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__c, Apttus_QPConfig__BasePrice__c, Apttus_QPConfig__Quantity2__c, APTS_Quantity__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_Selling_Term__c, APTS_Base_Price_override__c, APTS_Partner_Disc__c, APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c, Apttus_QPConfig__AdjustmentType__c, APTS_Manual_Discount__c, APTS_Total_Discount_Percentage__c, APTS_Net_Price__c, APTS_ACV__c, APTS_MRR__c, Term_to_Show__c,Product_Name__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =: ApexPages.currentpage().getparameters().get('payload')];
            
        }
        if(ApexPages.currentpage().getparameters().get('accId') != ''){
            assetLineItemList = [Select id, Product_Code__c, Apttus_Config2__BasePrice__c, Apttus_Config2__Quantity__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, APTS_Deal_Reg_Disc__c, APTS_Selling_Term__c, Apttus_Config2__ListPrice__c, APTS_Partner_Disc__c, APTS_New_Logo_Disc__c, Adjustment_Type__c, Adjustment_Amount__c, APTS_Total_Discount_Percentage__c, Apttus_Config2__NetPrice__c, APTS_ACV__c, APTS_MRR__c, Term_to_Show__c, Product_Name__c  FROM Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c =: ApexPages.currentpage().getparameters().get('accId') AND Apttus_Config2__AssetStatus__c =: 'Activated'];
            
        }
        
    }
}