/*************************************************************************************************************************
 @Name: APTS_AssetExpiringNotiScheduleTest
 @Author: Pranjal Mittal
 @Created Date: 23/11/2016
 @Descripton: Test Class for APTS_AssetExpiringNotificationSchedule, APTS_AssetLineItemNotificationBatch and APTS_AssetLineItemUtil
 @Used By: 
*************************************************************************************************************************/
@isTest
public class APTS_AssetExpiringNotiScheduleTest {
    
    @testSetup
    static void testData(){
        
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User userTest = new User(LastName = 'Lastname1',
                           FirstName='Firstname1',
                           Alias = 'testa',
                           Email = 'dummy@dummy.com1',
                           Username = 'test1@maari2.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
                           insert userTest;
        String emailBody='Sample Email Body';
        List<EmailTemplate> listemailTemplateTest = new List<EmailTemplate>();
        listemailTemplateTest.add(new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation', 
                                                                 FolderId = userTest.id, TemplateType= 'Text',
                                                                 Name = 'emailTemplateTest1', isActive = True, Body=emailBody));
        listemailTemplateTest.add(new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation_Customers', 
                                                                 FolderId = userTest.id, TemplateType= 'Text',
                                                                 Name = 'emailTemplateTest2', isActive = True, Body=emailBody));
        listemailTemplateTest.add(new EmailTemplate (developerName = 'APTS_Asset_Exp_Notif_After_Expiry', 
                                                                 FolderId = userTest.id, TemplateType= 'Text',
                                                                 Name = 'emailTemplateTest3', isActive = True, Body=emailBody));
       	System.runAs(userTest){
            insert listemailTemplateTest;
        }
        Account acctTest = new Account(Name = 'Test Account');
        Account acctTest1 = new Account(Name = 'Test Account 1');
        Account acctTest2 = new Account(Name = 'Test Account 2');
        
        Apttus__APTS_Admin__c adminTestLevel1 = new Apttus__APTS_Admin__c(Name = 'APTS_Level1_Notification', Apttus__Value__c = '90');
        Apttus__APTS_Admin__c adminTestLevel2 = new Apttus__APTS_Admin__c(Name = 'APTS_Level2_Notification', Apttus__Value__c = '60');
        Apttus__APTS_Admin__c adminTestLevel3 = new Apttus__APTS_Admin__c(Name = 'APTS_Level3_Notification', Apttus__Value__c = '30');
        Apttus__APTS_Admin__c adminTestLevel4 = new Apttus__APTS_Admin__c(Name = 'APTS_Level4_Notification', Apttus__Value__c = '7');
        Apttus__APTS_Admin__c adminTestLevel1OnExpire = new Apttus__APTS_Admin__c(Name = 'APTS_Level1_Notification_On_Expire', Apttus__Value__c = '7');
        
        Apttus_Config2__AssetLineItem__c assetLineItemTest = new Apttus_Config2__AssetLineItem__c(Name = 'Test Asset', Apttus_Config2__AssetStatus__c = 'Activated');
        
       
        
