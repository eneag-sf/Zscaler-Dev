@isTest
public class ProposalWizardControllerTest {
    
    static testMethod void ProposalWizardTest(){
        
        //Account
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;
        
        //Opportunity
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        testOppty.PriceBook2Id = Test.getStandardPricebookId();
        insert testOppty;
        
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
        testProduct1.ProductCode = 'ZIA-PRO-BUNDLE';
        testProduct1.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct1.IsActive = true;
        Product2 testProduct2 = new Product2(Name = 'Test Support Product');
        testProduct2.Product_Line__c = 'Support';
        testProduct2.ProductCode = 'ZIA-BUS-BUNDLE';
        testProduct2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct2.IsActive = true;
        Product2 testProduct3 = new Product2(Name = 'Test Support Product');
        testProduct3.Product_Line__c = 'Support';
        testProduct3.ProductCode = 'ZIA-TRANS-BUNDLE';
        testProduct3.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct3.IsActive = true;
        Product2 testProduct4 = new Product2(Name = 'Test Support Product');
        testProduct4.Product_Line__c = 'Support';
        testProduct4.ProductCode = 'ZPA-PRO';
        testProduct4.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct4.IsActive = true;
        Product2 testProduct5 = new Product2(Name = 'Test Support Product');
        testProduct5.Product_Line__c = 'Support';
        testProduct5.ProductCode = 'ZPA-BUS';
        testProduct5.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct5.IsActive = true;
        Product2 testProduct6 = new Product2(Name = 'Test Support Product');
        testProduct6.Product_Line__c = 'Support';
        testProduct6.ProductCode = 'ZPA-ENT';
        testProduct6.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct6.IsActive = true;
        List<Product2> listProduct=new List<Product2>();
        listProduct.add(testProduct1);
        listProduct.add(testProduct2);
        listProduct.add(testProduct3);
        listProduct.add(testProduct4);
        listProduct.add(testProduct5);
        listProduct.add(testProduct6);
        insert listProduct;
        
        List<Apttus_Config2__PriceListItem__c> listPriceListItem = new List<Apttus_Config2__PriceListItem__c>();
        for(Integer i=0; i<listProduct.size(); i++){
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
            testPli.Apttus_Config2__ProductId__c = listProduct[i].ID;
            testPli.Apttus_Config2__RelatedAdjustmentType__c='Percentage';
            testPli.Apttus_Config2__RelatedAdjustmentAmount__c=10.0;
            testPli.Apttus_Config2__RelatedAdjustmentAppliesTo__c='Base Price';
            testPli.Apttus_Config2__DefaultQuantity__c=1;
            listPriceListItem.add(testPli);
        }
        insert listPriceListItem;
        
        List<Apttus_Config2__PriceMatrix__c> pmList = new List<Apttus_Config2__PriceMatrix__c>();
        for(integer i=0; i<listPriceListItem.size(); i++){
            Apttus_Config2__PriceMatrix__c priceMatrix = new Apttus_Config2__PriceMatrix__c();
            priceMatrix.Apttus_Config2__Sequence__c = 1;
            priceMatrix.Apttus_Config2__InitialRows__c = 5;
            priceMatrix.Apttus_Config2__MatrixType__c = 'Dimension';
            priceMatrix.Apttus_Config2__PriceListItemId__c = listPriceListItem[i].id;
            pmList.add(priceMatrix);
        }
        insert pmList;
        
        List<Apttus_Config2__PriceMatrixEntry__c> pmEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        for(Apttus_Config2__PriceMatrix__c pmRec : pmList){
            Apttus_Config2__PriceMatrixEntry__c pmEntryRec = new Apttus_Config2__PriceMatrixEntry__c();
            pmEntryRec.Apttus_Config2__PriceMatrixId__c = pmRec.Id;
            pmEntryRec.Apttus_Config2__Sequence__c = 1;
            pmEntryRec.Apttus_Config2__PriceOverride__c = 35000;
            pmEntryRec.Apttus_Config2__AdjustmentAmount__c = 35000;
            pmEntryRec.Apttus_Config2__AdjustmentType__c = 'List Price Override';
            pmEntryRec.Apttus_Config2__Dimension1Value__c = '350000';
            pmEntryList.add(pmEntryRec);
        }
        insert pmEntryList;
        
        
        //Proposal
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1', 
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
        testProposal.Apttus_Proposal__Opportunity__c = testOppty.Id;
        testProposal.Apttus_QPConfig__BillToAccountId__c = acctTest.Id;
        testProposal.Apttus_Proposal__Account__c = acctTest.Id;
        testProposal.Apttus_QPConfig__ShipToAccountId__c = acctTest.Id;
        insert testProposal;
        
        
        Apttus_Config2__ProductConfiguration__c config = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c = 'Finalized');
        config.Apttus_QPConfig__Proposald__c = testProposal.Id;
        insert Config;
        List<Apttus_Config2__LineItem__c> conline= APTS_TestUtil.createLineItems(Config.Id, testPriceList.Id, listProduct);
        
