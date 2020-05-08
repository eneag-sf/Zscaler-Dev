@isTest
public class CaseDetailLWCControllerTest {
    public static testMethod void CaseDetailLWCTest(){
        Contact ct = new Contact();
        ct.LastName = 'tests';
		ct.Email = 'test@fsdh.sgo';
		insert ct; 
        Contact ct1 = new Contact();
        ct1.LastName = 'tests';
		ct1.Email = 'test@fsdh.sgo';
		insert ct1; 
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        insert c;
        Attachment at = new Attachment();
        at.Name = 'tewsyts';
        at.ParentId = c.id;
        at.Body = blob.valueOf('tsetset');
        insert at;
        CaseComment cc = new CaseComment();
        cc.CommentBody = 'tesys';
        cc.ParentId = c.Id;
        
        Contact ct2 = new Contact();
        ct2.LastName = 'test';
        ct2.Email = 'srfh@dfdfhdfh.sfg';
        String teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
        CaseTeamMember cst = new CaseTeamMember();
        cst.MemberId = ct.Id;
        cst.ParentId = c.Id;
        cst.TeamRoleId = teamRoleId;
        insert cst;
        
        
        
        test.startTest();
        CaseDetailLWCController.updateCase(c.Id);
        CaseDetailLWCController.fetchCase(c.Id);
        CaseDetailLWCController.updateContact(ct,c.id);
        CaseDetailLWCController.deleteContact(ct.id,c.id);
        CaseDetailLWCController.createContact(ct2, c.Id);
        CaseDetailLWCController.fetchEmailList(c.Id);
        CaseDetailLWCController.getDomains();
        CaseDetailLWCController.addUserToCaseTeamMember(userinfo.getUserId(),c.id);
        CaseDetailLWCController.addMultiContactToCaseTeamMember(new List<String>{ct.Id},c.id);
        CaseDetailLWCController.addMultiUserToCaseTeamMember(new List<String>{userinfo.getUserId()},c.id);
        CaseDetailLWCController.addContactToCaseTeamMember(ct1.Id,c.id);
        CaseDetailLWCController.fetchUserCaseTeamMember(c.Id);
        CaseDetailLWCController.fetchAccountContacts(c.Id);
        CaseDetailLWCController.fetchUsers(c.Id);
        CaseDetailLWCController.updatecaseCCList(new List<Case>{c});
        
        
        
        test.stopTest();
    }
}