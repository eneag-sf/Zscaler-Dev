@isTest
public class APTSCU_AssetUtilsTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string cartId;
    public static list<Apttus_Config2__AssetLineItem__c> assetList;
    public static string prdId; 
    public static Apttus_Config2__AssetLineItem__c asset;
    
   static
    {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
    	assetList = new list<Apttus_Config2__AssetLineItem__c>();
    
        acc = APTS_TestUtil.creatAccount ();
        pricelist = APTS_TestUtil.createpricelist ();
        
        opp = APTS_TestUtil.createOpportunity (acc.Id,pricelist.Id);
        
        prop = APTS_TestUtil.createproposal(opp.id,acc.id,pricelist.id,false);
        
      
        prdId = APTS_TestUtil.createProduct (); 
        Apttus_Proposal__Proposal_Line_Item__c prl = APTS_TestUtil.createProposalLineItem(prop.Id,prdId );
        //Made asset public - Anay
        asset = APTS_TestUtil.createassetlineItems (prop.Id,acc.id,prdId,prl.id);
        assetList.add(asset);
        cartid = APTSCU_CreateProposalUtility.CreateCartForProposal(prop.id);
        
     
    }

    //********************
    //Added by Anay Bhande
    @isTest static void addPremiumSupportTest () {
        Test.startTest();        
        APTSCU_AssetUtils.addPremiumSupport (cartid,prdId);
        Test.stopTest();
    }
    
    @isTest static void renewIndividualAssetLineItemTest () {
        Test.startTest();        
        Map<Id,Apttus_Config2__AssetLineItem__c> allAssetMap =new Map<Id,Apttus_Config2__AssetLineItem__c>();
        allAssetMap.put(asset.Id, asset);
        Map<String,Decimal> assetQuantityMap=new Map<String,Decimal>();
        assetQuantityMap.put(string.valueOf(prdId).substring(0,15),5);
        APTSCU_AssetUtils.renewIndividualAssetLineItem (asset,cartid,allAssetMap,assetQuantityMap);
        Test.stopTest();
    }

    
}