@isTest
public class OpportunityNOTRAHandlerTest {
    @testSetup static void setup() {
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc1;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', 
                                            Primary_Quote_Exception__c  = true, 
                                            AccountId = acc.Id, 
                                            StageName = label.Stage_1_Alignment, 
                                            CloseDate = Date.newInstance(system.today().Year(), 2, 1), 
                                            Type = 'Existing Customer (Renewal)',
                                            Contract_End_Date_New__c = system.Today() + 1,
                                            CRO_Forecast_Category__c = 'Commit');
        insert opp;
      
    }

    @isTest static void doOpportunityNOTRAHandlerTest(){
        Test.startTest();
        Opportunity Opp = [select Id,Name,AccountId,CloseDate  from Opportunity limit 1];
        opp.CloseDate = Date.newInstance(system.today().Year(), 3, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 5, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 8, 1);
        
        update opp;
        
        opp.CloseDate = Date.newInstance(system.today().Year(), 11, 1);
        
        update opp;

        Test.stopTest();
    }
}