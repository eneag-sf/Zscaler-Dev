/*************************************************************************************************************************
 @Name: APTS_AssetLineItemCompContTest
 @Author: Anay Bhande
 @Created Date: 15/12/2016
 @Descripton: Test Class for APTS_AssetLineItemComponentController
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTS_AssetLineItemCompContTest {
    static{
        Apttus_Config2__PriceList__c Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        Pricebook2 Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
        insert Pricebook;
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
    }
    public static testMethod void testMyController() {
    Test.startTest();
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        Id productId = [Select Id From Product2 Where ProductCode = 'ZSC-SIP1' Limit 1][0].Id;
        Id priceListId = [Select Id From Apttus_Config2__PriceList__c Where Name = 'ZScaler Price List'][0].Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;        
        Id priceListItemId = [Select Id From Apttus_Config2__PriceListItem__c Where Apttus_Config2__PriceListId__c = :priceListId And Apttus_Config2__ProductId__c = :productId And Apttus_Config2__Active__c = true Limit 1][0].Id;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Id accountId = account.Id;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
       
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;
        
        String proposalId = proposal.Id;
        
        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;          
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        
        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();

        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);
        
        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);
        
        Apttus_Config2__AssetLineItem__c assetLineItem=new Apttus_Config2__AssetLineItem__c();
        assetLineItem.Apttus_Config2__ProductId__c=productId;
        assetLineItem.Apttus_Config2__StartDate__c=Date.TODAY();
        assetLineItem.Apttus_Config2__EndDate__c=Date.TODAY()+90;
        assetLineItem.Apttus_Config2__AccountId__c=accountId;
        assetLineItem.Apttus_Config2__AssetStatus__c='Activated';
        insert assetLineItem;
        
    APTS_AssetLineItemComponentController controller=new APTS_AssetLineItemComponentController();
    controller.noOfDays='90';
    controller.accntId=accountId;
    controller.GetlstAssetExpiring();
    assetLineItem.Apttus_Config2__EndDate__c=Date.TODAY()+30;
    update assetLineItem;
    controller.noOfDays='30'; 
    controller.mapAssetExpiring.clear();
    controller.GetlstAssetExpiring();
    assetLineItem.Apttus_Config2__EndDate__c=Date.TODAY()+60;
    update assetLineItem;
    controller.noOfDays='60';
    controller.mapAssetExpiring.clear();
    controller.GetlstAssetExpiring();
    assetLineItem.Apttus_Config2__EndDate__c=Date.TODAY()+7;
    update assetLineItem;
    controller.noOfDays='7';
    controller.mapAssetExpiring.clear();
    controller.GetlstAssetExpiring();
    Test.stopTest();
    }
}