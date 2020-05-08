@isTest
public class CloneMeetingControllerTest {
    public static testMethod void CloneMeetingControllerTest(){
        Contact ct = new Contact();
        ct.LastName = 'tests';
		ct.Email = 'test@fsdh.sgo';
		insert ct; 
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        insert c;
        
        String teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
        CaseTeamMember cst = new CaseTeamMember();
        cst.MemberId = ct.Id;
        cst.ParentId = c.Id;
        cst.TeamRoleId = teamRoleId;
        insert cst;
        
        test.startTest();
        CloneMeetingController.cloneCase(c.Id);
        test.stopTest();
    }
}