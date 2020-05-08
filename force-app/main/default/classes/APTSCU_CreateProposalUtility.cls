/**
 * @File Name          : APTSCU_CreateProposalUtility.cls
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : Minkesh patel
 * @Last Modified On   : 5/7/2020, 9:28:11 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/7/2019, 5:14:32 PM   pranjalsingh@zscaler.com     Initial Version
**/
public abstract class APTSCU_CreateProposalUtility {

  // parameter names
  public static final String PARAM_ID = 'id';
  public static final String PARAM_CART_ID = 'cartId';
  public static final String PARAM_CONFIG_REQUEST_ID = 'configRequestId';
  public static final String PARAM_USEDEALOPTIMIZER = 'useDealOptimizer';
  public static final String PARAM_MODE = 'mode';

  // config modes
  public static final String MODE_READONLY = 'readOnly';

  // system properties
  static final String PROP_SYSTEM_PROPERTIES = 'System Properties';

  // business object type
  private static final String CATEGORY_QUOTE_OR_PROPOSAL = 'Proposal';
  // summary group types
  private static final String GROUPTYPE_CATEGORY = 'Category';
  private static final String GROUPTYPE_PRODUCT = 'Product';

  // status
  private static final String STATUS_NEW = 'New';
  private static final String STATUS_FINALIZED = 'Finalized';
  // record types Acme Car Dealership
  private static final String RECORDTYPE_ADOBE = 'DELL';

  // value types
  private static final String VALUETYPE_DEFAULT = 'Default';
  private static final String VALUETYPE_PRODUCT = 'Product';

  // line types
  public static final String LINETYPE_PRODUCT = 'Product/Service';
  public static final String LINETYPE_OPTION = 'Option';

  // global default record name
  private static final String GLOBAL_DEFAULT_NAME = 'All';

  // max name field size
  private static final Integer MAX_NAME_SIZE = 80;

  // nil value indicator
  private static final String NILVALUE = 'xsi:nil';

  /**
    * Creates a quote/proposal using the given opportunity
    * @param opptySO the opportunity to create the quote for
    * @return the id of the created quote/proposal
    */
  public static ID createQuoteOrProposal(Opportunity opptySO, Date enddate, Id billtoAccountId, Id priceListId) {

    // STEP I - get the proposal record type id
    // get the record type name
    //String recordTypeName = 'DELL';
    //


    // STEP II - create a new quote/proposal object from the opportunity
    Apttus_Proposal__Proposal__c proposalSO = createProposalFromOpportunity(opptySO, null,enddate, billtoAccountId, priceListId);


    insert proposalSO;


    // get the quote/proposal id
    return proposalSO.Id;

  }

  public static string CreateCartForProposal(string proposalId) {
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposalId;
        Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
        return response.CartId;
  }

