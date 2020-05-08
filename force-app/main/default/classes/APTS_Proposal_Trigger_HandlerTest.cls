/*************************************************************************************************************************
 @Name: APTS_Proposal_Trigger_HandlerTest
 @Author: Pranjal Mittal
 @Created Date: 2/12/2016
 @Descripton: Test Class for APTS_Proposal_Trigger_Handler
 @Used By:
*************************************************************************************************************************/

@isTest
public class APTS_Proposal_Trigger_HandlerTest {
    @testSetup
    static void testData(){
        TriggerUtility.prospectTypeUpdExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        //User
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userMgr = new User(LastName = 'Lastname1',
                           FirstName='Firstname1',
                           Alias = 'testf',
                           Email = 'dummy1@dummy.com1',
                           Username = 'test11@asdf1234.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert userMgr;
        User userTest = new User(LastName = 'Lastname1',
                           FirstName='Firstname1',
                           Alias = 'testa',
                           Email = 'dummy@dummy.com1',
                           Username = 'test1@asdf1234.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           ManagerID = userMgr.Id,
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert userTest;

        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        //Account
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;

        Account acc1 = APTS_TestUtil.creatAccount();


        //Opportunity
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        testOppty.OwnerId = userTest.Id;
        testOppty.PriceBook2Id = Test.getStandardPricebookId();
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        insert testOppty;

        //Opportunity Partner
        Partner testOpptyPartner = new Partner();
        testOpptyPartner.AccountToId = acc1.Id;
        testOpptyPartner.IsPrimary = true;
        testOpptyPartner.OpportunityId = testOppty.Id;
        insert testOpptyPartner;

        //Price List
        Apttus_Config2__PriceList__c testPriceList = new Apttus_Config2__PriceList__c(Name = 'US Price List',
                                                                                    Apttus_Config2__AccountId__c = acctTest.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041992',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList;

        //Products
        Product2 testProduct1 = new Product2(Name = 'Test Support Product');
        testProduct1.Product_Line__c = 'Support';
        testProduct1.ProductCode = 'ABCD';
        testProduct1.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct1.IsActive = true;
        Product2 testProduct2 = new Product2(Name = 'Test Support Product');
        testProduct2.Product_Line__c = 'Support';
        testProduct2.ProductCode = 'ZCR-BuyBack';
        testProduct2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct2.IsActive = true;
        // Product2 testProduct3 = new Product2(Name = 'Test Support Product');
        // testProduct3.Product_Line__c = 'Support';
        // testProduct3.ProductCode = 'ZCR-UPY4';
        // testProduct3.Apttus_Config2__ConfigurationType__c = 'Standalone';
        // testProduct3.IsActive = true;
        // Product2 testProduct4 = new Product2(Name = 'Test Support Product');
        // testProduct4.Product_Line__c = 'Support';
        // testProduct4.ProductCode = 'ZCR-UPY5';
        // testProduct4.Apttus_Config2__ConfigurationType__c = 'Standalone';
        // testProduct4.IsActive = true;
        List<Product2> listProduct=new List<Product2>();
        listProduct.add(testProduct1);
        listProduct.add(testProduct2);
        // listProduct.add(testProduct3);
        // listProduct.add(testProduct4);
        insert listProduct;

        //Price List Item
        Apttus_Config2__PriceListItem__c testPli = new Apttus_Config2__PriceListItem__c();
        testPli.Apttus_Config2__Active__c = true;
        testPli.Apttus_Config2__PriceType__c = 'One Time';
        testPli.Apttus_Config2__Frequency__c = 'Yearly';
        testPli.Apttus_Config2__ChargeType__c = 'Subscription Fee';
        testPli.Apttus_Config2__ListPrice__c = 50.00;
        testPli.Apttus_Config2__PriceListId__c = testPriceList.ID;
        testPli.Apttus_Config2__PriceMethod__c = 'Per Unit';
        testPli.Apttus_Config2__PriceUom__c = 'Each';
        testPli.Apttus_Config2__ProductId__c = testProduct1.ID;
        testPli.Apttus_Config2__RelatedAdjustmentType__c='Percentage';
        testPli.Apttus_Config2__RelatedAdjustmentAmount__c=10.0;
        testPli.Apttus_Config2__RelatedAdjustmentAppliesTo__c='Base Price';
        testPli.Apttus_Config2__DefaultQuantity__c=1;
        insert testPli;

        //Proposal
        Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1',
                                                                                      Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),
                                                                                      RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),
                                                                                      Apttus_Proposal__Approval_Stage__c = 'Draft',
                                                                                      Apttus_QPConfig__BillToAccountId__c = acctTest.Id,
                                                                                      Apttus_Proposal__ExpectedStartDate__c = Date.today(),
                                                                                      Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(365),
                                                                                      Apttus_Proposal__Primary__c = true,
                                                                                      Apttus_QPConfig__PriceListId__c = testPriceList.Id,
                                                                                      Apttus_Proposal__Valid_Until_Date__c = Date.today()
                                                                                      );
        testProposal1.Apttus_Proposal__Opportunity__c = testOppty.Id;
        testProposal1.Apttus_QPConfig__BillToAccountId__c = acctTest.Id;
        testProposal1.Apttus_Proposal__Account__c = acctTest.Id;
        testProposal1.Apttus_QPConfig__ShipToAccountId__c = acctTest.Id;
        // Apttus_Proposal__Proposal__c testProposal2 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 2',
        //                                                                               Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),
        //                                                                               RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),
        //                                                                               Apttus_Proposal__Approval_Stage__c = 'Draft',
        //                                                                               Apttus_QPConfig__BillToAccountId__c = acctTest.Id,
        //                                                                               Apttus_Proposal__ExpectedStartDate__c = Date.today(),
        //                                                                               Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(365),
        //                                                                               Apttus_Proposal__Primary__c = true,
        //                                                                               Apttus_QPConfig__PriceListId__c = testPriceList.Id,
        //                                                                               Apttus_Proposal__Valid_Until_Date__c = Date.today()
        //                                                                               );
        // testProposal2.Apttus_Proposal__Opportunity__c = testOppty.Id;
        // testProposal2.Apttus_QPConfig__BillToAccountId__c = acctTest.Id;
        // testProposal2.Apttus_Proposal__Account__c = acctTest.Id;
        // testProposal2.Apttus_QPConfig__ShipToAccountId__c = acctTest.Id;
        List<Apttus_Proposal__Proposal__c> listProp=new List<Apttus_Proposal__Proposal__c>();
        listProp.add(testProposal1);
        // listProp.add(testProposal2);
        insert listprop;
        //Proposal Line Items
        // Apttus_Proposal__Proposal_Line_Item__c testProposalLineItem1 = new Apttus_Proposal__Proposal_Line_Item__c(APTS_Product_Code__c = 'Z-LOGFEED',
        //                                                                                                          APTS_Total_Ramp_Quantity__c = 100,
        //                                                                                                          APTS_Ramp_End_Date__c = Date.today());
        // testProposalLineItem1.Apttus_Proposal__Proposal__c = testProposal1.Id;
        // insert testProposalLineItem1;
        //
        // Apttus_Proposal__Proposal_Line_Item__c testProposalLineItem2 = new Apttus_Proposal__Proposal_Line_Item__c(APTS_Product_Code__c = 'ZSC-SIP',
        //                                                                                                          APTS_Total_Ramp_Quantity__c = 100,
        //                                                                                                          APTS_Ramp_End_Date__c = Date.today());
        // testProposalLineItem2.Apttus_Proposal__Proposal__c = testProposal1.Id;
        // insert testProposalLineItem2;

        //Product Configurations
        Apttus_Config2__ProductConfiguration__c config1 = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c = 'Finalized');
        config1.Apttus_QPConfig__Proposald__c = testProposal1.Id;
        // Apttus_Config2__ProductConfiguration__c config2 = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c = 'Finalized');
        // config2.Apttus_QPConfig__Proposald__c = testProposal2.Id;
        List<Apttus_Config2__ProductConfiguration__c> listConfig=new List<Apttus_Config2__ProductConfiguration__c>();
        listConfig.add(config1);
        // listConfig.add(config2);
        insert listConfig;

