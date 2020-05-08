/**
 * @File Name          : APTSCU_AcceptProposalController.cls
 * @Description        : 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Minkesh patel
 * @Last Modified On   : 5/7/2020, 11:43:14 PM
 * @Modification Log   : 
**/
public class APTSCU_AcceptProposalController {

    public string proposalId{get;set;}
    public string accountId{get;set;}
    public string opportunityId{get;set;}
    public string billtoAccountId {get;set;}
    public String apiServerURL{get;set;}
    public string templateId {get;set;}
    public string sessionId {get; set;}
    public String retUrl { get; set; }



    public APTSCU_AcceptProposalController() {
        proposalId = apexpages.currentpage().getparameters().get('id');
        String netSuiteSOId = apexpages.currentpage().getparameters().get('NSSOId');
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
        prop = [select id,Apttus_QPConfig__PriceListId__c,Line_Item_SKU__c,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Primary__c,Apttus_QPConfig__BillToAccountId__c,Apttus_Proposal__Opportunity__r.AccountId,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c  where id=:proposalId];
        accountId = prop.Apttus_Proposal__Opportunity__r.AccountId;
        opportunityId = prop.Apttus_Proposal__Opportunity__c;
        billtoAccountId = prop.Apttus_QPConfig__BillToAccountId__c;
        
        apiServerURL = Apttus_Config2__ConfigSystemProperties__c.getAll().get('System Properties').Apttus_Config2__InstanceUrl__c + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
        List<Apttus__APTS_Template__c> templatelist = new List<Apttus__APTS_Template__c> ();

        List<Apttus__APTS_Admin__c> adminEntryList = new List<Apttus__APTS_Admin__c> ();
        adminEntryList = [select id,Name,Apttus__Value__c from Apttus__APTS_Admin__c where Name='Generate Document Email Template'];

        string templateName;
        if(adminEntryList.size() > 0) {
            templateName =adminEntryList[0].Apttus__Value__c;
        }
        templatelist  = [select id from Apttus__APTS_Template__c where Name =:templateName];
        if(templatelist.size() > 0) {
            templateId = templatelist[0].id;
        }
        if (String.isNotBlank(netSuiteSOId)) {
            retUrl = ZscalerSetting__c.getAll().get('NSSOUrl').Value__c + netSuiteSOId;
        } else {
            retUrl = '/' + proposalId;
        }
        sessionId = userInfo.getSessionId();

   }


   @RemoteAction
   public static string getAlldata (string accountId,integer index, Boolean isCreateNew, String proposalId) {//added by Minkesh for requirement 2 ( Boolean isCreateNew, String proposalId)

        Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap;
        Map<Integer,Apttus_Config2__AssetLineItem__c> AssetMapTorenew;
        Map<String,Decimal> assetQuantityMap;
        Map<String,Decimal> assetNetAmountMap;
        string allAssetMapString;
        string AssetMapTorenewString;
        string assetQuantityMapString;
        string assetNetAmountMapString;

        List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c> ();
        assetLineItems = [select id,
                                Apttus_Config2__SellingTerm__c,
                                Apttus_Config2__BusinessObjectId__c,
                                APTS_ACV__c,
                                Apttus_QPConfig__ProposalId__c,
                                Apttus_Config2__ProductId__c,
                                Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,
                                Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,
                                Apttus_Config2__Quantity__c,
                                Apttus_Config2__StartDate__c, 
                                Adjustment_Amount__c,Adjustment_Type__c,
                                Apttus_Config2__EndDate__c, 
                                Apttus_Config2__IsPrimaryLine__c, 
                                Apttus_Config2__IsPrimaryRampLine__c, 
                                Apttus_Config2__BundleAssetId__c, 
                                Apttus_Config2__NetPrice__c,
                                CreatedDate 
                            from Apttus_Config2__AssetLineItem__c 
                            where Apttus_Config2__AccountId__c=:accountId AND 
                                Apttus_Config2__ChargeType__c='Subscription Fee' AND
                                Apttus_Config2__AssetStatus__c='Activated' AND 
                                Apttus_Config2__ProductId__r.productcode NOT IN ('ZCR-UPY5','ZCR-UPY4') order by Apttus_Config2__ItemSequence__c DESC];
        List<product2> productList = new List<product2> ();
        boolean insertPremierSupport = false;
        string productIdPremiumSupport;
        // Commented the addition of premium support on renewal.
        productList = [select id,name from product2 where productcode='ZCES-SUP-PREM' AND family = 'Zscaler Products'];

         // Added By Minkesh for requirement 2 -start
         List<Apttus_Config2__AssetLineItem__c> newAssetList = new List<Apttus_Config2__AssetLineItem__c>();
         for(Apttus_Config2__AssetLineItem__c asset : assetLineItems) {
             if(string.valueof(asset.Apttus_QPConfig__ProposalId__c).substring(0,15) == proposalId.substring(0,15)) {
                 newAssetList.add(asset);
             }
         }
         // Added By Minkesh for requirement 2 End

        if(productList.size() > 0) {
            productIdPremiumSupport = string.valueof(productList[0].Id).substring(0,15);
            boolean flag = true;
            for(Apttus_Config2__AssetLineItem__c asset :assetLineItems) {
                if(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15) == productIdPremiumSupport) {
                     flag = false;
                }
            }
            if(flag) {
                insertPremierSupport = flag;
            }
        }
        // insertPremierSupport  to False so that by default no premimum support is added while renwal - Kunal Raj
        insertPremierSupport = false;

        Apttus_Config2__AssetLineItem__c oldAsset;
        allAssetMap = new Map<Id,Apttus_Config2__AssetLineItem__c> ();
        AssetMapTorenew = new Map<Integer,Apttus_Config2__AssetLineItem__c> ();

