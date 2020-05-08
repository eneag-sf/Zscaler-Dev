Public Class Update_OwnerDetails_On_Owner_UpdateTest{

     Private Static testMethod void testTriggerFORUser(){
        Opportunity o = new Opportunity();
        User U =[SELECT id FROM User WHERE ID = :Userinfo.getUserID()];
        o.OwnerID = u.id;
        o.Name = 'TestName';
        o.StageName = Label.Stage_1_Alignment /*'Prospecting'*/;
        o.Forecast_Category__c ='Pipeline';
        o.Type = 'TestType';
        o.CloseDate = Date.today();
        o.Expected_Term_Months__c = 12;
        o.Amount = 4000;
        o.Product_Type__c = 'TestOrder';
        o.Sales_Engineer__c = 'se@email.com';
        o.Selling_Theatre__c = 'Rest of World';
        o.Proposed_Number_of_Users__c = 1;
        o.LeadSource = 'Website';
         Insert o;
       } 
   }