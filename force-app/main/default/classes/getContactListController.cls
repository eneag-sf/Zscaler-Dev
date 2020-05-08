public without sharing class getContactListController {
    @AuraEnabled(cacheable = true)
    public static AccountTeamWrapper getContactList() {
        
        List<User> userList = [SELECT Id,FirstName, LastName , AccountId, Account.Name, Phone, Email FROM User WHERE Id  = :UserInfo.getUserId() LIMIT 1];
        AccountTeamWrapper atw = new AccountTeamWrapper();
        if(!userList.isEmpty()){

            List<AccountTeamMember> accountTeamMemberList = [SELECT AccountId, Id, User.Name,
             User.Phone, User.Email, TeamMemberRole, Title
             FROM AccountTeamMember WHERE AccountId = :userList[0].AccountId AND
            TEAMMEMBERROLE IN ('Technical Account Manager','Customer Success Manager', 'Sales Engineer') ];
            system.debug(accountTeamMemberList);
            
            atw.accteamlst = accountTeamMemberList;
            atw.accname = userList[0].Account.Name;
            atw.showaccteam = accountTeamMemberList != null && !accountTeamMemberList.isEmpty();
        }
        return atw;
    }
    public class AccountTeamWrapper{
        @AuraEnabled
        public List<AccountTeamMember> accteamlst;
        @AuraEnabled
        public String accname;
        @AuraEnabled
        public Boolean showaccteam;
    }
}