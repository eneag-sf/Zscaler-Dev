@isTest
public class Confirm_Reprice_controller_Test{
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
        
        List<Apttus_Proposal__Proposal__c> listProp=new List<Apttus_Proposal__Proposal__c>();
        listProp.add(testProposal1);
        insert listprop;


    }
    
    static testmethod void test1(){
        List<Apttus_Proposal__Proposal__c> listProp = [Select Id from Apttus_Proposal__Proposal__c limit 1];
        Test.setCurrentPage(Page.Confirm_Reprice);
        ApexPages.currentPage().getParameters().put('backtoVF', 'true');
        ApexPages.currentPage().getParameters().put('retURL', '/apex/RepriceApttusProposals?proposalIds=' + listProp[0].Id);
        ApexPages.currentPage().getParameters().put('confirmrepricequoteid', listProp[0].Id);
        Confirm_Reprice_controller ctrl = new Confirm_Reprice_controller();
        ctrl.onCancel();
        ctrl.init();
        ctrl.onConfirm();
        test.starttest();
        ctrl.partnerprogSwitch();
        ctrl.onSwitchPL();
        ctrl.taketoCart();
        system.debug(ctrl.isReprice);
        system.debug(ctrl.isSwitchPL);
        system.debug(ctrl.isOldDas);
        system.debug(ctrl.isPartnerProgramMismatch);
        test.stoptest();
    }   
    
}