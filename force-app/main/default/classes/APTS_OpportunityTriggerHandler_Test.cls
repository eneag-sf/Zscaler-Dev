/*************************************************************************************************************************
 @Name: APTS_OpportunityTriggerHandler_Test
 @Author: Anay Bhande
 @Created Date: 22/12/2016
 @Descripton: Test Class for APTS_OpportunityTriggerHandler 
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTS_OpportunityTriggerHandler_Test 
{
        static testMethod void autoreneOpportunity() {
            Test.startTest();
            Account acc=APTS_TestUtil.creatAccount();
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            insert pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = acc.Id;
            opp.Price_List__c = pricelist.Id;
            opp.type ='Existing Customer (Renewal)';
            //opp.type='Renewal';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            update opp;

            Test.stopTest();
        }

        static testMethod void createNewBusinesOpp() {
            Test.startTest();
            Account acc=APTS_TestUtil.creatAccount();
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            insert pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = acc.Id;
            opp.Price_List__c = pricelist.Id;
            opp.type ='New Business';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            update opp;

            Test.stopTest();
        }

        static testMethod void createUpsellOpp() {
            Test.startTest();
            Account acc=APTS_TestUtil.creatAccount();
            Apttus_Config2__PriceList__c pricelist = new Apttus_Config2__PriceList__c ();
            pricelist.Name = 'ZScaler Price List';
            pricelist.Apttus_Config2__Active__c = true;
            insert pricelist;
            Pricebook2 pricebook=new Pricebook2(Name='Apttus Default Price Book');
            insert pricebook;
            //Admin Entries
            Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
            Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
            insert adminPriceBook;
            insert adminPriceList;
            
            Opportunity opp = new Opportunity ();
            opp.Name = 'test opportunity';
            opp.closedate =  Date.today();
            opp.Start_Date__c  =  Date.today();
            opp.accountId = acc.Id;
            opp.Price_List__c = pricelist.Id;
            opp.type ='Existing Customer (Renewal)';
            opp.Stagename = label.Stage_4_Economic_Buyer_Signoff;
            Apttus_Config2__AssetLineItem__c asl=new Apttus_Config2__AssetLineItem__c(Name='Test Asset Line Item',Apttus_Config2__AccountId__c=acc.Id,Apttus_Config2__AssetStatus__c='Activated');
            insert asl;
            TriggerUtility.realignPatchReset();
            insert opp;
            TriggerUtility.realignPatchReset();
            update opp;

            Test.stopTest();
        }

}