public class APTS_CreateApttusQuoteController {

    public string QuoteId {get;set;}
    public static string quoteIdArraystring {get;set;}

    public static Map<string,SBQQ__Quote__c> sbQuoteMap;
    public static List<APTS_Create_Apttus_Quote_Setting__c> fieldMapSetting;
    public static Map<string,List<SBQQ__QuoteLine__c>> sbQuoteLineMap;
    public static Map<Id,Id> productToReplaceMap;
    public static Map<string, string> recordTypeMap;
    public static string  pricelistid;
    public static set<id> pricelistProductIdset;
    public static string accountId;
    
    static{
        List<SBQQ__Quote__c> sbQuoteList = new List<SBQQ__Quote__c>  ();
        pricelistProductIdset = new set<id> ();
        String querystring = 'SELECT id, Name,';
        //getQueryStringWithAllFields('SBQQ__Quote__c','Migrate_to_Apttus__c=true');
        fieldMapSetting = new List<APTS_Create_Apttus_Quote_Setting__c> ();
        fieldMapSetting = APTS_Create_Apttus_Quote_Setting__c.getall().values();
        
        List<RecordType> ProposalRecordTypeList = new List<RecordType> ();
        Set<String> recordtypeNameSet = new Set<String>{'New Business','Renewal','Upsell'};
        ProposalRecordTypeList = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE AND sObjectType ='Apttus_Proposal__Proposal__c' AND Name IN:recordtypeNameSet];
        
        recordTypeMap = new Map<string, string> ();
        
        List<Account> accountlist = new List<Account>();
        accountlist = [select id from account where name = 'Zscaler'];
        
        if(accountlist.size() > 0) {
            accountId = accountlist[0].id;
        }
        
        for(RecordType rc : ProposalRecordTypeList) {
            if(rc.Name == 'New Business') {
                recordTypeMap.put('New Business',rc.id);
            }
            
            if(rc.Name == 'Renewal') {
                recordTypeMap.put('Existing Customer (Add On)',rc.id);
            }
            
            if(rc.Name == 'Upsell') {
                recordTypeMap.put('Existing Customer (Renewal)',rc.id);
            }
        }
        
                            
        for(APTS_Create_Apttus_Quote_Setting__c field : fieldMapSetting ) {
            if(querystring.toLowerCase().indexOf(field.APTS_SBQuote_Field_API__c.toLowercase()) == -1)
            querystring =  querystring + field.APTS_SBQuote_Field_API__c + ',';
        }
        
        querystring = querystring + 'SBQQ__Opportunity2__r.Type,SBQQ__Opportunity2__r.Price_List__c from SBQQ__Quote__c where Migrate_to_Apttus__c=true';
        
        sbQuoteList = Database.query(querystring);
        
        sbQuoteMap = new Map<string,SBQQ__Quote__c> (sbQuoteList);
        
        
        set<string> sbquoteIdset = new set<string>();
        
        
        for(SBQQ__Quote__c sbq : sbQuoteList) {
            
            sbquoteIdset.add(sbq.id);
            sbQuoteMap.put(string.valueof(sbq.id),sbq);
        }
        quoteIdArraystring = JSON.serialize(sbquoteIdset);
        
        
        List<Apttus_Config2__PriceList__c> pricelist = new List<Apttus_Config2__PriceList__c> ();
        pricelist = [select id from Apttus_Config2__PriceList__c where Name='ZScaler Price List'];
        
        if(pricelist.size() > 0) {
            pricelistid = pricelist[0].id;
        }
        
        List<Apttus_Config2__PriceListItem__c> pricelistItem = new List<Apttus_Config2__PriceListItem__c> ();
        pricelistItem = [select id,Name,Apttus_Config2__ProductId__c from Apttus_Config2__PriceListItem__c where Apttus_Config2__PriceListId__c = :pricelistid];
        
        for(Apttus_Config2__PriceListItem__c pli: pricelistItem ) {
            pricelistProductIdset.add(pli.Apttus_Config2__ProductId__c );
        }
        
