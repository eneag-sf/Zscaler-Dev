/*************************************************************************************************************************
 @Name: APTS_TestUtil_Test
 @Author: Anay Bhande
 @Created Date: 20/12/2016
 @Descripton: Test Class for APTS_TestUtil
 @Used By:
*************************************************************************************************************************/
@isTest
public class APTS_TestUtil_Test {
    static testMethod void testUtility() {
        Account acc=APTS_TestUtil.creatAccount();
        Apttus_Config2__PriceList__c pricelist=APTS_TestUtil.createpricelist();
        Id productid=APTS_TestUtil.createProduct();
        List<product2> testProducts=APTS_TestUtil.createProducts(10);
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Opportunity opp=APTS_TestUtil.createOpportunity(acc.Id, pricelist.Id);
//        Opportunity opp = new Opportunity(Name = 'Test Opportunity', accountId = acc.Id, CloseDate = Date.today() + 30,
  //                                        StageName = '1 - Qualified and Budgeted', Type = 'New Business',
    //                                      Price_List__c = pricelist.Id, Pricebook2Id=Test.getStandardPricebookId());
        //insert opp;
        Apttus_Proposal__Proposal__c proposal=APTS_TestUtil.createproposal(opp.Id, acc.Id, pricelist.Id, TRUE);
        List<Apttus_Proposal__Proposal_Line_Item__c> ProposalLineItem =APTS_TestUtil.createProposalLineItems(proposal, testProducts);
        ProposalLineItem[0].APTS_ACV__c=100;
        update ProposalLineItem;
        Test.startTest();
        List<Apttus_Config2__AssetLineItem__c> assetlist=APTS_TestUtil.createassetlineItems(proposal, ProposalLineItem);
        Apttus_Config2__AssetLineItem__c assetlineitem=APTS_TestUtil.createassetlineItems(proposal.Id, acc.id, productid, proposallineitem[0].id);
        Apttus_Proposal__Proposal_Line_Item__c ProLine=APTS_TestUtil.createProposalLineItem(proposal.Id, productId);
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        List<Apttus_Config2__LineItem__c> conline= APTS_TestUtil.createLineItems(cartId, pricelist.Id,testProducts);
        Set<String> strset=new Set<String>();
        APTS_UtilityFns.flattenSet(strset,',');
        APTS_UtilityFns.splitString_toset('',',');
        strset.add('String1');
        strset.add('String2');
        String str=APTS_UtilityFns.flattenSet(strset,',');
        APTS_UtilityFns.splitString_toset(str,',');
        Test.stopTest();
    }
}