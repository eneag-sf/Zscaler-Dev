/*************************************************************************************************************************
 @Name: APTS_AssetLineItemUtil
 @Author: Shishir Bose
 @Created Date: 11/08/2016
 @Descripton: 
 @Used By: 
 //account.APTS_Notification_Number_of_Days__c field commented as part of field deletion
*************************************************************************************************************************/
public class APTS_AssetLineItemUtil {
    

 /*************************************************************************************************************************
 @Name: activateAgreement
 @Author: Shishir Bose
 @Created Date: 04/14/2016
 @Descripton: This method activates the agreement
*************************************************************************************************************************/

    static integer level_1_Notification = null;
    static integer level_2_Notification = null;
    static integer level_3_Notification = null;
    static integer level_4_Notification = null;
    static integer level_1_Notification_AfterExpiry = null;
    
    static date dateOnLevel_1_Notification = null;     
    static date dateOnLevel_2_Notification = null;     
    static date dateOnLevel_3_Notification = null;
    static date dateOnLevel_4_Notification = null;     
    static date dateOnlevel_1_Notification_AfterExpiry = null;
    static date todaysDate = date.today();
    static EmailTemplate[] emailTemplatesForBillTo;
    static EmailTemplate[] emailTemplatesCustomer;
    static EmailTemplate[] emailTemplatesCustomerAfterExpiry;
    static User accountUsr;
    