        List<SBQQ__QuoteLine__c> quoteLineItemListOld = new List<SBQQ__QuoteLine__c> ();
        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c> ();
        quoteLineItemListOld = [select id,Name,SBQQ__Quote__r.Name,Manual_Discount_for_Apttus2__c,SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__Product__c,Start_Date__c,End_Date__c,SBQQ__SubscriptionTerm__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.pricebook2Id from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:sbquoteIdset AND SBQQ__Optional__c=false AND SBQQ__Product__c IN :pricelistProductIdset AND (NOt SBQQ__ProductCode__c like '%Bundle%') AND (Not SBQQ__ProductName__c like '%Bundle%')];
        
        sbQuoteLineMap = new Map<string,List<SBQQ__QuoteLine__c>> () ;
        
        List<SBQQ__QuoteLine__c>  sbqList;
        Set<id> productIdset = new set<id>();
        
        for(SBQQ__QuoteLine__c sbql : quoteLineItemListOld) {
            productIdset.add(sbql.SBQQ__Product__c);
        }
        
        List<PricebookEntry> pricebookentrylist = new List<PricebookEntry>();
        pricebookentrylist = [Select Id,Name,IsActive,Pricebook2Id,Product2Id From PricebookEntry
                                                        Where Product2Id IN :productIdset AND IsActive=True ];
        Map<string,List<PricebookEntry>> pricebookentryMap = new Map<string,List<PricebookEntry>> ();
        
        List<PricebookEntry> pbelist;
        
        for(PricebookEntry pbe : pricebookentrylist) {
            pbelist = new List<PricebookEntry>();
            if(pricebookentryMap.get(string.valueof(pbe.Pricebook2Id).substring(0,15)) != null) {
                pbelist = pricebookentryMap.get(string.valueof(pbe.Pricebook2Id).substring(0,15));
            }
            pbelist.add(pbe);
            pricebookentryMap.put((string.valueof(pbe.Pricebook2Id).substring(0,15)),pbelist);
        }
        
        for(SBQQ__QuoteLine__c sbql : quoteLineItemListOld) {
            Boolean include = false;
            if(sbql.SBQQ__Quote__r.SBQQ__Opportunity2__r.pricebook2Id != null) {
                if(pricebookentryMap.get(string.valueOf(sbql.SBQQ__Quote__r.SBQQ__Opportunity2__r.pricebook2Id).substring(0,15)) != null) {
                    for(PricebookEntry pbe :pricebookentryMap.get(string.valueOf(sbql.SBQQ__Quote__r.SBQQ__Opportunity2__r.pricebook2Id).substring(0,15))) {
                        if(string.valueof(sbql.SBQQ__Product__c).substring(0,15) ==  string.valueOf(pbe.Product2Id).substring(0,15)) {
                            include = true;
                        }
                    }
                }
            } else {
                include = true;
            }
            if(include) {
                quoteLineItemList.add(sbQL);
            }
        }
        
        for(SBQQ__QuoteLine__c sbql : quoteLineItemList) {
            sbqList = new List<SBQQ__QuoteLine__c> ();
            if(sbQuoteLineMap.get(string.valueOf(sbql.SBQQ__Quote__c)) != null) {
                sbqList = sbQuoteLineMap.get(string.valueOf(sbql.SBQQ__Quote__c));
            }
            sbqList.add(sbQL);
            sbQuoteLineMap.put(string.valueOf(sbql.SBQQ__Quote__c),sbqList);
        }
        
        List<Product2> existingProducts = [Select Id, Name, ProductCode From Product2 Where Family = 'Products'];
        List<Product2> newProducts = [Select Id, Name, ProductCode From Product2 Where Family = 'Zscaler Products'];
        productToReplaceMap = new Map<Id,Id>();
        
