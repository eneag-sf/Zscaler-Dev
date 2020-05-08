@isTest
private class BatchSendInternalHandoffEmailTest {

 @testSetup static void setup() {
     
     Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
                User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          Email = 'test@gmail.com',
                          username= 'testuser@zscalar.com', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
                insert u;   
     
     Account acc1 = new Account(name = 'test');
     insert acc1;
     contact c1 = new contact(accountid = acc1.Id,lastname = 'abc', email='abc@abc.com',Contacts_that_matter__c = true, Active__c = false, Champion__c = true);
     insert c1;
     
    PatchTeam__c SalesTerritory = new PatchTeam__c();
    SalesTerritory.Name = 'Test';
    SalesTerritory.Theater__c = 'CHANNEL';
    SalesTerritory.Account_Manager__c = u.Id;
    SalesTerritory.Theater__c = 'CHANNEL';
    SalesTerritory.Region__c = 'Channel SP/SI';
    SalesTerritory.District__c = 'Channel SP';
    SalesTerritory.Area__c = 'Channel SP';
    
    insert SalesTerritory;

     Account acc = new Account();
     acc.Name='testacc';
     acc.Type ='Prospect';
     acc.CSM_Name_New__c = u.Id;
     acc.TAM_Name_New__c = u.Id;
     //acc.CloudArchitect__c = c1.Id;
     acc.Account_Manager__c = u.Id;
     acc.Channel_Manager__c = u.Id;
     acc.Customer_Advocate__c = u.Id;
     acc.Area_Director__c = u.Id;
     acc.Sales_Territory__c = SalesTerritory.Id;
     insert acc;
       
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/,SE_name__c = u.Id, NextStep = 'Test 1',Amount = 1000000,
                                 Type = 'New Business',Last_Stage_Changed_Date__c =system.today()-27,CloseDate = system.Today()+10, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp;
        
        
       
       
            
    }
    
    static testMethod void testmethod1(){
        list<Account> acclist = [select id from Account limit 1];
         List<opportunity> opplist = [Select Id,Name,
                                           AccountId,
                                           StageName,
                                           Days_in_Current_Stage__c,
                                           type,Amount,
                                           Last_Stage_Changed_Date__c,
                                           Opportunity_Sales_Engineer__c,
                                           SE_name__c,SE_name__r.Email,
                                           Architect__c,SE_Name__r.name,  
                                           Primary_Quote_Exception__c,
                                           Premium_Support__c
                                           from opportunity Where AccountId != null LIMIT 1];
                    
        if(!opplist.isEmpty()){
            Test.startTest();
           
             BatchSendInternalHandoffEmail obj = new BatchSendInternalHandoffEmail();
           //  DataBase.executeBatch(obj);
             Database.QueryLocator ql = obj.start(null);
             obj.execute(null,opplist);
             obj.Finish(null);
            Test.stopTest();
            
            List<opportunity> opplistrecs = [Select Id,AccountId,
                                           StageName,
                                           Opportunity_Sales_Engineer__c,
                                           Last_Stage_Changed_Date__c,
                                           SE_name__c,Amount,
                                           Architect__c,
                                           Primary_Quote_Exception__c
                                           from opportunity
                                           where  Id =: opplist[0].Id];
                list<Account> accreclist = [select id from Account where Id =: opplistrecs[0].AccountId];
            system.assertEquals(1, opplist.size());
            
        }
       
    }

}