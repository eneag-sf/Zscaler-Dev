@isTest
public class CaseTrigger_Test {
    @IsTest
    static void test1(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
            
            //Insert Products
            List<Product2> listProduct = new list<Product2>();
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
            insert listProduct;
            
            //Create Contractdetails
            List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
            Contract_Detail__c contractDetail1 = new Contract_Detail__c();
            contractDetail1.Name = 'Migrate as is';
            contractDetail1.Account_Name__c = acct.Id;
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
            contractDetailList.add(contractDetail1);
            
            //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' and isActive = true limit 1];
            Contract_Detail__c contractDetail2 = new Contract_Detail__c();
            contractDetail2.Name = 'Split';
            contractDetail2.Account_Name__c = acct.Id;
            contractDetail2.Product_Name__c = listProduct[1].Id;
            contractDetail2.Start_Date__c = Date.Today();
            contractDetail2.End_Date__c = Date.Today() + 365;
            contractDetail2.Quantity__c = 100;
            contractDetail2.Amount_USD__c = 1000;
            contractDetail2.Contract_No__c = '100';
            contractDetail2.MRR_USD__c = 100;
            contractDetail2.List_Price__c = 100;
            contractDetail2.Discount__c = 10;
            contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail2);
            
            insert contractDetailList;
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            try{
                update cs;
            }catch(Exception ex){
                
            }
			CaseTriggerUtility.booster();
        }
    }
    @IsTest
    static void test2(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
            
            //Insert Products
            List<Product2> listProduct = new list<Product2>();
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
            listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
            listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product22', 'ZCES-SUP-PREM', 'Zscaler Products', 'Standalone'));
            listProduct.add(createProduct('Product33', 'CODE04', 'Zscaler Products', 'Standalone'));
            insert listProduct;
            
            //Create Contractdetails
            List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
            Contract_Detail__c contractDetail1 = new Contract_Detail__c();
            contractDetail1.Name = 'Migrate as is';
            contractDetail1.Account_Name__c = acct.Id;
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
            contractDetailList.add(contractDetail1);
            
            //Product2 product2 = [Select Id From Product2 Where ProductCode = 'ZSUITE-WEBSTD-1YR' and isActive = true limit 1];
            Contract_Detail__c contractDetail2 = new Contract_Detail__c();
            contractDetail2.Name = 'Split';
            contractDetail2.Account_Name__c = acct.Id;
            contractDetail2.Product_Name__c = listProduct[1].Id;
            contractDetail2.Start_Date__c = Date.Today();
            contractDetail2.End_Date__c = Date.Today() + 365;
            contractDetail2.Quantity__c = 100;
            contractDetail2.Amount_USD__c = 1000;
            contractDetail2.Contract_No__c = '100';
            contractDetail2.MRR_USD__c = 100;
            contractDetail2.List_Price__c = 100;
            contractDetail2.Discount__c = 10;
            contractDetail2.Needs_to_Be_Migrated_to_Asset_Line__c = true;
            contractDetailList.add(contractDetail2);
            
            insert contractDetailList;
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    @IsTest
    static void test3(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
			Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
			
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    @IsTest
    static void test4(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
			Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
			
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }

    
    @IsTest
    static void test5(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c != null and isActive = true limit 1];
        System.runAs(ur){
			
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    @IsTest
    static void test6(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c != null and isActive = true limit 1];
        System.runAs(ur){
            Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }

    /*@IsTest
    static void test7(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        System.runAs(ur){
			Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
			
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            cs.HandOff_Cases__c = true;
            cs.Escalation_Resolution_Notes__c = 'itsnotes';
            cs.Status = 'Researching';
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            try{
                update cs;
            }catch(Exception ex){
                
            }
        }
    }
    @IsTest
    static void test8(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getpriorityscore();
        insert TestDatafactory_Zscaler.getdefconcasescore();
        insert TestDatafactory_Zscaler.getprimsecescmap();
        insert TestDatafactory_Zscaler.getserviceteamtoskill();
        Test.startTest();
        Test.stopTest();
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where ContactId != null and isActive = true limit 1];
        System.runAs(ur){
		
			Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = UserInfo.getUserId();
            insert acct;
			
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;
			
            
            TriggerUtility.CaseBeforeUpdateReset();
            TriggerUtility.CaseAfterUpdateReset();
            cs.Status = 'Closed';
            cs.Case_category__c = 'APIs';
            cs.Case_Sub_Category__c = 'Assets Fix';
            cs.Resolution_Type__c = 'Resolved by KB';
            cs.Resolution_Summary__c = 'Resolved';
            try{
                update cs;
            }catch(Exception ex){

            }
        }
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
}