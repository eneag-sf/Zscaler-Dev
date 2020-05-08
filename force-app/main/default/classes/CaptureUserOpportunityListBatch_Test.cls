@isTest
public class CaptureUserOpportunityListBatch_Test{
    
    static testmethod void testopptysnapshotbatch(){
        User u1 = [Select Id from User where isActive = true and Profile.Name = 'System Administrator' and ManagerId != null limit 1];
        System.RunAs(u1){
            List<Opportunity> opplst = new List<Opportunity>();
            
            Opportunity op1 = new Opportunity();
            op1.Name = 'TEst op1';
            op1.StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/;
            op1.Type = 'New Business';
            op1.closedate = date.today().adddays(-60);
            opplst.add(op1);
            
            Opportunity op2 = new Opportunity();
            op2.NextStep  = 'Have to accomplish the next step';
            op2.Name = 'TEst op2';
            op2.StageName = label.Stage_4_Economic_Buyer_Signoff/*'7 - Negotiation & Review'*/;
            op2.Type = 'New Business';
            op2.closedate = date.today().adddays(40);
            op2.Last_Next_Step_Updated_Date__c = date.today().adddays(-30);
            opplst.add(op2);
            
            Opportunity op3 = new Opportunity();
            op3.NextStep  = '';
            op3.Name = 'TEst op3';
            op3.StageName = label.Stage_4_Economic_Buyer_Signoff/*'7 - Negotiation & Review'*/;
            op3.Type = 'New Business';
            op3.closedate = date.today().adddays(40);
            op3.Last_Next_Step_Updated_Date__c = date.today().adddays(-30);
            opplst.add(op3);
            
            Opportunity op4 = new Opportunity();
            op4.Name = 'TEst op4';
            op4.StageName = label.Stage_4_Economic_Buyer_Signoff/*'9 - Deal Stuck'*/;
            op4.Type = 'New Business';
            op4.closedate = date.today().adddays(40);
            op4.Last_Next_Step_Updated_Date__c = date.today().adddays(10);
            opplst.add(op4);
            
            Opportunity op5 = new Opportunity();
            op5.Name = 'TEst op5';
            op5.StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/;
            op5.Type = 'New Business';
            op5.closedate = date.today().adddays(-60);
            opplst.add(op5);
            
            Opportunity op6 = new Opportunity();
            op6.NextStep  = 'Have to accomplish the next step';
            op6.Name = 'TEst op6';
            op6.StageName = label.Stage_4_Economic_Buyer_Signoff/*'7 - Negotiation & Review'*/;
            op6.Type = 'New Business';
            op6.closedate = date.today().adddays(40);
            op6.Last_Next_Step_Updated_Date__c = date.today().adddays(-30);
            opplst.add(op6);
            
            Opportunity op7 = new Opportunity();
            op7.NextStep  = '';
            op7.Name = 'TEst op7';
            op7.StageName = label.Stage_4_Economic_Buyer_Signoff/*'7 - Negotiation & Review'*/;
            op7.Type = 'New Business';
            op7.closedate = date.today().adddays(40);
            op7.Last_Next_Step_Updated_Date__c = date.today().adddays(-30);
            opplst.add(op7);
            
            Opportunity op8 = new Opportunity();
            op8.Name = 'TEst op8';
            op8.StageName = label.Stage_4_Economic_Buyer_Signoff /*'9 - Deal Stuck'*/;
            op8.Type = 'New Business';
            op8.closedate = date.today().adddays(40);
            op8.Last_Next_Step_Updated_Date__c = date.today().adddays(10);
            opplst.add(op8);
            
            insert opplst;
            test.startTest();
            Database.executeBatch(new CaptureUserOpportunityListBatch(),2000);
            test.stoptest();
        }
    }


}