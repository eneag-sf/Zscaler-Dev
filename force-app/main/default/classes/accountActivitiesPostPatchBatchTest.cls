@isTest
public class accountActivitiesPostPatchBatchTest {
    
    @testSetup static void setup() {
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
       
       Task ta = new Task();
       ta.Subject='test';
       ta.Status='New';
       ta.Priority='Normal';
       ta.whatId = acc.id;
       insert ta;
       
        Event ev = new Event();
        ev.WhatID  = acc.id;
        ev.StartDateTime=system.today();
        ev.EndDateTime=system.today()+5;
        insert ev;
       
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        
    }  
    
     static testMethod void testmethod1(){
        List<Account> acclist = [Select Id, Patch__c from Account where Patch__c != null];
         //  List<Patch__c> palist = [select id,PatchTeam__c from Patch__c limit 1]  ;  
           list<id>ids = new list<id>();
           for(Account acc :acclist){
               
               ids.add(acc.Patch__c);
           }
           
        if(!acclist.isEmpty()){
            Test.startTest();
            accountActivitiesPostPatchBatch obj = new accountActivitiesPostPatchBatch(ids);
           //  DataBase.executeBatch(obj);
             Database.QueryLocator ql = obj.start(null);
             obj.execute(null,acclist);
             obj.Finish(null);
            Test.stopTest();
            
            List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: ids ];
                                           
           
           system.assertEquals(1, accreclist.size());
          
            
        }
    }

}