        test.startTest();
        
        PageReference myVfPage = Page.ProposalWizardOne;
        Test.setCurrentPageReference(myVfPage);
   
        ApexPages.currentPage().getParameters().put('id',testProposal.Id);
        String id = ApexPages.currentPage().getParameters().get('id');
        system.assertEquals(true, id!=null);
   
        ApexPages.StandardController sc = new ApexPages.StandardController(testProposal);
        ProposalWizardController pwc = new ProposalWizardController(sc);
        
        pwc.goToNextWizard();
        pwc.goToPreviousWizard();
        pwc.generateDocument();
        pwc.updateWizardTwoElements();
        pwc.togglenote();
        pwc.cancel();
        
        test.stopTest();
    }
    
    
    static testMethod void ProposalWizardGenerateDocTest(){
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = 'New Zscaler Executive Document';
        template.Apttus__IsActive__c = true;
        insert template;
        
        Apttus_Config2__ConfigSystemProperties__c setting = new Apttus_Config2__ConfigSystemProperties__c();
        setting.Name = 'System Properties';
        setting.Apttus_Config2__InstanceUrl__c = 'Whatever';
        insert setting;
        
        //Account
        Account acctTest = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        acctTest.APTS_Asset_SKU__c = 'ZSC-SIP, ZSUITE-WEBBUS, ZCES-SUP-PREM';
        insert acctTest;
        
        //Opportunity
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity', StageName = label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/, CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
        testOppty.PriceBook2Id = Test.getStandardPricebookId();
        insert testOppty;
        
        //Price List
        Apttus_Config2__PriceList__c testPriceList = new Apttus_Config2__PriceList__c(Name = 'US Price List',
                                                                                    Apttus_Config2__AccountId__c = acctTest.Id,
                                                                                    Apttus_Config2__Active__c = true,
                                                                                    APTS_Ext_ID__c = '03041992',
                                                                                    Apttus_Config2__Type__c = 'Standard');
        insert testPriceList;
        
        //Proposal
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__PONumber__c = 'Test Proposal 1', 
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
        testProposal.Apttus_Proposal__Opportunity__c = testOppty.Id;
        testProposal.Apttus_QPConfig__BillToAccountId__c = acctTest.Id;
        testProposal.Apttus_Proposal__Account__c = acctTest.Id;
        testProposal.Apttus_QPConfig__ShipToAccountId__c = acctTest.Id;
        insert testProposal;
        
        test.startTest();
        
        PageReference myVfPage = Page.ProposalWizardOne;
        Test.setCurrentPageReference(myVfPage);
   
        ApexPages.currentPage().getParameters().put('id',testProposal.Id);
        String id = ApexPages.currentPage().getParameters().get('id');
        system.assertEquals(true, id!=null);
   
        ApexPages.StandardController sc = new ApexPages.StandardController(testProposal);
        ProposalWizardController pwc = new ProposalWizardController(sc);
        
        try{
            pwc.generateFinalDocument();
        }
        catch(Exception exp){
            
        }
        test.stopTest();
    }
}