    public Static void processAssetLineItems(Account account)
    {
        Set<Id> assetBillToLevel_1_Notification = new Set<Id>();
        Set<Id> assetBillToLevel_2_Notification = new Set<Id>();
        Set<Id> assetBillToLevel_3_Notification = new Set<Id>();
        Set<Id> assetBillToLevel_4_Notification = new Set<Id>();
        Set<Id> assetBillToExpiredToday = new Set<Id>();
        Map<Id, string> assetBillToLevel_1_Notification_onExpiry = new Map<Id, string>();
        string tempString;
        emailTemplatesForBillTo = [SELECT Id, Name,  Subject, DeveloperName, 
                                         TemplateType, description, FolderId, Folder.DeveloperName,folder.Name
                                         FROM EmailTemplate where DeveloperName = 'APTS_Asset_Expire_Notifcation'];
                                         
        emailTemplatesCustomer = [SELECT Id, Name,  Subject, DeveloperName, 
                                         TemplateType, description, FolderId, Folder.DeveloperName,folder.Name
                                         FROM EmailTemplate where DeveloperName = 'APTS_Asset_Expire_Notifcation_Customers'];
                                         
        emailTemplatesCustomerAfterExpiry = [SELECT Id, Name,  Subject, DeveloperName, 
                                         TemplateType, description, FolderId, Folder.DeveloperName,folder.Name
                                         FROM EmailTemplate where DeveloperName = 'APTS_Asset_Exp_Notif_After_Expiry'];
                                                    
        
        //Admin entries for levels:
        for(Apttus__APTS_Admin__c adLevel : [select IsDeleted, Name, Apttus__Value__c from Apttus__APTS_Admin__c where IsDeleted = false])
        {
            if(adLevel.Name == 'APTS_Level1_Notification')
            {
                level_1_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_1_Notification = date.today().addDays(level_1_Notification);
            }
            else if(adLevel.Name == 'APTS_Level2_Notification')
            {
                level_2_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_2_Notification = date.today().addDays(level_2_Notification);
            }
            else if(adLevel.Name == 'APTS_Level3_Notification')
            {
                level_3_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_3_Notification = date.today().addDays(level_3_Notification);
            }
            else if(adLevel.Name == 'APTS_Level4_Notification')
            {
                level_4_Notification = integer.valueof(adLevel.Apttus__Value__c);
                dateOnLevel_4_Notification = date.today().addDays(level_4_Notification);
            }
            else if(adLevel.Name == 'APTS_Level1_Notification_On_Expire')
            {
                level_1_Notification_AfterExpiry = integer.valueof(adLevel.Apttus__Value__c);
                dateOnlevel_1_Notification_AfterExpiry = date.today().addDays(-level_1_Notification_AfterExpiry);
            }
        }
        
        
        List<Apttus_Config2__AssetLineItem__c> assetsToBeExpired = new List<Apttus_Config2__AssetLineItem__c>();
        
        
        
        accountUsr = [select Id, Name, email from user where Id =: account.ownerId ];
        
        for(Apttus_Config2__AssetLineItem__c assetLineItem : [select Id, Apttus_Config2__ProductId__r.ProductCode, 
            Apttus_Config2__ProductId__r.Description, Apttus_Config2__ListPrice__c, Apttus_Config2__NetPrice__c,  Apttus_Config2__NetUnitPrice__c,  
            APTS_Deal_Reg_Disc__c,Apttus_Config2__AccountId__c, Apttus_Config2__Quantity__c,
            Apttus_Config2__AssetStatus__c, Apttus_Config2__BillToAccountId__c, Apttus_Config2__EndDate__c from Apttus_Config2__AssetLineItem__c 
            where Apttus_Config2__AccountId__c =: account.Id and Apttus_Config2__AssetStatus__c = 'Activated' ])
        {
            if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_1_Notification)
            {
                if(!assetBillToLevel_1_Notification.contains(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    assetBillToLevel_1_Notification.add(assetLineItem.Apttus_Config2__BillToAccountId__c);
                }
            }
            else if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_2_Notification)
            {
                if(!assetBillToLevel_2_Notification.contains(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    assetBillToLevel_2_Notification.add(assetLineItem.Apttus_Config2__BillToAccountId__c);
                }
            }
            else if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_3_Notification)
            {
                if(!assetBillToLevel_3_Notification.contains(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    assetBillToLevel_3_Notification.add(assetLineItem.Apttus_Config2__BillToAccountId__c);
                }
            }
            else if(assetLineItem.Apttus_Config2__EndDate__c == dateOnLevel_4_Notification)
            {
                if(!assetBillToLevel_4_Notification.contains(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    assetBillToLevel_4_Notification.add(assetLineItem.Apttus_Config2__BillToAccountId__c);
                }
            }
            else if(assetLineItem.Apttus_Config2__EndDate__c == todaysDate)
            {
                if(!assetBillToExpiredToday.contains(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    assetBillToExpiredToday.add(assetLineItem.Apttus_Config2__BillToAccountId__c);
                }
            }
            else if(assetLineItem.Apttus_Config2__EndDate__c == dateOnlevel_1_Notification_AfterExpiry)
            {
                if(assetBillToLevel_1_Notification_onExpiry.containsKey(assetLineItem.Apttus_Config2__BillToAccountId__c))
                {
                    tempString = assetBillToLevel_1_Notification_onExpiry.get(assetLineItem.Apttus_Config2__BillToAccountId__c);
                    tempString = tempString + ', ' + assetLineItem.Apttus_Config2__ProductId__r.ProductCode;
                    assetBillToLevel_1_Notification_onExpiry.remove(assetLineItem.Apttus_Config2__BillToAccountId__c);
                    assetBillToLevel_1_Notification_onExpiry.put(assetLineItem.Apttus_Config2__BillToAccountId__c, tempString);
                }
                else
                {
                    assetBillToLevel_1_Notification_onExpiry.put(assetLineItem.Apttus_Config2__BillToAccountId__c, assetLineItem.Apttus_Config2__ProductId__r.ProductCode);
                }
            }
            
            
            if(assetLineItem.Apttus_Config2__EndDate__c != null && assetLineItem.Apttus_Config2__EndDate__c.addDays(30) == todaysDate)
            {
                assetLineItem.Apttus_Config2__AssetStatus__c = 'Cancelled';
                assetsToBeExpired.add(assetLineItem);
            }
        }
        
        if(assetsToBeExpired.size() > 0)
        {
            update assetsToBeExpired;
        }
        
       
        
        
        if(assetBillToLevel_1_Notification.size() > 0)
        {
            for(Id billToId : assetBillToLevel_1_Notification)
            {
                sendLevel_1_NotificationMail(account, billToId);
            }
        }
        
        if(assetBillToLevel_2_Notification.size() > 0)
        {
            for(Id billToId : assetBillToLevel_2_Notification)
            {
                sendLevel_2_NotificationMail(account, billToId);
            }
        }
        
        if(assetBillToLevel_3_Notification.size() > 0)
        {
            for(Id billToId : assetBillToLevel_3_Notification)
            {
                sendLevel_3_NotificationMail(account, billToId);
            }
        }
        
        if(assetBillToLevel_4_Notification.size() > 0)
        {
            for(Id billToId : assetBillToLevel_4_Notification)
            {
                sendLevel_4_NotificationMail(account, billToId);
            }
        }
        
        if(assetBillToExpiredToday.size() > 0)
        {
            for(Id billToId : assetBillToExpiredToday)
            {
                sendNotificationMailonExpiry(account, billToId);
            }
        }
        
        if(assetBillToLevel_1_Notification_onExpiry.size() > 0)
        {
            for(Id billToId : assetBillToLevel_1_Notification_onExpiry.keySet())
            {
                
                sendLevel_1_NotificationMail_OnExpiry(account, billToId, assetBillToLevel_1_Notification_onExpiry.get(billToId));
            }
        }
    }
    
    
    private static void sendLevel_1_NotificationMail(Account account, Id billToAccountId)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        /**account.APTS_Notification_Number_of_Days__c = string.valueof(level_1_Notification);**/
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        account.APTS_Asset_Expiry__c = dateOnLevel_1_Notification;
        update account;
        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName =account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomer(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendLevel_2_NotificationMail(Account account, Id billToAccountId)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        /**account.APTS_Notification_Number_of_Days__c = string.valueof(level_2_Notification);**/
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        account.APTS_Asset_Expiry__c = dateOnLevel_2_Notification;
        update account;
        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName =account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomer(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendLevel_3_NotificationMail(Account account, Id billToAccountId)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        /**account.APTS_Notification_Number_of_Days__c = string.valueof(level_3_Notification);**/
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        account.APTS_Asset_Expiry__c = dateOnLevel_3_Notification;
        update account;
        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName =account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        System.debug('--Contact:'+listOfContact);
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomer(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendLevel_4_NotificationMail(Account account, Id billToAccountId)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        /**account.APTS_Notification_Number_of_Days__c = string.valueof(level_4_Notification);**/
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        account.APTS_Asset_Expiry__c = dateOnLevel_4_Notification;
        update account;
        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName =account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        System.debug('--Contact:'+listOfContact);
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomer(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendNotificationMailonExpiry(Account account, Id billToAccountId)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        /**account.APTS_Notification_Number_of_Days__c = '0';**/
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        account.APTS_Asset_Expiry__c = todaysDate;
        update account;

        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName =account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        System.debug('--Contact:'+listOfContact);
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomer(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendLevel_1_NotificationMail_OnExpiry(Account account, Id billToAccountId, string assetCodes)
    {
        Account billToAccount = [select Id, ownerId, owner.Name, owner.email from Account where Id =: billToAccountId ];
        //User usr = [select Id, Name, email from user where Id =: billToAccount.ownerId ];
        
        
        /**account.APTS_Notification_Number_of_Days__c = '-' + string.valueof(level_1_Notification_AfterExpiry);**/
        account.APTS_Asset_Expiry__c = dateOnlevel_1_Notification_AfterExpiry;
        account.APTS_Bill_To_For_Notification__c = billToAccountId;
        Date tempDate = dateOnlevel_1_Notification_AfterExpiry.addDays(30);
        System.debug('Shishir tempDate ' + tempDate );
        account.APTS_Asset_Discontinuance__c = tempDate ;
        account.APTS_Assets_Code_To_Be_Expired__c = assetCodes;
        update account;             
        Contact contactForPartner = new contact(AccountId=billToAccountId,Project_Role__c='Other',LastName =billToAccount.owner.Name, email =billToAccount.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        Contact contactForCustomer = new contact(AccountId=account.ID ,Project_Role__c='Other',LastName = account.owner.Name, email =account.owner.email,Contact_Type__c = 'Prospect',No_of_employees_users__c='1 - 100' );
        List<Contact> listOfContact = new List<Contact>{contactForPartner,contactForCustomer};
        insert listOfContact;
        System.debug('--Contact:'+listOfContact);
        sendMailToPartner(account, contactForPartner);
        sendMailToCustomeronExpiry(account, contactForCustomer);
        delete listOfContact;
    }
    
    private static void sendMailToPartner(Account account, Contact cont)
    {
        EmailTemplate emailTemplate = emailTemplatesForBillTo[0];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        
        emailMsg.setTemplateId(emailTemplate.Id);        
        emailMsg.setSaveAsActivity(false);
        
        List<string> toAddresses = new List<string>{cont.email};
      
        emailMsg.setToAddresses(toAddresses);
        
        System.debug('account-->'+account.Id);
        emailMsg.setTargetObjectId(cont.Id);
        emailMsg.setWhatId(account.Id);
        System.debug('emailMsg-->'+emailMsg);
        List<Messaging.SingleEmailMessage> lMessgs = new List<Messaging.SingleEmailMessage>();
        lMessgs.add(emailMsg);
//        Messaging.sendEmail(lMessgs,true); 
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
        }
        
    }
    
    private static void sendMailToCustomer(Account account, Contact cont)
    {
        EmailTemplate emailTemplate = emailTemplatesCustomer[0];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        
        emailMsg.setTemplateId(emailTemplate.Id);        
        emailMsg.setSaveAsActivity(false);
        
       	List<string> toAddresses = new List<string>{cont.email};
        
        emailMsg.setToAddresses(toAddresses);
        
        System.debug('account-->'+account.Id);
        emailMsg.setTargetObjectId(cont.Id);
        emailMsg.setWhatId(account.Id);
        System.debug('emailMsg-->'+emailMsg);
        List<Messaging.SingleEmailMessage> lMessgs = new List<Messaging.SingleEmailMessage>();
        lMessgs.add(emailMsg);
//        Messaging.sendEmail(lMessgs,true); 
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});        
        }
       
    }
    private static void sendMailToCustomeronExpiry(Account account, Contact cont)
    {
        EmailTemplate emailTemplate = emailTemplatesCustomerAfterExpiry[0];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        
        emailMsg.setTemplateId(emailTemplate.Id);        
        emailMsg.setSaveAsActivity(false);
        
        List<string> toAddresses = new List<string>{cont.email};
        
        emailMsg.setToAddresses(toAddresses);
        
        emailMsg.setTargetObjectId(cont.Id);
        emailMsg.setWhatId(account.Id);
        System.debug('emailMsg-->'+emailMsg);
        List<Messaging.SingleEmailMessage> lMessgs = new List<Messaging.SingleEmailMessage>();
        lMessgs.add(emailMsg);
//        Messaging.sendEmail(lMessgs,true);   
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});  
        }
    }
}