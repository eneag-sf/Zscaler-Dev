public class FS_TestTriggers {
    static testMethod void testCopyAccountOwner() {
        User acctOwner = newUser('AcctOwner');
        User oppOwner = newUser('OppOwner');
        insert new User[] {acctOwner, oppOwner};
        Account acct = new Account(name='test', owner=acctOwner);
        insert acct;
        Opportunity opp = new Opportunity(
            name = 'test opp',
            owner = oppOwner,
            closedate = Date.today(),
            amount = 54,
            probability = 54,
            stagename = label.Stage_1_Alignment /*'Qualification'*/
        );
        insert opp;
        opp = [select FS_Account_Owner__c from opportunity where id = :opp.id];
        System.assertEquals(acct.OwnerId, opp.FS_Account_Owner__c);
    }

    static User newUser(String uniqueTag) {
        Id stdProfileId = [select id from profile where usertype='Standard' and name='Standard User' limit 1].id;
        String email = 'amorgan_TestFunnelSourceOpportunityOwner' + uniqueTag.replace(' ', '_') + '@example.com';
        String nick = 'FS_' + uniqueTag.substring(0,5);
        User user = new User(
            FirstName = 'Test User ',
            LastName = uniqueTag,
            CompanyName = 'Test Company',
            Username = email,
            Email = email,
            Alias = nick,
            CommunityNickname = 'FS_' + uniqueTag,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = stdProfileId, // Standard User
            LanguageLocaleKey = 'en_US'
        );
        return user;
    }
}