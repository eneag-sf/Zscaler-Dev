/**
 * Util class for Asset related methods. 
 * Author : Sagar Jogi
 ***********************************************************************************************
 * Modification Log
 ***********************************************************************************************
 * Harish Emmadi, 01/04/2017 - Updated renewIndividualAssetLineItem to populate ramp end date - [ZSCAL-281]
 ***********************************************************************************************
*/
public class APTSCU_AssetUtils {

    /*
      public static void renewAssetLineItem (List<Apttus_Config2__AssetLineItem__c> assetLineItems, String cartId) {
          system.debug('123456***');
          Map<String,Apttus_Config2__AssetLineItem__c> assetMap = new Map<String,Apttus_Config2__AssetLineItem__c> ();
          Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap = new Map<Id,Apttus_Config2__AssetLineItem__c> ();
          Apttus_Config2__AssetLineItem__c oldAsset;
          
         
          Apttus_Config2__ProductConfiguration__c prodConfig = [Select Id, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c From Apttus_Config2__ProductConfiguration__c Where Id = :cartId];
          Map<String,Decimal> assetQuantityMap = new Map<String,Decimal>();
          for(Apttus_Config2__AssetLineItem__c asset :assetLineItems) {
              allAssetMap.put(asset.Id, asset);
              if(assetMap.containsKey(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15))) {
                  oldAsset = assetMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)); 
                  if(asset.CreatedDate > oldAsset.CreatedDate) {
                      assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                      assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));                   
                  } else {
                       assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));
                  }
              } else {
                  assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                  assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c);                   
                           
              }
          }
          
          system.debug('jogijogi - '+assetMap);
          
          Set<Id> assetToIgnore = new Set<Id>();
          for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
              if(asset.Apttus_Config2__BundleAssetId__c != null){
                  assetToIgnore.add(asset.Apttus_Config2__BundleAssetId__c);
              }
          }
         
          List<Apttus_CPQApi.CPQ.AssetActionDO> assetActDOList = new List<Apttus_CPQApi.CPQ.AssetActionDO>();
          Apttus_CPQApi.CPQ.AssetActionDO assetActDO;
          for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
              if(assetToIgnore.contains(asset.Id)){
                  continue;
              }
              assetActDO  = new Apttus_CPQApi.CPQ.AssetActionDO();
              assetActDO.AssetAction = 'Renew';
              
              if(asset.Apttus_Config2__IsPrimaryLine__c){
                  assetActDO.AssetLineItemId = asset.Id;
              }else{
                  assetActDO.AssetLineItemId = asset.Apttus_Config2__BundleAssetId__c;
              }
            
              assetActDO.Pending = true;
              assetActDO.Quantity = allAssetMap.get(assetActDO.AssetLineItemId).Apttus_Config2__Quantity__c;//assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              assetActDO.StartDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c;//asset.Apttus_Config2__EndDate__c.addDays(1);
              assetActDO.EndDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;//asset.Apttus_Config2__EndDate__c.addMonths(36);
      
              assetActDO.customFields.add('Apttus_Config2__Comments__c');
              assetActDO.customFields.add('Apttus_Config2__PricingStatus__c');
              assetActDO.customFields.add('APTS_Renewal_Quantity__c');
              
              Apttus_Config2__LineItem__c liSO = new Apttus_Config2__LineItem__c();
              liSO.Apttus_Config2__Comments__c = 'Comments Added my Modify Asset API Code';
              liSO.Apttus_Config2__PricingStatus__c = 'Pending';
              liSO.APTS_Renewal_Quantity__c = assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              assetActDO.CustomData=liSO;
              assetActDOList.add(assetActDO);
             
          }
            Apttus_CPQApi.CPQ.ModifyAssetRequestDO modifyRequest = new Apttus_CPQApi.CPQ.ModifyAssetRequestDO();
              modifyRequest.CartId = cartId;
              modifyRequest.AssetActions = assetActDOList;
              system.debug('######Before'+modifyRequest);
              //create line items on the cart
              Apttus_CPQApi.CPQ.ModifyAssetResponseDO modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
              System.debug('###Line Numbers:'+modifyReponse.LineNumbers);
              
              
              // Start modification for asset status is completed or not 
              
              List<Apttus_CPQApi.CPQ.AssetActionDO> assetList = modifyReponse.AssetActions;
              Boolean bIsPending = false;
              Integer iCounter = 0;
              while (iCounter < 1000){
                  bIsPending = false;
                  for(Apttus_CPQApi.CPQ.AssetActionDO objAsset: assetList){
                      if(objAsset.Pending == true){
                          bIsPending = true;
                          break;
                      }
                  }
              //If asset Action is pending execute the following loop
                  if(bIsPending == true){
                      modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
                      //lineNumberList = modifyReponse.LineNumbers;
                      //assetList = modifyReponse.AssetActions;
                  }else{
                      break;
                  }
                  iCounter++;
              }
      
          system.debug('######After'+modifyReponse);
       
      }  
      
      
      public static void renewAssetLineItemRemote (List<Apttus_Config2__AssetLineItem__c> assetLineItems, String cartId,Boolean insertPremierSupport,string productId) {
          system.debug('1234567***');
          if(insertPremierSupport) {
              Apttus_CPQApi.CPQ.SelectedProductDO product=new Apttus_CPQApi.CPQ.SelectedProductDO();
              product.Productid=productId;
              product.Quantity = 1;
              List<Apttus_CPQApi.CPQ.SelectedProductDO> selectedProducts=new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
              selectedProducts.add(product);
              
              Apttus_CPQApi.CPQ.AddMultiProductRequestDO products=new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
              products.cartId=cartID;
              products.SelectedProducts=selectedProducts;
              System.debug('*** cartID : '+cartID);
              Apttus_CPQApi.CPQ.AddMultiProductResponseDO productsRes=Apttus_CPQApi.CPQWebService.addMultiProducts(products);
              
              List<Decimal> lineNumbers = productsRes.LineNumbers;
              List<Apttus_Config2__LineItem__c> lineItems = [select id,Apttus_Config2__PricingStatus__c  
                                                                  FROM Apttus_Config2__LineItem__c
                                                                  WHERE Apttus_Config2__LineNumber__c=:lineNumbers[0]
                                                                  AND Apttus_Config2__ConfigurationId__c=:cartID];
              for(Apttus_Config2__LineItem__c litem: lineItems) {
                 litem.Apttus_Config2__PricingStatus__c ='pending'; 
              }
              update lineItems;
          }
          
          Map<string,Apttus_Config2__AssetLineItem__c> assetMap = new Map<string,Apttus_Config2__AssetLineItem__c> ();
          Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap = new Map<Id,Apttus_Config2__AssetLineItem__c> ();
          Apttus_Config2__AssetLineItem__c oldAsset;
          
          
          Apttus_Config2__ProductConfiguration__c prodConfig = [Select Id, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c From Apttus_Config2__ProductConfiguration__c Where Id = :cartId];
          
          Map<String,Decimal> assetQuantityMap = new Map<String,Decimal>();
          for(Apttus_Config2__AssetLineItem__c asset :assetLineItems) {
              allAssetMap.put(asset.Id, asset);
              if(assetMap.containsKey(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15))) {
                  oldAsset = assetMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)); 
                  if(asset.CreatedDate > oldAsset.CreatedDate) {
                      assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                      assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));                   
                  } else {
                       assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));
                  }
              } else {
                  assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                  assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c);                   
                           
              }
          }
          
          Set<Id> assetToIgnore = new Set<Id>();
          for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
              if(asset.Apttus_Config2__BundleAssetId__c != null){
                  assetToIgnore.add(asset.Apttus_Config2__BundleAssetId__c);
              }
          }
          
          
          List<Apttus_CPQApi.CPQ.AssetActionDO> assetActDOList = new List<Apttus_CPQApi.CPQ.AssetActionDO>();
          Apttus_CPQApi.CPQ.AssetActionDO assetActDO;
          for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
              if(assetToIgnore.contains(asset.Id)){
                  continue;
              }
              assetActDO  = new Apttus_CPQApi.CPQ.AssetActionDO();
              assetActDO.AssetAction = 'Renew';
              
              if(asset.Apttus_Config2__IsPrimaryLine__c){
                  assetActDO.AssetLineItemId = asset.Id;
              }else{
                  assetActDO.AssetLineItemId = asset.Apttus_Config2__BundleAssetId__c;
              }
              
              assetActDO.Pending = true;
              assetActDO.Quantity = allAssetMap.get(assetActDO.AssetLineItemId).Apttus_Config2__Quantity__c;//assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              assetActDO.StartDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c;//asset.Apttus_Config2__EndDate__c.addDays(1);
              assetActDO.EndDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;//asset.Apttus_Config2__EndDate__c.addMonths(36);
      
              assetActDO.customFields.add('Apttus_Config2__Comments__c');
              assetActDO.customFields.add('Apttus_Config2__PricingStatus__c');
              assetActDO.customFields.add('APTS_Renewal_Quantity__c');
              
              Apttus_Config2__LineItem__c liSO = new Apttus_Config2__LineItem__c();
              liSO.Apttus_Config2__Comments__c = 'Comments Added my Modify Asset API Code';
              liSO.Apttus_Config2__PricingStatus__c = 'Pending';
              liSO.APTS_Renewal_Quantity__c = assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              assetActDO.CustomData=liSO;
              assetActDOList.add(assetActDO);
             
          }
            Apttus_CPQApi.CPQ.ModifyAssetRequestDO modifyRequest = new Apttus_CPQApi.CPQ.ModifyAssetRequestDO();
              modifyRequest.CartId = cartId;
              modifyRequest.AssetActions = assetActDOList;
              system.debug('######Before'+modifyRequest);
              //create line items on the cart
              Apttus_CPQApi.CPQ.ModifyAssetResponseDO modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
              System.debug('###Line Numbers:'+modifyReponse.LineNumbers);
              
              
              // Start modification for asset status is completed or not 
              
              List<Apttus_CPQApi.CPQ.AssetActionDO> assetList = modifyReponse.AssetActions;
              Boolean bIsPending = false;
              Integer iCounter = 0;
              while (iCounter < 1000){
                  bIsPending = false;
                  for(Apttus_CPQApi.CPQ.AssetActionDO objAsset: assetList){
                      if(objAsset.Pending == true){
                          bIsPending = true;
                          break;
                      }
                  }
              //If asset Action is pending execute the following loop
                  if(bIsPending == true){
                      modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
                      //lineNumberList = modifyReponse.LineNumbers;
                      //assetList = modifyReponse.AssetActions;
                  }else{
                      break;
                  }
                  iCounter++;
              }
      
          system.debug('######After'+modifyReponse);
       
      }  
      */
     public static void addPremiumSupport(string cartId,string productid) {
             Apttus_CPQApi.CPQ.SelectedProductDO product=new Apttus_CPQApi.CPQ.SelectedProductDO();
              product.Productid=productId;
              product.Quantity = 1;
              List<Apttus_CPQApi.CPQ.SelectedProductDO> selectedProducts=new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
              selectedProducts.add(product);
              
              Apttus_CPQApi.CPQ.AddMultiProductRequestDO products=new Apttus_CPQApi.CPQ.AddMultiProductRequestDO();
              products.cartId=cartID;
              products.SelectedProducts=selectedProducts;
              System.debug('*** cartID : '+cartID);
              Apttus_CPQApi.CPQ.AddMultiProductResponseDO productsRes=Apttus_CPQApi.CPQWebService.addMultiProducts(products);
              
              List<Decimal> lineNumbers = productsRes.LineNumbers;
              List<Apttus_Config2__LineItem__c> lineItems = [select id,Apttus_Config2__PricingStatus__c  
                                                                  FROM Apttus_Config2__LineItem__c
                                                                  WHERE Apttus_Config2__LineNumber__c=:lineNumbers[0]
                                                                  AND Apttus_Config2__ConfigurationId__c=:cartID];
              for(Apttus_Config2__LineItem__c litem: lineItems) {
                 litem.Apttus_Config2__PricingStatus__c ='pending'; 
              }
              update lineItems;
     } 
  
