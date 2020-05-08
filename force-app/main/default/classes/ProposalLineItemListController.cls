public class ProposalLineItemListController {
    public Apttus_Proposal__Proposal__c proposal {get;set;}
    public Boolean isPartnerSummit {get;set;}
    public Boolean isPartnerAdjustment {get;set;}
    public list<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList {get;set;}
    public list<Apttus_Config2__AssetLineItem__c> assetLineItemList {get;set;}
    public list<Apttus_Config2__AssetLineItem__c> assetLineItemListlegacy {get;set;}
    public list<Apttus_Config2__AssetLineItem__c> assetLineItemListpartnersummit {get;set;}
    public YearWiseSplitUtil.YearWiseSplitWrapper yearWiseSplit { get; set; }
    public Map<Integer, Decimal> mapYearWiseSubTotal { get; set; }
    public List<Integer> years { get; set; }

    public ProposalLineItemListController(){
        proposal = new Apttus_Proposal__Proposal__c();
        proposalLineItemList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        assetLineItemListlegacy = new list<Apttus_Config2__AssetLineItem__c>();
        assetLineItemListpartnersummit = new list<Apttus_Config2__AssetLineItem__c>();
        yearWiseSplit = new YearWiseSplitUtil.YearWiseSplitWrapper();
        mapYearWiseSubTotal = new Map<Integer, Decimal>();
        years = new List<Integer>();
        string proposalId = ApexPages.currentPage().getParameters().get('id');
        if(proposalId != null && proposalId != ''){
            proposal = [SELECT id, 
                            Name, Total_Stackable_Margin__c, Total_Deal_Discount__c, 
                            Total_Net_to_Zscaler__c, 
                            Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c, 
                            Model_Type_Partner__c, APTS_ACV__c, Abs_Total_Discount__c, 
                            APTS_Proposal_Net_Price__c, Apttus_Proposal__Account__c, 
                            Apttus_Proposal__Account__r.Name, Number_Of_Year_Wise_Split_Years__c, 
                            Generate_Year_Wise_Split__c, Is_Year_Wise_Split_Data_Incorrect__c, 
                            Year_1_Subtotal__c, Year_2_Subtotal__c, Year_3_Subtotal__c, 
                            Year_4_Subtotal__c, Year_5_Subtotal__c 
                        FROM Apttus_Proposal__Proposal__c 
                        WHERE Id =: proposalId];
            isPartnerAdjustment = proposal.Apttus_Proposal__Opportunity__r.Partner_Margin_Adjustment__c;
            isPartnerSummit = proposal.Model_Type_Partner__c == 'Partner Summit';
            proposalLineItemList = [SELECT Id, 
                                        Apttus_QPConfig__DerivedFromId__r.Partner_Summit_Deal_Reg__c, 
                                        Apttus_QPConfig__DerivedFromId__r.AW_Margin_Formula__c, 
                                        Apttus_QPConfig__DerivedFromId__r.POV__c, 
                                        Apttus_QPConfig__DerivedFromId__r.Fulfilment_Margin__c,
                                        Apttus_QPConfig__DerivedFromId__r.Partner_Adjustment__c, 
                                        Apttus_QPConfig__DerivedFromId__r.Partner_Adjustment_Type__c, 
                                        Apttus_QPConfig__DerivedFromId__r.Total_Stackable_Margin__c, 
                                        Apttus_QPConfig__DerivedFromId__r.Net_to_Zscaler__c, 
                                        Apttus_QPConfig__DerivedFromId__r.Total_Zscaler_Discount__c, 
                                        APTS_Product_Code__c, 
                                        Apttus_Proposal__Product__r.Name,
                                        Apttus_Proposal__Product__c, 
                                        Apttus_QPConfig__BasePrice__c, 
                                        Apttus_QPConfig__Quantity2__c,APTS_Quantity__c, 
                                        Apttus_QPConfig__StartDate__c,Apttus_QPConfig__EndDate__c, 
                                        APTS_Selling_Term__c, 
                                        APTS_Base_Price_override__c, 
                                        APTS_Partner_Disc__c, APTS_Deal_Reg_Disc__c, 
                                        APTS_New_Logo_Disc__c, Apttus_QPConfig__AdjustmentType__c, 
                                        APTS_Manual_Discount__c, APTS_Total_Discount_Percentage__c, 
                                        APTS_Net_Price__c, APTS_ACV__c, APTS_MRR__c, 
                                        Term_to_Show__c,Product_Name__c 
                                    FROM Apttus_Proposal__Proposal_Line_Item__c 
                                    WHERE Apttus_Proposal__Proposal__c =: proposalId];

            if (proposal.Generate_Year_Wise_Split__c) {
                yearWiseSplit = YearWiseSplitUtil.getYearWiseSplitsList(proposal.Id);
            }

            if(proposal != null && proposal.Apttus_Proposal__Account__c != null ){
                assetLineItemListlegacy = [SELECT id, 
                                                Net_to_Zscaler__c, 
                                                Total_Stackable_Margin__c, Total_Zscaler_Discount__c, 
                                                AW_Margin_Formula__c,Partner_Summit_Deal_Reg__c, 
                                                Fulfilment_Margin__c,  POV__c, 
                                                Product_Code__c, Apttus_Config2__BasePrice__c, 
                                                Apttus_Config2__Quantity__c, 
                                                Apttus_Config2__StartDate__c, 
                                                Apttus_Config2__EndDate__c, APTS_Deal_Reg_Disc__c, 
                                                APTS_Selling_Term__c, Apttus_Config2__ListPrice__c, 
                                                APTS_Partner_Disc__c, APTS_New_Logo_Disc__c, 
                                                Adjustment_Type__c, Adjustment_Amount__c, 
                                                APTS_Total_Discount_Percentage__c, 
                                                Apttus_Config2__NetPrice__c, APTS_ACV__c, 
                                                APTS_MRR__c, Term_to_Show__c, Product_Name__c  
                                            FROM Apttus_Config2__AssetLineItem__c 
                                            WHERE Apttus_Config2__AccountId__c =: proposal.Apttus_Proposal__Account__c 
                                            AND Apttus_Config2__AssetStatus__c =: 'Activated' 
                                            AND Partner_Program__c != 'Partner Summit'];
                assetLineItemListpartnersummit = [SELECT id, 
                                                        Net_to_Zscaler__c, 
                                                        Total_Stackable_Margin__c, 
                                                        Total_Zscaler_Discount__c, 
                                                        AW_Margin_Formula__c, 
                                                        Partner_Summit_Deal_Reg__c, 
                                                        Fulfilment_Margin__c, POV__c, 
                                                        Product_Code__c, 
                                                        Apttus_Config2__BasePrice__c, 
                                                        Apttus_Config2__Quantity__c, 
                                                        Apttus_Config2__StartDate__c, 
                                                        Apttus_Config2__EndDate__c, 
                                                        APTS_Deal_Reg_Disc__c, 
                                                        APTS_Selling_Term__c, 
                                                        Apttus_Config2__ListPrice__c, 
                                                        APTS_Partner_Disc__c, 
                                                        APTS_New_Logo_Disc__c, 
                                                        Adjustment_Type__c, Adjustment_Amount__c,
                                                        APTS_Total_Discount_Percentage__c, 
                                                        Apttus_Config2__NetPrice__c, APTS_ACV__c, 
                                                        APTS_MRR__c, Term_to_Show__c, 
                                                        Product_Name__c  
                                                    FROM Apttus_Config2__AssetLineItem__c 
                                                    WHERE Apttus_Config2__AccountId__c =: proposal.Apttus_Proposal__Account__c 
                                                    AND Apttus_Config2__AssetStatus__c =: 'Activated' 
                                                    AND Partner_Program__c = 'Partner Summit'];
            }
        }
    }
}