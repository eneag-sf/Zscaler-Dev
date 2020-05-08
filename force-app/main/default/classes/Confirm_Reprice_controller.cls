public class Confirm_Reprice_controller{
    public Map<String,string> urlparams;    
    public Boolean isReprice{get;set;}  
    public Boolean iscoSellmodified{get;set;}  
    public Boolean isSwitchPL{get;set;} 
    public Boolean isOldDas{get;set;} 
    public Boolean isPartnerProgramMismatch{get;set;} 
    public String quoteId{get;set;} 
    public String partnerProgram{get;set;} 
    public String accountId{get;set;} 
    public String pricelistApplied{get;set;} 
    public list<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList {get;set;}
    public List<Apttus_Proposal__Proposal__c> proplst = new List<Apttus_Proposal__Proposal__c>();
    public list<Apttus_Config2__AssetLineItem__c> assetLineItemList {get;set;}
    public Confirm_Reprice_controller(){
        urlparams = ApexPages.currentPage().getParameters();
        quoteId = urlparams.get('confirmrepricequoteid');
        assetLineItemList = new list<Apttus_Config2__AssetLineItem__c>();
    }
    public Pagereference onCancel(){
        return new Pagereference('/'+(urlparams.get('confirmrepricequoteid') != null ? urlparams.get('confirmrepricequoteid') : ''));

    }
    public Pagereference onConfirm(){
        String returl = '/apex/RepriceApttusProposals?proposalIds='+urlparams.get('confirmrepricequoteid');
        if(urlparams != null && urlparams.containskey('backtoVF') && urlparams.get('backtoVF') != null){
            urlparams.remove('confirmrepricequoteid');
            urlparams.remove('backtoVF');
            for(String s: urlparams.keyset()){
                if(s != null && urlparams.get(s) != null && !s.contains('com.salesforce') && !urlparams.get(s).contains('Confirm'))
                    returl += '&'+s+'=' + urlparams.get(s);
            }
            system.debug('++++'+returl);
        }
        return new Pagereference(returl);
    }
    public Pagereference init(){
        if(quoteId != null && quoteId != ''){
            proplst = [Select Id, Apttus_Proposal__Account__c, Model_Type_Partner__c, SelectedFlow__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.Applied_Price_List_Name__c, Co_Sell_Partner_Modified__c, Needs_Repricing__c, Must_Switch_PriceList__c, Ignore_Quote_Reprice_Pricelist_Switch__c, Price_List_Name__c, RecordType.Name, Block_Old_DAS__c, Apttus_QPConfig__BillToAccountId__c, (Select Id from R00N70000001yUfBEAU__r where APTS_Product_Code__c like'ZSUITE%' and Apttus_QPConfig__LineStatus__c != 'Cancelled') from Apttus_Proposal__Proposal__c where Id = :quoteId];
            proposalLineItemList = [Select Id, APTS_Product_Code__c, Apttus_Proposal__Product__r.Name, Apttus_Proposal__Product__c, Apttus_QPConfig__BasePrice__c, Apttus_QPConfig__Quantity2__c, APTS_Quantity__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_Selling_Term__c, APTS_Base_Price_override__c, APTS_Partner_Disc__c, APTS_Deal_Reg_Disc__c, APTS_New_Logo_Disc__c, Apttus_QPConfig__AdjustmentType__c, APTS_Manual_Discount__c, APTS_Total_Discount_Percentage__c, APTS_Net_Price__c, APTS_ACV__c, APTS_MRR__c, Term_to_Show__c,Product_Name__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c =: quoteId];
            
            if(!proplst.isEmpty()){
                List<Opportunity_Partner__c> opppartlst = [Select Id, Partner_Program__c from Opportunity_Partner__c where Opportunity__c = :proplst[0].Apttus_Proposal__Opportunity__c and Account__c = :proplst[0].Apttus_QPConfig__BillToAccountId__c and Partner_Type__c = 'Reseller'];
                
                accountId = proplst[0].Apttus_Proposal__Account__c;
                pricelistApplied = proplst[0].Apttus_Proposal__Opportunity__r.Applied_Price_List_Name__c != null ? proplst[0].Apttus_Proposal__Opportunity__r.Applied_Price_List_Name__c : 'FY20 Pricelist';
                assetLineItemList = [Select id, Product_Code__c, Apttus_Config2__BasePrice__c, Apttus_Config2__Quantity__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, APTS_Deal_Reg_Disc__c, APTS_Selling_Term__c, Apttus_Config2__ListPrice__c, APTS_Partner_Disc__c, APTS_New_Logo_Disc__c, Adjustment_Type__c, Adjustment_Amount__c, APTS_Total_Discount_Percentage__c, Apttus_Config2__NetPrice__c, APTS_ACV__c, APTS_MRR__c, Term_to_Show__c, Product_Name__c  FROM Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c =: proplst[0].Apttus_Proposal__Account__c AND Apttus_Config2__AssetStatus__c =: 'Activated'];
                if(!opppartlst.isEmpty() && opppartlst[0].Partner_Program__c != proplst[0].Model_Type_Partner__c){
                    isPartnerProgramMismatch = true;
                    partnerProgram = opppartlst[0].Partner_Program__c;
                }else if(proplst[0].Price_List_Name__c == 'ZScaler FY2017 Price List'){
                    isSwitchPL = true;
                }else if(proplst[0].Must_Switch_PriceList__c && !proplst[0].R00N70000001yUfBEAU__r.isEmpty()){
                    isSwitchPL = true;
                }else if(proplst[0].Co_Sell_Partner_Modified__c && !proposalLineItemList.isEmpty()){
                    iscoSellmodified = true;
                }else if(proplst[0].Needs_Repricing__c && !proposalLineItemList.isEmpty()){
                    isReprice = true;
                }else if(proplst[0].Block_Old_DAS__c){
                    isOldDas = true;
                }else{
                    Map<String,string> urlparams_copy = urlparams;
                    urlparams_copy.remove('confirmrepricequoteid');
                    urlparams_copy.remove('backtoVF');
                    String returl = urlparams_copy.get('retURL');
                    urlparams_copy.remove('retURL');
                    for(String s: urlparams_copy.keyset()){
                        if(s != null && urlparams_copy.get(s) != null && !s.contains('com.salesforce'))
                            returl += '&'+s+'=' + urlparams.get(s);
                    }
                    return new Pagereference(returl);
                    
                }
                
            }
        }
        return null;
    }
    public pagereference partnerprogSwitch(){
        if(!proplst.isEmpty()){
            Opportunity opp = new Opportunity(Id = proplst[0].Apttus_Proposal__Opportunity__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(opp);
            
            ApttusSelectPriceListController ctrl = new ApttusSelectPriceListController(controller);
            ctrl.proposalId = proplst[0].Id;
            ctrl.selectedPriceListId = proplst[0].Price_List_Name__c == null ? 'ZScaler FY2020 Price List' : proplst[0].Price_List_Name__c;
            ctrl.isPriceListSwitchMode  = true;
            ctrl.partnerProgram  = partnerProgram;
            ctrl.ispartnerProgramChange  = true;
            ctrl.mapPriceLists = new Map<String, Id>();
            for (Apttus_Config2__PriceList__c priceList : [SELECT Id, Name FROM Apttus_Config2__PriceList__c WHERE Apttus_Config2__Active__c = true AND Name = :ctrl.selectedPriceListId]) {
                ctrl.mapPriceLists.put(priceList.Name, priceList.Id);
            }
            ctrl.proceed();
            return new Pagereference(cartpage(proplst[0]));
             
        }
        return null;
    }
    public pagereference onSwitchPL(){
        if(!proplst.isEmpty()){
            Opportunity opp = new Opportunity(Id = proplst[0].Apttus_Proposal__Opportunity__c);
            ApexPages.StandardController controller = new ApexPages.StandardController(opp);
            
            ApttusSelectPriceListController ctrl = new ApttusSelectPriceListController(controller);
            ctrl.proposalId = proplst[0].Id;
            ctrl.selectedPriceListId = 'ZScaler FY2020 Price List';
            ctrl.isPriceListSwitchMode  = true;
            ctrl.mapPriceLists = new Map<String, Id>();
            for (Apttus_Config2__PriceList__c priceList : [SELECT Id, Name FROM Apttus_Config2__PriceList__c WHERE Apttus_Config2__Active__c = true AND Name = 'ZScaler FY2020 Price List']) {
                ctrl.mapPriceLists.put(priceList.Name, priceList.Id);
            }
            ctrl.proceed();
            /*Map<String,string> urlparams_copy = urlparams;
            urlparams_copy.remove('confirmrepricequoteid');
            urlparams_copy.remove('backtoVF');
            String returl = urlparams_copy.get('retURL');
            urlparams_copy.remove('retURL');
            for(String s: urlparams_copy.keyset()){
                if(s != null && urlparams_copy.get(s) != null && !s.contains('com.salesforce'))
                    returl += '&'+s+'=' + urlparams.get(s);
            }
            return new Pagereference(returl);*/
            return new Pagereference(cartpage(proplst[0]));
             
        }
        return null;
    }
    
    public PageReference taketoCart(){
        return new Pagereference(cartpage(proplst[0]));
    }
    
    public String cartpage(Apttus_Proposal__Proposal__c prop){
        prop = [Select Id, Apttus_Proposal__Account__c, Model_Type_Partner__c, SelectedFlow__c, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Opportunity__r.Applied_Price_List_Name__c, Co_Sell_Partner_Modified__c, Needs_Repricing__c, Must_Switch_PriceList__c, Ignore_Quote_Reprice_Pricelist_Switch__c, Price_List_Name__c, RecordType.Name, Block_Old_DAS__c, Apttus_QPConfig__BillToAccountId__c, (Select Id from R00N70000001yUfBEAU__r where APTS_Product_Code__c like'ZSUITE%' and Apttus_QPConfig__LineStatus__c != 'Cancelled') from Apttus_Proposal__Proposal__c where Id = :prop.Id];
        if(prop.RecordType.Name == 'Renewal'){
            return '/apex/Apttus_QPAsset__ProposalConfiguration?flow=' + prop.SelectedFlow__c + '&id=' + prop.Id + '&mode=addon';
        }else{
            return '/apex/Apttus_QPConfig__ProposalConfiguration?id=' + prop.Id + '&useDealOptimizer=true&useAdvancedApproval=true&flow=' + prop.SelectedFlow__c;
        }
    }
}