     public static void renewIndividualAssetLineItem (Apttus_Config2__AssetLineItem__c asset, String cartId,Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap,Map<String,Decimal> assetQuantityMap, String oldProposalId, Map<String,Decimal> assetNetAmountMap) { // Added By Minkesh for requirement 1 (oldProposalId)
          /*Change By Jigar- Start*/
          Apttus_Config2__ProductConfiguration__c prodConfig = [Select Id, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c From Apttus_Config2__ProductConfiguration__c Where Id = :cartId];
          List<Apttus_CPQApi.CPQ.AssetActionDO> assetActDOList = new List<Apttus_CPQApi.CPQ.AssetActionDO>();
          Apttus_CPQApi.CPQ.AssetActionDO assetActDO;
              assetActDO  = new Apttus_CPQApi.CPQ.AssetActionDO();
              assetActDO.AssetAction = 'Renew';
              
              if(asset.Apttus_Config2__IsPrimaryLine__c){
                  assetActDO.AssetLineItemId = asset.Id;
              }else{
                  assetActDO.AssetLineItemId = asset.Apttus_Config2__BundleAssetId__c;
              }
            
              assetActDO.Pending = true;
              system.debug('## asset : '+asset);
              assetActDO.AdjustmentAmount = asset.Adjustment_Amount__c;
              assetActDO.AdjustmentType = asset.Adjustment_Type__c;
              assetActDO.Quantity = allAssetMap.get(assetActDO.AssetLineItemId).Apttus_Config2__Quantity__c;//assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              assetActDO.StartDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedStartDate__c;//asset.Apttus_Config2__EndDate__c.addDays(1);
              assetActDO.EndDate = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;//asset.Apttus_Config2__EndDate__c.addMonths(36);
      
              assetActDO.customFields.add('Apttus_Config2__Comments__c');
              assetActDO.customFields.add('Apttus_Config2__PricingStatus__c');
              assetActDO.customFields.add('APTS_Renewal_Quantity__c');
              assetActDO.customFields.add('APTS_Manual_Discount__c');
              assetActDO.customFields.add('APTS_Ramp_End_Date__c');
              assetActDO.customFields.add('Apttus_Config2__AdjustmentType__c');
              assetActDO.customFields.add('Apttus_Config2__AdjustmentAmount__c');
              
              
              //map<id, decimal> manualDiscountMap = new map<id, decimal>();
              //for(Apttus_Config2__AssetLineItem__c ali : allAssetMap.Values()){
              //  manualDiscountMap.put(ali.Apttus_Config2__ProductId__c, APTS_Total_Discount_Percentage__c - APTS_New_Logo_Disc__c - APTS_Deal_Reg_Disc__c);
          //  }
              
              Apttus_Config2__LineItem__c liSO = new Apttus_Config2__LineItem__c();
              liSO.Apttus_Config2__Comments__c = 'Comments Added my Modify Asset API Code';
              liSO.Apttus_Config2__PricingStatus__c = 'Pending';
              //system.debug('# asset: '+asset);
              // Added By Minkesh for requirement 1
              liSO.APTS_Manual_Discount__c = assetNetAmountMap.get(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));//asset.Adjustment_Amount__c;
              //liSO.APTS_Manual_Discount__c =  asset.APTS_Total_Discount_Percentage__c - asset.APTS_New_Logo_Disc__c - asset.APTS_Deal_Reg_Disc__c;
              //system.debug('@@@assetQuantityMap'+assetQuantityMap);
              //system.debug('string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              liSO.APTS_Renewal_Quantity__c = assetQuantityMap.get(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
              // Update: HE, 01/04/2017 - populate the ramp end date on renewal line item.
              liSO.APTS_Ramp_End_Date__c = prodConfig.Apttus_QPConfig__Proposald__r.Apttus_Proposal__ExpectedEndDate__c;
              // Added By Minkesh for requirement 1 -start
              if(oldProposalId == allAssetMap.get(assetActDO.AssetLineItemId).Apttus_QPConfig__ProposalId__c) {
                liSO.Apttus_Config2__AdjustmentType__c = 'Price Override';
                //if(asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c != null) {
                    liSO.APTS_Manual_Discount__c = assetNetAmountMap.get(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
                    liSO.Apttus_Config2__AdjustmentAmount__c = assetNetAmountMap.get(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
                //}
              }
              // Added By Minkesh for requirement 1 -End
              
              assetActDO.CustomData=liSO;
              assetActDOList.add(assetActDO);
             
          
            Apttus_CPQApi.CPQ.ModifyAssetRequestDO modifyRequest = new Apttus_CPQApi.CPQ.ModifyAssetRequestDO();
              modifyRequest.CartId = cartId;
              modifyRequest.AssetActions = assetActDOList;
              //system.debug('######Before'+modifyRequest);
              //create line items on the cart
              Apttus_CPQApi.CPQ.ModifyAssetResponseDO modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
              //System.debug('###Line Numbers:'+modifyReponse.LineNumbers);
              
              
              // Start modification for asset status is completed or not 
              
              List<Apttus_CPQApi.CPQ.AssetActionDO> assetList = modifyReponse.AssetActions;
              Boolean bIsPending = false;
              Integer iCounter = 0;
              while (iCounter < 1000){
                  bIsPending = false;
                  for(Apttus_CPQApi.CPQ.AssetActionDO objAsset: assetList){
                      if(objAsset.Pending == true){
                          bIsPending = true;
                          break;
                      }
                  }
              //If asset Action is pending execute the following loop
                  if(bIsPending == true){
                      modifyReponse = Apttus_CPQApi.CPQWebservice.modifyAsset(modifyRequest);
                      //lineNumberList = modifyReponse.LineNumbers;
                      //assetList = modifyReponse.AssetActions;
                  }else{
                      break;
                  }
                  iCounter++;
              }
      
          system.debug('######After'+modifyReponse);
       
      }
  
  }