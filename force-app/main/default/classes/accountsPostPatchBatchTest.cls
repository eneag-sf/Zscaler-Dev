@isTest
public class accountsPostPatchBatchTest {
    
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
            accountsPostPatchBatch job = new accountsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testAccountPostPatch2(){
        PatchTeamMember__c pteam = [Select id,Role__c from PatchTeamMember__c Where Role__c='acme' and User__c=:UserInfo.getUserId()];
        pteam.Role__c = 'Account Manager';
        update pteam;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        update acclist;
        
        if(!acclist.isEmpty()){
            Test.startTest();
            accountsPostPatchBatch job = new accountsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testAccountPostPatch3(){
        PatchTeamMember__c pteam = [Select id,Role__c from PatchTeamMember__c Where Role__c='acme' and User__c=:UserInfo.getUserId()];
        pteam.Role__c = 'Area Director';
        update pteam;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        update acclist;
        
        if(!acclist.isEmpty()){
            Test.startTest();
            accountsPostPatchBatch job = new accountsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testAccountPostPatch4(){
        PatchTeamMember__c pteam = [Select id,Role__c from PatchTeamMember__c Where Role__c='acme' and User__c=:UserInfo.getUserId()];
        pteam.Role__c = 'Channel Manager';
        update pteam;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        update acclist;
        
        if(!acclist.isEmpty()){
            Test.startTest();
            accountsPostPatchBatch job = new accountsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }
    static testMethod void testAccountPostPatch5(){
        PatchTeamMember__c pteam = [Select id,Role__c from PatchTeamMember__c Where Role__c='acme' and User__c=:UserInfo.getUserId()];
        pteam.Role__c = 'Customer Advocate';
        update pteam;
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
        system.debug('the account list is' + acclist);
        list<id>ids = new list<id>();
        for(Account acc :acclist){
            ids.add(acc.Patch__c);
        }
        update acclist;
        
        if(!acclist.isEmpty()){
            Test.startTest();
            accountsPostPatchBatch job = new accountsPostPatchBatch(ids);
            Database.executeBatch(job, 1);
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
            system.assertEquals(1, accreclist.size());
        }
    }

    
}