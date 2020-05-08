@istest
public class SYNCOppdetails_Test{
    
    static testMethod void testopplogic() {
        List<Account> acclst = new List<Account>();
        Account acc = new Account(Name = 'accname' );
        Account acc1 = new Account(Name = 'accname');
        acclst.add(acc);
        acclst.add(acc1);
        insert acclst;
        Opportunity opp = new Opportunity(name='opp1', stagename = Label.Stage_1_Alignment /*'Prospect'*/, closedate = date.today(),accountId = acc.Id, Approved_Pzen_ME__c = true, Approved_Equipment_Request__c = true, Approved_DLP_PZen_ER__c = true,Approved_Equipment_Request_VZEN__c = true);
        insert opp;
        Map<String, Opportunity> oppmap = new Map<String, Opportunity>{opp.Id => opp};
        
        Test.startTest();
        try{
            SYNCOppdetails.doPost(oppmap);
        }catch(Exception ex){
        
        }
    }
}