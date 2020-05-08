/*************************************************************************************************************************
 @Name: APTS_AssetLineItemUtilTest
 @Author: Pranjal Mittal
 @Created Date: 24/11/2016
 @Descripton: Test class for APTS_AssetExpPartnerNotfController
 @Used By: 
*************************************************************************************************************************/

@isTest
public class APTS_AssetExpPartnerNotfControllerTest {

    @testSetup static void testData() {
    	Apttus__APTS_Admin__c adminTestLevel1 = new Apttus__APTS_Admin__c(Name = 'APTS_Level1_Notification', Apttus__Value__c = '90');
        Apttus__APTS_Admin__c adminTestLevel2 = new Apttus__APTS_Admin__c(Name = 'APTS_Level2_Notification', Apttus__Value__c = '60');
        Apttus__APTS_Admin__c adminTestLevel3 = new Apttus__APTS_Admin__c(Name = 'APTS_Level3_Notification', Apttus__Value__c = '30');
        Apttus__APTS_Admin__c adminTestLevel4 = new Apttus__APTS_Admin__c(Name = 'APTS_Level4_Notification', Apttus__Value__c = '7');
        Apttus__APTS_Admin__c adminTestLevel1OnExpire = new Apttus__APTS_Admin__c(Name = 'APTS_Level1_Notification_On_Expire', Apttus__Value__c = '7');
        Apttus_Config2__AssetLineItem__c assetLineItemTest = new Apttus_Config2__AssetLineItem__c(Name = 'Test Asset',
                                                                                                  Apttus_Config2__AssetStatus__c = 'Activated');
        Account acctTest = new Account(Name = 'Test Account');
        insert adminTestLevel1;
        insert adminTestLevel2; 
        insert adminTestLevel3;
        insert adminTestLevel4;
        insert adminTestLevel1OnExpire;
        insert assetLineItemTest;
        insert acctTest;
    }
    
    static testMethod void testNoAssetExpiring(){
		APTS_AssetExpPartnerNotfController assetExpPartnerNotfControllerObj = new APTS_AssetExpPartnerNotfController();
        List<Apttus_Config2__AssetLineItem__c> lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 0);
    }
    
    static testMethod void testOneExpiringAsset(){
        APTS_AssetExpPartnerNotfController assetExpPartnerNotfControllerObj = new APTS_AssetExpPartnerNotfController();
        assetExpPartnerNotfControllerObj.noOfDays = '90';
        
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c,
                                                              Apttus_Config2__BillToAccountId__c, Apttus_Config2__EndDate__c
                                                              from Apttus_Config2__AssetLineItem__c
                                                              where Name ='Test Asset'];
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        assetExpPartnerNotfControllerObj.billToId = acctTest.Id;
        assetExpPartnerNotfControllerObj.accntId = acctTest.Id;
		assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
       	assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__NetPrice__c = 0;
        
        //Check when 90 days are left to expire
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(90);
        update assetLineItemTest;
        List<Apttus_Config2__AssetLineItem__c> lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);
        
        //Check when 60 days are left to expire
        assetExpPartnerNotfControllerObj.noOfDays = '60';
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(60);
        update assetLineItemTest;
        assetExpPartnerNotfControllerObj.mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        assetExpPartnerNotfControllerObj.lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
        lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);
        
        //Check when 30 days are left to expire
		assetExpPartnerNotfControllerObj.noOfDays = '30';
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(30);
        update assetLineItemTest;
        assetExpPartnerNotfControllerObj.mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        assetExpPartnerNotfControllerObj.lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
        lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);
        
        //Check when 7 days are left to expire
        assetExpPartnerNotfControllerObj.noOfDays = '7';
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(7);
        update assetLineItemTest;
        assetExpPartnerNotfControllerObj.mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        assetExpPartnerNotfControllerObj.lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
        lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);
        
        //Check when 0 days are left to expire
		assetExpPartnerNotfControllerObj.noOfDays = '0';
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(0);
        update assetLineItemTest;
        assetExpPartnerNotfControllerObj.mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        assetExpPartnerNotfControllerObj.lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
        lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);

        //Check when already expired
		assetExpPartnerNotfControllerObj.noOfDays = '-7';
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(-7);
        update assetLineItemTest;
        assetExpPartnerNotfControllerObj.mapAssetExpiring = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        assetExpPartnerNotfControllerObj.lstAssetExpiring = new List<Apttus_Config2__AssetLineItem__c>();
        lisOfAssetLineItems = assetExpPartnerNotfControllerObj.GetlstAssetExpiring();
        System.assertEquals(lisOfAssetLineItems.size(), 1);
    }
    
}