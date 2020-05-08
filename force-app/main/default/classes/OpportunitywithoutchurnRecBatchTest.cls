@isTest
private class OpportunitywithoutchurnRecBatchTest {
   /*  @testSetup static void setup() {
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          email = 'test@gmail.com',
                          username = 'testuser@zscalar.com.churnOppEmailTest', 
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
     
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        acc.CSM_Name_New__c = u.Id;
        acc.TAM_Name_New__c = u.Id;
        acc.CloudArchitect__c = c1.Id;
        insert acc;
        TriggerUtility.prospectTypeUpdExecuted();
        TriggerUtility.realignPatch();
        Id rectype = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '11 - Closed Lost', RecordtypeId = rectype, CloseDate=system.today());
        opp.Primary_Reason_For_Loss__c = 'Price was too high';
        opp.Secondary_Reason_For_Loss__c  = 'Price was too high';
        opp.Deal_Lost_To__c = 'Akamai (ETP)';
        insert opp;
        
        Apttus_Proposal__Proposal__c app = new Apttus_Proposal__Proposal__c();
        app.Apttus_Proposal__Opportunity__c = opp.Id;
        app.APTS_Current_Quote_MRR__c = 6064.71;
        app.APTS_Original_Quote_MRR__c = 9435.12;
        insert app;
    } */
    
    static testMethod void testmethod1(){
		Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u = new User(firstname= 'fname',
                          lastname='lanme',
                          Alias='testali',
                          email = 'test@gmail.com',
                          username = 'testuser@zscalar.com.churnOppEmailTest', 
                          profileId= p.id, 
                          Full_Name__c='testfull',
                          emailencodingkey='UTF-8',
                          languagelocalekey='en_US',
                          localesidkey='en_US',
                          timezonesidkey='America/Los_Angeles');
        insert u;  
		
        Test.startTest();
        List<User> userLst = [SELECT Id, Name, Manager.Email, Email FROM User Where UserName = 'testuser@zscalar.com.churnOppEmailTest'];
        OpportunitywithoutchurnRecBatch obj = new OpportunitywithoutchurnRecBatch();
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null, userLst);
        obj.Finish(null);
        Test.stopTest();
            
    }
}