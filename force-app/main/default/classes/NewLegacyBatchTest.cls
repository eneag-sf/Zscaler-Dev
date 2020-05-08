@isTest
public class NewLegacyBatchTest {
    public static testMethod void NewLegacyTest(){
        Profile p;
        List<Profile> profileList = [SELECT id FROM profile where NAME like '%sys%'];
        if (profileList.size()>0) 
            p=profileList.get(0); 
        User u = new User(alias = 'kbra', email='asdasdasd@noemail.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                          localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                          timezonesidkey='Europe/Paris', username='asdasdasd@noemail.com',
                          IsActive = true);
        insert u; 
        User u1 = new User(alias = 'kbra', email='asdasdasd@salesforce.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                           localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                           timezonesidkey='Europe/Paris', username='asdasdasd@salesforce.com',
                           IsActive = true);
        insert u1; 
        Account pAcc = new Account( Name = 'Parent Account', BillingCountry='FRANCE' );
        insert pAcc;
        Account acc = new Account(Name = 'Child Account',BillingCountry='FRANCE' );
        Insert acc;
        Contact con = new Contact(LastName='BRAZI', Account= acc, Title='Mrs', Email='asdasdasd@salesforce.com');
        insert con;
     
        Case c1 = new Case();
        c1.Type = 'Complaint';
        c1.Status = 'Created';
        c1.AccountId = acc.Id;
        c1.ContactId = con.Id;
        c1.OwnerId = u1.Id;
        c1.Origin = 'Customer Service Input';
        insert c1;
        
        CaseTeamRole ctr = new CaseTeamRole();
        ctr=[select Id, AccessLevel from CaseTeamRole  limit 1];
        
        CaseTeamRole ctr1 = new CaseTeamRole();
        ctr1=[select Id, AccessLevel from CaseTeamRole  limit 1];
        List<CaseTeamMember> CTMs = new List<CaseTeamMember>();
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Zendesk_Reference_Id__c = '123';
        cs.New_Legacy_2__c = false;
        cs.Origin = 'Legacy';
        insert cs;
        Case cs1 = new Case();
        cs1.Status = 'New';
        cs1.Zendesk_Reference_Id__c = '123';
        cs1.New_Legacy_2__c = true;
        cs1.Origin = 'Legacy';
        insert cs1;
        
        Case cs2 = new Case();
        cs2.Status = 'New';
        cs2.Zendesk_Reference_Id__c = '123';
        cs2.New_Legacy_2__c = true;
        cs2.Origin = 'Legacy';
        insert cs2;
        
        Legacy_Case_Comment__c lc = new Legacy_Case_Comment__c();
        lc.Name = 'test';
        lc.Comment_Body__c = 'test';
        lc.Cases__c = cs.Id;
        insert lc;
        Legacy_Case_Comment__c lc1 = new Legacy_Case_Comment__c();
        lc1.Name = 'test';
        lc1.Comment_Body__c = 'test';
        lc1.Cases__c = cs1.Id;
        insert lc1;
        
        Legacy_Case_Comment__c lc2 = new Legacy_Case_Comment__c();
        lc2.Name = 'test';
        lc2.Comment_Body__c = 'test';
        lc2.Cases__c = cs2.Id;
        insert lc2;
        
        CaseTeamMember ctmem = new CaseTeamMember();
        ctmem.TeamRoleId = ctr.Id;
        ctmem.MemberId = u1.Id;
        ctmem.ParentId = cs.Id;
        CTMs.add(ctmem);
        
        CaseTeamMember ctmem1 = new CaseTeamMember();
        ctmem1.TeamRoleId = ctr1.Id;
        ctmem1.MemberId = con.Id;
        ctmem1.ParentId = cs1.Id;
        
        CTMs.add(ctmem1);
        insert CTMs;
        
        
        test.startTest();
        NewLegacyBatch nb = new NewLegacyBatch();
        Database.executeBatch(nb);
        test.stopTest();
    }
    public static testMethod void NewLegacyTest1(){
        Profile p;
        List<Profile> profileList = [SELECT id FROM profile where NAME like '%sys%'];
        if (profileList.size()>0) 
            p=profileList.get(0); 
        User u = new User(alias = 'kbra', email='asdasdasd@noemail.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                          localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                          timezonesidkey='Europe/Paris', username='asdasdasd@noemail.com',
                          IsActive = true);
        insert u; 
        User u1 = new User(alias = 'kbra', email='asdasdasd@salesforce.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                           localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                           timezonesidkey='Europe/Paris', username='asdasdasd@salesforce.com',
                           IsActive = true);
        insert u1; 
        Account pAcc = new Account( Name = 'Parent Account', BillingCountry='FRANCE' );
        insert pAcc;
        Account acc = new Account(Name = 'Child Account',BillingCountry='FRANCE' );
        Insert acc;
        Contact con = new Contact(LastName='BRAZI', Account= acc, Title='Mrs', Email='asdasdasd@salesforce.com');
        insert con;
     
        Case c1 = new Case();
        c1.Type = 'Complaint';
        c1.Status = 'Created';
        c1.AccountId = acc.Id;
        c1.ContactId = con.Id;
        c1.OwnerId = u1.Id;
        c1.Origin = 'Customer Service Input';
        insert c1;
        
        CaseTeamRole ctr = new CaseTeamRole();
        ctr=[select Id, AccessLevel from CaseTeamRole  limit 1];
        
        CaseTeamRole ctr1 = new CaseTeamRole();
        ctr1=[select Id, AccessLevel from CaseTeamRole  limit 1];
        List<CaseTeamMember> CTMs = new List<CaseTeamMember>();
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Zendesk_Reference_Id__c = '123';
        cs.New_Legacy_2__c = false;
        cs.Origin = 'Legacy';
        insert cs;
        Case cs1 = new Case();
        cs1.Status = 'New';
        cs1.Zendesk_Reference_Id__c = '123';
        cs1.New_Legacy_2__c = true;
        cs1.Origin = 'Legacy';
        insert cs1;
        
        Case cs2 = new Case();
        cs2.Status = 'New';
        cs2.Zendesk_Reference_Id__c = '123';
        cs2.New_Legacy_2__c = true;
        cs2.Origin = 'Legacy';
        insert cs2;
        
        Legacy_Case_Comment__c lc = new Legacy_Case_Comment__c();
        lc.Name = 'test';
        lc.Comment_Body__c = 'test';
        lc.Cases__c = cs.Id;
        insert lc;
        Legacy_Case_Comment__c lc1 = new Legacy_Case_Comment__c();
        lc1.Name = 'test';
        lc1.Comment_Body__c = 'test';
        lc1.Cases__c = cs1.Id;
        insert lc1;
        
        Legacy_Case_Comment__c lc2 = new Legacy_Case_Comment__c();
        lc2.Name = 'test';
        lc2.Comment_Body__c = 'test';
        lc2.Cases__c = cs2.Id;
        insert lc2;
        
        CaseTeamMember ctmem = new CaseTeamMember();
        ctmem.TeamRoleId = ctr.Id;
        ctmem.MemberId = u1.Id;
        ctmem.ParentId = cs.Id;
        CTMs.add(ctmem);
        
        CaseTeamMember ctmem1 = new CaseTeamMember();
        ctmem1.TeamRoleId = ctr1.Id;
        ctmem1.MemberId = con.Id;
        ctmem1.ParentId = cs1.Id;
        
        CTMs.add(ctmem1);
        insert CTMs;
        
        
        test.startTest();
        CaseCount cc = new CaseCount('Select Id, Number_of_comment__c, Number_of_TeamMember__c, Number_of_link__c from case limit 2');
        Database.executeBatch(cc);
        test.stopTest();
    }
    public static testMethod void NewLegacyTest3(){
        Profile p;
        List<Profile> profileList = [SELECT id FROM profile where NAME like '%sys%'];
        if (profileList.size()>0) 
            p=profileList.get(0); 
        User u = new User(alias = 'kbra', email='asdasdasd@noemail.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                          localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                          timezonesidkey='Europe/Paris', username='asdasdasd@noemail.com',
                          IsActive = true);
        insert u; 
        User u1 = new User(alias = 'kbra', email='asdasdasd@salesforce.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                           localesidkey='fr_FR_EURO', profileid = p.Id, country='France',
                           timezonesidkey='Europe/Paris', username='asdasdasd@salesforce.com',
                           IsActive = true);
        insert u1; 
        Account pAcc = new Account( Name = 'Parent Account', BillingCountry='FRANCE' );
        insert pAcc;
        Account acc = new Account(Name = 'Child Account',BillingCountry='FRANCE' );
        Insert acc;
        Contact con = new Contact(LastName='BRAZI', Account= acc, Title='Mrs', Email='asdasdasd@salesforce.com');
        insert con;
     
        Case c1 = new Case();
        c1.Type = 'Complaint';
        c1.Status = 'Created';
        c1.AccountId = acc.Id;
        c1.ContactId = con.Id;
        c1.OwnerId = u1.Id;
        c1.Origin = 'Customer Service Input';
        insert c1;
        
        CaseTeamRole ctr = new CaseTeamRole();
        ctr=[select Id, AccessLevel from CaseTeamRole  limit 1];
        
        CaseTeamRole ctr1 = new CaseTeamRole();
        ctr1=[select Id, AccessLevel from CaseTeamRole  limit 1];
        List<CaseTeamMember> CTMs = new List<CaseTeamMember>();
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Zendesk_Reference_Id__c = '123';
        cs.New_Legacy_2__c = false;
        cs.Origin = 'Legacy';
        insert cs;
        Case cs1 = new Case();
        cs1.Status = 'New';
        cs1.Zendesk_Reference_Id__c = '123';
        cs1.New_Legacy_2__c = true;
        cs1.Origin = 'Legacy';
        insert cs1;
        
        Case cs2 = new Case();
        cs2.Status = 'New';
        cs2.Zendesk_Reference_Id__c = '123';
        cs2.New_Legacy_2__c = true;
        cs2.Origin = 'Legacy';
        insert cs2;
        
        Legacy_Case_Comment__c lc = new Legacy_Case_Comment__c();
        lc.Name = 'test';
        lc.Comment_Body__c = 'test';
        lc.Cases__c = cs.Id;
        insert lc;
        Legacy_Case_Comment__c lc1 = new Legacy_Case_Comment__c();
        lc1.Name = 'test';
        lc1.Comment_Body__c = 'test';
        lc1.Cases__c = cs1.Id;
        insert lc1;
        
        Legacy_Case_Comment__c lc2 = new Legacy_Case_Comment__c();
        lc2.Name = 'test';
        lc2.Comment_Body__c = 'test';
        lc2.Cases__c = cs2.Id;
        insert lc2;
        
        CaseTeamMember ctmem = new CaseTeamMember();
        ctmem.TeamRoleId = ctr.Id;
        ctmem.MemberId = u1.Id;
        ctmem.ParentId = cs.Id;
        CTMs.add(ctmem);
        
        CaseTeamMember ctmem1 = new CaseTeamMember();
        ctmem1.TeamRoleId = ctr1.Id;
        ctmem1.MemberId = con.Id;
        ctmem1.ParentId = cs1.Id;
        
        CTMs.add(ctmem1);
        insert CTMs;
        
        
        test.startTest();
        CopyLegacyCommentDetails cc = new CopyLegacyCommentDetails('select Id, Cases__c,CreatedBy.Name,Createddate, Legacy_Author__c, Created_At__c FROM Legacy_Case_Comment__c limit 1');
        Database.executeBatch(cc);
        test.stopTest();
    }
}