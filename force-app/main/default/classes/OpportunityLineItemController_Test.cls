@isTest
public class OpportunityLineItemController_Test{
    @TestSetup static void setuprecs(){
        Account acc = new Account(name='testaccount');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'test opp', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today());
        insert opp;
    }
    static testmethod void testopplineitemctrl(){
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id from Opportunity];
        OpportunityLineItemController ctrl = new OpportunityLineItemController();
        System.debug(ctrl.url);
        if(!acc.isEmpty()){
            ctrl.accrecordId = acc[0].Id;
            System.debug(ctrl.accrecord);
        }
        if(!opp.isEmpty()){
            ctrl.opptyrecId = opp[0].Id;
            System.debug(ctrl.opptyrec);
            System.debug(ctrl.olilst);
        }
    }
}