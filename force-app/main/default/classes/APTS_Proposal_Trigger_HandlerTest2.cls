@isTest
public class APTS_Proposal_Trigger_HandlerTest2 {

    static testMethod void testUpdateProposal2(){
        //Test.startTest();
        TriggerUtility.prospectTypeUpdExecuted();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;

        Account acc1 = APTS_TestUtil.creatAccount();
        TriggerUtility.prospectTypeUpdExecuted();
        Account acct = new Account(Name = 'Test Account 2', APTS_Platform_Subscription_End_Date__c = Date.today());
        acct.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acct;

        //Opportunity
        Opportunity testOppty2 = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won/*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
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
                                                                                      Apttus_Proposal__ExpectedStartDate__c = Date.today().addDays(-180),
                                                                                      Apttus_Proposal__ExpectedEndDate__c = Date.today(),
                                                                                      Apttus_Proposal__Primary__c = true,
                                                                                      Apttus_QPConfig__PriceListId__c = testPriceList1.Id,
                                                                                      Apttus_Proposal__Valid_Until_Date__c = Date.today()
                                                                                      );
        testProposal1.Apttus_Proposal__Opportunity__c = testOppty2.Id;
        testProposal1.Apttus_QPConfig__BillToAccountId__c = acct.Id;
        testProposal1.Apttus_Proposal__Account__c = acct.Id;
        testProposal1.Apttus_QPConfig__ShipToAccountId__c = acct.Id;
        System.debug('>>>> testProposal1: ' + JSON.serialize(testProposal1));
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

 }