        acctTest.OwnerId = userTest.Id;
        acctTest1.OwnerId = userTest.Id;
        acctTest2.OwnerId = userTest.Id;
        insert acctTest;
        //insert acctTest1;
        //insert acctTest2;
        insert adminTestLevel1;
        insert adminTestLevel2;
        insert adminTestLevel3;
        insert adminTestLevel4;
        insert adminTestLevel1OnExpire;
        insert assetLineItemTest;
        
        
    }
    
    @isTest
    static void scheduleTestMethod(){
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
    } 
    
    @isTest
    static void testLevel1Notification(){
        Account acctTest = [SELECT Name, Id, OwnerId/**, APTS_Notification_Number_of_Days__c**/ from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c 
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(90);
        update assetLineItemTest;
        /*
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname2',
                           FirstName='Firstname2',
                           Alias = 'testb',
                           Email = 'dummy@dummy.com2',
                           Username = 'test2@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test2@asdf.com' limit 1];
  //          EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation_2', 
  //                                                               FolderId = userTest.id, TemplateType= 'Text', 
  //                                                               Name = 'emailTemplateTest', isActive = True);
       //     insert emailTemplateTest;
        }
        */
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '90');
    }
    
    @isTest
    static void testLevel2Notification(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c 
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(60);
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname3',
                           FirstName='Firstname3',
                           Alias = 'testc',
                           Email = 'dummy@dummy.com3',
                           Username = 'test3@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test3@asdf.com' limit 1];
  //          EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation', 
    //                                                             FolderId = userTest.id, TemplateType= 'Text',
     //                                                            Name = 'emailTemplateTest', isActive = True);
      //      insert emailTemplateTest;
        }
        
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        //APTS_AssetLineItemUtil.processAssetLineItems(acctTest);
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '60');
    }
    
    @isTest
    static void testLevel3Notification(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c 
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(30);
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname4',
                           FirstName='Firstname4',
                           Alias = 'testd',
                           Email = 'dummy@dummy.com4',
                           Username = 'test4@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test4@asdf.com' limit 1];
      //      EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation',
       //                                                          FolderId = userTest.id, TemplateType= 'Text',
        //                                                         Name = 'emailTemplateTest', isActive = True);
        //    insert emailTemplateTest;
        }

        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '30');
    }
    
    @isTest
    static void testLevel4Notification(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c 
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(7);
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname5',
                           FirstName='Firstname5',
                           Alias = 'teste',
                           Email = 'dummy@dummy.com5',
                           Username = 'test5@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test5@asdf.com' limit 1];
      //      EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation', 
       //                                                          FolderId = userTest.id, TemplateType= 'Text',
       //                                                          Name = 'emailTemplateTest', isActive = True);
        //    insert emailTemplateTest;
        }
        
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '7');
    }
    
    @isTest
    static void testTodayExpiryNotification(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c 
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today();
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname6',
                           FirstName='Firstname6',
                           Alias = 'testf',
                           Email = 'dummy@dummy.com6',
                           Username = 'test6@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test6@asdf.com' limit 1];
         //   EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation', 
        //                                                         FolderId = userTest.id, TemplateType= 'Text', 
         //                                                        Name = 'emailTemplateTest', isActive = True);
        //    insert emailTemplateTest;
        }
        
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '0');
    }
    
    @isTest
    static void testLevel1NotificationonExpiryNotification(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c
                                                              from Apttus_Config2__AssetLineItem__c
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(-7);
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname7',
                           FirstName='Firstname7',
                           Alias = 'testg',
                           Email = 'dummy@dummy.com7',
                           Username = 'test7@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test7@asdf.com' limit 1];
      //      EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation',
        //                                                         FolderId = userTest.id, TemplateType= 'Text',
         //                                                        Name = 'emailTemplateTest', isActive = True);
         //   insert emailTemplateTest;
        }
        
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '-7');
    }
        
    @isTest
    static void testCancelledAssets(){
        Account acctTest = [SELECT Name, Id, OwnerId from Account where Name = 'Test Account'];
        Apttus_Config2__AssetLineItem__c assetLineItemTest = [SELECT Name, Id, Apttus_Config2__AccountId__c, Apttus_Config2__BillToAccountId__c 
                                                              from Apttus_Config2__AssetLineItem__c
                                                              where Name ='Test Asset'];
        assetLineItemTest.Apttus_Config2__AccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__BillToAccountId__c = acctTest.Id;
        assetLineItemTest.Apttus_Config2__EndDate__c = date.today().addDays(-30);
        update assetLineItemTest;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        System.runAs(new User(LastName = 'Lastname8',
                           FirstName='Firstname8',
                           Alias = 'testh',
                           Email = 'dummy@dummy.com8',
                           Username = 'test8@maari2.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           )) {
            User userTest = [SELECT Id from User where Username = 'test8@maari2.com' limit 1];
        //    EmailTemplate emailTemplateTest = new EmailTemplate (developerName = 'APTS_Asset_Expire_Notifcation',
         //                                                        FolderId = userTest.id, TemplateType= 'Text',
         //                                                        Name = 'emailTemplateTest', isActive = True);
         //   insert emailTemplateTest;
        }
        
        test.startTest();
        APTS_AssetExpiringNotificationSchedule assetExpiringNotificationScheduleTest = new APTS_AssetExpiringNotificationSchedule();
        String cronExp = '0 0 23 * * ?';
        System.schedule('Test Schedule', cronExp, assetExpiringNotificationScheduleTest);
        test.stopTest();
        
        //acctTest = [SELECT Name, Id, OwnerId, APTS_Notification_Number_of_Days__c from Account where Name = 'Test Account'];
        //System.assertEquals(acctTest.APTS_Notification_Number_of_Days__c, '-30');
    }
}