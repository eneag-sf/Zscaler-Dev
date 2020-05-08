@istest
public class DASNotification_OpptySnapshotBatch_Test{
    @isTest static void test(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        opportunity testOppty = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acctTest.Id, StageName = label.Stage_5_Contracts_Complete/*'10b - PO recd, pending finance approval'*/, CloseDate = system.Today()+30);
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
        testProduct1.Zscaler_Product_Family__c = 'ZIA';
        
        Product2 testProduct2 = new Product2(Name = 'Test Support Product');
        testProduct2.Product_Line__c = 'Support';
        testProduct2.ProductCode = 'ZIA-BUS-BUNDLE';
        testProduct2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct2.IsActive = true;
        testProduct2.Zscaler_Product_Family__c = 'ZIA';
        
        Product2 testProduct3 = new Product2(Name = 'Test Support Product');
        testProduct3.Product_Line__c = 'Support';
        testProduct3.ProductCode = 'ZIA-TRANS-BUNDLE';
        testProduct3.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct3.IsActive = true;
        testProduct3.Zscaler_Product_Family__c = 'ZPA';
        
        Product2 testProduct4 = new Product2(Name = 'Test Support Product');
        testProduct4.Product_Line__c = 'Support';
        testProduct4.ProductCode = 'ZPA-PRO';
        testProduct4.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct4.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'ZPA';
        
        Product2 testProduct5 = new Product2(Name = 'Test Support Product');
        testProduct5.Product_Line__c = 'Support';
        testProduct5.ProductCode = 'ZPA-BUS';
        testProduct5.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct5.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Support';
        
        Product2 testProduct6 = new Product2(Name = 'Test Support Product');
        testProduct6.Product_Line__c = 'Support';
        testProduct6.ProductCode = 'ZPA-ENT';
        testProduct6.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct6.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Deployment';
        
        List<Product2> listProduct=new List<Product2>();
        listProduct.add(testProduct1);
        listProduct.add(testProduct2);
        listProduct.add(testProduct3);
        listProduct.add(testProduct4);
        listProduct.add(testProduct5);
        listProduct.add(testProduct6);
        insert listProduct;
        
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
        testProposal.Included_DAS_Package__c = 'DAS0';
        insert testProposal;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemLst = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Integer i=0; i<listProduct.size(); i++){
            //Price List Item
            Apttus_Proposal__Proposal_Line_Item__c proposalLine = new Apttus_Proposal__Proposal_Line_Item__c();
            proposalLine.Apttus_Proposal__Proposal__c = testProposal.Id;
            proposalLine.Apttus_QPConfig__ExtendedPrice__c = 100;
            proposalLine.APTS_ACV__c = 30000;
            proposalLine.Apttus_Proposal__Product__c = listProduct[i].ID;
            proposalLineItemLst.add(proposalLine);
        }
        insert proposalLineItemLst;
        
        DASNotification_OpptySnapshotBatch batch;
        Date sd = Date.Today();
        Date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new DASNotification_OpptySnapshotBatch(startdate,enddate);
        Database.executeBatch(batch,1);
        
    }
    
    @isTest static void test2(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        opportunity testOppty = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acctTest.Id, StageName = label.Stage_5_Contracts_Complete/*'10b - PO recd, pending finance approval'*/, CloseDate = system.Today()+30);
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
        testProduct1.Zscaler_Product_Family__c = 'ZIA';
        
        Product2 testProduct2 = new Product2(Name = 'Test Support Product');
        testProduct2.Product_Line__c = 'Support';
        testProduct2.ProductCode = 'ZIA-BUS-BUNDLE';
        testProduct2.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct2.IsActive = true;
        testProduct2.Zscaler_Product_Family__c = 'ZIA';
        
        Product2 testProduct3 = new Product2(Name = 'Test Support Product');
        testProduct3.Product_Line__c = 'Support';
        testProduct3.ProductCode = 'ZIA-TRANS-BUNDLE';
        testProduct3.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct3.IsActive = true;
        testProduct3.Zscaler_Product_Family__c = 'ZPA';
        
        Product2 testProduct4 = new Product2(Name = 'Test Support Product');
        testProduct4.Product_Line__c = 'Support';
        testProduct4.ProductCode = 'ZPA-PRO';
        testProduct4.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct4.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'ZPA';
        
        Product2 testProduct5 = new Product2(Name = 'Test Support Product');
        testProduct5.Product_Line__c = 'Support';
        testProduct5.ProductCode = 'ZPA-BUS';
        testProduct5.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct5.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Support';
        
        Product2 testProduct6 = new Product2(Name = 'Test Support Product');
        testProduct6.Product_Line__c = 'Support';
        testProduct6.ProductCode = 'ZPA-ENT';
        testProduct6.Apttus_Config2__ConfigurationType__c = 'Standalone';
        testProduct6.IsActive = true;
        testProduct4.Zscaler_Product_Family__c = 'Deployment';
        
        List<Product2> listProduct=new List<Product2>();
        listProduct.add(testProduct1);
        listProduct.add(testProduct2);
        listProduct.add(testProduct3);
        listProduct.add(testProduct4);
        listProduct.add(testProduct5);
        listProduct.add(testProduct6);
        insert listProduct;
        
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
        testProposal.Included_DAS_Package__c = 'DAS0';
        insert testProposal;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemLst = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        for(Integer i=0; i<listProduct.size(); i++){
            //Price List Item
            Apttus_Proposal__Proposal_Line_Item__c proposalLine = new Apttus_Proposal__Proposal_Line_Item__c();
            proposalLine.Apttus_Proposal__Proposal__c = testProposal.Id;
            proposalLine.Apttus_QPConfig__ExtendedPrice__c = 100;
            proposalLine.APTS_ACV__c = 30000;
            proposalLine.Apttus_Proposal__Product__c = listProduct[i].ID;
            proposalLineItemLst.add(proposalLine);
        }
        insert proposalLineItemLst;
        
        testOppty.Stagename = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/;
        update testOppty;
        
        DASNotification_OpptySnapshotBatch batch;
        Date sd = Date.Today();
        Date ed = Date.Today();
        String startdate = sd.year() + '-' + sd.month() + '-' + sd.day() + ' 00:00:00';
        String enddate = ed.year() + '-' + ed.month() + '-' + ed.day() + ' 23:59:59';
        batch = new DASNotification_OpptySnapshotBatch(startdate,enddate);
        Database.executeBatch(batch,1);
        
        
    }
}