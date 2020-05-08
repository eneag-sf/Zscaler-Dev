@isTest
public class LegacyCaseCommentsControllerTest {
    public static testMethod void genericFeedItemTest(){  
        Account acc= new Account();
        acc.Name = 'test';
        insert acc;
        
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        c.AccountId = acc.Id;
        insert c;
        
        Case c1 = new Case();
        c1.Status = 'Closed';
        c1.Subject = 'test';
        c1.Description = 'test dessc';
        c1.AccountId = acc.Id;
        insert c1;
        
        Case c2 = new Case();
        c2.Status = 'New';
        c2.Subject = 'test';
        c2.Description = 'test dessc';
        c2.AccountId = acc.Id;
        insert c2;
        
        
        
        test.startTest();
        PageReference myVfPage = Page.LegacyCaseComments;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Id',c1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(c1);
        LegacyCaseCommentsController ac = new LegacyCaseCommentsController(sc);
        test.stopTest();
    }
}