        for(Product2 existingProduct : existingProducts){
            for(Product2 newProduct : newProducts){
                if(existingProduct.ProductCode == newProduct.ProductCode){
                    productToReplaceMap.put(existingProduct.Id, newProduct.Id);
                    break;
                }
            }
        }
    }

    @RemoteAction
    public static void deleteOldProposal(string quoteId) {
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c >();
        proposalList  = [select id,name,APTS_SBQuote_Id__c from Apttus_Proposal__Proposal__c where APTS_SBQuote_Id__c=:sbQuoteMap.get(quoteId).Name];
        if(proposallist.size() > 0)
        delete proposallist;

    }
    
    
    @RemoteAction
    public static string createproposal (string quoteId) {
        SBQQ__Quote__c sbQuote = sbQuoteMap.get(quoteId);
       
       
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c ();
        
        if(recordTypeMap.containskey(sbQuote.SBQQ__Opportunity2__r.Type)) {
            prop.recordtypeid = recordTypeMap.get(sbQuote.SBQQ__Opportunity2__r.Type);
        }
        
        for(APTS_Create_Apttus_Quote_Setting__c field : fieldMapSetting ) {
            prop.put(field.APTS_Apttus_Quote_Field_API__c, sbQuote.get(field.APTS_SBQuote_Field_API__c));
        }
        
        if(sbQuote.SBQQ__Opportunity2__r.Price_List__c != null) {
            prop.Apttus_QPConfig__PriceListId__c = sbQuote.SBQQ__Opportunity2__r.Price_List__c;
        }
        else {
            prop.Apttus_QPConfig__PriceListId__c = pricelistid;
        }
        if(sbQuote.SBQQ__Partner__c == null) {
            prop.Apttus_QPConfig__BillToAccountId__c = accountid;
        }
        
        system.debug('@@@');
        system.debug(prop);
        prop.APTS_SBQuote_Id__c = sbQuote.Name;
        prop.ownerId = UserInfo.getUserId();
        insert prop;
        return prop.Id;
    }
    
    @RemoteAction
    public static string CreateCartForProposal(string proposalId) {
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposalId;
        Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
        return response.CartId;
    }
    
    @RemoteAction 
    public static Integer CreateCartlineItem (string cartId, string sbQuoteId) {
        
        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c> ();
        quoteLineItemList = sbQuoteLineMap.get(sbQuoteId);
        
        if(quoteLineItemList != null && quoteLineItemList.size() > 0) {
           
            
            List<Apttus_CPQApi.CPQ.SelectedProductDO> selectedProducts=new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
            Apttus_CPQApi.CPQ.SelectedProductDO product;
            
            for(SBQQ__QuoteLine__c sbQL : quoteLineItemList) {
                product=new Apttus_CPQApi.CPQ.SelectedProductDO();
                if(productToReplaceMap.get(sbQL.SBQQ__Product__c) != null) {
                    product.Productid = productToReplaceMap.get(sbQL.SBQQ__Product__c);
                } else {
                    product.Productid = sbQL.SBQQ__Product__c;
                }
                if(sbQL.SBQQ__SubscriptionTerm__c != null) {
                    product.SellingTerm = (sbQL.SBQQ__SubscriptionTerm__c)/12;
                }
                
                product.Quantity = sbQL.SBQQ__Quantity__c;
                selectedProducts.add(product);
            }
            
            
            Apttus_CPQApi.CPQ.AddMultiProductRequestDO products=new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
            products.cartId=cartID;
            products.SelectedProducts=selectedProducts;
           
            Apttus_CPQApi.CPQ.AddMultiProductResponseDO productsRes=Apttus_CPQApi.CPQWebService.addMultiProducts(products);
            
            List<Decimal> lineNumbers = productsRes.LineNumbers;
             
            return quoteLineItemList.size();
        } 
        return 0;
    }
    
    
    @RemoteAction 
    public static boolean updatelineitem (string cartid, string sbQuoteId,Integer count) {
        
        List<Apttus_Config2__LineItem__c> lineItems = [select id,Apttus_Config2__SellingFrequency__c ,APTS_ProductCode__c,Apttus_Config2__AttributeValueId__c,Apttus_Config2__StartDate__c,Apttus_Config2__EndDate__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__AdjustmentType__c,APTS_Manual_Discount__c,Apttus_Config2__ProductId__c  
                                                        FROM Apttus_Config2__LineItem__c
                                                        WHERE Apttus_Config2__ConfigurationId__c=:cartID];
        Map<id,string> attributeIdMap = new Map<id,string>();
        if(count != lineItems.size()) {
            return false;
        } else {
            List<Apttus_Config2__ProductAttributeValue__c> attributevalueToUpdate = new List<Apttus_Config2__ProductAttributeValue__c> ();  
            for(Apttus_Config2__LineItem__c litem: lineItems) {
               
               if(litem.APTS_ProductCode__c == 'ZCES-SUP-PREM') {
                   attributeIdMap.put(litem.Apttus_Config2__AttributeValueId__c,'Zscaler');
             
               }
               
               if(litem.APTS_ProductCode__c  =='ZCES-SUP-PREM-SP') {
                  attributeIdMap.put(litem.Apttus_Config2__AttributeValueId__c, 'Partner Qualified Support');
               }
               litem.Apttus_Config2__PricingStatus__c ='pending';        
            }
            if(attributeIdMap.size() > 0) {
                attributevalueToUpdate = [select id,name,APTS_Premium_Support_Type__c  from Apttus_Config2__ProductAttributeValue__c where id IN: attributeIdMap.keyset()];
                for (Apttus_Config2__ProductAttributeValue__c attr : attributevalueToUpdate ) {
                    attr.APTS_Premium_Support_Type__c  = attributeIdMap.get(attr.id);
                }
                update attributevalueToUpdate;
                
            }
            update lineItems;
            return true;
        }
        return true;
    }
    
    
    
    @RemoteAction 
    public static void updateTermOnlineitem (string cartid, string sbQuoteId) {
        
        List<Apttus_Config2__LineItem__c> lineItems = [select id,Apttus_Config2__SellingFrequency__c ,Apttus_Config2__StartDate__c,Apttus_Config2__EndDate__c,Apttus_Config2__PricingStatus__c,Apttus_Config2__AdjustmentType__c,APTS_Manual_Discount__c,Apttus_Config2__ProductId__c  
                                                        FROM Apttus_Config2__LineItem__c
                                                        WHERE Apttus_Config2__ConfigurationId__c=:cartID];
     
    
            
            
            List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c> ();
            quoteLineItemList = sbQuoteLineMap.get(sbQuoteId);
            
            Map<string , SBQQ__QuoteLine__c> sbQuoteLiProductMap = new Map<string , SBQQ__QuoteLine__c> ();
                for (SBQQ__QuoteLine__c sbql : quoteLineItemList) {
                    if(productToReplaceMap.get(sbQL.SBQQ__Product__c) != null) {
                        sbQuoteLiProductMap.put(string.valueOf(productToReplaceMap.get(sbQL.SBQQ__Product__c)).substring(0,15),sbql); 
                        
                    } else {
                        sbQuoteLiProductMap.put(string.valueOf(sbql.SBQQ__Product__c).substring(0,15),sbql); 
                    }
                    
                    
                }
            
            
    
            system.debug('@@@@@sbQuoteLiProductMap :'+sbQuoteLiProductMap);
            
            for(Apttus_Config2__LineItem__c litem: lineItems) {
               litem.Apttus_Config2__PricingStatus__c ='pending'; 
               system.debug('litem.Apttus_Config2__ProductId__c'+litem.Apttus_Config2__ProductId__c);
               
               system.debug('111--'+sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)));
               system.debug('222--'+sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Manual_Discount_for_Apttus2__c);
               
               if(sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)) != null) {
                   litem.APTS_Line_Item_Name__c = sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).SBQQ__Quote__r.Name + ' > '+ sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Name;
                   system.debug('333--');
                   litem.Apttus_Config2__Quantity__c =  sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).SBQQ__Quantity__c;
                   if(sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Manual_Discount_for_Apttus2__c != null) {
                       system.debug('444--');
                       litem.APTS_Manual_Discount__c = sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Manual_Discount_for_Apttus2__c;
                       litem.Apttus_Config2__AdjustmentType__c = '% Discount';
                   }
                   if(sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).SBQQ__SubscriptionTerm__c != null) {
                       system.debug('555--');
                       if(sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Start_Date__c != null) {
                           litem.Apttus_Config2__StartDate__c = sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).Start_Date__c;
                       }
                       if(litem.Apttus_Config2__StartDate__c != null)
                       litem.Apttus_Config2__EndDate__c  = litem.Apttus_Config2__StartDate__c.addMonths(Integer.valueof(sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).SBQQ__SubscriptionTerm__c));
                       litem.Apttus_Config2__SellingTerm__c = sbQuoteLiProductMap.get(string.valueof(litem.Apttus_Config2__ProductId__c).substring(0,15)).SBQQ__SubscriptionTerm__c / 12;
                       system.debug('$$$litem--'+litem);
                   }
                    
               }
            }
            update lineItems;
   
    }
    
    
    
    
    @RemoteAction 
     public static boolean repriceCart (String cartId) {
    
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        objUpdatePriceRequestDO.CartId = cartID;
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
        return result.IsPricePending;
    }


    @RemoteAction 
    
    public static void finalizeCart (string cartId) {
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
        request.CartId = CartId;
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
    }

  
}