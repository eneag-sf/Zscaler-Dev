@istest
public class GOVPRODSYNC_Tests {
    static testMethod void getlstofleads() {
        Lead ld = new Lead();
        ld.firstname = 'John';
        ld.lastname = 'John';
        ld.company = 'ABC';
        ld.email = 'abc@gmail.com';
        ld.Federal_Change__c = system.now();
        insert ld;
        
        String startdate = date.today().year() + '-' + date.today().month() + '-' + date.today().day() + ' 00:00:00';
        String enddate = date.today().year() + '-' + date.today().month() + '-' + date.today().day() + ' 23:59:59';
        RestRequest req = new RestRequest();
        req.params.put('type', EncodingUtil.urlEncode('get_leads','UTF-8'));
        req.params.put('Start_Date', EncodingUtil.urlEncode(startdate,'UTF-8'));
        req.params.put('End_Date', EncodingUtil.urlEncode(enddate,'UTF-8'));
        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        GOVPRODSYNC.doGet();

        Test.stopTest();

    }
    static testMethod void testaccandopplogic() {
        Test.startTest();
        try{
        List<Account> acclst = new List<Account>();
        Account acc = new Account(Name = 'accname' );
        Account acc1 = new Account(Name = 'accname');
        acclst.add(acc);
        acclst.add(acc1);
        insert acclst;
        Map<String, Account> accmap = new map<String, Account>{'Ultimate Parent' => acc1, 'Account' => acc};
        Opportunity opp = new Opportunity(name='opp1', stagename = label.Stage_1_Alignment /*'Prospect'*/, closedate = date.today(),accountId = acc.Id);
        List<Opportunity> opplst = new List<Opportunity>{opp};
        Partner pt = new partner();
        pt.AccountToId = acc1.Id;
        pt.IsPrimary = true;
        pt.Role = 'Reseller';
        pt.OpportunityId = opp.Id;
        List<Partner> pl = new List<Partner>{pt};
        
        
        
            GOVPRODSYNC.doPost(accmap, opplst, pl,true);
        
        //try{
            delete acclst[0];
            SYNCAccdetails.doPost(accmap);
       // }catch(Exception ex){
        
       // }
        Test.stopTest();
            }catch(Exception ex){
        
        }

    }
    
    static testMethod void testscilogic() {
        List<Account> acclst = new List<Account>();
        Account acc = new Account(Name = 'accname' );
        Account acc1 = new Account(Name = 'accname');
        acclst.add(acc);
        acclst.add(acc1);
        insert acclst;
        Map<String, Account> accmap = new map<String, Account>{'Ultimate Parent' => acc1, 'Account' => acc};
        Opportunity opp = new Opportunity(name='opp1', stagename = label.Stage_1_Alignment /*'Prospect'*/, closedate = date.today(),accountId = acc.Id);
        List<Opportunity> opplst = new List<Opportunity>{opp};
        Partner pt = new partner();
        pt.AccountToId = acc1.Id;
        pt.IsPrimary = true;
        pt.Role = 'Reseller';
        pt.OpportunityId = opp.Id;
        List<Partner> pl = new List<Partner>{pt};
        
        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci.Date__c = system.today();
        sci.Interaction_With__c = 'Test Data';
        sci.I_am_the__c = 'Organizer';
        sci.Next_Steps__c = 'F2F Meeting';
        sci.Meeting_Notes__c = 'Important conv';
        sci.Account_Name__c = acc.Id;
        sci.Primary_Topic_Covered__c = 'Solution Architecture';
        
        SCI_Zscaler_Attendee__c attendee1 = new SCI_Zscaler_Attendee__c(
                                                    Attendee_Name__c = userinfo.getuserId(),
                                                    Organizer__c = true,
                                                    Participation__c = 'In Person'
                                                
        );
        
        SCI_External_Attendee__c exAttendee1 = new SCI_External_Attendee__c(
                                                    Type__c = 'Customer'
                                                );
        

        
        Test.startTest();
        //try{
        TriggerUtility.oppPatchManagerAfterInsertExecuted();
        TriggerUtility.oppPatchManagerAfterUpdateExecuted();
            SCISYNC.doPost(accmap, opplst, pl,true, new List<Significant_Customer_Interaction__c>{sci}, new List<SCI_Zscaler_Attendee__c>{attendee1}, new List<SCI_External_Attendee__c>{exAttendee1});
        //}catch(Exception ex){}
        
        Test.stopTest();

    }
}