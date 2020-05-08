/*************************************************************************************************************************
 @Name: APTSCU_CreateOpportunitySplitTest
 @Author: Anay Bhande
 @Created Date: 22/12/2016
 @Descripton: Test Class for trigger APTSCU_CreateOpportunitySplit 
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTSCU_CreateOpportunitySplitTest {
    @isTest
    static void testTrigger(){
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        Test.startTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User userTest = new User(LastName = 'Lastname1',
                           FirstName='Firstname1',
                           Alias = 'testa',
                           Email = 'dummy@dummy.com1',
                           Username = 'test1@maari2.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                           isActive=True
                           );
        
        insert userTest;

        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.Account_Manager__c=userTest.Id;
        Account acc2=new Account ();
        acc2.Name = 'Test Account 2';
        acc2.Account_Manager__c=userTest.Id;
        List<Account> lisacc=new List<Account>();
        lisacc.add(acc);
        lisacc.add(acc2);
        insert lisacc;
        Pricebook2 Pricebook=new Pricebook2(Name = 'Apttus Default Price Book');
        insert Pricebook;
        
        Apttus_Config2__PriceList__c pricelist=APTS_TestUtil.createpricelist();
        Id productid=APTS_TestUtil.createProduct();
        Id productid2=APTS_TestUtil.createProduct();
        //Admin Entries
        List<Apttus__APTS_Admin__c> adminlist=new List<Apttus__APTS_Admin__c>();
        adminlist.add(new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book'));
        adminlist.add(new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List'));
        insert adminlist;
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = Label.Stage_1_Alignment /*'0 - Initial Prospecting'*/;
        opp.closedate =  Date.today();
        opp.Start_Date__c  =  Date.today();
        opp.accountId = acc.Id;
        opp.Price_List__c = pricelist.Id;
        opp.type ='Existing Customer (Renewal)';
        Opportunity opp2 = new Opportunity ();
        opp2.Name = 'test opportunity';
        opp2.StageName = Label.Stage_1_Alignment /*'0 - Initial Prospecting'*/;
        opp2.closedate =  Date.today();
        opp2.Start_Date__c  =  Date.today();
        opp2.accountId = acc2.Id;
        opp2.Price_List__c = pricelist.Id;
        opp2.type ='Existing Customer (Renewal)';
//        opp.Pricebook2ID=Pricebook.Id;
//        opp2.Pricebook2ID=Pricebook.Id;
        opp.Pricebook2ID=Test.getStandardPricebookId();
        opp2.Pricebook2ID=Test.getStandardPricebookId();
        List<Opportunity> lisopp=new List<Opportunity>();
        lisopp.add(opp);
        lisopp.add(opp2);
        insert lisopp;

        Apttus_Proposal__Proposal__c proposal=APTS_TestUtil.createproposal(opp.Id, acc.Id, pricelist.Id, TRUE);
        Apttus_Proposal__Proposal_Line_Item__c ProLine=APTS_TestUtil.createProposalLineItem(proposal.Id, productId);
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;          
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId = result.CartId;
        Apttus_Config2__ProductConfiguration__c config=[Select Id, Apttus_Config2__Status__c from Apttus_Config2__ProductConfiguration__c where Id=:result.CartId];
        proposal.Apttus_Proposal__Primary__c=TRUE; 
        config.Apttus_Config2__Status__c='Finalized';
        update config;
        update proposal;
        
        lisopp = [select id, Pricebook2Id from Opportunity where id = :opp.Id or id = :opp2.Id];
        List<PricebookEntry> lipri1=new List<PricebookEntry>();
        try{
        Id pricebookId = Test.getStandardPricebookId();

        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId,
                                                Product2Id=productid,UnitPrice=100.0));
        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId, 
                                                Product2Id=productid2,UnitPrice=100.0));
        insert lipri1;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        PricebookEntry entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=lisopp[0].Pricebook2Id,
                                                Product2Id=productid,UnitPrice=100.0);
        PricebookEntry entry2=new PricebookEntry(IsActive=TRUE,Pricebook2Id=lisopp[1].Pricebook2Id, 
                                                Product2Id=productid2,UnitPrice=100.0);
        List<PricebookEntry> lipri=new List<PricebookEntry>();
        lipri.add(entry);
        lipri.add(entry2);
        try{
            insert lipri;
            OpportunityLineItem oppol=new OpportunityLineItem(OpportunityId=lisopp[0].Id, PricebookEntryId=entry.Id);
            OpportunityLineItem oppol2=new OpportunityLineItem(OpportunityId=lisopp[1].Id, PricebookEntryId=entry2.Id);
            List<OpportunityLineItem> lioppl=new List<OpportunityLineItem>();
            lioppl.add(oppol);
            lioppl.add(oppol2);
            system.debug('OpportunityLineItem:'+ lioppl);
            system.debug('Opportunity'+ lisopp);
            //lisopp = [select id,Pricebook2Id from Opportunity where id = :opp.Id or id = :opp2.Id];
            //system.debug('Opportunity after Query'+ lisopp);
            system.debug('PricebookEntry'+ lipri);
            system.debug('PricebookEntry'+ lipri1);
            insert lioppl;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        Test.stopTest();
    }
}