  /*
  public static void addAssetLineItemsToCart(String AccountId,String cartId,List<Apttus_Config2__AssetLineItem__c> assetLineItems) {
      APTSCU_AssetUtils.renewAssetLineItem(assetLineItems,cartId);
      List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();
     lineitemlist = [select id, APTS_MRR__c,APTS_Prev_MRR__c,Apttus_Config2__ProductId__c,Apttus_Config2__StartDate__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];

     Apttus_Proposal__Proposal__c prop = [select id,APTSCU_Original_Quote_ACV__c,APTS_Original_Quote_MRR__c,APTS_Original_Quote_TCV__c from Apttus_Proposal__Proposal__c where id=:lineitemlist[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c];
     Decimal MRRTotalOld = 0;
     Decimal TCVTotalOld = 0;
     Decimal ACVTotalOld = 0;


     Decimal oldMRR;
     for(Apttus_Config2__LineItem__c litem : lineitemlist) {
        if(litem.Apttus_Config2__AssetLineItemId__c != null) {
            oldMRR = 0;
            for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
                system.debug('@@@ - '+ string.valueOf(asset.id).substring(0,15));
                system.debug('### - '+ string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15));

                if(string.valueOf(asset.id).substring(0,15) == string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15)) {
                    oldMRR = oldMRR + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;

                }
                else if(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15) == string.valueOf(litem.Apttus_Config2__ProductId__c).substring(0,15)  && asset.Apttus_Config2__EndDate__c.addDays(1) == litem.Apttus_Config2__StartDate__c) {
                    oldMRR = oldMRR + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;
                }
            }
            litem.APTS_Prev_MRR__c = oldMRR;
        }

     }
     update lineitemlist;

     for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
         if(asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c != null) {
             MRRTotalOld =MRRTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;
         }
         if(asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c != null) {
             TCVTotalOld = TCVTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c ;
         }
         if(asset.APTS_ACV__c != null) {
             ACVTotalOld = ACVTotalOld +asset.APTS_ACV__c;
         }

     }
         prop.APTS_Original_Quote_MRR__c = MRRTotalOld ;
         prop.APTS_Original_Quote_TCV__c = TCVTotalOld ;
         prop.APTSCU_Original_Quote_ACV__c = ACVTotalOld;
         update prop;

      finalizeCart(cartId);

  }



  public static void addAssetLineItemsToCartRemote(String AccountId,String cartId,List<Apttus_Config2__AssetLineItem__c> assetLineItems,Boolean insertPremierSupport,string productId) {
      if(insertPremierSupport) {
          APTSCU_AssetUtils.renewAssetLineItemRemote(assetLineItems,cartId,insertPremierSupport,productId);
      } else {
          APTSCU_AssetUtils.renewAssetLineItem(assetLineItems,cartId);
      }


      List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();

      lineitemlist = [select id, APTS_MRR__c,APTS_Prev_MRR__c,Apttus_Config2__ProductId__c,Apttus_Config2__StartDate__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];

      Apttus_Proposal__Proposal__c prop = [select id,APTSCU_Original_Quote_ACV__c,APTS_Original_Quote_MRR__c,APTS_Original_Quote_TCV__c from Apttus_Proposal__Proposal__c where id=:lineitemlist[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c];
      Decimal MRRTotalOld = 0;
     Decimal TCVTotalOld = 0;
     Decimal ACVTotalOld = 0;


     Decimal oldMRR;
     for(Apttus_Config2__LineItem__c litem : lineitemlist) {
        if(litem.Apttus_Config2__AssetLineItemId__c != null) {
            oldMRR = 0;
            for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
                system.debug('@@@ - '+ string.valueOf(asset.id).substring(0,15));
                system.debug('### - '+ string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15));

                if(string.valueOf(asset.id).substring(0,15) == string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15)) {
                    oldMRR = oldMRR + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;

                }
                else if(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15) == string.valueOf(litem.Apttus_Config2__ProductId__c).substring(0,15)  && asset.Apttus_Config2__EndDate__c.addDays(1) == litem.Apttus_Config2__StartDate__c) {
                    oldMRR = oldMRR + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;
                }
            }
            litem.APTS_Prev_MRR__c = oldMRR;
        }

     }
     update lineitemlist;


     for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
         if(asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c != null) {
             MRRTotalOld =MRRTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;
         }
         if(asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c != null) {
             TCVTotalOld = TCVTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c ;
         }
           if(asset.APTS_ACV__c != null) {
             ACVTotalOld = ACVTotalOld +asset.APTS_ACV__c;
         }
     }
         prop.APTS_Original_Quote_MRR__c = MRRTotalOld ;
         prop.APTS_Original_Quote_TCV__c = TCVTotalOld ;
           prop.APTSCU_Original_Quote_ACV__c = ACVTotalOld;
         update prop;


  }
  */

