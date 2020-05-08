public with sharing class TakeOwnershipPassThruCtrl{

    //class fields
    private Case cs;

    //constructor
    public TakeOwnershipPassThruCtrl(ApexPages.StandardController stdController) {
        this.cs = (Case)stdController.getRecord();
    }
    
    //methods
    public PageReference redir(){
        cs.OwnerId = UserInfo.getUserId();
        update cs;
        PageReference pg = new PageReference('/' + cs.id);
        pg.setRedirect(true);
        return pg;
    }
    
    //test
    static testMethod void TakeOwnershipPassThruCtrlTest(){
        Case c = new Case();
        Insert c;
        TakeOwnershipPassThruCtrl ptc = new TakeOwnershipPassThruCtrl(new ApexPages.StandardController(c));
        PageReference pg = ptc.redir();
        System.assert(c.OwnerId == UserInfo.getUserId());
    }
}