@isTest
public class SendSignedLegalCertificationEmailTest {
    
    
	public static testMethod void testLegalCertification() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
            test.starttest();
            Account AccountToBeReferred = new Account();
            AccountToBeReferred.Name ='Test Account';
            AccountToBeReferred.Type ='Partner';
            AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today();
            AccountToBeReferred.BillingCountry = 'US';
            insert AccountToBeReferred;
            
            Contact ContactReferred = new Contact();
            //ContactReferred.FirstName =  ;
            ContactReferred.LastName = 'Test LastName';
            ContactReferred.AccountId = AccountToBeReferred.id;
            insert ContactReferred;
            
            AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
            update AccountToBeReferred;
            
            //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
            DataBase.executeBatch(btch);
            test.stoptest();
        }
	}
	public static testMethod void testLegalCertificationMethod1() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today() -37;
        AccountToBeReferred.BillingCountry = 'US';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}
	
	public static testMethod void testLegalCertificationMethod2() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today() -48;
        AccountToBeReferred.BillingCountry = 'US';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}
	public static testMethod void testLegalCertificationMethod3() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today();
        AccountToBeReferred.BillingCountry = 'France';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}
	public static testMethod void testLegalCertificationMethod4() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today() -37;
        AccountToBeReferred.BillingCountry = 'France';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}
	public static testMethod void testLegalCertificationMethod5() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today() -48;
        AccountToBeReferred.BillingCountry = 'France';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}
	public static testMethod void testLegalCertificationMethod6() {
	    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1];
        User me = [SELECT Username, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ViewForecastAs__c, ForecastEnabled__c, ForecastLevel__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23', UserRoleId = r.Id,
            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = me.Email, Alias = 'dumt', CommunityNickname = 'dumt',
            TimeZoneSidKey = me.TimeZoneSidKey, LocaleSidKey = me.LocaleSidKey, EmailEncodingKey = me.EmailEncodingKey,
            LanguageLocaleKey = me.LanguageLocaleKey, ForecastEnabled__c = true);
        insert usr;
        Id userId = usr.Id;
        system.runas(new User(Id=Userinfo.getUserId())){
        test.starttest();
        Account AccountToBeReferred = new Account();
        AccountToBeReferred.Name ='Test Account';
        AccountToBeReferred.Type ='Partner';
        AccountToBeReferred.Signed_Legal_Certification_Date__c = system.today() -51;
        AccountToBeReferred.BillingCountry = 'France';
        insert AccountToBeReferred;
        
        Contact ContactReferred = new Contact();
        //ContactReferred.FirstName =  ;
        ContactReferred.LastName = 'Test LastName';
        ContactReferred.AccountId = AccountToBeReferred.id;
        insert ContactReferred;
        
        AccountToBeReferred.PartnerContractReviewer__c = ContactReferred.id;
        update AccountToBeReferred;
        
        //BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails(AccountToBeReferred.id);
        BatchSendSignedLegalCertificationEmails btch = new BatchSendSignedLegalCertificationEmails();
        DataBase.executeBatch(btch);
        test.stoptest();
        }
	}

}