  public static void deleteRampLineItem (String cartId,string accountId) {
      List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c> ();
      List<Apttus_Config2__LineItem__c> lineItemListToDelete = new List<Apttus_Config2__LineItem__c> ();
      lineItemList = [select id,Apttus_Config2__IsPrimaryRampLine__c,Apttus_Config2__ProductId__c, Apttus_Config2__LineNumber__c, APTS_Renewal_Quantity__c from Apttus_Config2__LineItem__c where  Apttus_Config2__ConfigurationId__c=:cartId ORDER BY Apttus_Config2__ItemSequence__c DESC ];
      Map<Decimal, Decimal> renewalQuantityMap = new Map<Decimal, Decimal>();

       List<Apttus_Config2__AssetLineItem__c> assetLineItemsList = new List<Apttus_Config2__AssetLineItem__c> ();
       assetLineItemsList  = [select id,Apttus_Config2__SellingTerm__c,APTS_ACV__c,Apttus_QPConfig__ProposalId__c,Apttus_Config2__ProductId__c,Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__StartDate__c,
                                                                  Apttus_Config2__EndDate__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__BundleAssetId__c, CreatedDate from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c=:accountId AND Apttus_Config2__ChargeType__c='Subscription Fee' AND Apttus_Config2__AssetStatus__c='Activated'];

       Map<string, Decimal> renewalACVMap = new Map<string,decimal> ();
       Decimal RenewalAcv;
       Decimal currentAssetACV;
       for(Apttus_Config2__AssetLineItem__c asset : assetLineItemsList ) {
           RenewalAcv = 0;
           currentAssetACV = 0;
           if(asset.APTS_ACV__c  != null) {
               currentAssetACV = asset.APTS_ACV__c;
           }
           if(renewalACVMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15)) != null) {
              RenewalAcv = renewalACVMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15)) ;
           }
           RenewalAcv = RenewalAcv +  currentAssetACV;
            renewalACVMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15),RenewalAcv);
       }


       List<Apttus_Config2__LineItem__c> lineItemListToUpdate = new List<Apttus_Config2__LineItem__c> ();
      lineItemListToUpdate  = [select id,Apttus_Config2__LineType__c,Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__LineNumber__c, APTS_Renewal_Quantity__c  from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId AND
                                      Apttus_Config2__LineType__c = 'Product/Service' AND Apttus_Config2__IsPrimaryLine__c = false];


        /*
        for(Apttus_Config2__LineItem__c primaryLI : lineItemList){
            for(Apttus_Config2__LineItem__c rampLI : lineItemListToUpdate){
                if(primaryLI.Apttus_Config2__LineNumber__c == rampLI.Apttus_Config2__LineNumber__c){
                    lineItemListToDelete.add(primaryLI);
                    renewalQuantityMap.put(primaryLI.Apttus_Config2__LineNumber__c, primaryLI.APTS_Renewal_Quantity__c);
                    break;
                }
            }
        }*/

        Set<id> lineIdset = new Set<id> ();

        for(Apttus_Config2__LineItem__c primaryLI : lineItemList){
            if(lineIdset.contains(primaryLI.Apttus_Config2__ProductId__c)) {
                lineItemListToDelete.add(primaryLI);
            } else {
                lineIdset.add(primaryLI.Apttus_Config2__ProductId__c);
            }
        }
        system.debug('2deleteRampLineItem '+lineItemListToDelete );
          if(!lineItemListToDelete.isEmpty()) {
              delete lineItemListToDelete;
          }

      lineItemListToUpdate  = [select id,Apttus_Config2__LineType__c,Apttus_Config2__IsPrimaryLine__c,APTS_Renewal_Gap__c,Apttus_Config2__ProductId__c, Apttus_Config2__LineNumber__c, APTS_Renewal_Quantity__c, Apttus_Config2__Quantity__c, Apttus_Config2__PricingStatus__c  from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId AND
                                      Apttus_Config2__LineType__c = 'Product/Service' And Apttus_Config2__LineStatus__c = 'Renewed'];
      for(Apttus_Config2__LineItem__c li :lineItemListToUpdate) {
          li.Apttus_Config2__IsPrimaryLine__c  = true;
          li.Apttus_Config2__PricingStatus__c = 'Pending';

          if( renewalACVMap.get(string.valueof(li.Apttus_Config2__ProductId__c).substring(0,15)) != null) {
              li.APTS_Renewal_Base__c=renewalACVMap.get(string.valueof(li.Apttus_Config2__ProductId__c).substring(0,15));
          } else {
              li.APTS_Renewal_Base__c= 0;
          }

          if(li.APTS_Renewal_Quantity__c != null){
              li.Apttus_Config2__Quantity__c = li.APTS_Renewal_Quantity__c;
          }else if(li.APTS_Renewal_Quantity__c == null && renewalQuantityMap.containskey(li.Apttus_Config2__LineNumber__c)){
              //li.APTS_Renewal_Quantity__c = renewalQuantityMap.get(li.Apttus_Config2__LineNumber__c);
             // li.Apttus_Config2__Quantity__c = renewalQuantityMap.get(li.Apttus_Config2__LineNumber__c);
          }
      }
      if(lineItemListToUpdate.size() > 0) {
          update lineItemListToUpdate  ;
      }


  }

  public static boolean repriceCart (String cartId) {
        Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
        objUpdatePriceRequestDO.CartId = cartID;
        Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
        return result.IsPricePending;
    }

  public static void finalizeCartRemote (String cartId, String templateId) {
     Decimal MRRTotal = 0;
     Decimal TCVTotal = 0;
     List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();
     lineitemlist = [select id, APTS_MRR__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, Apttus_Config2__LineStatus__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];
     Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();

     if(lineitemlist.size() > 0) {
         prop = [select id, Apttus_Proposal__Opportunity__c, APTS_Original_Quote_MRR__c,APTS_Original_Quote_TCV__c, APTS_Current_Quote_MRR__c, APTS_Current_Quote_TCV__c from Apttus_Proposal__Proposal__c where id=:lineitemlist[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c];
         for(Apttus_Config2__LineItem__c lItem : lineitemlist) {
             if(lItem.APTS_MRR__c != null && lItem.Apttus_Config2__LineStatus__c != 'Cancelled') {
                 MRRTotal = MRRTotal + lItem.APTS_MRR__c;
             }
             if(lItem.Apttus_Config2__NetPrice__c != null) {
                 TCVTotal = TCVTotal+lItem.Apttus_Config2__NetPrice__c;
             }
         }
         prop.APTS_Current_Quote_MRR__c = MRRTotal;
         prop.APTS_Current_Quote_TCV__c = TCVTotal;

         update prop;
     }


     Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
        // add request parameters
        request.CartId = CartId;
        system.debug('####'+cartid);
        // finalize the cart
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);
        String apiServerURL = Apttus_Config2__ConfigSystemProperties__c.getAll().get('System Properties').Apttus_Config2__InstanceUrl__c + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        List<Apttus__APTS_Template__c> templatelist = new List<Apttus__APTS_Template__c> ();
        //templatelist  = [select id from Apttus__APTS_Template__c where Name ='Zscaler Proposal Template'];
        //if(templatelist.size() > 0) {
        //    String templateId = templatelist[0].id;

        String sessionId = userInfo.getSessionId();
        if(templateId!= null && templateId.length()>0 && prop.Id !=null ){
            ID tempId = templateId;
            generateDocument(prop.Id,apiServerURL,tempId,sessionId);
        }



  }

    //added by minkesh for new Requirement 1 - start
    public static void RenewUpsellProposal (String cartId,String proposalId,String oldProposalId,string accountId) {
        System.debug('Inside RenewUpsellProposal====>cartId'+cartId+'====>proposalId'+proposalId+'====>oldProposalId'+oldProposalId);
       
        List<Apttus_Config2__LineItem__c> oldlineitemlist = new List<Apttus_Config2__LineItem__c> ();
 
        oldlineitemlist = [select id,
                                  Apttus_Config2__ProductId__c,
                                  Apttus_Config2__ProductId__r.Zscaler_Product_Family__c ,
                                  Partner_Program__c,
                                  Apttus_Config2__AssetLineItemId__c,
                                  Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c,
                                  Apttus_Config2__NetPrice__c,
                                  Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c 
                            from Apttus_Config2__LineItem__c 
                            where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c =: oldProposalId AND 
                                Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c = 'Finalized'];
        Boolean hasAssetFamilies = false;
 
        List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c> ();
        List<Apttus_Config2__LineItem__c> lineItemlist = new List<Apttus_Config2__LineItem__c> ();
        assetLineItems = [select id,
                                 Apttus_Config2__SellingTerm__c,
                                 Apttus_Config2__ProductId__r.Zscaler_Product_Family__c,
                                 Apttus_Config2__ProductId__c,
                                 Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c,
                                 Apttus_Config2__NetPrice__c,
                                 Partner_Program__c
                        from Apttus_Config2__AssetLineItem__c
                        where Apttus_Config2__AccountId__c=:accountId 
                        AND  Apttus_Config2__AssetStatus__c='Activated' ];
 
         lineItemlist = [select id,
                                Apttus_Config2__ProductId__r.Zscaler_Product_Family__c,
                                Apttus_Config2__IsPrimaryRampLine__c,
                                Apttus_Config2__AdjustmentType__c,
                                APTS_Manual_Discount__c,
                                Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c,
                                Quote_Proposal_Line_Item__c,
                                Apttus_Config2__AssetLineItemId__c,
                                Apttus_Config2__ProductId__c, 
                                Apttus_Config2__LineNumber__c, 
                                Partner_Program__c,
                                APTS_Renewal_Quantity__c 
                         from Apttus_Config2__LineItem__c 
                         where  Apttus_Config2__ConfigurationId__c=:cartId 
                         ORDER BY Apttus_Config2__ItemSequence__c DESC ];
 
        List<Apttus_Config2__LineItem__c> productLineList;
        Map<String,List<Apttus_Config2__AssetLineItem__c>> oldProposalLineItemProductMap = new Map<String,List<Apttus_Config2__AssetLineItem__c>>();
        Set<Id> currentAssetsIds = new Set<Id>();
        // for(Apttus_Config2__LineItem__c li : oldlineitemlist){
        //     if(oldProposalLineItemProductMap.containsKey(li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
        //         oldProposalLineItemProductMap.get(li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c).add(li);
        //     }else{
        //         oldProposalLineItemProductMap.put(li.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, new List<Apttus_Config2__LineItem__c>{li});
        //     }
            
        // }
        
        //added by Minkesh for new Requirement 1 - end
 
 
        //added by Minkesh for new Requirement 1 - start
        for(Apttus_Config2__AssetLineItem__c asset : assetLineItems) {
         if( asset.Apttus_QPConfig__ProposalId__c != null && asset.Apttus_QPConfig__ProposalId__c == oldProposalId ) {
             currentAssetsIds.add(asset.Id); 
         } else if( asset.Apttus_QPConfig__ProposalId__c != null ){
             if(oldProposalLineItemProductMap.containsKey(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
                 oldProposalLineItemProductMap.get(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c).add(asset);
             }else{
                 oldProposalLineItemProductMap.put(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, new List<Apttus_Config2__AssetLineItem__c>{asset});
             }
               
         }
           
      }
      //added by Minkesh for new Requirement 1 - end 
 
      for(Apttus_Config2__LineItem__c lItems : lineItemlist) {
        System.debug('litems.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c'+litems.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c);
       //added  by minkesh for new Requirement 1 - start 
       if(oldProposalLineItemProductMap.Containskey(litems.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c) && currentAssetsIds.contains(litems.Apttus_Config2__AssetLineItemId__c)){
           for(Apttus_Config2__AssetLineItem__c oldli : oldProposalLineItemProductMap.get(litems.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
               if(oldli.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == litems.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c
                   && litems.Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT
                   && oldli.Partner_Program__c != APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT
                  // && currentAssetsIds.equals(oldProposalId)
                   ){
 
                   litems.Apttus_Config2__AdjustmentType__c = 'Price Override';
                   //litems.APTS_Manual_Discount__c = oldli.Apttus_Config2__NetPrice__c;
                   litems.APTS_Manual_Discount__c = litems.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c;
                   lItems.Apttus_Config2__AdjustmentAmount__c = litems.Apttus_Config2__AssetLineItemId__r.Apttus_Config2__NetPrice__c;
                   hasAssetFamilies = true;
                  
                   System.debug('@@@@@@@@@litem:' + litems.APTS_Manual_Discount__c + '@@' + litems.Id + '@@' + litems.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c);
                   System.debug('@@@@@@@@@litem:' + oldli.Apttus_Config2__NetPrice__c + '@@' + oldli.Id);
                   break;
               }
           }
         }
     }
     update lineItemlist;
 
   }
  

  private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId, Date enddate) {
      return createProposalFromOpportunity(opptySO, recordTypeId, enddate, null, null);
  }

  private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId, Date enddate, Id billToAccountId) {
      return createProposalFromOpportunity(opptySO, recordTypeId, enddate, billToAccountId, null);
  }

  /**
   * Creates a new proposal from the given opportunity
   * @param opptySO the opportunity to create the proposal for
   * @param recordTypeId the record type id for the proposal
   * @return the created proposal
   */
  private static Apttus_Proposal__Proposal__c createProposalFromOpportunity(Opportunity opptySO, ID recordTypeId, Date enddate, Id billToAccountId, Id priceListId) {

    List<Apttus_Proposal__Proposal__c> primaryProposalList = new List<Apttus_Proposal__Proposal__c >();
    primaryProposalList = [select id,Apttus_Proposal__Primary__c  from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c=:opptySO.Id AND Apttus_Proposal__Primary__c = true];
    if(primaryProposalList.size() > 0) {
        for(Apttus_Proposal__Proposal__c prop : primaryProposalList) {
            prop.Apttus_Proposal__Primary__c  = false;
        }
        update primaryProposalList;
    }


    // STEP I - create a new proposal sobject
    Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c();

    // initialize the proposal from the opportunity

    // STEP II - copy known opportunity fields
    // record type id
    if (recordTypeId != null) {
      proposalSO.RecordTypeId = recordTypeId;
      System.debug(proposalSO.RecordTypeId);
      System.debug('proposalSO.RecordTypeId');
      System.debug([SELECT Name FROM RecordType WHERE Id =: proposalSO.RecordTypeId]);

    }

    // proposal name (max length = 50)
    String opptyName = opptySO.Name;
    if (opptyName != null && opptyName.length() > 50) {
      opptyName = opptyName.substring(0, 50);

    }

    Integer quoteCount = [select count() from Apttus_Proposal__Proposal__c
                            where Apttus_Proposal__Opportunity__c = :opptySO.Id
                            and Apttus_Proposal__Primary__c = true];
    Boolean isPrimaryQuote = (quoteCount == 0 ? true : false);

    List<Recordtype> recordtypelist = new list<Recordtype>();
    recordtypelist = [SELECT Id,Name FROM RecordType WHERE Name = 'Renewal'];
    if(recordtypelist.size() > 0) {
        proposalSO.RecordtypeId = recordtypelist[0].Id;
    }
    //proposalSO.RecordType.Name = opptySO.RecordType.Name;
    // base fields
    proposalSO.Apttus_Proposal__Proposal_Name__c = opptyName;
    // opportunity
    proposalSO.Apttus_Proposal__Opportunity__c = opptySO.Id;
    // account
    proposalSO.Apttus_Proposal__Account__c = opptySO.AccountId;
    // primary contact
    proposalSO.Apttus_Proposal__Primary_Contact__c = getPrimaryContactIdForAccount(opptySO.AccountId);
    // description
    //proposalSO.Apttus_Proposal__Description__c = opptySO.Description;
    // primary
    proposalSO.Apttus_Proposal__Primary__c = isPrimaryQuote;
    // price list id
    proposalSO.Apttus_QPConfig__PriceListId__c = opptySO.Price_List__c;
    // pricing date
    proposalSO.Apttus_QPConfig__PricingDate__c = Datetime.now();
    // valid until date
    proposalSO.Apttus_Proposal__Valid_Until_Date__c = enddate.addDays(1);
    // ready to generate
    proposalSO.Apttus_Proposal__ReadyToGenerate__c = true;
    // ready to present
    proposalSO.Apttus_Proposal__ReadyToPresent__c = true;

    proposalSO.Apttus_Proposal__Primary__c = true;
    // owner
    if(opptySO.OwnerId != null)
    proposalSO.OwnerId = opptySO.OwnerId;

    proposalSO.Apttus_Proposal__ExpectedStartDate__c = enddate.addDays(1);

    proposalSO.Apttus_Proposal__ExpectedEndDate__c = enddate.addMonths(36).addDays(-1);

    if (billToAccountId != null) {
        proposalSO.Apttus_QPConfig__BillToAccountId__c = billToAccountId;
    }

    if (priceListId != null) {
        proposalSO.Apttus_QPConfig__PriceListId__c = priceListId;
    }

    // custom fields
    //added as part of Summit - Raghu
    proposalSO.Model_Type_Partner__c = opptySO.Primary_Partner_Program__c;

    //end of changes - Raghu


    // return the created proposal
    return proposalSO;

  }


 /**
   * Gets the record type id associated with the given sobject name and record type name
   * @param sObjectName the sobject name
   * @param recordTypeName the record type name to get the record type for
   * @return the record type id
   */
  public static ID getRecordTypeIdForName(String sObjectName, String recordTypeName) {

    // get the record type
    List<RecordType> recordTypes = [SELECT Id
                     FROM RecordType
                     WHERE SobjectType = :sObjectName AND
                         (Name = :recordTypeName OR
                          DeveloperName = :recordTypeName)
                     LIMIT 1];

    return (!recordTypes.isEmpty() ? recordTypes[0].Id : null);

  }

  /**
   * Gets the primary contact id for the given account id
   * @param acctId the account id to to retrieve the contact for
   * @return the contact sobject id
   */
  private static ID getPrimaryContactIdForAccount(ID acctId) {

    // get the contacts for the account
    List<Contact> contacts = [SELECT Id,
                     Name,
                     Title,
                     Phone,
                     Email
                   FROM Contact
                   WHERE AccountId = :acctId
                   LIMIT 1];

    return (!contacts.isEmpty() ? contacts[0].Id : null);

  }

  /**
   * Gets the instance url
   * @return the instance url
   */
  public static String getInstanceUrl() {

        // get the system property dataset
        Apttus_Config2__ConfigSystemProperties__c prop = Apttus_Config2__ConfigSystemProperties__c.getInstance(PROP_SYSTEM_PROPERTIES);

        return (prop != null && !nullOrEmpty(prop.Apttus_Config2__InstanceUrl__c)
                ? prop.Apttus_Config2__InstanceUrl__c
                : null);

  }

  /**
   * Checks if the given string value is null or empty.
   * @param strValue the string to check
   * @return <code>true</code> if the string value is null or empty, <code>false</code> otherwise
   */
  public static Boolean nullOrEmpty(String strValue) {
    // check if null or zero length string
    return (strValue == null || strValue.trim().length() == 0);

  }

  /**
   * Checks if the given string value holds a nil value.
   * @param strValue the string to check
   * @return <code>true</code> if the string holds a nil value, <code>false</code> otherwise
   */
  public static Boolean isNilValue(String strValue) {
    return (NILVALUE == strValue);

  }

  /**
   * Returns ifNull value when the value is null or empty.
   * Otherwise returns actual value
   */
  public static String nullValue(String value, String ifNull) {
    if (nullOrEmpty(value) || isNilValue(value)) {
        return ifNull;

    }

    return value;

  }

  /**
   * Gets the opportunity sobject for the given opportunity id
   * @param opptyId the opportunity id to retrieve
   * @return the opportunity sobject
   */
  public static Opportunity getOpportunitySO(ID opptyId) {

    // get the opportunity
    List<Opportunity> opportunities = [SELECT Id,
                          Name,
                          Type,
                          StageName,
                          Price_List__r.Name,
                          Price_List__c,
                          OwnerId,
                          LeadSource,
                          Description,
                          CloseDate,
                          Amount,
                          AccountId
                       FROM Opportunity
                       WHERE Id = :opptyId LIMIT 1];

    return (!opportunities.isEmpty() ? opportunities[0] : null);

  }

    /**
     * Gets the product configuration sobject for the given product configuration id
     * @param cartId the cart id
     * @return the product configuration sobject
     */
    public static Apttus_Config2__ProductConfiguration__c getCartSO(ID cartId) {

        // get the product configurations
        List<Apttus_Config2__ProductConfiguration__c> configs = [SELECT Id,
                                                                        Name,
                                                                        Apttus_QPConfig__Proposald__c,
                                                                        Apttus_Config2__VersionNumber__c,
                                                                        Apttus_Config2__Status__c,
                                                                        Apttus_Config2__SummaryGroupType__c,
                                                                        Apttus_Config2__PrimordialId__c,
                                                                        Apttus_Config2__PriceListId__c,
                                                                        Apttus_Config2__IsTransient__c,
                                                                        Apttus_Config2__FinalizedDate__c,
                                                                        Apttus_Config2__ExpectedStartDate__c,
                                                                        Apttus_Config2__ExpectedEndDate__c,
                                                                        Apttus_Config2__EffectiveDate__c,
                                                                        Apttus_Config2__Description__c,
                                                                        Apttus_Config2__Comments__c,
                                                                        Apttus_Config2__BusinessObjectType__c,
                                                                        Apttus_Config2__BusinessObjectId__c,
                                                                        Apttus_Config2__AncestorId__c
                                                                 FROM Apttus_Config2__ProductConfiguration__c
                                                                 WHERE Id = :cartId];

        return (!configs.isEmpty() ? configs[0] : null);

    }

    @future (callout=true)
    public static void generateDocument(ID proposalId, String apiServerURL, String templateId,String sessionId)
    {
        Id recordId = proposalId;
        String accessLevel = 'Read Only';
        String docFormat = 'pdf';
        boolean isDraft = false;
        system.debug('### templateId: '+templateId);
        system.debug('### recordId: '+recordId);
        system.debug('### accessLevel: '+accessLevel);
        system.debug('### isDraft: '+isDraft);
        system.debug('### sessionId: '+sessionId);
        system.debug('### apiServerURL: '+apiServerURL);
        String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc2(templateId
                , recordId
                , accessLevel
                , docFormat
                , isDraft
                , sessionId
                , apiServerURL);
      if(generatedDocId != null) {
          Apttus_Proposal__Proposal__c proposal  = new Apttus_Proposal__Proposal__c();
          proposal = [select id,Apttus_Proposal__Approval_Stage__c from  Apttus_Proposal__Proposal__c where id=:proposalId];
          proposal.Apttus_Proposal__Approval_Stage__c ='Draft';
          update proposal;
      }
      Apttus_Proposal__Proposal__c prop = [select id, Apttus_Proposal__Opportunity__c from  Apttus_Proposal__Proposal__c where id=: proposalId];

      createOpportunityProduct(prop.Id, prop.Apttus_Proposal__Opportunity__c);
    }

    public static void createOpportunityProduct(string proposalId,string opportunityId)
    {
        List<OpportunityLineItem> newOppLineItemList = new List<OpportunityLineItem> ();
        list<id> productIDlist = new list<id>();

        Opportunity opp = [Select id,Pricebook2Id, AccountId
                                                        From Opportunity
                                                            Where Id =: opportunityId];
        List<Apttus_Proposal__Proposal_Line_Item__c> proposallineItemlist =  [Select id,Apttus_Proposal__Product__c,Apttus_QPConfig__OptionId__c,APTS_Product_Code__c,APTS_Selling_Term__c,Apttus_QPConfig__Quantity2__c, Apttus_QPConfig__BasePrice__c, APTS_ACV__c, APTS_Net_Price__c, Apttus_QPConfig__StartDate__c, Apttus_QPConfig__EndDate__c, APTS_MRR__c, APTS_Prev_MRR__c, APTS_Partner_Disc__c, APTS_New_Logo_Disc__c,
                                                                                Partner_Adjustment_Type__c,
                                                                                Partner_Adjustment__c,
                                                                                Total_Stackable_Margin__c,
                                                                                Net_to_Zscaler__c,
                                                                                Total_Zscaler_Discount__c,
                                                                                Partner_Summit_Deal_Reg__c,
                                                                                AW_Margin_Formula__c,
                                                                                Fulfilment_Margin__c,
                                                                                POV__c,
                                                                                APTS_Deal_Reg_Disc__c, APTS_Manual_Discount__c, Apttus_QPApprov__Approval_Status__c, APTSCU_Renewal_ACV__c,
                                                                                Apttus_QPConfig__BaseExtendedPrice__c,
                                                                                APTS_Total_Discount_Percentage__c,
                                                                                Apttus_QPConfig__NetPrice__c,Name,Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C
                                                                               From Apttus_Proposal__Proposal_Line_Item__c
                                                                               Where Apttus_Proposal__Proposal__c =: proposalId];

        for(Apttus_Proposal__Proposal_Line_Item__c lineItemSO : proposallineItemlist)
        {
            productIDlist.add(lineItemSO.Apttus_Proposal__Product__c);
            if(lineItemSO.Apttus_QPConfig__OptionId__c <> null){
                productIDlist.add(lineItemSO.Apttus_QPConfig__OptionId__c);
            }
        }

        list<PricebookEntry> pricebookentrylist = new list<PricebookEntry>();
        if(productIDlist.size() > 0)
        {
            pricebookentrylist = [Select Id,Name,IsActive,Pricebook2Id,
                                                    Product2Id,ProductCode,UnitPrice,UseStandardPrice
                                                    From PricebookEntry
                                                        Where Product2Id IN :productIDlist ];
        }



        for(Apttus_Proposal__Proposal_Line_Item__c lineItemSO : proposallineItemlist)
        {
            System.debug('Bose Apttus_Proposal__Proposal_Line_Item__c ' + lineItemSO);
            OpportunityLineItem oppLineItem= new OpportunityLineItem();

            for(PricebookEntry entry: pricebookentrylist)
            {
                if(entry.Product2Id == lineItemSO.Apttus_Proposal__Product__c
                && opp != null && entry.Pricebook2Id == opp.Pricebook2Id){
                    oppLineItem.PricebookEntryId = entry.id;
                }
            }

            oppLineItem.Quantity=lineitemso.Apttus_QPConfig__Quantity2__c;
            system.debug('line692=class=createproposalutility=lineitemso.Apttus_QPConfig__BasePrice__c'+lineitemso.Apttus_QPConfig__BasePrice__c);
            oppLineItem.US_List_Price__c=lineitemso.Apttus_QPConfig__BasePrice__c;
            oppLineItem.TotalPrice=lineitemso.Apttus_QPConfig__NetPrice__c;
            oppLineItem.Opportunityid=lineitemso.Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__C ;

            oppLineItem.Apttus_Approval__Approval_Status__c = lineItemSO.Apttus_QPApprov__Approval_Status__c;
            oppLineItem.APTS_Term__c = lineItemSO.APTS_Selling_Term__c;
            oppLineItem.Discount = lineItemSO.APTS_Total_Discount_Percentage__c;
            oppLineItem.APTS_List_Price__c = lineItemSO.Apttus_QPConfig__BaseExtendedPrice__c;
            oppLineItem.APTS_Proposal_Line_Item__c = lineItemSO.Id;
            // === Due to Partner Summit Program (added by Minkesh patel)(Start)===
            oppLineItem.Partner_Adjustment__c = lineItemSO.Partner_Adjustment__c;
            oppLineItem.Partner_Adjustment_Type__c = lineItemSO.Partner_Adjustment_Type__c;
            oppLineItem.Total_Stackable_Margin__c = lineItemSO.Total_Stackable_Margin__c;
            oppLineItem.Net_to_Zscaler__c = lineItemSO.Net_to_Zscaler__c;
            oppLineItem.Total_Zscaler_Discount__c = lineItemSO.Total_Zscaler_Discount__c;
            oppLineItem.Partner_Summit_Deal_Reg__c = lineItemSO.Partner_Summit_Deal_Reg__c;
            oppLineItem.AW_Margin_Formula__c = lineItemSO.AW_Margin_Formula__c;
            //oppLineItem.Fulfilment_Margin__c = lineItemSO.Fulfilment_Margin__c;
            oppLineItem.POV__c = lineItemSO.POV__c;
            // ===(End)===

            oppLineItem.TotalPrice = lineItemSO.APTS_ACV__c;
            oppLineItem.APTS_TCV__c = lineItemSO.APTS_Net_Price__c;
            oppLineItem.APTS_Start_Date__c = lineItemSO.Apttus_QPConfig__StartDate__c;
            oppLineItem.APTS_End_Date__c = lineItemSO.Apttus_QPConfig__EndDate__c;
            oppLineItem.APTS_MRR__c = lineItemSO.APTS_MRR__c;
            oppLineItem.APTS_Previous_MRR__c = lineItemSO.APTS_Prev_MRR__c;
            oppLineItem.APTS_Partner_Disc__c = lineItemSO.APTS_Partner_Disc__c;
            oppLineItem.APTS_New_Logo__c = lineItemSO.APTS_New_Logo_Disc__c;
            oppLineItem.APTS_Deal_Reg_Discount__c = lineItemSO.APTS_Deal_Reg_Disc__c;
            oppLineItem.APTS_Manual_Discount__c = lineItemSO.APTS_Manual_Discount__c;
            oppLineItem.APTSCU_New_ACV__c = lineItemSO.APTS_ACV__c;
            oppLineItem.APTSCU_Old_ACV__c = lineItemSO.APTSCU_Renewal_ACV__c;

            System.debug('Bose Opportunity Line Item ' + oppLineItem);
            newOppLineItemList.add(oppLineItem);
        }


        List<OpportunityLineItem> opplineItemList =  [Select id,Product2id, ProductCode,Committed_Months__c,Quantity,US_List_Price__c,UnitPrice,TotalPrice,SBQQ__QuoteLine__c
                                                                        From OpportunityLineItem
                                                                            Where Opportunityid =: opportunityId];
        if(opplineItemList!=null)
        {
            delete opplineItemList;
        }

        if(newOppLineItemList!=null)
        {
           insert newOppLineItemList;
        }
    }

}