        List<Apttus_Config2__LineItem__c> conline= APTS_TestUtil.createLineItems(config1.Id, testPriceList.Id,listProduct);


        //Year Wise Split
        APTS_Year_Wise_Split__c testSplit = new APTS_Year_Wise_Split__c();
        testSplit.APTS_Proposal__c = testProposal1.Id;
        insert testSplit;

    }

    static testMethod void testUpdateProposal1(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        Account acct = new Account(Name = 'Test Account 2', APTS_Platform_Subscription_End_Date__c = Date.today());
        acct.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acct;
        
        
        List<Apttus_Proposal__Proposal__c> listOfProposals = [SELECT Id, Name, Apttus_QPConfig__ConfigurationFinalizedDate__c,
                                                                Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c
                                                                where Apttus_QPConfig__PONumber__c = 'Test Proposal 1' LIMIT 1];

        listOfProposals[0].Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today().addDays(1);
        listOfProposals[0].Apttus_Proposal__Approval_Stage__c = label.Apttus_Config2.Accepted;
        listOfProposals[0].Apttus_QPConfig__BillToAccountId__c = acct.Id;

        update listOfProposals;

        APTS_Proposal_Trigger_Handler obj = new APTS_Proposal_Trigger_Handler();
        obj.calculateTotalofProposal(listOfProposals);
        Test.stopTest();

    }
    /*
    static testMethod void testUpdateProposal2(){
        //Test.startTest();

        Account acc1 = APTS_TestUtil.creatAccount();

        Account acct = new Account(Name = 'Test Account 2', APTS_Platform_Subscription_End_Date__c = Date.today());
        acct.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acct;

        //Opportunity
        Opportunity testOppty2 = new Opportunity(Name = 'Test Opportunity', StageName = '13 - Closed & Approved By Finance', CloseDate = Date.today());
        testOppty2.AccountID = acct.Id;
        //testOppty.OwnerId = userTest.Id;
        testOppty2.PriceBook2Id = Test.getStandardPricebookId();
        insert testOppty2;

        //Price List
        Apttus_Config2__PriceList__c testPriceList1 = new Apttus_Config2__PriceList__c(Name = 'US Price List1',
                                                                                    Apttus_Config2__AccountId__c = acct.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041991',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList1;

         Test.startTest();
        Apttus_Proposal__Proposal__c testProposal1 = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1',
                                                                                      Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today(),
                                                                                      RecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Upsell').getRecordTypeId(),
                                                                                      Apttus_Proposal__Approval_Stage__c = 'Draft',
                                                                                      Apttus_QPConfig__BillToAccountId__c = acct.Id,
                                                                                      Apttus_Proposal__ExpectedStartDate__c = Date.today(),
                                                                                      Apttus_Proposal__ExpectedEndDate__c = Date.today().addDays(365),
                                                                                      Apttus_Proposal__Primary__c = true,
                                                                                      Apttus_QPConfig__PriceListId__c = testPriceList1.Id,
                                                                                      Apttus_Proposal__Valid_Until_Date__c = Date.today()
                                                                                      );
        testProposal1.Apttus_Proposal__Opportunity__c = testOppty2.Id;
        testProposal1.Apttus_QPConfig__BillToAccountId__c = acct.Id;
        testProposal1.Apttus_Proposal__Account__c = acct.Id;
        testProposal1.Apttus_QPConfig__ShipToAccountId__c = acct.Id;
        insert testProposal1;

        Apttus_Config2__ProductConfiguration__c config1 = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c = 'Finalized');
        config1.Apttus_QPConfig__Proposald__c = testProposal1.Id;
        Apttus_Config2__ProductConfiguration__c config2 = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c = 'Saved');
        config2.Apttus_QPConfig__Proposald__c = testProposal1.Id;
        List<Apttus_Config2__ProductConfiguration__c> liscon=new List<Apttus_Config2__ProductConfiguration__c>();
        liscon.add(config1);
        liscon.add(config2);
        insert liscon;

        Product2 tp = new Product2();
        tp.Name = 'test product 1';
        tp.Apttus_Config2__ConfigurationType__c = 'Standalone';
        tp.ProductCode = 'ZSEC-SKU1';
        tp.Family = 'Zscaler Products';
        tp.Product_Line__c = 'Support';
        tp.IsActive = true;
        Product2 tp2 = new Product2();
        tp2.Name = 'test product 2';
        tp2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        tp2.ProductCode = 'ZCR-UPY4';
        tp2.Family = 'Zscaler Products';
        tp2.Product_Line__c = 'Usage';
        tp2.IsActive = true;
        List<Product2> lstProd = new List<Product2>();
        lstProd.add(tp);
        lstProd.add(tp2);
        insert lstProd;


        List<Apttus_Config2__LineItem__c> lisline=new List<Apttus_Config2__LineItem__c>();
        List<String> PriceType=new List<String>();
        PriceType.add('One Time');
        PriceType.add('Usage');
        for(Product2 proda:lstProd){
            for(Apttus_Config2__ProductConfiguration__c conf:liscon){
                for(String price:PriceType){
                    Apttus_Config2__LineItem__c testLineItem3 = new Apttus_Config2__LineItem__c();
                    testLineItem3.Apttus_Config2__PriceType__c = price;
                    testLineItem3.Apttus_Config2__ChargeType__c = 'Subscription Fee';
                    testLineItem3.Apttus_Config2__IsPrimaryLine__c = false;
                    testLineItem3.Apttus_Config2__IsPrimaryRampLine__c = false;
                    testLineItem3.Apttus_Config2__LineStatus__c = 'NewInstance';
                    testLineItem3.Apttus_Config2__LineType__c = 'Product/Service';
                    testLineItem3.Apttus_Config2__SellingTerm__c = 1;
                    testLineItem3.Apttus_Config2__PriceListId__c = testPriceList1.Id;
                    testLineItem3.Apttus_Config2__PriceMethod__c = 'Per Unit';
                    testLineItem3.Apttus_Config2__SellingFrequency__c = 'Yearly';
                    testLineItem3.Apttus_Config2__PricingStatus__c = 'Pending';
                    testLineItem3.Apttus_Config2__ListPrice__c = 50.00;
                    testLineItem3.Apttus_Config2__BasePrice__c = 10.00;
                    testLineItem3.Apttus_Config2__ExtendedPrice__c = 20.00;
                    testLineItem3.Apttus_Config2__NetPrice__c = 50.00;
                    testLineItem3.Apttus_Config2__Quantity__c=2;
                    testLineItem3.Apttus_Config2__ConfigurationId__c = conf.id;
                    testLineItem3.Apttus_Config2__ProductId__c = proda.Id;
                    testLineItem3.Apttus_Config2__StartDate__c = Date.today();
                    testLineItem3.Apttus_Config2__EndDate__c = Date.today().addYears(2);
                    testLineItem3.Apttus_Config2__PrimaryLineNumber__c = 12;
                    testLineItem3.Apttus_Config2__LineNumber__c = 12;
                    testLineItem3.Apttus_Config2__ItemSequence__c = 1;
                    lisline.add(testLineItem3);
                }
            }
        }
        insert lisline;

        testProposal1.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today().addDays(1);
        testProposal1.Apttus_Proposal__Approval_Stage__c = label.Apttus_Config2.Accepted;
        testProposal1.Apttus_QPConfig__BillToAccountId__c = acct.Id;

        update testProposal1;
        List<Apttus_Proposal__Proposal_Line_Item__c> lisprol=new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Apttus_Config2__LineItem__c litem:lisline){
        lisprol.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = testProposal1.Id,
                                                            APTS_MRR__c = 5, APTS_ACV__c = 200,
                                                            Apttus_QPConfig__OptionId__c=lstProd[1].Id,
                                                            APTS_Renewal_Base__c=210,
                                                            Apttus_Proposal__Product__c = lstProd[0].Id,
                                                            Apttus_QPConfig__NetPrice__c = 200,
                                                            Apttus_QPConfig__DerivedFromId__c=lisline[0].Id));
        }
        insert lisprol;
        List<Opportunity> lisop=new List<Opportunity>();
        lisop.add(testOppty2);
        Test.stopTest();
        new APTS_Proposal_Trigger_Handler().getPricebookentry(lisprol,lisop);

    }
*/

    //* Edited by Anay Bhande
    static testMethod void ThrowErrorForQuoteOnLockedOpty(){
        Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        List<Apttus_Proposal__Proposal__c> listOfProposals = [SELECT Id, Name, Apttus_QPConfig__ConfigurationFinalizedDate__c,
                                                                Apttus_Proposal__Approval_Stage__c,Apttus_Proposal__ExpectedStartDate__c,
                                                              Apttus_Proposal__ExpectedEndDate__c from Apttus_Proposal__Proposal__c
                                                                where Apttus_QPConfig__PONumber__c = 'Test Proposal 1' LIMIT 1];
        APTS_Proposal_Trigger_Handler obj = new APTS_Proposal_Trigger_Handler();
        obj.ThrowErrorForQuoteOnLockedOpty(listOfProposals);
        /*listOfProposals[0].Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today().addDays(1);
        listOfProposals[0].Apttus_Proposal__Approval_Stage__c = label.Apttus_Config2.Accepted;
        update listOfProposals;*/
        Test.stopTest();
    }
}