@isTest 
public class CreateCommunityUserTest {
    public static testMethod void CreateCommunityTest(){
        Account act = new Account();
        act.name = 'test';
        insert act;
        Contact ct = new Contact();
        ct.AccountId = act.Id;
        ct.LastName = 'test';
        ct.Email = 'test@test.com';
        insert ct;
        test.startTest();
        String query = 'select id,email,name,lastname,firstname,AccountId,Account.Name,Account.OwnerId,Account.Owner.UserRoleId,Account.Owner.UserRole.Name from Contact';
        CreateCommunityUser cu = new CreateCommunityUser(query);
        Database.executeBatch(cu);
        test.stopTest();
    }
}