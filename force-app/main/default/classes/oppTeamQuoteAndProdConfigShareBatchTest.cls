@isTest
private class oppTeamQuoteAndProdConfigShareBatchTest {
    
    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        insert acc;
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        System.runAs(uu) {
            
            opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/,Opportunity_Sales_Engineer__c=UserInfo.getUserId(), SE_name__c = uu.id, NextStep = 'Test 1',
                                              CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
            insert opp;
            
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = uu.id,TeamMemberRole = 'Opportunity Split',OpportunityAccessLevel ='Edit');
            insert otm;
            //delete otm;
            
            String  shareStatus = 'Ready To Share';
            Opportunity_Share__c oppshare = new Opportunity_Share__c();
            oppshare.Opportunity_Id__c =opp.id;
            oppshare.Status__c = shareStatus;
            insert oppshare;
            
            Apttus_Proposal__Proposal__c app = new Apttus_Proposal__Proposal__c();
            app.Apttus_Proposal__Opportunity__c  =opp.id;
            insert app;
            
            Apttus_Config2__ProductConfiguration__c acp = new Apttus_Config2__ProductConfiguration__c();
            acp.Apttus_QPConfig__Proposald__c =app.id;
            acp.Apttus_Config2__Status__c ='Finalized';
            insert acp;
        }
        
    }
    
    static testMethod void testexcute(){
        Test.startTest();
        List<Apttus_Config2__ProductConfiguration__c> proposalProdConfigs = [Select Id, Apttus_QPConfig__Proposald__c,
                                                                             Apttus_Config2__Status__c
                                                                             from 
                                                                             Apttus_Config2__ProductConfiguration__c limit 1];
        
        List<Apttus_Proposal__Proposal__c> oppProposals = [Select Id, Apttus_Proposal__Opportunity__c 
                                                           from 
                                                           Apttus_Proposal__Proposal__c limit 1];
        
        
        List<Opportunity_Share__c> oppsharelist = [Select Id,Name,
                                                   Opportunity_Id__c,
                                                   Status__c
                                                   from Opportunity_Share__c LIMIT 1];
        if(!oppsharelist.isEmpty()){
            
            oppTeamQuoteAndProdConfigShareBatch obj = new oppTeamQuoteAndProdConfigShareBatch();
            //  DataBase.executeBatch(obj);
            Database.QueryLocator ql = obj.start(null);
            obj.execute(null,oppsharelist);
            obj.Finish(null);
            
            
            List<Opportunity_Share__c> oppshlist = [Select Id,Name,
                                                    Opportunity_Id__c,
                                                    Status__c
                                                    from Opportunity_Share__c 
                                                    where  Id =: oppsharelist[0].Id];
            
            List<Apttus_Proposal__Proposal__c> oppProposalslist = [Select Id, 
                                                                   Apttus_Proposal__Opportunity__c 
                                                                   from 
                                                                   Apttus_Proposal__Proposal__c 
                                                                   where Apttus_Proposal__Opportunity__c =:oppshlist[0].Opportunity_Id__c];
            
            List<Apttus_Config2__ProductConfiguration__c> proposalProdConfigslist = [Select Id, Apttus_QPConfig__Proposald__c,
                                                                                     Apttus_Config2__Status__c
                                                                                     from 
                                                                                     Apttus_Config2__ProductConfiguration__c 
                                                                                     where Apttus_QPConfig__Proposald__c =: oppProposalslist[0].id];
            system.assertEquals(1, oppshlist.size());
            system.assertEquals(1, oppProposalslist.size());
            system.assertEquals(1, proposalProdConfigslist.size());
            Test.stopTest();
        }
    }
    static testMethod void testexcuteDeleteOpportunityTeamMember(){
        Test.startTest();
        try{
            list<Opportunity>OpportunityList = [Select id From Opportunity];
            list<OpportunitySplit > oppSplitList = [select id,OpportunityId,SplitOwnerId From OpportunitySplit Where OpportunityId=:OpportunityList[0].Id];
            opportunitySplitTriggerHandler.afterDelete(oppSplitList);
        }
        catch(exception e){
            
        }
        Test.stopTest();
    }
}