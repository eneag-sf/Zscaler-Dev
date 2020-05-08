@isTest
public class contactsPostPatchBatchTest {
    
    @testSetup
    static void setup() {
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='acme', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping;
        PatchFieldMapping__c mapping2 = new PatchFieldMapping__c(Name='acme acc', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping2;
        
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pateam.Id, Role__c='acme', User__c=UserInfo.getUserId());
        insert member;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=pateam.Id);
        insert patch;
        Lead lead = new Lead(LastName='acme', Company='acme', Patch__c=patch.Id, IsConverted=false);
        Insert lead;
        lead.PatchLocked__c = true;
        lead.Patch__c=patch.Id;
        update lead;
        Account acc =new Account(Name='acme acc');
        Insert acc;
        acc.Patch__c = patch.Id;
        acc.PatchLocked__c = true;
        update acc;
        List<contact> conListRef = new List<contact>();
        contact con =new contact(FirstName = 'Test',LastName ='Test',AccountId = acc.id,ZPA_Manager__c=UserInfo.getUserId(),ZPA_SE__c=UserInfo.getUserId());
        conListRef.add(con);
        Insert conListRef;
    }  
    
    static testMethod void testAccountPostPatch(){
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){
            Test.startTest();
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testAccountManager(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'Account Manager';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testSalesEngineer(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'Sales Engineer';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testLeadDevelopment(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'Lead Development';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testCustomerAdvocate(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'Customer Advocate';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testChannelManager(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'Channel Manager';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testZPAManager(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'ZPA Manager';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testZPASE(){
        PatchTeamMember__c patchMember = [Select id,Role__c,User__c From PatchTeamMember__c Where User__c=:UserInfo.getUserId() Limit 1];
        patchMember.Role__c = 'ZPA SE';
        update patchMember;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        
        if(!acclist.isEmpty()){ 
            Test.startTest();
            contactsPostPatchBatch.SalesTeam w = new contactsPostPatchBatch.SalesTeam(patchMember);
            contactsPostPatchBatch.SalesTeam ww = new contactsPostPatchBatch.SalesTeam(w,patchMember);
            contactsPostPatchBatch job = new contactsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
}