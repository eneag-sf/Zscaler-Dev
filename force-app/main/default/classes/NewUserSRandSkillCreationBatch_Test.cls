@isTest
public class NewUserSRandSkillCreationBatch_Test {
    @IsTest
    static void test1(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserPermissionsSupportUser = true,
            service_level__c = 'L1',
            UserRoleId = r.Id
        );
        insert u;
        test.startTest();
        NewUserSRandSkillCreationBatch batch = new NewUserSRandSkillCreationBatch();
        batch.errorlst.add('abc');
        batch.successlst.add('abc');
        Database.executeBatch(batch,200);
        Test.stopTest();
    }
}