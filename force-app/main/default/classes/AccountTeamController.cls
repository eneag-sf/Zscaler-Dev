public Without Sharing class AccountTeamController {
    @AuraEnabled(cacheable=true)
    public static List<AccountTeamMember> getAccountTeamList() {
        
        User ur = [select id,AccountId from User where id =: UserInfo.getUserId()];
        System.debug(ur);
        Id accId = ur.AccountId;
        return Database.query('SELECT Id,TeamMemberRole,User.name,User.Full_Name__c,User.Email FROM AccountTeamMember where AccountId =:accId'+
            +' and (TeamMemberRole = \'Overlay Team Member\' OR TeamMemberRole = \'TAM\' OR TeamMemberRole = \'CSM\')');
    }
}