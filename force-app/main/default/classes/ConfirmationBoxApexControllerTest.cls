@isTest
public class ConfirmationBoxApexControllerTest {
    public static testMethod void ConfirmationBoxApexTest(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        case cs = new case();
        cs.Status ='New';
        cs.Subject ='test sub';
        cs.AccountId = acc.Id;
        insert cs;
        String teamRoleId = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'Customer' limit 1].Id;
        Contact ct = new Contact();
        ct.LastName = 'tests';
		ct.Email = 'test@fsdh.sgo';
		insert ct; 
        CaseTeamMember cst = new CaseTeamMember();
        cst.MemberId = ct.Id;
        cst.ParentId = cs.Id;
        cst.TeamRoleId = teamRoleId;
        insert cst;
        test.startTest();
        ConfirmationBoxApexController.sendMail(cs.Id, 'emailBody');
        ConfirmationBoxApexController.getEmailText(cs.Id);
        ConfirmationBoxApexController.setEmailTextOnCase(cs.Id,'emailbody');
        test.stopTest();
    }
}