@isTest
private class opportunitiesPostPatchBatchTest {

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
       
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
       
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        
    }  
    
     static testMethod void testmethod1(){
        //list<Account> acclist = [select id,Patch__c from Account limit 1];
        Test.startTest();
         List<Patch__c> palist = [select id,PatchTeam__c from Patch__c limit 1]  ;
         List<opportunity> opplist = [Select Id,Name,
                                           AccountId,
                                           StageName,
                                           Days_in_Current_Stage__c,
                                           type,
                                           Last_Stage_Changed_Date__c,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity  where Account.Patch__c =: palist[0].id LIMIT 1];  
            
           
        if(!opplist.isEmpty()){
            
              
           list<id>ids = new list<id>();
           for(Patch__c p :palist){
               
               ids.add(p.id);
           }
            opportunitiesPostPatchBatch obj = new opportunitiesPostPatchBatch(ids);
           //  DataBase.executeBatch(obj);
             Database.QueryLocator ql = obj.start(null);
             obj.execute(null,opplist);
             obj.Finish(null);
            
            
            List<opportunity> opplistrec = [Select Id,Name,
                                           AccountId,
                                           StageName,
                                           Days_in_Current_Stage__c,
                                           type,
                                           Last_Stage_Changed_Date__c,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,
                                           Primary_Quote_Exception__c
                                           from opportunity  where Id =: opplist[0].id];
                                           
               // List<Account> accreclist = [Select Id,Patch__c from Account  where Patch__c =: palist[0].id];
                                           
           
           system.assertEquals(1, opplistrec.size());
          Test.stopTest();
            
        }
    }

}