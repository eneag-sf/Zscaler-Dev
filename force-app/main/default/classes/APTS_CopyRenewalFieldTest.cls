/*************************************************************************************************************************
 @Name: APTS_CopyRenewalFieldTest
 @Author: Anay Bhande
 @Created Date: 20/12/2016
 @Descripton: Test Class for Trigger APTS_CopyRenewalField
 @Used By:
*************************************************************************************************************************/
@isTest
public class APTS_CopyRenewalFieldTest {
    static testMethod void testTrigger() {
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        List<product2> testProducts=new List<product2>();
        for(integer i=0;i<10;i++){
            testProducts.add(new Product2(Name='ZSCProd '+i,ProductCode='ZSC-SIP'+i));
        }
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZSC-SIP1');
        insert ZSCProd;
        insert testProducts;
        Id productId = ZSCProd.Id;

        Apttus_Config2__PriceList__c Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        Id priceListId = Pricelist.Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = PriceListItem1.Id;

        Account account = new Account(Name = 'Zscaler');
        insert account;
        Id accountId = account.Id;

        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        Test.startTest();
        String proposalId = proposal.Id;

        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;

        List<Apttus_Config2__ProductConfiguration__c> lisConf=new List<Apttus_Config2__ProductConfiguration__c>();
        for(integer i=0;i<10;i++){
            lisConf.add(new Apttus_Config2__ProductConfiguration__c(Name='Config '+i,Apttus_Config2__AncestorId__c=cartId,Apttus_QPConfig__Proposald__c=proposal.Id));
        }
        insert lisconf;

//        List<Apttus_Config2__LineItem__c> lineItemList2=APTS_TestUtil.createLineItems(cartId, priceListId, testProducts);
        List<Apttus_Config2__LineItem__c> lineItemList= new list<Apttus_Config2__LineItem__c>();
        for(integer j=0;j<4;j++){
        for(integer i=0;i<10;i++){
            Apttus_Config2__LineItem__c tli = new Apttus_Config2__LineItem__c();
            tli.APTS_ACV__c = 400;
            tli.APTS_Renewal_Base__c=i*100+300;
            tli.Apttus_Config2__ConfigurationId__c=lisconf[i].Id;
            tli.Apttus_Config2__ProductId__c = testProducts[i].Id;
            tli.Apttus_Config2__Quantity__c = 10;
            tli.Apttus_Config2__StartDate__c = Date.today();
            tli.Apttus_Config2__EndDate__c = Date.today().addYears(2);
            tli.Apttus_Config2__PrimaryLineNumber__c = j*10+i+1;
            tli.Apttus_Config2__LineNumber__c = j*10+i+1;
            tli.Apttus_Config2__ItemSequence__c = j*10+i+1;
            tli.Apttus_Config2__PriceListId__c = priceListId;
            tli.Apttus_Config2__SellingFrequency__c = 'Yearly';
            if((j&1)==0){
                tli.Apttus_Config2__LineStatus__c='Renewed';
            }
            else{
                tli.Apttus_Config2__LineStatus__c='Existing';
            }
            lineItemList.add(tli);
        }
        }
        insert lineItemList;
        List<Apttus_Proposal__Proposal_Line_Item__c> Prop=new List<Apttus_Proposal__Proposal_Line_Item__c>();

        lineItemList[3].Apttus_Config2__DerivedFromId__c=lineItemList[2].Id;
        for(integer j=0;j<4;j++){
        for(integer i=0;i<10;i++){
        Prop.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposalId,
                                                            APTS_MRR__c = 5,
                                                            Apttus_Proposal__Product__c = testProducts[i].Id,
                                                            Apttus_QPConfig__NetPrice__c = 200,
                                                            Apttus_QPConfig__DerivedFromId__c=lineItemList[j*10+i].Id));
        }
        }
        insert prop;
        update prop;

        Test.stopTest();
    }
}