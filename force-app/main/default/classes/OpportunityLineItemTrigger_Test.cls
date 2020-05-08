@istest
public class OpportunityLineItemTrigger_Test{
    @testsetup
    static void testsetup(){
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        //Insert Account
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;

        //Insert Price List
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler FY2017 Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(OppotunityTriggerHelperTest.createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;
        
        Pricebook2 standardPB1 = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert standardPB1 ;
        
        Id standardPB = Test.getStandardPricebookId();
        //Insert Procebookentry
        List<PricebookEntry> listPBEntry = new List<PricebookEntry>();
        listPBEntry.add(createPriceBookEntry(listProduct[0],standardPB));
        listPBEntry.add(createPriceBookEntry(listProduct[1],standardPB ));
        insert listPBEntry;

        

        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(OppotunityTriggerHelperTest.createPriceListItem(pricelist.Id, listProduct[3].ID));
        listPLI.add(OppotunityTriggerHelperTest.createPriceListItem(pricelist.Id, listProduct[4].Id));
        listPLI.add(OppotunityTriggerHelperTest.createPriceListItem(pricelist.Id, listProduct[5].Id));
        insert listPLI;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = account.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId());
        insert opp;

        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[0].Id,
                                            pricebookentryId = listPBEntry[0].Id
                                        );

        lstLineItems.add(lineItem1);

        OpportunityLineItem lineItem2 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[1].Id,
                                            pricebookentryId = listPBEntry[1].Id
                                        );

        lstLineItems.add(lineItem2);
        insert lstLineItems;
    }
    static testmethod void test1(){
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        List<OpportunityLineItem> olilst = [select id from OpportunityLineItem];
        delete olilst ;
    }
    public static PricebookEntry createPriceBookEntry(Product2 prod, Id pricBookID){
        PricebookEntry PBEntry = new PricebookEntry();
        PBEntry.IsActive =true;
        PBEntry.UnitPrice = 100;
        PBEntry.Product2Id = Prod.Id;
        PBEntry.Pricebook2Id = pricBookID;
        return PBEntry;
    }
}