        Map<String,Apttus_Config2__AssetLineItem__c> assetMap = new Map<String,Apttus_Config2__AssetLineItem__c> ();
        assetQuantityMap = new Map<String,Decimal>();
        assetNetAmountMap = new Map<String,Decimal>(); //added by Minkesh for requirement 1
        Decimal qty = 0;
        Decimal netAmount = 0; //added by Minkesh for requirement 1
        for(Apttus_Config2__AssetLineItem__c asset : ( isCreateNew ? newAssetList : assetLineItems) ) {//added by Minkesh for requirement 2(!isCreateNew ?)
                allAssetMap.put(asset.Id, asset);
                
                if(assetMap.containsKey(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15))) {
                    oldAsset = assetMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
                    if(asset.CreatedDate > oldAsset.CreatedDate) {
                        assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                       // assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));
                    } else {
                     //    assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c + assetQuantityMap.get(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15)));
                    }
                } else {
                    assetMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset);
                   // assetQuantityMap.put(string.valueof(asset.Apttus_Config2__EndDate__c) +'$' +string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15),asset.Apttus_Config2__Quantity__c);

                }
                qty = 0;
                netAmount = 0;
                if(assetQuantityMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15)) != null) {
                    qty = assetQuantityMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15));
                    netAmount = assetNetAmountMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15));
                }
                qty = qty + asset.Apttus_Config2__Quantity__c;
                netAmount = netAmount + asset.Apttus_Config2__NetPrice__c;
               // system.debug('111 ---'+asset.Apttus_Config2__Quantity__c);
               // system.debug('222 ---'+asset.Apttus_Config2__ProductId__c);
               // system.debug('333 ---'+assetQuantityMap);
               // system.debug('444 ---'+assetQuantityMap.get(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15)));
                if(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15) == productIdPremiumSupport.substring(0,15)) {
                     assetQuantityMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15),1);
                     //assetNetAmountMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15), asset.Apttus_Config2__NetPrice__c);
                     assetNetAmountMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15), netAmount);
                } else {
                    assetQuantityMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15),qty);
                    assetNetAmountMap.put(string.valueof(asset.Apttus_Config2__ProductId__c).substring(0,15), netAmount);
                }

        }
       // system.debug('constructor --'+allAssetMap);
        Set<Id> assetToIgnore = new Set<Id>();
        Map<string, Apttus_Config2__AssetLineItem__c> assetToRetainMap = new Map<string,Apttus_Config2__AssetLineItem__c>();
        for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
            if(assetToRetainMap.get(asset.Apttus_Config2__BusinessObjectId__c+'$'+string.valueof(asset.Apttus_Config2__ProductId__c)) == null) {
               assetToRetainMap.put(asset.Apttus_Config2__BusinessObjectId__c+'$'+string.valueof(asset.Apttus_Config2__ProductId__c),asset);

            }

        }
        Integer count = 0;
        for(Apttus_Config2__AssetLineItem__c asset :assetMap.values()) {
            if(assetToRetainMap.get(asset.Apttus_Config2__BusinessObjectId__c+'$'+string.valueof(asset.Apttus_Config2__ProductId__c)) != null && assetToRetainMap.get(asset.Apttus_Config2__BusinessObjectId__c+'$'+string.valueof(asset.Apttus_Config2__ProductId__c)).id == asset.id){
                count++;
                AssetMapTorenew.put(count,asset);
            }
        }
       // system.debug('In constructor allAssetMap '+allAssetMap);
       // system.debug('In constructor AssetMapTorenew'+AssetMapTorenew);
       // system.debug('In constructor assetQuantityMap'+assetQuantityMap);
        allAssetMapString = JSON.serialize(allAssetMap);
        AssetMapTorenewString = JSON.serialize(AssetMapTorenew);
        assetQuantityMapString = JSON.serialize(assetQuantityMap);
        assetNetAmountMapString = JSON.serialize(assetNetAmountMap);
        if(index == 0) {
            return string.valueof(insertPremierSupport).toLowerCase();
        }
        if(index == 1) {
            return productIdPremiumSupport;
        }
        if(index == 2) {
            return allAssetMapString;
        }
        if(index == 3) {
            return AssetMapTorenewString;
        }
        if(index == 4) {
            return assetQuantityMapString ;
        }
        if(index == 5) {
            return assetNetAmountMapString;
        }
        return null;
   }


    @RemoteAction
    public static void delteOpportunityLineItem (string proposalId,string opportunityId) {

        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
        prop = [select id,Apttus_Proposal__Opportunity__c,Line_Item_SKU__c,Apttus_Proposal__Primary__c,Apttus_Proposal__Opportunity__r.AccountId,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c  where id=:proposalId];
        if(prop.Apttus_Proposal__Primary__c) {
            List<OpportunityLineItem> oppLitemList = new List<OpportunityLineItem> ();
            oppLitemList = [select id from OpportunityLineItem where opportunityId =:opportunityId];
            if(oppLitemList.size() > 0) {
                delete oppLitemList;
            }
        }

    } 


    @RemoteAction
    public static void acceptproposal (string proposalId) {
       // system.debug('proposalId :'+proposalId);

       APTSCU_AcceptProposalUtil.acceptProposal(proposalId);

    }

    @RemoteAction
    public static boolean changeOpportunityStatus (string proposalId,string opportunityId) {
      // system.debug('proposalId :'+proposalId);

       Boolean OrderCreated = false;
       List<Apttus_Config2__AssetLineItem__c> assetList = new List<Apttus_Config2__AssetLineItem__c>();
       assetList = [select id from  Apttus_Config2__AssetLineItem__c where Apttus_QPConfig__ProposalId__c=:proposalId];
      // system.debug('assetList :'+assetList);
        if(assetList.size() > 0) {
           OrderCreated = true;
           
           Opportunity opp = new Opportunity ();
           opp = [select id,stageName,RecordTypeId from Opportunity where id=:opportunityId];
           opp.stageName = label.Stage_6_Closed_Won;// 13 - Closed & Approved By Finance 
           update opp;
           
       }
       APTSCU_CreateProposalUtility.createOpportunityProduct(proposalId, opportunityId);
       return OrderCreated;
    }

    @RemoteAction
    public static string createRenewalOpportunity (string proposalId,string accountId,string opportunityId,string billtoAccountId) {
        Id priceListId;
        String salesOrderNumber;
        
        List<opportunity> renewalOppList = new List<Opportunity> ();
        List<opportunity> UpsellnewOppList = new List<Opportunity> ();
        renewalOpplist = [SELECT Id,
                            Name,
                            Type,
                            StageName,
                            Price_List__r.Name,
                            Price_List__c,
                            OwnerId,
                            Primary_Partner_Program__c, //added by minkesh for new requirement 1
                            LeadSource,
                            Description,
                            CloseDate,
                            Amount,
                            AccountId,
                            Netsuite_Sales_Order_No__c 
                        FROM Opportunity 
                        WHERE Type='Existing Customer (Renewal)' 
                            AND AccountId =: accountId 
                            AND id !=: opportunityId 
                            AND Isclosed = false];
                            
        //added by minkesh for new Requirement 2 - start 
        /*UpsellnewOppList = [SELECT Id,
                            Name,
                            Type,
                            StageName,
                            Price_List__r.Name,
                            Price_List__c,
                            OwnerId,
                            Primary_Partner_Program__c, //added by minkesh for new requirement 1
                            LeadSource,
                            Description,
                            CloseDate,
                            Amount,
                            AccountId,
                            Netsuite_Sales_Order_No__c 
                        FROM Opportunity 
                        WHERE Type='Existing Customer (Add On)' 
                        AND AccountId =: accountId 
                        AND id !=: opportunityId 
                        AND Isclosed = false];  
        System.debug('UpsellnewOppList++++'+UpsellnewOppList);*/
        //added by minkesh for new Requirement 2 - end
                        
        Account accountSO = [SELECT Id, 
                                    APTS_Platform_Subscription_End_Date__c
                            FROM Account
                            WHERE id = :accountId];

        Apttus_Proposal__Proposal__c proposal = [SELECT Id,
                                                    Line_Item_SKU__c, 
                                                    Apttus_QPConfig__PriceListId__c 
                                                FROM Apttus_Proposal__Proposal__c 
                                                WHERE Id = :proposalId LIMIT 1];
        priceListId = proposal.Apttus_QPConfig__PriceListId__c;
        String lineitemskus =proposal.Line_Item_SKU__c;

        List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c> ();
        assetLineItems = [select id,
                                 Apttus_Config2__SellingTerm__c,
                                 Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,
                                 Apttus_Config2__ProductId__r.Zscaler_Product_Family__c,
                                 Apttus_Config2__ProductId__c,
                                 Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c,
                                 Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,
                                 Apttus_Config2__Quantity__c,Apttus_Config2__StartDate__c,
                                 Apttus_Config2__EndDate__c,
                                 Apttus_Config2__NetPrice__c 
                         from Apttus_Config2__AssetLineItem__c 
                         where Apttus_Config2__AccountId__c=:accountId 
                         AND Apttus_Config2__ChargeType__c='Subscription Fee' 
                         AND Apttus_Config2__AssetStatus__c='Activated' 
                         AND Apttus_Config2__ProductId__r.productcode NOT IN ('ZCR-UPY5','ZCR-UPY4')];
        // system.debug('@@@@@@--'+assetLineItems );
        Date maxDate = null;
        if(accountSO.APTS_Platform_Subscription_End_Date__c == null) {
           for(Apttus_Config2__AssetLineItem__c asset :assetLineItems) {
               if(maxDate == null || maxDate <asset.Apttus_Config2__EndDate__c) {
                   maxDate = asset.Apttus_Config2__EndDate__c;
                }
            }
        }
        //added by minkesh for new Requirement 2 - start
        boolean createnewopp = false;
        List<Apttus_Config2__LineItem__c> oldlineitemlist = new List<Apttus_Config2__LineItem__c> ();
 
        oldlineitemlist = [select id,
                                  Apttus_Config2__ProductId__c,
                                  Apttus_Config2__ProductId__r.Zscaler_Product_Family__c ,
                                  Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c,
                                  Apttus_Config2__AssetLineItemId__c,
                                  Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c,
                                  Apttus_Config2__NetPrice__c,
                                  Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c 
                            from Apttus_Config2__LineItem__c 
                            where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c =: proposalId 
                            AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c = 'Finalized'];
        
        Map<String,List<Apttus_Config2__AssetLineItem__c>> oldProposalLineItemProductMap = new Map<String,List<Apttus_Config2__AssetLineItem__c>>();
        Set<Id> currentAssetsIds = new Set<Id>();
        for(Apttus_Config2__AssetLineItem__c asset : assetLineItems) {
            if( asset.Apttus_QPConfig__ProposalId__c != null && asset.Apttus_QPConfig__ProposalId__c == ProposalId ) {
                currentAssetsIds.add(asset.Id); 
            } else if( asset.Apttus_QPConfig__ProposalId__c != null ){
                if(oldProposalLineItemProductMap.containsKey(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
                    oldProposalLineItemProductMap.get(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c).add(asset);
                }else{
                    oldProposalLineItemProductMap.put(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, new List<Apttus_Config2__AssetLineItem__c>{asset});
                    //createnewopp = true;
                    System.debug('createnewopp++++'+createnewopp);
                }
                  
            }
              
         }
        createnewopp = true;
        for(Apttus_Config2__LineItem__c oldliitem : oldlineitemlist){
            if(oldProposalLineItemProductMap.containsKey(oldliitem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c) 
                && oldliitem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c != APTS_CONSTANTS.PROD_SUPPORT_FAMILY
                && oldliitem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c != APTS_CONSTANTS.PROD_DEPLOYMENT_FAMILY) {
                createnewopp = false;
                break;
            }
        }
        
        //added by minkesh for new Requirement 2 - end
        
        if(assetLineItems.size() > 0 ) {//added by minkesh for new Requirement 2 -  (createnewopp == true)
            System.debug('createnewopp++++'+createnewopp);

            boolean iscloned = false;
            Opportunity opp = new Opportunity ();
            //why is this created ??
            Opportunity oppOld =[select Id,Primary_Partner_Program__c,Partner_Margin_Adjustment__c from Opportunity where Id = :opportunityId];
            String partnerprog = oppOld.Primary_Partner_Program__c;
            //above two lines are not required.
            String querystring = getQueryStringWithAllFields('Opportunity','id=:opportunityId');
            opp  = Database.query(querystring);
            salesOrderNumber = opp.Netsuite_Sales_Order_No__c;
            Opportunity clonedOpp;
            if(renewalOpplist.size() == 0 ||  createnewopp == true) {
                clonedOpp = opp.clone(false,true);
                clonedOpp.Type ='Existing Customer (Renewal)';
                clonedOpp.StageName = label.Stage_4_Economic_Buyer_Signoff;//'8 - Expecting Order';
                //added by minkesh for new Requirement 2 - start
                /*if(createnewopp == true && UpsellnewOppList.size() == 0){
                    clonedOpp.Name = clonedOpp.Name + ' - Upsell/New';
                }
                else{
                    clonedOpp.Name = clonedOpp.Name + ' - Renew';
                }*/
                //added by minkesh for new Requirement 2 - end
                
                clonedOpp.Name = clonedOpp.Name + ' - Renew';
                clonedOpp.APTS_Primary_Proposal_Lookup__c = null;
                clonedOpp.NextStep = null;
                //clonedOpp.Opportunity_Next_Step_History__c = null;
                clonedOpp.Description = null;
                clonedOpp.Comment_On_Budget__c = null;
                clonedOpp.Summarize_the_Procurement_Process__c = null;
                clonedOpp.What_makes_this_ZPA_deal_strategic__c = null;
                clonedOpp.Summarize_the_Value_to_the_Customer__c = null;
                clonedOpp.Identify_Compelling_Events__c = null;
                clonedOpp.Opportunity_Risk__c = null;
                clonedOpp.Eloborate_the_health_of_the_opportunity__c = null;
                clonedOpp.Closed_Resolution__c = null;
                clonedOpp.Split__c = false;
                clonedOpp.ELA_Approved_Opportunity__c = false;
                clonedOpp.Additional_Customer_Information__c = null;

                clonedOpp.Adoption_Status_Gsuite__c = null;
                clonedOpp.Adoption_Status_O365__c = null;
                clonedOpp.Architect__c = null;
                clonedOpp.Architecture_Document__c = null;
                clonedOpp.Architecture_Next_Steps__c = null;
                clonedOpp.Architecture_Stage__c = null;
                clonedOpp.CampaignId = null;
                clonedOpp.Competitors__c = null;
                clonedOpp.Deal_Lost_To__c = null;
                clonedOpp.Deal_Reg__c = null;
                clonedOpp.Detailed_Loss_Reason__c = null;
                clonedOpp.Emerging_Technology_Specialist__c = null;
                clonedOpp.Emerging_Technology__c = null;
                clonedOpp.Exec_Owner__c = null;
                clonedOpp.Gsuite_Comments__c = null;
                clonedOpp.Gsuite_Roll_Out_Status__c = null;
                clonedOpp.Incumbent__c = null;
                clonedOpp.Next_Steps__c = null;
                clonedOpp.O365_Comments__c = null;
                clonedOpp.Partner_Close_Date__c = null;
                clonedOpp.Partner_Comments__c = null;
                clonedOpp.Partner_Forecast_Category__c = null;
                clonedOpp.Partner_Role__c = null;
                clonedOpp.Primary_Project_Contact_Name__c = null;
                clonedOpp.Primary_Project_Contact_Phone__c = null;
                clonedOpp.Primary_Reason_For_Loss__c = null;
                clonedOpp.Primary_ZPA_Use_Case__c = null;
                clonedOpp.Private_apps_in_IaaS_cloud__c = null;
                clonedOpp.Secondary_Partner_Role__c = null;
                clonedOpp.Secondary_Partner__c = null;
                clonedOpp.Secondary_Reason_For_Loss__c = null;
                clonedOpp.Secondary_Use__c = null;
                clonedOpp.Source__c = null;
                clonedOpp.Service_Start_Date__c = null;
                clonedOpp.Technical_Validation_Start_Date__c = null;
                clonedOpp.Validation_End_Date__c = null;
                clonedOpp.Validation_Plan__c = null;
                clonedOpp.Validation_Report__c = null;
                clonedOpp.Validation_Stage__c = null;
                clonedOpp.Zway_Fully_Utilized__c = null;

                 //added as part of Summit - Raghu
                 clonedOpp.Primary_Partner_Program__c = opp.Primary_Partner_Program__c != null ? opp.Primary_Partner_Program__c : 'Legacy';
                 clonedOpp.Architectural_Workshop_Margin__c = null;
                 clonedOpp.POV_Margin__c = null;
                 clonedOpp.Deal_Reg_Margin__c = null;


                // NS - SF Integration
                clonedOpp.Netsuite_Sales_Order_Internal_ID__c = null;
                clonedOpp.Netsuite_Sales_Order_No__c = clonedOpp.Netsuite_Sales_Order_Number__c;
                clonedOpp.Netsuite_Sales_Order_Number__c = null;
                clonedOpp.NS_Integration_Status__c = 'Not Started';
                clonedOpp.NS_Integration_Failure_Reason__c = null;
                clonedOpp.Netsuite_Primary_Partner_ID_Override__c = null;
                clonedOpp.Netsuite_Customer_ID_Override__c = null;
                clonedOpp.NS_Integration_Requested_By__c = null;
                clonedOpp.Partner_PO_Number__c = null;


                if(accountSO.APTS_Platform_Subscription_End_Date__c != null) {
                    clonedopp.CloseDate = accountSO.APTS_Platform_Subscription_End_Date__c;
                    clonedopp.Start_Date__c = accountSO.APTS_Platform_Subscription_End_Date__c.addDays(1);
                    clonedopp.End_Date__c = accountSO.APTS_Platform_Subscription_End_Date__c.addMonths(36);

                } else {
                    clonedopp.CloseDate = maxDate;
                    clonedopp.Start_Date__c = maxDate.addDays(1);
                    clonedopp.End_Date__c = maxDate.addMonths(36);
                }

                //List<Pricebook2> stdPBL = [select id,name from Pricebook2 where name='Apttus Default Price Book'];
                clonedopp.pricebook2Id = opp.pricebook2Id;
                clonedopp.Expected_Term_Months__c = opp.Expected_Term_Months__c;
                clonedopp.Pushed_deal__c = false;
                clonedopp.Pushed_From_Quarter__c = '';
                clonedopp.VMO_Play__c = '';
                clonedopp.Applied_Price_List_Name__c = 'FY20 Pricelist';
                clonedopp.Probability = 90;
                //changed as part of new custom Forecasting functionality
                //clonedopp.ForecastCategoryName = 'Commit';
                clonedopp.Forecast_Category__c = 'Commit';
                if(opp.Account.Customer_Advocate__c != null) {
                    clonedopp.ownerid = opp.Account.Customer_Advocate__c;
                }
                // system.debug('@@@@'+clonedopp);
                
                //Clear my number fields for renewals - 05-feb-2019 - START
                clonedopp.RD_In_my_Number__c = false;
                clonedopp.RVP_In_my_Number__c = false;
                clonedopp.Renewal_RD_In_my_Number__c = false;
                clonedopp.Renewal_RVP_In_my_Number__c = false;
                //clonedopp.Renewal_VP_In_my_Number__c = false;
                //clonedopp.AVP_In_my_Number__c = false;
                //clonedopp.Geo_VP_In_my_Number__c = false;
                
                //Clear my number fields for renewals - 05-feb-2019 - END
                
                insert clonedOpp;

                /*
                Updated BY : Sateesh U 
                To Create Opportunity Partner Records instead of creating old partners
                */
                List<Opportunity_Partner__c> oppPartnerRecs = [SELECT Id, Name, Account__c, 
                                                                        Account__r.Name,
                                                                        Approval_Status__c,
                                                                        Is_Primary__c,
                                                                        Opportunity__c,
                                                                        Opportunity_Type__c,
                                                                        Opportunity__r.Name,
                                                                        Partner_Program__c,
                                                                        Partner_Type__c 
                                                                FROM Opportunity_Partner__c 
                                                                WHERE Opportunity__c = :opp.Id
                                                                AND Partner_Type__c NOT IN (:Label.Partner_Type_Deal_Reg,:Label.Partner_Type_POV,:Label.Partner_Type_AW)
                                                                AND Account__c != :opp.AccountId];
                if(oppPartnerRecs.size()>0 ){
                    List<Opportunity_Partner__c> partnerList = new List<Opportunity_Partner__c> ();

                    for(Opportunity_Partner__c OppPartner:oppPartnerRecs){
                        Opportunity_Partner__c partner = new Opportunity_Partner__c();
                        partner.Is_Primary__c = OppPartner.Is_Primary__c;
                        partner.Partner_Type__c = OppPartner.Partner_Type__c;
                        partner.Partner_Program__c = OppPartner.Partner_Program__c;
                        partner.Account__c = OppPartner.Account__c;
                        
                        if(!renewalOppList.isEmpty()){
                            partner.Opportunity__c = renewalOppList[0].Id;
                        }
                        else if(clonedOpp != null){
                            partner.Opportunity__c = clonedOpp.Id; 
                        }
                        partner.Partner_Type__c = OppPartner.Partner_Type__c;
                        partner.Approval_Status__c = OppPartner.Approval_Status__c;
                        partnerList.Add(partner);
                    }
                    if(partnerList.size()>0){
                        insert partnerList;
                    }
                }
               iscloned = true;
            }
            String proposalIdNew;
            
            if(iscloned) {
                if(accountSO.APTS_Platform_Subscription_End_Date__c != null) {
                    proposalIdNew = APTSCU_CreateProposalUtility.createQuoteOrProposal(clonedOpp, accountSO.APTS_Platform_Subscription_End_Date__c, billtoAccountId, priceListId);
                } else {
                    proposalIdNew = APTSCU_CreateProposalUtility.createQuoteOrProposal(clonedOpp, maxDate, billtoAccountId, priceListId);
                }
            } else {
                if(accountSO.APTS_Platform_Subscription_End_Date__c != null) {
                    proposalIdNew = APTSCU_CreateProposalUtility.createQuoteOrProposal(renewalOpplist[0],accountSO.APTS_Platform_Subscription_End_Date__c, billtoAccountId, priceListId);
                } else{
                    proposalIdNew = APTSCU_CreateProposalUtility.createQuoteOrProposal(renewalOpplist[0],maxDate, billtoAccountId, priceListId);
                } 
                
                Apttus_Proposal__Proposal__c  proposalnew= [select id,
                                                                    Line_Item_SKU__c,
                                                                    Model_Type_Partner__c,
                                                                    Apttus_QPConfig__BillToAccountId__c 
                                                            from Apttus_Proposal__Proposal__c 
                                                            where id=:proposalIdNew];
                //if exiting renewal opp has legacy and new upsell quote has partner sumit program copy legacy to new proposal
                //Added by minkesh for new requirement 1 start
                if(!renewalOpplist.isempty() && (renewalOpplist[0].Primary_Partner_Program__c == null 
                    || renewalOpplist[0].Primary_Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_LEGACY)
                        && partnerprog == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT){
                    proposalnew.Model_Type_Partner__c = APTS_CONSTANTS.P_PARTNERPRG_LEGACY;
                }else{
                    proposalnew.Model_Type_Partner__c = partnerprog;
                }
                //Added by minkesh for new requirement 1 end
                proposalnew.Line_Item_SKU__c = lineitemskus;
                update proposalnew;
               
                //added by Minkesh patel due to Requirement 3 - start
                List<Opportunity_Partner__c> oppPartnOldList = [SELECT Id, Name, Account__c, 
                                                                        Account__r.Name,
                                                                        Approval_Status__c,
                                                                        Is_Primary__c,
                                                                        Opportunity__c,
                                                                        Opportunity_Type__c,
                                                                        Opportunity__r.Name,
                                                                        Partner_Program__c,
                                                                        Partner_Type__c 
                                                                FROM Opportunity_Partner__c 
                                                                WHERE Opportunity__c = :oppOld.Id];
                if(oppPartnOldList.size()>0 ){
                    List<Opportunity_Partner__c> oppPartnerNewList = new List<Opportunity_Partner__c> ();

                    for(Opportunity_Partner__c OppPartner:oppPartnOldList){
                        Opportunity_Partner__c partner = new Opportunity_Partner__c();
                        partner.Is_Primary__c = OppPartner.Is_Primary__c;
                        partner.Partner_Type__c = OppPartner.Partner_Type__c;
                        partner.Partner_Program__c = OppPartner.Partner_Program__c;
                        partner.Account__c = OppPartner.Account__c;
                        partner.Opportunity__c = renewalOppList[0].Id;
                        partner.Partner_Type__c = OppPartner.Partner_Type__c;
                        partner.Approval_Status__c = OppPartner.Approval_Status__c;
                        System.debug('OppPartner.Partner_Type__c----'+OppPartner.Partner_Type__c);
                        if((OppPartner.Partner_Type__c == 'Architecture Workshop'
                            || OppPartner.Partner_Type__c == 'POV')
                            && OppPartner.Partner_Program__c == APTS_CONSTANTS.P_PARTNERPRG_PARTSUMMIT
                            && OppPartner.Opportunity_Type__c == APTS_CONSTANTS.P_RT_NBUSINESS)
                        {
                           System.debug('-do nothing-----'); 
                        }else{
                            oppPartnerNewList.Add(partner);
                            System.debug('-do add-----'+partner.Partner_Type__c);
                        }
                    }
                    if(oppPartnerNewList.size()>0){
                        insert oppPartnerNewList;
                    }
                }
                //added by Minkesh patel due to Requirement 3 - end

                // Logic to update the Netsuite Sales Orders To Be Renewed
                Opportunity opportunityToUpdate = new Opportunity(Id = renewalOppList[0].Id);
                String existingOrderNumbers = renewalOppList[0].Netsuite_Sales_Order_No__c;

                Set<String> orderNumbersSet = new Set<String>();
                if(!string.isBlank(existingOrderNumbers)){
                    for (String orderNo : existingOrderNumbers.split(',')) {
                        if (String.isNotBlank(orderNo.trim())){
                            orderNumbersSet.add(orderNo);
                        }
                    }
                }
                

                orderNumbersSet.add(salesOrderNumber);

                opportunityToUpdate.Netsuite_Sales_Order_No__c = joinSet(orderNumbersSet, ',');
                //opportunityToUpdate.Primary_Partner_Program__c = oppOld.Primary_Partner_Program__c;
                opportunityToUpdate.Partner_Margin_Adjustment__c = oppOld.Partner_Margin_Adjustment__c;
                try {
                    update opportunityToUpdate;
                } catch(Exception ex) {
                    System.debug('Exception occurred while updating the renewal opportunity with Sales Order Number. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
                }
            }
            // Apttus_Proposal__Proposal__c  prp = [select id,Apttus_QPConfig__BillToAccountId__c from Apttus_Proposal__Proposal__c where id=:proposalIdNew];
            // prp.Apttus_QPConfig__BillToAccountId__c = billtoAccountId;
            // update prp;
            return proposalIdNew + '::' + ( renewalOpplist.size() > 0 && createnewopp ? createnewopp : false); //Added by minkesh for new requirement 2

        }
        return null;
    }


    @RemoteAction
    public static string CreateCartForProposal (string proposalId) {
       // system.debug('@@@@@@@ -proposalId '+proposalId);
        String cartId = APTSCU_CreateProposalUtility.CreateCartForProposal(proposalId);
        return cartId;
    }

    /*
    @RemoteAction
    public static void addAssetLineItemsToCart (string cartId,String proposalId, String accountId) {
        List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c> ();
        assetLineItems = [select id,Apttus_Config2__SellingTerm__c,APTS_ACV__c,Apttus_QPConfig__ProposalId__c,Apttus_Config2__ProductId__c,Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,Apttus_Config2__Quantity__c,Apttus_Config2__StartDate__c,
                                                                  Apttus_Config2__EndDate__c, Apttus_Config2__IsPrimaryLine__c, Apttus_Config2__IsPrimaryRampLine__c, Apttus_Config2__BundleAssetId__c, CreatedDate from Apttus_Config2__AssetLineItem__c where Apttus_Config2__AccountId__c=:accountId AND Apttus_Config2__ChargeType__c='Subscription Fee' AND Apttus_Config2__AssetStatus__c='Activated'];
        List<product2> productList = new List<product2> ();
        boolean insertPremierSupport = false;
        string productId;
        productList = [select id,name from product2 where productcode='ZCES-SUP-PREM' AND family = 'Zscaler Products'];
        if(productList.size() > 0) {
            productId = string.valueof(productList[0].Id).substring(0,15);
            boolean flag = true;
            for(Apttus_Config2__AssetLineItem__c asset :assetLineItems) {
                if(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15) == productId) {
                     flag = false;
                }
            }
            if(flag) {
                insertPremierSupport = flag;
            }
        }

        APTSCU_CreateProposalUtility.addAssetLineItemsToCartRemote(accountId,cartId,assetLineItems,insertPremierSupport,productId);
    }
    */

    @RemoteAction
    public static void addPremiumsupport(string cartId, string productId) {
        APTSCU_Assetutils.addPremiumSupport(cartid,productid);
    }

    @RemoteAction
    public static boolean renewIndividualAssetLineItem (Integer currentIndex,String cartId, String allAssetMapData, string AssetMapTorenewData, String assetQuantityMapData, String oldProposalId, String assetNetAmountMapString) { // Added By Minkesh for requirement 1 (oldProposalId)
        Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap = (Map<Id,Apttus_Config2__AssetLineItem__c>)JSON.deserialize(allAssetMapData,Map<Id,Apttus_Config2__AssetLineItem__c>.class);
        Map<Integer,Apttus_Config2__AssetLineItem__c> AssetMapTorenew = (Map<Integer,Apttus_Config2__AssetLineItem__c>)JSON.deserialize(AssetMapTorenewData,Map<integer,Apttus_Config2__AssetLineItem__c>.class);
        Map<String,Decimal> assetQuantityMap = (Map<String,Decimal>)JSON.deserialize(assetQuantityMapData,Map<String,Decimal>.class);
        Map<String,Decimal> assetNetAmountMap = (Map<String,Decimal>)JSON.deserialize(assetNetAmountMapString,Map<String,Decimal>.class); // Added By Minkesh for requirement 1
       // system.debug('@@allAssetMapData'+allAssetMapData);
       // system.debug('@@AssetMapTorenewData'+AssetMapTorenewData);
       // system.debug('@@assetQuantityMapData'+assetQuantityMapData);
       // system.debug('@@assetQuantityMap'+assetQuantityMap);
       // system.debug('currentIndex'+currentIndex);
       // system.debug('cartId :' +cartId);
        if(AssetMapTorenew.get(currentIndex) != null)
        APTSCU_Assetutils.renewIndividualAssetLineItem(AssetMapTorenew.get(currentIndex),cartId,allAssetMap,assetQuantityMap, oldProposalId, assetNetAmountMap); // Added By Minkesh for requirement 1 (oldProposalId, assetNetAmountMap)
        if(currentIndex == AssetMapTorenew.size()) {
            return true;
        } else {
            return false;
        }

    }

    @RemoteAction
    public static void calculateOldACV (string cartid,string accountid) {

       List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();

       //added by minkesh for new Requirement 1 - start
       /* List<Apttus_Config2__LineItem__c> oldlineitemlist = new List<Apttus_Config2__LineItem__c> ();

        oldlineitemlist = [select id,Apttus_Config2__ProductId__c,Apttus_Config2__ProductId__r.Zscaler_Product_Family__c ,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c =: oldProposalId AND Apttus_Config2__ConfigurationId__r.Apttus_Config2__Status__c = 'Finalized'];*/



        //added by Minkesh for new Requirement 1 - end
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
        
        lineitemlist = [select id, APTS_MRR__c,Apttus_Config2__AdjustmentType__c,APTS_Prev_MRR__c,Apttus_Config2__ProductId__c,Apttus_Config2__StartDate__c,Apttus_Config2__AssetLineItemId__c,Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ProductId__r.Zscaler_Product_Family__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, Old_PPU__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];

        Apttus_Proposal__Proposal__c prop = [select id,APTSCU_Original_Quote_ACV__c,APTS_Original_Quote_MRR__c,APTS_Original_Quote_TCV__c from Apttus_Proposal__Proposal__c where id=:lineitemlist[0].Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c];

        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        proposalList  = [select id,APTS_Proposal_Net_Price__c from Apttus_Proposal__Proposal__c where id!=:prop.id AND Apttus_Proposal__Account__c=:accountid AND Apttus_Proposal__Opportunity__r.type != 'Existing Customer (Renewal)'];

        Decimal MRRTotalOld = 0;
        Decimal TCVTotalOld = 0;
        Decimal ACVTotalOld = 0;
        // Set<String> prodfamilyset = new Set<String>();
        // Set<Id> newbusprod = new Set<Id>();
        // Set<Id> upsellprod = new Set<Id>();

        List<Apttus_Config2__AssetLineItem__c> assetLineItems = new List<Apttus_Config2__AssetLineItem__c> ();
        assetLineItems = [select id,
                                 Apttus_Config2__SellingTerm__c,
                                 Apttus_Config2__ProductId__r.Zscaler_Product_Family__c,
                                 APTS_ACV__c,
                                 Apttus_QPConfig__ProposalId__c,
                                 Apttus_Config2__ProductId__c,
                                 Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c,
                                 Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c,
                                 Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c,Apttus_Config2__Quantity__c,
                                 Apttus_Config2__StartDate__c,
                                 Apttus_Config2__EndDate__c,
                                 Apttus_Config2__IsPrimaryLine__c,
                                 Apttus_Config2__IsPrimaryRampLine__c,
                                 Apttus_Config2__BundleAssetId__c,
                                 Apttus_Config2__NetPrice__c,
                                 CreatedDate,
                                 Apttus_QPConfig__ProposalLineItemId__r.Price_Per_Unit__c from Apttus_Config2__AssetLineItem__c
                        where Apttus_Config2__AccountId__c=:accountId 
                        AND Apttus_Config2__ChargeType__c='Subscription Fee' 
                        AND Apttus_Config2__AssetStatus__c='Activated' 
                        AND Apttus_Config2__ProductId__r.productcode NOT IN ('ZCR-UPY5','ZCR-UPY4')];


         Decimal oldMRR;
         Decimal oldPPU;
         
         /* commented by sagar - 15/12
         for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            if(litem.Apttus_Config2__AssetLineItemId__c != null) {
                oldMRR = 0;
                for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
                   // system.debug('@@@ - '+ string.valueOf(asset.id).substring(0,15));
                   // system.debug('### - '+ string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15));

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

         commented by sagar end */

         //&& asset.Apttus_QPConfig__ProposalId__r.Model_Type_Partner__c  == 'Legacy' && !oldlineitemlist.isempty() && oldlineitemlist.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Model_Type_Partner__c == 'Partner Summit'

         /*for(Apttus_Config2__AssetLineItem__c asset : assetLineItems) {
            if( asset.Apttus_QPConfig__ProposalId__c != null && asset.Apttus_QPConfig__ProposalId__c == oldProposalId ) {
                currentAssetsIds.add(asset.Id); 
            } else if( asset.Apttus_QPConfig__ProposalId__c != null ){
                if(oldProposalLineItemProductMap.containsKey(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
                    oldProposalLineItemProductMap.get(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c).add(asset);
                }else{
                    oldProposalLineItemProductMap.put(asset.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c, new List<Apttus_Config2__AssetLineItem__c>{asset});
                }
                  
            }
              
         }*/
        
        Boolean hasAssetFamilies = false;
        for(Apttus_Config2__LineItem__c litem : lineitemlist) {
            if(litem.Apttus_Config2__AssetLineItemId__c != null) {
                oldMRR = 0;
                oldPPU = 0;
                
               
                for(Apttus_Config2__AssetLineItem__c asset : assetLineItems) {
                    // // system.debug('@@@ - '+ string.valueOf(asset.id).substring(0,15));
                    // // system.debug('### - '+ string.valueOf(litem.Apttus_Config2__AssetLineItemId__c).substring(0,15));
                    //system.debug('---'+string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15));
                    //system.debug('---'+string.valueOf(litem.Apttus_Config2__ProductId__c).substring(0,15));
                    // system.debug('---'+asset.Apttus_QPConfig__ProposalId__c);
                    // system.debug('---'+litem.Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c);
                     
                    
                    if(string.valueOf(asset.Apttus_Config2__ProductId__c).substring(0,15) == string.valueOf(litem.Apttus_Config2__ProductId__c).substring(0,15)
                            && asset.Apttus_QPConfig__ProposalId__c != null 
                            && litem.Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c != null
                            && string.valueOf(asset.Apttus_QPConfig__ProposalId__c).substring(0,15) == string.valueOf(litem.Apttus_Config2__AssetLineItemId__r.Apttus_QPConfig__ProposalId__c).substring(0,15)
                            ) {
                        oldMRR = oldMRR + ( asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c != null ? asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c : 0 );
                        oldPPU += ( asset.Apttus_QPConfig__ProposalLineItemId__r.Price_Per_Unit__c != null ? asset.Apttus_QPConfig__ProposalLineItemId__r.Price_Per_Unit__c : 0 );

                    }
                   // system.debug('5==='+oldMRR);
                }
                litem.APTS_Prev_MRR__c = oldMRR;
                litem.Old_PPU__c = oldPPU;
            }
          
            //added  by minkesh for new Requirement 1 - start 
            /*list<Apttus_Config2__LineItem__c> newLitoUpdate = new List<Apttus_Config2__LineItem__c>();
            if(oldProposalLineItemProductMap.Containskey(litem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c) && currentAssetsIds.contains(litem.Apttus_Config2__AssetLineItemId__c)){
                for(Apttus_Config2__AssetLineItem__c oldli : oldProposalLineItemProductMap.get(litem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c)){
                    if(oldli.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c == litem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c
                        && oldli.Apttus_Config2__ProductId__c != litem.Apttus_Config2__ProductId__c ){

                        litem.Apttus_Config2__AdjustmentType__c = 'Price Override';
                        litem.Apttus_Config2__AdjustmentAmount__c = oldli.Apttus_Config2__NetPrice__c;
                        hasAssetFamilies = true;

                        System.debug('@@@@@@@@@litem:' + litem.Apttus_Config2__AdjustmentAmount__c + '@@' + litem.Id + '@@' + litem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c);
                        System.debug('@@@@@@@@@litem:' + oldli.Apttus_Config2__NetPrice__c + '@@' + oldli.Id);
                        break;
                    }
                }
                
            }*/
            
            //if(!newLitoUpdate.isEmpty() )
                //update newLitoUpdate;
            
        //end of added  by minkesh for new Requirement 1 - end

         }

         update lineitemlist;
        //  for(Apttus_Config2__LineItem__c litem : lineitemlist) {
        //     System.debug('@@@@@@@@@litem:' + litem.Apttus_Config2__AdjustmentAmount__c + '@@' + litem.Id + '@@' + litem.Apttus_Config2__ProductId__r.Zscaler_Product_Family__c);
        //  }

         for(Apttus_Config2__AssetLineItem__c asset:assetLineItems) {
             
             if(asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c != null) {
                 MRRTotalOld = MRRTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.APTS_MRR__c;
             }
             if(asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c != null) {
                // TCVTotalOld = TCVTotalOld + asset.Apttus_QPConfig__ProposalLineItemId__r.Apttus_QPConfig__NetPrice__c ;
             }
               if(asset.APTS_ACV__c != null) {
                 ACVTotalOld = ACVTotalOld +asset.APTS_ACV__c;
             }
         }

         for(Apttus_Proposal__Proposal__c prop1 :proposalList ) {
            TCVTotalOld = TCVTotalOld + prop1.APTS_Proposal_Net_Price__c;
           
         }
            
             prop.APTS_Original_Quote_MRR__c = MRRTotalOld ;
             prop.APTS_Original_Quote_TCV__c = TCVTotalOld ;
             prop.APTSCU_Original_Quote_ACV__c = ACVTotalOld;
            update prop;

    }


    @RemoteAction
    public static void deleteRampLineItem(string cartId,string accountId) {
       // system.debug('1deleteRampLineItem ');
        APTSCU_CreateProposalUtility.deleteRampLineItem(cartId,accountId);
    }

    @RemoteAction
    public static void finalizeProposal (string cartId, string templateID) {

        APTSCU_CreateProposalUtility.finalizeCartRemote(cartId,templateID);
    }

    //added by minkesh for new Requirement 1 - start
    @RemoteAction
    public static void RenewUpsellProposal (string cartId, string proposalId, string oldProposalId,string accountId) {
        APTSCU_CreateProposalUtility.RenewUpsellProposal(cartId,proposalId,oldProposalId,accountId);
    }
    //added by minkesh for new Requirement 1 - end

    //added by Raghu as part of Parter Margin
    @RemoteAction
    public static void makePrimary(String proposalId)
    {
        Apttus_Proposal__Proposal__c prop = [select id, Apttus_Proposal__Opportunity__c from  Apttus_Proposal__Proposal__c where id=: proposalId];
        APTSCU_CreateProposalUtility.createOpportunityProduct(proposalId,prop.Apttus_Proposal__Opportunity__c);
    }
    //end of change - Raghu


    @RemoteAction
    public static void generateDocument(String proposalId, String apiServerURL, String templateId,String sessionId) {

        APTSCU_CreateProposalUtility.generateDocument(proposalId,apiServerURL,templateId,sessionId);
    }

     @RemoteAction
    public static boolean repriceCart (String cartId) {
         return APTSCU_CreateProposalUtility.repriceCart(cartId);
    }


     public static string getQueryStringWithAllFields(String objectName, String whereClause){
        String selects = '';

        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && !fd.isUnique() && fd.isUpdateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }

        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if(objectName == 'Opportunity') {
                selects += 'Price_List__r.Name' + ',';
                selects += 'Account.Customer_Advocate__c' + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}

        }

        if (whereClause != null) {
            return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        }
        else {
            return 'SELECT ' + selects + ' FROM ' + objectName ;
        }

    }

    @testvisible private static String joinSet(Set<String> items, String separator) {
        String result = '';

        for (String item : items) {
            result += (item + separator);
        }

        if (result.length() > 0) {
            result = result.substring(0, result.length() - separator.length());
        }

        return result;
    }

}