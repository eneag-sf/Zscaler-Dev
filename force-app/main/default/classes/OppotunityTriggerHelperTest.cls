/*****************************************************************************************
Name: OppotunityTriggerHelperTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for OppotunityTriggerHelper class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            22-Aug-2016    Initial Development
******************************************************************************************/

@isTest(seeAllData = false)
public class OppotunityTriggerHelperTest{
    @isTest static void test(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        TriggerUtility.realignPatchReset();
        insert opp;

        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
        
        }

        opp.StageName = label.Stage_7_Closed_Lost /*'12 - Closed With No Decision'*/;
        opp.Primary_Reason_For_Loss__c = 'test';
        opp.Validation_Stage__c = '7 - Technical Loss';
        opp.Sub_Stage__c = Label.SubStage_Closed_Lost;
        update opp;


        Id erRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Equipment_Request__c er = new Equipment_Request__c();
        er.Approval_Status__c = 'Approved';
        er.RecordTypeId = erRecordTypeId;
        er.Opportunity__c = opp.Id;
        //er.OwnerId = userinfo.getUserId();
        er.Localized_content__c = true;
        insert er;

        opp.StageName = label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/;
        update opp;



        test.stoptest();
    }

    @isTest static void testAmberRoadScreening(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;

        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
        
        }

        opp.StageName = label.Stage_5_Contracts_Complete /*10b - PO recd, pending finance approval*/;
        update opp;


        test.stoptest();
    }

    @isTest static void testAmberRoadScreeningCase2(){
        test.starttest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(),
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;

        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){
        
        }

        opp.StageName = label.Stage_5_Contracts_Complete /*10b - PO recd, pending finance approval*/;
        update opp;


        test.stoptest();
    }

    @isTest static void testOpptyNextStepsUpdate() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;

        opp.NextStep = 'Test 2';
        update opp;
        Test.stopTest();
    }
    @isTest static void testOpptyArchiandforecastchanges() {
        Test.startTest();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();

        PatchTeam__c salestert  = new PatchTeam__c();
         salestert.District__c = 'District 1';
         salestert.Theater__c = 'AMER';
         salestert.Region__c = 'Central';
         salestert.Territory__c = 'SF Bay Area 1';
         salestert.Name = 'Sales Team';
         salestert.Sales_Territory_Year__c = 'Current';
         insert salestert;

        Patch__c patch  = new Patch__c();
         patch.Active__c = true;
         patch.PatchTeam__c = salestert.Id ;
         patch.PatchName__c = 'Test Patch';
         insert patch;

         PatchTeamMember__c SalesTeamMem1 = new PatchTeamMember__c();
         SalesTeamMem1.Role__c = 'Account Manager';
         SalesTeamMem1.PatchTeam__c = salestert.Id;
         SalesTeamMem1.User__c = userinfo.GetuserId();
         insert SalesTeamMem1 ;

         Account acc = new Account(Name = 'Test Account', Patch__c = patch.Id, Sales_Territory__c=salestert.Id,Type='Prospect');
         TriggerUtility.accSalesTeamExecuted();
        insert acc;

        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk');
        insert opp;

        acc.PatchLocked__c = true;
        acc.Patch__c = patch.Id;
        update acc;

        opp.NextStep = 'Test 2';
        opp.StageName = label.Stage_2_Qualified_Budgeted /*'2 - Technical Validation'*/;
        opp.AD_Forecast_Category__c = 'Omitted';
        opp.Architecture_Next_Steps__c = 'dfkjdsfjkjsfjkdsfjk';
        opp.Next_Steps__c  = 'dfkjdsfjkjsfjkdsfjk';
        opp.NextStep = 'dfkjdsfjkjsfjkdsfjk';
        opp.SE_Name__c = null;
        opp.Opportunity_ZPA_Manager__c = null;
         update opp;
        TriggerUtility.oppSpliSalesTeamReset();
        TriggerUtility.updateForecastCategoryReset();
        TriggerUtility.architectureHistoryReset();
        TriggerUtility.updateTechValHistoryReset();
        TriggerUtility.updateOppNextStepHistoryReset();
        TriggerUtility.updateSEManagerEmailReset();
        OppotunityTriggerHelper OTH = new OppotunityTriggerHelper();
        OppotunityTriggerHelper.booster();
        update opp;
        Test.stopTest();
    }

   /* @isTest static void testUpdateContractEndDate() {
        //Insert Account
        Account account = new Account(Name = 'Test Account',Type='Prospect');
        //account.Needs_to_be_Migrated__c = true;
        insert account;

        //Insert Price List
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c ();
        pricelist.Name = 'ZScaler FY2017 Price List';
        pricelist.Apttus_Config2__Active__c = true;
        insert pricelist;

        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
        listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
        insert listProduct;

        //create PriceListIteams
        List<Apttus_Config2__PriceListItem__c> listPLI = new List<Apttus_Config2__PriceListItem__c>();
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[3].ID));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[4].Id));
        listPLI.add(createPriceListItem(pricelist.Id, listProduct[5].Id));
        insert listPLI;

        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Do_Not_Aggregate__c = false;
        contractDetailList.add(contractDetail1);

        //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' Limit 1];
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Split';
        contractDetail2.Account_Name__c = account.Id;
        contractDetail2.Product_Name__c = listProduct[1].Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 180;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail2.Do_Not_Aggregate__c = false;
        contractDetailList.add(contractDetail2);

        Contract_Detail__c contractDetail3 = new Contract_Detail__c();
        contractDetail3.Name = 'Split';
        contractDetail3.Account_Name__c = account.Id;
        contractDetail3.Product_Name__c = listProduct[1].Id;
        contractDetail3.Start_Date__c = Date.Today();
        contractDetail3.End_Date__c = Date.Today() + 400;
        contractDetail3.Quantity__c = 100;
        contractDetail3.Amount_USD__c = 1000;
        contractDetail3.Contract_No__c = '100';
        contractDetail3.MRR_USD__c = 100;
        contractDetail3.List_Price__c = 100;
        contractDetail3.Discount__c = 10;
        contractDetail3.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail3.Do_Not_Aggregate__c = false;
        contractDetailList.add(contractDetail3);

        insert contractDetailList;

        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = account.Id, StageName = 1 - Qualified and Budgeted', SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId());
        insert opp;

        List<OpportunityLineItem> lstLineItems = new List<OpportunityLineItem>();
        OpportunityLineItem lineItem1 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[0].Id
                                        );

        lstLineItems.add(lineItem1);

        OpportunityLineItem lineItem2 = new OpportunityLineItem(
                                            OpportunityId = opp.Id,
                                            Product2Id = listProduct[1].Id
                                        );

        lstLineItems.add(lineItem2);

        Test.startTest();
        OppotunityTriggerHelper.updateContractEndDate(new List<Id> { account.Id });
        OppotunityTriggerHelper.updateContractEndDate(new List<Id> { account.Id }, new List<Id> { opp.Id });
        Test.stopTest();
    }*/

    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
       Product2 productSO = new Product2();
       productSO.Name = ProductName;
       productSO.Family = pfamily;
       productSO.ProductCode = pcode;
       productSO.IsActive = true;
       productSO.Apttus_Config2__ConfigurationType__c = sConfigType;
       productSO.Apttus_Config2__HasAttributes__c = false;
       productSO.Apttus_Config2__HasOptions__c = false;
       return productSO;
   }

   public static Apttus_Config2__PriceListItem__c createPriceListItem(Id PriceListId, Id ProductId) {

      Apttus_Config2__PriceListItem__c priceListItem = new Apttus_Config2__PriceListItem__c();
      priceListItem.Apttus_Config2__PriceListId__c = PriceListId;
      priceListItem.Apttus_Config2__ProductId__c = ProductId;
      priceListItem.Apttus_Config2__ChargeType__c = 'Standard Price';
      priceListItem.Apttus_Config2__PriceType__c = 'One Time';
      priceListItem.Apttus_Config2__PriceMethod__c = 'Flat Price';
      priceListItem.Apttus_Config2__ListPrice__c = 100;
      priceListItem.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-100);
      priceListItem.Apttus_Config2__ExpirationDate__c = Date.today().addDays(365);
      priceListItem.Apttus_Config2__Frequency__c = 'Yearly';
      priceListItem.Apttus_Config2__PriceUom__c = 'Each';
      priceListItem.Apttus_Config2__Active__c = true;
      priceListItem.Apttus_Config2__BillingFrequency__c = 'Yearly';
      priceListItem.Apttus_Config2__BillingRule__c = 'Bill In Advance';
      return priceListItem;
  }
  
  
   @testSetup static void setup() {
       Account acc = new Account();
       acc.Name='testacc';
       acc.Type ='Prospect';
       insert acc;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
         Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
         opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        
       
            
    }
    
    static testMethod void testafterInsert(){
        List<opportunity> opp = [Select Id,Name,
                                           AccountId,
                                           StageName,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity LIMIT 1];
        if(!opp.isEmpty()){
            Test.startTest();
            //OppotunityTriggerHelper opptriggerhelp = new OppotunityTriggerHelper();
            OppotunityTriggerHelper.afterInsert(opp);
            Test.stopTest();
            
            List<opportunity> opplist = [Select Id,AccountId,
                                           StageName,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity
                                           where  Id =: opp[0].Id];
            system.assertEquals(1, opplist.size());
            
        }
    }
    
     static testMethod void testafterUpdate(){
         
        List<opportunity> opp = [Select Id,Name,
                                           AccountId,
                                           StageName,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity LIMIT 1];
                        
        if(!opp.isEmpty()){
            Test.startTest();
           // opp[0].SE_name__c =uu.id;
             map<Id, Opportunity> oldOppMap = new map<Id, Opportunity>();
             oldOppMap.put(opp[0].id, opp[0]);
            //OppotunityTriggerHelper opptriggerhelp = new OppotunityTriggerHelper();
            OppotunityTriggerHelper.afterUpdate(opp,oldOppMap);
            Test.stopTest();
            
            List<opportunity> opplist = [Select Id,AccountId,
                                           StageName,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity
                                           where  Id =: opp[0].Id];
           opplist[0].SE_name__c = userinfo.getUserId();
            update  opplist;             
            system.assertEquals(1, opplist.size());
            
        }
    }
}