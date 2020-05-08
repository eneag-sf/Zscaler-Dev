@isTest
private class POCSetCurrentPhaseTest{
    @isTest(seeAllData=false)
    static void TestCurrentPhase(){
        
         Account acc = new account();
         Acc.Name = 'Test Data';
         insert acc;
         contact con = new contact();
         con.FirstName = 'Test';
         con.lastName = 'Contact';
         con.AccountId = acc.Id;
         insert con;
         contact con1 = new contact();
         con1.FirstName = 'Test';
         con1.lastName = 'Contact';
         con1.AccountId = acc.Id;
         insert con1;
         Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
         sci.Date__c = system.today();
         sci.Interaction_With__c = 'Test Data';
         sci.I_am_the__c = 'Organizer';
         sci.Next_Steps__c = 'F2F Meeting';
         sci.Meeting_Notes__c = 'Important conv';
         sci.Account_Name__c = acc.Id;
         insert sci;
         
        POC_Phase__c vPOC = new POC_Phase__c(POC_Phase__c = '1-Establishing POC Plan & Success Criteria',Significant_Customer_Interaction__c = sci.id);
        insert vPOC;
        vPoc.POC_Phase__c = '2-Documenting Detailed POC Plan';
        update vPoc;
        delete vPOC;
        POC_Phase__c vPOC1 = new POC_Phase__c(POC_Phase__c = '1-Establishing POC Plan & Success Criteria',Significant_Customer_Interaction__c = sci.id);
        insert vPOC1;
        POC_Phase__c vPOC2 = new POC_Phase__c(POC_Phase__c = '2-Documenting Detailed POC Plan',Significant_Customer_Interaction__c = sci.id);
        insert vPOC2;
        
       
    }
}